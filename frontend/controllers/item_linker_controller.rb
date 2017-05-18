class ItemLinkerController < ApplicationController

  set_access_control "view_repository" => [:create, :update]

  def create
    item = JSONModel(:archival_object).find(params[:id])
    create_digital_object(item)

    redirect_to(:controller => :resources, :action => :edit, :id => JSONModel(:resource).id_for(item['resource']['ref']), :anchor => "tree::archival_object_#{params[:id]}")
  end

  def update
    item = JSONModel(:archival_object).find(params[:id])
    update_digital_object(item)

    redirect_to(:controller => :resources, :action => :edit, :id => JSONModel(:resource).id_for(item['resource']['ref']), :anchor => "tree::archival_object_#{params[:id]}")
  end

  private

  def create_digital_object(item)
    # 1. Create new Digital Object using the item's title and component ID
    # 2. Create the digital object in the backend via POST
    # 3. If successful, link it to the item record; otherwise throw the error
    # 4. Throw the error if the item/digital object link is unsuccessful
    # 5. Return the user to the item record

    links = item['external_documents'].select{|e| e["title"] == "Special Collections @ DU"}
    digital_object_id = links.empty? ? item['component_id'] : links[0]['location']

    object = JSONModel(:digital_object).new({
      :title => item['title'],
      :digital_object_id => digital_object_id,
      :publish => true
    }).to_json

    res = JSONModel::HTTP.post_json(URI("#{JSONModel::HTTP.backend_url}/repositories/#{session[:repo_id]}/digital_objects"), object)

    if res.code === "200"
      uri = ASUtils.json_parse(res.body)['uri']

      item['instances'].push(JSONModel(:instance).new({
        :instance_type => "digital_object",
        :is_representative => true,
        :digital_object => { :ref => uri }
      }))

      res = JSONModel::HTTP.post_json(URI("#{JSONModel::HTTP.backend_url}#{item['uri']}"), item.to_json)
      if res.code === "200"
        flash[:success] = "Digital object created and linked: #{uri}"
      else
        flash[:success] = "Digital object created: #{uri}"
        flash[:error] = "An error occurred while linking the digital object: #{ASUtils.json_parse(res.body)['error'].to_s}".html_safe
      end
    else
      flash[:error] = "An error occurred while creating the digital object: #{ASUtils.json_parse(res.body)['error'].to_s}".html_safe
    end

  end

  def update_digital_object(item)
    # 1. Check to see if the Special Collections @ DU link matches the digital object identifier
    # 2. If yes, do nothing
    # 3. If not, copy the Special Collections @ DU link to the digital object
    # 4. Return the user to the item record

    links = item['external_documents'].select{|e| e["title"] == "Special Collections @ DU"}
    link = links[0]['location']

    digital_objects = item['instances'].select{|i| i["instance_type"] == "digital_object"}
    digital_object = digital_objects[0]['digital_object']['ref']

    object = JSONModel::HTTP.get_json(digital_object)

    if link == object['digital_object_id']
      flash[:info] = "The handles already match; no action taken"
    else
      object['digital_object_id'] = link
      res = JSONModel::HTTP::post_json(URI("#{JSONModel::HTTP.backend_url}#{digital_object}"), object.to_json)
      if res.code === "200"
        flash[:success] = "Digital object updated: #{digital_object}"
      else
        flash[:error] = "An error occurred while updating the digital object: #{ASUtils.json_parse(res.body)['error'].to_s}".html_safe
      end
    end
  end

end
