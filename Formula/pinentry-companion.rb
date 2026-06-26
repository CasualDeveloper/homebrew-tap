# typed: false
# frozen_string_literal: true

class PinentryCompanion < Formula
  desc "Native macOS GPG pinentry with Apple Watch, Touch ID, and Keychain support"
  homepage "https://github.com/CasualDeveloper/pinentry-companion"
  version "0.1.2"
  license "Apache-2.0"
  head "https://github.com/CasualDeveloper/pinentry-companion.git", branch: "main"

  depends_on "gnupg"
  depends_on :macos
  depends_on "pinentry"
  depends_on "pinentry-mac"

  on_macos do
    on_arm do
      url "https://github.com/CasualDeveloper/pinentry-companion/releases/download/v0.1.2/pinentry-companion-v0.1.2-arm64.tar.gz"
      sha256 "ad974d75438bd08a81514d710cfcee7dbfe404933788431841968deb84a2cfc7"
    end

    on_intel do
      url "https://github.com/CasualDeveloper/pinentry-companion/releases/download/v0.1.2/pinentry-companion-v0.1.2-x86_64.tar.gz"
      sha256 "4b4c3f0a5706fe95b1a81b556f655a2cffbeb31841cf9796d2b4bab3250b70a9"
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
      Configure GPG to use pinentry-companion:
        #{opt_bin}/pinentry-companion setup

      Check the installation:
        #{opt_bin}/pinentry-companion doctor

      First unlock after install may ask for the GPG passphrase through
      pinentry-mac. Later unlocks use macOS device-owner authentication.
    EOS
  end

  test do
    pinentry = bin/"pinentry-companion"

    assert_match "pinentry-companion doctor", shell_output("#{pinentry} help doctor")

    output = pipe_output(pinentry, "GETINFO flavor\nBYE\n")
    assert_match "OK Hi from pinentry-companion!", output
    assert_match "D companion", output
  end
end
