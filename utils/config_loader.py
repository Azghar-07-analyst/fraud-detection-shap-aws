import json

def load_config(config_path):
	with open(config_path) as f:
		config = json.load(f)
	print(f"Config loaded: {config['dataset_name']}")
	return config 