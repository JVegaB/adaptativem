extends Node
class_name AMTrack;


signal finished;


@export var level : int;
@export var debug : bool;
@export var minimal_db : float = -20;


@onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer;


var main_track : bool;
var original_db : float;
var tween : Tween;


class Query:
	var from : float;
	var fade_time : float;

	static func from_dict(dict : Dictionary) -> Query:
		var query = Query.new();
		if dict.has("from"):
			query.from = dict.get("from");
		if dict.has("fade_time"):
			query.fade_time = dict.get("fade_time");
		return query;

func _ready():
	original_db = audio_stream_player.volume_db;
	audio_stream_player.finished.connect(_on_audio_finished)

func _on_audio_finished():
	if not main_track:
		return;
	finished.emit();

func play(query : Query = null):
	if query == null:
		query = Query.new();
	if query.fade_time <= 0:
		audio_stream_player.play(query.from);
		return;
	_play_tween(query);

func stop(query : Query = null):
	if query == null:
		query = Query.new();
	if query.fade_time <= 0:
		audio_stream_player.stop();
		return;
	await _stop_tween(query.fade_time);

func _play_tween(query : Query) -> void:
	if tween != null:
		tween.stop();
	tween = create_tween();
	audio_stream_player.volume_db = minimal_db;
	tween.tween_property(audio_stream_player, "volume_db", original_db, query.fade_time);
	audio_stream_player.play(query.from);

func _stop_tween(fade_time : float) -> void:
	if tween != null:
		tween.stop();
	tween = create_tween();
	tween.tween_property(audio_stream_player, "volume_db", minimal_db, fade_time);
	await tween.finished;
	audio_stream_player.stop();

func get_playback_position() -> float:
	return audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix();

func length() -> float:
	return audio_stream_player.stream.get_length();
