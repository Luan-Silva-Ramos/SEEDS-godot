extends Area2D

# Exporta as variáveis para você arrastar e soltar os nós direto pelo Inspector da Godot
@export var boss: CharacterBody2D
@export var nevoa_parede: Node2D # Nó que representa a parede/névoa fechando a arena
@export var hud_boss_bar: Control # Barra de vida do Boss na interface (HUD)

var cutscene_rodada: bool = false

func _ready():
	# Conecta automaticamente o sinal de colisão com o próprio script
	body_entered.connect(_on_body_entered)
	
	# Garante que a névoa de bloqueio e a barra de vida comecem invisíveis
	if nevoa_parede:
		nevoa_parede.visible = false
	if hud_boss_bar:
		hud_boss_bar.visible = false
		
	# Coloca o Boss no estado de cutscene logo no carregamento da cena
	if boss and boss.has_method("preparar_cutscene"):
		boss.preparar_cutscene()

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem entrou foi o Player e se a cutscene ainda não rodou
	if body.name == "Player" and not cutscene_rodada:
		cutscene_rodada = true
		
		# Desativa a colisão do trigger para não disparar 2 vezes
		$CollisionShape2D.set_deferred("disabled", true)
		
		rodar_cutscene(body)

func rodar_cutscene(player: Node2D) -> void:
	# 1. Trava os controles do Player
	if player.has_method("travar_para_cutscene"):
		player.travar_para_cutscene()
	
	# 2. Ativa a parede de névoa que fecha a entrada da arena
	if nevoa_parede:
		nevoa_parede.visible = true
	
	# 3. Pausa dramática estilo Souls (1 segundo de suspense)
	await get_tree().create_timer(1.0).timeout
	
	# 4. Boss acorda / se levanta da fogueira
	if boss and boss.has_method("iniciar_lutaboss"):
		# Exibe a barra de vida do Boss na tela
		if hud_boss_bar:
			hud_boss_bar.visible = true
			
		await boss.iniciar_lutaboss(player)
	
	# 5. Devolve o controle ao Player para iniciar a luta
	if player.has_method("liberar_da_cutscene"):
		player.liberar_da_cutscene()
