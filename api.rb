=begin

things to improve
	error message in json?  what is typical way to handle that e.x. {"error":"invalid query parameter"}
=end

require 'sinatra'
#require 'sinatra/reloader'
require 'pg'

con = PG.connect :dbname => "players", :user => nil, :password => nil

get '/sports/:sport' do
	content_type :json

	#get sport from path variable
	sport = params['sport']
	#valid sports
	sports = ["football","basketball","baseball"]
	#valid query variables
	valid_query_params = ["team","age","position","first_name","last_name","name_brief","average_position_age_diff"]
	#get requests query_parameters
	query_params = request.env['rack.request.query_hash']

	#make sure the passed path sport parameter is valid, e.x. hockey isnt a valid sport
	if not sports.include? params['sport']
		#not a valid sport, so repond with message saying its not valid
		return sport+" a not valid sport"
	end

	#if no query parameters were passed, send all players
	if query_params.keys.empty?
		#it is a valid sport, return json of all players
		json_resp = (con.exec "select array_to_json(array_agg(t)) from (select * from "+sport+") t").values
		#returns list of json player objects
		json_resp[0]
	else

		#check if any invalid query parameters were passed
		# invalid_query_params = ((query_params.keys - valid_query_params) + (valid_query_params - query_params.keys))
		invalid_query_params = []
		query_params.keys.each {|param|
			if not valid_query_params.include? param
				invalid_query_params.push(param)
			end
		}
		#there are invalid params, concatenate them for a invalid message
		#puts invalid_query_params
		if invalid_query_params.any?
			invalid_message = "invalid query parameters: "
			invalid_query_params.each {|param| invalid_message = invalid_message+param+" "}
			return invalid_message
		end


		#its a valid sport and query paramereters were passed, now process a where clause sql query

		#where_string is a string that will be injected into the postgres query
		where_string = "where "
		#loop through the requests query parameters and add them the where_string
		query_params.each_with_index do |(query_pram_name, query_pram_val), i|

			#prepare the where substring for the postgres query
			if i == query_params.size - 1
				where_string = where_string + query_pram_name + " = "+ "'"+query_pram_val.downcase+"'"
			else
				where_string = where_string + query_pram_name + " = " + "'"+query_pram_val.downcase+"'" + " and "
			end

		end

		#execute postgres query
		statement = "select array_to_json(array_agg(t)) from (select * from "+sport+" "+where_string+") t"
		json_resp = (con.exec statement).values
		#return the json response
		if json_resp[0].any?
			json_resp[0]
		#for some goofy reason sinatra throws an error with responding with an empty sql json response
		else
			[].to_json
		end
	end
end

