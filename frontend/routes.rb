ArchivesSpace::Application.routes.draw do
  match('/plugins/ao_mods/:id/download' => 'ao_mods#download', :via => [:get])
end
