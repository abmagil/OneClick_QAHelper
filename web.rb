require 'sinatra'
require 'nokogiri'
require 'httparty'
require 'haml'
require_relative 'FullStoryGrabber'
require_relative 'StoryUpdater'

get '/' do
  haml :index
end

post '/' do
  xml_doc = Nokogiri::XML(request.body)
  case xml_doc.at_xpath("//event_type").text
    #Chore stories are not going to encapsulate QA-able tasks.  Label as dev-test
    when "story_create"
      project = xml_doc.at_xpath("//project_id").text
      stories = xml_doc.root.xpath("//stories")
      story_ids = stories.xpath(".//id")
      #Labels do not come through on all activities, so we must access raw story data
      story_ids.each do |story|
        grabber = FullStoryGrabber.new(project,story)
        grabber.get_story
        full_story = grabber.full_story
        next if full_story['story_type'] != 'chore' #TODO Clean up this logic
        updater = StoryUpdater.new(full_story)
        updater.update_on_create
      end
    #Transitions into Accepted automatically tag as "qa-pending"
    when "story_update" 
      project = xml_doc.at_xpath("//project_id").text
      stories = xml_doc.root.xpath("//stories")
      story_ids = stories.xpath(".//id")
      #Labels do not come through on all activities, so we must access raw story data
      story_ids.each do |story|
        grabber = FullStoryGrabber.new(project,story)
        grabber.get_story
        full_story = grabber.full_story
        #Adding a comment will spawn another activity note.  Catch and move on if this is the case.
        next if xml_doc.at_xpath("//author").text.eql? "QA Helper" 
        #If the story is labeled with dev-test, don't update it on status transitions
        next if full_story['story'].has_key?('labels') and full_story['story']['labels'].include? "dev-test"
        updater = StoryUpdater.new(full_story)
        updater.update_on_update
      end
    end
end