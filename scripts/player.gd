extends CharacterBody2D
@onready var hitbox = $Hitbox

# 1. NOSSAS VARIÁVEIS DE VELOCIDADE
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DODGE_SPEED = 500.0 # A esquiva é mais rápida que o andar normal

var hp = 5 #Vida do Player
@onready var visual = $Sprite2D
@onready var hurtbox = $Hurtbox #pra os I-frames
@onready var life_bar = $HUD/LifeBar
@onready var stamina_bar = $HUD/StaminaBar

# vars da Stamina
var max_stamina = 100.0
var stamina = 100.0
var stamina_regen = 40.0 #Custo de recuperação da stamina
var attack_cost = 30.0 #Ataque custo
var dodge_cost = 40.0 #Esquiva custo

# 2. A MÁQUINA DE ESTADOS
# Aqui definimos o que o personagem pode estar fazendo
enum State { NORMAL, ATTACKING, DODGING, HURT }
var current_state = State.NORMAL

# 3. VARIÁVEL PARA LEMBRAR A DIREÇÃO
# 1 significa direita, -1 significa esquerda
var facing_direction = 1 

func _ready():
	life_bar.max_value = hp
	life_bar.value = hp
	
	stamina_bar.max_value = max_stamina
	stamina_bar.value = stamina

func _physics_process(delta: float) -> void:
	# A gravidade sempre funciona, para ele não flutuar no meio do ataque
	if not is_on_floor():
		velocity += get_gravity() * delta

	# O jogo checa o Estado Atual e decide qual bloco de código ler
	if current_state == State.NORMAL:
		state_normal()
	elif current_state == State.DODGING:
		state_dodging()
	elif current_state == State.ATTACKING:
		state_attacking()
	elif current_state == State.HURT:
		state_hurt()
	# Recupera a stamina se o jogador não estiver morto
	if hp > 0:
		# move_toward faz o número subir aos poucos até o limite (max_stamina)
		stamina = move_toward(stamina, max_stamina, stamina_regen * delta)
		
	# Atualiza a barra verde na tela o tempo todo
	stamina_bar.value = stamina
	# Aplica o movimento na tela (padrão da Godot)
	move_and_slide()

func state_normal():
	# Só obedece aos comandos se estiver no estado NORMAL
	
	# -- ATAQUE --
	if Input.is_action_just_pressed("attack") and is_on_floor() and stamina >= attack_cost:
		stamina -= attack_cost
		visual.play("attack")
		start_attack()
		return # O 'return' faz o código parar aqui, impedindo ele de andar junto

	# -- ESQUIVA --
	if Input.is_action_just_pressed("dodge") and is_on_floor() and stamina >= dodge_cost:
		stamina -= dodge_cost
		start_dodge()
		return 

	# -- PULO (Seu código) --
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	# -- ANDAR E VIRAR O SPRITE --
	if Input.is_action_pressed("move_right"):
		velocity.x = SPEED
		visual.flip_h = false
		visual.play("run") # <-- TOCA A CORRIDA
		facing_direction = 1
		hitbox.position.x = 0
	
		
	elif Input.is_action_pressed("move_left"):
		velocity.x = -SPEED
		visual.flip_h = true
		visual.play("run") # <-- TOCA A CORRIDA
		facing_direction = -1
		hitbox.position.x = -54
		
	else:
		velocity.x = 0
		visual.play("idle") # <-- TOCA PARADO QUANDO SOLTA O BOTÃO

# ==========================================
# FUNÇÕES DE AÇÃO (O QUE ACONTECE QUANDO APERTA O BOTÃO)
# ==========================================

func start_attack():
	
	current_state = State.ATTACKING
	velocity.x = 0 # O personagem CRAVA no chão
	
	# ==========================================
	# FASE 1: PREPARAÇÃO (Wind-up)
	# A animação começou, mas a espada está levantando.
	# Ajuste esse tempo para bater exatamente com o frame que a espada desce!
	await get_tree().create_timer(0.2).timeout 
	
	# ==========================================
	# FASE 2: O GOLPE (Active Frames)
	# A espada desceu! LIGA A HITBOX AGORA!
	hitbox.visible = true
	hitbox.set_deferred("monitoring", true) 
	hitbox.set_deferred("monitorable", true)
	hitbox.position.y -= 0.1 # Aquele nosso truque de atualização de física
	
	# O corte no ar é muito rápido, a Hitbox fica ligada por pouco tempo
	await get_tree().create_timer(0.15).timeout
	
	# ==========================================
	# FASE 3: RECUPERAÇÃO (Recovery)
	# O golpe acabou. DESLIGA A HITBOX para não dar dano duplo.
	hitbox.visible = false
	hitbox.set_deferred("monitoring", false) 
	hitbox.set_deferred("monitorable", false)
	hitbox.position.y += 0.1
	
	# Tempo que o personagem demora para guardar a espada e voltar ao normal
	await get_tree().create_timer(0.25).timeout
	
	current_state = State.NORMAL

func start_dodge():
	current_state = State.DODGING
	velocity.x = DODGE_SPEED * facing_direction
	
	# INÍCIO DOS I-FRAMES: Desliga a capacidade de tomar dano!
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	
	# Tempo da esquiva (0.3 segundos)
	await get_tree().create_timer(0.3).timeout
	
	# FIM DOS I-FRAMES: Liga a Hurtbox de volta!
	hurtbox.set_deferred("monitoring", true)
	hurtbox.set_deferred("monitorable", true)
	
	current_state = State.NORMAL
	
func state_hurt():
	# Enquanto estiver machucado, o jogador não obedece controles.
	# Ele apenas vai "freando" no chão após tomar o empurrão.
	pass

func state_attacking():
	# Aqui não tem nada ainda. 
	# Enquanto ataca, o personagem ignora botões de andar e pular.
	pass

func state_dodging():
	# Aqui também não. A velocidade da esquiva foi definida no start_dodge.
	pass

# --- SISTEMA DE DANO DO JOGADOR ---
#func _on_hurtbox_body_entered(body):
	#print("Encostou! Corpo: ", body.name)
	# Se quem encostou na gente estiver no grupo 'enemy'...
	#if body.is_in_group("enemy"):
		#take_damage(body)

func take_damage(enemy_body):
	# Garantia extra de I-Frames: se estiver esquivando, ignora o dano!
	if current_state == State.DODGING:
		return 

	hp -= 1
	life_bar.value = hp
	print("Jogador tomou dano! HP restante: ", hp)
	
	# MUDA O ESTADO PARA ATORDOADO!
	current_state = State.HURT 
	
	var knockback_dir = sign(global_position.x - enemy_body.global_position.x)
	velocity.x = knockback_dir * 300.0
	velocity.y = -200.0
	
	visual.modulate = Color(1, 0, 0)
	
	# O jogador fica "atoroado/piscando" por 0.3 segundos
	await get_tree().create_timer(0.3).timeout 
	visual.modulate = Color(1, 1, 1)
	
	if hp <= 0:
		print("VOCÊ MORREU! (YOU DIED)")
		get_tree().reload_current_scene() 
	else:
		# Se sobreviveu ao golpe, devolve o controle ao jogador
		current_state = State.NORMAL

func travar_para_cutscene():
	# Defina aqui o estado do Player como parado/neutro
	velocity = Vector2.ZERO
	# Desative ações ou altere o estado para CUTSCENE se tiver na Enum
	# ex: current_state = State.CUTSCENE

func liberar_da_cutscene():
	# Retorna o Player ao estado normal
	# ex: current_state = State.NORMAL
	pass

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "Hitbox":
		if area.get_parent().is_in_group("enemy"): # Se encostar numa Hitbox
			take_damage(area) # (Nós passamos a area para calcular o Knockback)
