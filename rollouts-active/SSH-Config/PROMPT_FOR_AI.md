# SSH-Config Rollout - AI Instructions

## Objective
Configure SSH for NLF infrastructure access on this host.

## Prerequisites
- SSH already installed on target host
- User has `~/.ssh/` directory
- Source key available at `/mnt/foundry_project/AppServices/env/.ssh/id_ed25519_nlf`

## Deployment Steps

### 1. Check Current State
```bash
ls -la ~/.ssh/
cat ~/.ssh/config 2>/dev/null || echo "No config"
```

### 2. Copy SSH Key (if missing)
```bash
# Check if key exists
if [ ! -f ~/.ssh/id_ed25519_nlf ]; then
    cp /mnt/foundry_project/AppServices/env/.ssh/id_ed25519_nlf ~/.ssh/
    cp /mnt/foundry_project/AppServices/env/.ssh/id_ed25519_nlf.pub ~/.ssh/
    chmod 600 ~/.ssh/id_ed25519_nlf
    chmod 644 ~/.ssh/id_ed25519_nlf.pub
    echo "SSH key installed"
else
    echo "SSH key already exists"
fi
```

### 3. Append NLF Config to SSH Config
```bash
# Check if NLF config already present
if ! grep -q "Next Level Foundry Infrastructure" ~/.ssh/config 2>/dev/null; then
    cat skeleton_files/.ssh/config_nlf >> ~/.ssh/config
    echo "NLF SSH config appended"
else
    echo "NLF SSH config already present"
fi
```

### 4. Verify Connectivity
```bash
ssh -o ConnectTimeout=5 helicarrier "echo 'SSH to helicarrier works'"
```

## Success Criteria
- `~/.ssh/id_ed25519_nlf` exists with mode 600
- `~/.ssh/config` contains NLF host aliases
- Can SSH to helicarrier, stark, parker by hostname

## Notes
- SSH keys are stored securely in `/mnt/foundry_project/AppServices/env/.ssh/`
- Keys should NOT be committed to git
- This rollout is HOST-LEVEL, not project-level
