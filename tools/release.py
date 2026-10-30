"""Publish through GitHub Actions; never leave an empty release public.

Uses the runner's gh/GH_TOKEN. No tokens, binaries or browser uploads cross chat.
An interrupted draft can be resumed. A published release is only verified.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import zipfile


def gh(*args):
    result = subprocess.run(["gh", *args], text=True, capture_output=True, timeout=300)
    if result.returncode:
        raise RuntimeError(f"gh {args[0]} failed: {result.stderr.strip()}")
    return result.stdout


def manifest():
    data = json.loads(Path("release.json").read_text())
    version = data["version"]
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError("release.json version must be X.Y.Z")
    project_version = re.search(r'^config/version="([^"]+)"', Path("project.godot").read_text(), re.M)
    if not project_version or not (project_version[1] == version or project_version[1].startswith(version + "-")):
        raise ValueError("release.json and project.godot versions disagree")
    if not isinstance(data["prerelease"], bool) or not data["title"].strip():
        raise ValueError("Release requires a title and boolean prerelease")
    if not Path(data["notes"]).is_file():
        raise ValueError("Release notes are missing")
    return data


def names(data):
    return (f"Chiefs-of-War-{data['version']}-Windows.zip", f"SHA256SUMS-{data['version']}.txt", "creator.png")


def find_release(repo, tag):
    # List drafts as well as public releases. Auth/network failures must not be
    # interpreted as "release missing", which would cause duplicate mutations.
    pages = json.loads(gh("api", "--paginate", "--slurp", f"repos/{repo}/releases?per_page=100"))
    return next((r for page in pages for r in page if r["tag_name"] == tag), None)


def same_source(release, sha):
    if release["target_commitish"] != sha:
        raise ValueError("This version already belongs to another source commit. Choose a new version; do not overwrite it.")


def validate_files(directory, data, sha):
    archive_name, checksum_name, preview_name = names(data)
    paths = [directory / name for name in names(data)]
    if any(not p.is_file() or p.stat().st_size == 0 for p in paths):
        raise ValueError("Windows ZIP, checksum or preview is missing/empty")
    archive = directory / archive_name
    checksum = (directory / checksum_name).read_text().split()
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    if checksum != [digest, archive_name]:
        raise ValueError("Windows ZIP checksum mismatch")
    with zipfile.ZipFile(archive) as package:
        required = {"ChiefsOfWar.exe", "README.txt", "Combat-Practice.bat", "BUILD.txt", "THIRD_PARTY_NOTICES.txt"}
        if not required.issubset(package.namelist()) or package.testzip():
            raise ValueError("Windows ZIP is incomplete/corrupt")
        if any(package.getinfo(name).file_size == 0 for name in required):
            raise ValueError("Windows ZIP contains an empty required file")
        if f"Source commit: {sha}\n" not in package.read("BUILD.txt").decode():
            raise ValueError("Packaged source commit does not match the requested release")
    if not (directory / preview_name).read_bytes().startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("Preview is not a PNG")
    return paths


def verify_remote(repo, release, data, sha):
    same_source(release, sha)
    assets = {a["name"]: a for a in release["assets"]}
    for name in names(data):
        if name not in assets or assets[name]["state"] != "uploaded" or assets[name]["size"] <= 0:
            raise ValueError(f"Release asset missing/incomplete: {name}")
    with tempfile.TemporaryDirectory() as tmp:
        args = ["release", "download", release["tag_name"], "--repo", repo, "--dir", tmp]
        for name in names(data):
            args += ["--pattern", name]
        gh(*args)
        for path in validate_files(Path(tmp), data, sha):
            asset = assets[path.name]
            if path.stat().st_size != asset["size"]:
                raise ValueError(f"Downloaded size mismatch: {path.name}")
            digest = "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()
            if asset.get("digest") and asset["digest"] != digest:
                raise ValueError(f"Downloaded digest mismatch: {path.name}")


def publish(repo, sha, data, directory):
    tag = "v" + data["version"]
    release = find_release(repo, tag)
    if release:
        same_source(release, sha)
        if not release["draft"]:
            verify_remote(repo, release, data, sha)
            return release["html_url"]  # An already-published retry is read-only.
    paths = validate_files(directory, data, sha)
    if not release:
        args = ["release", "create", tag, "--repo", repo, "--target", sha, "--title", data["title"], "--notes-file", data["notes"], "--draft"]
        if data["prerelease"]:
            args.append("--prerelease")
        gh(*args)
    # Retry may replace only a draft's assets, never an existing public build.
    gh("release", "upload", tag, *(str(p) for p in paths), "--repo", repo, "--clobber")
    release = find_release(repo, tag)
    verify_remote(repo, release, data, sha)
    gh("release", "edit", tag, "--repo", repo, "--draft=false")
    release = find_release(repo, tag)
    if release["draft"]:
        raise ValueError("GitHub still reports a draft; publication did not finish")
    verify_remote(repo, release, data, sha)
    return release["html_url"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["prepare", "publish", "verify"])
    args = parser.parse_args()
    data = manifest()
    sha = os.environ["GITHUB_SHA"]
    repo = os.environ["GITHUB_REPOSITORY"]
    if not re.fullmatch(r"[0-9a-f]{40}", sha):
        raise ValueError("A full source commit SHA is required")
    if args.command == "publish":
        print(publish(repo, sha, data, Path("builds")))
        return
    if args.command == "verify":
        existing = find_release(repo, "v" + data["version"])
        if existing and not existing["draft"]:
            verify_remote(repo, existing, data, existing["target_commitish"])
            print("Existing published version verified (no writes): " + existing["html_url"])
        else:
            print("No published version to audit. This does not establish release completion.")
        return
    ref = os.environ.get("GITHUB_REF_NAME", "")
    publishing = ref.startswith("release/v") or os.environ.get("PUBLISH_REQUESTED") == "true"
    if ref.startswith("release/v") and ref != "release/v" + data["version"]:
        raise ValueError("Release branch and release.json version disagree")
    complete = False
    if publishing:
        release = find_release(repo, "v" + data["version"])
        if release:
            same_source(release, sha)
            if not release["draft"]:
                verify_remote(repo, release, data, sha)
                complete = True
                print("Already published and downloads verified: " + release["html_url"])
    with open(os.environ["GITHUB_OUTPUT"], "a") as output:
        output.write(f"version={data['version']}\npublish={str(publishing).lower()}\ncomplete={str(complete).lower()}\n")


if __name__ == "__main__":
    main()
