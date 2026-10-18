// FIXTURE KIỂM THỬ QUY TẮC SEMGREP: lỗi giả có chủ đích. Không import, không chạy, không dùng trong build.
declare const html: string;
declare const userName: string;

const rawComment = <div dangerouslySetInnerHTML={{ __html: html }} />;
const rawBanner = <p dangerouslySetInnerHTML={{ __html: `<b>${userName}</b>` }} />;
