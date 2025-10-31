extends Node

var current_scene = null

func _ready():
	print("[SceneManager] Initializing...")
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("[SceneManager] Current scene: ", current_scene.name if current_scene else "None")

func goto_scene(path: String):
	print("[SceneManager] Attempting to change scene to: ", path)
	
	# Load new scene first
	var loader = ResourceLoader.load_threaded_request(path)
	if loader == null:
		print("[SceneManager] ERROR: Failed to start scene load!")
		return
		
	print("[SceneManager] Loading scene...")
	while true:
		var status = ResourceLoader.load_threaded_get_status(path)
		match status:
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				print("[SceneManager] ERROR: Invalid scene resource!")
				return
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				# Still loading
				continue
			ResourceLoader.THREAD_LOAD_FAILED:
				print("[SceneManager] ERROR: Scene load failed!")
				return
			ResourceLoader.THREAD_LOAD_LOADED:
				# Successfully loaded
				break
	
	var new_scene = ResourceLoader.load_threaded_get(path)
	if new_scene == null:
		print("[SceneManager] ERROR: Could not get loaded scene!")
		return
	
	# Instance the new scene
	print("[SceneManager] Instantiating new scene...")
	var instance = new_scene.instantiate()
	
	# Get the root node
	var root = get_tree().root
	
	# Queue free the current scene
	if current_scene:
		print("[SceneManager] Removing current scene: ", current_scene.name)
		current_scene.queue_free()
	
	# Add new scene
	print("[SceneManager] Adding new scene: ", instance.name)
	root.add_child(instance)
	current_scene = instance