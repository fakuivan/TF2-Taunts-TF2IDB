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
