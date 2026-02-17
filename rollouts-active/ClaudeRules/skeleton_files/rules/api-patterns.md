# API Design Patterns

## REST Conventions

| Action | Method | Path | Response |
|--------|--------|------|----------|
| List | GET | `/resources` | Array |
| Get one | GET | `/resources/:id` | Object |
| Create | POST | `/resources` | Created object |
| Update | PUT/PATCH | `/resources/:id` | Updated object |
| Delete | DELETE | `/resources/:id` | 204 No Content |

## Response Format

```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "total": 100
  }
}
```

## Error Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "User-friendly message",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

## Status Codes

| Code | Use For |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (delete) |
| 400 | Bad Request (validation) |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Server Error |

## Versioning

Use path versioning: `/api/v1/resources`

## Pagination

```
GET /resources?page=1&limit=20
```

Response includes meta with total count.

## Authentication

- Use Bearer tokens in Authorization header
- Return 401 for invalid/expired tokens
- Return 403 for valid token but insufficient permissions
