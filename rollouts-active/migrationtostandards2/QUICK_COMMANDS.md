# Quick Command Reference

Fast commands for common migration tasks.

## 1. Find All References

```bash
# Find all files with Standards references (expanded file types)
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

# Just show filenames (not line numbers)
grep -r "Standards/" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  -l

# Count total references
grep -r "Standards/" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  | wc -l
```

## 2. Automated Verification (Recommended First Step)

```bash
# Run the automated verification script
bash UpdateAllDevProjects/migrationtostandards2/verify-migration.sh
```

This will check for:
- Old Standards/ references
- Infrastructure references (should be none for app projects)
- Proper Standards-v2 usage
- CLAUDE.md compliance

## 3. Common Search & Replace Patterns

### Shared Standards (most common for apps)

**Note:** Most developers use relative paths like `AppServices/Standards/` not absolute paths.

```bash
# AppServices-relative paths (most common)
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|AppServices/Standards/secrets\.md|AppServices/Standards-v2/shared/secrets.md|g' {} +
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|AppServices/Standards/security\.md|AppServices/Standards-v2/shared/security.md|g' {} +
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|AppServices/Standards/documentation-format\.md|AppServices/Standards-v2/shared/documentation-format.md|g' {} +
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|AppServices/Standards/Containers/|AppServices/Standards-v2/shared/Containers/|g' {} +

# Absolute paths (less common, for infrastructure references)
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|/mnt/foundry_project/Forge/Standards/secrets\.md|/mnt/foundry_project/Forge/Standards-v2/shared/secrets.md|g' {} +
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|/mnt/foundry_project/Forge/Standards/Containers/|/mnt/foundry_project/Forge/Standards-v2/shared/Containers/|g' {} +
```

### App Standards

```bash
# Design directory (AppServices-relative)
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|AppServices/Standards/Design/|AppServices/Standards-v2/apps/Design/|g' {} +

# Design directory (absolute path)
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|/mnt/foundry_project/Forge/Standards/Design/|/mnt/foundry_project/Forge/Standards-v2/apps/Design/|g' {} +
```

### Infrastructure Standards (uncommon for app projects)

**Note:** App projects typically don't need infrastructure standards. Consider removing these references instead of migrating them.

```bash
# Only if you confirmed you need these (rare for app projects)
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|AppServices/Standards/ports\.md|AppServices/Standards-v2/infrastructure/ports.md|g' {} +
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -exec sed -i 's|AppServices/Standards/deployments\.md|AppServices/Standards-v2/infrastructure/deployments.md|g' {} +
```

## 4. Verify Updates

```bash
# Run automated verification (recommended)
bash UpdateAllDevProjects/migrationtostandards2/verify-migration.sh

# Or manual checks:

# Check no old references remain (should be empty)
grep -r "Standards/" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  | grep -v "Standards-v2"

# Verify no infrastructure refs (should be empty for app projects)
grep -r "Standards-v2/infrastructure" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git"

# List all new Standards-v2 references
grep -r "Standards-v2" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  -l
```

## 5. Verify Files Exist

```bash
# Check key shared standards exist
ls -lh /mnt/foundry_project/Forge/Standards-v2/shared/

# Check containers standards
ls -lh /mnt/foundry_project/Forge/Standards-v2/shared/Containers/

# Check app standards
ls -lh /mnt/foundry_project/Forge/Standards-v2/apps/
```

## 6. Commit Changes

```bash
# Stage all changes
git add .

# Commit with standard message
git commit -m "chore: migrate to Standards-v2 directory structure

- Updated all Standards/ references to Standards-v2/
- App project now references shared/ and apps/ directories only
- Verified all paths exist and documentation renders correctly"

# Or short version
git commit -m "chore: migrate to Standards-v2 paths"
```

## 7. Rollback If Needed

```bash
# Revert last commit
git revert HEAD

# Or reset (if not pushed)
git reset --hard HEAD~1
```

## 8. Advanced: Batch Update Script

If you have many references, create a quick script:

```bash
#!/bin/bash
# update-standards.sh

# Backup first
git commit -am "checkpoint before standards migration" || true

# Update AppServices-relative paths (most common)
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -exec sed -i \
  -e 's|AppServices/Standards/secrets\.md|AppServices/Standards-v2/shared/secrets.md|g' \
  -e 's|AppServices/Standards/security\.md|AppServices/Standards-v2/shared/security.md|g' \
  -e 's|AppServices/Standards/documentation-format\.md|AppServices/Standards-v2/shared/documentation-format.md|g' \
  -e 's|AppServices/Standards/Containers/|AppServices/Standards-v2/shared/Containers/|g' \
  -e 's|AppServices/Standards/Design/|AppServices/Standards-v2/apps/Design/|g' \
  {} +

# Update absolute paths (less common)
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -exec sed -i \
  -e 's|/mnt/foundry_project/Forge/Standards/|/mnt/foundry_project/Forge/Standards-v2/shared/|g' \
  {} +

echo "✓ Updated references"
echo ""
echo "Running verification..."
bash UpdateAllDevProjects/migrationtostandards2/verify-migration.sh
```

Make executable and run:
```bash
chmod +x update-standards.sh
./update-standards.sh
```

## Notes

- Always verify changes before committing
- Create backups or commits before bulk updates
- Test that documentation still works after updates
- The old `Standards/` directory exists for a few days as fallback
