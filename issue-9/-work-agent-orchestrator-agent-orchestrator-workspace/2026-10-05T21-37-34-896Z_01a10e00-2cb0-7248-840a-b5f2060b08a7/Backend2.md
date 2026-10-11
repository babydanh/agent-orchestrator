{
  "changed_files": [
    "backend/src/modules/rankings/ranking-consent-gate.spec.ts",
    "backend/src/modules/rankings/rankings.service.ts"
  ],
  "changes": [
    "Added gate behavior cases for non-ranked tournaments and empty match sides, with an expanded query harness.",
    "Extended ranking-consent eligibility to require ranked tournaments, two populated participant slots, and consent from every roster row no later than completedAt.",
    "Blocked manual updateMatchElo when ranking-consent eligibility fails."
  ],
  "constraints": [
    "Stopped further edits as requested by Main to avoid conflicts; add-athlete flow, consent registration, and reminders remain unimplemented by me.",
    "No tests/build/lint/formatters or migrations were run, as instructed.",
    "No staging or commits."
  ]
}