#!/usr/bin/ruby

require 'pg'

begin

    con = PG.connect :dbname => 'players', :user => 'squeel'

=begin
    con.exec "DROP TABLE IF EXISTS Cars"
    con.exec "CREATE TABLE Cars(Id INTEGER PRIMARY KEY,
        Name VARCHAR(20), Price INT)"
    con.exec "INSERT INTO Cars VALUES(1,'Audi',52642)"
    con.exec "INSERT INTO Cars VALUES(2,'Mercedes',57127)"
    con.exec "INSERT INTO Cars VALUES(3,'Skoda',9000)"
    con.exec "INSERT INTO Cars VALUES(4,'Volvo',29000)"
    con.exec "INSERT INTO Cars VALUES(5,'Bentley',350000)"
    con.exec "INSERT INTO Cars VALUES(6,'Citroen',21000)"
    con.exec "INSERT INTO Cars VALUES(7,'Hummer',41400)"
    con.exec "INSERT INTO Cars VALUES(8,'Volkswagen',21600)"
    con.exec "INSERT INTO Cars VALUES(9,'Oldsmobile',28550)"
=end
    sport = "Basketball"
    # players = con.exec "select * from "+sport+" where age is not null"
    # players.each {|p|
    #     puts p
    # }
    s = "update "+sport+" set name_brief = %s where id = %s" % ["D. A.", 2]
    puts s
    #con.exec "update "+sport+" set name_brief = %s where id = %s" % [name_brief, player["id"]]
    # resp = con.exec "select first_name, last_name from "+sport+" where id = %s" % [2]
    # first = resp.field_values("first_name")[0][0].upcase
    # last = resp.field_values("last_name")[0][0].upcase
    # initial = first+". "+last+"."
    # puts initial

rescue PG::Error => e

    puts e.message

ensure

    con.close if con

end