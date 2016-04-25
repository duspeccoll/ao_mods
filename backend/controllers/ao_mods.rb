class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/repositories/:repo_id/archival_objects/mods/:id.xml')
    .description("Get a MODS representation of an Archival Object")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "(:archival_object)"]) \
  do
    obj = resolve_references(ArchivalObject.to_jsonmodel(params[:id]), ['repository::agent_representation', 'linked_agents', 'subjects'])
    ao_mods = ASpaceExport.model(:ao_mods).from_archival_object(JSONModel(:archival_object).new(obj))

    xml_response(ASpaceExport::serialize(ao_mods))
  end

end
