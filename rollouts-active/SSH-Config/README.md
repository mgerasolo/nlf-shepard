# SSH-Config - NLF Infrastructure SSH Access

This rollout configures SSH access to all Next Level Foundry infrastructure hosts.

## What This Rollout Does

1. Copies the NLF SSH key (`id_ed25519_nlf`) to `~/.ssh/`
2. Appends host aliases to `~/.ssh/config`
3. Enables SSH by hostname (e.g., `ssh helicarrier` instead of `ssh -p 3322 mgerasolo@10.0.0.27`)

## Why This Change

Claude Code instances need to SSH to infrastructure hosts (especially Helicarrier) to:
- Create Traefik dynamic configuration files
- Manage infrastructure services
- Access shared storage

## Prerequisites

- Target host has SSH installed
- Target host has access to `/mnt/foundry_project/` (NFS mount)
- User account exists with `~/.ssh/` directory

## Hosts Configured

| Host | IP | User | Port | Role |
|------|-----|------|------|------|
| fury | 10.0.0.20 | mgerasolo | 3322 | NAS |
| assemble | 10.0.0.30 | root | 3322 | Proxmox primary |
| shield | 10.0.0.25 | root | 3322 | Proxmox secondary |
| stark | 10.0.0.31 | mgerasolo | 3322 | Development |
| hulk | 10.0.0.32 | mgerasolo | 3322 | Production |
| banner | 10.0.0.33 | mgerasolo | 3322 | Development |
| parker | 10.0.0.34 | mgerasolo | 3322 | Experimental |
| friday | 10.0.0.35 | mgerasolo | 3322 | Infrastructure automation |
| coulson | 10.0.0.28 | mgerasolo | 3322 | Monitoring |
| helicarrier | 10.0.0.27 | mgerasolo | 3322 | Infrastructure services |
| jarvis | 10.0.0.40 | mgerasolo | 22 | AI (Windows) |

## Scope

This is a **HOST-LEVEL** rollout, not project-level. Deploy once per machine.

## Verification

After rollout:
```bash
ssh helicarrier "hostname"  # Should output "helicarrier"
ssh stark "hostname"         # Should output "stark"
```

## Security Notes

- SSH private key is stored in `/mnt/foundry_project/AppServices/env/.ssh/`
- Key file permissions must be 600
- Keys are NOT stored in git
