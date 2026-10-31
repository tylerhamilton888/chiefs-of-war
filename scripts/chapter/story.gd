extends RefCounted
var game
var s
var scenes: Dictionary={}
func _init(owner) -> void:
    game=owner;s=owner.state
    scenes=JSON.parse_string(FileAccess.get_file_as_string("res://resources/chapter/dialogue.json"))
func objective() -> String:
    match s.chapter:
        0:return "AN OGRE EARNS HIS SUPPER · Bramm needs 6 timber at the damaged wagon"
        1:return "THE FIRST PORTION · Cook, eat [Q], and give Sava the first portion"
        2:return "BLOOD IN THE PINES · Read three signs, hunt the wolf, bring home its trophy"
        3:return "THE LAST FEAST · Speak with your clan; tell Gorund when you are ready"
        4:return "SMOKE OVER THE RIVER · Defeat the blades, reach Bramm and Dorrik · %ds"%int(s.defense_left)
        5:return "THE STRONGER HAND · Face Hrothgar; every blow counts"
        6:return "A NEW FIRE · Find Thyra, then speak with Runa at the beast pen"
        7:return "THE SUNDERED ROAD · Clear three rockfalls; feed the stone-eater; lead the wagon"
        8:return "MEAT FOR IRON · Ask Eydis at Blackstone about the goblin contract"
        9:return "A HEARTH OF YOUR OWN · Eydis needs 8 timber, 2 hides and 25 coin"
        _:return "THE OPEN ROAD · Your own hearth, your own choices · J journal and routes"
func talk(id: String) -> void:
    s.relationships[id].met=true
    var key=id+"_idle"
    match id:
        "bramm":
            if s.chapter==0:key="bramm_work"
            elif s.chapter==2:key="bramm_hunt"
            elif s.chapter==3:key="bramm_feast"
            elif s.chapter>=6:key="bramm_survived"
        "svala":
            if s.chapter<=1:key="svala_food"
            elif s.chapter>=6:key="svala_after"
        "gorund":key="gorund_feast" if s.chapter==3 else "gorund_idle"
        "dorrik":key="dorrik_contest" if not s.has("contest") else "dorrik_after"
        "astrid":
            if s.chapter>=6:key="astrid_memory" if not s.has("astrid_activity") else "astrid_court"
        "hrothgar":key="hrothgar_home" if s.chapter>=9 else "hrothgar_idle"
        "thyra":key="thyra_welcome" if s.chapter==6 else "thyra_idle"
        "runa":key="runa_road" if s.chapter<=7 else "runa_harness" if not s.has("runa_activity") else "runa_court"
        "eydis":
            if s.chapter==8:key="eydis_contract" if not s.has("contract") else "eydis_collect" if game.contract_done() else "eydis_wait"
            elif s.chapter==9:key="eydis_wagon"
            else:key="eydis_forge" if not s.has("eydis_activity") else "eydis_court"
    game.dialogue(key)
func action(id: String) -> void:
    match id:
        "work":s.mark("work");game.say("Gather fallen wood nearby. Carry six timber to the damaged family wagon.")
        "contest":
            if not s.has("contest"):s.mark("contest");s.change("dorrik","rivalry",1);game.say("Dorrik wagers a meal: carry six timber to the wagon before you repair it.")
        "hunt":s.mark("companion");game.say("Dorrik will meet you in the Pines. Look for tracks beside the north trail.")
        "feast":
            if not s.pay({"meat":2}):game.say("Bring two cuts of meat for the feast.");return
            s.chapter=3;s.mark("feast");game.dialogue("feast")
        "ready":s.mark("ready");game.say("Take the northern trail when ready. The feast and camp remain open until you leave.")
        "duel":s.chapter=5;game.rebuild();game.say("Hrothgar has 620 health. His maul commits slowly; dodge its marked arc and punish recovery.")
        "join":s.chapter=6;s.hp=160;game.travel("host",Vector2(1000,1050),true);game.dialogue("host_arrival")
        "thyra":s.mark("thyra_welcome");s.change("thyra","loyalty",1);game.say("Runa is tending the beasts in the west of the host.")
        "road":
            if not s.has("thyra_welcome"):game.say("Thyra must first give you a place in the host. Speak with her near the eastern tents.");return
            s.chapter=maxi(7,s.chapter);s.mark("road");game.say("Sundered Pass lies north. Clear the three rockfalls; save three ore for the beast.")
        "contract":s.mark("contract");game.say("Three goblin raiders at Goblin Cairn. Return to Eydis after the work; 30 coin agreed.")
        "bargain":s.mark("contract");s.mark("bargained");s.change("eydis","admiration",1);game.say("Forty coin — and Eydis takes two cuts of meat on delivery. The three raiders wait at Goblin Cairn.")
        "payment":
            if not game.contract_done():game.say("The contract is not complete. Three named raiders hold the Cairn.");return
            if s.has("paid"):return
            if s.has("bargained") and not s.pay({"meat":2}):game.say("Your bargain included two meat. Hunt or purchase supplies first.");return
            s.inventory.coin+=40 if s.has("bargained") else 30;s.mark("paid");s.chapter=9;s.change("eydis","admiration",2);s.change("hrothgar","admiration",2);game.dialogue("paid")
        "wagon":
            if s.has("own_wagon"):return
            if not s.pay({"wood":8,"hide":2,"coin":25}):game.say("Your wagon needs eight timber, two hides and twenty-five coin. Hunt the Pines or gather along the roads.");return
            s.mark("own_wagon");s.chapter=10;s.camp_region="host";s.change("hrothgar","admiration",2);game.rebuild();game.dialogue("own_hearth")
        "pendant":
            if s.has("astrid_activity"):return
            if not s.has("pendant"):game.say("Astrid's family coffer remains beside the ruined Emberhide wagon. Return to the Crossing.");return
            s.mark("astrid_activity");s.change("astrid","admiration",3);s.change("astrid","loyalty",2);game.dialogue("astrid_return")
        "harness":
            if s.has("runa_activity"):return
            if not s.pay({"hide":2,"wood":2}):game.say("A proper harness needs two hides and two timber.");return
            s.mark("runa_activity");s.change("runa","admiration",3);game.dialogue("runa_done")
        "forge":
            if s.has("eydis_activity"):return
            if not s.pay({"ore":3,"wood":2}):game.say("Eydis needs three ore and two timber for the commission.");return
            s.mark("eydis_activity");s.mark("honed_axe");s.change("eydis","admiration",3);game.dialogue("eydis_done")
        "court_astrid","court_runa","court_eydis":
            var person=id.trim_prefix("court_")
            if s.eligible(person):s.relationships[person].courting=true;s.change(person,"interest",3);game.say("%s agrees to courtship. Friendship and work remain available; no marriage has been promised."%game.cast[person].name)
            else:game.say("Earn her trust through the work she cares about first.")
        "friend_astrid","friend_runa","friend_eydis":
            var person=id.trim_prefix("friend_");s.relationships[person].courting=false;s.change(person,"friendship",1);game.say("Your friendship is welcome. Courtship remains your choice.")
        "buy_food":
            if s.pay({"coin":2}):s.inventory.meat+=4;game.say("Four cuts of meat for two coin.")
            else:game.say("You need two coin.")
        "sell_hide":
            if s.pay({"hide":1}):s.inventory.coin+=6;game.say("One hide sold for six coin.")
            else:game.say("No hides to sell.")
        "train":game.say("LMB strike. Hold RMB to block toward the threat; the first 0.18 seconds parry. Space dodges. Q eats a meal.")
    game.save_progress()
