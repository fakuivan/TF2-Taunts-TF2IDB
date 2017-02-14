# TF2 Taunts TF2IDB [![Build Status](https://travis-ci.org/fakuivan/TF2-Taunts-TF2IDB.svg?branch=master)](https://travis-ci.org/fakuivan/TF2-Taunts-TF2IDB)
An extensible and auto-updatable TF2 taunt menu/command plugin for sourcemod

## Usage
### Commands
* ``sm_taunt``/``sm_taunts`` If no arguments given, it shows a taunt menu, if one argument is given it'll be interpreted as an Item Definition Index (aka taunt id).
* ``sm_taunt_list``/``sm_taunts_list`` Shows a list of available taunts, starting with it's id, then the name and lastly the class that can use it.

### Tips
Using the commands listed above, you can bind a key to a specific taunt like this:
* Type ``!taunt_list`` from chat, find and write down the id for which you'd like to bind a key.
* Enter the game console and write ``bind KEY "sm_taunt id"`` replace ``KEY`` and ``id`` with their respective values, of course.

Now each time you press ``KEY`` you'll taunt to the rhythm of ``id`` 💃

## Installing

1. Make sure you have [TF2ItemsInfo](https://github.com/chauffer/tf2itemsinfo) or [TF2ItemsDB](https://forums.alliedmods.net/showthread.php?t=255885) (preferred) installed on your server.
2. __Recommended__: Install the [Updater](https://forums.alliedmods.net/showthread.php?p=1570806) plugin or check if you have it installed (`sm plugins info updater`), all releases/updates to this repo will be immediately available to the updater, including updates to gamedata files.
3. Go to the [releases](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases) section.
4. Look for the latest post and download the attched zip file that matches your installed schema api (eg. ``tf2_taunts_tf2idb-nX-tf2ii.zip`` for TF2II).
5. Drag and drop the contents from the file to your ``sourcemod`` folder.
6. Load the plugin (``sm plugins load tf2_taunts_tf2idb``) and test it using the ``sm_taunt_list`` command.

## Contributing

### You found a bug? Want to request a feature?

Open a new [issue](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues) and descibe your request (include as much information as possible).

### You want to contribute to this project?

Fork the repo and issue a pull request, you help is always welcome, just make sure to be consistent with the code style and naming conventions already in place.

### About the libraries included with this project

Both ``CTauntCacheSystem`` and ``CTauntEnforcer`` (except gamedata for the latter) are ment to be modular, encapsulated methodmaps that anyone can use on their project if they want to, keep in mind that at the time of writting this, there is no documentation about them, however, most properties and methods are pretty self explanatory.
