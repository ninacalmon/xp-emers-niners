extends Node

var player: Player = null
var julio: Node3D = null
var lucio: Node3D = null
var hugo: Node3D = null
var sanson: Node3D = null
var confessor: Node3D = null
var prior: Node3D = null

var astrolabus_desk: Node3D = null

var confessor_booth: Node3D = null
var confessing_pos: Node3D = null
var hugo_room_pos: Node3D = null
var sanson_room_pos: Node3D = null


func get_player() -> Player:
	if is_instance_valid(player) and player.is_inside_tree():
		return player

	var node: Node = get_tree().get_first_node_in_group(&"player")
	player = node as Player
	return player


func get_julio() -> Node3D:
	julio = _find_cached(julio, &"julio")
	return julio


func get_lucio() -> Node3D:
	lucio = _find_cached(lucio, &"lucio")
	return lucio


func get_hugo() -> Node3D:
	hugo = _find_cached(hugo, &"hugo")
	return hugo


func get_sanson() -> Node3D:
	sanson = _find_cached(sanson, &"sanson")
	return sanson


func get_confessor() -> Node3D:
	confessor = _find_cached(confessor, &"confessor")
	return confessor


func get_prior() -> Node3D:
	prior = _find_cached(prior, &"prior")
	return prior


func get_confessor_booth() -> Node3D:
	confessor_booth = _find_cached(confessor_booth, &"confessor_booth")
	return confessor_booth

func get_confessing_pos() -> Node3D:
	confessing_pos = _find_cached(confessing_pos, &"confessing_pos")
	return confessing_pos


func get_hugo_room_pos() -> Node3D:
	hugo_room_pos = _find_cached(hugo_room_pos, &"hugo_room_pos")
	return hugo_room_pos


func get_sanson_room_pos() -> Node3D:
	sanson_room_pos = _find_cached(sanson_room_pos, &"sanson_room_pos")
	return sanson_room_pos


func get_astrolabus_desk() -> Node3D:
	astrolabus_desk = _find_cached(astrolabus_desk, &"astrolabus_desk")
	return astrolabus_desk


func _find_cached(cached: Node3D, group_name: StringName) -> Node3D:
	if is_instance_valid(cached) and cached.is_inside_tree():
		return cached

	var node: Node = get_tree().get_first_node_in_group(group_name)
	return node as Node3D


func put_entity_at(entity: Node3D, pos: Vector3):
	entity.global_position = pos
