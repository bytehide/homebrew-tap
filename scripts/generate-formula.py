#!/usr/bin/env python3
"""Generate the Homebrew formula for shield-ios.

Usage:
    python generate-formula.py <version>

Outputs the complete Formula/shield-ios.rb to stdout.
"""

import sys


def generate_formula(version):
    test_line = '    assert_match "shield-ios", shell_output("#{bin}/shield-ios --help")'

    formula = f'''class ShieldIos < Formula
  desc "iOS application protection: obfuscation, encryption, and runtime security"
  homepage "https://www.bytehide.com"
  url "https://pypi.org/simple/bytehide-shield-ios/"
  version "{version}"
  license :cannot_represent

  depends_on "python@3.12"

  def install
    virtualenv_create(libexec, "python3.12")
    system libexec/"bin/pip", "install", "bytehide-shield-ios==#{{version}}"
    bin.install_symlink Dir[libexec/"bin/shield-ios"]
  end

  test do
{test_line}
  end
end
'''
    return formula


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]
    print(generate_formula(version))
