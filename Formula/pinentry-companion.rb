# typed: false
# frozen_string_literal: true

class PinentryCompanion < Formula
  desc "Native macOS GPG pinentry with Apple Watch, Touch ID, and Keychain support"
  homepage "https://github.com/CasualDeveloper/pinentry-companion"
  url "https://github.com/CasualDeveloper/pinentry-companion/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "3b074c2861dc1a1c4651be1494167012e9b8f9b154d48b5e55b4f40aa4a1b7ce"
  license "Apache-2.0"
  head "https://github.com/CasualDeveloper/pinentry-companion.git", branch: "main"

  depends_on "gnupg"
  depends_on :macos
  depends_on "pinentry"
  depends_on "pinentry-mac"

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "pinentry-companion"
    bin.install ".build/release/pinentry-companion"
  end

  def caveats
    <<~EOS
      Configure GPG to use pinentry-companion:
        #{opt_bin}/pinentry-companion setup

      Check the installation:
        #{opt_bin}/pinentry-companion doctor

      First unlock after install may ask for the GPG passphrase through
      pinentry-mac. Later unlocks use macOS device-owner authentication.
    EOS
  end

  test do
    assert_match "pinentry-companion doctor", shell_output("#{bin}/pinentry-companion help doctor")

    output = pipe_output("#{bin}/pinentry-companion", "GETINFO flavor\nBYE\n")
    assert_match "OK Hi from pinentry-companion!", output
    assert_match "D companion", output
  end
end
