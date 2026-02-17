# Code Quality Standards

## Error Handling

- Catch specific exceptions, not generic
- Log errors with context (user, request ID, etc.)
- Return meaningful error messages to users
- Never expose stack traces in production

```typescript
// Good
try {
  await processOrder(orderId);
} catch (error) {
  logger.error('Order processing failed', { orderId, error });
  throw new UserFacingError('Unable to process order. Please try again.');
}

// Bad
try {
  await processOrder(orderId);
} catch (e) {
  console.log(e);
  throw e;
}
```

## Logging

- Use structured logging (JSON format)
- Include correlation IDs for request tracing
- Log at appropriate levels: debug, info, warn, error
- Never log sensitive data (passwords, tokens, PII)

## Testing

- Write tests for new features
- Test edge cases and error conditions
- Integration tests for API endpoints
- Mock external services

## Code Organization

- One responsibility per file/module
- Keep functions under 50 lines
- Extract reusable logic into utilities
- Use meaningful names that describe intent

## Comments

- Comment "why", not "what"
- Keep comments up to date
- Use TODO with ticket reference: `// TODO(#123): refactor this`
- Remove commented-out code
