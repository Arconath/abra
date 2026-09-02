# Abra documentation

Last reviewed: 2026-08-31 (documentation review date; not a claim that runtime state is current).

Abra is an agent-first, source-cited memory control plane. This index separates
the stable product contract, agent-facing behavior, operator procedures, and
research/evaluation material. Read [AI-CONTEXT.md](AI-CONTEXT.md) before making
an automated or cross-boundary change, and [STATUS.md](STATUS.md) before
treating a release or deployment statement as current.

## Start here

| Document | Use it for |
| --- | --- |
| [AI-CONTEXT.md](AI-CONTEXT.md) | Machine-readable orientation, invariants, source-of-truth precedence, edit boundaries, workflows, and terminology. |
| [STATUS.md](STATUS.md) | Evidence-backed repository state, external unknowns, blockers, risks, verification, and next milestones. |
| [ARCHITECTURE.md](ARCHITECTURE.md) | MCP/CLI/HTTP boundaries, core ownership, request paths, and package placement. |
| [REPOSITORY_LAYOUT.md](REPOSITORY_LAYOUT.md) | Directory ownership and where changes belong. |
| [FEATURE_FREEZE.md](FEATURE_FREEZE.md) | Frozen public surface and compatibility rules. |
| [CLI.md](CLI.md) | Operator workflows and stable command surface. |
| [COGNITIVE_ARCHITECTURE.md](COGNITIVE_ARCHITECTURE.md) | Memory, evidence, reasoning, learning, and decision-gate model. |

## Read by concern

| Concern | Canonical documents |
| --- | --- |
| Agent and product shape | [FEATURE_FREEZE.md](FEATURE_FREEZE.md), [COGNITIVE_ARCHITECTURE.md](COGNITIVE_ARCHITECTURE.md) |
| System boundaries | [ARCHITECTURE.md](ARCHITECTURE.md), [REPOSITORY_LAYOUT.md](REPOSITORY_LAYOUT.md) |
| CLI/MCP use | [CLI.md](CLI.md), root [README.md](../README.md) core-tool section |
| Extensions | [EXTENSIONS.md](EXTENSIONS.md), [PLUGIN_AUTHORING.md](PLUGIN_AUTHORING.md) |
| Quality and evaluation | [BENCHMARKS.md](BENCHMARKS.md), brain review/scorecard guidance in the architecture docs |
| Deployment and production | [PRODUCTION.md](../PRODUCTION.md), [deploy/helm/README.md](../deploy/helm/README.md), and [deploy/kubernetes/README.md](../deploy/kubernetes/README.md) |
| Release and provenance | [RELEASE.md](../RELEASE.md), release scripts, and external release-control evidence |
| Security | [SECURITY.md](../SECURITY.md) |
| Database migration policy | [migrations/README.md](../migrations/README.md) |
| Contributions and history | [CONTRIBUTING.md](../CONTRIBUTING.md), [CHANGELOG.md](../CHANGELOG.md) |

## Stable design decisions

- MCP is the canonical agent-facing interface; the CLI is the operator surface.
- HTTP is a transport for MCP, CLI fallback, gateways, and private automation,
  not a second product UX.
- Postgres with `pgvector` owns durable evidence, claims, graph relations,
  approvals, policy decisions, traces, and evaluation history.
- Core owns validation, citations, conflicts, approvals, health, and learning
  promotion. Connectors and plugins provide evidence but cannot promote truth.
- The default path is deterministic and no-LLM; optional synthesis is bounded by
  evidence, citations, anchors, and governance.
- The OSS public surface is frozen according to [FEATURE_FREEZE.md](FEATURE_FREEZE.md);
  compatibility commands are not automatically new product interfaces.

## Source-of-truth precedence

For behavior, use the implementation and tests first, then the public contracts
and feature-freeze rules, then architecture and operator documents, then the
README for orientation. For production requirements use [PRODUCTION.md](../PRODUCTION.md)
and [RELEASE.md](../RELEASE.md). For live routes, secrets, promoted digests,
backup records, and operator approvals, this checkout is not authoritative; use
the external platform/release source of truth and record missing evidence here.

## Maintenance rule

When changing a public tool, persisted schema, source/connector contract, or
approval rule, update the relevant architecture/feature-freeze document and
tests in the same checkout. Do not add provider-specific business logic to core,
rewrite a released migration, or expose a production API without the controls
listed in [AI-CONTEXT.md](AI-CONTEXT.md) and [PRODUCTION.md](../PRODUCTION.md).

## Architecture diagram

- [Rendered architecture diagram](diagrams/architecture.svg)
- [Editable Mermaid source](diagrams/architecture.mmd)
