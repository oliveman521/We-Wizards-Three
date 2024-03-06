extends Node2D
class_name Projectile

@export var speed: float = 750
@export var damage: float = 1
@export var damage_type: GameManager.Damage_Type
@export var spawn_on_hit: Array[PackedScene]


@onready var sprite: Sprite2D = $Sprite

var direction: Vector2 = Vector2(-1,0)

@export_enum("Enemy", "Player") var target:int = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	rotation = direction.angle()


func _on_area_exited(area: Area2D) -> void:
	if area.name == "Play Boundry":
		queue_free()

func impact_effect() -> void:
	for item: PackedScene in spawn_on_hit:
		var new_node: Node2D = item.instantiate() as Node2D
		new_node.global_position = global_position
		add_sibling(new_node)
	queue_free() #delete bullet


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and target == 1: #TODO make the player take damage
		body.take_damage(damage)
		impact_effect()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") and target == 0:
		area.take_damage(damage_type, damage)
		impact_effect()
