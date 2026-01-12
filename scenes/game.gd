extends Node2D

#visible et modifiable dans l’inspecteur/stock la scene dans une var accessible
@export var pipe_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 4
var screen_size: Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200 #valeur maximale du décalage vertical aléatoire

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	new_game()
	
func new_game():
	#reset variables
	game_running = false
	game_over = false
	score = 0
	$scoreLabel.text = "SCORE " + str(score)
	$gameOver.hide() #cache le bouton reset (ici cache directement la scene contenant le bouton)
	get_tree().call_group("pipes", "queue_free") #Supprime proprement tous les nodes du groupe pipes en une seule commande
	scroll = 0
	pipes.clear()
	generate_pipes()
	$player.reset()
	
func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $player.flying:
						$player.flap()
						check_top()
 
func start_game():
	game_running = true
	$player.flying = true
	$player.flap()
	$pipeTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0 #quand décalage atteint la largeur de l’écran on remet scroll à 0
		$ground.position.x = -scroll #décale le sol vers la gauche
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED  #déplace chaque tuyau vers la gauche à la même vitesse que le sol

func _on_pipe_timer_timeout() -> void:
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate() #= node vivant manipulable
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE) #centre verticalement + décalage aléatoire pour varier hauteur tuyau
	pipe.hit.connect(player_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)
	
func scored():
	score += 1
	$scoreLabel.text = "SCORE " + str(score)

func check_top():
	if $player.position.y<0:
		$player.falling = true
		stop_game()
		
func stop_game():
	$pipeTimer.stop()
	$gameOver.show()
	$player.flying = false
	game_running = false
	game_over = true
		
func player_hit():
	$player.falling = true
	stop_game()

func _on_ground_hit() -> void:
	$player.falling = false
	stop_game()

func _on_game_over_restart() -> void:
	new_game()
