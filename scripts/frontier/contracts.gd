extends RefCounted
## Definitions supply objectives/terms; one event ledger drives readiness and payment.
var definitions: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://resources/frontier/contracts.json"))
var state
func _init(ledger) -> void:state=ledger
func accept(id: String,term: String) -> bool:
    if not id in definitions or id in state.contracts or not term in definitions[id].terms:return false
    if id=="bargain" and not state.regional.pass_safe:return false
    if id=="bargain" and term=="coin" and state.reputation.blackstone.reliability<10:return false
    state.contracts[id]={"status":"active","term":term};return true
func refuse(id: String) -> bool:
    if not id in definitions or id in state.contracts:return false
    state.contracts[id]={"status":"refused","term":"none"};return true
func ready(id: String) -> bool:
    if not id in state.contracts or state.contracts[id].status!="active":return false
    for event in definitions[id].requires:
        if state.has(event)!=definitions[id].requires[event]:return false
    return true
func claim(id: String) -> bool:
    if not ready(id):return false
    var c=state.contracts[id];var def=definitions[id]
    if not c.term in def.terms:return false
    state.grant(def.terms[c.term]);c.status="paid"
    for key in def.effects:state.regional[key]=def.effects[key]
    for axis in def.reputation:state.rep(def.employer,axis,int(def.reputation[axis]))
    if id=="pass":
        state.mark("trade_open");state.rep("dunmere","reliability",8)
        if c.term=="rights":state.mark("hunting_rights")
    if id=="bargain" and c.term=="license":state.mark("raid_license")
    return true
func event(id: String) -> void:
    state.mark(id)
    # Safety is a physical outcome, even if the Ogre never signed the contract.
    if state.has("pass_cleared") and state.has("rockfall_cleared"):
        state.regional.pass_safe=true;state.regional.trade=maxi(35,state.regional.trade)
func settle(choice: String) -> bool:
    if not state.has("raid_license") or state.has("dunmere_resolved"):return false
    match choice:
        "spare":state.rep("dunmere","reliability",12);state.rep("blackstone","reliability",2)
        "protection":
            state.regional.protection="protection";state.regional.last_tribute=state.day;state.rep("dunmere","reliability",15);state.grant({"meat":8})
        "tribute":
            state.regional.protection="tribute";state.regional.last_tribute=state.day;state.regional.dunmere_resistance=30;state.rep("dunmere","brutality",12);state.grant({"coin":20,"meat":8})
        "raid":
            if not state.has("raid_won"):return false
            state.regional.dunmere_prosperity=20;state.regional.dunmere_resistance=70;state.rep("dunmere","brutality",30);state.rep("dunmere","reliability",-25);state.rep("stonebelly","strength",12);state.grant({"coin":40,"meat":20,"hide":6})
        "occupy":
            if not state.has("raid_won"):return false
            state.regional.dunmere_control="ogre";state.regional.dunmere_prosperity=35;state.regional.dunmere_resistance=55;state.regional.protection="tribute";state.regional.last_tribute=state.day;state.rep("dunmere","brutality",20);state.rep("blackstone","treachery",12)
        _:return false
    state.mark("dunmere_resolved");state.mark("dunmere_"+choice);return true
func tribute() -> bool:
    var r=state.regional
    if r.protection=="none" or state.day<=r.last_tribute or not r.pass_safe:return false
    if r.protection=="protection" and not state.has("protected_dunmere"):return false
    if r.dunmere_resistance>=60:return false
    state.grant({"meat":6,"coin":6 if r.protection=="protection" else 12});r.last_tribute=state.day
    if r.protection=="tribute":r.dunmere_resistance=mini(100,r.dunmere_resistance+12);r.dunmere_prosperity=maxi(0,r.dunmere_prosperity-5)
    else:r.dunmere_prosperity=mini(100,r.dunmere_prosperity+5);state.rep("dunmere","reliability",2);state.flags["protected_dunmere"]=false
    return true
