### **[Download latest release](https://github.com/dillonkearns/mobster/releases/latest)** [![GitHub release](https://img.shields.io/github/release/dillonkearns/mobster.svg)](https://github.com/dillonkearns/mobster/releases/latest)
# Mobster [![Stories in Ready](https://badge.waffle.io/dillonkearns/mobster.png?label=ready&title=Ready)](https://waffle.io/dillonkearns/mobster) [![Build Status](https://travis-ci.org/dillonkearns/mobster.svg?branch=master)](https://travis-ci.org/dillonkearns/mobster)
A mob/pair programming timer, inspired by the [MobProgramming/MobTimer.Python](https://github.com/MobProgramming/MobTimer.Python). Runs great on Mac, Windows, and Linux. Learn all about mobbing at the MobTimer.Python github page, and at [mobprogramming.org](http://mobprogramming.org/).
This app was created to have an easier to maintain cross-platform application (using github's [electron](electron.atom.io) framework).

## Using Current Mobsters for Git Commit Authors/Shell Scripts
The active mobsters will always be up-to-date in the `active-mobsters` file.

The location of this file for the different platforms is:
- `%APPDATA%\mobster\active-mobsters` on Windows
- `$XDG_CONFIG_HOME/mobster/active-mobsters` or `~/.config/mobster/active-mobsters` on Linux
- `~/Library/Application Support/mobster/active-mobsters` on macOS

(As described in the [`appData` section of the Electron docs](https://electron.atom.io/docs/api/app/#appgetpathname))

The names in the `active-mobsters` file are separated by `,`s with spaces like so: `Jim Kirk, Spock, McCoy`

You can set the author field in a commit to the list of active mobsters. See the  [mobster-commit.sh](https://github.com/dillonkearns/mobster/blob/master/mobster-commit.sh) for a working example. The output of `git log` looks like
```shell
$ git log
commit 39d59e7e4c9acb021988b3040f9b7ace5f539b78
Author: James Kirk, Leonard McCoy, Spock <example@example.com>
Date:   Fri Mar 3 21:00:25 2017 -0500

    Set phasers to stun.
```


## Contributors
* A big thanks to Eric Heikkila ([ehei](https://github.com/ehei)) for figuring out the
autoUpdater (which I couldn't for the life of me get to work)!
* Thanks to Gedward Gonzalez ([gedward](https://github.com/gedward)) for stepping
me through the Mac app signing and autoUpdater with his Apple dev expertise!

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
