extends CardEffect
class_name CardEffect_ScreenShake


@export var shake_amnt: float = 0.2



func use_effect() -> void:
	GameCamera.instance.shake(shake_amnt)
