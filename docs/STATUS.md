# Abra status and evidence boundary

Last reviewed: 2026-08-31 (documentation review date; not a claim that runtime state is current).

This is a repository evidence snapshot. It does not claim that a live Abra deployment, published release, or public `abra.arconath.com` service is active.

The safe initial portfolio mapping is `abra.arconath.com`. The unrelated
`abra.com` domain is outside this rollout and must not be used or changed.
Keep route activation and technical self-hosting readiness separate from that
domain-ownership decision; this checkout does not prove that the safe initial
hostname is live.

## Summary

Abra has a broad, production-oriented self-hosted contract and a frozen
agent-first public surface. The repository contains the core CLI/API/MCP,
governed memory model, Postgres/pgvector persistence, plugin boundaries, and
production deployment requirements. Live operational readiness is deployment-
and operator-dependent.

Repository checks are evidence of checkout health only. The checkout does not
prove production secrets, a deployed runtime, exact promoted image digests,
release artifacts or attestations, backup/restore execution, provider capacity,
or an assigned operator/support process.

## Evidence register

| Area | State | Evidence | Interpretation |
| --- | --- | --- | --- |
| Agent-facing MCP tools | PASS (source-defined) | Root README and `docs/CLI.md` | The canonical tool families are documented and implemented in the checkout |
| Governed learning and approvals | PASS (contracted) | `docs/COGNITIVE_ARCHITECTURE.md`, `docs/FEATURE_FREEZE.md` | Observation/proposal/promotion is intentionally separated |
| Postgres/pgvector persistence | PASS (designed/implemented) | `internal/store`, migrations, `PRODUCTION.md` | Requires real managed database and restore evidence for production |
| Provider-neutral ingestion/plugins | PASS (contracted) | `docs/EXTENSIONS.md`, `docs/PLUGIN_AUTHORING.md` | Source adapters must feed normalized evidence; core owns trust |
| Local development | PASS (documented) | README and CLI docs | Exact environment/tooling and model availability still matter |
| Production deployment | BLOCKED until evidenced | `PRODUCTION.md` | Real secrets, internal routing, backup/restore, signed digests, and operators are required |
| Public domain/brand mapping | DEFINED / not live-evidenced | Workspace `AGENTS.md` and `platform/portfolio.yaml` | `abra.arconath.com` is the safe initial mapping; `abra.com` is outside scope and must not be cut over |

## Completed or evidenced in the repository

- The agent-first product shape, MCP tool families, operator CLI, HTTP
  transport, and no-web-dashboard boundary are documented and represented by
  source entrypoints.
- Core memory behavior covers source-backed evidence, citations/anchors,
  temporal and conflicting claims, graph relations, approvals, health,
  scorecards, and governed learning promotion.
- Postgres with `pgvector`, ordered migrations, Compose development/runtime
  files, and a generic Helm delivery shape are present.
- Plugin and connector contracts keep source adaptation separate from core trust
  decisions; provider-specific business behavior is kept out of the
  provider-neutral core.
- Security, installer, packaging, migration, maintainability, evaluation, and
  OSS hygiene checks are wired into the repository’s Node task runner and CI
  workflows.
- Production and release documents define authentication, webhook protection,
  approval enforcement, PII handling, digest-pinned artifacts, backups/restores,
  and rollback expectations.

## In progress or only partially evidenced

- The complete release gate is configured, but the recorded
  `release:gate:dry-run` only enumerated 40 checks and skipped their execution.
  A live full gate has not been evidenced here.
- The generic Helm defaults contain a placeholder digest and disabled external
  exposure; the exact registry image, environment values, secrets, routes, and
  GitOps promotion state are external and unknown.
- Local model and provider capacity, production embedding dimensions, queue
  pressure, readiness, smoke, eval, and recovery outcomes are not recorded as
  live results in this checkout.
- The repository defines production procedures but does not identify an
  executed backup/restore drill, rollback identity, on-call owner, support
  process, or customer data boundary for a live deployment.
- The safe initial `abra.arconath.com` route remains unproven independently of
  any internal/self-hosted deployment decision; `abra.com` remains outside
  scope.

## Open gates

- generate and manage production API/webhook/database/provider credentials;
- enforce production approvals, internal routing, rate limits, and secret
  delivery;
- validate digest-pinned image provenance, SBOM/signatures, and rollback identity;
- exercise backup/restore and measure database/vector/provider capacity;
- assign an operator and support/incident process;
- keep the domain/brand decision separate from the internal/self-hosted product
  readiness decision.

## Next milestones

1. Obtain release-control evidence for an exact source revision, archive
   checksums, attestations, SBOM/signatures, and immutable container digests.
2. Run a controlled internal/self-hosted deployment using generated credentials,
   enforced approvals, private routing/TLS, Postgres/pgvector, embedding
   capacity, and the separate migration process.
3. Execute and retain full-gate, readiness, smoke, queue-pressure, evaluation,
   backup/restore, and rollback evidence against the exact artifacts.
4. Assign the operator/support and incident process, and record the live source
   of truth for routes, secrets, backups, registry state, and runtime
   configuration.
5. Verify DNS, TLS, gateway ownership, and route evidence for
   `abra.arconath.com`; do not treat technical readiness as authorization to
   use or change `abra.com`.

## Blockers and unknowns

| ID | State | Evidence or missing source of truth | Impact / next action |
| --- | --- | --- | --- |
| AB-01 | Pending | The safe initial hostname `abra.arconath.com` is recorded by the portfolio authority, but this checkout has no live DNS/TLS/route evidence. The unrelated `abra.com` domain remains outside scope. | Obtain platform-owned route and availability evidence for `abra.arconath.com`; do not cut over or modify `abra.com`. |
| AB-02 | Pending | No published archive, checksum/attestation record, promoted image digest, or release-control result is present in the checkout. | Exact deployable artifact and provenance are unknown; obtain release evidence. |
| AB-03 | Pending | No live deployment, route, runtime secret, API-key, webhook-secret, provider, or GitOps state is evidenced here. | Cannot assert production availability or secure exposure; obtain platform/operator records. |
| AB-04 | Pending | No executed backup/restore drill, rollback, capacity measurement, queue-pressure result, or incident owner is recorded. | Operational readiness and recovery claims remain unproven. |
| AB-05 | Pending | The repository requires a configured embedding provider or local model and measurable capacity, but live provider/model state is absent. | Retrieval quality, vector readiness, and throughput remain environment-dependent. |
| AB-06 | Unknown | No external production source of truth is identified in this checkout for secrets, routes, registry, backups, or operator ownership. | Record authoritative links before relying on any deployment claim. |

## Risks and dependencies

- Source documents, URLs, claims, embeddings, audit metadata, and provider
  responses may contain sensitive or untrusted content; keep PII redaction,
  source provenance, access controls, and approval gates active.
- Public exposure without API keys, webhook protection, approval enforcement,
  private routing/TLS, rate limits, and recovery controls would violate the
  documented production boundary.
- Embedding dimensions, model/provider capacity, worker concurrency, queue
  limits, and database/vector indexes must stay aligned; configuration drift can
  damage recall or throughput.
- Migrations are append-only after release and must run through
  `cmd/abra-migrate`; rewriting released SQL or running migrations against
  shared/production databases without authorization is unsafe.
- Plugins and connectors can introduce source-specific trust or availability
  risk even though core governance remains centralized.
- Postgres/pgvector, object/runtime storage, embedding providers,
  Docker-compatible runtime, Helm, registry, network/gateway, secrets,
  backups, and release-control are dependencies outside the product checkout.

## Verification evidence

Commands run on `2026-08-31`:

| Command | Result | Scope and limitation |
| --- | --- | --- |
| `npm test` | Passed | Script checks, eval contracts, installer/packaging, OSS hygiene, maintainability, migration, and audit checks; no live runtime. |
| `npm run release:gate:dry-run` | Passed: 40 checks configured | Dry-run enumerated the full profile and skipped actual stack/release commands; not a release proof. |
| `go test ./...` | Passed | Go package tests; no deployment or provider proof. |
| `go vet ./...` | Passed | Go static correctness check; no live-state proof. |
| `helm lint ./deploy/helm` | Passed | Generic chart lint; placeholder/external values remain unresolved. |

These results support repository health on the documentation review date. They
do not prove published artifacts, image provenance, domain ownership,
production routing, secrets, provider/model capacity, backup/restore, or live
availability.

## Canonical follow-up documents

- Agent and system contracts: [ARCHITECTURE.md](ARCHITECTURE.md), [FEATURE_FREEZE.md](FEATURE_FREEZE.md), and [REPOSITORY_LAYOUT.md](REPOSITORY_LAYOUT.md)
- Operator behavior: [CLI.md](CLI.md) and the root [README.md](../README.md)
- Production requirements: [PRODUCTION.md](../PRODUCTION.md)
- Release and provenance: [RELEASE.md](../RELEASE.md)
- Security: [SECURITY.md](../SECURITY.md)
- Database migration policy: [migrations/README.md](../migrations/README.md)
