# Generated from ottto-local-platform 0.1.185 (stable).
# Do not hand-edit: run tools/ottto-local-platform/scripts/homebrew_formula.sh.
class Ottto < Formula
  desc "Local Ottto CLI and per-user service"
  homepage "https://ottto.net"
  url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.185/ottto-macos-arm64.zip"
  version "0.1.185"
  sha256 "2cb689a1e2962d5f2d9f2efc917f2bbe827eaac2203944a754678d12de873a66"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  resource "ottto-service" do
    url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.185/ottto-service-macos-arm64.zip"
    sha256 "e532d9bb551b6368844eacbafd473f4592049c267c0d5ba3e6584c0a798132b8"
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
