extends Node2D
class_name Projectile

@export var speed: float = 750
@export var damage: float = 1
@export var ammo_type: Ammo_Type
@onready var sprite: Sprite2D = $Sprite

var direction: Vector2 = Vector2(-1,0)

@export_enum("Enemy", "Player") var target:int = 0

#Note: if I add a _ready later, it might interfere with the explosive projectile
#note 2: this can be fixed with a super call. TODO impliment that fix


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	rotation = direction.angle()


func _on_area_exited(area: Area2D) -> void:
	if area.name == "Play Boundry":
		queue_free()

func impact_effect() -> void:
	queue_free() #delete bullet


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and target == 1: #TODO make the player take damage
		body.take_damage(damage)
		impact_effect()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") and target == 0:
		area.take_damage(ammo_type.damage_type, damage)
		impact_effect()
