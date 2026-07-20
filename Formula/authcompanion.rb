# typed: false
# frozen_string_literal: true

class Authcompanion < Formula
  desc "Set up Touch ID and Apple Watch authentication for GPG signing and sudo"
  homepage "https://github.com/CasualDeveloper/AuthCompanion"
  url "https://github.com/CasualDeveloper/AuthCompanion/releases/download/v0.1.1/authcompanion-0.1.1.tar.gz"
  sha256 "3597dd380e1c88ba35b6af6d3e37af3c069d6443c70941e49efbd5660b0fc085"
  license "Apache-2.0"

  depends_on macos: :sonoma
  depends_on "pam-companion"
  depends_on "pinentry-companion"

  def install
    bin.install "bin/authcompanion"
  end

  def caveats
    <<~EOS
      Review the combined GPG and PAM plan, then apply it explicitly:
        #{opt_bin}/authcompanion plan
        sudo -v
        #{opt_bin}/authcompanion setup --yes

      Check both components:
        sudo -v
        #{opt_bin}/authcompanion doctor

      Before uninstalling, restore both components:
        sudo -v
        #{opt_bin}/authcompanion restore --yes
    EOS
  end

  test do
    companion = bin/"authcompanion"

    assert_equal "authcompanion 0.1.1", shell_output("#{companion} --version").strip
    assert_match "authcompanion setup --yes", shell_output("#{companion} --help")
    assert_match "requires explicit --yes confirmation", shell_output("#{companion} setup 2>&1", 2)
  end
end
