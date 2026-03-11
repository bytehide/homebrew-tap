#!/usr/bin/env python3
"""Generate the Homebrew formula for shield-ios from PyPI metadata.

Usage:
    python generate-formula.py <version>

Outputs the complete Formula/shield-ios.rb to stdout.
"""

import json
import sys
import urllib.request

PACKAGE = "bytehide-shield-ios"
PYTHON_VERSION = "3.12"
PYTHON_TAG = "cp312"

SKIP_DEPS = {"setuptools", "pip", "wheel", "setuptools-scm", "cython"}


def fetch_pypi(package, version=None):
    url = f"https://pypi.org/pypi/{package}/json" if not version else f"https://pypi.org/pypi/{package}/{version}/json"
    with urllib.request.urlopen(url) as resp:
        return json.loads(resp.read())


def find_wheel(pypi_data):
    """Find the best wheel for macOS arm64 / cp312."""
    wheels = [f for f in pypi_data["urls"] if f["packagetype"] == "bdist_wheel"]
    # Priority: py3-none-any > cp37-abi3 universal2 > cp312 universal2 > cp312 arm64
    for w in wheels:
        fn = w["filename"]
        if "py3-none-any" in fn or "py2.py3-none-any" in fn:
            return w["url"], w["digests"]["sha256"]
    for w in wheels:
        fn = w["filename"]
        if "abi3" in fn and "universal2" in fn:
            return w["url"], w["digests"]["sha256"]
    for w in wheels:
        fn = w["filename"]
        if PYTHON_TAG in fn and "universal2" in fn:
            return w["url"], w["digests"]["sha256"]
    for w in wheels:
        fn = w["filename"]
        if PYTHON_TAG in fn and "arm64" in fn:
            return w["url"], w["digests"]["sha256"]
    for w in wheels:
        fn = w["filename"]
        if PYTHON_TAG in fn and "macosx" in fn:
            return w["url"], w["digests"]["sha256"]
    return None, None


def get_dependencies(pypi_data):
    deps = []
    requires = pypi_data["info"].get("requires_dist") or []
    for req in requires:
        if "extra ==" in req:
            continue
        parts = req.split(";")[0]
        for sep in "<>=!~":
            parts = parts.split(sep)[0]
        name = parts.strip().lower().replace("_", "-")
        if name not in SKIP_DEPS:
            deps.append(name)
    return deps


def resolve_all_deps(package, version):
    """Resolve direct + transitive dependencies."""
    seen = set()
    result = []
    to_visit = [(package, version)]

    while to_visit:
        pkg, ver = to_visit.pop(0)
        if pkg in seen:
            continue
        seen.add(pkg)
        data = fetch_pypi(pkg, ver)
        if pkg != package:
            url, sha = find_wheel(data)
            if url:
                result.append((pkg, url, sha))
                print(f"  {pkg} {ver}: OK", file=sys.stderr)
            else:
                print(f"  {pkg} {ver}: NO WHEEL", file=sys.stderr)
        child_deps = get_dependencies(data)
        for dep in child_deps:
            if dep not in seen:
                to_visit.append((dep, None))

    return result


def generate_formula(version):
    print(f"Fetching {PACKAGE} {version}...", file=sys.stderr)
    data = fetch_pypi(PACKAGE, version)
    main_url, main_sha = find_wheel(data)
    if not main_url:
        print("Error: no wheel found on PyPI.", file=sys.stderr)
        sys.exit(1)

    print("Resolving dependencies...", file=sys.stderr)
    resources = resolve_all_deps(PACKAGE, version)

    test_line = '    assert_match "shield-ios", shell_output("#{bin}/shield-ios --help")'

    lines = []
    lines.append('require "uri"')
    lines.append("")
    lines.append("class ShieldIos < Formula")
    lines.append("  include Language::Python::Virtualenv")
    lines.append("")
    lines.append('  desc "iOS application protection: obfuscation, encryption, and runtime security"')
    lines.append('  homepage "https://www.bytehide.com"')
    lines.append(f'  url "{main_url}"')
    lines.append(f'  sha256 "{main_sha}"')
    lines.append("  license :cannot_represent")
    lines.append("")
    lines.append(f'  depends_on "python@{PYTHON_VERSION}"')

    for name, url, sha in resources:
        lines.append("")
        lines.append(f'  resource "{name}" do')
        lines.append(f'    url "{url}"')
        lines.append(f'    sha256 "{sha}"')
        lines.append("  end")

    lines.append("")
    lines.append("  def install")
    lines.append('    virtualenv_create(libexec, "python3.12")')
    lines.append('    pip = libexec/"bin/pip"')
    lines.append("")
    lines.append('    wheel_dir = buildpath/"wheels"')
    lines.append("    wheel_dir.mkpath")
    lines.append("")
    lines.append("    resources.each do |r|")
    lines.append("      whl_name = File.basename(URI.parse(r.url).path)")
    lines.append("      cp r.cached_download, wheel_dir/whl_name")
    lines.append("    end")
    lines.append("")
    lines.append("    main_name = File.basename(URI.parse(stable.url).path)")
    lines.append("    cp cached_download, wheel_dir/main_name")
    lines.append("")
    lines.append('    system pip, "install", "--no-deps", "--ignore-installed", *Dir[wheel_dir/"*.whl"]')
    lines.append('    bin.install_symlink Dir[libexec/"bin/shield-ios"]')
    lines.append("  end")
    lines.append("")
    lines.append("  test do")
    lines.append(test_line)
    lines.append("  end")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]
    print(generate_formula(version))
