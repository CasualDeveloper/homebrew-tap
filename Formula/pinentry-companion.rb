# typed: false
# frozen_string_literal: true

class PinentryCompanion < Formula
  desc "Native macOS GPG pinentry with Apple Watch, Touch ID, and Keychain support"
  homepage "https://github.com/CasualDeveloper/pinentry-companion"
  version "0.1.1"
  license "Apache-2.0"
  head "https://github.com/CasualDeveloper/pinentry-companion.git", branch: "main"

  depends_on "gnupg"
  depends_on :macos
  depends_on "pinentry"
  depends_on "pinentry-mac"

  on_macos do
    on_arm do
      url "https://github.com/CasualDeveloper/pinentry-companion/releases/download/v0.1.1/pinentry-companion-v0.1.1-arm64.tar.gz"
      sha256 "5eb0df529c8402944c84a0b10fa4eb0345c90e78cd33b342b6a08ac46cef58b6"
    end

    on_intel do
      url "https://github.com/CasualDeveloper/pinentry-companion/releases/download/v0.1.1/pinentry-companion-v0.1.1-x86_64.tar.gz"
      sha256 "7b3c589a0ffc12b0d81a2e44f6455ae6e39c2d98d210017e4165d128e0a3fd85"
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
