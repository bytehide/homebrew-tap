class ShieldIos < Formula
  include Language::Python::Virtualenv

  desc "iOS application protection: obfuscation, encryption, and runtime security"
  homepage "https://www.bytehide.com"
  url "https://files.pythonhosted.org/packages/eb/1e/e0c17f84eaede0f5bdff454db32d5f8e2b53b2f1680c551d09a925a81cc7/bytehide_shield_ios-1.0.7-cp312-cp312-macosx_11_0_universal2.whl"
  sha256 "623c07948940bd1bb8f8947068d513155d740685f30ca2bcef4a065798f70673"
  license :cannot_represent

  depends_on "python@3.12"

  resource "lief" do
    url "https://files.pythonhosted.org/packages/8f/d2/96fe1d90bb74161f3dd9f2b131f64ed36b12178a035d3b6568390f160fac/lief-0.17.5.tar.gz"
    sha256 "a0b7ece5694be14aafa180fb4f2f3008e0e34be03d2649ed8128f22830b37525"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/3d/fa/656b739db8587d7b5dfa22e22ed02566950fbfbcdc20311993483657a5c0/click-8.3.1.tar.gz"
    sha256 "12ff4785d337a1bb490bb7e9c2b1ee5da3112e94a8622f26a6c77f5d2fc6842a"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  resource "colorama" do
    url "https://files.pythonhosted.org/packages/d8/53/6f443c9a4a8358a93a6792e2acffb9d9d5cb0a5cfd8802644b7b1c9a02e4/colorama-0.4.6.tar.gz"
    sha256 "08695f5cb7ed6e0531a20572697297273c47b8cae5a63ffc6d6ed5c201be6e44"
  end

  resource "pycryptodome" do
    url "https://files.pythonhosted.org/packages/8e/a6/8452177684d5e906854776276ddd34eca30d1b1e15aa1ee9cefc289a33f5/pycryptodome-3.23.0.tar.gz"
    sha256 "447700a657182d60338bab09fdb27518f8856aecd80ae4c6bdddb67ff5da44ef"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/c9/74/b3ff8e6c8446842c3f5c837e9c3dfcfe2018ea6ecef224c710c85ef728f4/requests-2.32.5.tar.gz"
    sha256 "dbba0bac56e100853db0ea71b82b4dfd5fe2bf6d3754a8893c3af500cec7d7cf"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/c7/24/5f1b3bdffd70275f6661c76461e25f024d5a38a46f04aaca912426a2b1d3/urllib3-2.6.3.tar.gz"
    sha256 "1b62b6884944a57dbe321509ab94fd4d3b307075e0c2eae991ac71ee15ad38ed"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "shield-ios", shell_output("#{bin}/shield-ios --help")
  end
end

