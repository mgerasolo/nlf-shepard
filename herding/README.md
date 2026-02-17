# Herding - Protocol Feedback Collection

Herding brings the sheep back in. It collects feedback on deployed protocols to inform future versions.

## Overview

After a protocol has been shepherded out to hosts/projects, herding:
1. Collects feedback on what works and what doesn't
2. Gathers suggestions for improvements
3. Proposes new protocols based on emerging needs
4. Feeds insights back into the iteration cycle

## Directory Structure

```
herding/
├── README.md         # This file
├── pending/          # Feedback awaiting review
│   └── {protocol}-{YYYY-MM-DD}.md
└── processed/        # Feedback that's been addressed
    └── {protocol}-{YYYY-MM-DD}.md
```

## Submitting Feedback

### Via CLI

```bash
shepard.sh herd new {protocol}
```

This creates a new feedback file from template.

### Manual

Create a file in `pending/` following the template:

```markdown
# Feedback: {protocol-name}

**Submitted:** YYYY-MM-DD
**Source:** {host or project where this was observed}
**Protocol Version:** {version when feedback generated}

## What Worked Well

- ...

## What Could Be Better

- ...

## Suggested Changes

- ...

## Related Issues

- #XX
```

## Proposing New Protocols

Herding can also propose entirely new protocols:

```bash
shepard.sh herd propose {name}
```

Creates `pending/new-protocol-{name}.md` with proposal template.

## Processing Feedback

When reviewing and acting on feedback:

1. Review item in `pending/`
2. Create GitHub issue if actionable
3. Implement changes in protocol
4. Add notes to feedback file about what was done
5. Move to `processed/`

```bash
shepard.sh herd process {file}
```

## Feedback Lifecycle

```
Usage observation
       ↓
Feedback submitted (pending/)
       ↓
Review during iteration
       ↓
Issue created / Change implemented
       ↓
Protocol version bumped
       ↓
Feedback archived (processed/)
```

## Integration with Shepherd

Herding is a phase in the Shepherd lifecycle:

1. **Inventory** - Know what protocols exist
2. **Distribute** - Roll out to hosts/projects
3. **Track** - Record what version is where
4. **Herd** - Collect feedback over time ← You are here
5. **Iterate** - Improve protocol, bump version
6. Back to **Distribute**

## See Also

- [Shepherd PROTOCOL.md](../PROTOCOL.md)
- [catalog.json](../catalog.json)
- Issue #222: Shepherd expansion
