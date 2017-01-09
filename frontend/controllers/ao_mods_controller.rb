class AoModsController < ExportsController

  require 'csv'
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

	def process_tree(obj, zos, log)
		url = "/repositories/#{session[:repo_id]}/archival_objects/mods/#{obj['id']}.xml"
		filename = String.new
		if obj['level'] == "item"
			if obj['component_id']
				filename = "#{obj['component_id']}.xml"
			else
				filename = "#{obj['id']}.xml"
			end
			mods = get_mods(URI("#{JSONModel::HTTP.backend_url}#{url}"))
			zos.put_next_entry filename
			zos.print mods
			log.push("#{filename} (#{url}) downloaded")
		end
		obj['children'].each do |child|
			process_tree(child, zos, log)
		end
	end

	def batch_download(resource)
    tree = JSONModel::HTTP.get_json("#{resource}/tree")
		log = Array.new
		output = Zip::OutputStream.write_buffer do |zos|
			tree['children'].each do |child|
				process_tree(child, zos, log)
			end
			zos.put_next_entry "action_log.txt"
			log.each do |entry|
				zos.puts entry
			end
		end
		output.rewind
    send_data output.read, filename: "mods_download.zip"
	end

end
