import unittest

from failure_analyzer import extract_safe_diagnostics, redact_line


class FailureAnalyzerTests(unittest.TestCase):
    def test_redacts_credentials_tokens_and_connection_urls(self):
        line = (
            "Error: connection failed POSTGRES_PASSWORD=local-only "
            "Authorization: Bearer abc.def "
            "https://user:local-only@example.invalid/path?token=local-only"
        )

        safe = redact_line(line)

        self.assertNotIn("local-only", safe)
        self.assertNotIn("abc.def", safe)
        self.assertIn("<redacted>", safe)

    def test_extracts_only_diagnostics_and_omits_environment_assignments(self):
        logs = (
            "DATABASE_URL=postgres://user:password@db/app\n"
            "ordinary build output\n"
            "ERROR: migration failed for DB_PASSWORD=local-only\n"
        )

        safe = extract_safe_diagnostics(logs)

        self.assertIn("migration failed", safe)
        self.assertNotIn("ordinary build output", safe)
        self.assertNotIn("DATABASE_URL", safe)
        self.assertNotIn("local-only", safe)

    def test_private_key_blocks_are_never_included(self):
        logs = (
            "Error: signing failed\n"
            "-----BEGIN PRIVATE KEY-----\n"
            "sensitive-material\n"
            "-----END PRIVATE KEY-----\n"
            "Build failed with exit code 1\n"
        )

        safe = extract_safe_diagnostics(logs)

        self.assertIn("signing failed", safe)
        self.assertIn("Build failed", safe)
        self.assertNotIn("sensitive-material", safe)

    def test_diagnostics_are_bounded(self):
        safe = extract_safe_diagnostics("Error: " + ("x" * 20000), max_chars=500)

        self.assertLessEqual(len(safe), 500)


if __name__ == "__main__":
    unittest.main()
