// FIXTURE KIỂM THỬ QUY TẮC SEMGREP: lỗi giả có chủ đích. Không import, không chạy, không dùng trong build.
declare const expr: string;
declare const body: string;

eval(expr);
const dynamicFn = new Function("x", body);
