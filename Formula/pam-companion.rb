# typed: false
# frozen_string_literal: true

class PamCompanion < Formula
  desc "Authenticate macOS sudo with Touch ID or a companion device"
  homepage "https://github.com/CasualDeveloper/pam-companion"
  url "https://github.com/CasualDeveloper/pam-companion/releases/download/v0.1.1/pam-companion-0.1.1.tar.gz"
  sha256 "39b824b63fcee0c2a5f5a3f1dafebadb343c495358ea93cf25daab2aeaac6f28"
  license "Apache-2.0"

  depends_on macos: :sonoma

  def install
    bin.install "bin/pam-companion"
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
    assert_equal "pam-companion 0.1.1", shell_output("#{companion} --version").strip
    assert_match "status", shell_output("#{companion} --help")
  end
end
