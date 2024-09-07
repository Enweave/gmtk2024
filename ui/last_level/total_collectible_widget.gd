extends HBoxContainer
class_name TotalCollectibleWidget

@onready var collectible_label: Label = %Label
@onready var collectible_value: Label = %Value
@onready var collectible_icon: TextureRect = %TextureRect


func render(_type: CollectibleBase.CollectibleType, _amount: int, _max_amount: int) -> void:
	if _amount > 0:
		self.visible = true
		collectible_label.text = CollectibleBase.NameMap[_type] + "s"
		collectible_value.text = str(_amount) + "/" + str(_max_amount)
		collectible_icon.texture = load(CollectibleBase.IconMap[_type])
	else:
		self.visible = false
	
