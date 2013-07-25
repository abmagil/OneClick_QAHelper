require 'sinatra'
require 'nokogiri'
require 'httparty'
require_relative 'FullStoryGrabber'
require_relative 'StoryUpdater'

get '/' do
  "Why are you GETting this page?  Should be PUT to."
end

post '/' do
  xml_doc = Nokogiri::XML(request.body)
  #At present, no need to handle any transition that isn't a story update
  case xml_doc.at_xpath("//event_type").text
    when "story_update" 
      project = xml_doc.at_xpath("//project_id").text
      stories = xml_doc.root.xpath("//stories")
      story_ids = stories.xpath(".//id")
      #It's unclear to me that labels will necessarily come on update, so pull the issue from PT and edit from that.
      story_ids.each do |story|
        grabber = FullStoryGrabber.new(project,story)
        grabber.get_story
        full_story = grabber.full_story
        updater = StoryUpdater.new(full_story)
        updater.update
      end
    end
end