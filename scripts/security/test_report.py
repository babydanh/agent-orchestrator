import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

import report


class SecurityReportTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.rd = Path(self.tmp.name)
        self.args = SimpleNamespace(owner='owner', repo='Backend', target='backend', ref='main',
                                    sha='a' * 40, reports=self.rd)

    def write(self, name, value):
        (self.rd / name).write_text(json.dumps(value), encoding='utf-8')

    def test_missing_reports_are_infrastructure_errors_even_with_zero_exit(self):
        for tool, scan in [('gitleaks', report.scan_gitleaks), ('osv', report.scan_osv), ('semgrep', report.scan_semgrep)]:
            with self.subTest(tool=tool):
                (self.rd / f'{tool}.exit').write_text('0')
                self.assertEqual(scan(self.rd, self.rd)['status'], report.INFRA)

    def test_scanner_failure_is_not_clean_or_a_finding(self):
        (self.rd / 'gitleaks.exit').write_text('124')
        self.assertEqual(report.scan_gitleaks(self.rd, self.rd)['status'], report.INFRA)

    def test_gitleaks_findings_never_echo_secret_or_code(self):
        (self.rd / 'gitleaks.exit').write_text('0')
        self.write('gitleaks.json', [{'RuleID': 'fake-rule', 'File': 'src/a.ts', 'StartLine': 7,
                                     'Secret': 'DO_NOT_PUBLISH_FAKE_SECRET', 'Match': 'PRIVATE_CODE_SNIPPET'}])
        scan = report.scan_gitleaks(self.rd, self.rd)
        self.assertEqual(scan['status'], report.FINDINGS)
        body = report.build_body(self.args, [scan])
        self.assertIn('src/a.ts', body)
        self.assertNotIn('DO_NOT_PUBLISH_FAKE_SECRET', body)
        self.assertNotIn('PRIVATE_CODE_SNIPPET', body)

    def test_empty_semgrep_coverage_is_not_clean(self):
        (self.rd / 'semgrep.exit').write_text('0')
        self.write('semgrep.json', {'results': [], 'errors': [], 'paths': {'scanned': []}})
        self.assertEqual(report.scan_semgrep(self.rd, self.rd)['status'], report.INFRA)

    def test_public_target_routes_findings_only_to_verified_private_repo(self):
        scans = [report.result('scanner', report.FINDINGS, rows=[{'rule': 'check', 'file': 'a.ts'}])]
        with patch.object(report, 'gh', side_effect=[(0, 'false'), (0, 'true'), (0, '[]'),
                                                   (0, 'https://github.com/owner/omp-global-config/issues/1')]) as api:
            _, infra = report.sync_issue(self.args, scans, 'fake-token')
        self.assertFalse(infra)
        create = api.call_args_list[-1].args[0]
        self.assertEqual(create[create.index('--repo') + 1], 'owner/omp-global-config')
        self.assertIn('Backend', create[create.index('--title') + 1])

    def test_public_fallback_repo_is_rejected_without_publishing(self):
        scans = [report.result('scanner', report.FINDINGS)]
        with patch.object(report, 'gh', side_effect=[(0, 'false'), (0, 'false')]) as api:
            _, infra = report.sync_issue(self.args, scans, 'fake-token')
        self.assertTrue(infra)
        self.assertEqual(api.call_count, 2)

    def test_private_target_keeps_its_report_in_its_own_repo(self):
        self.args.repo = 'Web'
        scans = [report.result('scanner', report.FINDINGS)]
        with patch.object(report, 'gh', side_effect=[(0, 'true'), (0, '[]'),
                                                   (0, 'https://github.com/owner/Web/issues/1')]) as api:
            _, infra = report.sync_issue(self.args, scans, 'fake-token')
        self.assertFalse(infra)
        create = api.call_args_list[-1].args[0]
        self.assertEqual(create[create.index('--repo') + 1], 'owner/Web')


if __name__ == '__main__':
    unittest.main()
