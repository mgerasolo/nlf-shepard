# Security Practices

## Never Commit

- API keys, tokens, passwords
- Private keys or certificates
- `.env` files with real values
- Database connection strings with credentials

Use `.gitignore` and environment variables.

## Input Validation

- Validate all user input
- Sanitize before database queries
- Use parameterized queries (never string concatenation)
- Validate file uploads (type, size, content)

## Authentication

- Use established libraries (don't roll your own)
- Hash passwords with bcrypt (cost factor 10+)
- Use secure session management
- Implement rate limiting on auth endpoints

## Authorization

- Check permissions on every request
- Use principle of least privilege
- Validate ownership before updates/deletes
- Log authorization failures

## HTTPS

- All production traffic over HTTPS
- Set secure cookie flags
- Use HSTS headers

## Dependencies

- Keep dependencies updated
- Review security advisories
- Use lock files for reproducible builds
- Audit with `npm audit` or equivalent

## Logging Security Events

Log (without sensitive data):
- Failed login attempts
- Permission denied events
- Password changes
- Admin actions

## Environment Variables

```bash
# Use .env.example for documentation
DATABASE_URL=
API_KEY=
JWT_SECRET=

# Never commit .env with real values
```
