ArchivesSpace::Application.routes.draw do

  match('/plugins/ao_mods' => 'ao_mods#index', :via => [:get])
  match('/plugins/ao_mods/batch' => 'ao_mods#batch', :via => [:post])
  match('/plugins/ao_mods/:id/download' => 'ao_mods#download', :via => [:get])

end
