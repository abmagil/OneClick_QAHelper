require 'sinatra'
require 'nokogiri'
require 'httparty'
require_relative 'FullStoryGrabber'

get '/' do
  "Why are you GETting this page?"
end

post '/' do
  xml_doc = Nokogiri::XML(request.body)
  #At present, no need to handle any transition that isn't a story update
  response =""
  case xml_doc.at_xpath("//event_type").text
    when "story_update" 
      project = xml_doc.at_xpath("//project_id").text
      stories = xml_doc.root.xpath("//stories")
      story_ids = stories.xpath(".//id")
      #It's unclear to me that labels will necessarily come on update, so pull the issue and edit from that.
      story_ids.each do |story|
        grabber = FullStoryGrabber.new(project,story)
        grabber.get_story
        case grabber.fullStory['story']['current_state']
        when "accepted"
          update_with_qa_pending
        when "rejected"
          update_with_no_qa
        end
        labels = grabber.get_labels
      end
      response
  end
end

def update_with_qa_pending
  
end

def update_with_no_qa
  
end