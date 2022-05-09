import json
import os
from os.path import exists
import signal
import sys
from flask import Flask,request,jsonify, send_file
from itsdangerous import base64_decode


userdata = {}
UPLOAD_PATH = '/chall_pics'
num_runs=0
def save():
    with open('data.json', 'w') as f:
        json.dump(userdata,f)



app = Flask(__name__)
@app.before_first_request
def setup():
    if exists('data.json'):
        with open('data.json') as f:
            userdata=json.load(f)

@app.route('/')
def hello():
    return 'howdy';

@app.route('/<user>.jpg')
def picture(user):
    
    return send_file(user+'.jpg');

@app.route('/users')
def users():
    tmp = []
    for user in userdata.keys():
        tmp.append(user)
    return jsonify(tmp)


@app.route('/submit',methods=['POST'])
def gib():
    print(request.headers)
    data= request.form.to_dict()
    tmp ={
        'user':data['user'],
        'ts':data['timestamp'],
        'lat':data['lat'],
        'lon':data['lon'],
        'hint':data['hint'],
    }
    userdata[data['user']] = tmp
    filemaybe = base64_decode( data['image'])
    with open(data['user']+'.jpg','wb') as f:
        f.write(filemaybe)
    save()

    return 'roger roger'

@app.route('/challenge/<user>')
def chall(user):
    return userdata[user]

