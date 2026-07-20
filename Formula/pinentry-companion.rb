# typed: false
# frozen_string_literal: true

class PinentryCompanion < Formula
  desc "Native macOS GPG pinentry with Apple Watch, Touch ID, and Keychain support"
  homepage "https://github.com/CasualDeveloper/pinentry-companion"
  version "0.2.0"
  license "Apache-2.0"
  head "https://github.com/CasualDeveloper/pinentry-companion.git", branch: "main"

  depends_on "gnupg"
  depends_on macos: :sonoma
  depends_on "pinentry"
  depends_on "pinentry-mac"

  on_macos do
    on_arm do
      url "https://github.com/CasualDeveloper/pinentry-companion/releases/download/v0.2.0/pinentry-companion-v0.2.0-arm64.tar.gz"
      sha256 "10b1ac4bbc65c2ef604a68f62c4fc8eab6c9b5aa3eb8941f0ce0cb6ac00a51c3"
    end

    on_intel do
      url "https://github.com/CasualDeveloper/pinentry-companion/releases/download/v0.2.0/pinentry-companion-v0.2.0-x86_64.tar.gz"
      sha256 "1899cf0bd0ccc871b4eeb2caf33dc82dc0c9de5066c79316dbe1d5e0b416aa20"
    end
  end

  def install
    if build.head?
      system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "pinentry-companion"
      bin.install ".build/release/pinentry-companion"
    else
      bin.install "pinentry-companion"
    end
  end

  def caveats
    <<~EOS
      Set up GPG to use pinentry-companion:
        #{opt_bin}/pinentry-companion setup

      Check the installation:
        #{opt_bin}/pinentry-companion doctor

      First unlock after install may ask for the GPG passphrase through
      pinentry-mac. Later unlocks use macOS device-owner authentication.

      Before uninstalling, restore the prior GPG configuration:
        #{opt_bin}/pinentry-companion uninstall --prepare
    EOS
  end

  test do
    pinentry = bin/"pinentry-companion"

    assert_match "pinentry-companion 0.2.0", shell_output("#{pinentry} --version")
    assert_match "pinentry-companion doctor", shell_output("#{pinentry} help doctor")

    output = pipe_output(pinentry, "GETINFO flavor\nGETINFO version\nBYE\n")
    assert_match "OK Hi from pinentry-companion!", output
    assert_match "D companion", output
    assert_match "D 0.2.0", output
  end
end
