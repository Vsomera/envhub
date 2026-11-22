# Env-Locker Project Handoff

This document gives a new agent or session the product context, current design, repository state, and unresolved decisions needed to continue Env-Locker work. It distinguishes documented intent from implemented behavior; the architecture and feature notes are proposals, not proof that any service exists.

## Project at a glance

**Env-Locker** is a personal-project concept for securely storing and distributing environment-variable secrets used by software projects. The Eraser notes describe a CLI and `.env` workflow, while the local architecture sketch also includes a web app and team/project organization.

The codebase is currently a small Go repository with a `main` stub and a draft SQL schema. It is a design-stage project, not a working secret manager. Do not assume authentication, encryption, API endpoints, deployments, tests, CI/CD, or database migrations have been implemented.

## Source of truth and design artifacts

- **Eraser workspace:** [Env-Locker](https://app.eraser.io/workspace/c7EYEOlU7797NhdEG9ar)
  - App overview: personal project to store environment-variable secrets for software-development projects.
  - Feature list and a short todo list; the listed data/database design work is still unchecked there.
  - The workspace document currently has no embedded diagrams. Its notes should not be cited as a diagram.
- **Local architecture sketch:** [`docs/images/architecture-overview.PNG`](images/architecture-overview.PNG)
- **Local data-model sketch:** [`docs/images/table-overview.PNG`](images/table-overview.PNG)
- **Functional requirements:** [`docs/functional-requirements.md`](functional-requirements.md)
- **Draft SQL schema:** [`scripts/tables.sql`](../scripts/tables.sql)
- **Application entry point:** [`main.go`](../main.go)

The repository remote is `Vsomera/envhub`; the product name used in Eraser is “Env-Locker.” Treat these as the current code repository and product name, respectively, unless the owner says otherwise.

## Product intent and features

The Eraser feature list names:

- Command-line interface.
- Upload `.env` files and encrypt them.
- Pull `.env` files back down.
- Name, rename, delete, and list `.env` files.
- Prevent `.env` files from being pushed to GitHub.

The local functional-requirements file adds:

- Horizontal and vertical scaling.
- Resilience to failure.
- Persistent data.
- Encryption of sensitive environment data.
- HTTP request tracing through logs.
- Testability of each service.
- CI/CD.

These are high-level requirements, not acceptance criteria. In particular, clarify what “prevent pushing `.env` files to GitHub” means. A remote secret store cannot by itself prevent a developer from committing a local file; possible interpretations include local Git hooks/tooling, repository scanning, generated ignore rules, or a more limited warning/prevention workflow.

## Proposed architecture in the local sketch

The architecture image shows the following proposed components and connections:

1. A **CLI** and a **web app** enter through an **API Gateway / load balancer**.
2. The gateway routes to **Auth Service** and **Env Service**, each drawn as an AWS Lambda.
3. Auth Service connects to a **user SQL database**.
4. Env Service connects to an **environment SQL database** and an **environment cache** labeled NoSQL.
5. Messaging queues appear between the auth and environment services and between services and a **Logging Service**.
6. Logging Service is drawn as a Lambda and sends data to **Elasticsearch** (NoSQL).

This should be treated as a conceptual sketch only. Queue arrows and responsibilities are not fully specified, so do not infer whether messaging is synchronous, asynchronous, or required for a user request. The sketch also does not define deployment topology, queue guarantees, cache semantics, key management, or failure behavior.

## Draft data model

[`scripts/tables.sql`](../scripts/tables.sql) currently defines:

| Table | Draft fields | Intended relationship |
| --- | --- | --- |
| `User` | `userID`, `userName`, `userPassword` | A user identity and credential record |
| `Team` | `teamID`, `teamName` | A group/workspace |
| `UserTeam` | `userTeamID`, `userID`, `teamID`, `role` | Many-to-many membership; comment names `admin` and `member` |
| `Project` | `projectID`, `teamID`, `projectName` | A project belongs to a team |
| `Env` | `envID`, `projectID`, `envKey`, `envSecret` | A secret key/value pair belongs to a project |

Foreign keys are declared from `UserTeam` to `User` and `Team`, `Project` to `Team`, and `Env` to `Project`. Primary keys are integer IDs. The schema does not specify a database dialect or migration/runtime mechanism.

### Data-model gaps to resolve

- The product feature list operates on **`.env` files**, but the schema has no environment-file/container entity. `Env` appears to represent one key/value pair. Decide whether to add a resource such as `Environment` (project + name + metadata) with child secret entries, or document a different model. This affects list, upload, rename, pull, and delete semantics.
- Decide the uniqueness rules: likely candidates to evaluate include username, team/project names within their parent scope, membership (`userID`, `teamID`), and a key name within an environment.
- Define roles and authorization policy beyond the comment in SQL. Every read/write/delete/pull must authorize the caller against the owning team/project/environment.
- `userPassword` does not say whether it stores a password hash. It must never store plaintext or a reversible password; decide authentication scope and use a purpose-built adaptive password-hashing scheme if passwords are owned by this service.
- `envSecret` is a plain-text-shaped `varchar(100)` column; the schema does not implement or describe encryption. Define the encrypted representation, value-size limits, key management and rotation, and the treatment of plaintext during request handling.
- Add lifecycle needs as appropriate: timestamps, secret/environment versions, audit events, soft-delete or retention rules, and recovery behavior.
- IDs are not declared generated/identity-backed, and tables lack explicit check constraints for roles. Define these when choosing a database and migration strategy.
- “Personal project” and team-based ownership are both present in the design. Confirm whether teams are an initial product requirement or a future extension.
- Two SQL databases are depicted for users and environments, but the code/schema do not explain why they are separated. Decide whether that separation is needed; it adds operational and consistency considerations.

## Security and operations guardrails

These are unresolved design requirements and recommended constraints, not claims about current implementation:

- **Secrets:** Encrypt persisted secret values with a managed key strategy; keep encryption keys out of the application database and source repository. Specify rotation, backup/restore, and key-loss behavior before choosing an implementation.
- **Secret exposure:** Never place raw secret values in application logs, traces, metrics, error messages, analytics, queue payloads, or cache keys. Redact request bodies and carefully limit access to any audit trail.
- **Credentials and sessions:** Specify authentication, token/session lifetime, revocation, and account recovery. Store only a password hash if local passwords are supported.
- **Authorization:** Enforce team/project ownership and role checks server-side on every operation; do not rely on the CLI or web UI to hide unauthorized resources.
- **Transport and uploads:** Require protected transport. Define `.env` parsing, size limits, malformed input behavior, and whether arbitrary file contents are accepted.
- **Cache and queues:** Decide what secret-related data can enter them, retention/TTL, encryption, access control, retry/dead-letter policy, idempotency, and behavior during outages. A cache must not become the authoritative source unless that is an explicit design.
- **Persistence and resilience:** Define backups, restore objectives, availability expectations, and failure modes for each dependency. “Persisted” and “resilient” need measurable acceptance criteria.
- **Observability:** Add request correlation/trace IDs and useful structured logs while excluding secret values and credentials.
- **GitHub protection:** Be explicit about whether this is a local developer guard, server-side repo integration/scanning, or documentation. Avoid promising prevention that cannot be guaranteed.

## Repository status at handoff

Observed repository contents:

- `main.go`: `package main` and an empty `main()` only.
- `scripts/tables.sql`: draft schema described above.
- `docs/functional-requirements.md` and two design images.
- `makefile`: contains only a comment indicating it is for executing test commands.
- No `go.mod`, service packages, API definitions, test files, database migrations beyond the draft SQL, or CI/CD workflow files were present in the tracked project files at the time this handoff was written.

Therefore, feature work should begin by agreeing the minimum product slice and design boundaries, then establishing the Go module, test strategy, and executable service structure. Do not treat the AWS/Lambda architecture as a fixed technology decision unless the owner confirms it.

## Suggested continuation order

1. **Confirm the product boundary:** individual vs. team use; CLI vs. web app for the first release; definition of “environment” and the GitHub-prevention promise.
2. **Write core workflows and acceptance criteria:** create/list/rename/delete an environment, upload and validate variables, pull/materialize a file, and access control for each action.
3. **Agree the threat model and secret lifecycle:** identify principals, protected assets, trust boundaries, authorized secret readers, logging policy, encryption/key ownership and rotation, and recovery requirements.
4. **Revise the data model:** represent an environment/file separately from its entries if that matches the product; add constraints and lifecycle fields; choose one source of truth and a database dialect.
5. **Choose a minimal architecture:** decide whether to start as a modular Go service or split services; add queues/cache only for a concrete need. Define service contracts and failure semantics before implementing distributed components.
6. **Build a vertical slice:** authentication/authorization, one project/environment workflow, persistent encrypted secrets, CLI upload/pull, and focused tests.
7. **Add operational foundations:** secret-safe structured request logging, health checks, migrations, backup/recovery plan, CI checks, and deployment only after the core threat and data model are settled.
8. **Update the artifacts:** keep Eraser diagrams, the schema, requirements, and this handoff aligned as decisions are made. Record durable domain terms and architectural decisions in the repo’s glossary/ADR locations when they are established.

## Agent/session guidance

- Read [`AGENTS.md`](../AGENTS.md) and [`docs/agents/domain.md`](agents/domain.md) before code exploration; the domain-doc instructions say to read any existing root glossary/map and relevant ADRs, but to proceed silently if they do not exist.
- Treat unchecked Eraser todos (data design, database tables, feature tickets, code) as a note of project intent, not a current issue tracker state.
- Do not store real secrets in examples, tests, fixtures, or logs.
- Preserve unrelated worktree changes. The setup files `AGENTS.md` and `docs/agents/` were untracked at handoff time; do not discard them.
