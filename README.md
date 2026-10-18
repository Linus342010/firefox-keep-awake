# Firefox Keep Awake

Firefox Keep Awake keeps Omarchy from suspending or locking your session while
Firefox is playing media. It detects Firefox through Quickshell's MPRIS support
and restores normal idle behavior when playback stops.

## Requirements

- Omarchy with Quickshell and MPRIS support
- Firefox with media playback exposed over MPRIS

The plugin runs as a native Omarchy Quickshell service. It does not require
systemd, `playerctl`, or additional packages.

## Install

Add the plugin repository with Omarchy:

```sh
omarchy plugin add https://github.com/Linus342010/firefox-keep-awake.git --enable
```

To remove it later:

```sh
omarchy plugin remove io.github.linus342010.firefox-keep-awake
```

Omarchy manages the plugin files and enabled state. The source repository is
not affected by removing the installed plugin.

## License

[The Unlicense](LICENSE)
