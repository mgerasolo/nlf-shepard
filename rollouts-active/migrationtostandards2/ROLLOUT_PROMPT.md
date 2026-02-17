# Standards Directory Migration - App Development Projects

## Context

The infrastructure standards directory has been reorganized to separate infrastructure-only standards from application development standards. This improves clarity and reduces context noise for app development teams.

## What Changed

The old `Standards/` directory has been reorganized into `Standards-v2/` with three sections:

```
Standards-v2/
├── infrastructure/    # Infrastructure team only - NOT for app projects
├── apps/             # App development standards
└── shared/           # Standards both teams need
```

## For App Development Projects

**You only need to reference files in:**
- `Standards-v2/apps/` - Application-specific standards
- `Standards-v2/shared/` - Shared standards (Containers, secrets, security, documentation)

**Do NOT reference:**
- `Standards-v2/infrastructure/` - These are infrastructure-only standards

## Task: Update This Project

Please scan this project for any references to the old `Standards/` directory and update them according to the mapping below.

### Path Mapping for App Projects

**Shared Standards** (you likely reference these):

| Old Path | New Path |
|----------|----------|
| `Standards/documentation-format.md` | `Standards-v2/shared/documentation-format.md` |
| `Standards/secrets.md` | `Standards-v2/shared/secrets.md` |
| `Standards/security.md` | `Standards-v2/shared/security.md` |
| `Standards/Containers/` | `Standards-v2/shared/Containers/` |
| `Standards/Containers/compose-conventions.md` | `Standards-v2/shared/Containers/compose-conventions.md` |
| `Standards/Containers/portainer-stack-standards.md` | `Standards-v2/shared/Containers/portainer-stack-standards.md` |
| `Standards/Containers/deployment-verification.md` | `Standards-v2/shared/Containers/deployment-verification.md` |

**App Standards** (if you reference design specs):

| Old Path | New Path |
|----------|----------|
| `Standards/Design/` | `Standards-v2/apps/Design/` |
| `Standards/Design/phoenixui-design-spec.md` | `Standards-v2/apps/Design/phoenixui-design-spec.md` |

**Infrastructure Standards** (if you reference these, consider if you really need to):

| Old Path | New Path | Note |
|----------|----------|------|
| `Standards/ports.md` | `Standards-v2/infrastructure/ports.md` | Usually only infrastructure needs this |
| `Standards/deployments.md` | `Standards-v2/infrastructure/deployments.md` | Usually only infrastructure needs this |
| Any other `Standards/*.md` | See `Standards-v2/MIGRATION.md` | Likely infrastructure-only |

## Step-by-Step Instructions

1. **Scan for references:**
   ```bash
   grep -r "Standards/" . \
     --include="*.md" \
     --include="*.json" \
     --include="*.yml" \
     --include="*.yaml" \
     --include="*.sh" \
     --include=".env*" \
     --include="CLAUDE.md" \
     --exclude-dir="node_modules" \
     --exclude-dir=".git" \
     -n
   ```

2. **Review each reference:**
   - Is it in the "Shared" or "Apps" category? → Update to new path
   - Is it in the "Infrastructure" category? → Consider if you really need it
   - Not sure? → Check `Standards-v2/README.md` for guidance

3. **Update the references:**
   - Use automated script from QUICK_COMMANDS.md (recommended)
   - Or use search & replace in your editor
   - Or manually update each file
   - **Note:** Most developers use `AppServices/Standards/` (relative paths), not absolute paths

4. **Verify:**
   - Run automated verification: `bash UpdateAllDevProjects/migrationtostandards2/verify-migration.sh`
   - Check that all referenced files exist at new paths
   - Ensure documentation still renders correctly
   - Run any build/test commands to verify nothing broke

5. **Clean up:**
   - Remove this rollout directory after migration
   - Report completion

## Example Updates

**Most Common (AppServices-relative paths):**

**Before:**
```markdown
See [secrets.md](AppServices/Standards/secrets.md) for details.
```

**After:**
```markdown
See [secrets.md](AppServices/Standards-v2/shared/secrets.md) for details.
```

**Before:**
```markdown
Follow [compose-conventions.md](AppServices/Standards/Containers/compose-conventions.md)
```

**After:**
```markdown
Follow [compose-conventions.md](AppServices/Standards-v2/shared/Containers/compose-conventions.md)
```

**Less Common (Absolute paths):**

**Before:**
```markdown
See [secrets.md](/mnt/foundry_project/Forge/Standards/secrets.md) for details.
```

**After:**
```markdown
See [secrets.md](/mnt/foundry_project/Forge/Standards-v2/shared/secrets.md) for details.
```

## Questions?

- Full migration guide: `/mnt/foundry_project/Forge/Standards-v2/MIGRATION.md`
- Directory structure: `/mnt/foundry_project/Forge/Standards-v2/README.md`
- Path mappings: `/mnt/foundry_project/Forge/Standards-v2/MIGRATION.md`

## Timeline

- **Now - Day 2:** Both `Standards/` and `Standards-v2/` coexist
- **After Day 2:** Old `Standards/` directory will be deleted
- **Action required:** Update references before old directory is deleted
