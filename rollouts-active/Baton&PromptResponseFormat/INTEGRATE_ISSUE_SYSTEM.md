# Integrate NLF Issue Management System

> **Purpose:** Enable this project to submit issues to core framework and receive completion notifications
>
> **Target Projects:** appbrain, appbrain-ai, appbrain-plugins, doughflow, finance-ingest, dashcentral, habits, health, n8n
>
> **Date:** 2025-12-25

---

## Overview

You are being integrated with the **NLF Issue Management System**, which allows you to:

1. **Automatically submit issues** to the core framework (`nlf-infrastructure`) when you detect missing features, API mismatches, or blocking problems
2. **Track which cursor project** submitted the issue
3. **Distinguish automated vs explicit** issue submissions
4. **Receive notifications** when issues are resolved so you can resume blocked workflows
5. **Participate in cross-project collaboration** with other NLF apps

## Standards to Read

These standards define the entire system:

| Standard | Path | What It Covers |
|----------|------|----------------|
| **Project Management** | `/mnt/foundry_project/Forge/Standards-v2/infrastructure/project-management.md` | GitHub Projects, labels, board setup |
| **Issue Management** | `/mnt/foundry_project/Forge/Standards-v2/infrastructure/issue-management.md` | Issue lifecycle, submission, handling |
| **Task Management** | `/mnt/foundry_project/Forge/Standards-v2/infrastructure/task-management.md` | Daily task workflow, prioritization |
| **Issue Automation** | `/mnt/foundry_project/Forge/Standards-v2/infrastructure/issue-automation.md` | **← START HERE** - Automated submission, webhooks |

**Focus on:** `issue-automation.md` - it has all the code examples and implementation details.

---

## Your Submitter Identity

Based on your project, use this submitter label:

| Project | Submitter Label |
|---------|-----------------|
| AppBrain core | `submitter:appbrain` |
| AppBrain AI subsystem | `submitter:appbrain-ai` |
| AppBrain plugins | `submitter:appbrain-plugins` |
| DoughFlow | `submitter:doughflow` |
| Finance Ingest | `submitter:finance-ingest` |
| DashCentral | `submitter:dashcentral` |
| Habits | `submitter:habits` |
| Health | `submitter:health` |
| n8n workflows | `submitter:n8n` |

**Your rate limit:** See `issue-automation.md` - most apps get 10 issues/hour, AI subsystems get 15.

---

## Implementation Tasks

### Phase 1: Setup (30 minutes)

#### 1. Install Dependencies

```bash
npm install @octokit/rest dotenv
# or
yarn add @octokit/rest dotenv
```

#### 2. Create GitHub Token

1. Go to https://github.com/settings/tokens/new
2. Name: `[YourProject] Issue Automation`
3. Scopes: `repo` (full control of private repositories)
4. Generate token
5. Store in Infisical or `.env`:

```bash
# .env
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx
GITHUB_ISSUE_REPO_OWNER=mgerasolo
GITHUB_ISSUE_REPO_NAME=nlf-infrastructure
CALLBACK_WEBHOOK_URL=https://[yourapp].nextlevelfoundry.com/api/webhooks/issues
SUBMITTER_NAME=appbrain  # Change to your submitter
```

#### 3. Create Issue Submission Module

**File:** `src/services/issue-automation.js` (or `.ts`)

```javascript
// src/services/issue-automation.js
const { Octokit } = require('@octokit/rest');
const fs = require('fs');
const path = require('path');

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

const ISSUE_TRACKER_DIR = path.join(__dirname, '../../.issue-tracker');
if (!fs.existsSync(ISSUE_TRACKER_DIR)) {
  fs.mkdirSync(ISSUE_TRACKER_DIR, { recursive: true });
}

/**
 * Submit an issue to nlf-infrastructure
 *
 * @param {Object} config - Issue configuration
 * @param {string} config.title - Issue title (without [AUTO] prefix)
 * @param {string} config.description - Main issue description
 * @param {string} config.impact - What's blocked or affected
 * @param {string} config.context - Additional context, logs, etc.
 * @param {string} config.priority - 'critical', 'high', 'medium', 'low'
 * @param {string[]} config.additionalLabels - Extra labels like 'area:api'
 * @param {boolean} config.explicit - Was this explicitly requested by user? (default: false)
 * @param {string} config.identifier - Unique ID for tracking (e.g., 'oauth-provider-api')
 * @returns {Promise<number>} Issue number
 */
async function submitIssue(config) {
  const {
    title,
    description,
    impact,
    context = '',
    priority = 'medium',
    additionalLabels = [],
    explicit = false,
    identifier
  } = config;

  const submitter = process.env.SUBMITTER_NAME || 'other';
  const submissionType = explicit ? 'explicit' : 'automated';
  const cursorProject = process.env.CURSOR_PROJECT || `${submitter}-dev`;
  const version = process.env.APP_VERSION || getGitCommit();

  const body = formatIssueBody({
    submitter,
    cursorProject,
    submissionType,
    version,
    description,
    impact,
    context
  });

  const labels = [
    'type:enhancement',
    `submitter:${submitter}`,
    `submission:${submissionType}`,
    `priority:${priority}`,
    ...additionalLabels
  ];

  console.log(`Submitting issue to nlf-infrastructure: ${title}`);

  const issue = await octokit.issues.create({
    owner: process.env.GITHUB_ISSUE_REPO_OWNER || 'mgerasolo',
    repo: process.env.GITHUB_ISSUE_REPO_NAME || 'nlf-infrastructure',
    title: `[AUTO]: ${title}`,
    body,
    labels
  });

  console.log(`✓ Issue created: #${issue.data.number}`);
  console.log(`  URL: ${issue.data.html_url}`);

  // Track issue locally for callback matching
  if (identifier) {
    saveIssueMapping(identifier, issue.data.number);
  }

  return issue.data.number;
}

function formatIssueBody(config) {
  const callbackUrl = process.env.CALLBACK_WEBHOOK_URL || '';

  return `---
**Submitted by:** ${config.submitter} (cursor project: ${config.cursorProject})
**Submission type:** ${config.submissionType}
**Source version:** ${config.version}
${callbackUrl ? `**Callback webhook:** ${callbackUrl}` : ''}
---

## Issue Description

${config.description}

## Impact

${config.impact}

${config.context ? `## Additional Context\n\n${config.context}` : ''}
`;
}

function getGitCommit() {
  try {
    const { execSync } = require('child_process');
    return execSync('git rev-parse --short HEAD').toString().trim();
  } catch {
    return 'unknown';
  }
}

function saveIssueMapping(identifier, issueNumber) {
  const filePath = path.join(ISSUE_TRACKER_DIR, `${identifier}.issue`);
  fs.writeFileSync(filePath, issueNumber.toString());
}

function getIssueNumber(identifier) {
  try {
    const filePath = path.join(ISSUE_TRACKER_DIR, `${identifier}.issue`);
    return parseInt(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return null;
  }
}

function clearIssueMapping(identifier) {
  try {
    const filePath = path.join(ISSUE_TRACKER_DIR, `${identifier}.issue`);
    fs.unlinkSync(filePath);
  } catch (err) {
    // Ignore if doesn't exist
  }
}

module.exports = {
  submitIssue,
  getIssueNumber,
  clearIssueMapping
};
```

#### 4. Create Webhook Handler

**File:** `src/routes/webhooks.js`

```javascript
// src/routes/webhooks.js
const express = require('express');
const router = express.Router();
const { getIssueNumber, clearIssueMapping } = require('../services/issue-automation');

// Store pending issues
const pendingIssues = new Map();

/**
 * Receive issue status updates from nlf-infrastructure
 *
 * POST /api/webhooks/issues
 * Body: {
 *   event: 'issue_created' | 'issue_resolved',
 *   issue_number: number,
 *   status?: string,
 *   resolution?: string,
 *   pull_request?: string
 * }
 */
router.post('/issues', express.json(), async (req, res) => {
  const { event, issue_number, status, resolution, pull_request } = req.body;

  console.log(`[Webhook] Received: ${event} for issue #${issue_number}`);

  try {
    if (event === 'issue_created') {
      // Issue successfully created in core framework
      pendingIssues.set(issue_number, {
        status: 'pending',
        created_at: new Date()
      });

      console.log(`Issue #${issue_number} created, awaiting resolution`);

    } else if (event === 'issue_resolved') {
      // Core framework completed the work!
      const issue = pendingIssues.get(issue_number);

      if (issue) {
        issue.status = 'resolved';
        issue.resolution = resolution;
        issue.resolved_at = new Date();
        issue.pull_request = pull_request;

        console.log(`✓ Issue #${issue_number} resolved: ${resolution}`);

        // Handle the resolution
        await handleResolution(issue_number, resolution, pull_request);

        // Clean up
        pendingIssues.delete(issue_number);
      }
    }

    res.status(200).json({ received: true });

  } catch (error) {
    console.error('[Webhook] Error:', error);
    res.status(500).json({ error: 'Processing failed' });
  }
});

/**
 * Handle issue resolution
 */
async function handleResolution(issueNumber, resolution, pullRequest) {
  if (resolution === 'completed') {
    console.log(`✓ Issue #${issueNumber} completed - feature now available`);
    console.log(`  PR: ${pullRequest || 'N/A'}`);

    // Examples of what to do:
    // - Retry previously failed operation
    // - Re-run integration tests
    // - Update local cache
    // - Resume blocked workflow
    // - Notify developers

    // Example: If OAuth provider API is now available
    const oauthIssue = getIssueNumber('oauth-provider-api');
    if (issueNumber === oauthIssue) {
      console.log('OAuth provider API now available - resuming auth setup');
      clearIssueMapping('oauth-provider-api');
      // await setupOAuthProviders(); // Your actual function
    }

  } else if (resolution === 'not_planned') {
    console.log(`⚠ Issue #${issueNumber} won't be fixed - need to find workaround`);
    // Implement fallback or workaround
  }
}

module.exports = router;
```

#### 5. Register Webhook Route

**File:** `src/app.js` or `src/index.js`

```javascript
const webhooksRouter = require('./routes/webhooks');

// ... your other routes ...

app.use('/api/webhooks', webhooksRouter);
```

#### 6. Add to .gitignore

```gitignore
# Issue tracking
.issue-tracker/
```

---

### Phase 2: Usage Examples (15 minutes)

#### Example 1: Detect Missing API Endpoint

```javascript
// src/services/auth.js
const { submitIssue } = require('./issue-automation');

async function getOAuthProviders() {
  try {
    const response = await fetch('https://api.nlf.com/v1/config/oauth-providers');

    if (response.status === 404) {
      // API doesn't exist - submit issue
      console.log('OAuth provider API not found - submitting issue to core framework');

      await submitIssue({
        title: 'AppBrain needs OAuth provider config API',
        description: `AppBrain authentication module needs to retrieve list of configured OAuth providers from the core framework.

## Expected API

\`\`\`
GET /api/v1/config/oauth-providers
Response: [
  {"provider": "google", "client_id": "...", "enabled": true},
  {"provider": "github", "client_id": "...", "enabled": true}
]
\`\`\``,
        impact: `- Cannot implement "Login with Google/GitHub" feature
- Blocking AppBrain v2.1.0 release`,
        context: `Currently using hardcoded provider list as workaround.
Needed by: AppBrain auth module v2.1.0
Similar needs: DoughFlow, other apps using OAuth`,
        priority: 'high',
        additionalLabels: ['area:api'],
        identifier: 'oauth-provider-api'
      });

      // Use fallback for now
      return getHardcodedProviders();
    }

    return await response.json();

  } catch (error) {
    console.error('Failed to fetch OAuth providers:', error);
    return getHardcodedProviders();
  }
}
```

#### Example 2: User Explicitly Requests Feature

```javascript
// src/routes/admin.js
const { submitIssue } = require('../services/issue-automation');

router.post('/request-feature', async (req, res) => {
  const { title, description, priority } = req.body;

  // User explicitly requested this feature be added to core framework
  const issueNumber = await submitIssue({
    title,
    description,
    impact: `User-requested feature for ${process.env.SUBMITTER_NAME}`,
    priority: priority || 'medium',
    explicit: true, // Mark as explicit request
    additionalLabels: ['area:feature-request']
  });

  res.json({
    success: true,
    message: `Feature request submitted as issue #${issueNumber}`,
    url: `https://github.com/mgerasolo/nlf-infrastructure/issues/${issueNumber}`
  });
});
```

#### Example 3: Detecting API Contract Mismatch

```javascript
// src/services/api-client.js
const { submitIssue } = require('./issue-automation');

async function fetchUserData(userId) {
  const response = await fetch(`https://api.nlf.com/v1/users/${userId}`);
  const data = await response.json();

  // Validate expected fields
  const requiredFields = ['id', 'email', 'name', 'roles'];
  const missingFields = requiredFields.filter(field => !(field in data));

  if (missingFields.length > 0) {
    console.error(`API contract mismatch: missing fields ${missingFields.join(', ')}`);

    // Submit issue about API contract
    await submitIssue({
      title: `User API missing fields: ${missingFields.join(', ')}`,
      description: `The \`GET /v1/users/:id\` endpoint is missing expected fields.`,
      impact: `AppBrain cannot properly display user information.
Missing fields: ${missingFields.join(', ')}`,
      context: `Expected schema:
\`\`\`json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "roles": ["string"]
}
\`\`\`

Actual response missing: ${missingFields.join(', ')}`,
      priority: 'high',
      additionalLabels: ['area:api', 'type:bug'],
      identifier: 'user-api-schema-mismatch'
    });
  }

  return data;
}
```

---

### Phase 3: Testing (15 minutes)

#### 1. Test Issue Submission

Create a test script:

**File:** `scripts/test-issue-submission.js`

```javascript
#!/usr/bin/env node
require('dotenv').config();
const { submitIssue } = require('../src/services/issue-automation');

async function test() {
  console.log('Testing issue submission...\n');

  const issueNumber = await submitIssue({
    title: 'TEST: Verify issue automation is working',
    description: 'This is a test issue to verify the automated issue submission system.',
    impact: 'No impact - this is a test',
    context: 'Testing from ' + process.env.SUBMITTER_NAME,
    priority: 'low',
    additionalLabels: ['type:test'],
    explicit: true,
    identifier: 'test-issue'
  });

  console.log(`\n✓ Test complete!`);
  console.log(`Issue #${issueNumber} created successfully`);
  console.log(`View at: https://github.com/mgerasolo/nlf-infrastructure/issues/${issueNumber}`);
  console.log(`\nYou can close this test issue manually.`);
}

test().catch(console.error);
```

Run it:

```bash
node scripts/test-issue-submission.js
```

#### 2. Test Webhook Handler

```bash
# Start your app
npm start

# In another terminal, test the webhook
curl -X POST http://localhost:8080/api/webhooks/issues \
  -H "Content-Type: application/json" \
  -d '{
    "event": "issue_resolved",
    "issue_number": 999,
    "resolution": "completed",
    "pull_request": "https://github.com/mgerasolo/nlf-infrastructure/pull/123"
  }'
```

Check your app logs for the webhook handling output.

---

### Phase 4: Configuration (10 minutes)

#### 1. Update Environment Variables

Add these to your `.env` file:

```bash
# Issue Automation
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx
GITHUB_ISSUE_REPO_OWNER=mgerasolo
GITHUB_ISSUE_REPO_NAME=nlf-infrastructure
CALLBACK_WEBHOOK_URL=https://[yourapp].nextlevelfoundry.com/api/webhooks/issues
SUBMITTER_NAME=appbrain  # Change this!
CURSOR_PROJECT=${CURSOR_PROJECT:-appbrain-dev}
APP_VERSION=${npm_package_version:-dev}
```

#### 2. Store in Infisical (Production)

```bash
# Using Infisical CLI
infisical secrets set GITHUB_TOKEN "ghp_xxxxx" --env production --path /
infisical secrets set CALLBACK_WEBHOOK_URL "https://[yourapp].nextlevelfoundry.com/api/webhooks/issues" --env production --path /
infisical secrets set SUBMITTER_NAME "[yourapp]" --env production --path /
```

#### 3. Add Traefik Route (if needed)

If your app doesn't already have a public-facing webhook endpoint, add Traefik route for the webhook:

```yaml
# In your docker-compose.yml or stack file
services:
  app:
    labels:
      - "traefik.http.routers.[yourapp]-webhook.rule=Host(`[yourapp].nextlevelfoundry.com`) && PathPrefix(`/api/webhooks`)"
      - "traefik.http.routers.[yourapp]-webhook.entrypoints=websecure"
      - "traefik.http.routers.[yourapp]-webhook.tls.certresolver=letsencrypt"
```

---

## When to Use This System

### ✅ DO submit issues for:

- Missing framework features you need
- API endpoints that don't exist
- Configuration values missing from core framework
- API contract mismatches (missing fields, wrong types)
- Integration test failures against core services
- Dependency version incompatibilities
- Features needed by multiple apps

### ❌ DON'T submit issues for:

- App-specific bugs (fix in your app)
- User data issues (handle in your app)
- Expected errors (log them, don't submit)
- Transient failures (retry first)
- Things you can easily implement yourself

### 🤔 When in doubt:

Ask yourself: "Does the **core framework** need to change for this to work?"
- **YES** → Submit issue
- **NO** → Fix in your app

---

## Integration Checklist

Copy this to your project's TODO/tasks:

```markdown
## Issue Automation Integration

- [ ] Install dependencies (@octokit/rest, dotenv)
- [ ] Create GitHub token with repo scope
- [ ] Store token in Infisical or .env
- [ ] Create issue-automation.js service
- [ ] Create webhooks.js route handler
- [ ] Register webhook route in app
- [ ] Add .issue-tracker/ to .gitignore
- [ ] Update environment variables
- [ ] Test issue submission (scripts/test-issue-submission.js)
- [ ] Test webhook handler (curl test)
- [ ] Add Traefik route for webhooks (if needed)
- [ ] Document usage in your project README
- [ ] Implement first real issue detection (e.g., missing API)
- [ ] Implement resolution handler for that issue
- [ ] Deploy to production
- [ ] Monitor for first automated issue submission
- [ ] Verify callback works when issue is resolved
```

---

## Monitoring & Debugging

### View Your Submitted Issues

```bash
gh issue list --repo mgerasolo/nlf-infrastructure --label "submitter:[yourapp]"
```

### Check Issue Status

```bash
gh issue view 123 --repo mgerasolo/nlf-infrastructure
```

### View Tracked Issues

```bash
ls -la .issue-tracker/
cat .issue-tracker/oauth-provider-api.issue
```

### Webhook Logs

```bash
# Check your app logs for webhook activity
docker logs [yourapp] | grep "Webhook"

# Or if running locally
npm start | grep "Webhook"
```

---

## Troubleshooting

### Issue Submission Fails

**Error:** `Bad credentials`
- **Fix:** Check `GITHUB_TOKEN` is valid and has `repo` scope

**Error:** `Not Found`
- **Fix:** Check `GITHUB_ISSUE_REPO_OWNER` and `GITHUB_ISSUE_REPO_NAME` are correct

**Error:** `Rate limit exceeded`
- **Fix:** You're submitting too many issues. Review the rate limits in `issue-automation.md`

### Webhook Not Receiving Callbacks

**Problem:** Issue resolved but no webhook received

1. **Check callback URL:** Is `CALLBACK_WEBHOOK_URL` publicly accessible?
2. **Check Traefik route:** Is the route configured and working?
3. **Check webhook-dispatcher:** Is it running on Helicarrier? `docker ps | grep webhook`
4. **Check logs:** `docker logs webhook-dispatcher`
5. **Test manually:** Use curl to send test webhook (see Phase 3)

### Issue Tracking Not Working

**Problem:** `getIssueNumber('identifier')` returns null

- **Fix:** Make sure you passed `identifier` when calling `submitIssue()`
- **Fix:** Check `.issue-tracker/` directory exists and has write permissions

---

## Examples from Other Apps

### AppBrain AI Example

```javascript
// Detect missing AI model configuration
const { submitIssue } = require('../issue-automation');

async function loadModelConfig(modelName) {
  const config = await fetchFromCore(`/ai/models/${modelName}`);

  if (!config) {
    await submitIssue({
      title: `AI model config missing: ${modelName}`,
      description: `AppBrain AI needs configuration for model: ${modelName}`,
      impact: `Cannot use ${modelName} for inference`,
      priority: 'high',
      additionalLabels: ['area:ai', 'area:config'],
      identifier: `ai-model-${modelName}`
    });

    return null; // Fallback
  }

  return config;
}
```

### DashCentral Example

```javascript
// Request widget API
const { submitIssue } = require('../issue-automation');

async function registerWidget(widgetConfig) {
  const response = await fetch('https://api.nlf.com/v1/dashboard/widgets', {
    method: 'POST',
    body: JSON.stringify(widgetConfig)
  });

  if (response.status === 501) {
    // Not implemented yet
    await submitIssue({
      title: 'Widget registration API needed for DashCentral',
      description: `DashCentral needs ability to register custom dashboard widgets.

## Expected API
\`\`\`
POST /api/v1/dashboard/widgets
Body: {
  "id": "string",
  "name": "string",
  "component": "string",
  "config": {}
}
\`\`\``,
      impact: 'Cannot dynamically register dashboard widgets',
      priority: 'medium',
      additionalLabels: ['area:api', 'area:dashboard'],
      identifier: 'widget-registration-api'
    });
  }
}
```

---

## Next Steps

After integration:

1. **Use it!** Start detecting and submitting real issues
2. **Iterate:** Improve your detection logic based on what works
3. **Handle resolutions:** Implement smart resumption when issues are resolved
4. **Monitor:** Watch for automated submissions and callback successes
5. **Collaborate:** Your issues help other apps too (shared APIs)

---

## Questions?

See the full standards:
- `/mnt/foundry_project/Forge/Standards-v2/infrastructure/issue-automation.md`
- `/mnt/foundry_project/Forge/Standards-v2/infrastructure/issue-management.md`

Or submit an issue to nlf-infrastructure (manually for now 😊).

---

**Last updated:** 2025-12-25
