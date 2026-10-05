{
  "clean": [
    "`src/components/ui/Modal.tsx` is a faithful Radix Dialog re-export: `Modal = DialogPrimitive.Root` (10), `ModalContent` renders `DialogPrimitive.Content` inside `DialogPrimitive.Portal` (41-64). It therefore supplies `role=\"dialog\"`, `aria-modal=\"true\"`, focus trap (FocusScope), Escape-to-close, scroll lock (`react-remove-scroll`) and focus return to the trigger for every consumer. Its built-in dismiss button carries a name: `<X className=\"h-4 w-4\" />` plus `<span className=\"sr-only\">{translate(\"close\")}</span>` (62-64), and `Common.close` exists in both `messages/en.json:1234` and `messages/vi.json:1234`. The `aria-describedby` line at 47 is a no-op but harmless (it can only be overridden by a caller who passes the key explicitly, and none does).",
    "Every Radix-based organizer dialog was checked for an accessible name and all of them have one: manage/page.tsx round modal (2860-2862), lock modal (2986-2988), delete-division (3090-3092), match-schedule (3173-3176), dates (3390-3393), fee (3466-3469); CreateDivisionModal.tsx (157-160); BracketSetupModal.tsx (399-409); MockDataModal.tsx (50-56); PairingParticipantsModal.tsx (198-201); PermissionsTab.tsx (444-447); RegistrationFormBuilder.tsx (263-267); RegistrationTab.tsx (1070-1073, 1342-1346); ScheduleGridView.tsx (714-719, 880-883); TournamentStepper.tsx (466-468); RosterImportModal.tsx (397-415); LivestreamTab.tsx (459-462, the only one using a real `ModalTrigger`); CourtWorkspace court picker (426-430); CourtScheduleBoard.tsx (4994-5005, 5189-5199, 5389-5397, 5565-5573, 6362-6370); ops/page.tsx (723-729); OpsMatches.tsx (755-758, 807-818, 838-841); OpsParticipants.tsx (273-276).",
    "`ManageWideOverlay.tsx` — the wide manage tab shell — is the best-in-class overlay: Radix-backed, `closeButtonClassName` sized to 44px only for this dialog, `onEscapeKeyDown` that consumes the first Escape to leave full screen and lets the second close the dialog (89-94), and a deliberately screen-reader-only header so the dialog still has a name: `<ModalHeader className=\"sr-only\"><ModalTitle>{title}</ModalTitle><ModalDescription>{description}</ModalDescription></ModalHeader>` (110-113). Tab icons are `aria-hidden=\"true\"` beside visible `<span>` labels (141-149), and the active tab is scrolled into view via a ref callback on open (66-73).",
    "`src/components/ui/ConfirmModal.tsx` — Radix-backed, has `ModalTitle` + `ModalDescription`, wraps its actions in a `<form onSubmit>` so Enter submits (48-50), and is used by `RegistrationTab.tsx:9` in the organizer.",
    "`src/components/ui/DropdownMenu.tsx` (Radix DropdownMenu), `Select.tsx` (Radix Select) and `Avatar.tsx` (Radix Avatar) are primitives, not overlays — they inherit full keyboard/AT behaviour from Radix.",
    "`src/components/ui/Toaster.tsx` — the toast surface is `react-hot-toast`, which renders `role=\"status\"`/aria-live regions, and the per-toast dismiss button is named: `aria-label={translate(\"close\")}` (26).",
    "`src/components/ui/Textarea.tsx` takes no `label` prop at all, so it cannot produce a broken implicit association — labelling is entirely the caller's job (the callers that get it wrong are reported separately).",
    "`src/components/ui/Input.tsx` lines 152-166 and 321-334 — the `DateTimePicker` / `DatePicker` trigger buttons are correctly named with `aria-label={translate('openDateTimePicker')}` / `aria-label={translate('openDatePicker')}` and are real `<button type=\"button\">` elements.",
    "`src/components/ui/Button.tsx` extends `React.ButtonHTMLAttributes<HTMLButtonElement>` and renders a real `<button>` with Radix `Slot` for `asChild` — no div-button and no missing-type problems.",
    "`src/app/organizer/payouts/page.tsx` — the withdrawal form is an inline card (`<div className=\"bg-white border border-slate-200 rounded-lg p-6 md:p-8 …\">` at 181), not an overlay, so it is outside this audit's overlay scope and has no dialog obligations.",
    "`src/app/organizer/series/create/page.tsx`, `organizer/page.tsx`, `organizer/layout.tsx` and `organizer/tournaments/create/page.tsx` contain no fixed/z-index overlays at all — a repo-wide search for `fixed inset-0` / `z-50` in `src/app/organizer/**` returns only the files listed in the findings.",
    "`CourtScheduleBoard.tsx:4578-4581` — the export menu uses a native `<details>`/`<summary>` pair, so it is keyboard-operable by construction (unlike the sibling popovers reported above).",
    "No `autoFocus` was found that lands focus on `body` or on a non-focusable container: the only in-overlay `autoFocus` is `RegistrationFormBuilder.tsx:389` (reported above at low confidence), and the one deliberate programmatic focus, `PairingParticipantsModal.tsx:122-124`, correctly targets a `tabIndex={-1}` container. The three `autoFocus` calls in `manage/page.tsx` (1007, 1449, 1645) target inline-rename inputs rendered in the page, not inside any overlay.",
    "No focus-trap, scroll-lock or Escape defects exist in the Radix dialogs, and no organizer dialog blocks Radix's Escape in a way that would strand it — `ManageWideOverlay.tsx:89-94` is the only `onEscapeKeyDown` override and it correctly defers to the default on the second press."
  ],
  "coverage": "READ-ONLY audit; no files were modified and no builds/tests/linters were run (as instructed).\n\nMethod: I enumerated the whole overlay surface two ways and cross-checked them. (1) A repo-wide regex for `fixed inset-0` / `absolute inset-0` / `z-50` / `z-[NN]` / `z-40` across `src/app/organizer/**` — exhaustive for the stated scope, and it produced the complete overlay list (series/manage leg + link dialogs; manage/page fullscreen workspace; CourtCameraBoard conflict alertdialog; CourtScheduleBoard local fullscreen, date-picker popover, auto-schedule menu, duration popover, context menu; CourtWorkspace fullscreen; CreateVenueModal; EditVenueModal; VenueCourtsModal; ManageWideOverlay; TournamentManageSidebar drawer; create/QuickTournamentCreate format dialog; create/SmartAiTournamentModal). (2) A grep for every `from '@/components/ui/Modal'` import in `src/app/organizer/**` to classify the Radix-backed set, then a per-file check that each `ModalContent` has a sibling `ModalTitle`.\n\nRead in full: `src/components/ui/Modal.tsx`, `ConfirmModal.tsx`, `Toaster.tsx`, `Textarea.tsx`, `src/components/common/ShareModal.tsx`, `src/components/common/CircularImageCropModal.tsx`, `src/app/organizer/series/[id]/manage/page.tsx` (overlay regions), `manage/components/CreateVenueModal.tsx`, `EditVenueModal.tsx`, `VenueCourtsModal.tsx`, `ManageWideOverlay.tsx`, `MockDataModal.tsx` (full render), `PairingParticipantsModal.tsx` (99-248), `CourtWorkspace.tsx` (299-433), `TournamentManageSidebar.tsx` (300-400), `payouts/page.tsx` (149-263), `Input.tsx` (1-63).\n\nRead in targeted ranges only — the largest files were NOT read end-to-end: `CourtScheduleBoard.tsx` (6415 lines: 1264-1303, 4029-4143, 4160-4263, 4719-4803, 4859-4963, 5805-5963; every finding is anchored to a line inside those ranges), `BracketSetupModal.tsx` (672 lines: 399-623), `manage/page.tsx` (3803 lines: 584-628, 2679-2793, 2807-2842, 3373-3386), `RegistrationFormBuilder.tsx` (only the 380-395 autoFocus region and the modal shell), `SmartAiTournamentModal.tsx` (614-703 plus a full identifier/handler scan), `QuickTournamentCreate.tsx` (1699-1803, 490-505), `CourtCameraBoard.tsx` (429-458, 659-743, handler scan), `ScheduleGridView.tsx`, `LivestreamTab.tsx`, `PermissionsTab.tsx`, `OpsMatches.tsx`, `OpsParticipants.tsx`, `TournamentStepper.tsx`, `RosterImportModal.tsx`, `CreateDivisionModal.tsx` (modal shells only). For those I verified only dialog/overlay and interactive-element behaviour, not unrelated page logic — a non-overlay a11y defect in an unread region would not have been caught.\n\nI additionally audited two components outside the literal target directories because they are rendered as overlays by organizer routes: `src/components/common/ShareModal.tsx` (rendered at `manage/page.tsx:3374`) and `src/components/common/CircularImageCropModal.tsx` (rendered at `manage/page.tsx:3382` and `create/QuickTournamentCreate.tsx:415`).\n\nTwo things I could not prove and therefore did not report as defects: (a) whether any hand-rolled overlay's open handler causes its trigger to unmount (which would drop focus to `body` rather than leaving it on the trigger) — in every case I read the trigger stays mounted, so I described the failure as \"focus stays on the trigger\"; (b) the runtime effect of `RegistrationFormBuilder.tsx:389` `autoFocus`, filed at confidence 0.45 with the mechanism stated. I also concluded the dangling-id claims (`court-workspace-title`, `schedule-board-title`) from a repo-wide identifier search that found no matching `id` in `src/`, not from runtime inspection.",
  "findings": [
    {
      "confidence": 0.97,
      "evidence": "`if (!isOpen) return null;` (71) then `return (` / `<div className=\"fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs animate-in fade-in duration-150\">` (153) / `<div className=\"relative w-full max-w-lg rounded-xl bg-white shadow-xl border border-slate-200 overflow-hidden flex flex-col\">` (154). No `role`, no `aria-modal`, no `aria-label`/`aria-labelledby`; the file contains no `useEffect`, no `ref`, no `keydown` listener and no `.focus()` call.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CreateVenueModal.tsx",
      "impact": "Screen readers see no dialog; focus stays on the trigger, Tab walks straight through the form into the page behind it, Escape does nothing, and the page behind is never hidden from AT — the venue form is unusable without a mouse.",
      "line": 153,
      "severity": "Critical",
      "title": "CreateVenueModal is a bare `fixed inset-0` div: no role/aria-modal, no focus move, no Tab trap, no Escape, no focus return, no background isolation"
    },
    {
      "confidence": 0.97,
      "evidence": "Lines 214-217: `<label className=\"block text-xs font-bold text-slate-700 mb-1.5\">Tên địa điểm / Tên CLB <span className=\"text-rose-500\">*</span></label>` followed by `<Input value={name} … />`; the same sibling-label pattern at 228/231, 309/310, 320/321. The bare `<select>`s at 183, 250, 266 have no `aria-label` and no wrapping label (183's only nearby text is a `<p>` at 178-180).",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CreateVenueModal.tsx",
      "impact": "Every form control in the modal is announced as an unlabelled combobox/textbox, so a screen-reader user cannot tell the name field from the address field or pick a province.",
      "line": 214,
      "severity": "Critical",
      "title": "Every control inside CreateVenueModal has no accessible name (labels are siblings with no htmlFor; selects have no label at all)"
    },
    {
      "confidence": 0.97,
      "evidence": "`<button type=\"button\" onClick={onClose} className=\"rounded-lg p-1.5 text-slate-400 …\">` (166-170) containing only `<X className=\"h-4 w-4\" />` (171); no `aria-label` and no `<span className=\"sr-only\">`.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CreateVenueModal.tsx",
      "impact": "The only keyboard-reachable way out of the modal announces as just \"button\" — a screen-reader user cannot find the dismiss control.",
      "line": 166,
      "severity": "Critical",
      "title": "CreateVenueModal close button is icon-only with no accessible name"
    },
    {
      "confidence": 0.97,
      "evidence": "`if (!isOpen || !venue) return null;` (69) / `<div className=\"fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs animate-in fade-in duration-150\">` (112) / `<div className=\"relative w-full max-w-lg rounded-xl bg-white shadow-xl border border-slate-200 overflow-hidden\">` (113). No `role`, no `aria-modal`, no accessible name; no `useEffect`, no ref, no `keydown` listener in the file.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/EditVenueModal.tsx",
      "impact": "No dialog semantics, no focus containment, no Escape, no focus return, background still exposed to AT.",
      "line": 112,
      "severity": "Critical",
      "title": "EditVenueModal is a bare `fixed inset-0` div with no dialog semantics and no keyboard affordances"
    },
    {
      "confidence": 0.97,
      "evidence": "`<button type=\"button\" onClick={onClose} className=\"rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 …\">` (125-129) / `<X className=\"h-4 w-4\" />` (130). Same unnamed-close pattern as CreateVenueModal.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/EditVenueModal.tsx",
      "impact": "Screen-reader users get an unnamed \"button\" for the modal's only dismiss control.",
      "line": 125,
      "severity": "Critical",
      "title": "EditVenueModal close button is icon-only with no accessible name"
    },
    {
      "confidence": 0.97,
      "evidence": "Lines 141/144, 154/157: `<label className=\"block text-xs font-bold text-slate-700 mb-1.5\">…</label>` then `<Input value={name} … />`; the selects at 176 and 192 are preceded by sibling `<label>`s (175, 191) with no `htmlFor` and carry no `aria-label`.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/EditVenueModal.tsx",
      "impact": "Name, address, province and ward are all announced without labels.",
      "line": 141,
      "severity": "Critical",
      "title": "EditVenueModal form controls have no accessible names (sibling labels, no htmlFor)"
    },
    {
      "confidence": 0.97,
      "evidence": "`if (!isOpen || !venue) return null;` (57) / `<div className=\"fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs animate-in fade-in duration-150\">` (115) / `<div className=\"relative w-full max-w-2xl rounded-xl bg-white shadow-xl border border-slate-200 max-h-[90vh] flex flex-col overflow-hidden\">` (116). No `role`, no `aria-modal`, no label; no `useEffect`, no ref, no keydown handler in the file.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/VenueCourtsModal.tsx",
      "impact": "The whole venue/court editor loses dialog semantics, focus containment, Escape and focus return.",
      "line": 115,
      "severity": "Critical",
      "title": "VenueCourtsModal is a bare `fixed inset-0` div with no dialog semantics and no keyboard affordances"
    },
    {
      "confidence": 0.97,
      "evidence": "`<button type=\"button\" onClick={onClose} className=\"rounded-lg p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors\">` (123-127) / `<X className=\"h-4 w-4\" />` (128).",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/VenueCourtsModal.tsx",
      "impact": "Unnamed dismiss control for screen-reader users.",
      "line": 123,
      "severity": "Critical",
      "title": "VenueCourtsModal close button is icon-only with no accessible name"
    },
    {
      "confidence": 0.95,
      "evidence": "Lines 230/231 and 241/242: `<label className=\"block text-xs font-semibold text-slate-500 mb-1\">Số lượng sân</label>` then `<Input type=\"number\" …>`; the single-court field at 271-275 carries only `placeholder=\"VD: Sân VIP 1, Sân Trung Tâm…\"`; the per-court URL field at 336 has no label or `aria-label`.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/VenueCourtsModal.tsx",
      "impact": "Court-count, prefix, court-name and stream-URL fields are announced unlabelled.",
      "line": 230,
      "severity": "Important",
      "title": "VenueCourtsModal batch-creator and court-name inputs have no accessible names"
    },
    {
      "confidence": 0.97,
      "evidence": "`{isLegModalOpen && (` (445) / `<div className=\"fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4\">` (446) / `<div className=\"bg-white w-full max-w-md rounded-lg border border-slate-200 shadow-xl overflow-hidden animate-in fade-in duration-200\">` (447). No `role`, no `aria-modal`, no label; the file contains no Escape listener and no `.focus()` call.",
      "file": "web/src/app/organizer/series/[id]/manage/page.tsx",
      "impact": "No dialog semantics, focus trap, Escape or focus return for the leg editor.",
      "line": 446,
      "severity": "Critical",
      "title": "Series leg dialog is a bare `fixed inset-0` div with no dialog semantics and no keyboard affordances"
    },
    {
      "confidence": 0.97,
      "evidence": "`<button onClick={() => setIsLegModalOpen(false)} className=\"p-1 text-slate-400 hover:text-slate-700 rounded-lg\">` (452) / `<X className=\"w-5 h-5\" />` (453). No `aria-label`, no `sr-only`, and no `type` attribute.",
      "file": "web/src/app/organizer/series/[id]/manage/page.tsx",
      "impact": "The dismiss control is announced as an unlabelled button.",
      "line": 452,
      "severity": "Critical",
      "title": "Series leg dialog close button is icon-only with no accessible name"
    },
    {
      "confidence": 0.97,
      "evidence": "`{isLinkModalOpen && (` (537) / `<div className=\"fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4\">` (538) / `<div className=\"bg-white w-full max-w-md rounded-lg border border-slate-200 shadow-xl overflow-hidden animate-in fade-in duration-200\">` (539). No `role`, no `aria-modal`, no label; no Escape listener, no focus code in the file.",
      "file": "web/src/app/organizer/series/[id]/manage/page.tsx",
      "impact": "No dialog semantics, focus trap, Escape or focus return for the tournament-link editor.",
      "line": 538,
      "severity": "Critical",
      "title": "Series link-tournament dialog is a bare `fixed inset-0` div with no dialog semantics and no keyboard affordances"
    },
    {
      "confidence": 0.97,
      "evidence": "`<button onClick={() => setIsLinkModalOpen(false)} className=\"p-1 text-slate-400 hover:text-slate-700 rounded-lg\">` (544) / `<X className=\"w-5 h-5\" />` (545).",
      "file": "web/src/app/organizer/series/[id]/manage/page.tsx",
      "impact": "Unnamed dismiss control for screen-reader users.",
      "line": 544,
      "severity": "Critical",
      "title": "Series link dialog close button is icon-only with no accessible name"
    },
    {
      "confidence": 0.97,
      "evidence": "`if (!isOpen) return null;` (215) / `<div className=\"fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-fadeIn\" onMouseDown={(event) => { if (event.target === event.currentTarget && !isAnalyzing && !isCreating) onClose(); }}>` (632-637). The only `useEffect` in the file (181-190) fetches categories; there is no keydown listener, no ref and no `.focus()`.",
      "file": "web/src/app/organizer/tournaments/create/SmartAiTournamentModal.tsx",
      "impact": "Escape does not close it, focus never enters it, and assistive tech has no dialog to announce — the multi-step AI creation wizard is mouse-only to close and explore.",
      "line": 632,
      "severity": "Critical",
      "title": "SmartAiTournamentModal is a bare `fixed inset-0` div with no role, no aria-modal, no Escape, no focus handling"
    },
    {
      "confidence": 0.97,
      "evidence": "`<button onClick={onClose} className=\"p-1.5 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-xl transition-colors\">` (652-655) / `<X className=\"w-5 h-5\" />` (656). No `aria-label`, no `sr-only`, no `type`.",
      "file": "web/src/app/organizer/tournaments/create/SmartAiTournamentModal.tsx",
      "impact": "Screen-reader users get an unlabelled button as the only keyboard exit.",
      "line": 652,
      "severity": "Critical",
      "title": "SmartAiTournamentModal close button is icon-only with no accessible name"
    },
    {
      "confidence": 0.95,
      "evidence": "`<div className=\"fixed inset-0 z-50 flex items-center justify-center\">` (102) / `<div className=\"absolute inset-0 bg-slate-900/40 backdrop-blur-[3px] …\" onClick={onClose} />` (104-107) / `<div className=\"relative w-full max-w-lg overflow-hidden rounded-lg …\">` (110). Only `useEffect`s (20-36) handle mount timing and body scroll; no keydown listener, no ref, no `.focus()`. Rendered from `manage/page.tsx:3374`.",
      "file": "web/src/components/common/ShareModal.tsx",
      "impact": "No dialog semantics, no Escape, no focus containment or return; the backdrop close path is reachable by mouse only.",
      "line": 102,
      "severity": "Critical",
      "title": "ShareModal (rendered by the manage page) is a bare `fixed inset-0` div with no role/aria-modal, no Escape and no focus handling"
    },
    {
      "confidence": 0.95,
      "evidence": "`<div className=\"absolute inset-0 bg-slate-900/40 backdrop-blur-[3px] transition-opacity duration-350\" onClick={onClose} />` — a `div` with an `onClick` and no `role`, no `tabIndex`, no `onKeyDown`.",
      "file": "web/src/components/common/ShareModal.tsx",
      "impact": "Backdrop-dismiss is mouse-only; keyboard users must find the (unlabelled) close button.",
      "line": 104,
      "severity": "Minor",
      "title": "ShareModal backdrop is a non-interactive div with a mouse-only onClick"
    },
    {
      "confidence": 0.95,
      "evidence": "`useEffect(() => { if (isOpen) { document.body.style.overflow = 'hidden'; } else { document.body.style.overflow = 'unset'; } return () => { document.body.style.overflow = 'unset'; }; }, [isOpen]);`",
      "file": "web/src/components/common/ShareModal.tsx",
      "impact": "Closing the share modal resets body scroll to `unset` instead of the previous value, so a scroll lock set by the fullscreen-workspace effect (`manage/page.tsx:600-601`) can be released prematurely.",
      "line": 28,
      "severity": "Minor",
      "title": "ShareModal body-scroll lock clobbers other scroll locks on close and on unmount"
    },
    {
      "confidence": 0.95,
      "evidence": "`<div className=\"fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-xs p-4 animate-in fade-in duration-200\">` (189) / `<div className=\"bg-white rounded-2xl max-w-md w-full p-5 shadow-2xl border border-slate-200 flex flex-col gap-4\">` (190). Only `useEffect` (26-38) resets zoom/pan. Rendered from `manage/page.tsx:3382` and `create/QuickTournamentCreate.tsx:415`.",
      "file": "web/src/components/common/CircularImageCropModal.tsx",
      "impact": "No dialog semantics, no Escape, no focus containment or return while cropping the logo.",
      "line": 189,
      "severity": "Important",
      "title": "CircularImageCropModal is a bare `fixed inset-0` div with no role/aria-modal, no Escape and no focus handling"
    },
    {
      "confidence": 0.95,
      "evidence": "`<button onClick={onClose} className=\"p-1.5 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors\">` (197-200) / `<X className=\"w-5 h-5\" />` (201).",
      "file": "web/src/components/common/CircularImageCropModal.tsx",
      "impact": "Unnamed dismiss control.",
      "line": 197,
      "severity": "Important",
      "title": "CircularImageCropModal close button is icon-only with no accessible name"
    },
    {
      "confidence": 0.9,
      "evidence": "`<div className=\"relative w-[260px] h-[260px] rounded-full overflow-hidden … cursor-grab active:cursor-grabbing …\" onMouseDown={handleMouseDown} onMouseMove={handleMouseMove} onMouseUp={handleMouseUp} onMouseLeave={handleMouseUp} onTouchStart={handleTouchStart} onTouchMove={handleTouchMove} onTouchEnd={handleTouchEnd}>` (207-214) — a `div` with no `role`, no `tabIndex`, no `onKeyDown`. Zoom is separately available via the `type=\"range\"` input, but pan is not.",
      "file": "web/src/components/common/CircularImageCropModal.tsx",
      "impact": "A keyboard-only organizer can zoom but can never re-position the image, so the crop is effectively unusable without a pointer.",
      "line": 207,
      "severity": "Important",
      "title": "CircularImageCropModal image pan is a mouse/touch-only drag on a plain div — no keyboard equivalent"
    },
    {
      "confidence": 0.92,
      "evidence": "`{label && (<label className=\"text-sm font-medium text-slate-700\">{label}</label>)}` (21-24) then `<input type={type} … ref={ref} {...props} />` (33-41). No `htmlFor`, no generated `id`, and no `aria-label` is applied.",
      "file": "web/src/components/ui/Input.tsx",
      "impact": "Every `<Input label=…>` consumer — including `CreateVenueModal:217/231/310/321`, `EditVenueModal:144/157`, `VenueCourtsModal:231/242`, `organizer/payouts/page.tsx`, `organizer/.../ops/page.tsx` — renders a field with no accessible name even though a visible label is on screen.",
      "line": 21,
      "severity": "Important",
      "title": "Shared Input primitive emits a `<label>` that is not associated with its `<input>`, so `label`-passed fields have no accessible name"
    },
    {
      "confidence": 0.95,
      "evidence": "`<div className=\"fixed inset-0 z-[70] flex min-h-screen flex-col overflow-hidden bg-slate-100\" role=\"dialog\" aria-modal=\"true\" aria-labelledby=\"fullscreen-workspace-title\">` (2697). Escape and scroll lock exist (`const handleEscape = (event: KeyboardEvent) => { if (event.key === 'Escape') setIsCourtWorkspaceFullscreen(false); };` 596-599; `document.body.style.overflow = 'hidden'` 600). There is no ref, no `.focus()`, no Tab handling, no `inert`, and it renders as a plain sibling inside the page flow.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/page.tsx",
      "impact": "Focus stays on the trigger behind the overlay and Tab reaches every control in the obscured page; `aria-modal` alone does not remove those controls from the tab order.",
      "line": 2697,
      "severity": "Important",
      "title": "Global fullscreen workspace dialog declares role/aria-modal but never moves focus, traps Tab, or returns focus"
    },
    {
      "confidence": 0.95,
      "evidence": "`<div className=\"fixed inset-0 z-50 flex flex-col overflow-hidden bg-slate-100 animate-in fade-in duration-150 p-2 md:p-3\" role=\"dialog\" aria-modal=\"true\" aria-labelledby=\"fullscreen-workspace-title\">` (413-418). A repo-wide search for `fullscreen-workspace-title` matches only this `aria-labelledby` and the unrelated `<h2 id=\"fullscreen-workspace-title\">` at `manage/page.tsx:2701`; the nearest section instead references `aria-labelledby=\"court-workspace-title\"` (396) for which no `id` exists anywhere in `src`. No Escape listener, no ref, no `.focus()` in this file.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtWorkspace.tsx",
      "impact": "The fullscreen workspace is announced with no name at all, and it has no Escape, no focus move, no focus trap and no focus return.",
      "line": 413,
      "severity": "Important",
      "title": "CourtWorkspace's own fullscreen dialog points `aria-labelledby` at an id that exists only in a different component"
    },
    {
      "confidence": 0.95,
      "evidence": "`<section className={`relative w-full ${isLocalFullscreen ? 'fixed inset-0 z-50 bg-slate-100 p-3 flex flex-col overflow-hidden h-screen' : 'space-y-1.5 h-full flex flex-col'}`} aria-labelledby=\"schedule-board-title\" ref={boardRef} onClick={handleScheduleShellClick}>` (4182-4192). No `role`, no `aria-modal`; a repo-wide search for `schedule-board-title` matches only line 4190. Escape is wired (`if (e.key === 'Escape') { clearScheduleSelection(); if (isLocalFullscreen) setIsLocalFullscreen(false); }` 1274-1282) but there is no focus move, trap or return.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "Board fullscreen is an unnamed, unannounced, non-modal full-screen takeover with no focus containment, and the board's landmark is unnamed at all times.",
      "line": 4186,
      "severity": "Important",
      "title": "CourtScheduleBoard's fullscreen mode is a `<section>` with no dialog role, and its `aria-labelledby` target id does not exist"
    },
    {
      "confidence": 0.95,
      "evidence": "`<div role=\"alertdialog\" aria-labelledby=\"court-board-conflict-title\" aria-describedby=\"court-board-conflict-body\" className=\"fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4 backdrop-blur-xs\">` (679-683), with the title `h4 id=\"court-board-conflict-title\"` (686) and body `p id=\"court-board-conflict-body\"` (693). No ref, no `.focus()`, no `tabIndex`, no keydown handler; the only `useEffect`s in the file register sensors and drag handlers.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtCameraBoard.tsx",
      "impact": "The dialog is correctly named and described, but focus never enters it, Tab is not contained, Escape does not dismiss the conflict prompt, and focus is not restored.",
      "line": 679,
      "severity": "Important",
      "title": "Court camera conflict prompt is a hand-rolled `role=\"alertdialog\"` with no focus move, no Tab trap, no Escape and no focus return"
    },
    {
      "confidence": 0.92,
      "evidence": "`useEffect(() => { if (isConfirmingRandom) randomConfirmRef.current?.focus(); }, [isConfirmingRandom]);` (122-124) and `<div ref={randomConfirmRef} role=\"dialog\" aria-labelledby={randomConfirmTitleId} aria-describedby={randomConfirmDescriptionId} tabIndex={-1} onKeyDown={handleConfirmKeyDown} className=\"space-y-4 p-5 focus-visible:outline-none\">` (214-222).",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/PairingParticipantsModal.tsx",
      "impact": "Not a functional break — reported because a nested `role=\"dialog\"` without `aria-modal` announces a second dialog boundary to screen readers, and Tab is not confined to the two confirmation buttons.",
      "line": 122,
      "severity": "Minor",
      "title": "Nested random-pairing confirmation inside the Radix dialog creates a second, non-modal `role=\"dialog\"` with no Tab trap"
    },
    {
      "confidence": 0.95,
      "evidence": "`const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 5 } }));` (437-442) — no `KeyboardSensor` anywhere in the imports (12-23 list only `PointerSensor`). The handle is `<button type=\"button\" {...attributes} {...listeners} aria-label={t(\"dragHandleAria\")}>` (208-212).",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtCameraBoard.tsx",
      "impact": "The button takes focus and announces a drag handle, but Space/Enter do nothing, so a keyboard user can never move a match to another court here.",
      "line": 437,
      "severity": "Important",
      "title": "Court camera drag handle is a focusable button with a drag aria-label, but only PointerSensor is registered so keyboard dragging is dead"
    },
    {
      "confidence": 0.95,
      "evidence": "Team chips: `<div key={team.id} draggable onDragStart={(e) => handleDragStart(e, team.id)} className=\"p-2.5 rounded-lg border border-slate-200 bg-white … cursor-grab …\">` (521-528, unassigned) and the assigned variant (581-586). Drop zones: `<div onDragOver={handleDragOver} onDrop={handleDropOnUnassigned} className=\"lg:col-span-4 …\">` (496-500), `<div … onDrop={(e) => handleDropOnGroup(e, gIdx)} …>` (562-566), and the empty-group zone (619-622). The only mutation paths found are `handleDropOnGroup` (357) and `handleDropOnUnassigned` (371); the sole non-drag escape is the \"move to unassigned\" `button` (603-613), which only removes.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/BracketSetupModal.tsx",
      "impact": "No team can be placed into a pool without a pointer, and the empty-pool drop zone (620-622, `cursor-pointer`) is neither clickable nor focusable.",
      "line": 521,
      "severity": "Critical",
      "title": "Bracket setup group assignment is HTML5 drag-and-drop only: chips and drop zones are divs with no role, no tabIndex and no key handler"
    },
    {
      "confidence": 0.95,
      "evidence": "Column header: `key={court.id} onPointerDown={(e) => handleCourtColPointerDown(cIdx, e)} onPointerEnter={() => handleCourtColPointerEnter(cIdx)} title={`Bấm hoặc kéo ngang để chọn cột ${court.courtName}`}` inside a plain `div` (4718-4735). Time row: `onPointerDown={(e) => handleTimeRowPointerDown(row.index, e)}` on a `div` (4748-4774). Cell: `<div key={`${court.id}-${row.index}`} … onPointerDown … onPointerEnter … onDoubleClick … onClick … onContextMenu … title={`Click / Click phải để mở menu thao tác…`} />` (4885-4941), whose `onClick`/`onDoubleClick` handlers call `openAssignmentPicker(court.id, targetTime, row.index)` (4905, 4910). None has `role`, `tabIndex` or a key handler.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "Range selection, cell-to-match assignment and the whole right-click action menu are pointer-only, so the primary scheduling surface is unusable by keyboard.",
      "line": 4885,
      "severity": "Critical",
      "title": "Schedule board court column, time row and grid cell are pointer-only divs — selection and cell click are unreachable by keyboard"
    },
    {
      "confidence": 0.93,
      "evidence": "Only triggers: `<button type=\"button\" onContextMenu={(event) => { event.preventDefault(); event.stopPropagation(); … setContextMenu({ x: event.clientX, y: event.clientY, … }); }}>` on the match card (3980-4005), the time row (4751-4766) and the grid cell (4913-4938). The panel is `<div className=\"fixed z-50 w-[270px] rounded-2xl bg-white/98 … select-none …\" style={{ left: Math.max(10, menuX), top: Math.max(10, menuY) }} onClick={…} onContextMenu={…}>` (5844-5858) containing plain `<button>` items; no `role=\"menu\"`/`role=\"menuitem\"`, no `tabIndex`, and no focus is moved on open. Only `if (e.key === 'Escape') { setContextMenu(null); clearScheduleSelection(); }` (2155-2159) and a global click-away (2148-2154) dismiss it.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "Cut/copy/paste, duration change, move-to-court, block, clear and bulk-schedule are available to pointer users only — there is no keyboard or Shift+F10 path to this menu at all.",
      "line": 5844,
      "severity": "Critical",
      "title": "Schedule board context menu is opened only by right-click and is a bare `div` with no menu semantics and no focus handling"
    },
    {
      "confidence": 0.95,
      "evidence": "Openers are `<button type=\"button\" onClick={() => setIsDatePickerOpen((prev) => !prev)}>` (4216-4224), `setAutoScheduleMenuOpen` (4439-4447) and the duration picker (4036-4049). The popovers are bare divs: date picker `<div className=\"absolute left-0 top-full mt-2 z-[101] w-80 …\">` (4233) preceded by a mouse-only backdrop `<div className=\"fixed inset-0 z-[100]\" onClick={() => setIsDatePickerOpen(false)} />` (4229-4232); auto-schedule `<div className=\"absolute left-0 top-full mt-1 z-50 w-56 …\">` (4452-4453); duration popover `<div className=\"pointer-events-auto absolute right-0 top-full z-40 mt-1 w-48 …\">` (4052-4053). The board's only key handlers are `clearScheduleSelection()` + fullscreen exit (1274-1282) and `{ setContextMenu(null); clearScheduleSelection(); }` (2155-2159) — neither resets these flags.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "Keyboard users can open these but not close them with Escape, and the date-picker backdrop is a div with a mouse-only handler.",
      "line": 4229,
      "severity": "Important",
      "title": "Board ribbon popovers (date picker, auto-schedule, match duration) have no role, no focus move and no Escape dismissal"
    },
    {
      "confidence": 0.95,
      "evidence": "`<button type=\"button\" onClick={() => setIsDatePickerOpen(false)} className=\"text-slate-400 hover:text-slate-600 p-0.5 rounded-md text-xs font-bold cursor-pointer\">` (4239-4243) / `✕` (4244). Contrast the sibling duration popover, which does name its close button: `aria-label=\"Đóng bảng chọn thời lượng\"` (4065).",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "The popover's dismiss control is announced as a bare glyph.",
      "line": 4239,
      "severity": "Minor",
      "title": "Date-picker popover close button is a bare `✕` glyph with no accessible name"
    },
    {
      "confidence": 0.95,
      "evidence": "`<div className=\"fixed inset-0 z-[110] flex items-center justify-center bg-slate-950/45 p-4 backdrop-blur-sm\" role=\"dialog\" aria-modal=\"true\" aria-label={translate('formatDialogAria')} onMouseDown={(event) => { if (event.target === event.currentTarget) setIsFormatModalOpen(false); }}>` (1714-1721) with `<button type=\"button\" … aria-label={translate('close')}>` (1731). Escape is handled by `useEffect(() => { … const handleEscape = (event: KeyboardEvent) => { if (event.key !== 'Escape') return; if (isFormatModalOpen) setIsFormatModalOpen(false); if (isAiModalOpen) setIsAiModalOpen(false); }; window.addEventListener('keydown', handleEscape); … }, [isAiModalOpen, isFormatModalOpen]);` (495-504). The file contains no ref and no `.focus()`.",
      "file": "web/src/app/organizer/tournaments/create/QuickTournamentCreate.tsx",
      "impact": "Name, aria-modal, Escape and a named close button are all correct, but focus never enters the dialog, Tab escapes into the create form behind it, and closing leaves focus on the trigger.",
      "line": 1714,
      "severity": "Important",
      "title": "Quick-tournament format dialog has correct semantics and Escape but no focus move, no Tab trap and no focus return"
    },
    {
      "confidence": 0.9,
      "evidence": "The component defines `{isOpen ? <button type=\"button\" onClick={onClose} className=\"fixed inset-0 z-40 bg-slate-950/35 lg:hidden\" aria-label={t('sidebar.closeMenu')} /> : null}` (334) and `<aside aria-label={t('sidebar.manageMenu')} … className={cn('z-50 flex-col gap-3 …', isOpen ? 'fixed inset-y-0 left-0 flex w-[min(88vw,300px)] overflow-y-auto bg-white p-3 shadow-2xl' : 'hidden')}>` (336-345) — no `role=\"dialog\"`, no `aria-modal`, no Escape, no focus move/trap/return. A repo-wide search for `TournamentManageSidebar` shows it is only ever imported as a type: `import { type ManageSection } from './components/TournamentManageSidebar';` (`manage/page.tsx:49`).",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/TournamentManageSidebar.tsx",
      "impact": "Latent only — the component is dead code, so no user currently hits it; it would be a modal-without-semantics drawer the moment it is mounted again.",
      "line": 334,
      "severity": "Minor",
      "title": "Mobile manage-menu drawer would be a modal-less overlay, but the component is never rendered anywhere"
    },
    {
      "confidence": 0.93,
      "evidence": "Match card handle: `<div role=\"presentation\" draggable={false} onMouseDown={…} onPointerDown={(event) => { event.stopPropagation(); event.preventDefault(); … setMatchCardResize({ matchId: item.match.id, startY: event.clientY, … }); }} className=\"… cursor-ns-resize …\" title=\"Giữ chuột và kéo lên/xuống để co giãn thời lượng (15p, 20p, 25p, 30p...)\">` (4133-4182). Row divider: `<div role=\"presentation\" onPointerDown={(e) => { e.stopPropagation(); e.preventDefault(); … }} …>` (4780-4782), which rewrites `rowDurations` for the whole selected range. The duration popover button at 4036-4049 is the only keyboard-reachable way to change a match's length; no equivalent exists for row heights.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/CourtScheduleBoard.tsx",
      "impact": "`role=\"presentation\"` explicitly removes the element from the accessibility tree, so AT never learns the resize affordance exists; match duration has a keyboard fallback, row height does not.",
      "line": 4133,
      "severity": "Minor",
      "title": "Two drag-to-resize handles in the schedule board are `role=\"presentation\"` divs with no keyboard equivalent (row height has none at all)"
    },
    {
      "confidence": 0.45,
      "evidence": "`<ModalContent data-testid=\"roster-import-modal\" …>` (412) is Radix-backed, and at 389-390 a conditionally rendered field input inside it carries `className=\"mt-1.5 h-10 w-full rounded-lg …\" autoFocus`. I cannot prove the runtime outcome without running the component; the mechanism is the browser's own `autofocus` handling, which fires on mount and therefore runs after Radix's open-time focus placement.",
      "file": "web/src/app/organizer/tournaments/[id]/manage/components/RegistrationFormBuilder.tsx",
      "impact": "Unverified — flagged because a later-mounting `autoFocus` inside a focus-trapping dialog is a known way to move the dialog's initial focus away from its first control.",
      "line": 389,
      "severity": "Minor",
      "title": "`autoFocus` inside a Radix dialog may fight the dialog's own initial-focus placement"
    },
    {
      "confidence": 0.93,
      "evidence": "Header close is `<button onClick={onClose} className=\"flex h-8 w-8 items-center justify-center rounded-full …\">` (115-118) / `✕` (119). The zoom buttons use `title={translate('zoomOut')}` / `title={translate('zoomIn')}` / `title={translate('reset')}` only.",
      "file": "web/src/components/common/CircularImageCropModal.tsx",
      "impact": "`✕` is read as punctuation and the zoom controls depend on `title` (a last-resort name) with no `aria-label`, so both are effectively unlabelled for screen-reader users.",
      "line": 115,
      "severity": "Minor",
      "title": "CircularImageCropModal names its zoom controls by `title` only and its close button by a bare `✕` glyph"
    }
  ]
}