# Generated from ottto-local-platform 0.1.111 (stable).
# Do not hand-edit: run tools/ottto-local-platform/scripts/homebrew_formula.sh.
class Ottto < Formula
  desc "Local Ottto CLI and per-user service"
  homepage "https://ottto.net"
  url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.111/ottto-macos-arm64.zip"
  version "0.1.111"
  sha256 "50f1e8552fad0f98554eb6ec5ac921a8a0db16f20f377b9506f038ad0948a5eb"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  resource "ottto-service" do
    url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.111/ottto-service-macos-arm64.zip"
    sha256 "fdbcc9d8d9c9a53f87f31d9896c908fc28e884f4bf755fe04c58dd7a682ea2d6"
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
