# Generated from ottto-local-platform 0.1.132 (stable).
# Do not hand-edit: run tools/ottto-local-platform/scripts/homebrew_formula.sh.
class Ottto < Formula
  desc "Local Ottto CLI and per-user service"
  homepage "https://ottto.net"
  url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.132/ottto-macos-arm64.zip"
  version "0.1.132"
  sha256 "dd724f9303c8977ac985008d2e568b74813bad53c87223351aa8be5f66d37abc"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  resource "ottto-service" do
    url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.132/ottto-service-macos-arm64.zip"
    sha256 "b8de4b6618023a4cd22ed069f96d7261b7e4e74b91ac17474d4737095dc20d63"
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
