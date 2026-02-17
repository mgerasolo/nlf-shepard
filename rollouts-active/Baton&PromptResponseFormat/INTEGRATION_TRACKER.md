# Issue System Integration Tracker

> **Purpose:** Track which projects have been integrated with the NLF Issue Management System
>
> **Last updated:** 2025-12-25

---

## Integration Status

| Project | Status | Submitter Label | Callback URL | Notes |
|---------|--------|-----------------|--------------|-------|
| appbrain | ⏳ Pending | `submitter:appbrain` | `https://dev.appbrain.cloud/api/webhooks/issues` | |
| appbrain-ai | ⏳ Pending | `submitter:appbrain-ai` | `https://dev.appbrain.cloud/api/webhooks/issues` | |
| appbrain-plugins | ⏳ Pending | `submitter:appbrain-plugins` | `https://dev.appbrain.cloud/api/webhooks/issues` | |
| doughflow | ⏳ Pending | `submitter:doughflow` | `https://doughflow.pro/api/webhooks/issues` | |
| finance-ingest | ⏳ Pending | `submitter:finance-ingest` | `https://finance-ingest.nextlevelfoundry.com/api/webhooks/issues` | |
| dashcentral | ⏳ Pending | `submitter:dashcentral` | `https://dashcentral.nextlevelfoundry.com/api/webhooks/issues` | |
| habits | ⏳ Pending | `submitter:habits` | `https://habits.nextlevelfoundry.com/api/webhooks/issues` | |
| health | ⏳ Pending | `submitter:health` | `https://health.nextlevelfoundry.com/api/webhooks/issues` | |
| n8n | ⏳ Pending | `submitter:n8n` | `https://n8n.nextlevelguild.com/api/webhooks/issues` | Internal only |

**Legend:**
- ⏳ Pending - Not started
- 🏗️ In Progress - Integration underway
- ✅ Complete - Fully integrated and tested
- ⚠️ Partial - Some features implemented
- ❌ Blocked - Waiting on dependency

---

## Integration Checklist (Per Project)

Copy this for each project:

### [Project Name]

**Date started:** YYYY-MM-DD
**Date completed:** YYYY-MM-DD
**Cursor project:** [project]-dev
**Submitter:** submitter:[project]

#### Implementation
- [ ] Dependencies installed (@octokit/rest, dotenv)
- [ ] GitHub token created and stored
- [ ] `src/services/issue-automation.js` created
- [ ] `src/routes/webhooks.js` created
- [ ] Webhook route registered in app
- [ ] Environment variables configured
- [ ] `.issue-tracker/` added to .gitignore

#### Testing
- [ ] Test script created (`scripts/test-issue-submission.js`)
- [ ] Test issue submitted successfully
- [ ] Test webhook received successfully
- [ ] Traefik route configured for webhooks
- [ ] End-to-end test passed

#### Usage
- [ ] First real issue detection implemented
- [ ] Resolution handler implemented
- [ ] Deployed to production
- [ ] First automated issue submitted
- [ ] First resolution callback received
- [ ] Workflow resumption verified

#### Documentation
- [ ] Usage documented in project README
- [ ] Team notified of new capability
- [ ] Examples added to project docs

---

## Common Issues & Solutions

### Issue: GitHub Token Permissions

**Problem:** `Bad credentials` or `Resource not accessible`

**Solution:**
1. Token needs `repo` scope (full control of private repositories)
2. Regenerate token at https://github.com/settings/tokens/new
3. Update in Infisical or `.env`

### Issue: Webhook Not Accessible

**Problem:** Callback URL returns 404 or times out

**Solution:**
1. Verify Traefik route is configured
2. Check service is running: `docker ps | grep [service]`
3. Test locally first: `curl http://localhost:8080/api/webhooks/issues`
4. Check Traefik dashboard for route status

### Issue: Rate Limit Exceeded

**Problem:** Too many issues being submitted

**Solution:**
1. Review detection logic - is it too aggressive?
2. Add caching to reduce duplicate submissions
3. Increase threshold for automatic submission
4. Consider batching related issues

### Issue: Callback Not Triggering

**Problem:** Issue resolved but no webhook received

**Solution:**
1. Check webhook-dispatcher service is running on Helicarrier
2. Verify callback URL is correct in submitted issues
3. Check webhook-dispatcher logs: `docker logs webhook-dispatcher`
4. Ensure callback URL is whitelisted in dispatcher config

---

## Verification Commands

### Check Submitted Issues

```bash
# All issues from a project
gh issue list --repo mgerasolo/nlf-infrastructure --label "submitter:appbrain"

# Automated submissions only
gh issue list --repo mgerasolo/nlf-infrastructure --label "submitter:appbrain,submission:automated"

# Explicit submissions
gh issue list --repo mgerasolo/nlf-infrastructure --label "submitter:appbrain,submission:explicit"
```

### Test Webhook Endpoint

```bash
# Replace [project] and [port] with actual values
curl -X POST https://[project].nextlevelfoundry.com/api/webhooks/issues \
  -H "Content-Type: application/json" \
  -d '{
    "event": "issue_resolved",
    "issue_number": 999,
    "resolution": "completed"
  }'
```

### Check Issue Tracking

```bash
# SSH to project
ssh -p 3322 mgerasolo@[host]

# Check tracked issues
ls -la /path/to/project/.issue-tracker/
cat /path/to/project/.issue-tracker/oauth-provider-api.issue
```

---

## Integration Priority

Suggested order based on dependencies and usage:

1. **appbrain** - Core app, highest priority
2. **appbrain-ai** - Depends on core appbrain
3. **doughflow** - High usage, needs framework APIs
4. **dashcentral** - Central dashboard, integrates with many services
5. **finance-ingest** - Data pipeline, may need core APIs
6. **appbrain-plugins** - Plugin system
7. **habits** - Smaller app, lower priority
8. **health** - Smaller app, lower priority
9. **n8n** - Workflow automation, last (internal only)

---

## Metrics to Track

After integration, monitor:

| Metric | Target | How to Check |
|--------|--------|--------------|
| Issues submitted/week | 2-5 per project | `gh issue list --label "submitter:X"` filtered by date |
| Callback success rate | >95% | Check app logs for successful callbacks |
| Issue resolution time | <48 hours | Check issue closed_at - created_at |
| False positives | <10% | Issues closed as "won't fix" or "invalid" |
| Workflow resumption | 100% | Verify blocked workflows resume after resolution |

---

## Next Steps

1. **Deploy webhook-dispatcher** to Helicarrier (if not already done)
   - See `/mnt/foundry_project/Forge/Standards/issue-automation.md` for setup

2. **Configure GitHub webhook** in nlf-infrastructure repo
   - Settings → Webhooks → Add webhook
   - URL: `https://automation.nextlevelfoundry.com/api/webhooks/github`

3. **Integrate projects** following priority order above

4. **Monitor first submissions** from each project

5. **Iterate and improve** detection logic based on results

---

## Resources

- **Full Integration Guide:** `INTEGRATE_ISSUE_SYSTEM.md`
- **AI Prompt:** `PROMPT_FOR_AI.md`
- **Standards:** `/mnt/foundry_project/Forge/Standards/issue-automation.md`
- **Project Management:** `/mnt/foundry_project/Forge/Standards/project-management.md`
- **Issue Management:** `/mnt/foundry_project/Forge/Standards/issue-management.md`

---

**Last updated:** 2025-12-25
