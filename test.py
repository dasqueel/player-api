import requests

r = requests.get("http://localhost:4567/sports/football")

json = r.json()
for j in json: print j