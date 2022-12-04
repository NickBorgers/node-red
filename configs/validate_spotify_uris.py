import yaml
import requests
# Read our config file to validate
with open('music_config.yaml', 'r') as file:
    music_config = yaml.safe_load(file)
# Iterate over each type of music
for music_type in music_config['music']:
    music_type_object = music_config['music'][music_type]
    for playback_option in music_type_object['playback_options']:
        if playback_option['command'] == 'group.queue.urispotify':
            components = playback_option['uri'].split(':')
            resource = components[len(components)-1]
            response = requests.get('https://open.spotify.com/playlist/' + resource)
            if response.status_code != 200:
              print("Could not find Spotify playlist identified by: " + resource)
              print("Currently processing: " + music_type)
              exit(1)
