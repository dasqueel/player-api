# player-api
code challenge solution

Haven't used postgres that much so I decided to learn something new with postgres

1) normalize cbs play api to postgres table

```
ruby api_to_postrgres.rb
```

2) start sinatra app
```
ruby app.rb
```

3) you should be good to go, try sample queries

http://localhost:4567/sports/football?position=qb&age=27

or 

http://localhost:4567/sports/basketball?position=c
