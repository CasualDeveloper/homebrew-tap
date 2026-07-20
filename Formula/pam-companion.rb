# typed: false
# frozen_string_literal: true

class PamCompanion < Formula
  desc "Authenticate macOS sudo with Touch ID or a companion device"
  homepage "https://github.com/CasualDeveloper/pam-companion"
  url "https://github.com/CasualDeveloper/pam-companion/releases/download/v0.1.0/pam-companion-0.1.0.tar.gz"
  sha256 "91a2db9def9dd653cf8c5fceefe69cd3f95af70aeb4fbe2da11e1783f9118a3f"
  license "Apache-2.0"

  depends_on macos: :sonoma

  def install
    bin.install "bin/pam-companion"
    libexec.install "libexec/pam_companion.so"
  end

  def caveats
    <<~EOS
      Review the planned PAM change, then enable it explicitly:
        sudo #{opt_bin}/pam-companion setup --dry-run
        sudo #{opt_bin}/pam-companion setup

      Before uninstalling, restore the previous PAM configuration:
        sudo #{opt_bin}/pam-companion uninstall --prepare
    EOS
  end

  test do
    companion = bin/"pam-companion"
    assert_equal "pam-companion 0.1.0", shell_output("#{companion} --version").strip
    assert_match "status", shell_output("#{companion} --help")
  end
end
