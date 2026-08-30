#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(git -C "$script_dir" rev-parse --show-toplevel)"
export REPOSITORY_ROOT="$repository_root"

ruby <<'RUBY'
require "yaml"

root = ENV.fetch("REPOSITORY_ROOT")
expected = {
  "group" => "arconath-jit",
  "labels" => %w[self-hosted linux x64 arconath-jit rootless-buildkit],
}
fork_guard = "${{ github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository }}"
Dir[File.join(root, ".github/workflows/*.{yml,yaml}")].sort.each do |workflow_path|
  source = File.read(workflow_path)
  abort("#{workflow_path}: mounting the Docker socket is forbidden") if source.match?(/--volume\s+\/?var\/run\/docker\.sock/)
  workflow = YAML.safe_load(source, permitted_classes: [], permitted_symbols: [], aliases: true) || {}
  (workflow["jobs"] || {}).each do |job_name, job|
    next if job.key?("uses")
    actual = job["runs-on"]
    abort("#{workflow_path}: #{job_name} runner contract drifted: #{actual.inspect}") unless actual == expected
    if source.match?(/^\s*pull_request:/) && job["if"] != fork_guard
      abort("#{workflow_path}: #{job_name} must fail closed for fork pull requests")
    end
    strategy = job["strategy"]
    if strategy.is_a?(Hash) && strategy.key?("matrix") && strategy["max-parallel"] != 1
      abort("#{workflow_path}: #{job_name} matrix must set max-parallel: 1")
    end
  end
end
RUBY
