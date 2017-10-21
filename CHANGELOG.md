* [1.6.3](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.6.3) Gamedata update, minor improvements
	* Gamedata updated ([#23](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/23)). 
	* Cache initialization failure for the [TF2IDB](https://github.com/FlaminSarge/tf2idb) (while quite rare) was never treated as such, allowing the plugin to just move on with invalid values ([#21](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/21)). 
	* Now the ``TF2IDB_UsedByClasses_Compat`` wrapper calls ``TF2IDB_UsedByClasses`` directly, improving load times on newer versions of [TF2IDB](https://github.com/FlaminSarge/tf2idb) ([#22](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/22)). 
* [1.6.1](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.6.1) I like better menus
	* Class-specific taunts are back on top of the list for ``sm_taunt``, ([#19](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/19)) along with class labels ([#18](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/18)).
	* Fix plugin not checking if target filter matches no clients, attempting to give taunts to entity 0 (world/"console"), under the ``sm_taunt_force`` menu ([#17](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/17)).
* [1.6](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.6) I like menus
    * Add a menu for the ``sm_taunt_force`` ([#16](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/16)).
* [1.5.2](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.5.2) 2Fast4UM8, sadly
    * Make this plugin call the item schema API once all pluigins are loaded fixing [#14](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/14)
* [1.5.1](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.5.1) Minor updater fix
    * Fix version strings mismatch between the updater manifest file and the version reported by the plugin, making the updater update the already up-to-date plugin ([#11](https://github.com/fakuivan/TF2-Taunts-TF2IDB/pull/11)).
* [1.5](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.5) Make others taunt! _if you are an admin_ :P
    * Add the ``sm_taunt_force``/``sm_taunts_force`` command to allow admins to make other players taunt ([#8](https://github.com/fakuivan/TF2-Taunts-TF2IDB/pull/8)).
* [1.4.5](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.4.5) "Disaster recovery"
    * Update description for ``sm_taunt_list``/``sm_taunts_list`` ([#3](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/3)).
    * Fix plugin not failing to initialize if gamedata is invalid ([#4](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/4)).
    * Fix plugin unloading if initialization failed (and the updater not registering it), this means that if gamedata wasn't up-to-date or TF2IDB misbehaves when creating the cache, the plugin could still be registered by the updater. ([#5](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/5))
    * Changed class name "demo" by "demoman" ([#6](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/6))
* [1.4](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.4) The updater!... update?
    * Add updater support (https://github.com/fakuivan/TF2-Taunts-TF2IDB/commit/781ac8e8b6f396cd7bddae86bc245041c5ebf905)
* [1.3](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.3) Enhanced compatibility
    * Fix issues with older versions of TF2IDB when getting the taunt classes (https://github.com/fakuivan/TF2-Taunts-TF2IDB/commit/e3cf2adcc4cb18e1dbc4f23b43840da39baaea0a).
* [1.2](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.2) Production release
    * Add checks to avoid building the taunt cache before TF2II is ready to process requests ([#1](https://github.com/fakuivan/TF2-Taunts-TF2IDB/issues/1)).
    * Fix ``sm_taunt``/``sm_taunts`` trying to target the server console if the command originated from there (https://github.com/fakuivan/TF2-Taunts-TF2IDB/commit/d8b6edd6b109f304311587f57f5dd912485085fa).
* [1.0](https://github.com/fakuivan/TF2-Taunts-TF2IDB/releases/tag/1.0) Initial release
    * Initial release.
