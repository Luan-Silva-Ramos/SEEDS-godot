extends Area2D

# O @export cria um campo no Inspetor para escolhermos a fase!
@export var proxima_cena: String = ""

func _on_body_entered(body):
	# Verifica se quem pisou no portal foi o jogador
	if body.name == "Player":
		if proxima_cena != "":
			print("Viajando para: ", proxima_cena)
			get_tree().call_deferred("change_scene_to_file",proxima_cena)
		else:
			print("AVISO: O Portal não sabe para onde ir! Configure a próxima cena.")
