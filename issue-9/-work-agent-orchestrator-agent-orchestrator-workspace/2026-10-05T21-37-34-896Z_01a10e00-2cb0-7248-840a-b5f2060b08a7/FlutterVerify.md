{
  "scope": "app/ only; no files changed.",
  "observed_behavior": [
    "app/lib/features/register/screens/tournament_register_screen.dart: ranked standard registration starts with `_rankingConsent = false`, exposes an opt-in checkbox, and sends `rankingConsent: true` only if explicitly checked; otherwise it sends null. Existing registered players get a separate explicit confirm action, gated from duplicate submits and marked complete only after repository success.",
    "When standard registration diverts to team or doubles, it forwards affirmative consent in the route query only when checked. app/lib/core/router/app_router.dart parses only literal `rankingConsent=true` into true, otherwise null.",
    "app/lib/features/register/screens/doubles_registration_screen.dart initializes consent from explicit route true; its ranked checkbox is player-controlled and unchecked by default absent that query. Submission sends true only when checked.",
    "app/lib/features/register/screens/football_team_register_screen.dart similarly initializes from true-only route input, displays checkbox only for new registrations in ranked tournaments, and submits true only on affirmative player choice. Participant roster updates do not alter consent.",
    "app/lib/data/repositories/api/api_tournament_repository.dart includes consent in registration payload only when `rankingConsent == true`; explicit later confirmation calls `/tournaments/$tournamentId/participants/me/ranking-consent`. No observed path grants consent based only on tournament ranking."
  ],
  "tests": {
    "discovery": "No test references to ranking consent were found under app/test. Existing related test: app/test/features/doubles_registration_saved_status_test.dart.",
    "command": "cd app && flutter test test/features/doubles_registration_saved_status_test.dart",
    "status": "Failed before tests ran (exit 1): `The current Dart SDK version is 3.7.2. Because app_quanly_giaidau requires SDK version ^3.10.3, version solving failed. Failed to update packages.`"
  },
  "analyze": {
    "command": "cd app && flutter analyze",
    "status": "Failed before analysis (exit 1), same dependency solver failure: installed Dart SDK 3.7.2 does not satisfy required ^3.10.3; package update failed."
  },
  "release_blocking_flaw": "No consent-flow defect evident from inspected app paths. Verification is blocked: installed Flutter/Dart toolchain is too old for the app's declared SDK requirement, so neither focused test nor analyze produced code validation. Flutter is not responsible for the Web guest-claim fragment flow."
}