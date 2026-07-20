# typed: false
# frozen_string_literal: true

class PamCompanion < Formula
  desc "Authenticate macOS sudo with Touch ID or a companion device"
  homepage "https://github.com/CasualDeveloper/pam-companion"
  url "https://github.com/CasualDeveloper/pam-companion/releases/download/v0.1.0/pam-companion-0.1.0.tar.gz"
  sha256 "1d0c52cfbd2d37bce3a92ddccaab3018248ef0af06116c5e00ba5c7871cc1729"
  license "Unlicense"

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
