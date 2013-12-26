require 'sinatra'
require 'json'
require 'httparty'
require 'haml'
require_relative 'FullStoryGrabber'
require_relative 'StoryUpdater'

get '/' do
	haml :index
end

post '/' do
	json_response = JSON.parse(request.body.read)
	#Adding a comment will spawn another activity note.  Catch and move on if this is the case.
	if json_response["performed_by"]["id"].eql? "1077736"	# 	This is the QA Helper user's ID number
		return
	end 
	project = json_response["project"]["id"]
	change_ary = json_response["changes"]
	change_ary.each do |story|
		story_id = story["id"]
		#Labels do not come through on all activities, so we must access raw story data
		case story["change_type"]
		when "story_create"
			full_story = FullStoryGrabber.new(project,story_id).full_story
			updater = StoryUpdater.new(full_story)
			updater.update_on_create
		when "update"
			full_story = FullStoryGrabber.new(project,story_id).full_story
			updater = StoryUpdater.new(full_story)
			updater.update_on_update
		end
	end
	puts "post"
end