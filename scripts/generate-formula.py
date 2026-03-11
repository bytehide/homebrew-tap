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
PYTHON_DEP = "python@3.12"

# Dependencies that are already part of Python stdlib or Homebrew Python
SKIP_DEPS = {
    "setuptools",
    "pip",
    "wheel",
    "setuptools-scm",
    "cython",
}


def fetch_pypi_info(package, version):
    """Fetch package info from PyPI JSON API."""
    url = f"https://pypi.org/pypi/{package}/{version}/json"
    with urllib.request.urlopen(url) as resp:
        return json.loads(resp.read())


def find_sdist(pypi_data):
    """Find the sdist (.tar.gz) URL and sha256."""
    for f in pypi_data["urls"]:
        if f["packagetype"] == "sdist":
            return f["url"], f["digests"]["sha256"]
    return None, None


def get_dependencies(pypi_data):
    """Extract direct dependencies from requires_dist."""
    deps = []
    requires = pypi_data["info"].get("requires_dist") or []
    for req in requires:
        # Skip extras and markers like ; extra == "dev"
        if "extra ==" in req:
            continue
        # Parse package name (before any version specifier)
        parts = req.split(";")[0]
        for sep in "<>=!~":
            parts = parts.split(sep)[0]
        name = parts.strip()
        name_normalized = name.lower().replace("_", "-")
        if name_normalized not in SKIP_DEPS:
            deps.append(name_normalized)
    return deps


def fetch_sdist_for_dep(package):
    """Fetch the latest sdist URL and sha256 for a dependency."""
    url = f"https://pypi.org/pypi/{package}/json"
    try:
        with urllib.request.urlopen(url) as resp:
            data = json.loads(resp.read())
        sdist_url, sha = find_sdist(data)
        if sdist_url:
            return package, sdist_url, sha
    except Exception as e:
        print(f"  Warning: could not fetch {package}: {e}", file=sys.stderr)
    return package, None, None


def generate_formula(version):
    """Generate the complete Homebrew formula."""
    print(f"Fetching {PACKAGE} {version} from PyPI...", file=sys.stderr)
    pypi_data = fetch_pypi_info(PACKAGE, version)

    sdist_url, sdist_sha = find_sdist(pypi_data)
    if not sdist_url:
        print("Error: no sdist found on PyPI for this version.", file=sys.stderr)
        print("Falling back to wheel...", file=sys.stderr)
        # Try wheel
        for f in pypi_data["urls"]:
            if f["packagetype"] == "bdist_wheel":
                sdist_url = f["url"]
                sdist_sha = f["digests"]["sha256"]
                break
        if not sdist_url:
            print("Error: no distribution found on PyPI.", file=sys.stderr)
            sys.exit(1)

    deps = get_dependencies(pypi_data)
    print(f"Dependencies: {deps}", file=sys.stderr)

    # Fetch resource info for each dependency
    resources = []
    for dep in deps:
        name, url, sha = fetch_sdist_for_dep(dep)
        if url:
            resources.append((name, url, sha))
            print(f"  {name}: OK", file=sys.stderr)
        else:
            print(f"  {name}: SKIPPED (no sdist)", file=sys.stderr)

    # Generate formula
    formula = f'''class ShieldIos < Formula
  include Language::Python::Virtualenv

  desc "iOS application protection: obfuscation, encryption, and runtime security"
  homepage "https://www.bytehide.com"
  url "{sdist_url}"
  sha256 "{sdist_sha}"
  license :cannot_represent

  depends_on "python@3.12"
'''

    for name, url, sha in resources:
        formula += f'''
  resource "{name}" do
    url "{url}"
    sha256 "{sha}"
  end
'''

    test_line = '    assert_match "shield-ios", shell_output("#{bin}/shield-ios --help")'
    formula += "\n"
    formula += "  def install\n"
    formula += "    virtualenv_install_with_resources\n"
    formula += "  end\n"
    formula += "\n"
    formula += "  test do\n"
    formula += test_line + "\n"
    formula += "  end\n"
    formula += "end\n"

    return formula


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]
    print(generate_formula(version))
