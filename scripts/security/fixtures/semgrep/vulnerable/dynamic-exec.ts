// FIXTURE KIỂM THỬ QUY TẮC SEMGREP: lỗi giả có chủ đích. Không import, không chạy, không dùng trong build.
import { exec, execSync } from "child_process";
import * as cp from "child_process";

declare const dir: string;
declare const branch: string;
declare const cmd: string;

exec(`ls ${dir}`);
cp.execSync("git checkout " + branch);
execSync(cmd);
