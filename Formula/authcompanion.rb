# typed: false
# frozen_string_literal: true

class Authcompanion < Formula
  desc "Set up Touch ID and Apple Watch authentication for GPG signing and sudo"
  homepage "https://github.com/CasualDeveloper/AuthCompanion"
  url "https://github.com/CasualDeveloper/AuthCompanion/releases/download/v0.1.0/authcompanion-0.1.0.tar.gz"
  sha256 "1011838a3e8b5812500bfdb6a50ecef96173a50e24c4c372f8a04fc98e851ca0"
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
        #{opt_bin}/authcompanion setup --yes

      Check both components:
        #{opt_bin}/authcompanion doctor

      Before uninstalling, restore both components:
        #{opt_bin}/authcompanion restore --yes
    EOS
  end

  test do
    companion = bin/"authcompanion"

    assert_equal "authcompanion 0.1.0", shell_output("#{companion} --version").strip
    assert_match "authcompanion setup --yes", shell_output("#{companion} --help")
    assert_match "requires explicit --yes confirmation", shell_output("#{companion} setup 2>&1", 2)
  end
end
