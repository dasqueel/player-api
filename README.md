# player-api
code challenge solution

Haven't used postgres that much so I decided to learn something new with postgres

1) clone repo and cd into player-api

```
git clone https://github.com/dasqueel/player-api.git
cd player-api
```

2) install postgresql (if havent)

homebrew

```
brew install postgresql
```

linux

```
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
```

3) create a postgres database named "players"

```
createdb players
```


4) install bundler (if havent already)

```
gem install bundler
```

5) install gems

```
bundle install
```

6) normalize cbs play api to postgres table

```
ruby api_to_postrgres.rb
```

7) start sinatra app
```
ruby app.rb
```

8) you should be good to go, try sample queries

http://localhost:4567/sports/football?position=qb&age=27

or

http://localhost:4567/sports/basketball?position=c
