extends Node
class_name AMContainer;


@export var fade_time : float;
@export var level : int = 0 :
	set (value):
		level = value;
		on_change_level();

var am_tracks : Array[AMTrack];
var main_track : AMTrack;
var current_passed_time : float;


func _ready() -> void:
	main_track = null;
	for child in get_children():
		if not (child is AMTrack):
			continue;

		var track : AMTrack = child;
		am_tracks.append(track);

		track.finished.connect(on_track_finished);

		if not main_track or track.length() < main_track.length():
			main_track = track;

	assert(
		main_track != null,
		"AMContainer Error: No tracks found. Add AMTrack nodes as direct childs of this node.",
	)
	main_track.main_track = true;

func on_track_finished() -> void:
	for track in am_tracks:

		if track.level > level:
			continue;

		var playback_position := track.get_playback_position();
		var main_playback_position := main_track.get_playback_position();
		var max_duration := main_track.length();
		var current_iterations = int(playback_position / max_duration);
		var from : float = (current_iterations * max_duration) + main_playback_position;
		track.play(AMTrack.Query.from_dict({"from": from}));

func start():
	for track in am_tracks:
		if track.level > level:
			continue;
		track.play();

func on_change_level() -> void:
	for track in am_tracks:
		var query := AMTrack.Query.from_dict({"fade_time": fade_time});
		if track.level <= level and not track.audio_stream_player.playing:
			var main_playback_position := main_track.get_playback_position();
			query.from = main_playback_position;
			track.play(query);
		elif track.level > level and track.audio_stream_player.playing:
			track.stop(query);
