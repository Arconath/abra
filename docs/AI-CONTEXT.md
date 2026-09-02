# Abra AI context

Last reviewed: 2026-08-31 (documentation review date; not a claim that runtime state is current).

The YAML block is the compact orientation contract. The existing sections below
add the safety rules and operator workflow that agents should follow.

```yaml
product: abra
repository_root: products/abra
canonical_repository: https://github.com/Arconath/abra
canonical_go_module: github.com/Arconath/abra
declared_toolchain:
  go: "1.25.13 or newer"
  node: "24.20.0"
  helm: "3.21.4"
status_basis: repository_evidence_only
runtime_state: unknown_not_evidenced
public_brand_mapping:
  initial_domain: abra.arconath.com
  state: safe_initial_mapping_not_live_evidenced
  protected_external_domain: abra.com
  constraint: "abra.com is outside this rollout and must not be used or changed; verify abra.arconath.com through platform-owned route evidence"
product_shape: "agent-first source-cited memory control plane; not a chatbot or web dashboard"
interfaces:
  canonical_agent: MCP
  operator: cmd/abra
  http_transport: cmd/abra-api
  background_jobs: cmd/abra-worker
  migrations: cmd/abra-migrate
  core_tools: [discover_scopes, working_memory_compose, brain_think, brain_review, brain_scorecard]
owns:
  - Go CLI, API, worker, migration process, and core memory behavior
  - source normalization, citations, evidence anchors, conflicts, approvals, and learning promotion
  - Postgres/pgvector persistence model and append-only migrations
  - connector/plugin contracts, tests, evaluation scripts, generic Compose and Helm deployment shape
  - release validation evidence; trusted publication remains external
external_owners:
  - production secrets, API keys, webhook signing, and identity configuration
  - runtime network exposure, gateway, cluster, registry digests, and GitOps promotion
  - backup/restore operations, provider capacity, and operator/support process
  - public domain/brand ownership and any public commercial route
invariants:
  - evidence and source anchors precede generated prose
  - stale, expired, superseded, conflicting, and deprecated claims remain distinguishable
  - observations and learning proposals do not become trusted memory without governance
  - scope is explicit and untrusted input; read/write decisions remain scope-bound
  - risky writes, policy/ACL changes, backfills, forget operations, and authority changes require approval in production mode
  - the default recall/review/scorecard/maintenance path is deterministic and no-LLM
  - plugins normalize source evidence but core owns trust, citations, conflicts, approvals, and promotion
  - released migrations are append-only and applied by the separate migration process
  - production requires approval enforcement, PII redaction, auth, rate limits, private routing/TLS, backups, and measurable provider capacity
source_of_truth:
  public_surface: docs/FEATURE_FREEZE.md
  architecture: docs/ARCHITECTURE.md
  cognitive_model: docs/COGNITIVE_ARCHITECTURE.md
  operator_contract: docs/CLI.md
  repository_layout: docs/REPOSITORY_LAYOUT.md
  extension_contracts: docs/EXTENSIONS.md and docs/PLUGIN_AUTHORING.md
  production_requirements: PRODUCTION.md
  release_requirements: RELEASE.md
  security: SECURITY.md
  migration_policy: migrations/README.md and migrations/*.sql
  runtime_entrypoints: cmd/abra, cmd/abra-api, cmd/abra-worker, cmd/abra-migrate
  persistence_and_governance: internal/store, internal/memory, internal/server, internal/brain
  repository_checks: package.json and scripts/abra-release-gate.mjs
edit_boundaries:
  product_owned: [cmd, internal, migrations, plugins, examples, deploy, scripts, docs]
  core_boundary: "keep provider-specific business logic in plugins or overlays"
  external_sources: [platform GitOps, release-control, registry, runtime secrets, DNS, production operations]
  never_add: [secrets, customer data, source exports, embeddings, database dumps, audit logs, fake release or runtime status]
workflows:
  install_checks: npm ci
  fast_checks: "go test ./... && npm test && go vet ./... && helm lint ./deploy/helm"
  release_gate: "ABRA_RELEASE_PROFILE=full ABRA_RELEASE_MANAGE_STACK=1 npm run release:gate"
  operator_bootstrap: "abra setup -> abra doctor -> abra scope -> abra agent bootstrap/verify"
  agent_context: "discover_scopes -> working_memory_compose -> inspect policy and agent_decision -> act only within gate"
terminology:
  source_citation: "evidence anchor linking a claim or packet to its source"
  working_memory: "task-specific governed context packet"
  agent_decision: "proceed, caution, review, or stop gate returned with governed output"
  learning_proposal: "reviewable promotion request derived from observations/outcomes"
  core: "provider-neutral trust, memory, governance, and persistence behavior"
  plugin: "adapter that supplies normalized source evidence without owning trust decisions"
  production_mode: "runtime posture requiring explicit auth, approval, secret, routing, and recovery controls"
```

## Identity

- Abra is a governed, source-cited external memory control plane for AI agents.
- It is not a chatbot, web dashboard, generic RAG UI, vector-database product,
  model wrapper, or source-specific connector bundle.
- The public repository is provider-neutral and intentionally keeps private
  business behavior in plugins or overlays.

## Ownership map

| Area | Responsibility |
| --- | --- |
| `cmd/abra` | Operator CLI entry point |
| `cmd/abra-api`, `cmd/abra-worker`, `cmd/abra-migrate` | API, worker, and migration process entry points |
| `internal/brain` | Ingestion and knowledge extraction |
| `internal/memory` | Retrieval, working-memory composition, evidence, decisions, scorecards, maintenance, and synthesis gates |
| `internal/server` | HTTP/MCP protocol, auth, policies, and approvals |
| `internal/store` | Postgres persistence and migrations |
| `internal/jobs`, `internal/ingest`, `internal/graph` | Source execution, normalization, and graph extraction |
| `plugins/` | Extension adapters and existing built-in plugin surfaces |

## Invariants an agent must preserve

- Evidence and source anchors precede generated prose.
- Claims without a `source_url` are unverified; stale, conflicting, expired,
  superseded, and manually deprecated claims must remain distinguishable.
- Agents may observe and propose learning; trusted memory is promoted only by
  explicit governance.
- Risky writes, broad-scope operations, ACL/policy changes, source-authority
  changes, backfills, and forget operations require approval in production mode.
- Keep `ABRA_APPROVAL_MODE=enforce` and `REDACT_PII=true` for production-facing
  deployments unless a reviewed contract says otherwise.
- Scope is part of every read/write decision (`company`, `team:<name>`,
  `agent:<slug>`, `user:<id>`); never treat an agent-provided scope as trusted.
- Persisted migrations are append-only after release; do not rewrite released
  migrations.
- Keep embedding dimensions, batch limits, worker concurrency, timeouts, and
  provider capacity bounded and measurable.

## Agent workflow

1. Resolve the exact memory scope with `discover_scopes` or `abra scope`.
2. Compose task-specific context with `working_memory_compose`.
3. Read both the memory policy decision and the returned `agent_decision` before
   any write, challenge, forget, backfill, authority, or policy mutation.
4. Prefer deterministic `brain_think`, `brain_review`, `brain_scorecard`, and
   entity dossier output; use synthesis only after the evidence gate passes.
5. Record observations/outcomes and propose learning instead of writing trusted
   memory directly.

## Source-of-truth precedence

Use `AGENTS.md` first, then runtime behavior/tests, then the architecture and
feature-freeze docs, then the README. `PRODUCTION.md` defines deployment
requirements. If prose and code disagree, correct the documentation and add or
adjust a test in the same change.

## Verification

Use the documented Go/Node toolchains and run the smallest relevant checks first:

```sh
go test ./...
npm test
go vet ./...
helm lint ./deploy/helm
```

The full production gate may need Docker and local model capacity. Report
unavailable external services rather than replacing them with mocks.

## Stop conditions

Do not expose a production API without generated keys, webhook secrets, approval
enforcement, rate limits, TLS/gateway controls, managed Postgres/pgvector,
backups/restore, digest-attested images, and provider capacity evidence. Do not
publish, deploy, run migrations against shared/production databases, rotate
keys, or change DNS without explicit authorization.
