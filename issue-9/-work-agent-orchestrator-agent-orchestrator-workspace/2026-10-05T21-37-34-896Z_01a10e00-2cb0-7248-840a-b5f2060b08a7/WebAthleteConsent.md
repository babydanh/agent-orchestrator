{
  "status": "completed",
  "summary": "Đã tích hợp Add Athlete cạnh Import Excel, hoàn thiện consent opt-in cho các luồng tự đăng ký Web và trạng thái xác nhận riêng của người chơi; cập nhật note, snapshot phí và locale en/vi. Không sửa backend/tài liệu, không chạy build, lint, tests hoặc formatter theo yêu cầu.",
  "files": [
    "web/src/app/organizer/tournaments/[id]/manage/components/RegistrationTab.tsx — nút Add Athlete/modal wiring, refresh roster, note thành hàng cuối, payment chỉ khi snapshot dương; presence giữ nguyên.",
    "web/src/app/organizer/tournaments/[id]/manage/components/AddAthleteModal.tsx — error/retry candidate, phân trang, nhập trực tiếp thêm/bớt người theo division, note tối đa 280 ký tự, submit status và handoff claim token một lần.",
    "web/src/features/tournaments/api.ts — `MyRegistrationResponse.myRankingConsentAt` optional và client method `confirmMyRankingConsent` gọi endpoint hiện hữu.",
    "web/src/types/tournament.ts — `TournamentParticipant.organizerNote` optional.",
    "web/src/app/(public)/tournaments/[id]/register/page.tsx — opt-in không bắt buộc, tự xác nhận, trạng thái chỉ đọc sau xác nhận, giải thích không hồi tố.",
    "web/src/app/(public)/tournaments/[id]/register/components/DoublesRegistrationFlow.tsx — gửi consent chỉ khi ranked và checked; bỏ gate bắt buộc.",
    "web/src/app/(public)/tournaments/[id]/register/components/TeamRegistrationFlow.tsx — gửi consent chỉ khi ranked và checked; bỏ gate bắt buộc.",
    "web/src/app/(public)/tournaments/[id]/components/RegisterModal.tsx — consent tùy chọn, chỉ gửi `true` khi chọn.",
    "web/src/app/(public)/communities/[id]/components/CommunityTournamentRosterWidget.tsx — consent tùy chọn; luồng join invite chỉ gọi endpoint consent sau đăng ký nếu đã chọn.",
    "web/messages/en.json — nội dung Add Athlete và consent tiếng Anh.",
    "web/messages/vi.json — nội dung Add Athlete và consent tiếng Việt."
  ],
  "risks": [
    "Chưa xác minh runtime với backend đang được cập nhật; phần consent giả định `myRankingConsentAt` nằm ở root của `my-registration` và các API Add Athlete hiện hữu trả về đúng contract.",
    "Chưa triển khai giao diện đổi guest claim token thành claim flow/hiển thị lỗi invalid, expired hoặc already-used; token từ modal chỉ được handoff thủ công một lần như phạm vi yêu cầu.",
    "Build/tests/lint/formatter không chạy theo chỉ dẫn; cần main agent kiểm tra sau khi ghép thay đổi."
  ]
}