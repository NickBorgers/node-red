import yaml
import requests
import time
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Set up a session with retries
session = requests.Session()
retries = Retry(
    total=3, 
    backoff_factor=1, 
    status_forcelist=[429, 500, 502, 503, 504],
    allowed_methods=["GET"]
)
adapter = HTTPAdapter(max_retries=retries)
session.mount('http://', adapter)
session.mount('https://', adapter)

# Read our config file to validate
with open('music_config.yaml', 'r') as file:
    music_config = yaml.safe_load(file)

# Iterate over each type of music
for music_type in music_config['music']:
    music_type_object = music_config['music'][music_type]
    for playback_option in music_type_object['playback_options']:
        if playback_option['media_type'] == 'playlist':
            components = playback_option['uri'].split(':')
            if components[0] != 'spotify':
                continue
            resource = components[-1]
            try:
                response = session.get(f'https://open.spotify.com/playlist/{resource}')
                if response.status_code == 200:
                    print(f"Found Spotify playlist {resource} as part of {music_type} playback options")
                else:
                    print(f"Could not find Spotify playlist identified by: {resource}")
                    print(f"Currently processing: {music_type}")
                    print(f"HTTP Response: {response.status_code}")
                    print(response.text)
                    exit(1)
            except requests.RequestException as e:
                print(f"Request failed for playlist {resource}: {str(e)}")
                exit(1)
            time.sleep(0.5)
