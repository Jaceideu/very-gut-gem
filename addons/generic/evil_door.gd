extends StaticBody3D

var was_interacted_with := false

func interact(player_path: String):
	if was_interacted_with: return
	
	was_interacted_with = true
	
	
