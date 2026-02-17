# Image Generation Integration Rollout

Add n8n image generation API integration to NLF projects, enabling AI-powered image generation via webhook.

## What This Rollout Does

1. Adds image generation helper documentation to project's CLAUDE.md
2. Creates project-specific output directory on NAS
3. Verifies webhook connectivity

## Image Generation API

- **Endpoint:** `http://10.0.0.27:2725/webhook/generate-image`
- **Method:** POST
- **Providers:** OpenAI (DALL-E 3), Nano Banana (Google Gemini), Replicate (Flux)
- **Output:** `/mnt/foundry_project/AppServices/n8n/imagegen/{project}/`

## Request Format

```json
{
  "prompt": "Image description",
  "provider": "nanobanana",
  "project": "project-name",
  "filename": "output.png"
}
```

### Providers

| Provider | Model | Best For | Cost |
|----------|-------|----------|------|
| `nanobanana` | Google Gemini | Icons, UI, stylized art | Free tier available |
| `openai` | DALL-E 3 | Photorealistic, complex scenes | ~$0.04/image |
| `replicate` | Flux Schnell | Fast generation | ~$0.003/image |

## Example Usage

```bash
curl -X POST "http://10.0.0.27:2725/webhook/generate-image" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "A pixel art logo, 256x256, transparent background",
    "provider": "nanobanana",
    "project": "myproject",
    "filename": "logo.png"
  }'
```

## Response

```json
{
  "success": true,
  "filename": "logo.png",
  "project": "myproject",
  "path": "AppServices/n8n/imagegen/myproject/logo.png",
  "provider": "nanobanana",
  "model": "gemini-image"
}
```

## Full Documentation

See: `/mnt/foundry_project/Forge/deployments/helicarrier/n8n/image-generation.md`

## Prerequisites

- Network access to 10.0.0.27:2725 (n8n)
- Project directory created at `/mnt/foundry_project/AppServices/n8n/imagegen/{project}/`
