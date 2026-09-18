extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- NOVAS VARIÁVEIS DE COMBATE ---
var hp = 3
var knockback_force = 200.0

var speed = 50.0 # Inimigo é mais lento que o Player
var target = null # Começa sem alvo

var can_attack = true
var is_attacking = false
var attack_range = 50.0 # Distância que ele começa a atacar

var is_hurt = false
var is_dead = false
@onready var hitbox = $Hitbox


## GAME JUICE
# NOTA: Certifique-se de que o nó $Sprite2D foi transformado em um AnimatedSprite2D lá na sua cena!
@onready var visual = $Sprite2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# SE ESTIVER MORTO (Apenas freia o corpo e ignora o resto do código)
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, 800 * delta)
		move_and_slide()
		return
		
	# SE ESTIVER MACHUCADO (Toma o empurrão, mas não pensa nem ataca)
	if is_hurt:
		velocity.x = move_toward(velocity.x, 0, 800 * delta)
		move_and_slide()
		return

	# SE ESTIVER ATACANDO
	if is_attacking:
		velocity.x = 0
		
	# SE ESTIVER PERSEGUINDO O JOGADOR
	elif target != null:
		var distance = abs(target.global_position.x - global_position.x)
		var direcao = sign(target.global_position.x - global_position.x)
		
		if distance <= attack_range and can_attack:
			atacar()
		else:
			velocity.x = direcao * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 800 * delta)

	# --- LÓGICA DE ANIMAÇÃO DO INIMIGO ---
	if is_instance_valid(visual) and not is_attacking and not is_hurt and not is_dead:
		if abs(velocity.x) > 0.1:
			visual.play("run")
			visual.flip_h = (velocity.x > 0)
			
			if visual.flip_h: 
				hitbox.position.x = 30 
			else: 
				hitbox.position.x = -30 
		else:
			visual.play("idle")

	move_and_slide()	
# Código de Combate
func _on_hurtbox_area_entered(area):
	if area.name == "Hitbox":
		# Passamos a "area" (a espada do jogador) para sabermos de onde veio o golpe
		if area.get_parent().name == "Player":
			tomar_dano(area)

# --- A FUNÇÃO DE DANO (COM MORTE E HIT) ---
func tomar_dano(area_da_espada):
	if is_dead: return # Se já morreu, não toma mais dano no ar
	
	hp -= 1
	var direcao_do_golpe = sign(global_position.x - area_da_espada.global_position.x)
	velocity.x = direcao_do_golpe * knockback_force
	velocity.y = -150 
	
	visual.modulate = Color(1, 0, 0)
	
	if hp <= 0:
		is_dead = true
		print("Inimigo derrotado!")
		
		# Desliga a colisão para o jogador não esbarrar no cadáver
		$Hurtbox.set_deferred("monitoring", false)
		$Hitbox.set_deferred("monitoring", false)
		
		visual.modulate = Color(1, 1, 1) # Volta a cor normal para ver a morte
		visual.play("death") # Toca a animação de morte
		
		# O código PAUSA aqui até a animação de morte chegar no último frame!
		await visual.animation_finished 
		
		queue_free() # Destrói o inimigo
	else:
		is_hurt = true
		visual.play("hit") # Toca a animação de tomar porrada
		
		# O tempo de atordoamento (0.3s). Depois volta ao normal
		await get_tree().create_timer(0.3).timeout
		is_hurt = false
		if is_instance_valid(visual):
			visual.modulate = Color(1, 1, 1)


# --- A FUNÇÃO DE ATAQUE (COM SORTEIO) ---
# --- A FUNÇÃO DE ATAQUE (COM SORTEIO) ---
func atacar():
	is_attacking = true
	can_attack = false
	velocity.x = 0
	
	# CORREÇÃO DO BUG: Garante que vai virar a Hitbox pro lado certo ANTES de bater!
	if target != null:
		var direcao_ataque = sign(target.global_position.x - global_position.x)
		if direcao_ataque != 0:
			visual.flip_h = (direcao_ataque > 0)
			
			# Posiciona a arma para o lado exato que ele está olhando
			if visual.flip_h:
				hitbox.position.x = 30
			else:
				hitbox.position.x = -30
	
	# SORTEIO DE ATAQUE (Rola um dado que dá 0 ou 1)
	var ataque_sorteado = randi() % 2
	
	if ataque_sorteado == 0:
		visual.play("attack")
	else:
		visual.play("attack2")
		
	visual.modulate = Color(1, 1, 0) 
	
	await get_tree().create_timer(0.4).timeout 
	visual.modulate = Color(1, 1, 1) 
	
	# LIGA A HITBOX
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	
	await get_tree().create_timer(0.2).timeout 
	
	# DESLIGA A HITBOX
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	is_attacking = false
	
	await get_tree().create_timer(1.5).timeout
	can_attack = true
# --- SINAIS DA VISÃO ---
func _on_visao_body_entered(body):
	# Quando algum corpo entra no círculo, verificamos se o nome dele é "Player"
	if body.name == "Player":
		target = body # Foca no jogador!
		print("Inimigo: 'TE ACHEI!'")

func _on_visao_body_exited(body):
	# Se o jogador fugir para fora do círculo, o inimigo desiste
	if body.name == "Player":
		target = null
		print("Inimigo: 'Para onde ele foi?'")


	
