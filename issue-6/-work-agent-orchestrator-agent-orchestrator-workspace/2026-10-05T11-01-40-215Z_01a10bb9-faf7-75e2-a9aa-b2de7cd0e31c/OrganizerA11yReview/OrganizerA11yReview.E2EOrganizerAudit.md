{
  "clean": [
    "`playwright.config.ts:31-35` — single, correctly-scoped project: exactly one browser (`chromium`) with `...devices['Desktop Chrome']`; no duplicate/conflicting `projects` or `use` blocks, and `fullyParallel: false` + `workers: 1` avoids cross-test route-handler bleed.",
    "`organizer-wide-tab-overlay.spec.ts:124` — `await expect(overlay).toHaveAttribute('role', 'dialog')` is a genuine, correct dialog-semantics assertion backed by Radix `DialogPrimitive.Content` (Modal.tsx:57-62).",
    "`organizer-wide-tab-overlay.spec.ts:102` — the suite's only reduced-motion assertion, `await expect(overlay).toHaveCSS('animation-name', 'none')` under `page.emulateMedia({ reducedMotion: 'reduce' })` (:91), is a real computed-style check (not a class-string check) and correctly pairs with `motion-reduce:animate-none` in ManageWideOverlay.tsx:101.",
    "`organizer-wide-tab-overlay.spec.ts:105-113` — real target-size assertion on the close button (`width/height >= 44` via `boundingBox()`), i.e. WCAG 2.5.8, done with measured geometry rather than a class guess.",
    "`organizer-ops-match-scope.spec.ts:166-170` — the one genuine reflow assertion: `document.documentElement.scrollWidth <= window.innerWidth` evaluated in-page at 375 CSS px, plus a `testInfo.attach` full-page screenshot at both widths (:171-178).",
    "`organizer-wide-tab-overlay.spec.ts:307-333` — mobile tab-strip assertions use `scrollWidth <= clientWidth` plus per-button `getBoundingClientRect()` bounds and a `document.createRange().getClientRects()` line-count, so they measure layout instead of trusting CSS classes.",
    "`organizer-wide-tab-overlay.spec.ts:209-223` — the camera dialog is the one place the suite does full accessible-name verification: `getByRole('dialog', { name: 'Thêm camera' })`, `getByRole('heading', …)`, `getByLabel('Tên camera')`, `getByLabel('Sân dùng camera này')`, `getByRole('group', { name: 'Cách lấy luồng' })`, `getByRole('button', { name: 'PULL' })` and a positive+negative `getByLabel('URL phát trực tiếp')` pair.",
    "`organizer-wide-tab-overlay.spec.ts:151, 158, 178` and `roster-import.spec.ts:278-292` — the three Escape presses and the retry/re-preview button-state checks (`toBeEnabled()` / `toBeDisabled()` around a gated action) are correct keyboard/disabled-state coverage for what they claim.",
    "`organizer-venue-registration-settings.spec.ts:160` — `test.use({ timezoneId: 'UTC' })` is the single place the suite gets date determinism right, and it is load-bearing: it makes the `getUTC*` arithmetic at :215-217 and :233-235 agree with `DateTimePicker`'s local-time `parseManualValue` (Input.tsx:127-133).",
    "`organizer-venue-registration-settings.spec.ts:76` — this spec's own `fulfillApi` does advertise `GET, POST, PATCH, OPTIONS`, so its PATCH-based deadline tests are not CORS-blocked; `organizer-auto-save.spec.ts:26` likewise lists PATCH/PUT/DELETE. The gap is only in the shared helper (see finding on organizer-manage.ts:134).",
    "No `force: true` click appears anywhere in the seven target specs — so unlike many suites, no assertion here is made to pass by bypassing real hit-testing, and overlay/pointer-events regressions are not silently masked.",
    "No `.only` anywhere in `web/test/**`, and grep for `test.skip|test.fixme|test.only|test.slow|test.describe.configure|.only(|fixme(|skip(` over the entire test tree returns exactly ONE hit: `test/e2e/p0/fixtures.ts:72`, `if (missing.length) testInfo.skip(true, …)` — an env-gated skip of the `p0/` specs only. There are **zero** `test.fixme` and **zero** `test.only` in the organizer suite, and no skip/fixme gate hides any organizer test.",
    "`organizer-registration-visibility.spec.ts:134, 157` — error/empty-state disambiguation is tested properly with positive AND negative assertions (`getByRole('alert')` visible vs `toHaveCount(0)`, plus a sentinel-body leak check at :136), so a failed read can never masquerade as an empty list.",
    "`organizer-ops-match-scope.spec.ts:135-138, 189-193` — the negative assertions carry the observed request log in the failure message (`\\`Observed match requests: ${matchRequestUrls.join(' | ')}\\``), which is the right debugging affordance for this class of test."
  ],
  "coverage": "READ-ONLY audit. **No tests were executed** — no `playwright test`, no build, no linter, no dev server was run. Every claim below comes from reading source text and is cited with `path:line`. Where a value lives in `node_modules` (the exact `devices['Desktop Chrome']` descriptor numbers) I could not read it because dependencies are not installed; those are marked `[INFERENCE]`.\n\nFILES FULLY READ\n- `playwright.config.ts` (42 lines, complete)\n- `test/e2e/support/organizer-manage.ts` (196 lines, complete)\n- `test/e2e/organizer-auto-save.spec.ts` (81, complete)\n- `test/e2e/organizer-ops-match-scope.spec.ts` (192, complete)\n- `test/e2e/organizer-registration-visibility.spec.ts` (223, complete)\n- `test/e2e/organizer-venue-registration-settings.spec.ts` (258, complete)\n- `test/e2e/organizer-wide-tab-overlay.spec.ts` (545, complete)\n- `test/e2e/roster-import.spec.ts` (422, complete)\n- `test/e2e/quick-tournament.spec.ts` (190, complete)\n- `test/e2e/schedule-card-live-variant.spec.ts` (complete)\n- `test/e2e/fixtures/tournament-mock-api.mjs` (198, complete)\n\nSOURCE READ TO PROVE THE UI-SIDE CLAIMS (not the audit target, read only as evidence)\n- `src/components/ui/Modal.tsx` (complete) — Radix `DialogPrimitive.Content` wrapper, `sr-only` close label\n- `src/components/ui/Input.tsx:51-178` — `DateTimePicker` input markup\n- `src/app/organizer/tournaments/[id]/manage/components/ManageWideOverlay.tsx` (complete)\n- `.../manage/page.tsx:2459-2533, 2759-2765` — top-level tab bar, settings-tab wiring\n- `.../manage/components/OperationsWorkspace.tsx:164-218` — inner ops tabs\n- `.../manage/components/VenueCourtsModal.tsx:99-348` — hand-rolled modal shell, venue tabs, court list\n- `.../manage/components/ScheduleTab.tsx:179-416` — venue cards, `Cài đặt sân` button\n- `.../manage/components/TournamentSettingsTab.tsx:299-403` — the four date fields and their orphan `<label>`s\n- `.../manage/components/RegistrationTab.tsx:936-980` — status badge markup\n- `src/features/tournaments/api.ts:95-125, 703-728` — `TournamentCourt`, `TournamentVenueWithCourts`\n- `src/features/venues/api.ts` (complete) — `Court` with `courtName` + legacy `name`\n- `src/app/organizer/tournaments/[id]/manage/components/useManageState.ts:676-700` — `fetchTournamentVenues`\n- `src/lib/axios.ts:215-278` — `getBaseUrl()` (proves the API origin is cross-origin on localhost)\n- `src/components/shared/SearchableRegionSelect.tsx` (complete)\n- `src/app/organizer/tournaments/create/QuickTournamentCreate.tsx` (grepped for testids/format keys)\n- `messages/vi.json:1028-1031, 1234, 4965-5078` — `Common.dateTimePlaceholder`, `Common.close`, Ops tab labels\n- `package.json:6-13` — `test:e2e` script\n- `.github/workflows/` — full directory listing (`cleanup-merged.yml`, `agent-task.yml` only)\n\nNOT READ / LIMITATIONS (name these honestly)\n- `node_modules/playwright-core` device descriptors — not installed; the 1280×720 / DSF 1 figures for `devices['Desktop Chrome']` are `[INFERENCE]` from documented Playwright behaviour, not read from this repo.\n- `CourtScheduleBoard.tsx` (6415 lines) and `BracketTab.tsx` (1009) were grepped for `role`/`aria`/button markup but not read end-to-end; the \"no organizer test asserts X\" claims for those surfaces rest on the greps, not a full read.\n- `src/app/organizer/tournaments/[id]/ops/page.tsx` read only at 560-615; the rest of the ops route was not read.\n- `eslint.config.mjs` and whether `eslint-plugin-jsx-a11y` is enabled — not checked (belongs to the sibling UI-audit scope, not this one).\n- The real backend response contract (NestJS DTOs in `backend/`) was NOT read. The mock-fidelity findings are proved by comparing the mocks against the **frontend** type contract (`TournamentCourt.courtName`) and against rendered consumers, which is sufficient for the mismatches claimed, but I cannot rule out further mock/backend divergences outside those.\n- `roster-import.spec.ts:301` onward was read in two ranges that together cover the file; I did not re-verify every assertion individually.",
  "findings": [
    {
      "confidence": 1,
      "evidence": "quick-tournament.spec.ts:4 `// const baseURL = process.env.FRONTEND_URL || 'http://localhost:3001';` — line 6 `const baseURL = 'https://sporto.asia';` — lines 10-11 `const userEmail = 'admin1@gmail.com'; const userPassword = '123456';`. playwright.config.ts has no `testIgnore`, and package.json:12 is `\"test:e2e\": \"node --env-file-if-exists=.env.playwright node_modules/@playwright/test/cli.js test\"` with no `--grep`/`--ignore`.",
      "file": "test/e2e/quick-tournament.spec.ts",
      "impact": "`npm run test:e2e` logs into the live production site with a real admin account and creates real tournaments; anyone who runs the documented test command mutates production data.",
      "line": 6,
      "severity": "Critical",
      "title": "Organizer E2E spec hardcodes the production URL and a real admin password, and is not excluded from `test:e2e`"
    },
    {
      "confidence": 0.95,
      "evidence": "Grep of `src/` for `data-testid=\"tab-` returns only BasicInfoTab.tsx:208/221/234/247 (`tab-basic-general|branding|prizes|contact`). The real manage tabs are `data-testid={`manage-tab-${tab.id}`}` (page.tsx:2484) with ids `overview|registration|bracket|court_schedule|sponsors|settings` (page.tsx:2470-2477) — no `permissions`. Spec hits: 106 `tab-basic`, 114 & 125 `save-basic-info-btn`, 116 & 74 `tournament-title`, 129 `tab-schedule`, 138 `tab-registration`, 160/162 `tab-bracket`, 166 `tab-livestream`, 185/187 `tab-permissions`. A repo-wide grep for `tournament-title` and `save-basic-info-btn` in `src/` returns zero matches.",
      "file": "test/e2e/quick-tournament.spec.ts",
      "impact": "Every `getByTestId(...).click()` above auto-waits 45s then fails; the test can never have passed against the current UI, so any reviewer treating this spec as coverage of manage-page editing is reading a false signal.",
      "line": 106,
      "severity": "Critical",
      "title": "Test references nine `data-testid` values that no longer exist in `src/`, so it cannot pass"
    },
    {
      "confidence": 0.98,
      "evidence": "spec line 54: `const startDateInput = page.locator('input[name=\"startDate\"]');`. QuickTournamentCreate.tsx:1033-1034 passes `name=\"startDate\"` to `DateTimePicker`, but Input.tsx:144-147 destructures `name` and renders `<input value={draft} disabled={disabled} placeholder={...} onChange={...} onBlur={...} className=... />` — `name`, `id`, `ref` and `aria-label` are all dropped.",
      "file": "test/e2e/quick-tournament.spec.ts",
      "impact": "`locator.fill()` resolves 0 elements and times out; the same omission makes `activeRef.current.showPicker()` (Input.tsx:74-80) a permanent no-op, so the calendar button next to every date field in the product does nothing and no test detects it.",
      "line": 54,
      "severity": "Critical",
      "title": "`input[name=\"startDate\"]` cannot match: `DateTimePicker` destructures `name` but never forwards it to its `<input>`"
    },
    {
      "confidence": 1,
      "evidence": "Grep of the whole suite for keyboard assertions returns, in the target files, only `page.keyboard.press('Escape')` at organizer-wide-tab-overlay.spec.ts:151, 158, 178 and `page.mouse.click(2, 2)` at :82. Zero `toBeFocused`, zero `press('Tab')`, zero `document.activeElement` in `test/e2e/organizer-*.spec.ts`, `roster-import.spec.ts`, `quick-tournament.spec.ts`. The one Tab-traversal helper (`court-camera-live-controls.spec.ts:616-623`) is in a different spec.",
      "file": "test/e2e/organizer-wide-tab-overlay.spec.ts",
      "impact": "A reviewer cannot conclude anything about Tab reachability, focus order, focus-on-open/close of the operation dialog, or focus return — the four things screen-reader and keyboard users need most from a modal-heavy organizer UI.",
      "line": 151,
      "severity": "Critical",
      "title": "Zero keyboard-reachability or focus-management assertions in the entire organizer suite"
    },
    {
      "confidence": 0.95,
      "evidence": "playwright.config.ts:31-35 declares a single project `chromium` with `...devices['Desktop Chrome']`; `use:` (line 13) sets no `viewport`, `deviceScaleFactor`, `reducedMotion`, `forcedColors` or `colorScheme`. Repo-wide grep for `deviceScaleFactor|forced-colors|contrast|zoom` in `web/test` returns zero hits. Per-spec viewports: organizer-wide-tab-overlay.spec.ts:20,78,117,145,172,186,192,336,374,383 → 1600×900 and :90,:300 → 375×812; organizer-ops-match-scope.spec.ts:165 → 375×812. `organizer-auto-save`, `organizer-registration-visibility`, `organizer-venue-registration-settings`, `roster-import`, `schedule-card-live-variant` never call `setViewportSize` at all. No spec uses `devices['iPhone …']` or touch emulation. [INFERENCE] `devices['Desktop Chrome']` resolves to viewport 1280×720, deviceScaleFactor 1, hasTouch false — `node_modules` is not installed so the descriptor could not be read directly.",
      "file": "playwright.config.ts",
      "impact": "3 of ~30 organizer tests touch mobile, all at 375 CSS px on a non-touch, DSF-1 desktop Chromium. There is no 400% zoom test, no 320px reflow test, no `isMobile`/`hasTouch`, no forced-colors and no contrast check anywhere — WCAG 1.4.10 Reflow and 1.4.11 Non-text Contrast are entirely unverified.",
      "line": 35,
      "severity": "Critical",
      "title": "No zoom, no touch/mobile device profile, no forced-colors, no contrast — and 4 of the 7 target specs never set a viewport at all"
    },
    {
      "confidence": 1,
      "evidence": "Line 212 `const endDateInput = page.locator('input[placeholder*=\"/\"]').nth(1);` (also :231-233 `registrationInputs.nth(0)/.nth(1)` and :257). All four date fields are `DateTimePicker`s (TournamentSettingsTab.tsx:322, 333, 360, 372); each `<input>` (Input.tsx:144-147) carries no `id`/`aria-label`, and each visible `<label>` (TournamentSettingsTab.tsx:319, 330, 357, 369) has no `htmlFor` and does not wrap the control, so the only name source is the shared placeholder `Common.dateTimePlaceholder` = `\"dd/mm/yyyy HH:mm\"` (messages/vi.json:1030, en.json:1030).",
      "file": "test/e2e/organizer-venue-registration-settings.spec.ts",
      "impact": "Three green deadline-editing tests are the textbook case of \"assertion passes while the accessible name is wrong\": a screen reader announces four identical fields named \"dd/mm/yyyy HH:mm\" instead of \"Ngày khai mạc\"/\"Ngày bế mạc\"/registration start/end, and any new date field inserted above them silently retargets `.nth(1)` at the wrong control while the suite stays green.",
      "line": 212,
      "severity": "Important",
      "title": "Positional `input[placeholder*=\"/\"].nth(1)` masks four date fields that have no accessible name at all"
    },
    {
      "confidence": 1,
      "evidence": "Spec lines 189-192 `courts: [ { id: 'court-1', name: 'Sân 1' }, { id: 'court-2', name: 'Sân 2' } ]`. Consumed as `TournamentVenueWithCourts` (features/tournaments/api.ts:704-711) whose `courts: TournamentCourt[]` requires `{ id, venueId, courtName, status }` (api.ts:109-113); features/venues/api.ts:6-13 marks `name` as \"Legacy API alias; new code must prefer courtName\". `fetchTournamentVenues` stores the payload verbatim (useManageState.ts:682-685 `setTournamentVenues(res.data)`), so VenueCourtsModal.tsx:322 renders `{court.courtName}` → empty, and page.tsx:3208-3209 keeps the court (`status !== 'MAINTENANCE'` is true for `undefined`) and renders `<option>{court.courtName}</option>` with a blank label. The test opens exactly that modal at line 202 and asserts only `venueTab.locator('span').last()` font-weight at :205.",
      "file": "test/e2e/organizer-venue-registration-settings.spec.ts",
      "impact": "Missing field the UI reads → `undefined` → silently different rendered state, exactly as asked: the court list in the modal under test is blank and the maintenance filter is defeated, and the suite reports green because it never asserts a court name.",
      "line": 190,
      "severity": "Important",
      "title": "Mock venue courts use the legacy `name` field; the UI reads `courtName`, so court names render blank in the very modal the test opens"
    },
    {
      "confidence": 0.97,
      "evidence": "Header comment lines 1-19: \"used only by `tournament-participants-profile-navigation.spec.ts`\". `resolve()` (163-176) matches only `^\\/api\\/v1\\/tournaments\\/([^/]+)(\\/(.*))?$` and handles `divisions`, `results`, `participants`, ``; everything else falls through to line 193 `send(response, 200, { data: [] })`. The handler at 178-195 never inspects `request.method`, so `POST/PATCH/DELETE /api/v1/tournaments/:id` return 200 with the unchanged tournament and no mutation.",
      "file": "test/e2e/fixtures/tournament-mock-api.mjs",
      "impact": "The fixture a reviewer would assume stubs the organizer backend actually stubs zero organizer endpoints, and would answer every `/manage`, `/venues`, `/bracket`, `/livestream/*` request with a successful empty payload instead of 404 — so it cannot be repurposed as organizer coverage without silently masking missing routes.",
      "line": 171,
      "severity": "Important",
      "title": "`tournament-mock-api.mjs` stubs no organizer endpoint and answers every unmatched path with HTTP 200 `{data: []}`"
    },
    {
      "confidence": 1,
      "evidence": "Spec line 196 `const courtSettingsButton = page.getByRole('button').filter({ hasText: 'Cài đặt sân' });` then :202 `.click()`. The opened component's shell is VenueCourtsModal.tsx:118 `<div className=\"fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 …\">` — no `role=\"dialog\"`, no `aria-modal`, no `aria-labelledby`, no focus trap, no Escape handler (a grep for `role=\"dialog\"|aria-modal|Escape` over the whole `manage/components` dir returns no hit for this file, while `CourtWorkspace.tsx:415-416` and `CourtCameraBoard.tsx:680` do have them). Its close control at VenueCourtsModal.tsx:133-137 is `<button type=\"button\" onClick={onClose}><X className=\"h-4 w-4 text-slate-400\" /></button>` — no `aria-label`, no `sr-only` text, so no accessible name.",
      "file": "test/e2e/organizer-venue-registration-settings.spec.ts",
      "impact": "The `filter({ hasText })` escape hatch is precisely what lets the suite stay green while the dialog it enters is invisible to the accessibility tree, has no Escape path, and has a nameless close button — a WCAG 4.1.2 failure plus a keyboard trap.",
      "line": 196,
      "severity": "Important",
      "title": "`getByRole('button').filter({ hasText })` bypasses role+name matching and opens a modal with no dialog semantics and an unnamed close button"
    },
    {
      "confidence": 1,
      "evidence": "Spec line 143 `await expect(pendingRow.getByTitle(/chờ.*duyệt/i)).toBeVisible();`. The target is RegistrationTab.tsx:946-949: `<span … className=\"…bg-amber-50 text-amber-700…\" title={statusLabel}><Clock className=\"w-4 h-4 stroke-[2]\" /></span>` — no visible text, no `aria-label`, and the lucide `<svg>` has neither `<title>` nor `aria-hidden`.",
      "file": "test/e2e/organizer-registration-visibility.spec.ts",
      "impact": "The test asserts the weakest possible accessible-name fallback (a `title` attribute, not exposed on touch, and the `<span>` is not focusable so no keyboard user can even surface it). Approval state is conveyed by an unlabelled icon + tooltip, and the suite certifies that as correct.",
      "line": 143,
      "severity": "Important",
      "title": "`getByTitle` assertion passes on a status badge that has no visible text and no text alternative"
    },
    {
      "confidence": 1,
      "evidence": "Lines 141-145: `const modeSelect = page.locator('select').filter({ has: page.locator('option[value=\"APPROVAL\"]') }); if (await modeSelect.count() > 0) { await modeSelect.first().selectOption('APPROVAL'); await sleep(); }` — followed unconditionally at :156 by `await page.getByRole('button', { name: /Lưu thông tin đăng ký/i }).click();` with no assertion that the mode actually changed.",
      "file": "test/e2e/quick-tournament.spec.ts",
      "impact": "If the selector is renamed or the control becomes a custom combobox, the step silently does nothing, Save is still clicked, and the test reports the registration-mode configuration as covered when it was never exercised.",
      "line": 142,
      "severity": "Important",
      "title": "Soft-skip guard lets the registration-mode step vanish while the test still passes"
    },
    {
      "confidence": 1,
      "evidence": "`web/.github/workflows/` does not exist; the repo has only `/home/runner/work/agent-orchestrator/agent-orchestrator/.github/workflows/{cleanup-merged.yml, agent-task.yml}`. Grepping both for `playwright|test:e2e|e2e|FRONTEND_URL` yields exactly one hit: agent-task.yml:313, a prose line in an LLM prompt — \"Thư mục 'web/': … test bằng 'pnpm test:e2e' hoặc 'pnpm build'\".",
      "file": ".github/workflows/agent-task.yml",
      "impact": "All of the above — including the production-pointing spec — is invisible to CI. No a11y regression in the organizer UI can fail a build, so nothing here protects the accessibility properties the suite claims to check.",
      "line": 313,
      "severity": "Important",
      "title": "No CI workflow runs the Playwright suite at all"
    },
    {
      "confidence": 0.9,
      "evidence": "organizer-manage.ts:134 `'access-control-allow-methods': 'GET, POST, OPTIONS'` — vs organizer-auto-save.spec.ts:26 `'access-control-allow-methods': 'GET, POST, PATCH, PUT, DELETE, OPTIONS'` and organizer-venue-registration-settings.spec.ts:76 `'GET, POST, PATCH, OPTIONS'`. The API is cross-origin from the page: `getBaseUrl()` (lib/axios.ts:234-236) returns `${protocol}//${hostname}:3000/api/v1` on localhost while playwright.config.ts:14 serves the app on `:3001`.",
      "file": "test/e2e/support/organizer-manage.ts",
      "impact": "Three near-duplicate `fulfillApi` copies with divergent method lists is a live trap: the first organizer spec to add a PATCH/DELETE flow while importing the shared helper will fail on CORS preflight, not on the assertion the author wrote.",
      "line": 134,
      "severity": "Important",
      "title": "Shared `fulfillApi` advertises only `GET, POST, OPTIONS` while the app's API origin is cross-origin"
    },
    {
      "confidence": 1,
      "evidence": "Line 133 `await page.waitForTimeout(200);` then :136-138 `expect(unscopedMatchQueries, …).toHaveLength(0);`; line 182 `await page.waitForTimeout(200);` and :184 `await page.waitForTimeout(100);` back the :189-193 `expect(staleScopeQueries, …).toHaveLength(0);`. playwright.config.ts:7 sets `expect.timeout: 10_000`.",
      "file": "test/e2e/organizer-ops-match-scope.spec.ts",
      "impact": "The two headline anti-stale-scope assertions pass on any runner where the offending request lands after 200 ms — i.e. they are most likely to pass on a slow CI box, which is exactly when the bug they guard would ship.",
      "line": 133,
      "severity": "Important",
      "title": "Fixed 200 ms `waitForTimeout` windows back the \"no stale request was made\" assertions"
    },
    {
      "confidence": 0.9,
      "evidence": "organizer-wide-tab-overlay.spec.ts:104 `overlay.getByRole('button', { name: 'Đóng' })` and :165 the same. Playwright's default role-name matching is case-insensitive substring. `Common.close` = \"Đóng\" (messages/vi.json:1234). Other \"Đóng\"-prefixed names already exist in the same manage tree: CourtScheduleBoard.tsx:4065 `aria-label=\"Đóng bảng chọn thời lượng\"`, :5372 and ScheduleGridView.tsx:932 visible \"Đóng\", :6407 \"Đã hiểu & Đóng\", CourtWorkspace.tsx:357 \"Thu nhỏ / Đóng\".",
      "file": "test/e2e/organizer-wide-tab-overlay.spec.ts",
      "impact": "Today the registration tab happens to mount none of them, but any of those surfaces becoming reachable in the registration tab turns two assertions into Playwright strict-mode \"resolved to N elements\" failures. `{ exact: true }` would remove the coupling at zero cost.",
      "line": 104,
      "severity": "Minor",
      "title": "Non-exact substring `{ name: 'Đóng' }` will break the moment a second \"Đóng…\"-named button mounts in the overlay"
    },
    {
      "confidence": 1,
      "evidence": "Line 152 `await expect(page.getByRole('button', { name: /Trận đấu/ })).toBeVisible();` (repeated at :171). OperationsWorkspace.tsx:174-197 renders the inner ops tab as `<span className=\"truncate\">{tab.label}</span><span …>{tab.count}</span>` with `tab.label = translate('matchesTab')` = \"Trận đấu\" (messages/vi.json:5004) and `count: matches.length`. The outer page tabs are \"Tổng quan / Sơ đồ / Điều hành / Phát trực tiếp\" (vi.json:4977-4980), so only the inner tab matches.",
      "file": "test/e2e/organizer-ops-match-scope.spec.ts",
      "impact": "The assertion passes for an unrelated reason (substring against \"Trận đấu 0\") and would also match any future \"…trận đấu…\" button, so it is not evidence that the control is correctly named or correctly exposed.",
      "line": 152,
      "severity": "Minor",
      "title": "Substring regex `getByRole('button', { name: /Trận đấu/ })` matches an accessible name of \"Trận đấu 0\""
    },
    {
      "confidence": 1,
      "evidence": "Line 82 `await page.mouse.click(2, 2);`. The overlay is `max-w-screen-2xl w-[90vw] h-[96vh]` (ManageWideOverlay.tsx:103), so at 1600×900 its left inset is (1600-1440)/2 = 80 px and top inset is (900-864)/2 = 18 px — (2,2) is outside only by arithmetic, not by any semantic hit-test.",
      "file": "test/e2e/organizer-wide-tab-overlay.spec.ts",
      "impact": "There is no outside-click test at 375×812 and no keyboard equivalent, and the desktop test would start clicking the dialog itself if the overlay's sizing ever changed, silently turning into a no-op assertion.",
      "line": 82,
      "severity": "Minor",
      "title": "Outside-click test uses a raw coordinate and runs only at desktop width"
    },
    {
      "confidence": 1,
      "evidence": "Header comment: \"This is not a running-app check: no page is loaded, so it cannot catch a Tailwind purge or a stylesheet regression.\" Body asserts class strings, e.g. `expect(chrome.surface).toContain('border-rose-500')`, `expect(SCHEDULE_CARD_SELECTION.haloGradient).toContain('motion-reduce:animate-none')`, `expect(SCHEDULE_CARD_SELECTION.label).toBe('Đang chọn')`.",
      "file": "test/e2e/schedule-card-live-variant.spec.ts",
      "impact": "Despite its filename it contributes zero browser-rendered a11y or motion coverage; a reviewer must not read `motion-reduce:animate-none` here as evidence that reduced motion works in the running app (only one real reduced-motion assertion exists anywhere: organizer-wide-tab-overlay.spec.ts:102).",
      "line": 15,
      "severity": "Minor",
      "title": "`schedule-card-live-variant.spec.ts` loads no page and asserts Tailwind class strings, not computed styles"
    },
    {
      "confidence": 1,
      "evidence": "manage/page.tsx:2482-2487: `<button key={tab.id} data-testid={`manage-tab-${tab.id}`} type=\"button\" onClick={…} title={tab.title || tab.label} className={… isActive ? 'border-blue-600 text-blue-600 font-black' : 'border-transparent text-slate-800 …'}>` — no `aria-current`, no `role=\"tab\"`, no `aria-selected`. Same on the ops route: ops/page.tsx:588-604 and OperationsWorkspace.tsx:182-197 encode selection purely as `bg-action-primary-hover text-white`. The overlay tabs do carry it (ManageWideOverlay.tsx:127 `aria-current={isActive ? 'page' : undefined}`) and are the only ones asserted (organizer-wide-tab-overlay.spec.ts:42,55,60,66,72,199,305,352).",
      "file": "src/app/organizer/tournaments/[id]/manage/page.tsx",
      "impact": "Active-section state on both route families is conveyed by colour alone, so a screen-reader user cannot tell which tab is open. The suite asserts `aria-current` only where it already exists, which makes the E2E evidence look better than the product is.",
      "line": 2482,
      "severity": "Minor",
      "title": "Active tab state on the manage and ops tab bars is colour-only, and no spec asserts it"
    },
    {
      "confidence": 1,
      "evidence": "Line 71 `const nameInput = page.getByTestId('manage-tournament-name-input');` is the file's only locator; grep of the file for `getByRole|getByText|getByLabel|page.locator|aria-|keyboard` returns nothing else.",
      "file": "test/e2e/organizer-auto-save.spec.ts",
      "impact": "The autosave path is asserted purely through a testid and request-body inspection; renaming the input's accessible name, removing its label, or making it unreachable by keyboard would not fail this spec.",
      "line": 71,
      "severity": "Minor",
      "title": "`organizer-auto-save.spec.ts` is 100 % `getByTestId`, with no role, name, aria or keyboard assertion"
    },
    {
      "confidence": 1,
      "evidence": "organizer-manage.ts:191 `await fulfillApi(route, { data: [] });` — the terminal fallback of the `page.route('**/api/v1/**')` handler (line 171). organizer-wide-tab-overlay.spec.ts:191-224 depends on this: the camera list route is never stubbed and passes only because `Camera[]` happens to accept an empty array.",
      "file": "test/e2e/support/organizer-manage.ts",
      "impact": "A handler added for an endpoint the UI never calls is indistinguishable from a working one, and an endpoint the UI *does* call under a slightly different path silently resolves to an empty list instead of failing — the wrong-stub direction that hides regressions rather than surfacing them.",
      "line": 191,
      "severity": "Minor",
      "title": "`openManage`'s catch-all `{ data: [] }` makes a wrong route path indistinguishable from a correct one"
    },
    {
      "confidence": 1,
      "evidence": "Lines 148-154: `// await page.getByPlaceholder(/Mỗi dòng là 1 tên VĐV/i)`, `//   .fill('Vận động viên 1\\n…')`, `// await sleep();`, `// Click vào nút \"Sinh VĐV ảo\"`, `// await page.getByRole('button', { name: /Sinh VĐV ảo/i }).click();`. Lines 174-182: the whole Finance block — `// await page.getByTestId('tab-finance').click();` through `//   await page.getByRole('button', { name: /Lưu cài đặt tài chính/i }).click();` — including `entryFeeInput.fill('100000')`. Separately (out of the 7 target files but the same class), test/e2e/p0/p0-unified.spec.ts:79-160 comments out the entire organizer operations flow — organizer login, ops tab, match scheduling, score modal — inside its one P0 test.",
      "file": "test/e2e/quick-tournament.spec.ts",
      "impact": "Mock-participant generation and entry-fee/finance configuration have no coverage at all, and the one P0 spec that would have covered the organizer ops flow has it switched off; a reviewer reading the file list would assume both areas are tested.",
      "line": 148,
      "severity": "Minor",
      "title": "Commented-out blocks hide two untested organizer features"
    },
    {
      "confidence": 0.75,
      "evidence": "Line 471 `await page.getByRole('dialog').locator('table input').first().fill('Updated team name');` — at that point the manage-wide-overlay (ManageWideOverlay.tsx:79-80, `ModalContent` → Radix `DialogPrimitive.Content`) and the roster dialog (RosterImportModal.tsx:412 `ModalContent data-testid=\"roster-import-modal\"`) are both mounted, and `.locator('table input').first()` is positional within the match set.",
      "file": "test/e2e/organizer-wide-tab-overlay.spec.ts",
      "impact": "It works only because Radix `DismissableLayer` currently marks the outer dialog `aria-hidden`; if the roster modal is ever promoted to a sibling portal or the aria-hiding changes, this becomes a strict-mode failure rather than a targeted one. Marking the anchor explicitly (`roster-import-modal` or `getByRole('dialog', { name: … })`) would remove the coupling.",
      "line": 471,
      "severity": "Minor",
      "title": "Nested-dialog locator relies on Radix `aria-hidden` to resolve to exactly one dialog"
    }
  ]
}