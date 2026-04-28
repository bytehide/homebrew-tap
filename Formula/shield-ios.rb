require "uri"

class ShieldIos < Formula
  include Language::Python::Virtualenv

  desc "iOS application protection: obfuscation, encryption, and runtime security"
  homepage "https://www.bytehide.com"
  url "https://files.pythonhosted.org/packages/46/25/e36b66ee0bac9fd69461c5db64505eb405f24ec55a6aad151f181c33257e/bytehide_shield_ios-1.0.10-cp312-cp312-macosx_11_0_universal2.whl"
  sha256 "fc50917ad3d72cb21cfd51ce2975ad03c27a6010172479becfb2890a02b7a46c"
  license :cannot_represent

  depends_on "python@3.12"

  resource "lief" do
    url "https://files.pythonhosted.org/packages/1f/29/e7a0dabcb853867da70fda2b397012dd3d9ef4994ab7e8bd21f248bea64b/lief-0.17.6-cp312-cp312-macosx_11_0_arm64.whl"
    sha256 "c5a19642e42578fe0b701bd86b10dd7e86d69c35c67d25ac1433f72410a7c2bb"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/ae/44/c1221527f6a71a01ec6fbad7fa78f1d50dfa02217385cf0fa3eec7087d59/click-8.3.3-py3-none-any.whl"
    sha256 "a2bf429bb3033c89fa4936ffb35d5cb471e3719e1f3c8a7c3fff0b8314305613"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/89/a0/6cf41a19a1f2f3feab0e9c0b74134aa2ce6849093d5517a0c550fe37a648/pyyaml-6.0.3-cp312-cp312-macosx_11_0_arm64.whl"
    sha256 "fc09d0aa354569bc501d4e787133afc08552722d3ab34836a80547331bb5d4a0"
  end

  resource "colorama" do
    url "https://files.pythonhosted.org/packages/d1/d6/3965ed04c63042e047cb6a3e6ed1a63a35087b6a609aa3a15ed8ac56c221/colorama-0.4.6-py2.py3-none-any.whl"
    sha256 "4f1d9991f5acc0ca119f9d443620b77f9d6b33703e51011c16baf57afb285fc6"
  end

  resource "pycryptodome" do
    url "https://files.pythonhosted.org/packages/db/6c/a1f71542c969912bb0e106f64f60a56cc1f0fabecf9396f45accbe63fa68/pycryptodome-3.23.0-cp37-abi3-macosx_10_9_universal2.whl"
    sha256 "187058ab80b3281b1de11c2e6842a357a1f71b42cb1e15bce373f3d238135c27"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/d7/8e/7540e8a2036f79a125c1d2ebadf69ed7901608859186c856fa0388ef4197/requests-2.33.1-py3-none-any.whl"
    sha256 "4e6d1ef462f3626a1f0a0a9c42dd93c63bad33f9f1c1937509b8c5c8718ab56a"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/39/08/aaaad47bc4e9dc8c725e68f9d04865dbcb2052843ff09c97b08904852d84/urllib3-2.6.3-py3-none-any.whl"
    sha256 "bf272323e553dfb2e87d9bfd225ca7b0f467b919d7bbd355436d3fd37cb0acd4"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/db/8f/61959034484a4a7c527811f4721e75d02d653a35afb0b6054474d8185d4c/charset_normalizer-3.4.7-py3-none-any.whl"
    sha256 "3dce51d0f5e7951f8bb4900c257dad282f49190fdbebecd4ba99bcc41fef404d"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/5d/13/ad7d7ca3808a898b4612b6fe93cde56b53f3034dcde235acb1f0e1df24c6/idna-3.13-py3-none-any.whl"
    sha256 "892ea0cde124a99ce773decba204c5552b69c3c67ffd5f232eb7696135bc8bb3"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/22/30/7cd8fdcdfbc5b869528b079bfb76dcdf6056b1a2097a662e5e8c04f42965/certifi-2026.4.22-py3-none-any.whl"
    sha256 "3cb2210c8f88ba2318d29b0388d1023c8492ff72ecdde4ebdaddbb13a31b1c4a"
  end

  def install
    virtualenv_create(libexec, "python3.12")
    python = libexec/"bin/python"

    wheel_dir = buildpath/"wheels"
    wheel_dir.mkpath

    resources.each do |r|
      whl_name = File.basename(URI.parse(r.url).path)
      cp r.cached_download, wheel_dir/whl_name
    end

    main_name = File.basename(URI.parse(stable.url).path)
    cp cached_download, wheel_dir/main_name

    system python, "-m", "pip", "install", "--no-deps", "--ignore-installed", *Dir[wheel_dir/"*.whl"]
    bin.install_symlink Dir[libexec/"bin/shield-ios"]
  end

  test do
    assert_match "shield-ios", shell_output("#{bin}/shield-ios --help")
  end
end

