# ao_mods

This plugin allows users to download MODS representations of Archival Objects in ArchivesSpace. It does this through backend controllers allowing a MODS representation of any Archival Object record to be downloaded in the same way as a Digital Object, and using a version of the same MODS exporter/model files (re-written for the Archival Object JSON schema). On the frontend, it provides a link to export MODS records for any Archival Object with a component level of 'item' (in keeping with our local implementation of ArchivesSpace).

On the 'item_linker' branch, the plugin allows a user to create minimal digital object records for an item based on its title and component ID, and to update that digital object with the External Document link to [the University of Denver Islandora repository](https://specialcollections.du.edu). This branch is written more specifically for DU's implementation of ArchivesSpace, though others may find it useful.

Questions may be directed to kevin.clair at du.edu.
