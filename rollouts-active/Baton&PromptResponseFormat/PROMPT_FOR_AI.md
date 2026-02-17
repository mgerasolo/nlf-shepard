# AI Prompt: Integrate NLF Issue Management System

> **Copy this entire prompt and paste it into each project's AI assistant (Cursor, Claude, etc.)**

---

## Task: Integrate Automated Issue Submission System

You are working on a development project that is part of the **Next Level Foundry (NLF)** ecosystem. You need to integrate with the centralized issue management system.

## Your Identity

**Project:** [REPLACE WITH: appbrain | appbrain-ai | appbrain-plugins | doughflow | finance-ingest | dashcentral | habits | health | n8n]

**Submitter Label:** `submitter:[project-name]` (e.g., `submitter:appbrain`)

## What This System Does

1. **Auto-detect** when you need a feature from the core framework that doesn't exist
2. **Submit issues** automatically to `mgerasolo/nlf-infrastructure` GitHub repo
3. **Track metadata** like which cursor project submitted it, whether it was automated or explicit
4. **Receive webhooks** when the issue is resolved so you can resume blocked workflows

## Implementation Steps

### 1. Read the Standards

Full implementation guide: `/mnt/foundry_project/AppServices/UpdateAllDevProjects/INTEGRATE_ISSUE_SYSTEM.md`

Complete standards: `/mnt/foundry_project/Forge/Standards/issue-automation.md`

### 2. Implement These Files

Create in this project:

1. **`src/services/issue-automation.js`**
   - `submitIssue(config)` - Submit issue to nlf-infrastructure
   - `getIssueNumber(identifier)` - Get tracked issue by ID
   - `clearIssueMapping(identifier)` - Clean up after resolution

2. **`src/routes/webhooks.js`**
   - `POST /api/webhooks/issues` - Receive resolution notifications
   - `handleResolution(issueNumber, resolution)` - Act on completed issues

3. **Environment Variables**
   ```bash
   GITHUB_TOKEN=ghp_xxxxx
   GITHUB_ISSUE_REPO_OWNER=mgerasolo
   GITHUB_ISSUE_REPO_NAME=nlf-infrastructure
   CALLBACK_WEBHOOK_URL=https://[thisproject].nextlevelfoundry.com/api/webhooks/issues
   SUBMITTER_NAME=[project-name]
   ```

4. **Dependencies**
   ```bash
   npm install @octokit/rest dotenv
   ```

### 3. Usage Pattern

**When to submit:**
```javascript
// Detect missing API
if (response.status === 404) {
  await submitIssue({
    title: 'Need OAuth provider config API',
    description: 'Full description...',
    impact: 'Blocking feature X',
    priority: 'high',
    additionalLabels: ['area:api'],
    identifier: 'oauth-provider-api'
  });
}
```

**When resolved:**
```javascript
// Webhook handler receives notification
async function handleResolution(issueNumber, resolution) {
  if (resolution === 'completed') {
    // Feature now available - retry previously failed operation
    await retryBlockedWorkflow();
  }
}
```

### 4. Metadata Format

Every submitted issue includes:
```markdown
---
**Submitted by:** [project-name] (cursor project: [project-name]-dev)
**Submission type:** automated | explicit
**Source version:** [git commit]
**Callback webhook:** https://[project].nextlevelfoundry.com/api/webhooks/issues
---
```

### 5. Labels Applied

Every issue gets:
- `submitter:[project-name]` - Who submitted
- `submission:automated` or `submission:explicit` - How submitted
- `type:enhancement` (or `type:bug`, etc.)
- `priority:high` (or critical, medium, low)
- Additional labels like `area:api`, `area:config`

## Examples to Implement

### Example 1: Missing API Endpoint
```javascript
const response = await fetch('https://api.nlf.com/v1/config/oauth-providers');

if (response.status === 404) {
  await submitIssue({
    title: 'Need OAuth provider config API',
    description: 'Auth module needs list of configured OAuth providers...',
    impact: 'Cannot implement social login',
    priority: 'high',
    additionalLabels: ['area:api'],
    identifier: 'oauth-provider-api'
  });

  return getFallbackProviders(); // Use workaround for now
}
```

### Example 2: API Contract Mismatch
```javascript
const data = await response.json();
const missingFields = ['email', 'roles'].filter(f => !(f in data));

if (missingFields.length > 0) {
  await submitIssue({
    title: `User API missing fields: ${missingFields.join(', ')}`,
    description: 'GET /v1/users/:id missing expected fields...',
    impact: 'Cannot display user info properly',
    priority: 'high',
    additionalLabels: ['area:api', 'type:bug'],
    identifier: 'user-api-schema-mismatch'
  });
}
```

### Example 3: Webhook Resolution Handler
```javascript
router.post('/api/webhooks/issues', async (req, res) => {
  const { event, issue_number, resolution } = req.body;

  if (event === 'issue_resolved' && resolution === 'completed') {
    console.log(`Issue #${issue_number} resolved!`);

    // Check which issue was resolved
    const oauthIssue = getIssueNumber('oauth-provider-api');
    if (issue_number === oauthIssue) {
      // OAuth API now available!
      await setupOAuthProviders(); // Retry previously failed setup
      clearIssueMapping('oauth-provider-api');
    }
  }

  res.json({ received: true });
});
```

## Checklist

Use this checklist:

```markdown
- [ ] Read INTEGRATE_ISSUE_SYSTEM.md
- [ ] Read issue-automation.md standard
- [ ] Install @octokit/rest and dotenv
- [ ] Create GitHub token with repo scope
- [ ] Create src/services/issue-automation.js
- [ ] Create src/routes/webhooks.js
- [ ] Register webhook route in app
- [ ] Add environment variables
- [ ] Add .issue-tracker/ to .gitignore
- [ ] Test issue submission (create test script)
- [ ] Test webhook handler (curl test)
- [ ] Deploy webhook endpoint with Traefik route
- [ ] Implement first real detection (missing API/feature)
- [ ] Implement resolution handler
- [ ] Deploy and monitor
```

## When to Submit vs Not

**✅ Submit issues for:**
- Missing framework APIs you need
- API contract mismatches
- Missing configuration endpoints
- Features needed by multiple apps
- Integration test failures against core services

**❌ Don't submit for:**
- App-specific bugs (fix in your app)
- User data issues
- Expected errors
- Transient failures (retry first)
- Things you can implement yourself

**Rule of thumb:** Does the **core framework** need to change? → Submit issue

## Rate Limits

Your project has this limit (per hour):
- Most apps: 10 issues/hour
- AI subsystems: 15 issues/hour
- Monitoring: 20 issues/hour

Don't spam! Detect real problems only.

## Testing

Create `scripts/test-issue-submission.js`:
```javascript
require('dotenv').config();
const { submitIssue } = require('../src/services/issue-automation');

submitIssue({
  title: 'TEST: Verify automation works',
  description: 'Test issue',
  impact: 'No impact - test only',
  priority: 'low',
  explicit: true,
  identifier: 'test-issue'
}).then(num => {
  console.log(`✓ Created issue #${num}`);
  console.log(`https://github.com/mgerasolo/nlf-infrastructure/issues/${num}`);
});
```

Run: `node scripts/test-issue-submission.js`

## Questions?

Full documentation: `/mnt/foundry_project/AppServices/UpdateAllDevProjects/INTEGRATE_ISSUE_SYSTEM.md`

Standards: `/mnt/foundry_project/Forge/Standards/issue-automation.md`

---

## Action Required

Please implement this system in the current project following the steps above. Start by:

1. Reading the complete guide in `INTEGRATE_ISSUE_SYSTEM.md`
2. Creating the issue-automation service
3. Creating the webhook handler
4. Testing with a real or test issue
5. Deploying to production

**Estimated time:** 60-90 minutes

Begin implementation now.
