class ShieldIos < Formula
  desc "iOS application protection: obfuscation, encryption, and runtime security"
  homepage "https://www.bytehide.com"
  url "https://pypi.org/simple/bytehide-shield-ios/"
  version "1.0.7"
  license :cannot_represent

  depends_on "python@3.12"

  def install
    virtualenv_create(libexec, "python3.12")
    system libexec/"bin/pip", "install", "bytehide-shield-ios==#{version}"
    bin.install_symlink Dir[libexec/"bin/shield-ios"]
  end

  test do
    assert_match "shield-ios", shell_output("#{bin}/shield-ios --help")
  end
end
