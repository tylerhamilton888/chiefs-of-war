extends SceneTree
## Compact derivatives of runtime captures or artwork. The original image is preserved.
const MAX_EDGE := 960
const TARGET_BYTES := 350_000
const MAX_BYTES := 750_000

static func save(original: Image, path: String) -> Error:
    if original == null or original.is_empty() or path.get_extension().to_lower() != "webp":
        push_error("Preview requires an image and a .webp destination: " + path)
        return ERR_INVALID_PARAMETER
    var preview: Image = original.duplicate()
    var size := preview.get_size()
    var longest := maxi(size.x, size.y)
    if longest > MAX_EDGE:
        var scale := float(MAX_EDGE) / longest
        preview.resize(maxi(1, roundi(size.x * scale)), maxi(1, roundi(size.y * scale)), Image.INTERPOLATE_LANCZOS)
    var encoded: PackedByteArray
    for quality: float in [0.90, 0.78, 0.64]:
        encoded = preview.save_webp_to_buffer(true, quality)
        if encoded.size() <= TARGET_BYTES:
            break
    if encoded.is_empty() or encoded.size() > MAX_BYTES:
        push_error("Could not encode preview within its byte budget: " + path)
        return ERR_CANT_CREATE
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        push_error("Could not open preview for writing: " + path)
        return FileAccess.get_open_error()
    file.store_buffer(encoded)
    file.flush()
    var error := file.get_error()
    var length := file.get_length()
    file.close()
    if error != OK or length != encoded.size():
        push_error("Incomplete preview write: " + path)
        return ERR_FILE_CANT_WRITE
    return OK

func _initialize() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 2 or args[0].simplify_path() == args[1].simplify_path() or FileAccess.file_exists(args[1]):
        printerr("Usage: --script tools/art_preview.gd -- input-image new-preview.webp")
        quit(1)
        return
    var image := Image.load_from_file(args[0])
    quit(0 if save(image, args[1]) == OK else 1)
