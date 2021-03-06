extends Control

onready var layer_container = get_node("panel_container/scroll_container/v_box_container")
var layer_button_scene = preload("res://ui/editable_button_with_color_picker.tscn")

var layers = []
var selected_layer
signal layer_selected(layer_id)
signal layer_added(layer_id, layer_name, layer_color)
signal default_layer_added(layer_id, layer_name, layer_color)
signal layer_deleted(layer_id)
signal layer_name_changed(layer_id, layer_name)
signal layer_color_changed(layer_id, layer_color)
signal layer_sight_disabled(layer_id)
signal layer_sight_enabled(layer_id)

func _ready():
	var layer = add_layer("Default")
	layer.default_select()
	emit_signal("default_layer_added", 0, layer.name, layer.color)

func load_layers( selected_layer_id, layers ):
	delete_all_layers()
	for i in range(layers.size()):
		var layer = add_layer(layers[i].name, layers[i].color, layers[i].visible)
		if( i == selected_layer_id ):
			selected_layer = layer
			layer.default_select()

func add_layer(name = null, color = null, visible = null):
	var layer = layer_button_scene.instance()
	var id = layers.size()
	name = name if name != null else ("layer"+str(id))
	color = color if color != null else Color(255,255,255)
	visible = visible if visible != null else true
	layers.append(layer)
	
	selected_layer = id
	
	layer.set_name( name )
	layer.set_color( color )
	layer.set_sight( visible )
	layer.connect("selected",self,"on_layer_select", [layer])
	layer.connect("name_changed",self,"on_layer_name_change", [layer])
	layer.connect("color_changed",self,"on_layer_color_change", [layer])
	layer.connect("disabled_sight",self,"on_layer_disable_sight", [layer])
	layer.connect("enabled_sight",self,"on_layer_enable_sight", [layer])
	
	layer_container.add_child(layer)
	
	return layer
	

func on_layer_select(layer):
	print("on layer select")
	var layer_id = layers.find(layer)
	for id in range(layers.size()):
		if( id != layer_id ):
			layers[id].unselect()
	selected_layer = layer_id
	emit_signal("layer_selected", layer_id)
			
func on_layer_name_change(name, layer):
	var layer_id = layers.find(layer)
	emit_signal("layer_name_changed", layer_id, name)

func on_layer_color_change(color, layer):
	var layer_id = layers.find(layer)
	emit_signal("layer_color_changed", layer_id, color)

func on_layer_disable_sight(layer):
	var layer_id = layers.find(layer)
	emit_signal("layer_sight_disabled", layer_id)
func on_layer_enable_sight(layer):
	var layer_id = layers.find(layer)
	emit_signal("layer_sight_enabled", layer_id)


func _on_new_layer_button_pressed():
	var layer = add_layer()
	# order of the next two line is important
	emit_signal("layer_added", layers.size()-1, layer.name, layer.color) 
	layer.select()

func _on_delete_layer_button_pressed():
	if( layers.size() != 1 ):
		emit_signal("layer_deleted", selected_layer)
		delete_layer(selected_layer)

func delete_all_layers():
	var child_count = layers.size()
	for i in range(child_count-1,-1,-1):
		layer_container.remove_child(layers[i])
		layers.remove(i)
func delete_layer(layer_id):
	layer_container.remove_child(layers[layer_id])
	layers.remove(layer_id)
	if( layers.size() > 0 ):
		layers[0].select()
		
