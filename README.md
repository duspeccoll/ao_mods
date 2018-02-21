# ao_mods

This plugin allows users to download MODS representations of Archival Objects in ArchivesSpace. On the backend, there is an API call allowing the direct download of a MODS representation of any Archival Object as well as the metadata for that MODS representation, similar to the MODS export for Digital Object records. On the frontend, there is a toolbar button appearing in the "More..." dropdown menu for any Archival Object with the level of 'item'.

Because we have multiple plugins using the "More..." dropdown menu, the toolbar functionality may be found in our local plugins. If you only wish to use the ao_mods plugin, you will need to include an additional two files not found here:

* [archival_objects/_toolbar.html.erb](https://github.com/duspeccoll/plugins_local/blob/master/frontend/views/archival_objects/_toolbar.html.erb)
* [shared/_component_toolbar.html.erb](https://github.com/duspeccoll/plugins_local/blob/master/frontend/views/shared/_component_toolbar.html.erb)

Both files should be installed in the frontend/views directory of this plugin.

There used to be an "item_linker" branch to this plugin, allowing a user to link an item record to a Digital Object record for its digital surrogate; this is now [its own plugin](https://github.com/duspeccoll/item_linker).

Questions may be directed to kevin.clair at du.edu.
