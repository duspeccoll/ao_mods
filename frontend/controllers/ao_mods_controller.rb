class AoModsController < ExportsController

  require 'zip'
  require 'net/http'

  set_access_control "view_repository" => [:index, :download, :batch]

  include ExportHelper

  def index
  end

  def download
    download_export("/repositories/#{JSONModel::repository}/archival_objects/mods/#{params[:id]}.xml")
  end

end
