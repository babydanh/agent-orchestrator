{
  "sections": [
    {
      "task": "Add Athlete and guest-claim flow",
      "changed": [
        {
          "path": "web/src/features/tournaments/api.ts",
          "lines": "813-849",
          "details": "Model per-guest `claims[]` (`guestId`, `delivery`, optional HANDOFF token); add the existing guest-claim POST endpoint without assuming an unconfirmed response body."
        },
        {
          "path": "web/src/app/organizer/tournaments/[id]/manage/components/AddAthleteModal.tsx",
          "lines": "128-134",
          "details": "For each HANDOFF claim, show the organizer a one-time URL containing the guest ID and token in `#token=...`; leave emailed claims to the backend email flow."
        },
        {
          "path": "web/src/app/(public)/tournaments/[id]/guest-claim/[guestId]/page.tsx",
          "lines": "1-71",
          "details": "Read the token from the URL fragment; retain it in page memory while the user signs in in a separate tab; after email verification, clear the fragment and POST the token. Show localized success or neutral invalid/expired/reused/email-mismatch errors."
        },
        {
          "path": "web/messages/en.json",
          "lines": "5376-5390",
          "details": "Add guest-claim loading, sign-in, verification, error, and success copy."
        },
        {
          "path": "web/messages/vi.json",
          "lines": "5376-5390",
          "details": "Add Vietnamese guest-claim copy, including sign-in/refresh instructions and neutral claim errors."
        },
        {
          "path": "web/test/e2e/organizer-add-athlete.spec.ts",
          "lines": "56-69",
          "details": "Add a consumer scenario asserting fragment token POST and fragment cleanup after success."
        },
        {
          "path": "web/changes/organizer-add-athlete-consent-20261005/03-endpoint-contract.md",
          "lines": "29-31",
          "details": "Record the confirmed per-guest claims response and fragment link format."
        },
        {
          "path": "web/changes/organizer-add-athlete-consent-20261005/10-implementation-log.md",
          "lines": "13-15",
          "details": "Record Web implementation scope and that integrated verification remains outstanding."
        }
      ],
      "confirmed_existing_behavior": "Add Athlete remains a separate three-source flow with optional email/phone, no gender filter, and a short organizer note. Existing registration UI continues to use `entryFeeAtRegistration` for payment visibility (> 0), renders presence independently, and places the organizer note after the participant row. Existing player registration consent remains optional; the self-consent action uses `POST /tournaments/:id/participants/me/ranking-consent`, with no organizer control or duplicate route. No changes were needed in those existing surfaces.",
      "residual_concerns": [
        "The handoff URL is displayed in a one-time prompt; if the organizer dismisses it without copying, the one-time token cannot be retrieved again.",
        "Integrated runtime behavior is unverified. Parent should exercise FRIENDS/CLUB/DIRECT, both emailed and HANDOFF claims, sign-in in another tab then refresh, successful claim, and neutral invalid/expired/reused/email-mismatch handling."
      ],
      "verification": "No tests, builds, linters, formatters, or runtime checks were run."
    }
  ]
}