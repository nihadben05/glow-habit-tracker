import json
import urllib.request

url = 'http://localhost:3001/api/auth/login'
data = json.dumps({'email': 'test@example.com', 'password': 'password123'}).encode()
req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})
resp = urllib.request.urlopen(req)
body = json.loads(resp.read().decode())
print('LOGIN', body)
token = body['token']

url = 'http://localhost:3001/api/planner'
data = json.dumps({'title':'API Task','description':'Check planner create','date':'2026-05-02','priority':0,'time':'15:00','colorValue':4280391411}).encode()
req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json', 'Authorization': f'Bearer {token}'})
resp = urllib.request.urlopen(req)
body = json.loads(resp.read().decode())
print('CREATE', body)
