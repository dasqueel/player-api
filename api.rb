=begin

things to improve
	json error message?  what is typical way to handle that

=end

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'json'

con = PG.connect :dbname => 'players', :user => 'squeel'

get '/sports/:sport' do
	content_type :json

	sport = params['sport']
	sports = ["football","basketball","baseball"]
	valid_query = ["team","age","position"]
	query_params = request.env['rack.request.query_hash']

	#if no filtering query parameters were passed, send all players
	if query_params.keys.empty?
		if not sports.include? params['sport']
			return sport+" a not valid sport"
		else
			resp = (con.exec "select array_to_json(array_agg(t)) from (select * from "+sport+") t").values
			resp[0]
		end
	else
		#return params.to_s
		string_query_params = ["name_brief","first_name","last_name","position"]
		where_string = "where "
		query_params.each_with_index do |(k, v), i|

			#add quotes for string parameters
			if string_query_params.include? k
				v = "'"+v.to_s+"'"
			end

			if i == query_params.size - 1
				where_string = where_string + k.to_s + " = "+ v.to_s
			else
				where_string = where_string + k.to_s + " = " + v.to_s + " and "
			end

		end
		statement = "select array_to_json(array_agg(t)) from (select * from "+sport+" "+where_string+") t"
		resp = (con.exec statement).values
		resp[0]
	end

	# if params == []

	# end

	# invavlid_params = []
	# params.each {|param|
	# 	if not valid.include? param
	# 		invavlid_params.push(param)
	# 	end
	# }
	# #puts (legit_params & params).to_a
	# #(legit_params ^ params).to_a.to_s
	# invavlid_params
	# params
end