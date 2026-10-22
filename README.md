# Firefox Keep Awake

Firefox Keep Awake keeps Omarchy from suspending or locking your session while
a Firefox based browser is playing media. It detects browser media sessions
through Quickshell's MPRIS support and restores normal idle behavior when
playback stops.

It recognizes Firefox, Zen, LibreWolf, Floorp, Waterfox, Mullvad Browser,
Mercury, GNU IceCat, Tor Browser, Pale Moon, Basilisk, and SeaMonkey.


## Install

Add the plugin repository with Omarchy:

```sh
omarchy plugin add https://github.com/Linus342010/firefox-keep-awake.git --enable
```

To remove it later:

```sh
omarchy plugin remove linus342010.firefox-keep-awake
```

Omarchy manages the plugin files and enabled state. The source repository is
not affected by removing the installed plugin.

## License

[The Unlicense](LICENSE)
