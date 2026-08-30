# Agent Instructions

## Repository Identity and Purpose

- Abra is a governed, source-cited external memory control plane for AI agents.
- The canonical repository is `https://github.com/Arconath/abra`.
- MCP is the agent-facing contract, the CLI is the operator surface, and HTTP
  is transport for MCP, CLI fallbacks, gateways, and private automation.
- Keep the core provider-neutral. Source-specific, tenant-specific, identity,
  and business workflow behavior belongs in a plugin or private overlay.

## Context and Source of Truth

Before answering architecture questions or changing code, use Abra MCP when it
is already available and healthy:

1. Use exact scope `repo:abra`.
2. If discovering scopes first, call `discover_scopes` with
   `expected_scope: "repo:abra"`.
3. Call `working_memory_compose` with the current task, scope `repo:abra`, and
   `agent: "codex"` before implementation work.
4. Follow the returned decision gate, evidence, conflicts, impact map, and
   validation plan.

If Abra MCP or the `abra` binary is unavailable, say so and continue from the
checked-out repository when the task permits. Do not fabricate memory context,
install or repair integrations, start services, or run `abra sync` unless the
user explicitly asks for that operational work.

Repository evidence is authoritative for implementation:

- `README.md` and `docs/CLI.md` define supported user workflows.
- `docs/ARCHITECTURE.md`, `docs/COGNITIVE_ARCHITECTURE.md`, and
  `docs/REPOSITORY_LAYOUT.md` define ownership and system boundaries.
- `docs/FEATURE_FREEZE.md` defines the frozen public surface.
- `PRODUCTION.md`, deployment manifests, and `RELEASE.md` define production and
  release requirements.
- Runtime behavior and tests take precedence when prose and code disagree;
  correct the documentation in the same scoped change.

## Architecture Boundaries

- `cmd/abra` owns the operator CLI; `cmd/abra-api`, `cmd/abra-worker`, and
  `cmd/abra-migrate` are process entry points.
- `internal/brain` owns ingestion and knowledge extraction.
- `internal/memory` owns retrieval, working-memory composition, evidence,
  decision gates, scorecards, maintenance, and synthesis gates.
- `internal/server` owns HTTP and MCP protocol handling, auth, policies, and
  approvals; `internal/store` owns Postgres persistence.
- `internal/jobs`, `internal/ingest`, and `internal/graph` own source execution,
  normalization, and graph extraction respectively.
- Core alone owns validation, citations, trust, approvals, and promotion of
  learned memory. Plugins and agents must not write trusted memory directly.
- After a release, schema changes are append-only ordered migrations. Do not
  rewrite an already released migration.

## Development and Verification

Use Go 1.25.13 or newer, Node.js 24.20.0 for reproducible maintainer checks, and
Helm 3.21.4 for deployment or release checks. Install the locked Node
environment with `npm ci`.

Run checks proportionate to the change:

```sh
go test ./...
npm test
go vet ./...
go run honnef.co/go/tools/cmd/staticcheck@v0.7.0 ./...
```

For deployment or release work, also run the relevant render/build checks:

```sh
helm lint ./deploy/helm
helm template abra ./deploy/helm >/tmp/abra-helm-template.yaml
npm run release:gate:dry-run
```

The full managed gate requires Docker and local model capacity:

```sh
ABRA_RELEASE_PROFILE=full ABRA_RELEASE_MANAGE_STACK=1 npm run release:gate
```

Add focused tests for behavior changes. Diagnose failures before editing, run
fresh checks after editing, and report any checks that could not run. Do not
weaken tests, maintainability budgets, security checks, pinned-action policy,
or release gates merely to make validation pass.

## Security and Operational Safety

- Never commit or print secrets, tokens, private keys, real credentials,
  customer data, private source exports, embeddings, database dumps, audit
  logs, or private business context.
- Keep examples fake and provider-neutral. Use ignored local env files or the
  deployment secret manager for credentials.
- Preserve fail-closed production auth, approval enforcement, webhook
  verification, rate limiting, network boundaries, image digest pinning, and
  artifact attestation requirements.
- Do not run migrations against shared or production databases, rotate keys,
  publish packages or images, create releases, push commits/tags, deploy, or
  change DNS without explicit authorization.

## Change Discipline

- Make the smallest coherent change and preserve public behavior unless the
  task explicitly changes it.
- Respect existing user changes and do not clean unrelated files.
- Keep command families, store aggregates, MCP tool families, and memory
  capabilities in focused files; split responsibility instead of raising
  maintainability budgets.
- Do not add dependencies, generated artifacts, runtime data, local paths, or
  organization-specific terms without a demonstrated need.
- Do not edit release versions, changelog entries, image references, or
  deployment defaults incidentally.
- Review `git diff` and `git status` before handoff. Never push or publish as
  part of ordinary implementation work.
