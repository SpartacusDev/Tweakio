# Tweakio
Search packages globally directly from your favourite package manager! Works with Cydia, Installer, Zebra and Sileo!

## How does it work
The tweak adds an extra tab to each package manager or a button to the default search tab, as you can see in the `.x` files. What's in the extra tab/button is the Tweakio view controller. The Tweakio search utilizes a restAPI, such as the Tweakio API, Parcility API, Canister API and iOS Repo Updates API. In order to choose the API (default is Tweakio API), you simply open the in-app settings in the Tweakio tab, and then choose the API.

## Jailbreaks
Tweakio is built from a single source tree for both package layouts:

| Jailbreak | Layout | Build |
| --- | --- | --- |
| Dopamine, palera1n, roothide (iOS 15/16) | rootless, `/var/jb` | `make package ROOTLESS=1 FINALPACKAGE=1` |
| unc0ver, checkra1n, Taurine (iOS 12-14) | rootful, `/` | `make package FINALPACKAGE=1` |

Since Tweakio is only ever installed into a package manager that is itself running
from the jailbroken root, only one build of a given version is needed per layout.
Every path the tweak touches goes through `ROOT_PATH_NS()` from
[`rootless.h`](https://github.com/theos/headers/blob/master/rootless.h), so it
resolves correctly on rootful, rootless and roothide jailbreaks at runtime.

The rootless build depends on `mobilesubstrate`, which is provided by ElleKit on
Dopamine. `preferenceloader` and Cephei (`ws.hbang.common`) are needed for the
preference bundle in Settings.

Prebuilt `.deb`s for both layouts are produced by the
[Build workflow](.github/workflows/build.yml) and attached to each workflow run.

## Building
Requires [Theos](https://github.com/theos/theos) cloned **recursively** – `rootless.h`,
`libroot` and the Cephei frameworks live in submodules:

```sh
git clone --recursive https://github.com/theos/theos.git ~/theos
export THEOS=~/theos
make package ROOTLESS=1 FINALPACKAGE=1   # or: make package FINALPACKAGE=1
```

# Contributing
Feel free to contribute by making a pull request

# Found an issue?
Please either file an issue here in the GitHub repo (I may not see it fast, which is why I suggest the second method more, which is:) or tell me the issue in the [Discord server](https://discord.gg/mZZhnRDGeg)

# Credits
* Thanks to everyone who has made/maintained Cydia, Installer, Zebra and Sileo
* Thanks to Randy420 for helping me with some random bugs every now and then
* Thanks to relisiuol for making a PR with iOS Repo Updates support
* Thanks to my trusty beta testers
