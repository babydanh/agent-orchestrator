{
  "summary": "Hoàn tất phần Flutter trong `app/`: sửa route doubles bị trùng `inviteCode`/thiếu đóng constructor; checkbox opt-in ranking consent ở singles, doubles và football; đăng ký chỉ gửi `rankingConsent: true` khi người chơi chọn; thêm repository POST consent và UI tự xác nhận một chiều trong status của `/my-registration`, dùng `myRankingConsentAt` ở root response. Cập nhật strings EN/VI với giải thích không hồi tố và bỏ key localization consent-required đã không còn dùng.",
  "files": [
    "app/lib/core/router/app_router.dart — route doubles",
    "app/lib/domain/repositories/tournament_repository.dart — `confirmMyRankingConsent`",
    "app/lib/data/repositories/api/api_tournament_repository.dart — omission false/null; POST `/participants/me/ranking-consent`",
    "app/lib/features/register/screens/tournament_register_screen.dart — checkbox singles và self-confirm trong registration status",
    "app/lib/features/register/screens/doubles_registration_screen.dart — checkbox doubles",
    "app/lib/features/register/screens/football_team_register_screen.dart — checkbox football",
    "app/lib/l10n/app_en.arb",
    "app/lib/l10n/app_vi.arb",
    "app/lib/l10n/app_localizations.dart",
    "app/lib/l10n/app_localizations_en.dart",
    "app/lib/l10n/app_localizations_vi.dart"
  ],
  "verification": "Không chạy tests, build, analyze, lint hoặc formatter theo yêu cầu.",
  "risks": [
    "[INFERENCE] ARB và localization Dart generated files đã được đồng bộ thủ công; việc chạy localization generation và compile chưa được xác minh.",
    "Không sửa backend; endpoint response/field contract cần được kiểm tra cùng thay đổi backend của phiên chính."
  ]
}