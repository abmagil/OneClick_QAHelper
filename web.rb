require 'sinatra'
require 'nokogiri'

get '/' do
  "Why are you GETting this page?"
end

post '/' do
  #ENV['APIKEY'] + " is your token."
  response = ""
  @xml_doc = Nokogiri::XML(request.body)
  @event = @xml_doc.at_xpath("//event_type").text
  @labels = @xml_doc.at_xpath("//labels").text
  @project = @xml_doc.at_xpath("//project_id").text
  response << "Project: " + @project.to_s + "\n"
  stories = @xml_doc.root.xpath("//stories")
  story_ids = stories.xpath(".//id")
  story_ids.each do |story|
    response << "Story: " + story.text.to_s
    url =  "http://www.pivotaltracker.com/services/v3/projects/#{@project}/stories/#{story}"
    response << "\n"
  end
  response << "Labels: " + @labels.to_s
  response
  
end

