// FIXTURE AN TOÀN (negative case) cho quy tắc JSX: không được báo bất kỳ vị trí nào.
declare const DOMPurify: { sanitize: (html: string) => string };
declare const html: string;

const staticBanner = <p dangerouslySetInnerHTML={{ __html: "<b>Xin chào</b>" }} />;
const sanitizedComment = <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />;
const staticTemplate = <p dangerouslySetInnerHTML={{ __html: `<i>tĩnh</i>` }} />;
