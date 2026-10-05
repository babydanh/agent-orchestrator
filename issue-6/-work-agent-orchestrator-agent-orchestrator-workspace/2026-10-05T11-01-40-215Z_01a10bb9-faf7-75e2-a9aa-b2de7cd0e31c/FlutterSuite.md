{
  "sdk": "/tmp/omp-flutter-3.47.0 — Flutter 3.47.0 (rev 4cf2416426) / Dart 3.13.0",
  "headline": "Tests: 689 passed, 46 failed, 0 skipped, exit 1. Analyze: 201 issues (0 errors / 112 warnings / 89 infos), exit 1. Lockfile was NOT rewritten this time — working tree is fully clean.",
  "flutterTest": {
    "command": "/tmp/omp-flutter-3.47.0/bin/flutter test",
    "exitCode": "1",
    "wallClockSeconds": "134.91",
    "passed": "689",
    "failed": "46",
    "skipped": "0",
    "total": "735",
    "skippedNote": "Summary line is '689 tests passed, 46 failed.'; a scan of all 7505 output lines found 0 '(skipped)' markers.",
    "failuresByFile": {
      "item": {
        "item": [
          {
            "count": "9",
            "file": "test/core/utils/elo_tier_test.dart"
          },
          {
            "count": "4",
            "file": "test/features/profile/profile_sections_test.dart",
            "symptom": "RenderFlex overflowed by 144 pixels"
          },
          {
            "count": "4",
            "file": "test/models/app_notification_test.dart",
            "symptom": "timeAgo returns English, Vietnamese expected"
          },
          {
            "count": "4",
            "file": "test/notification_test.dart",
            "symptom": "timeAgo returns English, Vietnamese expected"
          },
          {
            "count": "3",
            "file": "test/registration/join_invite_gates_test.dart",
            "symptom": "PathNotFoundException — lib/features/register/screens/join_invite_screen.dart no longer exists"
          },
          {
            "count": "2",
            "file": "test/features/community_social_settings_sheet_test.dart",
            "symptom": "NEW ON THIS SDK — see regressionNote below"
          },
          {
            "count": "2",
            "file": "test/features/global_search_transition_test.dart"
          },
          {
            "count": "2",
            "file": "test/batch_ab_verification_test.dart"
          },
          {
            "count": "2",
            "file": "test/core/widgets/app_menu_sheet_test.dart"
          },
          {
            "count": "1",
            "file": "test/community_social_widgets_test.dart"
          },
          {
            "count": "1",
            "file": "test/widget_test.dart",
            "symptom": "Bad state: No ProviderScope found"
          },
          {
            "count": "1",
            "file": "test/networking_test.dart",
            "symptom": "Binding has not yet been initialized"
          },
          {
            "count": "1",
            "file": "test/features/home_feed_states_test.dart"
          },
          {
            "count": "1",
            "file": "test/features/community_social_authorization_test.dart"
          },
          {
            "count": "1",
            "file": "test/features/social_share_link_test.dart"
          },
          {
            "count": "1",
            "file": "test/models/player_ranking_test.dart"
          },
          {
            "count": "1",
            "file": "test/models/match_member_info_test.dart"
          },
          {
            "count": "1",
            "file": "test/models/payment_test.dart"
          },
          {
            "count": "1",
            "file": "test/score_validator_test.dart"
          },
          {
            "count": "1",
            "file": "test/core/utils/elo_helpers_test.dart"
          },
          {
            "count": "1",
            "file": "test/registration/tournament_banner_entrypoint_test.dart"
          },
          {
            "count": "1",
            "file": "test/registration/tournament_register_elo_gate_test.dart"
          },
          {
            "count": "1",
            "file": "test/features/global_search_tournament_date_range_test.dart",
            "symptom": "FILE LOAD FAILURE — 'Missing definition of `main` method.' Same root cause as before: line 12 is `// void main() {`, so this 120-line test file is entirely inert and contributes zero executed tests."
          }
        ]
      }
    }
  },
  "regressionNote": {
    "summary": "Going 3.41.0 -> 3.47.0 added exactly 2 failures, both in test/features/community_social_settings_sheet_test.dart, and removed none. The 3.47.0 failure set is a strict superset of the 3.41.0 set (44 -> 46).",
    "isRealAppDefect": "true",
    "assertion": "ListTile background color or ink splashes may be invisible. The ListTile is wrapped in a DecoratedBox that has a background color. Because ListTile paints its background and ink splashes on the nearest Material ancestor, this DecoratedBox will hide those effects.",
    "offendingCode": {
      "file": "lib/features/community/widgets/community_social_settings_sheet.dart",
      "lines": "377-429",
      "function": "_buildMatchPermissions",
      "detail": "A Container (line 377) with decoration BoxDecoration(color: colors.bgSurface, borderRadius, border) at lines 379-383 wraps a Column (384) whose children include _toggle(...), and _toggle is SwitchListTile.adaptive (line 433). SwitchListTile extends ListTile, so the new framework assertion fires."
    },
    "suggestedFix": "Either wrap the inner Column in its own Material widget, or drop `color: colors.bgSurface` from the BoxDecoration at line 380 and move that colour to a Material ancestor. NOT APPLIED — this task is verification-only.",
    "failingTestNames": {
      "item": [
        "CommunitySocialSettingsSheet loads settings and renders without crashing",
        "CommunitySocialSettingsSheet handles error gracefully without getting stuck"
      ]
    }
  },
  "flutterAnalyze": {
    "command": "/tmp/omp-flutter-3.47.0/bin/flutter analyze",
    "exitCode": "1",
    "issues": "201",
    "errors": "0",
    "warnings": "112",
    "infos": "89",
    "wallClockSeconds": "30.9",
    "identicalToPreviousRun": "Yes — same 201 total, same 0/112/89 split, same per-rule counts and same lib/test split as the 3.41.0 analyze. The only difference is cosmetic: the newer analyzer appends a 'Try ...' hint to each message. No new or resolved diagnostics from the SDK bump.",
    "byRule": {
      "item": {
        "item": [
          {
            "count": "77",
            "severity": "warning",
            "rule": "unnecessary_non_null_assertion"
          },
          {
            "item": [
              {
                "count": "37",
                "severity": "info",
                "rule": "curly_braces_in_flow_control_structures"
              },
              {
                "item": [
                  {
                    "count": "28",
                    "severity": "info",
                    "rule": "avoid_print"
                  },
                  {
                    "item": [
                      {
                        "count": "25",
                        "severity": "warning",
                        "rule": "unused_import"
                      },
                      {
                        "item": [
                          {
                            "count": "12",
                            "severity": "info",
                            "rule": "use_null_aware_elements"
                          },
                          {
                            "item": [
                              {
                                "count": "5",
                                "severity": "warning",
                                "rule": "unused_element"
                              },
                              {
                                "item": [
                                  {
                                    "count": "5",
                                    "severity": "info",
                                    "rule": "deprecated_member_use"
                                  },
                                  {
                                    "item": [
                                      {
                                        "count": "2",
                                        "severity": "warning",
                                        "rule": "unused_field"
                                      },
                                      {
                                        "item": [
                                          {
                                            "count": "2",
                                            "severity": "warning",
                                            "rule": "invalid_null_aware_operator"
                                          },
                                          {
                                            "item": [
                                              {
                                                "count": "2",
                                                "severity": "info",
                                                "rule": "unnecessary_brace_in_string_interps"
                                              },
                                              {
                                                "item": [
                                                  {
                                                    "count": "2",
                                                    "severity": "info",
                                                    "rule": "unnecessary_underscores"
                                                  },
                                                  {
                                                    "item": [
                                                      {
                                                        "count": "1",
                                                        "severity": "warning",
                                                        "rule": "unused_local_variable"
                                                      },
                                                      {
                                                        "item": [
                                                          {
                                                            "count": "1",
                                                            "severity": "info",
                                                            "rule": "unnecessary_import"
                                                          },
                                                          {
                                                            "item": [
                                                              {
                                                                "count": "1",
                                                                "severity": "info",
                                                                "rule": "dangling_library_doc_comments"
                                                              },
                                                              {
                                                                "item": {
                                                                  "count": "1",
                                                                  "severity": "info",
                                                                  "rule": "depend_on_referenced_packages"
                                                                }
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    },
    "byArea": {
      "lib/": "143",
      "test/": "35",
      "rootLevelScripts": "23"
    },
    "assetWarning": "Absent from this run — the `asset_does_not_exist` warning for .env is gone because the .env fixture is in place, so no analyzer diagnostic depends on that fixture.",
    "ciNote": "CI (app/.github/workflows/deploy-ios.yml:60) uses `flutter analyze --no-fatal-infos --no-fatal-warnings`, so these 112 warnings would not fail CI, but bare `flutter analyze` exits 1."
  },
  "lockfile": {
    "changed": "false",
    "evidence": "`flutter test` printed 'Got dependencies!' with NO 'Changed N dependencies!' line. `git status --porcelain` is empty after both commands and the sdks block still reads dart \">=3.11.0-0 <4.0.0\" / flutter \">=3.41.0\", i.e. exactly the committed HEAD content.",
    "significance": "This confirms the earlier inference: the committed pubspec.lock was resolved with a Dart newer than 3.11.0. Under 3.47.0/Dart 3.13.0 it resolves as-is. Dart 3.11.0 (the previous SDK) downgraded 7 packages; 3.13.0 does not. So 3.47.0 is the first of the two SDKs that respects the lockfile."
  },
  "workingTree": {
    "head": "60b6e83b1f673b8feb9838e49fa9aab19d1e8b5b",
    "branch": "omp/issue-6",
    "headUnchanged": "true",
    "porcelain": "empty — fully clean",
    "untrackedNonIgnoredFiles": "none",
    "envFixtureUntouched": "app/.env unchanged (859 bytes, mtime 11:25, predating this run). Not copied, not deleted, contents never read or printed."
  },
  "constraintsRespected": {
    "noCodeEdits": "true",
    "noFormatterOrDartFix": "true",
    "noEnvCopyOrDelete": "true",
    "noEnvContentsReadOrPrinted": "true",
    "noCommits": "true",
    "noLockfileMutation": "true"
  },
  "item": "All 44 failures that were already red on 3.41.0 are still red on 3.47.0, and the handoff-scope tests (division_selection, quick_tournament_format_mapping, tournament_division_capacity) remain green — they are not in this failure list."
}