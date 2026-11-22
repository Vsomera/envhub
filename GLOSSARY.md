# Env-Locker

Env-Locker stores and distributes named project configurations for individual owners, with optional GitHub repository protection.

## Language

**Owner**:
The individual GitHub account that owns Projects and their Environments.
_Avoid_: Team, organization

**Project**:
A named, owner-controlled grouping of Environments that may be linked to one or more GitHub repositories.
_Avoid_: Repository, account

**Repository**:
A GitHub repository linked to at most one Project in the initial product model.
_Avoid_: Codebase, project

**Environment**:
A named collection of Variables within a Project, such as `development` or `production`.
_Avoid_: Env file, secret

**Variable**:
A case-sensitive key and its sensitive value within an Environment.
_Avoid_: Env, setting

**Revision**:
A snapshot of all Variables in an Environment at a point in its history.
_Avoid_: Variable update, partial version

**Dotenv file**:
A local `.env`-style file used to import or export an Environment's Variables; it is not itself an Environment.
_Avoid_: Environment, Env
