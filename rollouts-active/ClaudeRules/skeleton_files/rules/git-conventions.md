# Git Conventions

## Commit Message Format

```
type(scope): description

Body explaining why (not what)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Types

| Type | Use For |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that neither fixes nor adds |
| `test` | Adding or updating tests |
| `chore` | Maintenance, dependencies, tooling |

## Scope

Use the component or area affected:
- `auth`, `api`, `ui`, `db`, `config`
- Or the specific module name

## Examples

```
feat(auth): add OAuth2 login flow

Implements Google OAuth as requested. Uses PKCE flow
for security. Tokens stored in httpOnly cookies.

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
fix(api): handle null user gracefully

Users without profiles were causing 500 errors on /settings.

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Branch Naming

```
{type}/{ticket-or-description}
```

Examples:
- `feat/oauth-login`
- `fix/null-user-crash`
- `chore/update-deps`

## Pull Requests

- Title follows commit format
- Description includes context and test plan
- Link related issues
