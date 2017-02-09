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
    batch_download(params['mods_resource']['ref'])
  end

  private

  def get_mods(url)
    req = Net::HTTP::Get.new(url.request_uri)
    req['X-ArchivesSpace-Session'] = Thread.current[:backend_session]
    resp = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    mods = resp.body if resp.code == "200"
  	return mods
	end

	def process_tree(obj, zos, path)
		url = "/repositories/#{session[:repo_id]}/archival_objects/mods/#{obj['id']}.xml"
		if obj['level'] == "item"
      filename = obj['component_id'] ? "#{obj['component_id']}.xml" : "#{obj['id']}.xml"
			mods = get_mods(URI("#{JSONModel::HTTP.backend_url}#{url}"))
      zos.put_next_entry "#{path}/#{filename}"
      zos.puts mods
		end
		obj['children'].each do |child|
			process_tree(child, zos, path)
		end
	end

	def batch_download(resource)
    id = JSONModel::HTTP.get_json("#{resource}")['id_0'].downcase!
    tree = JSONModel::HTTP.get_json("#{resource}/tree")
    path = "#{id}_mods_download"
    output = Zip::OutputStream.write_buffer do |zos|
			tree['children'].each do |child|
				process_tree(child, zos, path)
			end
		end
		output.rewind
    send_data output.read, :filename => "#{path}.zip", :type => "application/zip"
	end

end
