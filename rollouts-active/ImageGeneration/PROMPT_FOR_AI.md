# Image Generation Integration

Add n8n image generation API to this project.

## Tasks

1. **Add to CLAUDE.md** - Add this section to the project's CLAUDE.md (before "## Common Commands" or at end):

```markdown
## Image Generation

Generate images via n8n webhook:

\`\`\`bash
curl -X POST "http://10.0.0.27:2725/webhook/generate-image" \\
  -H "Content-Type: application/json" \\
  -d '{
    "prompt": "YOUR_PROMPT",
    "provider": "nanobanana",
    "project": "PROJECT_NAME",
    "filename": "output.png"
  }'
\`\`\`

**Providers:**
- `nanobanana` - Google Gemini (recommended for icons/UI)
- `openai` - DALL-E 3 (photorealistic)
- `replicate` - Flux Schnell (fast)

**Output:** `/mnt/foundry_project/AppServices/n8n/imagegen/{project}/`

**Full docs:** `/mnt/foundry_project/Forge/deployments/helicarrier/n8n/image-generation.md`
```

2. **Create project directory** (if on infrastructure VM):

```bash
ssh -p 3322 helicarrier "docker exec n8n mkdir -p /data/imagegen/PROJECT_NAME"
```

3. **Test connectivity**:

```bash
curl -X POST "http://10.0.0.27:2725/webhook/generate-image" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Test image, simple blue square",
    "provider": "nanobanana",
    "project": "PROJECT_NAME",
    "filename": "test.png"
  }'
```

## Replace PROJECT_NAME

Replace `PROJECT_NAME` with the actual project identifier (lowercase, no spaces):
- appbrain
- doughflow
- habitarcade
- dashcentral
- etc.

## Success Criteria

- [ ] CLAUDE.md updated with Image Generation section
- [ ] Project directory exists in n8n imagegen folder
- [ ] Test image generation returns `{"success": true, ...}`
