#!/usr/bin/ruby

=begin

test ruby script to play around with code

=end

require 'pg'
require 'json'

begin

    con = PG.connect :dbname => 'players', :user => 'squeel'

    sport = "Basketball"
    #resp = con.exec "select * from "+sport
    #resp = con.exec "select json_agg(t) from (select * from "+sport+") t"
    #resp = con.exec "select array_to_json(array_agg(row_to_json(t))) from ( select * from Football) t"
    #x = resp
    #resp = con.exec "select * from Basketball"
    resp = (con.exec "select array_to_json(array_agg(t)) from (select * from "+sport+" where age = '55') t").values
    #resp = con.exec "select array_to_json(array_agg(t)) from (select * from "+sport+") t"
    puts resp[0].any?
    #puts JSON.pretty_generate(x)
    #resp = con.exec "select json_agg(t) from (select * from "+sport+") t"
    #my_object = { :array => [1, 2, 3, { :sample => "hash"} ], :foo => "bar" }
    #puts JSON.pretty_generate(my_object)
    #resp = (con.exec "SELECT row_to_json(row) from (select * from "+sport+") row")
    #puts resp.to_json
    #puts JSON.pretty_generate(x)
    # x.each {|row|
    #     puts row
    # }

    # players = con.exec "select * from "+sport+" where age is not null"
    # players.each {|p|
    #     puts p
    # }
    #s = "update "+sport+" set name_brief = %s where id = %s" % ["D. A.", 2]
    #puts s
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