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

  def batch
    batch_download(params['mods_downloads'])
  end

  private

  def get_mods(uri)
    url = URI("#{JSONModel::HTTP.backend_url}#{uri}")
    req = Net::HTTP::Get.new(url.request_uri)
    req['X-ArchivesSpace-Session'] = Thread.current[:backend_session]
    resp = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    mods = resp.body if resp.code == "200"
  	return mods
	end

  def search_item(item)
    search_data = Search.all(session[:repo_id],{
      'q' => item,
      'filter_term[]' => {'primary_type' => "archival_object"}.to_json
    })

    if search_data.results?
      search_data['results'].each do |result|
        obj = JSON.parse(result['json'])
        return obj['uri'] if obj['component_id'] == item
      end
    end
  end

	def batch_download(downloads)
    items = downloads.split(/\r\n/)
    uris = []

    items.each do |item|
      uri = search_item(item)
      uris.push({'item' => item, 'uri' => uri}) unless uri.nil?
    end

    if uris.empty?
      flash[:error] = "Couldn't find any of the IDs provided!"
      redirect_to :controller => :ao_mods, :action => :index
    else
      output = Zip::OutputStream.write_buffer do |zos|
        uris.each do |uri|
          uri['uri'].gsub!(/objects\//,'objects/mods/')
          mods = get_mods("#{uri['uri']}.xml")
          zos.put_next_entry "#{uri['item']}.xml"
          zos.puts mods
        end
      end
      output.rewind
      send_data output.read, :filename => "batch_mods_download.zip", :type => "application/zip"
    end
	end

end
