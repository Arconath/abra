#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(git -C "$script_dir" rev-parse --show-toplevel)"

case "${1:-static}" in
  static)
    ;;
  --runtime=podman)
    test "$(id -u)" -ne 0
    test ! -S /var/run/docker.sock
    test -z "${DOCKER_HOST:-}"
    test -z "${CONTAINER_HOST:-}"
    command -v podman >/dev/null
    test "$(podman info --format '{{.Host.Security.Rootless}}')" = true
    exit 0
    ;;
  --runtime=buildkit)
    test "$(id -u)" -ne 0
    test ! -S /var/run/docker.sock
    test -z "${DOCKER_HOST:-}"
    test -z "${CONTAINER_HOST:-}"
    command -v buildctl >/dev/null
    case "${BUILDKIT_HOST:-}" in
      unix://*) ;;
      *) printf '%s\n' 'BUILDKIT_HOST must select a per-job Unix socket' >&2; exit 1 ;;
    esac
    test -S "${BUILDKIT_HOST#unix://}"
    buildctl --addr "$BUILDKIT_HOST" debug workers >/dev/null
    exit 0
    ;;
  *)
    printf '%s\n' 'usage: check-runner-contract.sh [static|--runtime=podman|--runtime=buildkit]' >&2
    exit 2
    ;;
esac

export REPOSITORY_ROOT="$repository_root"

ruby <<'RUBY'
require "yaml"

root = ENV.fetch("REPOSITORY_ROOT")
repository = File.basename(root)
linux_runner = {
  "group" => "arconath-jit",
  "labels" => %w[self-hosted linux x64 arconath-jit rootless-buildkit],
}
macos_runner = {
  "group" => "arconath-macos",
  "labels" => %w[self-hosted macOS ARM64 arconath-macos xcode],
}
macos_jobs = {
  "agentdeck" => {
    "ci.yml" => {"ios" => "26.2"},
    "release.yml" => {"ios" => "26.2"},
  },
  "spatial-studio" => {
    "ci.yml" => {"verify" => "26.2"},
  },
}
fork_guard_fragment = "github.event.pull_request.head.repo.full_name == github.repository"
external_action_pin = /\A[^@\s]+@[0-9a-f]{40}\z/
container_action_pin = /\Adocker:\/\/.+@sha256:[0-9a-f]{64}\z/

def validate_permissions!(path, scope, permissions)
  unless permissions.is_a?(Hash) && permissions["contents"] == "read"
    abort("#{path}: #{scope} must declare contents: read")
  end
  permissions.each do |name, access|
    next unless access == "write"
    next if name == "security-events"
    abort("#{path}: #{scope} may not grant #{name}: write")
  end
end

def validate_uses!(path, location, uses, external_action_pin, container_action_pin)
  return if uses.start_with?("./")
  return if uses.match?(external_action_pin) || uses.match?(container_action_pin)
  abort("#{path}: #{location} must pin #{uses.inspect} to an immutable commit or digest")
end

workflow_paths = Dir[File.join(root, ".github/workflows/*.{yml,yaml}")].sort
abort("#{root}: no workflows found") if workflow_paths.empty?

workflow_paths.each do |workflow_path|
  source = File.read(workflow_path)
  abort("#{workflow_path}: pull_request_target is forbidden on private runners") if source.match?(/^  pull_request_target:/)
  abort("#{workflow_path}: fixed localhost host ports are forbidden") if source.match?(/(?:127\.0\.0\.1|localhost):[0-9]+/)
  abort("#{workflow_path}: mounting the Docker socket is forbidden") if source.match?(/(?:--volume|-v)\s+\/?var\/run\/docker\.sock/)
  if repository == "agentdeck"
    if source.match?(/uses:\s*(?:actions\/setup-java|android-actions\/setup-android|subosito\/flutter-action)@/)
      abort("#{workflow_path}: mutable mobile SDK setup action is forbidden; use the immutable runner image")
    end
    if source.match?(/\bunzip(?:\.exe)?\b|\bapt(?:-get)?\s+install\b/)
      abort("#{workflow_path}: runtime SDK installation is forbidden on the Apple/Android runner fleet")
    end
  end
  workflow = YAML.safe_load(source, permitted_classes: [], permitted_symbols: [], aliases: true) || {}
  validate_permissions!(workflow_path, "workflow permissions", workflow["permissions"])
  pull_request_workflow = source.match?(/^  pull_request:/)

  (workflow["jobs"] || {}).each do |job_name, job|
    if job.key?("uses")
      validate_uses!(workflow_path, "job #{job_name}", job.fetch("uses"), external_action_pin, container_action_pin)
      next
    end

    required_xcode = macos_jobs.dig(repository, File.basename(workflow_path), job_name)
    expected_runner = required_xcode ? macos_runner : linux_runner
    actual_runner = job["runs-on"]
    abort("#{workflow_path}: #{job_name} runner contract drifted: #{actual_runner.inspect}") unless actual_runner == expected_runner

    if pull_request_workflow && !job["if"].to_s.include?(fork_guard_fragment)
      abort("#{workflow_path}: #{job_name} must fail closed for fork pull requests")
    end

    strategy = job["strategy"]
    if strategy.is_a?(Hash) && strategy.key?("matrix") && strategy["max-parallel"] != 1
      abort("#{workflow_path}: #{job_name} matrix must set max-parallel: 1")
    end

    validate_permissions!(workflow_path, "job #{job_name} permissions", job["permissions"]) if job.key?("permissions")
    steps = job["steps"] || []
    if File.basename(workflow_path) == "release-validation.yml"
      checkout_index = steps.index { |step| step["uses"].to_s.start_with?("actions/checkout@") }
      guard_index = steps.index { |step| step["name"] == "Verify protected source revision" }
      unless checkout_index == 0 && guard_index == 1
        abort("#{workflow_path}: #{job_name} must verify the protected source immediately after checkout")
      end
      checkout_options = steps.fetch(checkout_index).fetch("with", {})
      unless [0, "0"].include?(checkout_options["fetch-depth"])
        abort("#{workflow_path}: #{job_name} protected-source verification requires fetch-depth: 0")
      end
      guard_command = steps.fetch(guard_index).fetch("run", "")
      unless guard_command.include?("refs/remotes/origin/main") &&
          guard_command.include?("PR_HEAD_SHA") &&
          guard_command.include?("git merge-base --is-ancestor")
        abort("#{workflow_path}: #{job_name} protected-source verification is incomplete")
      end
    end

    steps.each_with_index do |step, index|
      uses = step["uses"]
      next unless uses
      validate_uses!(workflow_path, "#{job_name} step #{index + 1}", uses, external_action_pin, container_action_pin)
      next unless uses.start_with?("actions/checkout@")
      persist_credentials = (step["with"] || {})["persist-credentials"]
      unless persist_credentials == false || persist_credentials == "false"
        abort("#{workflow_path}: #{job_name} checkout must set persist-credentials: false")
      end
    end

    commands = steps.map { |step| step["run"].to_s }.join("\n")
    if commands.match?(/(?:^|\n)\s*(?:sudo\s+)?docker(?:\s|$)/)
      abort("#{workflow_path}: #{job_name} may not use the Docker CLI")
    end

    podman_runtime = commands.match?(/\bpodman\s+(?:build|run|compose|save|pull|create|start|exec)\b/) ||
      commands.match?(/(?:image-build-smoke|build-images)\.sh/)
    if podman_runtime && !commands.include?("check-runner-contract.sh --runtime=podman")
      abort("#{workflow_path}: #{job_name} must verify the rootless Podman runtime before use")
    end

    buildkit_runtime = commands.match?(/\bbuildctl\b.*\bbuild\b/m)
    if buildkit_runtime && !commands.include?("check-runner-contract.sh --runtime=buildkit")
      abort("#{workflow_path}: #{job_name} must verify the isolated rootless BuildKit runtime before use")
    end

    next unless required_xcode
    apple_step = steps.find { |step| step["name"] == "Verify Apple runner" }
    expected_command = "scripts/ci/verify-apple-runner.sh #{required_xcode}"
    unless apple_step&.fetch("run", "")&.include?(expected_command)
      abort("#{workflow_path}: #{job_name} must assert Xcode #{required_xcode}+")
    end
  end
end

Dir[File.join(root, ".github/actions/**/action.{yml,yaml}")].sort.each do |action_path|
  action = YAML.safe_load(File.read(action_path), permitted_classes: [], permitted_symbols: [], aliases: true) || {}
  (action.dig("runs", "steps") || []).each_with_index do |step, index|
    uses = step["uses"]
    next unless uses
    validate_uses!(action_path, "step #{index + 1}", uses, external_action_pin, container_action_pin)
  end
end
RUBY
