from flask import Flask, jsonify, send_file, request
import yaml
import os
from git import Repo
import requests

app = Flask(__name__)

def read_current_config():
    repo = Repo("/app/node-red/")
    origin = repo.remote(name='origin')
    origin.pull()
    with open('/app/node-red/configs/schedule_config.yaml', 'r') as file:
        config = yaml.safe_load(file)
        return config

def save_new_config(config):
    with open('/app/node-red/configs/schedule_config.yaml', 'w') as file:
        yaml.dump(config, file, indent=4)

def commit_and_push():
    username = os.getenv('GITHUB_USER')
    token = os.getenv('GITHUB_TOKEN')
    if (not username or username == ''):
        raise Exception('No Github Username configured with ENV_VAR: GITHUB_USER')
    if (not token or token == ''):
        raise Exception('No Github Token configured with ENV_VAR: GITHUB_TOKEN')
    repo = Repo("/app/node-red/")
    add_file = ['configs/schedule_config.yaml']  # relative path from git root
    repo.index.add(add_file)
    repo.index.commit("Updated schedule through wake-controller")
    origin = repo.remote(name='origin')
    origin.set_url(f"https://{username}:{token}@github.com/NickBorgers/node-red.git")
    origin.push()

def node_red_pull_latest_configs():
    url = 'http://10.212.101.102/inject/6b334e0185781b32'
    result = requests.post(url, json = {})
    print(result)

@app.route('/schedule', methods=['GET'])
def get_current_config():
    return jsonify(read_current_config())

@app.route('/schedule', methods=['PUT'])
def set_new_config():
    save_new_config(request.json)
    commit_and_push()
    node_red_pull_latest_configs()
    return "success"

@app.route('/reports/<path:path>')
def send_report(path):
    return send_from_directory('reports', path)

@app.route('/', methods=['GET'])
def get_page():
    return send_file('static/index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)