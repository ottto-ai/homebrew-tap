cask "ottto-app" do
  version "0.1.264"
  sha256 "62b0715fc2e0645d50700ffa3d6ee09dfc7a6f432b5daace83ea0dd392420c0e"

  url "https://install.ottto.net/ottto-local-platform/releases/stable/#{version}/Ottto-macos-arm64.dmg"
  name "Ottto"
  desc "Local-first observability for AI coding agents (Claude Code, Codex, and more)"
  homepage "https://ottto.net/"

  livecheck do
    url "https://api.ottto.net/api/v1/local-platform/release"
    strategy :json do |json|
      json["latest_version"]
    end
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Ottto.app"

  # Stop the background service only when it is this app's own job (its
  # program is inside Ottto.app). A job owned by the Homebrew formula is left
  # alone. The plist goes first, so an `ottto` command cannot start the job
  # again from the app bundle that is being replaced. Steps run in a sandbox
  # with a temporary HOME, so the script resolves the user's real home.
  uninstall_preflight_steps do
    run "/bin/sh",
        args:           [
          "-c",
          <<~SH,
            plist="$(eval echo "~$(/usr/bin/id -un)")/Library/LaunchAgents/net.ottto.service.plist"
            job="gui/$(/usr/bin/id -u)/net.ottto.service"
            if [ -f "$plist" ]; then
              program="$(/usr/bin/plutil -extract ProgramArguments.0 raw -o - "$plist" 2>/dev/null)"
            else
              program="$(/bin/launchctl print "$job" 2>/dev/null | /usr/bin/awk '$1 == "program" { sub(/^[^=]*= /, ""); print; exit }')"
            fi
            case "$program" in
              *.app/Contents/*) ;;
              *) exit 0 ;;
            esac
            /bin/rm -f "$plist"
            /bin/launchctl bootout "$job" 2>/dev/null || true
          SH
        ],
        must_succeed:   false,
        writable_paths: ["Library/LaunchAgents"],
        writable_base:  :home
  end

  uninstall quit: "net.ottto.Companion"

  zap trash: [
    "~/Library/Application Support/Ottto",
    "~/Library/Caches/net.ottto.Companion",
    "~/Library/HTTPStorages/net.ottto.Companion",
    "~/Library/Logs/Ottto",
    "~/Library/Preferences/net.ottto.Companion.plist",
    "~/Library/Saved Application State/net.ottto.Companion.savedState",
  ]

  caveats <<~EOS
    If Ottto was not running when it was upgraded, open Ottto to start its
    background service again.

    If you run Ottto's service through the Homebrew formula instead, this cask
    does not change it.

    This cask needs Homebrew 6.0.16 or newer.
  EOS
end
