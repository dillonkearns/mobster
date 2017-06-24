### **[Download the latest release](https://github.com/dillonkearns/mobster/releases/latest)** [![GitHub release](https://img.shields.io/github/release/dillonkearns/mobster.svg?style=flat-square)](https://github.com/dillonkearns/mobster/releases/latest)
<a href="https://trello.com/b/QWb0iO8j/mobster">Ideas tracked on <img src="/trello.png" width="48"></a>  
# Mobster [![Build Status](https://img.shields.io/travis/dillonkearns/mobster/master.svg?style=flat-square)](https://travis-ci.org/dillonkearns/mobster)

A mob/pair programming timer, inspired by the [MobProgramming/MobTimer.Python](https://github.com/MobProgramming/MobTimer.Python). Runs great on Mac, Windows, and Linux. Learn all about mobbing at the MobTimer.Python github page, and at [mobprogramming.org](http://mobprogramming.org/).

Mobster was built with delight in Elm and Electron <a href="http://elm-lang.org"><img src="https://avatars0.githubusercontent.com/u/4359353?v=3&s=280" height="35" /></a> <a href="http://electron.atom.io"><img src="https://camo.githubusercontent.com/79904b8ba0d1bce43022bbd5710f0ea1db33f54f/68747470733a2f2f7261776769742e636f6d2f73696e647265736f726875732f617765736f6d652d656c656374726f6e2f6d61737465722f656c656374726f6e2d6c6f676f2e737667" height="35"></img></a>

## RPG Mode
You can play through the mob programming RPG to practice mobbing skills with your team. This is a port of [Willem Larsen](https://github.com/willemlarsen)'s excellent [Mob Programming RPG](https://github.com/willemlarsen/mobprogrammingrpg). This is a fantastic way to learn about some of the subtleties that are essential to effective mobbing, such as the [Driver/Navigator Pattern (also known as Strong-Style)](http://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html).

![RPG Mode](/rpg-mode.gif)

### Recommended Structure
* Pick a familiar exercise in a familiar language if possible so you can focus on learning mobbing skills, not a new language, etc.

## Using Active Mobsters for Git Commit Authors/Shell Scripts
The active mobsters will always be up-to-date in the `active-mobsters` file.

The location of this file for the different platforms is:
- `%APPDATA%\mobster\active-mobsters` on Windows
- `$XDG_CONFIG_HOME/mobster/active-mobsters` or `~/.config/mobster/active-mobsters` on Linux
- `~/Library/Application Support/mobster/active-mobsters` on macOS

(As described in `appData` section of the Electron docs](https://electron.atom.io/docs/api/app/#appgetpathname)).

The names in the `active-mobsters` file are separated by `,`s with spaces like so: `Jim Kirk, Spock, McCoy`.

You can set the author field in a commit to the list of active mobsters. See  [mobster-commit.sh](https://github.com/dillonkearns/mobster/blob/master/mobster-commit.sh) for a working example. After committing with this script, your `git log` will look something like:
```shell
$ git log
commit 39d59e7e4c9acb021988b3040f9b7ace5f539b78
Author: James Kirk, Leonard McCoy, Spock <example@example.com>
Date:   Fri Mar 3 21:00:25 2017 -0500

    Set phasers to stun.
```

## Workaround for Windows 10 Transparency Issues
There is a [known Electron bug for transparency in Windows 10](https://github.com/electron/electron/issues/9357) (see also https://github.com/dillonkearns/mobster/issues/49). If you have this issue on your machine, you can disable transparency with these steps:

* Find the file path for `%APPDATA%` (you can use Windows-R to pull up the run menu and type it in there to open the folder)
* Create a file called `NO_TRANSPARENCY` in the directory `%APPDATA%/mobster` (make sure it doesn't have a `.txt` or any other extension)
* Restart Mobster

Thanks @steverb1 for reporting the issue and testing workarounds!


## Contributors
* A big thanks to Eric Heikkila ([ehei](https://github.com/ehei)) for figuring out the
autoUpdater (which I couldn't for the life of me get to work)!
* Thanks to Gedward Gonzalez ([gedward](https://github.com/gedward)) for stepping
me through the Mac app signing and autoUpdater with his Apple dev expertise!
* Thanks for contributing some sweet quotes Nayan Hajratwala ([nhajratw](https://github.com/nhajratw))

## Contributing
To clone and run this repository you'll need [Git](https://git-scm.com) and [Node.js](https://nodejs.org/en/download/) (which comes with [npm](http://npmjs.com)) installed on your computer. From your command line:

```bash
# Clone this repository
git clone https://github.com/dillonkearns/mobster
# Go into the repository
cd mobster
# Install dependencies
npm install
# Run the app
npm start
```

#### Under [MIT license](LICENSE.md)
