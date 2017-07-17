# player-api
code challenge solution

Haven't used postgres that much so I decided to learn something new with postgres

1) install postgresql

homebrew

```
brew install postgresql
```

linux

```
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
```

2) install bundler (if havent already)

```
gem install bundler
```

3) install gems

```
bundle install
```

4) normalize cbs play api to postgres table

```
ruby api_to_postrgres.rb
```

5) start sinatra app
```
ruby app.rb
```

6) you should be good to go, try sample queries

http://localhost:4567/sports/football?position=qb&age=27

or

http://localhost:4567/sports/basketball?position=c
