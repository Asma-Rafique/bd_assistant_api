# BD Assistant API

This repository is the boilerplate it's built on: sign-in, user management, invitations, permissions, rate limits and CI. The BD features (opportunities, scoring, proposals) come next.

Rails 8.1 (API only) · Ruby 3.4 · PostgreSQL · GraphQL (graphql-ruby) · ActionPolicy · Sidekiq and Redis · RSpec

## Features

16 GraphQL operations (5 queries and 11 mutations), listed in full under [API](#api).

### Authentication
- **Login** (`loginUser`) with email and password. It returns a bearer token for the `Authorization` header.
- **Logout** (`logout`) ends the current session at once.
- **Current user** (`currentUser`) tells the app who's signed in.
- **Sessions expire** after 7 days, or after 2 days of not being used.
- **Archived accounts are blocked** from signing in, and their existing tokens stop working.

### Passwords
- **Forgot password** (`sendResetPasswordInstructions`) emails a reset link.
- **Reset password** (`resetPassword`) sets a new password from the link (valid for 15 minutes, single use), then signs the user in.
- **Change password** (`updatePassword`) while signed in, which needs the current password.
- **Changing or resetting a password signs out other devices.**
- **Password rules:** at least 8 characters, with uppercase, lowercase and a special character.

### Profile
- **Update a profile** (`updateUser`): first and last name.

### User management (super admin)
- **List users** (`allUsers`): search by name or email, filter by role or archived status, newest first, paginated.
- **View one user** (`fetchUser`). Team members can view only themselves.
- **Update another user's profile** (`updateUser` with an `id`).
- **Archive or restore a user** (`archiveUser`). Archiving signs them out everywhere.

### Invitations (super admin)
- **Invite users** (`createInvitation`): up to 20 emails at once, with a role, all or nothing.
- **Resend an invitation** (`resendInvitation`) with a fresh link.
- **Cancel an invitation** (`deleteInvitation`), which removes the pending account.
- **Check an invitation link** (`validateInvitationToken`), for the frontend's "set your password" page.
- **Accept an invitation** (`acceptInvitation`): set a password and sign in. The link is valid for 7 days and works once.

### Roles and permissions
- **Two roles:** super admin and team member.
- **Team members** see and edit only their own account.
- **Super admins** manage everyone except themselves, so they can't archive or lock themselves out.
- **Records a user may not see answer `NOT_FOUND`**, so their existence isn't revealed.

### Emails
- **Password reset and invitation emails**, sent in the background by Sidekiq.
- **In development, emails open in the browser** at `/letter_opener` instead of being sent.

### Security
- **Rate limits** on login, password reset, invitation acceptance and password change, plus a cap of 300 requests a minute per IP.
- **Only token digests are stored**, so a database leak exposes no usable tokens.
- **No account discovery:** login and password reset never reveal whether an email has an account.
- **Query limits:** depth, complexity, size and a 10-second timeout.
- **CORS** allows only the frontend's origins.
- **Production:** HTTPS is enforced, only allowed host names are answered, slow database queries are cancelled, and passwords and tokens are kept out of the logs.
- **Errors:** every error has a code, and internal details are never sent to the client.

### Health check
- **API status** (`apiStatus`) answers `"ok"`, for uptime checks.

### Developer setup
- **Seeds:** demo accounts in development, and the first super admin from environment variables.
- **Local work:** `bin/setup` and `bin/dev`, or Docker Compose for the whole stack.
- **Specs:** RSpec with a 95% coverage gate.
- **CI:** GitHub Actions runs RuboCop, Brakeman, bundler-audit, the specs and a production boot check.
- **Production image:** a Dockerfile for deploying, with web and worker processes.

## Setup

You need only Docker. Everything else (Ruby, Postgres, Redis, Sidekiq) runs in containers.

```bash
docker compose build                                   # once
docker compose run --rm web bin/setup --skip-server    # gems, .env, database and seeds
docker compose run --rm -e RAILS_ENV=test web bin/rails db:prepare  # the test database
docker compose up                                      # API and Sidekiq at http://localhost:3000
```

Run any Rails command through the `web` container, such as `docker compose run --rm web bundle exec rspec`
or `docker compose exec web bin/rails console`.

Prefer Ruby on your machine? Install Ruby 3.4.11, run `docker compose up -d postgres redis`, set
`DATABASE_URL=postgres://postgres:postgres@localhost:5433` and `REDIS_URL=redis://localhost:6380/0` in `.env`,
then use `bin/setup` and `bin/dev`.

The API runs at `http://localhost:3000/graphql`. Emails sent in development open at `http://localhost:3000/letter_opener`.

The seeds create demo accounts, all with the password `Passw0rd!`:

| Email | Role |
| --- | --- |
| `admin@example.com` | super admin |
| `sam@example.com`, `member@example.com` | team member |
| `invited@example.com` | invited, hasn't set a password yet |

## Checks

```bash
bin/ci                               # everything GitHub runs: RuboCop, bundler-audit, Brakeman, RSpec, production boot
bundle exec rspec                    # specs only, in random order
RUN_COVERAGE=1 bundle exec rspec     # with a coverage report in coverage/index.html (fails below 95%)
bundle exec rspec --only-failures    # rerun what failed last time
```

GitHub Actions runs the same checks on every pull request, with its own Postgres.

## How the code is organised

A request goes `POST /graphql` → `GraphqlController` → a query or mutation → a policy check → a service → models.

| Folder | What lives there |
| --- | --- |
| `app/graphql/queries/<area>/`, `app/graphql/mutations/<area>/` | One class per operation, kept thin: check permissions, call a service, return the result |
| `app/graphql/types/<area>/` | Output types (`UserType`) and inputs (`UserAttributesInput`) |
| `app/graphql/concerns/graphql_operation.rb` | Shared by every operation: sign-in required by default, `allow_unauthenticated!`, `rate_limit` |
| `app/services/<area>/` | Business logic. Each service has `.call` and returns a `ServiceResult`: a value, or a `ServiceError` with a code |
| `app/policies/` | ActionPolicy rules: who may do what, and which records a user can see at all |
| `app/queries/` | Query objects for filtering and searching lists |
| `app/models/` | `User` and `Session`, with validations and small domain methods |

Conventions: a service never knows about GraphQL; an operation never holds business logic; every list is paginated; every signed-out mutation declares a rate limit (a spec enforces this).

## Authentication and roles

- `loginUser` returns a bearer token. Send it as `Authorization: Bearer <token>`. Only a SHA-256 digest of the token is stored, and `logout` ends it at once.
- Two roles: **team member** (sees and edits only their own account) and **super admin** (manages users and invitations, but never their own account, so an admin can't lock themselves out).
- People join by invitation: a super admin invites by email, and the link (valid 7 days, single use) lets them set a password and signs them in.
- Password reset works by emailed link (15 minutes, single use). Changing or resetting a password signs out other devices.

## API

The full schema is in [`schema.graphql`](schema.graphql); a spec fails if it's out of date (`bin/rails graphql:schema:idl` regenerates it). Introspection is on in development, off in production.

| Operation | Who | What it does |
| --- | --- | --- |
| `loginUser`, `logout` | anyone / signed in | Start or end a session |
| `sendResetPasswordInstructions`, `resetPassword` | anyone | Reset a forgotten password by email |
| `validateInvitationToken`, `acceptInvitation` | anyone | Check an invitation link, then set a password |
| `currentUser`, `updateUser`, `updatePassword` | signed in | Your own account |
| `fetchUser` | signed in | One user: yourself, or anyone for a super admin |
| `allUsers` | super admin | Search, filter and page through users |
| `archiveUser` | super admin | Switch an account off (signs it out) or back on |
| `createInvitation`, `resendInvitation`, `deleteInvitation` | super admin | Manage invitations |
| `apiStatus` | anyone | Health check: `"ok"` |

Every error has a machine-readable `extensions.code`:

| Code | Meaning |
| --- | --- |
| `UNAUTHENTICATED` | No valid token; sign in |
| `FORBIDDEN` | Signed in, but not allowed |
| `NOT_FOUND` | Doesn't exist, or you're not allowed to know it does |
| `VALIDATION_FAILED` | Bad input; `extensions.fieldErrors` lists each field |
| `INVALID_CREDENTIALS` | Wrong email or password |
| `INVALID_TOKEN` | Reset or invitation link is wrong, used or expired |
| `SIGN_IN_BLOCKED` | The account is archived (an invited account that hasn't set a password gets `INVALID_CREDENTIALS`) |
| `RATE_LIMITED` | Too many attempts; wait and retry |
| `BAD_REQUEST` | The request couldn't be read |
| `INTERNAL` | Something broke on the server; details go to the logs, never to the client |

## Environment variables

Copy `.env.example` to `.env` (`bin/setup` does it). Development works with the defaults.

| Variable | Needed in | Purpose |
| --- | --- | --- |
| `DATABASE_URL` | production | Postgres connection; merged into `config/database.yml` |
| `REDIS_URL` | all | Sidekiq jobs; in production also the cache that holds rate-limit counters |
| `SECRET_KEY_BASE` | production | Signs tokens; or provide `RAILS_MASTER_KEY` for the credentials file |
| `ALLOWED_HOSTS` | production | Host names the API answers to; the app won't boot without it |
| `FRONTEND_URL` | all | The React app; links in emails point here |
| `CORS_ALLOWED_ORIGINS` | all | Browser origins allowed to call `/graphql` |
| `MAILER_SENDER` | all | The "from" address of emails |
| `SUPER_ADMIN_EMAIL`, `SUPER_ADMIN_PASSWORD` | first deploy | `bin/rails db:seed` creates this super admin |
| `GRAPHQL_INTROSPECTION` | optional | `true` turns schema introspection on in production |
| `APP_HOST` | development | Host for URLs built in development |

## Running in production

The `Dockerfile` builds a production image. On start it runs `db:prepare` (migrations), then Puma behind Thruster on port 80. It runs as two processes from the same image:

- **web:** the default command
- **worker:** `bundle exec sidekiq -C config/sidekiq.yml`

Production forces HTTPS, answers only `ALLOWED_HOSTS`, caps each IP at 300 requests a minute, cancels queries that run over 15 seconds, and keeps credentials and personal data out of the logs.

Not done yet, planned for the deploy: email delivery (SMTP settings in `config/environments/production.rb`), `trusted_proxies` for the host's load balancer, and an error tracker for `Rails.error`.