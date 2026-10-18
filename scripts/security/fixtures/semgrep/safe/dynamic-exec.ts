// FIXTURE AN TOÀN (negative case) cho quy tắc exec: không được báo bất kỳ vị trí nào.
import { execFile } from "child_process";
import * as cp from "child_process";

declare const text: string;
const digitPattern = /ab+c/;

cp.exec("git status --short");
cp.execSync(`git status --short`);
execFile("git", ["status", "--short"]);
digitPattern.exec(text);
