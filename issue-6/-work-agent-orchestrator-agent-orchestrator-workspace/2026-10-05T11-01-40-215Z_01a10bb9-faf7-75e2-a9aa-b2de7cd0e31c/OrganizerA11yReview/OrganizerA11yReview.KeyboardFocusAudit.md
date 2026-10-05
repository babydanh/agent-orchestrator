{
  "coverage": "FULLY READ: ManageWideOverlay.tsx (364 L, whole), OperationsWorkspace.tsx (230 L, whole), WildcardManagerCard.tsx (whole), SeedingManagerCard.tsx (whole), ScheduleGridView.tsx (interactive regions 397-463, 460-530, 585-715, 727-763, 786-853), QuickSchedulePanel.tsx (180-275 + interaction map), TournamentStepper.tsx (179-338 + interaction map), TournamentManageSidebar.tsx (99-364), CourtWorkspace.tsx (266-438 + interaction map), TournamentManageSidebar/CourtWorkspace dangling-id verification, plus the shared primitives those depend on: src/components/ui/Modal.tsx (whole), src/components/tournaments/schedule/ScheduleMatchCard.tsx (299-339 + prop interface 49-82), src/app/(public)/tournaments/[id]/components/bracket/MatchCard.tsx (269-343), src/app/(public)/tournaments/[id]/components/BracketTab.tsx (117-208 tray), RoundRobinView.tsx (116-146, 235-313).\n\nREAD VIA TARGETED GREPS + BLOCK READS (not line-by-line): CourtScheduleBoard.tsx (6415 L) — mapped with onClick|onKeyDown|role=|tabIndex|aria-|draggable|onPointerDown|onContextMenu|setSaveToast|autoSaveStatus, then read 586-622, 834-1010, 1883-1899, 3900-4003, 4130-4199, 4348-4375, 4663-4703, 4859-4938, 5084-5128, 5265-5303, 5819-5903. RegistrationTab.tsx (1473 L) — read 794-903 and 1179-1273, mapped the rest. BracketTab.tsx (1009 L) — read 299-423, 507-563, 840-1009, mapped the rest. RegistrationFormBuilder.tsx (748 L) — read 459-515, mapped the rest. Manage page (3803 L) — read 590-693, 2454-2523, 2705-2745, mapped the rest.\n\nMOUNT STATUS VERIFIED (repo-wide greps for each JSX tag): live = CourtScheduleBoard (via CourtWorkspace.tsx:373), CourtWorkspace (page.tsx:1946, 2710), ManageWideOverlay (page.tsx:2808), OperationsWorkspace (ops/page.tsx:694), RegistrationTab (page.tsx:1792), RegistrationFormBuilder (page.tsx:1246), BracketTab (page.tsx:1847, ops/page.tsx:613), TournamentStepper (page.tsx:2309), ScheduleTab (page.tsx:2660). NOT MOUNTED / dead code = ScheduleGridView (imported BracketTab.tsx:21, zero JSX uses), SeedingManagerCard, WildcardManagerCard, QuickSchedulePanel, TournamentManageSidebar (only its `ManageSection` type is imported, page.tsx:49). Dead-code findings are ranked Minor and labelled as latent.\n\nDEPENDENCY VERIFICATION: dnd-kit attributes shape read from node_modules/@dnd-kit/core/dist/core.cjs.development.js:3400-3443 (role defaults to 'button', tabIndex 0, aria-roledescription 'draggable', aria-describedby, aria-pressed); react-hot-toast ariaProps defaults read from node_modules/react-hot-toast/dist/index.d.ts:25-28; Modal confirmed to wrap @radix-ui/react-dialog at src/components/ui/Modal.tsx:4,10,49; eslint.config.mjs read in full (eslint-config-next core-web-vitals + typescript only, no jsx-a11y plugin configured).\n\nNOT COVERED (out of assignment scope, so unassessed): BracketSetupModal.tsx, the roster-import/ subfolder, BasicInfoTab/ConfigTab/LivestreamTab/PermissionsTab/FinanceTab/RefereesTab, the ops/ components other than OperationsWorkspace, the public (non-organizer) bracket/schedule surfaces beyond the drag handlers they share with the organizer, and the playwright specs in test/e2e/. No test, build, lint or formatter was executed (read-only audit).",
  "findings": [
    {
      "confidence": 0.95,
      "evidence": "BracketTab.tsx:337 `const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 4 } }));` and :918-921 `<DndContext sensors={sensors} onDragStart={handleBracketDragStart} onDragEnd={handleBracketDragEnd}`. A repo-wide grep for `KeyboardSensor` in web/src returns 0 hits, and a grep for `accessibility|screenReaderInstructions|announcements` in manage/components returns 0 hits. The drag handles are announced as buttons: public BracketTab.tsx:144-156 `<button ref={setNodeRef} type=\"button\" {...attributes} {...listeners} disabled={!enabled} ... aria-label={translate('bracketDragParticipant')}>`; bracket/MatchCard.tsx:282-288 `<div ref={...} {...(dragEnabled ? attributes : {})} {...(dragEnabled ? listeners : {})} ...>`. Neither has an onClick. dnd-kit's attributes are `{role:'button', tabIndex:0, 'aria-disabled', 'aria-pressed', 'aria-roledescription:'draggable', 'aria-describedby'}` (node_modules/@dnd-kit/core/dist/core.cjs.development.js:3425-3437). The only mutation path is `onParticipantDrop` (BracketTab.tsx:501-506, :370), and `handleBracketSetupAction` (:527-541) opens the pool modal only for ROUND_ROBIN/GROUP_STAGE_KNOCKOUT, otherwise calling handleGenerateBracket().",
      "file": "src/app/organizer/tournaments/[id]/manage/components/BracketTab.tsx",
      "impact": "A keyboard/screen-reader user can focus a control announced as \"button, draggable\" and pressing Enter/Space does nothing; re-seeding or re-pairing a knockout bracket is impossible without a mouse.",
      "line": 337,
      "severity": "Critical",
      "title": "Organizer bracket slot assignment is 100% mouse-only: PointerSensor only, and the draggables are focusable role=\"button\" elements with no click handler"
    },
    {
      "confidence": 0.95,
      "evidence": "The only tabbable node in the grid is the scroll container, :4682-4685 `role=\"region\" aria-label={t('matchSchedule.court')} tabIndex={0}`. Cells, :4884-4912: `<div key={`${court.id}-${row.index}`} className=\"... cursor-cell ...\" onPointerDown={...} onDoubleClick={() => { ...openAssignmentPicker(court.id, targetTime, row.index); }} onClick={() => { if (!isSelecting && !selectionRange) { ...openAssignmentPicker(...) } }} onContextMenu={...}>` — no role, no tabIndex, no onKeyDown. Match cards, :3950-3978 `<ScheduleMatchCard draggable onClick={...} onDoubleClick={...} onContextMenu={...} />`; ScheduleMatchCard.tsx:72-81 does accept `role`, `tabIndex`, `aria-label`, `onKeyDown` (spread onto the root div at :317-328) but renderMatchCard passes none. Corner select-all header, :4694-4709 bare `<div onClick={() => { setSelectionRange({...}) }}>`. Court header, :4780-4784 `<div role=\"presentation\" onPointerDown={...}>`. No Arrow-key handling exists anywhere in the file: the only key handling is Escape (:1274-1284, :2155-2159) and Ctrl+Z/Y/X/C/V/S/A plus Delete/Backspace (:2086-2134).",
      "file": "src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "`openAssignmentPicker` is reachable only by mouse click/double-click on a cell, so a keyboard user cannot open the assign-match dialog, build a selection range, select a match, or reach the context menu — scheduling is effectively impossible without a pointer.",
      "line": 4886,
      "severity": "Critical",
      "title": "CourtScheduleBoard timeline grid is entirely keyboard-unreachable — cells, match cards and headers are divs with pointer handlers and no role/tabIndex/keydown, and there is no arrow-key navigation at all"
    },
    {
      "confidence": 0.97,
      "evidence": ":117-120 `<div data-testid=\"manage-wide-operation-tabs\" className=\"grid shrink-0 grid-cols-4 ...\">` — no role=\"tablist\". :128-132 `<button type=\"button\" data-testid={`manage-wide-tab-${id}`} aria-current={isActive ? 'page' : undefined} ref={isActive ? activeTabRef : undefined} onClick={() => onSectionChange(id)}` — no role=\"tab\", no aria-selected, no id/aria-controls. :168-171 `<div data-testid=\"manage-wide-content\" className=\"min-h-0 overflow-y-auto bg-card p-3 sm:p-4 md:p-6\"><div key={section} className=\"min-h-full animate-in ...\">` — no role=\"tabpanel\", no aria-live, no aria-labelledby. The only focus handling is scrollIntoView on the active tab (:64-70).",
      "file": "src/app/organizer/tournaments/[id]/manage/components/ManageWideOverlay.tsx",
      "impact": "A screen-reader user gets no selected-state for registration / bracket / court-schedule / livestream and no announcement when the panel content is replaced.",
      "line": 117,
      "severity": "Important",
      "title": "The four operation tabs are not a tab widget and switching sections is silent for AT"
    },
    {
      "confidence": 0.95,
      "evidence": ":2473 `<div className=\"flex overflow-x-auto gap-1 sm:gap-2 no-scrollbar\">` with :2482-2489 `<button key={tab.id} data-testid={`manage-tab-${tab.id}`} type=\"button\" onClick={() => handleManageNavigation(tab.id)} title={tab.title || tab.label} className=\"... border-b-2 ...\">` — no role=\"tablist\", no role=\"tab\", no aria-selected (only a border/colour difference). :2510 `<div id=\"manage-content-area\" className=\"bg-white rounded-2xl border border-slate-200/80 shadow-xs p-3.5 sm:p-6 md:p-7 ...\">` — no role=\"tabpanel\", no aria-live, no aria-labelledby. `handleManageNavigation` (:640-651) only calls setActiveSection + history.replaceState, no focus move. The settings tab is `label: ''` with `title: 'Cài đặt giải đấu'` (:2476).",
      "file": "src/app/organizer/tournaments/[id]/manage/page.tsx",
      "impact": "No announcement of section change and no selected-state exposure; the settings tab's accessible name comes only from `title`.",
      "line": 2482,
      "severity": "Important",
      "title": "Main horizontal section tab bar has no tab semantics and its content region is not a live region"
    },
    {
      "confidence": 0.95,
      "evidence": ":173-200 `<div className=\"grid grid-cols-3 gap-2\">` containing plain `<button type=\"button\" onClick={() => setActiveTab(tab.id)} className={cn('flex min-w-0 items-center justify-center gap-2 ...', isActive ? 'bg-action-primary-hover text-white shadow-sm' : ...)}>` — no role=\"tablist\", no role=\"tab\", no aria-selected, no aria-controls, no roving tabindex. Panels at :202/:219/:227 are bare conditional fragments (`{activeTab === 'MATCHES' ? <OpsMatches .../> : null}`) with no role=\"tabpanel\" and no aria-live; focus stays on the clicked button.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/OperationsWorkspace.tsx",
      "impact": "A screen-reader user cannot tell which of MATCHES / PARTICIPANTS / ACTIVITY is active (only a background colour differs) and gets no confirmation when the panel changes.",
      "line": 182,
      "severity": "Important",
      "title": "OperationsWorkspace's three tabs are plain buttons with no tablist/tab/aria-selected/tabpanel and no focus move"
    },
    {
      "confidence": 0.95,
      "evidence": "Five sibling rows: :188-198 (`onChecklistNavigate?.({ tab: 'basic', basicSubTab: 'general', elementId: 'manage-basic-description-input' })`), :217-227, :246-256, :275-285, :304-314. Each is `<div onClick={() => { if (!hasX) { onChecklistNavigate?.({...}); } }} className={`flex items-center justify-between text-xs font-bold p-2 rounded-lg border transition-all ${... 'bg-white/95 border-rose-200 hover:bg-rose-50/80 hover:border-rose-300 cursor-pointer shadow-2xs group/checkitem' ...}`}>` — no role, no tabIndex, no onKeyDown, but styled as a clickable card with hover states. Rendered whenever the tournament is a draft (:154) and mounted at page.tsx:2309.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/TournamentStepper.tsx",
      "impact": "The pre-publish checklist — the primary way to jump to a missing description/division/venue/date/contact field — cannot be operated with a keyboard.",
      "line": 188,
      "severity": "Important",
      "title": "TournamentStepper's five publish-checklist rows are mouse-only divs with onClick and no role/tabIndex/onKeyDown"
    },
    {
      "confidence": 0.93,
      "evidence": ":833-841 `<span className=\"inline-flex items-center justify-center min-w-[28px] h-[22px] rounded-full border border-blue-300 bg-blue-50 text-blue-700 text-xs font-bold cursor-pointer hover:bg-blue-100 transition-colors px-2\" title={registrationTranslate('clickToEditSeed')} onClick={(e) => { e.stopPropagation(); handleSeedEditStart(participant.id, participant.seed); }}>#{participant.seed}</span>` — a span with onClick, no role, no tabIndex, no onKeyDown. `handleSeedEditStart` has exactly two call sites (:838 here and :1253); the other one at :1252-1255 is inside the participant drawer gated by `{selectedParticipant.seed == null && canSeedMock && (` at :1247.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/RegistrationTab.tsx",
      "impact": "Once a participant already has a seed number, changing it requires a mouse click on the `#N` pill; the keyboard-reachable \"Assign seed\" drawer button only appears when seed is null.",
      "line": 833,
      "severity": "Important",
      "title": "Editing an existing participant seed is impossible with a keyboard — the entry point is a mouse-only span and the only button alternative is gated to unseeded participants"
    },
    {
      "confidence": 0.92,
      "evidence": ":5096-5105 `<div key={item.match.id} onClick={() => togglePickerMatchSelection(item.match.id)} className={`flex flex-col justify-between rounded-lg border p-3 text-left transition-all cursor-pointer ${isSelected ? 'border-blue-500 bg-blue-50/70 ring-1 ring-blue-400 shadow-xs' : 'border-slate-200 bg-white hover:border-slate-300 hover:bg-slate-50/50'}`}>` — no role, no tabIndex, no onKeyDown. The selected state is drawn with decorative lucide icons only (:5110-5114 `<CheckSquare className=\"h-4 w-4 text-blue-600 shrink-0\" />` / `<Square className=\"h-4 w-4 text-slate-400 shrink-0\" />`) — no real `<input type=\"checkbox\">` anywhere in this list. The \"select all\" control is a real Button (:5069-5070) but the assign button is `disabled={isSavingDraft || selectedPickerMatchIds.length === 0}` (:5174). The queue panel sibling at :5273-5279 has the identical div-onClick pattern (but does contain a real checkbox at :5287).",
      "file": "src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "Bulk \"assign N matches to this cell\" cannot be performed without a mouse; only the select-all button is reachable, and there is no way to deselect individuals.",
      "line": 5096,
      "severity": "Important",
      "title": "Assignment-picker match rows are keyboard-dead multi-select toggles (div onClick, decorative checkbox icons)"
    },
    {
      "confidence": 0.9,
      "evidence": "Opened only from onContextMenu: :3980 (match card), :4760 (court header), :4931 (grid cell) — there is no ContextMenu-key or Shift+F10 handling; the only key handling in the file is Escape (:1274-1284, :2155-2159) and Ctrl-combos + Delete/Backspace (:2086-2134). Root element :5844-5845 `<div className=\"fixed z-50 w-[270px] rounded-2xl bg-white/98 ...\">` with no role=\"menu\"; items are plain `<button type=\"button\">` (e.g. :5888-5909) with no role=\"menuitem\". The only `role` values in the whole 6415-line file are `presentation` (:4135, :4781), `region` (:4683) and `alert` (:4196). No arrow-key roving, no focus move into the menu, no focus return on close.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "A keyboard user can never open this menu, so per-match score edit (:5964-5975), move-to-court (:6049-6059), unassign (:6067-6077), duration change and cut/copy on a range are keyboard-unavailable.",
      "line": 5844,
      "severity": "Important",
      "title": "Schedule context menu has no menu semantics, no focus management, and no keyboard trigger (right-click only)"
    },
    {
      "confidence": 0.95,
      "evidence": "The debounced auto-save at :1887-1894 calls `void handleSaveAllDrafts(true)` (silent = true). `silent` suppresses every announcement path: :1650-1654 `if (!silent) { setSaveToast('Lịch thi đấu đã ở trạng thái mới nhất!'); ... }`, :1862 `else if (!silent) {`, :1875 `if (!silent) {`. The visible status indicator is a plain div with no live semantics, :4351-4367 `<div className=\"flex items-center gap-1.5 px-2 py-0.5 rounded-md bg-white border border-slate-200 text-xs font-semibold select-none shadow-2xs\">` rendering 'Đang lưu...' / 'Đang xếp...' / 'Tự lưu: Bật'. The file's only live region is the toast at :4196 `role=\"alert\" aria-live=\"assertive\"`, which the silent path never triggers.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "A screen-reader user rearranges the schedule, the 3.5s debounce persists it, and nothing is ever announced — no confirmation that changes were saved and no feedback on failures from the automatic path.",
      "line": 4351,
      "severity": "Important",
      "title": "Silent auto-save gives a screen reader no feedback at all — the status badge has no role=status/aria-live and the toast is deliberately suppressed"
    },
    {
      "confidence": 0.96,
      "evidence": ":395-396 `<section aria-labelledby=\"court-workspace-title\" className={forceExpanded ? 'w-full h-full min-h-0 flex flex-col' : 'w-full'}>`. A repo-wide grep for `court-workspace-title` in web/src returns exactly one hit: the reference at CourtWorkspace.tsx:396 itself. No element with that id exists anywhere.",
      "file": "src/app/organizer/tournestrator/tournaments/[id]/manage/components/CourtWorkspace.tsx",
      "impact": "The workspace region landmark is announced with no name, so a screen-reader user cannot tell which region they are in when navigating by landmark.",
      "line": 396,
      "severity": "Important",
      "title": "CourtWorkspace section has a dangling aria-labelledby — no element with id \"court-workspace-title\" exists anywhere in the repo"
    },
    {
      "confidence": 0.85,
      "evidence": ":412-417 `{!forceExpanded && isFullscreen && (<div className=\"fixed inset-0 z-50 flex flex-col overflow-hidden bg-slate-100 ...\" role=\"dialog\" aria-modal=\"true\" aria-labelledby=\"fullscreen-workspace-title\">`. It is reachable: page.tsx:2710-2736 mounts `<CourtWorkspace tournamentStatus={...} ... onRefetchData={s.refetchDivisionData} />` with no `forceExpanded` prop (the other mount at page.tsx:1946-1974 passes `forceExpanded` at :1974), inside the page's own `<div className=\"fixed inset-0 z-[70] ...\" role=\"dialog\" aria-modal=\"true\" aria-labelledby=\"fullscreen-workspace-title\">` (page.tsx:2697). The inner dialog's aria-labelledby resolves to the *outer* dialog's heading, page.tsx:2701 `<h2 id=\"fullscreen-workspace-title\" className=\"truncate text-base font-bold ...\">`. Neither dialog has a focus trap, initial focus or focus return (the page's Escape handler at :594-606 only toggles state).",
      "file": "src/app/organizer/tournaments/[id]/manage/components/CourtWorkspace.tsx",
      "impact": "Entering workspace fullscreen stacks two aria-modal dialogs with the same accessible name, and keyboard focus is not contained in either.",
      "line": 415,
      "severity": "Important",
      "title": "CourtWorkspace renders a second, nested aria-modal=\"true\" dialog that borrows the outer dialog's label and has no focus trap"
    },
    {
      "confidence": 0.9,
      "evidence": ":602-618 `<div key={slot.label} onDragOver={handleCellDragOver} onDrop={...} onClick={() => { setActiveCellModal({ courtId, courtName, timeSlot: slot.isoString, timeLabel: slot.label }); }} className={`group relative border-b transition-colors hover:bg-blue-50/50 cursor-pointer ...`}>`; :640-651 `<div key={m.id} draggable onDragStart={...} onClick={(e) => { e.stopPropagation(); setSelectedMatchId(m.id); }} onDoubleClick={...} className=\"absolute ... cursor-grab active:cursor-grabbing ...\">`; :800-816 `<div key={m.id} onClick={() => { if (isMultiAssignMode) { setSelectedMatchIds(...) } else { setSelectedMatchIds([m.id]); } }} className=\"... cursor-pointer ...\">` with decorative `<CheckSquare>`/`<Square>` icons at :819-825. Focus rings removed with no replacement: :739 `className=\"bg-transparent outline-none w-full text-xs font-semibold text-slate-800\"` (wrapper at :733 has no focus-within: style), plus :420, :444, :749.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/ScheduleGridView.tsx",
      "impact": "Latent only: if this view is re-enabled, grid cells, match cards and multi-select rows become mouse-only and several form controls lose all focus indication.",
      "line": 602,
      "severity": "Minor",
      "title": "ScheduleGridView: whole grid + multi-select rows are keyboard-dead and three form controls have outline-none with no replacement — component is dead code (imported, never rendered)"
    },
    {
      "confidence": 0.9,
      "evidence": "No `<SeedingManagerCard` JSX exists anywhere in web/src. The component renders its grip at :60-69 `<button type=\"button\" {...attributes} {...listeners} className=\"cursor-grab active:cursor-grabbing rounded p-1 text-slate-400 ... touch-none\" title={dragTitle}><GripVertical className=\"w-4 h-4\" /></button>` (no onClick) and registers only `:102-107 useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 5 } }))` around `:199-228 <DndContext sensors={sensors} ...><SortableContext items={seeded.map((p) => p.id)} ...>`.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/SeedingManagerCard.tsx",
      "impact": "Latent only; note that the underlying capability does have a keyboard path elsewhere (RegistrationTab.tsx:850-862 renders a numeric seed input with autoFocus, Enter to save, Escape to cancel).",
      "line": 60,
      "severity": "Minor",
      "title": "SeedingManagerCard: sortable seed list is mouse-only (PointerSensor only, focusable grip button that does nothing) — component is dead code (never rendered)"
    },
    {
      "confidence": 0.9,
      "evidence": ":191-194 `<div className=\"grid grid-cols-2 border border-slate-200 bg-white p-1\" role=\"tablist\" aria-label={t('matchSchedule.title')}>` with `<button type=\"button\" role=\"tab\" aria-label={t('basicMode')} aria-selected={mode === 'basic'} onClick={() => setMode('basic')} ...>` and the advanced counterpart — but no `id` on either tab and no `aria-controls`. The advanced panel at :250 is a bare `<div className=\"space-y-4 border-l-2 border-blue-600 bg-white p-4\">`; the basic panel is the `<form className=\"space-y-4\" onSubmit={handleSubmit}>` at :212 — neither has role=\"tabpanel\". No arrow-key handling, no focus move on switch. Its `aria-live=\"polite\"` preview region at :271 is correct.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/QuickSchedulePanel.tsx",
      "impact": "Latent only: an incomplete tab pattern (roles without id/aria-controls linkage and panels without role=tabpanel) would be exposed if this panel is mounted.",
      "line": 191,
      "severity": "Minor",
      "title": "QuickSchedulePanel: tablist has role/aria-selected but no id/aria-controls linkage and neither panel has role=\"tabpanel\" — component is dead code (never rendered)"
    },
    {
      "confidence": 0.9,
      "evidence": "No `<TournamentManageSidebar` JSX exists; the only external reference is `import { type ManageSection } from './components/TournamentManageSidebar';` (page.tsx:49). Its nav chevron is a correct pattern, :139-143 `<span role=\"button\" tabIndex={0} onClick={handleChevronClick} onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.stopPropagation(); onToggleExpand(); } }} ...>`. The mobile drawer at :333-346 is `<aside aria-label={t('sidebar.manageMenu')} className={cn('z-50 flex-col gap-3 ...', isOpen ? 'fixed inset-y-0 left-0 flex w-[min(88vw,300px)] overflow-y-auto bg-white p-3 shadow-2xl' : 'hidden')}>` with no role=\"dialog\", no aria-modal, no focus trap and no Escape handler.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/TournamentManageSidebar.tsx",
      "impact": "Latent only; if mounted, a keyboard user could tab out of the open mobile drawer into the page behind it and could not dismiss it with Escape.",
      "line": 333,
      "severity": "Minor",
      "title": "TournamentManageSidebar is never mounted; its mobile drawer has no dialog semantics or focus containment (the chevron pattern itself is correct)"
    },
    {
      "confidence": 0.9,
      "evidence": ":814-826 `<tr key={participant.id} tabIndex={0} className=\"cursor-pointer transition-colors hover:bg-slate-50 focus:bg-blue-50/40 focus:outline-none\" onClick={...} onKeyDown={(event) => { if ((event.key === 'Enter' || event.key === ' ') && event.target === event.currentTarget) { event.preventDefault(); setSelectedParticipant(participant); } }}>`. The `<tr>` carries no role, and the focus indicator is only bg-blue-50/40 (≈12% blue tint) replacing the native outline. Enter and Space are both handled correctly here.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/RegistrationTab.tsx",
      "impact": "The focus indicator is a low-contrast background tint rather than a visible ring, and AT announces a focusable table row with no indication that Enter/Space opens the participant.",
      "line": 816,
      "severity": "Minor",
      "title": "RegistrationTab participant row: focus indicator is a background tint only (focus:outline-none with no ring) and the focusable <tr> has no role"
    },
    {
      "confidence": 0.93,
      "evidence": ":476-481 `<button type=\"button\" onClick={() => removeOptionFromField(field.id, optIdx)} className=\"p-1 text-slate-400 hover:text-rose-500\"><X className=\"h-3.5 w-3.5\" /></button>` — no aria-label, no title, and the X icon is not aria-hidden. Every other icon-only button in the same component is labelled: :337 `aria-label={registrationFormTranslate('moveUp')}`, :346, :354, :362, :370.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/RegistrationFormBuilder.tsx",
      "impact": "Screen-reader users hear an unnamed button per choice option and cannot tell which option it removes.",
      "line": 476,
      "severity": "Minor",
      "title": "RegistrationFormBuilder: remove-option button has no accessible name (icon-only, no aria-label, icon not aria-hidden)"
    },
    {
      "confidence": 0.88,
      "evidence": ":5287-5291 `<input type=\"checkbox\" checked={isSelected} onChange={() => {}} className=\"h-3.5 w-3.5 rounded border-slate-300 text-blue-600 focus:ring-blue-500\" />` sits inside the row div at :5273-5279 whose onClick toggles the selection; the adjacent `<span>` at :5292-5294 holds the match name but is not programmatically associated (no aria-label, no wrapping label, no id/htmlFor). Keyboard activation does work here because the native Space-generated click bubbles to the row's onClick.",
      "file": "src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "Screen-reader users hear an unlabelled checkbox in the queue panel and cannot tell which match it selects.",
      "line": 5287,
      "severity": "Minor",
      "title": "Queue multi-select checkbox has no accessible name (the adjacent name span is not associated)"
    }
  ],
  "clean": [
    "Positive tabIndex: NONE. A grep for `tabIndex={[1-9]` across src/app/organizer returns 0 hits. The only tabIndex values in the target set are tabIndex={0} (CourtScheduleBoard.tsx:4685 scroll region, RegistrationTab.tsx:815 participant row, TournamentManageSidebar.tsx:141 nav chevron) and tabIndex={-1} (PairingParticipantsModal.tsx:219 dialog).",
    "Roving-tabindex grids: NEITHER scheduling grid implements one. CourtScheduleBoard.tsx and ScheduleGridView.tsx have no per-cell tabIndex, no aria-activedescendant and no arrow-key handling at all (grep for ArrowUp|ArrowDown|ArrowLeft|ArrowRight|Home|End across manage/components returns only lucide icon import names and unrelated text). So neither grid is a keyboard trap/dead end in the roving-tabindex sense — they are worse: nothing inside them is reachable (see Critical findings F1/F2).",
    "Enter-vs-Space (category 2): CLEAN. Every onKeyDown acting as a button/toggle checks BOTH Enter and ' ' — TournamentManageSidebar.tsx:143 `if (e.key === 'Enter' || e.key === ' ')`, RegistrationTab.tsx:823 `if ((event.key === 'Enter' || event.key === ' ') && event.target === event.currentTarget)`. The Enter-only handlers are all on <input> text fields where Enter-only is correct: RegistrationFormBuilder.tsx:490-494 (add choice option), RegistrationTab.tsx:857-860 (seed input, Enter save / Escape cancel). PairingParticipantsModal.tsx:220 is a dialog-level Enter/Escape handler. No Enter-only or Space-only button-like handler exists in the target set.",
    "Dropdowns/selects (category 7): CLEAN. Every select in the target set is a NATIVE <select> or <input type=\"date\"> — SeedingManagerCard.tsx:161-171, CourtWorkspace.tsx:286-296/304-314/318-329, ScheduleGridView.tsx:416/441/746, RegistrationTab.tsx:1368, QuickSchedulePanel.tsx:216/252/259, BasicInfoTab.tsx:294/611, ConfigTab.tsx:143/164/199, CourtCameraBoard.tsx:249. There is no Radix Select and no hand-rolled listbox anywhere in the target set, so no missing role=\"listbox\"/\"option\"/aria-expanded/aria-activedescendant cases exist. The custom toggles that ARE present are correctly exposed: role=\"switch\" + aria-checked (RegistrationSettingsCard.tsx:90-94, SponsorSettingsPanel.tsx:360-363, TournamentSettingsTab.tsx:179-183 and 262-266), aria-pressed on toggle buttons (DivisionIdentitySection.tsx:66/86, QuickSchedulePanel.tsx:233, CourtWorkspace.tsx:439), aria-expanded + aria-controls on disclosures (TournamentQuickManagePanel.tsx:117-120, CourtScheduleBoard.tsx:5889-5890, FootballRegistrationGroups.tsx:134-135).",
    "overflow:hidden focus traps (category 8): CLEAN. The only overflow-hidden usages in the target files are decorative chrome (ScheduleMatchCard.tsx:321/335 content wrapper, ManageWideOverlay.tsx:83 dialog shell, CourtWorkspace.tsx:414). Body scroll-lock plus Escape is handled in page.tsx:594-606. Every real dialog goes through the shared Modal, which wraps @radix-ui/react-dialog (src/components/ui/Modal.tsx:4 `import * as DialogPrimitive from \"@radix-ui/react-dialog\"`, :10 `const Modal = DialogPrimitive.Root`, :49 `<DialogPrimitive.Content`), so focus trap, aria-modal, Escape close and focus return are inherited from Radix — including ManageWideOverlay and the ScheduleGridView/CourtWorkspace/CourtScheduleBoard modals.",
    "aria-live / status announcements (category 5): CLEAN except the single silent-auto-save gap reported as F10. Present and correct: CourtScheduleBoard.tsx:4196 `role=\"alert\" aria-live=\"assertive\"` on the save/undo/redo/clipboard toast (used for nearly every mutation); RegistrationTab.tsx:725-726 and 770-771 `role=\"status\" aria-live=\"polite\"` loading, 731-732 and 776 `role=\"alert\"` error + retry button; QuickSchedulePanel.tsx:271 `aria-live=\"polite\"` preview block; PairingParticipantsModal.tsx:242 `role=\"status\"`, :261 `role=\"status\"`, :323 `aria-live=\"polite\"`; TournamentSettingsTab.tsx:301 and 342 `role=\"status\"` hints; page.tsx:685 `aria-busy=\"true\" aria-live=\"polite\"` on the initial skeleton; ScheduleTab.tsx:373 uses react-hot-toast, whose default ariaProps are `role: 'status'` / `aria-live: 'polite'` (node_modules/react-hot-toast/dist/index.d.ts:25-28).",
    "dnd-kit keyboard configuration (category 6): confirmed absent repo-wide — grep for `KeyboardSensor` in web/src returns 0 hits, and grep for `accessibility|screenReaderInstructions|announcements` in manage/components returns 0 hits. All four DndContexts in the organizer tree (BracketTab.tsx:918, SeedingManagerCard.tsx:199, CourtCameraBoard.tsx:731, and the public lite page) register PointerSensor only. Reported as F1 (live) and M3 (dead code).",
    "Structural/landmark labelling that IS done correctly: sections use aria-labelledby with a real heading id (CourtSetup.tsx:73, ScheduleTab.tsx:155/176, CourtWorkspace.tsx:396 is the one exception, BasicInfoTab/SponsorSettingsPanel equivalent), page.tsx:2510 aside-free layout aside, ManageWideOverlay.tsx:110-113 uses an sr-only ModalHeader + ModalTitle/ModalDescription so the Radix dialog gets an accessible name.",
    "eslint-config.mjs (eslint.config.mjs, read in full): only `eslint-config-next/core-web-vitals` + `eslint-config-next/typescript`; there is no eslint-plugin-jsx-a11y configured, which is why none of the div-onClick patterns above are caught statically."
  ]
}