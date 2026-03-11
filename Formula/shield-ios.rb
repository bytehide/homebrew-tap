require "uri"

class ShieldIos < Formula
  include Language::Python::Virtualenv

  desc "iOS application protection: obfuscation, encryption, and runtime security"
  homepage "https://www.bytehide.com"
  url "https://files.pythonhosted.org/packages/eb/1e/e0c17f84eaede0f5bdff454db32d5f8e2b53b2f1680c551d09a925a81cc7/bytehide_shield_ios-1.0.7-cp312-cp312-macosx_11_0_universal2.whl"
  sha256 "623c07948940bd1bb8f8947068d513155d740685f30ca2bcef4a065798f70673"
  license :cannot_represent

  depends_on "python@3.12"

  resource "lief" do
    url "https://files.pythonhosted.org/packages/86/19/d4777f22af38391ae149cb32444fe0cc5b6b6bdd42a1168fea487834b200/lief-0.17.5-cp312-cp312-macosx_11_0_arm64.whl"
    sha256 "386651db9a6697da3f856a1fce6234adad4bae28aba54449ca9998af63f9c635"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/98/78/01c019cdb5d6498122777c1a43056ebb3ebfeef2076d9d026bfe15583b2b/click-8.3.1-py3-none-any.whl"
    sha256 "981153a64e25f12d547d3426c367a4857371575ee7ad18df2a6183ab0545b2a6"
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
    url "https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl"
    sha256 "2462f94637a34fd532264295e186976db0f5d453d1cdd31473c85a6a161affb6"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/39/08/aaaad47bc4e9dc8c725e68f9d04865dbcb2052843ff09c97b08904852d84/urllib3-2.6.3-py3-none-any.whl"
    sha256 "bf272323e553dfb2e87d9bfd225ca7b0f467b919d7bbd355436d3fd37cb0acd4"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/9c/b6/9ee9c1a608916ca5feae81a344dffbaa53b26b90be58cc2159e3332d44ec/charset_normalizer-3.4.5-cp312-cp312-macosx_10_13_universal2.whl"
    sha256 "ed97c282ee4f994ef814042423a529df9497e3c666dca19be1d4cd1129dc7ade"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/0e/61/66938bbb5fc52dbdf84594873d5b51fb1f7c7794e9c0f5bd885f30bc507b/idna-3.11-py3-none-any.whl"
    sha256 "771a87f49d9defaf64091e6e6fe9c18d4833f140bd19464795bc32d966ca37ea"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/9a/3c/c17fb3ca2d9c3acff52e30b309f538586f9f5b9c9cf454f3845fc9af4881/certifi-2026.2.25-py3-none-any.whl"
    sha256 "027692e4402ad994f1c42e52a4997a9763c646b73e4096e4d5d6db8af1d6f0fa"
  end

  def install
    virtualenv_create(libexec, "python3.12")
    pip = libexec/"bin/pip"

    # Install wheels directly (bypass Homebrew's --no-binary flag)
    wheel_dir = buildpath/"wheels"
    wheel_dir.mkpath

    resources.each do |r|
      whl_name = File.basename(URI.parse(r.url).path)
      cp r.cached_download, wheel_dir/whl_name
    end

    main_name = File.basename(URI.parse(stable.url).path)
    cp cached_download, wheel_dir/main_name

    system pip, "install", "--no-deps", "--ignore-installed", *Dir[wheel_dir/"*.whl"]
    bin.install_symlink Dir[libexec/"bin/shield-ios"]
  end

  test do
    assert_match "shield-ios", shell_output("#{bin}/shield-ios --help")
  end
end
