"""Failure-path tests for the release boundary; no GitHub mutations/network."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import zipfile

import release


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.data = {"version": "0.4.2", "title": "Test", "notes": "notes.md", "prerelease": True}
        self.sha = "a" * 40
        self.repo = "owner/game"
        archive, checksum, preview = release.names(self.data)
        with zipfile.ZipFile(self.directory / archive, "w") as package:
            for name in ["ChiefsOfWar.exe", "README.txt", "Combat-Practice.bat", "THIRD_PARTY_NOTICES.txt"]:
                package.writestr(name, "test fixture")
            package.writestr("BUILD.txt", f"Source commit: {self.sha}\n")
        digest = hashlib.sha256((self.directory / archive).read_bytes()).hexdigest()
        (self.directory / checksum).write_text(f"{digest}  {archive}\n")
        (self.directory / preview).write_bytes(b"\x89PNG\r\n\x1a\nfixture")
        self.draft = {"tag_name": "v0.4.2", "target_commitish": self.sha, "draft": True, "html_url": "https://github.com/owner/game/releases/tag/v0.4.2", "assets": []}
        self.public = {**self.draft, "draft": False}

    def test_package_checksum_and_source(self):
        self.assertEqual(len(release.validate_files(self.directory, self.data, self.sha)), 3)
        with self.assertRaisesRegex(ValueError, "source commit"):
            release.validate_files(self.directory, self.data, "b" * 40)

    def test_corrupt_archive_rejected(self):
        (self.directory / release.names(self.data)[0]).write_bytes(b"truncated")
        with self.assertRaisesRegex(ValueError, "checksum"):
            release.validate_files(self.directory, self.data, self.sha)

    def test_empty_package_file_rejected(self):
        archive, checksum, _ = release.names(self.data)
        with zipfile.ZipFile(self.directory / archive, "w") as package:
            package.writestr("ChiefsOfWar.exe", "")
        digest = hashlib.sha256((self.directory / archive).read_bytes()).hexdigest()
        (self.directory / checksum).write_text(f"{digest}  {archive}\n")
        with self.assertRaisesRegex(ValueError, "incomplete"):
            release.validate_files(self.directory, self.data, self.sha)

    def test_missing_asset_prevents_publication(self):
        (self.directory / "creator.png").unlink()
        with patch.object(release, "find_release", return_value=None), patch.object(release, "gh") as gh:
            with self.assertRaisesRegex(ValueError, "missing/empty"):
                release.publish(self.repo, self.sha, self.data, self.directory)
            gh.assert_not_called()

    def test_lookup_failure_never_creates_release(self):
        with patch.object(release, "gh", side_effect=RuntimeError("403 Forbidden")) as gh:
            with self.assertRaisesRegex(RuntimeError, "403"):
                release.publish(self.repo, self.sha, self.data, self.directory)
            self.assertEqual(gh.call_count, 1)
            self.assertEqual(gh.call_args.args[0], "api")

    def test_draft_lookup_includes_multiple_pages(self):
        with patch.object(release, "gh", return_value=json.dumps([[], [self.draft]])):
            self.assertEqual(release.find_release(self.repo, "v0.4.2"), self.draft)

    def test_source_conflict_never_mutates(self):
        with patch.object(release, "find_release", return_value=self.public), patch.object(release, "gh") as gh:
            with self.assertRaisesRegex(ValueError, "another source"):
                release.publish(self.repo, "b" * 40, self.data, self.directory)
            gh.assert_not_called()

    def test_completed_retry_only_verifies(self):
        with patch.object(release, "find_release", return_value=self.public), patch.object(release, "verify_remote") as verify, patch.object(release, "gh") as gh:
            self.assertEqual(release.publish(self.repo, self.sha, self.data, self.directory), self.public["html_url"])
            verify.assert_called_once()
            gh.assert_not_called()

    def test_new_release_draft_upload_verify_publish_order(self):
        events = []
        with patch.object(release, "find_release", side_effect=[None, self.draft, self.public]), patch.object(release, "verify_remote", side_effect=lambda *a: events.append("verify")), patch.object(release, "gh", side_effect=lambda *a: events.append(a)):
            release.publish(self.repo, self.sha, self.data, self.directory)
        self.assertEqual(events[0][:2], ("release", "create"))
        self.assertIn("--draft", events[0])
        self.assertEqual(events[1][:2], ("release", "upload"))
        self.assertEqual(events[2], "verify")
        self.assertIn("--draft=false", events[3])
        self.assertEqual(events[4], "verify")

    def test_failed_upload_stays_draft(self):
        with patch.object(release, "find_release", return_value=self.draft), patch.object(release, "gh", side_effect=RuntimeError("upload timeout")) as gh:
            with self.assertRaisesRegex(RuntimeError, "timeout"):
                release.publish(self.repo, self.sha, self.data, self.directory)
            self.assertEqual(gh.call_count, 1)
            self.assertEqual(gh.call_args.args[:2], ("release", "upload"))

    def test_failed_download_verification_stays_draft(self):
        with patch.object(release, "find_release", return_value=self.draft), patch.object(release, "verify_remote", side_effect=ValueError("bad checksum")), patch.object(release, "gh") as gh:
            with self.assertRaisesRegex(ValueError, "checksum"):
                release.publish(self.repo, self.sha, self.data, self.directory)
            self.assertEqual(gh.call_count, 1)
            self.assertEqual(gh.call_args.args[:2], ("release", "upload"))

    def test_partial_draft_resumes_without_duplicate(self):
        with patch.object(release, "find_release", side_effect=[self.draft, self.draft, self.public]), patch.object(release, "verify_remote"), patch.object(release, "gh") as gh:
            release.publish(self.repo, self.sha, self.data, self.directory)
            self.assertEqual([call.args[1] for call in gh.call_args_list], ["upload", "edit"])
            self.assertIn("--clobber", gh.call_args_list[0].args)

    def test_remote_empty_release_rejected_before_download(self):
        with patch.object(release, "gh") as gh:
            with self.assertRaisesRegex(ValueError, "missing/incomplete"):
                release.verify_remote(self.repo, self.public, self.data, self.sha)
            gh.assert_not_called()

    def test_remote_download_checks_bytes(self):
        assets = []
        for path in self.directory.iterdir():
            assets.append({"name": path.name, "state": "uploaded", "size": path.stat().st_size, "digest": "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()})
        remote = {**self.public, "assets": assets}

        def download(*args):
            dest = Path(args[args.index("--dir") + 1])
            for path in self.directory.iterdir():
                (dest / path.name).write_bytes(path.read_bytes())

        with patch.object(release, "gh", side_effect=download):
            release.verify_remote(self.repo, remote, self.data, self.sha)
            remote["assets"][0]["digest"] = "sha256:bad"
            with self.assertRaisesRegex(ValueError, "digest mismatch"):
                release.verify_remote(self.repo, remote, self.data, self.sha)


if __name__ == "__main__":
    unittest.main()
