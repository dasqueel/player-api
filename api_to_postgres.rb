=begin

a monolithic procedural script that normalizes cbs player api to a normalized object you specified

1) first worry about getting each sports players into a postgres table

2) then worry about handling the name_brief and average_position_age_diff after players have been added

bulk inserts?

=end

require 'unirest'
require 'pg'
sports = ['Baseball','Football','Basketball']

con = PG.connect :dbname => "players", :user => nil, :password => nil

#loop through each sport and create its own table with player members
sports.each {|sport|

	con.exec "DROP TABLE IF EXISTS "+sport
	con.exec "CREATE TABLE "+sport+"(
					Id SERIAL PRIMARY KEY,
					name_brief VARCHAR(20),
					first_name VARCHAR(20),
					last_name VARCHAR(20),
					position VARCHAR(20),
					team VARCHAR(20),
					age INT,
					average_position_age_diff INT
					)"

	api_url = 'http://api.cbssports.com/fantasy/players/list?version=3.0&SPORT='+sport.downcase+'&response_format=JSON'
	resp = Unirest.get(api_url)

	players = resp.body["body"]["players"]

	#also can use prepared statements, wanted to practice them
	con.prepare(sport, 'insert into '+sport+' (first_name, last_name, position, age, team) values ($1, $2, $3, $4, $5)')
	#each through each player
	players.each { |player|
		con.exec_prepared(sport, [ player["firstname"].downcase, player["lastname"].downcase, player["position"].downcase, player["age" ], player["pro_team"].downcase ])
	}

	#now handle for ave_age_dif and name_brief
	#get positions for the sport
	res = con.exec "select distinct position from "+sport+" WHERE age is not null" #use where age is not null to get human names
	positions = res.column_values(0)

	#create a hash that stores the average age for each position
	ave_age_of_pos = {}
	#we will use this variable later to calculate average_position_age_diff for each player
	puts "cacluating average age for each position for "+sport
	positions.each { |pos|

		#get number of players at each position
		players = con.exec "SELECT * FROM "+sport+" WHERE position = '%s' and age is not null;" % [pos]
		num_pos_players = Integer(players.ntuples())

		#get sum of the ages of players
		res = con.exec "SELECT SUM(age) FROM "+sport+" WHERE position = '%s';" % [pos]
		age_sum = Integer(res.getvalue(0,0))

		#divide the total age by number of players, to get average age
		ave_age_pos = age_sum / num_pos_players

		#add position and average age to ave_age_of_pos hash
		ave_age_of_pos[pos] = ave_age_pos
	}

	#add average_position_age_diff to each player if they have an age field
	#aswell add name_brief field
	puts "cacluating average_position_age_diff for each player in "+sport
	puts "entering name_brief for each player in "+sport
	players = con.exec "select * from "+sport
	players.each {|player|

		#insert average_position_age_diff for each player
		#only calculate average_position_age_diff, if cbs api gave a player an age
		if player["age"] != nil
			#cacluate the age dif the player
			#if you wanted absolute difference, add .abs to next line
			age_dif = (player["age"].to_i - ave_age_of_pos[player["position"]])
			#update the player row with the calculated average
			con.exec "update "+sport+" set average_position_age_diff = %s where id = %s" % [age_dif, player["id"]]
		end

		#now apply the unique name_bried field for the given player
		#could add this logic within the previous players for loop, for simplicity sake lets loop over every play again
		if player["first_name"] == "" #for some reason, if player["first_name"] != "", throws edge case errors

		else
			#now handle the unique name_brief field for the given player
			if sport == "Baseball"
				#create name_brief for player name Bryce Harper -> B. H.
				name_brief = player["first_name"][0].to_s.upcase+". "+player["last_name"][0].to_s.upcase+"."
				con.exec "update "+sport+" set name_brief = '%s' where id = %s" % [con.escape_string(name_brief), player["id"]]
			end

			if sport == "Football"
				#create name_brief for player name Stefon Diggs -> S Diggs.
				name_brief = player["first_name"][0].to_s.upcase+". "+player["last_name"].to_s.capitalize
				con.exec "update "+sport+" set name_brief = '%s' where id = %s" % [con.escape_string(name_brief), player["id"]]
			end

			if sport == "Basketball"
				#create name_brief for player name Karl-Anthon Towns -> Karl-Anthon T.
				name_brief = player["first_name"].to_s.capitalize+" "+player["last_name"][0].to_s.upcase+"."
				con.exec "update "+sport+" set name_brief = '%s' where id = %s" % [con.escape_string(name_brief), player["id"]]
			end
		end
	}

}

puts "cbs api players to nominal postgres COMPLETED!! :D"
