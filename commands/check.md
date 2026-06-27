# Check Agent

You run a comprehensive code quality review and deploy testing checklist for web projects. This combines code review (security, performance, architecture) with pre-deploy and post-deploy checks.

## User Request: $ARGUMENTS

---

## When to Run

**AUTO-TRIGGER: Run `/check` automatically — without being asked — in ALL of these situations:**

- After any code change in a session, before wrapping up
- Before any deploy to production
- Before starting a local dev server for review
- After deploying to verify the live site works
- When the user types `/check` or says "run checks" or "test before deploy"

Do not ask "should I run /check?" — just run it.

---

## Phase 1: Code Quality Review

### Resource Limits
- Check `package.json` start script for `--max-old-space-size` — does the Node heap limit make sense for the hosting plan?
- Check for any artificial memory caps, worker limits, or connection pool sizes that are too low for the environment
- If there's a memory watchdog or OOM handler, check if it's triggering frequently in logs
- **Rule: never recommend a hosting upgrade before fixing code-level resource limits first**

### Security (OWASP Top 10)
- Broken access control (missing auth checks?)
- Exposed secrets (hardcoded API keys in client code?)
- Injection vulnerabilities (XSS, SQL injection?)
- Insecure data handling (unvalidated inputs?)
- Environment variables: are secrets in .env (not committed)? Anything sensitive exposed to the client?

### Performance
- Bundle size: any large dependencies or duplicate packages?
- Re-render issues: missing memo/useCallback where it matters?
- Missing lazy loading for heavy components?
- Image optimisation?

### Architecture & TypeScript
- Find `any` types that should be properly typed
- Components over 300 lines (should split?)
- Prop drilling through 3+ levels?
- Error handling and graceful degradation
- No TODO/FIXME left in production code
- No unused imports

For each issue found:
1. Show the exact file:line location
2. Explain why it's a problem
3. Provide the fix

### Priority Levels

| Level | Risk | Action |
|-------|------|--------|
| **Critical** | Security breach or data loss | Fix NOW |
| **High** | User-facing bug or performance | Fix before deploy |
| **Medium** | Technical debt | Plan to fix |
| **Low** | Nice to have | Optional |

---

## Phase 2: Pre-Deploy Checks (Local)

### 1. Build Check
```
pnpm build
```
If this fails, stop and fix the errors before proceeding.

### 2. Visual Page Check
Open the local dev server in Chrome (via browser automation if available) and check every page:
- Homepage: renders correctly, all components visible
- Search: type a query, confirm streaming answer appears
- Committee pages: click into at least 2 committees, check all tabs load
- About page: renders fully, links work
- Member profile: navigate to one, check profile + Hansard tabs

### 3. Responsive / Mobile Check
**MUST use Chrome browser automation (mcp__claude-in-chrome) for this.** Resize window to 390x844 (iPhone) and verify:
- Sidebar collapses to hamburger menu (not visible as sidebar)
- Navigation works via hamburger
- Content doesn't overflow horizontally
- Search box is usable and not cut off
- Search results render properly - answer text, sources, follow-up questions all visible
- Cards stack correctly in single column
- Committee pages render - tabs work, member list readable
- Member profile pages work - all tabs accessible and content renders
- Voting record tab (if present) renders on mobile
- About page renders fully
- Take screenshots at 390px width as evidence

After mobile check, resize back to desktop (1280x800) and verify nothing broke.

### 4. Functional Check
- Run at least 3 different search queries to test breadth:
  1. A topic query (e.g. "what has been said about AI regulation")
  2. A member-specific query (e.g. "what has Chi Onwurah said about broadband")
  3. A cross-committee query (e.g. "compare committee views on net zero targets")
- For each: confirm answer streams, sources appear, follow-up questions appear
- Check source types are represented (committee reports, Hansard, written questions if ingested)
- Test the filter if one exists
- Test copy/export buttons
- Log the response times from the streaming profiling output

---

## Phase 3: Deploy (if requested)

```
git add [changed files] && git commit -m "description"
git push
railway up --detach
```

Wait for build to complete:
```
railway logs --build --latest -n 30
```

---

## Phase 4: Post-Deploy Checks (Live)

### 1. Build Verification
```
railway logs --build --latest -n 10
```
Confirm no errors, deployment succeeded.

### 2. Live Visual Check
Open the live URL and verify all pages render.

### 3. Live Search Test
Run a search query on the live site, confirm answer streams and sources load.

### 4. Live Navigation
Click through committees, about page, member profiles.

---

## Phase 4.5: Copy vs Reality Check (Every Page)

On both local and live, check that all user-facing text accurately reflects what's actually in the platform. This catches stale marketing copy, outdated feature claims, and data descriptions that no longer match reality.

For every page:
- **Homepage / hero text**: Does it claim features or data coverage that don't exist yet (or anymore)?
- **About page**: Are descriptions of what the platform does accurate? Committee count, data types, member coverage?
- **Committee pages**: Do headers or descriptions claim data that isn't actually ingested?
- **Member profiles**: Do tab labels or descriptions promise data that's empty (e.g. "Hansard Activity" tab with no data)?
- **Search UI**: Does placeholder text or helper copy reference capabilities that aren't live?
- **Footer / nav**: Any outdated links or descriptions?

**How to check:** Read the actual text on each page (use Chrome browser automation). Compare claims against the data integrity results from Phase 4.5 below. Flag any mismatch as a copy issue.

**Report format:** List each mismatch as `[page] — [what copy says] vs [what's actually true]`

Any mismatch = FAIL. Log as a GitHub issue if not fixing immediately.

---

## Phase 4.5b: Data Integrity Checks (Live)

These catch pages that return 200 but serve no actual data — the silent failure mode that broke the Witnesses page on 15 Mar 2026. Run all three after every deploy. Any failure = FAIL, fix before reporting success.

### Witnesses (must return ≥50)
```bash
curl -s "https://diplomatic-mindfulness-production.up.railway.app/api/trpc/witnesses.list" | python3 -c "
import sys, json
d = json.load(sys.stdin)
n = len(d['result']['data']['json'])
print(f'Witnesses: {n}')
sys.exit(0 if n >= 50 else 1)
"
```

### Stats (reports >100, witnesses >50)
```bash
curl -s "https://diplomatic-mindfulness-production.up.railway.app/api/trpc/committees.stats" | python3 -c "
import sys, json
d = json.load(sys.stdin)
s = d['result']['data']['json']
print(f'Reports: {s[\"totalReports\"]}, Witnesses: {s[\"uniqueWitnesses\"]}')
sys.exit(0 if s['totalReports'] > 100 and s['uniqueWitnesses'] > 50 else 1)
"
```

### Search returns sources
```bash
curl -s -X POST https://diplomatic-mindfulness-production.up.railway.app/api/search/stream \
  -H "Content-Type: application/json" \
  -d '{"query":"AI regulation","reportIds":[],"limit":3,"mode":"concise"}' \
  --max-time 15 | grep -q '"sources"' && echo "Search: PASS" || echo "Search: FAIL"
```

**If Witnesses returns 0:** run `git ls-files witness-data-cache.json` — if the file is missing from git, re-add it and redeploy.

---

## Phase 5: Cleanup Audit

Check for dead weight across the project. Flag anything found, fix or ask before deleting.

1. **Dead code**: unused exports, unreferenced files, commented-out blocks. Check build warnings + grep for orphaned imports.
2. **Stale data files**: anything in the repo that isn't imported, required by the build, or committed intentionally (e.g. old JSON dumps, one-off scripts).
3. **Hosting**: if Railway, run `railway volume list` and flag orphaned volumes (Attached to: N/A) or offline services. If other hosting, check for equivalent dead resources.
4. **GitHub issues**: flag any open issues that are clearly done, stale, or out of scope.
5. **Dependencies**: check `package.json` for packages that aren't imported anywhere in the codebase.
6. **Logs**: check deploy logs for noisy/broken warnings that should be fixed or removed.

---

## Reporting

After completing all checks, report a summary:

```
CHECK RESULTS
=============
Code quality:    PASS/FAIL (issues: X critical, X high, X medium)
Local build:     PASS/FAIL
Homepage:        PASS/FAIL
Search:          PASS/FAIL
Committees:      PASS/FAIL
About:           PASS/FAIL
Mobile (390px):  PASS/FAIL — sidebar collapses, search works, tabs work
Deploy:          PASS/FAIL (or SKIPPED)
Live homepage:   PASS/FAIL (or SKIPPED)
Live search:     PASS/FAIL (or SKIPPED)
Live navigation: PASS/FAIL (or SKIPPED)
Copy accuracy:   PASS/FAIL — [list mismatches] (or SKIPPED)
Witnesses data:  PASS/FAIL — N witnesses (or SKIPPED)
Stats data:      PASS/FAIL — N reports, N witnesses (or SKIPPED)
Search sources:  PASS/FAIL (or SKIPPED)
Search queries:  PASS/FAIL — 3 queries tested, avg Xs response time
Cleanup audit:   PASS/FAIL — [dead code, stale files, orphaned resources]

Issues found: [list any]
```

If any check fails, fix the issue and re-run that check before proceeding. Do not deploy with critical or high failures.
