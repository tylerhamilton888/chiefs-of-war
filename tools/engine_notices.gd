extends SceneTree
func _initialize() -> void:
    var file:=FileAccess.open("res://builds/windows/THIRD_PARTY_NOTICES.txt",FileAccess.WRITE)
    file.store_string("Godot Engine 4.4.1\n\n"+Engine.get_license_text()+"\n\nThird-party components\n")
    file.store_string(JSON.stringify(Engine.get_copyright_info(),"  "))
    for name in Engine.get_license_info():
        file.store_string("\n\n"+str(name)+"\n"+str(Engine.get_license_info()[name]))
    file.close()
    quit()
