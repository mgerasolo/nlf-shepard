# Image Generation Rollout Checklist

Track rollout progress for each project.

## Rollout Status

| Project | CLAUDE.md Updated | Directory Created | Test Passed | Status |
|---------|-------------------|-------------------|-------------|--------|
| infrastructure | - | - | - | N/A (source) |
| appbrain | [ ] | [ ] | [ ] | pending |
| finance-ingest | [ ] | [ ] | [ ] | pending |
| doughflow | [x] | [x] | [ ] | complete |
| dashcentral | [ ] | [ ] | [ ] | skip |
| admin | [ ] | [ ] | [ ] | pending |
| basic-habits | [ ] | [ ] | [ ] | pending |
| self-improving-ai | [ ] | [ ] | [ ] | pending |
| start-matt | [ ] | [ ] | [ ] | pending |
| shadcn-wireframer | [ ] | [ ] | [ ] | pending |
| habitarcade-poc | [x] | [x] | [ ] | complete |

## Quick Commands

```bash
# Run verification in any project
bash /mnt/foundry_project/AppServices/ShepardProtocol/rollouts-active/ImageGeneration/verify-migration.sh

# Create project directory
ssh -p 3322 helicarrier "docker exec n8n mkdir -p /data/imagegen/PROJECT_NAME"

# Test image generation
curl -X POST "http://10.0.0.27:2725/webhook/generate-image" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Test image", "provider": "nanobanana", "project": "PROJECT_NAME", "filename": "test.png"}'
```

## Existing Project Directories

Pre-created directories in n8n:
- `appbrain/`
- `doughflow/`
- `habitarcade/`
- `outvestments/`
- `default/`

---

**Last Updated:** 2025-01-02
