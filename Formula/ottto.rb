# Generated from ottto-local-platform 0.1.201 (stable).
# Do not hand-edit: run tools/ottto-local-platform/scripts/homebrew_formula.sh.
class Ottto < Formula
  desc "Local Ottto CLI and per-user service"
  homepage "https://ottto.net"
  url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.201/ottto-macos-arm64.zip"
  version "0.1.201"
  sha256 "8ae9bb561f1c8c95e8fe44b17c5806b3a1d4378e371e4f6010b2cbca7498d833"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  resource "ottto-service" do
    url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.201/ottto-service-macos-arm64.zip"
    sha256 "cff66ce22c3b051416a5e2b01bb05addbe30a4d2145e58d5e95fca3dac8f91e3"
  end

  def install
    bin.install "ottto"

    resource("ottto-service").stage do
      daemons = Dir["*"].select { |path| File.file?(path) && File.executable?(path) }
      odie "ottto-service resource did not contain exactly one executable" if daemons.length != 1
      bin.install daemons.fetch(0) => "ottto-service"
    end
  end

  service do
    name macos: "net.ottto.service"
    run [
      opt_bin/"ottto-service",
      "serve",
      "--socket",
      "#{Dir.home}/Library/Application Support/Ottto/ottto-service.sock",
    ]
    keep_alive true
    environment_variables PATH: std_service_path_env
    log_path "#{Dir.home}/Library/Logs/Ottto/ottto-service.log"
    error_log_path "#{Dir.home}/Library/Logs/Ottto/ottto-service.error.log"
  end

  def caveats
    <<~EOS
      Start the Ottto local service:
        brew services start ottto

      Check status after the service is started:
        ottto --no-autostart status --json

      Update this Homebrew-managed install:
        brew update && brew upgrade ottto
        brew services restart ottto

      Stop and uninstall:
        brew services stop ottto
        brew uninstall ottto

      The Homebrew service owns launchd label net.ottto.service and the default
      per-user socket at ~/Library/Application Support/Ottto/ottto-service.sock.
      If Ottto.app is also installed, leave service lifecycle with Homebrew; the
      app connects to the Homebrew-owned service instead of replacing it.
    EOS
  end

  test do
    system bin/"ottto", "--help"
    system bin/"ottto-service", "--help"
  end
end
