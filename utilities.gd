class_name Utils

const MONTH_NAMES = [
	"",
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
]

static func get_resources(path, class_type=null, recursive=false):
	var resources = []
	var class_type_is_empty = class_type == null or class_type == ''

	var files = get_files(path, recursive)
	for file_name in files:
		var full_path = '%s/%s' % [path, file_name]
		var resource = load(full_path)

		if resource is Resource:
			if class_type_is_empty or resource.is_class(class_type):
				resources.append(resource)

	return resources

static func get_files(path, recursive=false):
	var files = []
	var dir = DirAccess.open(path)

	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with('.import'):
				file_name = file_name.replace('.import', '')

			if file_name.ends_with(".remap"):
				file_name = file_name.replace(".remap", "")

			if file_name in files:
				continue

			files.append(file_name)

		if recursive:
			var dirs = dir.get_directories()
			for subdir in dirs:
				var dir_path = '%s/%s' % [path, subdir]
				var sub_files = get_files(dir_path, true)
				for sub_file in sub_files:
					var sub_file_path = '%s/%s' % [subdir, sub_file]
					files.append(sub_file_path)

	return files

static func get_dirs(path):
	return DirAccess.open(path).get_directories()

static func clear_child_nodes(parent, free_them=true, skip_nodes=[]):
	var nodes = parent.get_children()
	for node in nodes:
		if node in skip_nodes:
			continue

		parent.remove_child(node)

		if free_them:
			node.queue_free()

static func friendly_name(text):
	return text.trim_suffix('.' + text.get_extension()).capitalize()

static func scroll_to_bottom(scroll_container, duration=1, play_now=true):
	var tween = scroll_container.create_tween()
	var bottom = scroll_container.get_child(0).size.y - scroll_container.size.y
	tween.tween_property(scroll_container, 'scroll_vertical', bottom, duration)

	if play_now:
		tween.play()

	return tween

static func date_string(timestamp):
	var date_info = Time.get_date_dict_from_unix_time(timestamp)
	return '%s %d, %d' % [MONTH_NAMES[date_info['month']], date_info['day'], date_info['year']]

static func pivot_center(node, x_normal=0.5, y_normal=0.5, also_apply_after_resize=true):
	node.pivot_offset[0] = node.size[0] * x_normal
	node.pivot_offset[1] = node.size[1] * y_normal

	if also_apply_after_resize:
		if node.is_connected('resized', pivot_center):
			node.resized.disconnect(pivot_center)

		node.resized.connect(pivot_center.bind(node, x_normal, y_normal, false))

static func fit_rect(source_size:Vector2, target_size:Vector2) -> Rect2 :
	var source_ratio = source_size.x / source_size.y
	var target_ratio = target_size.x / target_size.y

	var result = Rect2(Vector2.ZERO, source_size)

	if source_ratio > target_ratio:
		result.size.x = target_size.x
		result.size.y = source_size.y * (result.size.x / source_size.x)

	else:
		result.size.y = target_size.y
		result.size.x = source_size.x * (result.size.y / source_size.y)

	result.position = (target_size - result.size) / 2.0

	return result

static func get_rect_corner(rect:Rect2, corner_idx) -> Vector2:
	var x_scalar = corner_idx % 2 == 1
	var y_scalar = floor(corner_idx / 2)

	return rect.position + rect.size*Vector2(x_scalar, y_scalar)
