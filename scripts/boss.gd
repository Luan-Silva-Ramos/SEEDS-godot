extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# VARIÁVEIS DE STATUS
var hp = 15
var speed = 150.0 # Mais rápido que o inimigo comum!
var dash_speed = 400.0
var target = null
var can_attack = true

# A MÁQUINA DE ESTADOS DO BOSS
# Adicionado INTRO para a cena da fogueira
enum State { INTRO, IDLE, CHASE, DASH, MELEE, THROW, TELEPORT }
var current_state = State.IDLE

@onready var visual = $Sprite2D # AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var hurtbox = $Hurtbox

# Adicione esta função no Boss.gd para ser chamada quando a cutscene começar
func preparar_cutscene():
	current_state = State.INTRO
	velocity = Vector2.ZERO
	if visual.sprite_frames.has_animation("sitting"):
		visual.offset = Vector2(0,-18)
		visual.play("sitting")
	else:
		visual.play("idle")
		visual.offset = Vector2(0,-15)

# Função que o Trigger vai chamar para iniciar o combate de fato
func iniciar_lutaboss(player_node):
	target = player_node
	
	# Se você tiver a animação dele se levantando da fogueira:
	if visual.sprite_frames.has_animation("stand_up"):
		visual.scale = Vector2(0.13,0.13)
		visual.offset = Vector2(0,-60)
		visual.play("stand_up")
		await visual.animation_finished
	visual.scale = Vector2(0.2, 0.2)
	visual.offset = Vector2(0,-15)
	# Muda para o estado de perseguir/combate
	current_state = State.CHASE

func _ready():
	visual.play("idle")

func _physics_process(delta):
	# Gravidade sempre ativa
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Lógica por Estado
	match current_state:
		State.INTRO:
			# Fica parado durante a Cutscene
			velocity.x = 0
			
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, 800 * delta)
			visual.play("idle") # Garante que volte para a animação Idle quando parado
			
		State.CHASE:
			state_chase()
			
		State.DASH, State.MELEE, State.TELEPORT, State.THROW:
			# Durante ataques e teleporte, o movimento no eixo X é controlado pelas próprias funções de habilidade
			pass
		
	move_and_slide()

# --- FUNÇÕES DE ESTADO ---
func state_chase():
	if target == null:
		current_state = State.IDLE
		return

	var distance = abs(target.global_position.x - global_position.x)
	var direcao = sign(target.global_position.x - global_position.x)
	
	# Ajusta para onde o Boss está olhando
	if direcao != 0:
		visual.flip_h = (direcao > 0) # Mantida a padronização: flip_h = true quando anda para a esquerda
	
	if can_attack:
		velocity.x = 0 # Para antes de iniciar a transição de ataque
		if distance <= 60:
			start_melee()
		elif distance > 60 and distance < 200:
			start_dash()
		elif distance >= 200:
			start_teleport()
	else:
		# Se não puder atacar ainda (em cooldown), continua se movendo até o jogador
		velocity.x = direcao * speed
		if abs(velocity.x) > 0.1:
			visual.play("chase")
		else:
			visual.play("idle")

# ==========================================
# HABILIDADES DO BOSS
# ==========================================

func start_dash():
	can_attack = false
	current_state = State.DASH
	
	visual.play("dash_attack")
	
	# Calcula direção do avanço
	var direcao = sign(target.global_position.x - global_position.x) if target else 1.0
	velocity.x = direcao * dash_speed
	
	if direcao != 0:
		visual.flip_h = (direcao > 0)
	
	# Tempo de duração do avanço
	await get_tree().create_timer(0.3).timeout
	
	if target != null:
		start_melee() # Emenda o ataque corpo a corpo
	else:
		current_state = State.CHASE
		can_attack = true

func start_melee():
	can_attack = false
	current_state = State.MELEE
	velocity.x = 0 # Parado para atacar
	
	# Ajusta direção e posição da Hitbox
	if target != null:
		var direcao = sign(target.global_position.x - global_position.x)
		if direcao != 0:
			visual.flip_h = (direcao > 0)
		
		# Reposiciona a Hitbox baseada para onde o Boss está virado
		if visual.flip_h:
			hitbox.position.x = -abs(hitbox.position.x)
		else:
			hitbox.position.x = abs(hitbox.position.x)

	visual.play("attack")
	
	# Tempo de preparo (Startup)
	await get_tree().create_timer(0.2).timeout 
	
	# LIGA A HITBOX
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	
	await get_tree().create_timer(0.2).timeout 
	
	# DESLIGA A HITBOX
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	current_state = State.CHASE
	
	# Cooldown antes de poder atacar novamente
	await get_tree().create_timer(0.8).timeout
	can_attack = true

func start_teleport():
	can_attack = false
	current_state = State.TELEPORT
	velocity.x = 0
	
	# 1. SUMINDO NA NÉVOA
	visual.play("teleporte") 
	
	# Fica invulnerável desativando o Hurtbox
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	
	# Aguarda a animação de sumir (IMPORTANTE: A animação 'teleporte' NÃO pode ter LOOP ativado no AnimatedSprite2D)
	await visual.animation_finished 
	visual.visible = false 
	
	# 2. O TELETRANSPORTE
	if target != null:
		# Pega a direção que o jogador está virado para aparecer nas costas dele
		var lado_do_jogador = 1
		if "visual" in target and target.visual.flip_h:
			lado_do_jogador = -1
		elif "sprite" in target and target.sprite.flip_h:
			lado_do_jogador = -1
			
		global_position.x = target.global_position.x - (lado_do_jogador * 60)
		
		# Vira o Boss em direção ao Player
		var nova_direcao = sign(target.global_position.x - global_position.x)
		if nova_direcao != 0:
			visual.flip_h = (nova_direcao < 0)
	
	# Pausa de pânico/névoa
	await get_tree().create_timer(0.4).timeout 
	
	# 3. REAPARECENDO
	visual.visible = true
	visual.play_backwards("teleporte") 
	
	await visual.animation_finished
	
	# Reativa vulnerabilidade
	hurtbox.set_deferred("monitoring", true)
	hurtbox.set_deferred("monitorable", true)
	
	# Ataca imediatamente
	start_melee()

# --- SINAIS DA VISÃO ---
func _on_visao_body_entered(body):
	if body.name == "Player":
		target = body
		# Só inicia a perseguição automática se não estiver rodando a Cutscene
		if current_state != State.INTRO:
			current_state = State.CHASE
			print("Boss: 'TE ACHEI!'")

func _on_visao_body_exited(body):
	if body.name == "Player":
		target = null
		current_state = State.IDLE
		print("Boss: 'Para onde ele foi?'")
