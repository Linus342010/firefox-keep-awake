import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
  id: root

  property string stage: ""
  property bool ownsStayAwake: false
  property bool ownershipMarkerChecked: false

  readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
  readonly property string ownershipPath: runtimeDir + "/firefox-keep-awake.owns-idle-toggle"
  readonly property var players: Mpris.players ? Mpris.players.values : []
  readonly property var browserIdentities: [
    "firefox", "org.mozilla.firefox", "zen", "librewolf", "floorp",
    "waterfox", "mullvad", "mercury", "icecat", "torbrowser",
    "palemoon", "basilisk", "seamonkey"
  ]
  readonly property bool hasSupportedBrowser: supportedBrowserIsOpen()

  function supportedBrowserIsOpen() {
    for (var i = 0; i < players.length; i++) {
      var player = players[i]
      if (!player) continue

      var identity = [player.identity, player.desktopEntry, player.dbusName]
        .filter(function(value) { return !!value })
        .join(" ")
        .toLowerCase()

      for (var j = 0; j < browserIdentities.length; j++) {
        if (identity.indexOf(browserIdentities[j]) !== -1) return true
      }
    }

    return false
  }

  function supportedBrowserIsPlaying() {
    for (var i = 0; i < players.length; i++) {
      var player = players[i]
      if (!player || !player.isPlaying) continue

      var identity = [player.identity, player.desktopEntry, player.dbusName]
        .filter(function(value) { return !!value })
        .join(" ")
        .toLowerCase()

      for (var j = 0; j < browserIdentities.length; j++) {
        if (identity.indexOf(browserIdentities[j]) !== -1) return true
      }
    }

    return false
  }

  function run(args, nextStage) {
    if (command.running) return false
    stage = nextStage
    command.command = args
    command.running = true
    return true
  }

  function parseIdleEnabled(output) {
    try {
      var status = JSON.parse(output)
      return typeof status.enabled === "boolean" ? status.enabled : null
    } catch (error) {
      return null
    }
  }

  function poll() {
    if (!ownershipMarkerChecked || command.running) return

    if (supportedBrowserIsPlaying()) {
      run(["omarchy", "toggle", "idle", "status"], "idle-status-playing")
    } else if (ownsStayAwake) {
      run(["omarchy", "toggle", "idle", "allow-idle"], "restore-idle")
    }
  }

  Timer {
    interval: 2000
    repeat: true
    running: root.ownershipMarkerChecked && root.hasSupportedBrowser
    triggeredOnStart: true
    onTriggered: root.poll()
  }

  onHasSupportedBrowserChanged: {
    if (!root.hasSupportedBrowser && root.ownershipMarkerChecked)
      root.poll()
  }

  Process {
    id: command
    stdout: StdioCollector { waitForEnd: true }

    onExited: function(exitCode) {
      var output = stdout.text.trim()
      var finishedStage = root.stage
      root.stage = ""

      if (finishedStage === "ownership-marker") {
        root.ownsStayAwake = exitCode === 0
        root.ownershipMarkerChecked = true
      } else if (finishedStage === "idle-status-playing") {
        if (exitCode === 0 && root.supportedBrowserIsPlaying() && root.parseIdleEnabled(output) === false)
          root.run(["omarchy", "toggle", "idle", "stay-awake"], "enable-stay-awake")
      } else if (finishedStage === "enable-stay-awake" && exitCode === 0) {
        root.ownsStayAwake = true
        root.run(["touch", root.ownershipPath], "write-ownership-marker")
      } else if (finishedStage === "write-ownership-marker" && exitCode === 0) {
        if (!root.supportedBrowserIsPlaying())
          root.run(["omarchy", "toggle", "idle", "allow-idle"], "restore-idle")
      } else if (finishedStage === "restore-idle" && exitCode === 0) {
        root.ownsStayAwake = false
        root.run(["rm", "-f", root.ownershipPath], "remove-ownership-marker")
      }
    }
  }

  Component.onCompleted: root.run(["test", "-e", root.ownershipPath], "ownership-marker")

  Component.onDestruction: {
    if (!root.ownsStayAwake) return

    Quickshell.execDetached([
      "bash", "-c",
      "omarchy toggle idle allow-idle >/dev/null 2>&1; rm -f -- \"$1\"",
      "firefox-keep-awake-cleanup", root.ownershipPath
    ])
  }
}
