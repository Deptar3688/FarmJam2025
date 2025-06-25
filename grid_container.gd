extends GridContainer
var currently_selected: Selectable = null
signal switch_holding(object)

func _ready():
	for panel in get_children():
		if panel.get_child(0) is Selectable:
			panel.get_child(0).selected_self.connect(_on_selectable_selected)
			panel.get_child(0).stop_holding.connect(_on_stop_holding)

func _on_selectable_selected(selected: Selectable):
	if currently_selected and currently_selected != selected:
		currently_selected.deselect()
		switch_holding.emit(selected)
	
	currently_selected = selected

func _on_stop_holding():
	currently_selected = null
