extends SceneTree

const Actor = preload("res://scripts/chapter/actor.gd")
var checks := 0
var failures := 0
var unique := {}
var tested_foreground := false

func _initialize() -> void:
    run.call_deferred()

func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)

func verify_pose(actor: Actor, fitted_iron := false) -> void:
    var gear := actor.head_gear
    var body := actor.sprite
    gear.align_to(body)
    var label := "%s %s" % [body.texture.resource_path.get_file(), body.region_rect]
    var weapon := actor.weapon_head
    weapon.align_to(body)
    check(weapon.visible == fitted_iron, "Correct weapon-head layer on " + label)
    if fitted_iron:
        check(weapon.iron.texture.resource_path == actor.WEAPONS.data[actor.equipped_weapon].head_texture, "Equipped iron is shared on " + label)
        var world_size := absf(weapon.iron.scale.y * body.scale.y)
        check(is_equal_approx(world_size, actor.height / weapon.WALK_HEIGHT), "Consistent weapon-head scale on " + label)
    check(gear.visible and not gear.socket.is_empty(), "Missing fitted head socket on " + label)
    if not gear.visible:
        return
    var mantle := actor.body_gear
    mantle.align_to(body)
    check(mantle.visible and not mantle.socket.is_empty(), "Missing fitted shoulder panel on " + label)
    if mantle.visible:
        var panel: Array = mantle.socket
        var mask: Texture2D = mantle.coverage_material.get_shader_parameter("coverage")
        var sample_rect := Rect2(panel[6], panel[7], panel[8], panel[9])
        check(mask != null and Rect2(Vector2.ZERO, mask.get_size()).encloses(sample_rect), "Covered panel inside mask atlas")
        check(mantle.piece.flip_h == body.flip_h, "Covered panel follows handedness")
        check(mantle.get_index() < gear.get_index(), "Head draws over body armor on " + label)
    unique[label] = true
    check(gear.piece.flip_h == body.flip_h, "Helm mirror on " + label)
    check(gear.transform == body.transform, "Matching body transform on " + label)
    var socket_center := Vector2(gear.socket[0], gear.socket[1]) - body.region_rect.size * 0.5
    if body.flip_h:
        socket_center.x = -socket_center.x
    check(gear.piece.position.is_equal_approx(socket_center), "Registered head center on " + label)
    check(Rect2(Vector2.ZERO, gear.piece.texture.get_size()).encloses(gear.piece.region_rect), "Bounded item drawing")
    for part in gear.foreground:
        if part.visible:
            tested_foreground = true
            check(part.texture == body.texture and part.material == body.material, "Foreground uses the Ogre's current pixels and palette")

func run() -> void:
    var actor := Actor.new()
    actor.equip_head("iron_helm")
    actor.equip_body("scale_mantle")
    root.add_child(actor)
    actor.set_physics_process(false)
    actor.set_process(false)
    check(actor.head_gear != null and actor.equipped_head == "iron_helm", "Armor selected before a scene opens is applied")
    actor.set_hair_palette("silver")
    for facing in 4:
        actor.facing = facing
        for i in 4:
            actor.show_frame(i)
            verify_pose(actor)
            actor.show_run_frame(i)
            verify_pose(actor)
        for weapon in actor.WEAPONS.data:
            actor.equip_weapon(weapon)
            for i in 4:
                actor.action_pose(i)
                verify_pose(actor, true)
            for phase in 6:
                actor.show_swing(phase)
                verify_pose(actor, true)
            var dodge_art: Texture2D = load("res://assets/ogre/%s_dodge.png" % weapon)
            var dodge: Dictionary = load("res://resources/ogre/%s_dodge.json" % weapon).data
            var row := 0 if facing == 0 else 2 if facing == 3 else 1
            for frame in dodge.rows[row]:
                actor.FrameArt.cell(actor.sprite, dodge_art, frame, actor.height / dodge.height, facing == 1)
                verify_pose(actor, true)
            for i in 4:
                actor.ArmedGait.run_pose(actor, facing, float(i) * 0.25)
                verify_pose(actor)
            for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
                for i in 4:
                    actor.ArmedGait.pose(actor, direction, float(i) * 0.25)
                    verify_pose(actor, true)
    check(tested_foreground, "A hand or weapon passes in front of the helmet")
    actor.facing = 0
    actor.show_frame(0)
    actor._process(1.8)
    check(actor.idle_breath.visible and actor.head_gear.visible and not actor.sprite.visible, "Breathing keeps the fitted head visible")
    check(actor.head_gear.get_index() > actor.idle_breath.get_index(), "Helmet draws over breathing body")
    check(actor.head_gear.position.y < actor.sprite.position.y, "Breath lifts the head attachment at its socket")
    check(actor.body_gear.visible and actor.body_gear.position.y < actor.sprite.position.y, "Mantle follows the shoulders through the breathing idle")
    check(actor.body_gear.get_index() > actor.idle_breath.get_index() and actor.body_gear.get_index() < actor.head_gear.get_index(), "Breathing body, mantle, head draw in order")
    var strike_key: Array = []
    for head in ["bare", "iron_helm"]:
        actor.equip_head(head)
        actor.action_pose(2)
        actor._process(0.016)
        strike_key.append([actor.sprite.texture, actor.sprite.region_rect])
        check(actor.head_gear.visible == (head == "iron_helm"), "Swap changes only the worn head item")
    check(strike_key[0] == strike_key[1], "Head and weapon use independent assets")
    for weapon in actor.WEAPONS.data:
        actor.equip_weapon(weapon)
        for head in ["iron_helm", "bare"]:
            actor.equip_head(head)
            for body in ["fur", "scale_mantle"]:
                actor.equip_body(body)
                actor.show_swing(3)
                actor._process(0.016)
                check(actor.equipped_head == head and actor.equipped_body == body and actor.equipped_weapon == weapon, "Equipping a slot preserves the other two")
                check(actor.head_gear.visible == (head == "iron_helm") and actor.body_gear.visible == (body == "scale_mantle"), "Active layers match the selected combination")
    actor.equip_head("iron_helm")
    actor.equip_head("unknown")
    check(actor.equipped_head == "iron_helm", "Unknown item IDs preserve the active loadout")
    actor.free()
    print("Equipment fit: %d unique body drawings, %d checks, %d failures" % [unique.size(), checks, failures])
    quit(1 if failures else 0)
