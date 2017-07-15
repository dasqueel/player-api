require 'unirest'
require 'pg'

#first worry about getting each sports players into a postgres table
#then worry about creaing the name_brief and average_position_age_diff after players have been added
sports = ['Baseball','Football','Basketball']

con = PG.connect :dbname => 'players', :user => 'squeel'


sports.each {|sport|

	# con.exec "DROP TABLE IF EXISTS "+sport
	# con.exec "CREATE TABLE "+sport+"(
	# 				Id SERIAL PRIMARY KEY,
	# 				name_brief VARCHAR(20),
	# 				first_name VARCHAR(20),
	# 				last_name VARCHAR(20),
	# 				position VARCHAR(20),
	# 				age INT,
	# 				average_position_age_diff INT
	# 				)"

	# apiUrl = 'http://api.cbssports.com/fantasy/players/list?version=3.0&SPORT='+sport.downcase+'&response_format=JSON'
	# resp = Unirest.get(apiUrl)

	# players = resp.body["body"]["players"]

	# con.prepare(sport, 'insert into '+sport+' (first_name, last_name, position, age) values ($1, $2, $3, $4)')
	# players.each { |player|
	# 	#print player
	# 	con.exec_prepared(sport, [ player["firstname"], player["lastname"], player["position"], player["age" ] ])
	# 	#con.exec "insert into "+sport+" (first_name, last_name, position, age) values (%s, %s, %s, %s)" % [ player["firstname"], player["lastname"], player["position"], player["age" ] ]
	# }

	#get positions for the sport
	res = con.exec "select distinct position from "+sport+" WHERE age is not null"
	positions = res.column_values(0)
	#puts positions

	#create a hash that stores the average age for each position
	#we will use this variable later to calculate average_position_age_diff
	ave_age_of_pos = {}
	positions.each { |pos|
		players = con.exec "SELECT * FROM "+sport+" WHERE position = '%s' and age is not null;" % [pos]
		num_pos_players = Integer(players.ntuples())

		#get sum of the ages of players
		res = con.exec "SELECT SUM(age) FROM "+sport+" WHERE position = '%s';" % [pos]
		age_sum = Integer(res.getvalue(0,0))

		#divide the total age by number of players, to get average age
		ave_age_pos = age_sum / num_pos_players

		#puts pos, ave_age_of_pos
		ave_age_of_pos[pos] = ave_age_pos
	}

	#add average_position_age_diff to each player if they have an age field
	#aswell add name_brief field
	players = con.exec "select * from "+sport
	players.each {|player|

		#insert average_position_age_diff for each player
		#only calculate average_position_age_diff, if cbs api gave a player an age
		if player["age"] != nil
			#cacluate the age dif the player
			age_dif = (ave_age_of_pos[player["position"]] - Integer(player["age"])).abs
			#update the player row with the calculated average
			con.exec "update "+sport+" set average_position_age_diff = %s where id = %s" % [age_dif, player["id"]]
		end

		#now apply the unique name_bried field for the given player
		#could add this logic within the previous players for loop, for simplicity sake lets loop over every play again
		if player["first_name"] == ""

		else
			#now apply the unique name_brief field for the given player
			if sport == "Baseball"
				#resp = con.exec "select first_name, last_name from "+sport+" where id = %s" % [player["id"]]
				#first = resp.field_values("first_name")[0][0].upcase
				#last = resp.field_values("last_name")[0][0].upcase
				#puts player["first_name"][0].to_s+". "+player["last_name"][0].to_s+"."
				name_brief = player["first_name"][0].to_s+". "+player["last_name"][0].to_s+"."
				puts name_brief
				con.exec "update "+sport+" set name_brief = '%s' where id = %s" % [name_brief, player["id"]]
				con.exec statement
			end

			if sport == "Football"
				#resp = con.exec "select first_name from "+sport+" where id = %s" % [player["id"]]
				#first = resp.field_values("first_name")[0][0].upcase
				name_brief = player["first_name"][0].to_s+". "+player["last_name"].to_s
				#puts name_brief
				con.exec "update "+sport+" set name_brief = '%s' where id = %s" % [con.escape_string(name_brief), player["id"]]
			end

			if sport == "Basketball"
				name_brief = player["first_name"].to_s+" "+player["last_name"][0].to_s+"."
				#puts name_brief
				con.exec "update "+sport+" set name_brief = '%s' where id = %s" % [con.escape_string(name_brief), player["id"]]
			end
		end
	}
	#puts ave_age_of_pos

}

#print positions.field_values("position")
#positions.each {|p| puts p}
#print positions.values

=begin
sports.each { |sport|

	con = PG.connect :dbname => 'players', :user => 'squeel'

	con.exec "DROP TABLE IF EXISTS "+sport
	con.exec "CREATE TABLE "+sport+"(
					Id SERIAL PRIMARY KEY,
					name_brief VARCHAR(20),
					first_name VARCHAR(20),
					last_name VARCHAR(20),
					position VARCHAR(20),
					age INT,
					average_position_age_diff INT
					)"

	apiUrl = 'http://api.cbssports.com/fantasy/players/list?version=3.0&SPORT='+sport.downcase+'&response_format=JSON'
	resp = Unirest.get(apiUrl)

	players = resp.body["body"]["players"]

	con.prepare('statement', 'insert into '+sport+' (first_name, last_name, position, age) values ($1, $2, $3, $4)')
	players.each { |player|
		#print player
		con.exec_prepared('statement', [ player["firstname"], player["lastname"], player["position"], player["age" ] ])
	}

	#calculate average age for each position
	#get positions for the sport
	res = con.exec "select distinct position from "+sport+" WHERE age is not null"
	positions = res.column_values(0)

	ave_age_of_pos = {}
	positions.each { |pos|
		players = con.exec "SELECT * FROM "+sport+" WHERE position = '%s' and age is not null;" % [pos]
		num_pos_players = Integer(players.ntuples())

		#get sum of the ages of players
		res = con.exec "SELECT SUM(age) FROM "+sport+" WHERE position = '%s';" % [pos]
		age_sum = Integer(res.getvalue(0,0))

		#divide the total age by number of players, to get average age
		ave_age_pos = age_sum / num_pos_players

		#puts pos, ave_age_of_pos
		ave_age_of_pos[pos] = ave_age_pos
	}

	puts ave_age_of_pos
}
=end

#puts data
#data.each {|d| puts d}
=begin
	{
	id:
	name_brief:
	first_name:
	last_name:
	position:
	age:
	average_position_age_diff:
	}

=end

=begin
begin

    con = PG.connect :dbname => 'players', :user => 'squeel'

    con.exec "DROP TABLE IF EXISTS Baseball"
    con.exec "CREATE TABLE Baseball(
    				Id SERIAL PRIMARY KEY,
    				name_brief VARCHAR(20),
    				first_name VARCHAR(20),
    				last_name VARCHAR(20),
    				position VARCHAR(20),
    				age INT,
    				average_position_age_diff INT)"
    con.exec "INSERT INTO players VALUES(1,'Audi',52642)"


rescue PG::Error => e

    puts e.message

ensure

    con.close if con

end

=end
