{
  "scope": "Narrow lint — 4 Organizer files only (no full lint)",
  "command": "pnpm run lint 'src/app/organizer/tournaments/[id]/manage/page.tsx' 'src/app/organizer/tournaments/[id]/manage/components/ManageWideOverlay.tsx' 'src/app/organizer/tournaments/[id]/manage/components/useManageState.ts' 'test/e2e/organizer-wide-tab-overlay.spec.ts'",
  "cwd": "/home/runner/work/agent-orchestrator/agent-orchestrator/workspace/web",
  "exitCode": "0",
  "result": "PASS",
  "durationSeconds": "7.83",
  "totalProblems": "30",
  "errors": "0",
  "warnings": "30",
  "filesWithErrors": "",
  "perFile": {
    "item": [
      {
        "file": "src/app/organizer/tournaments/[id]/manage/page.tsx",
        "errors": "0",
        "warnings": "23",
        "rules": {
          "item": [
            {
              "rule": "@typescript-eslint/no-unused-vars",
              "count": "22"
            },
            {
              "rule": "@next/next/no-img-element",
              "count": "1",
              "line": "911:11"
            }
          ]
        }
      },
      {
        "file": "src/app/organizer/tournaments/[id]/manage/components/useManageState.ts",
        "errors": "0",
        "warnings": "7",
        "rules": {
          "item": [
            {
              "rule": "@typescript-eslint/no-unused-vars",
              "count": "1",
              "detail": "'currentStages' is assigned a value but never used (505:15)"
            },
            {
              "rule": "react-hooks/exhaustive-deps",
              "count": "6",
              "detail": "lines 676:6 unnecessary dep 'id'; 1203:9, 1276:9, 1331:9 handleSave* not wrapped in useCallback; 2379:6 missing 'fetchTournamentVenues'; 2523:6 missing 'isLiteProduct' and 'tournamentScoringMode'"
            }
          ]
        }
      },
      {
        "file": "src/app/organizer/tournaments/[id]/manage/components/ManageWideOverlay.tsx",
        "errors": "0",
        "warnings": "0",
        "problems": "0"
      },
      {
        "file": "test/e2e/organizer-wide-tab-overlay.spec.ts",
        "errors": "0",
        "warnings": "0",
        "problems": "0"
      }
    ]
  },
  "workingTree": {
    "clean": "true",
    "evidence": "git status --porcelain -> 0 lines; diff vs pre-lint baseline IDENTICAL; branch omp/issue-6; HEAD 58ec032b0c40e008e7c2db7a2f334f7a497d8610 unchanged; no .eslintcache created",
    "noEditsMade": "true",
    "reportedTo": "Main (agent://Main)",
    "notes": "No file diagnostics printed back to Main beyond counts, file names with errors, and working-tree status, as requested."
  }
}