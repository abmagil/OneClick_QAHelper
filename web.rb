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
      #Labels do not come through on all activities, so we must access raw story data
      story_ids.each do |story|
        grabber = FullStoryGrabber.new(project,story)
        grabber.get_story
        full_story = grabber.full_story
        next if xml_doc.at_xpath("//author").text.eql? "QA Helper" #Adding a comment will spawn another activity note.  Catch and move on if this is the case.
        updater = StoryUpdater.new(full_story)
        updater.update
      end
    end
end