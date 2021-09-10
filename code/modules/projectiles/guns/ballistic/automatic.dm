//IN THIS DOCUMENT: Automatic template, SMGs, Carbines, Semi-auto rifles, Assault rifles, Machineguns and Misc.
// See gun.dm for keywords and the system used for gun balance



//////////////////////
//AUTOMATIC TEMPLATE//
//////////////////////


/obj/item/gun/ballistic/automatic
	name = "automatic gun template"
	desc = "should not be here, bugreport."
	slowdown = 0.5
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = 0
	force = 15
	burst_size = 2
	burst_shot_delay = 3
	var/automatic_burst_overlay = TRUE
	var/semi_auto = FALSE
	var/auto_eject = 0
	var/auto_eject_sound = null
	var/alarmed = 0
	var/select = 1
	can_suppress = FALSE
	equipsound = 'sound/f13weapons/equipsounds/riflequip.ogg'

/obj/item/gun/ballistic/automatic/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	else if(istype(I, /obj/item/attachments/auto_sear))
		var/obj/item/attachments/auto_sear/A = I
		if(!auto_sear && can_automatic && semi_auto)
			if(!user.transferItemToLoc(I, src))
				return
			auto_sear = A
			src.desc += " It has an automatic sear installed."
			src.burst_size += 1
			src.spread += 6
			src.recoil += 0.1
			src.automatic_burst_overlay = TRUE
			src.semi_auto = FALSE
			to_chat(user, "<span class='notice'>You attach \the [A] to \the [src].</span>")
			update_icon()
	else
		return ..()

/obj/item/gun/ballistic/automatic/update_overlays()
	. = ..()
	if(automatic_burst_overlay)
		if(!select)
			. += ("[initial(icon_state)]semi")
		if(select == 1)
			. += "[initial(icon_state)]burst"

/obj/item/gun/ballistic/automatic/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"

/obj/item/gun/ballistic/automatic/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, mag_type))
			var/obj/item/ammo_box/magazine/oldmag = magazine
			if(user.transferItemToLoc(AM, src))
				magazine = AM
				if(oldmag)
					to_chat(user, "<span class='notice'>You perform a tactical reload on \the [src], replacing the magazine.</span>")
					oldmag.forceMove(get_turf(src.loc))
					oldmag.update_icon()
				else
					to_chat(user, "<span class='notice'>You insert the magazine into \the [src].</span>")

				playsound(user, 'sound/weapons/autoguninsert.ogg', 60, 1)
				chamber_round()
				A.update_icon()
				update_icon()
				return 1
			else
				to_chat(user, "<span class='warning'>You cannot seem to get \the [src] out of your hands!</span>")

/obj/item/gun/ballistic/automatic/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_firemode))
		burst_select()
	else
		return ..()

/obj/item/gun/ballistic/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	if(semi_auto)
		to_chat(user, "<span class = 'notice'>This weapon is semi-automatic only.</span>")
		return
	else
		select = !select
		if(!select)
			disable_burst()
			to_chat(user, "<span class='notice'>You switch to semi-automatic.</span>")
		else
			enable_burst()
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/gun/ballistic/automatic/proc/enable_burst()
	burst_size = initial(burst_size)
	if(auto_sear)
		burst_size = 1 + initial(burst_size)
	if(burst_improvement)
		burst_size = 1 + initial(burst_size)
	if(burst_improvement && auto_sear)
		burst_size = 2 + initial(burst_size)

/obj/item/gun/ballistic/automatic/proc/disable_burst()
	burst_size = 1

/obj/item/gun/ballistic/automatic/can_shoot()
	return get_ammo()

/obj/item/gun/ballistic/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/gun/ballistic/automatic/afterattack(atom/target, mob/living/user)
	..()
	if(auto_eject && magazine && magazine.stored_ammo && !magazine.stored_ammo.len && !chambered)
		magazine.dropped()
		user.visible_message(
			"[magazine] falls out and clatters on the floor!",
			"<span class='notice'>[magazine] falls out and clatters on the floor!</span>"
		)
		if(auto_eject_sound)
			playsound(user, auto_eject_sound, 40, 1)
		magazine.forceMove(get_turf(src.loc))
		magazine.update_icon()
		magazine = null
		update_icon()


///////////////////
//SUBMACHINE GUNS//
///////////////////


//SMG TEMPLATE
/obj/item/gun/ballistic/automatic/smg/
	name = "SMG TEMPLATE"
	desc = "should not exist"
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_HEAVY //Automatic fire and onehanded use mix poorly.
	slowdown = 0.2
	fire_delay = 3.75
	burst_shot_delay = 3
	spread = 10
	force = 12
	actions_types = list(/datum/action/item_action/toggle_firemode)

//PPSH-41			Keywords: 9mm, Automatic, 71 round mags. Special modifiers: -2 damage, extra spread and larger burst size.
/obj/item/gun/ballistic/automatic/smg/pps
	name = "PPSH-41"
	desc = "An extremely fast firing, inaccurate submachine gun from World War 2. Low muzzle velocity. Uses 9mm rounds."
	icon_state = "pps"
	mag_type = /obj/item/ammo_box/magazine/pps9mm
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_HEAVY
	force = 15
	burst_size = 3
	fire_delay = 4.5
	burst_shot_delay = 2
	can_suppress = FALSE
	can_attachments = TRUE
	extra_damage = -2
	can_scope = FALSE
	scope_state = "AEP7_scope"
	scope_x_offset = 9
	scope_y_offset = 21
	spread = 20

//Carl Gustaf			Keywords: 10mm, Automatic, 12/24 round mags.
//Was intended for Legion replacement to Uzis/10mm SMGs. No current implementation.
/obj/item/gun/ballistic/automatic/smg/cg45
	name = "Carl Gustaf 10mm"
	desc = "Post-war submachine gun made in Flagstaff workshops based on a simple old design. Chambered in 10mm."
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	icon_state = "cg45"
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	item_state = "cg45"
	mag_type = /obj/item/ammo_box/magazine/cg45
	fire_sound = 'sound/f13weapons/10mm_fire_03.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	force = 15
	burst_size = 2
	fire_delay = 5
	burst_shot_delay = 2.5
	spread = 9
	can_suppress = FALSE
	can_attachments = TRUE
	spread = 9

//Greasegun				Keywords: .45 APC, Automatic, 30 round mags. Notes: Should be slow-firing due to simple design and the punch it packs.
/obj/item/gun/ballistic/automatic/smg/greasegun
	name = "M3A1 grease gun"
	desc = "An inexpensive submachine gun chambered in .45 ACP. Slow fire rate allows the operator to conserve ammunition in controllable bursts."
	icon_state = "grease_gun"
	item_state = "smg9mm"
	mag_type = /obj/item/ammo_box/magazine/greasegun
	fire_sound = 'sound/f13weapons/greasegun.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	force = 15
	burst_size = 2
	fire_delay = 2.5
	burst_shot_delay = 3
	can_suppress = FALSE
	can_attachments = TRUE
	spread = 10
	can_suppress = TRUE
	suppressor_state = "uzi_suppressor"
	suppressor_x_offset = 26
	suppressor_y_offset = 17

/obj/item/gun/ballistic/automatic/smg/greasegun/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select += 1
			burst_size = 2
			spread = 8
			fire_delay =3.5
			recoil = 0.1
			weapon_weight = WEAPON_HEAVY
			to_chat(user, "<span class='notice'>You switch to automatic fire.</span>")
		if(1)
			select = 0
			burst_size = 1
			fire_delay = 3.25
			spread = 2
			weapon_weight = WEAPON_MEDIUM
			to_chat(user, "<span class='notice'>You switch to semi-auto.</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

//10mm SMG				Keywords: 10mm, Automatic, 12/24 round mags. Notes: Should be faster-firing than the Grease due to smaller rounds and complex design.
/obj/item/gun/ballistic/automatic/smg/smg10mm
	name = "10mm submachine gun"
	desc = "One of the most common personal-defense weapons of the Great War, a sturdy and reliable open-bolt 10mm submachine gun."
	icon_state = "smg10mm"
	item_state = "smg10mm"
	mag_type = /obj/item/ammo_box/magazine/m10mm_adv
	init_mag_type = /obj/item/ammo_box/magazine/m10mm_adv/ext
	fire_sound = 'sound/f13weapons/10mm_fire_03.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM //You should be able to dual-wield these.
	force = 15
	burst_size = 2
	fire_delay = 5
	burst_shot_delay = 2.5
	can_suppress = FALSE //we dont have sprites therefore cease
	can_attachments = TRUE
	spread = 18
	can_suppress = TRUE
	suppressor_state = "10mm_suppressor"
	suppressor_x_offset = 30
	suppressor_y_offset = 16

/obj/item/gun/ballistic/automatic/smg/smg10mm/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select += 1
			burst_size = 2
			spread = 9
			fire_delay = 3.75
			recoil = 0.1
			weapon_weight = WEAPON_HEAVY
			to_chat(user, "<span class='notice'>You switch to automatic fire.</span>")
		if(1)
			select = 0
			burst_size = 1
			fire_delay = 3.5
			spread = 2
			weapon_weight = WEAPON_MEDIUM
			to_chat(user, "<span class='notice'>You switch to semi-auto.</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

//Mini Uzi			Keywords: 9mm, Automatic, 32 round mags. Notes: Should be very fast firing; one of the fastest of SMGs.
/obj/item/gun/ballistic/automatic/smg/mini_uzi
	name = "Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "mini-uzi"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	force = 15
	burst_size = 2
	fire_delay = 4.5
	burst_shot_delay = 2
	can_suppress = TRUE
	can_attachments = TRUE
	can_scope = FALSE
	scope_state = "AEP7_scope"
	scope_x_offset = 9
	scope_y_offset = 21
	spread = 10
	suppressor_state = "uzi_suppressor"
	suppressor_x_offset = 29
	suppressor_y_offset = 16

/obj/item/gun/ballistic/automatic/smg/mini_uzi/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select += 1
			burst_size = 2
			spread = 11
			fire_delay = 3
			recoil = 0.1
			weapon_weight = WEAPON_HEAVY
			to_chat(user, "<span class='notice'>You switch to automatic fire.</span>")
		if(1)
			select = 0
			burst_size = 1
			fire_delay = 3
			spread = 3
			weapon_weight = WEAPON_MEDIUM
			to_chat(user, "<span class='notice'>You switch to semi-auto.</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

//Tompson SMG			Keywords: .45 APC, Automatic, ??? round drum-mags. Notes: Big fuckin' capacity n' big fuckin' round. Likely high spread and heavy weapon class.
/obj/item/gun/ballistic/automatic/smg/tommygun
	name = "Thompson SMG"
	desc = "Known colloquially as the 'Chicago Typewriter' the Thompson sub-machine gun is a relatively ancient yet famous weapon of the past. It's amazing it survived the war in such a good condition!"
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	burst_size = 4
	burst_shot_delay = 2.5
	fire_delay = 2.5

//P90					Keywords: 10mm, Automatic, ??? round snowflake mags. Notes: Snowflake gun top-loader, fast fire rate but likely inaccurate. Better 10mm SMG.
/obj/item/gun/ballistic/automatic/smg/p90
	name = "FN P90c"
	desc = "The Fabrique Nationale P90c was just coming into use at the time of the war. The weapon's bullpup layout, and compact design, make it easy to control. The durable P90c is prized for its reliability, and high firepower in a ruggedly-compact package. Chambered in 10mm."
	icon_state = "p90"
	item_state = "m90"
	burst_size = 3
	fire_delay = 2.5
	//automatic = 1
	mag_type = /obj/item/ammo_box/magazine/m10mm_p90
	fire_sound = 'sound/f13weapons/10mm_fire_03.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT
	extra_damage = 5
	extra_penetration = 0.1
	can_suppress = TRUE
	suppressor_state = "pistol_suppressor"
	suppressor_x_offset = 29
	suppressor_y_offset = 16

//MP-5			Keywords: 9mm, Automatic, 32 round mags. Note: Basically a superior version of the Mini-Uzi; bulkier but more accurate.
/obj/item/gun/ballistic/automatic/smg/mp5
	name = "MP-5 SD"
	desc = "An integrally suppressed sub machine chambered in 9mm. A classic."
	icon_state = "mp5"
	item_state = "fnfal"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	burst_size = 2
	burst_shot_delay = 1
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	suppressed = 1
	can_attachments = TRUE
	can_suppress = FALSE
	can_unsuppress = FALSE
	fire_sound = 'sound/weapons/Gunshot_silenced.ogg'

//Sten SMG			Keywords: 9mm , Automatic, 32 round mags. Note: Unused; old, shitty sprite from 2017 Lebensraum. Why do we have this???
/obj/item/gun/ballistic/automatic/smg/sten
	name = "Sten gun"
	desc = "A low-cost 9mm submachine gun that has seen use throughout the world since WW2."
	icon_state = "sten"
	item_state = "smg9mm"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	burst_size = 2
	burst_shot_delay = 1
	fire_delay = 1
	can_attachments = TRUE
	can_suppress = FALSE

//American 180
/obj/item/gun/ballistic/automatic/smg/smg22
	name = "American 180"
	desc = "An integrally suppressed submachinegun chambered in the common .22 long rifle."
	icon_state = "smg22"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/m22smg
	fire_sound = 'sound/f13weapons/american180.ogg'
	can_suppress = FALSE
	can_unsuppress = FALSE
	burst_size = 4
	burst_shot_delay = 2
	fire_delay = 3
	suppressed = 1
	untinkerable = TRUE

////////////
//CARBINES//
////////////

//M1 Carbine			Keywords: 10mm, Semi-auto, 12/24 rounds, 'Long barrel'. Notes: Can be made semi-auto. I guess it's realistic in a way due to prototype M1 Carbine models irl.
/obj/item/gun/ballistic/automatic/m1carbine
	name = "M1 Carbine"
	desc = "The M1 Carbine is a renowned carbine that has been in service since WW2. Recently retired, these guns were transferred to National Guard Armouries and rechambered to 10mm."
	icon_state = "m1carbine"
	item_state = "rifle"
	burst_size = 1
	fire_delay = 2
	//automatic = 0
	mag_type = /obj/item/ammo_box/magazine/m10mm_adv
	fire_sound = 'sound/f13weapons/varmint_rifle.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	extra_damage = 2
	extra_penetration = 0.08
	automatic_burst_overlay = FALSE
	//automatic = 1
	can_bayonet = TRUE
	bayonet_state = "lasmusket"
	knife_x_offset = 22
	knife_y_offset = 21
	can_scope = TRUE
	scope_state = "lasmusket_scope"
	scope_x_offset = 5
	scope_y_offset = 14
	can_attachments = TRUE
	can_automatic = TRUE
	semi_auto = TRUE
	can_suppress = TRUE
	suppressor_state = "rifle_suppressor"
	suppressor_x_offset = 26
	suppressor_y_offset = 31

//M1/NCR Carbine			Keywords: NCR, 10mm, Semi-Auto, 12/24 rounds, 'Long Barrel', No Autosear (!)
/obj/item/gun/ballistic/automatic/m1carbine/ncr
	name = "M1/N Carbine"
	desc = "The M1 Carbine is a renowned carbine that's been in service since WW2. This varient seems to sport a few modernizations alongside an NCR design in brahmin leather on its stock."
	icon_state = "ncr-m1carbine"
	can_automatic = FALSE
	untinkerable = TRUE
	extra_damage = 4

//Compact M1A1 Carbine		Keywords: 10mm, Semi-Auto, 12/24 rounds, 'Long Barrel', Folding stock / Compact.
/obj/item/gun/ballistic/automatic/m1carbine/compact
	name = "M1A1 Carbine"
	desc = "The M1A1 carbine is an improvement of the original, with this particular model having a folding stock allowing for greater mobility. Chambered in 10mm."
	icon_state = "m1a1carbine"
	var/stock = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	spread = 5

/obj/item/gun/ballistic/automatic/m1carbine/compact/AltClick(mob/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	toggle_stock(user)

/obj/item/gun/ballistic/automatic/m1carbine/compact/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to toggle the stock.</span>"

/obj/item/gun/ballistic/automatic/m1carbine/compact/proc/toggle_stock(mob/living/user)
	stock = !stock
	if(stock)
		w_class = WEIGHT_CLASS_BULKY
		to_chat(user, "You unfold the stock.")
		spread = 5
	else
		w_class = WEIGHT_CLASS_NORMAL
		to_chat(user, "You fold the stock.")
		spread = 20
	update_icon()

/obj/item/gun/ballistic/automatic/m1carbine/compact/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][stock ? "" : "-f"]"

////////////////////
//SEMI-AUTO RIFLES//
////////////////////

//Service Rifle 		Keywords: 5.56, Semi-Automatic, 20 (10-50) round mags, No Autosear (!)
/obj/item/gun/ballistic/automatic/service
	name = "Service Rifle"
	desc = "A 5.56x45 semi-automatic service rifle manufactured by the NCR and issued to all combat personnel."
	icon_state = "service_rifle"
	item_state = "servicerifle"
	fire_sound = 'sound/f13weapons/varmint_rifle.ogg'
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	fire_delay = 2
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	can_bayonet = TRUE
	bayonet_state = "lasmusket"
	can_attachments = TRUE
	knife_x_offset = 22
	knife_y_offset = 21
	burst_size = 1
	automatic_burst_overlay = FALSE
	semi_auto = TRUE
	can_suppress = TRUE
	suppressor_state = "rifle_suppressor"
	suppressor_x_offset = 28
	suppressor_y_offset = 30

//Scourt Carbine		Keywords: 5.56, Semi-Autoamtic, 20 (10-50) round mags, No Autosear, Scoped.
/obj/item/gun/ballistic/automatic/service/carbine
	name = "Scout Carbine"
	desc = "A cut down version of the standard-issue service rifle tapped with mounting holes for a scope. Shorter barrel, lower muzzle velocity."
	icon_state = "scout_carbine"
	can_scope = TRUE
	scope_state = "smallrifle_scope"
	scope_x_offset = 4
	scope_y_offset = 15
	extra_damage = -4
	fire_delay = 2
	suppressor_x_offset = 26
	suppressor_y_offset = 28

//Marksman Carbine		Keywords: 5.56,Semi-Autoamtic, 20 (10-50) round mags, Scoped.
/obj/item/gun/ballistic/automatic/marksman
	name = "Marksman Carbine"
	desc = "A marksman carbine built off the AR platform chambered in 5.56x45. Seen heavy usage in pre-war conflicts. This particular model is a civilian version and is semi-auto only."
	icon_state = "marksman_rifle"
	item_state = "marksman"
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 5
	can_attachments = TRUE
	can_bayonet = TRUE
	bayonet_state = "rifles"
	knife_x_offset = 22
	knife_y_offset = 12
	burst_size = 1
	automatic_burst_overlay = FALSE
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	extra_damage = 2
	can_automatic = TRUE
	semi_auto = TRUE
	can_suppress = TRUE
	fire_sound = 'sound/f13weapons/marksman_rifle.ogg'
	suppressor_state = "suppressor"
	suppressor_x_offset = 31
	suppressor_y_offset = 15

//Colt Rangemaster		Keywords: 7.62mm, Semi-Auto, 10/20 round mags, No Autosear
/obj/item/gun/ballistic/automatic/rangemaster
	name = "Colt Rangemaster"
	desc = "A Colt Rangemaster semi-automatic rifle, chambered for 7.62x51. Single-shot only."
	icon_state = "rangemaster"
	item_state = "308"
	fire_sound = 'sound/f13weapons/hunting_rifle.ogg'
	mag_type = /obj/item/ammo_box/magazine/m762
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	fire_delay = 4.5
	can_attachments = TRUE
	can_scope = TRUE
	can_bayonet = TRUE
	bayonet_state = "lasmusket"
	knife_x_offset = 24
	knife_y_offset = 21
	burst_size = 1
	automatic_burst_overlay = FALSE
	semi_auto = TRUE
	scope_state = "rifle_scope"
	scope_x_offset = 4
	scope_y_offset = 11
	can_suppress = TRUE
	suppressor_state = "rifle_suppressor"
	suppressor_x_offset = 27
	suppressor_y_offset = 16

//M1 Garand			Keywords: .308/7.62mm, Semi-Auto, 8 round internal mag, No Autosear
/obj/item/gun/ballistic/automatic/m1garand
	name = "Battle Rifle"
	desc = "The WWII American Classic, the M1 Garand. Still has that satisfiying ping. Don't stick your thumb in it.."
	icon_state = "m1garand"
	item_state = "rifle"
	mag_type = /obj/item/ammo_box/magazine/garand308
	fire_sound = 'sound/f13weapons/hunting_rifle.ogg'
	fire_delay = 4
	burst_size = 1
	en_bloc = 1
	auto_eject = 1
	auto_eject_sound = 'sound/f13weapons/garand_ping.ogg'
	can_bayonet = TRUE
	bayonet_state = "lasmusket"
	knife_x_offset = 22
	knife_y_offset = 21
	can_scope = TRUE
	scope_state = "rifle_scope"
	scope_x_offset = 5
	scope_y_offset = 14
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	semi_auto = TRUE

/obj/item/gun/ballistic/automatic/m1garand/update_icon()
	..()
	icon_state = "[initial(icon_state)]"

/obj/item/gun/ballistic/automatic/m1garand/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return

//Old Glory					Keywords: UNIQUE, 308/7.62mm, Semi-Auto, 8 round internal mag, No Autosear. Note: A lot of extra damage.
/obj/item/gun/ballistic/automatic/m1garand/oldglory
	name = "Old Glory"
	desc = "This Machine kills communists!"
	icon_state = "oldglory"
	extra_damage = 10

//Pawolskis Retribution		Keywords: UNIQUE, 308/7.62mm, Semi-Auto, 8 round internal mag, No Autosear. Note: Some exta damage.
/obj/item/gun/ballistic/automatic/m1garand/ncr
	name = "Pawolski's Retribution"
	desc = "'I am your rifle, you are on guard duty.'"
	icon_state = "pawolski"
	extra_damage = 5

//Republics Pride			Keywords: UNIQUE, NCR, 308/7.62mm, Semi-Auto, 8 round internal mag, No Autosear. Note: Normal extra damage.
/obj/item/gun/ballistic/automatic/m1garand/republicspride
	name = "Republic's Pride"
	desc = "A well-tuned scoped M1C rifle crafted by master gunsmith from the Gunrunners. Proudly issued to Scout Captains and packs a mean punch. Chambered in 7.62x51."
	icon_state = "republics_pride"
	item_state = "scoped308"
	extra_damage = 8
	extra_penetration = 0.1
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	can_scope = FALSE

//Republics Demise			Keywords: UNIQUE, Legion, 308/7.62mm, Semi-Auto, 8 round internal mag, No Autosear. Note: A lot of extra damage.
/obj/item/gun/ballistic/automatic/m1garand/republicsdemise
	name = "Republic's Demise"
	desc = "A well-tuned scoped M1C rifle crafted by master gunsmith from the Gunrunners. This one seems to be looted from a dead NCR Lieutenant and the flag replaced with a bull. Chambered in 7.62x51."
	icon_state = "republics_demise"
	item_state = "scoped308"
	extra_damage = 8
	extra_penetration = 0.1
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	can_scope = FALSE

//DKS 501 sniper rifle				Keywords: .308, Semi-auto, 7 round magazine, Scoped, Extra speed.
/obj/item/gun/ballistic/automatic/marksman/sniper
	name = "Sniper Rifle"
	desc = "A DKS 501, chambered in .308 Winchester.  With a light polymer body, it's suited for long treks through the desert."
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	icon_state = "sniper_rifle"
	item_state = "sniper_rifle"
	mag_type = /obj/item/ammo_box/magazine/w308
	fire_sound = 'sound/f13weapons/hunting_rifle.ogg'
	fire_delay = 10
	burst_size = 1
	can_bayonet = FALSE
	semi_auto = TRUE
	can_automatic = FALSE
	extra_speed = TILES_TO_PIXELS(85) //Hitscan with an improved barrel installed.


//////////////////
//ASSAULT RIFLES//
//////////////////

//R82 Heavy Rifle		Keywords: 5.56mm, Semi-Auto, 20 (10-50) round mags. Notes: Snowflake non-canon rifle.
/obj/item/gun/ballistic/automatic/service/r82
	name = "R82 Heavy Service Rifle"
	desc = "The assault rifle variant of the R84, based off the pre-war FN FNC. Chambered in 5.56."
	fire_delay = 1 //faster ROF, superior to regular service rifle
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	icon_state = "R82"
	item_state = "R84"
	//automatic = 1
	spread = 3
	burst_size = 1
	automatic_burst_overlay = TRUE
	actions_types = list(/datum/action/item_action/toggle_firemode)
	semi_auto = TRUE
	burst_shot_delay = 3.0 //Was 2.2 before.
	can_suppress = TRUE
	can_automatic = TRUE
	can_scope = TRUE
	suppressor_state = "rifle_suppressor"
	suppressor_x_offset = 27
	suppressor_y_offset = 28
	scope_state = "smallrifle_scope"
	scope_x_offset = 5
	scope_y_offset = 13

//R82/N				Keywords: NCR, 5.56mm, Semi-Auto, 20 (10-50) round mags.
/obj/item/gun/ballistic/automatic/service/r82/ncr
	name = "NCR R82 Heavy Service Rifle"
	desc = "The assault rifle variant of the R84, based off the pre-war FN FNC. Issued to high-ranking troopers and specialized units. Chambered in 5.56."
	fire_delay = 1 //faster ROF, superior to regular service rifle
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	icon_state = "R82_ncr"
	item_state = "R84"
	//automatic = 1
	spread = 3
	burst_size = 1
	semi_auto = TRUE
	burst_shot_delay = 3.0 //Was 2.2 before.
	can_automatic = FALSE
	untinkerable = TRUE
	can_suppress = TRUE
	can_scope = TRUE
	suppressor_state = "rifle_suppressor"
	suppressor_x_offset = 27
	suppressor_y_offset = 28
	scope_state = "smallrifle_scope"
	scope_x_offset = 5
	scope_y_offset = 13

//R82 'Pilum'		Keywords: Legion, 5.56mm, Semi-Auto, 20 (10-50) round mags.
/obj/item/gun/ballistic/automatic/service/r82/legion
	name = "'Pilum' Rifle"
	desc = "An old unmantained R91 with cut down stock and refurbished wooden furniture. It features a mark of bull on it and feels heavier than usual."
	icon_state = "pilum"
	item_state = "fnfal"
	can_automatic = FALSE
	untinkerable = TRUE
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	fire_delay = 3
	burst_shot_delay = 2
	force = 20
	spread = 1
	suppressor_state = "suppressor"
	can_scope = TRUE
	scope_state = "smallrifle_scope"
	scope_x_offset = 4
	scope_y_offset = 15
	suppressor_x_offset = 31
	suppressor_y_offset = 15
	bayonet_state = "rifles"
	knife_x_offset = 22
	knife_y_offset = 12

//R91 Assault Rifle		Keywords: 5.56, Automatic, 20 (10-50) round mags.
/obj/item/gun/ballistic/automatic/assault_rifle
	name = "R91 Assault Rifle"
	desc = "A standard R91 assault rifle, out of use around the time of the Great War."
	icon_state = "assault_rifle"
	item_state = "fnfal"
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 25
	burst_size = 2
	fire_delay = 4
	burst_shot_delay = 3
	can_attachments = TRUE
	can_bayonet = TRUE
	bayonet_state = "rifles"
	knife_x_offset = 23
	knife_y_offset = 11
	spread = 8
	can_suppress = TRUE
	suppressor_x_offset = 32
	suppressor_y_offset = 15
	suppressor_state = "ar_suppressor"

//R91 "Infiltrator"		Keywords: 5.56, Autoamtic, 20 (10-50) round mags, Scoped.
/obj/item/gun/ballistic/automatic/assault_rifle/infiltrator
	name = "Infiltrator"
	desc = "A customized R91 assault rifle, with an integrated suppressor, cut down stock and polymer furniture."
	icon_state = "infiltrator"
	item_state = "fnfal"
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	can_suppress = FALSE
	can_unsuppress = FALSE
	suppressed = 1
	fire_delay = 3
	burst_shot_delay = 2
	fire_sound = 'sound/weapons/Gunshot_large_silenced.ogg'
	can_bayonet = FALSE
	force = 15
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	spread = 1

//Type 93			Keywords: 5.56, Automatic, 20 (10-50) round mags. Notes: Some extra damage.
/obj/item/gun/ballistic/automatic/type93
	name = "Type 93 Assault Rifle"
	desc = "The Type 93 Chinese assault rifle was designed and manufactured by a Chinese industrial conglomerate for the People's Liberation Army during the Resource Wars, for the purpose of equipping the Chinese infiltrators and American fifth-columnists. Chambered in 5.56x45."
	icon_state = "type93"
	item_state = "handmade_rifle"
	icon = 'icons/obj/guns/ballistic/type93.dmi'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	can_suppress = TRUE
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	fire_sound = 'sound/f13weapons/assaultrifle_fire.ogg'
	burst_size = 2
	fire_delay = 3
	can_attachments = TRUE
	can_scope = FALSE
	can_bayonet = FALSE
	spread = 10
	extra_damage = 2
	suppressor_state = "suppressor"
	suppressor_x_offset = 40
	suppressor_y_offset = 18

//Bozar				Keywords: 5.56, Automatic, 20 (10-50) round mags, Scoped.
/obj/item/gun/ballistic/automatic/bozar
	name = "Bozar"
	desc = "The ultimate refinement of the sniper's art, the Bozar is a scoped, accurate, light machine gun that will make nice big holes in your enemy. Uses 5.56."
	icon_state = "bozar"
	item_state = "sniper"
	slot_flags = SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	burst_size = 3
	fire_delay = 3
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/f13weapons/bozar_fire.ogg'
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	can_attachments = TRUE
	can_scope = FALSE

//Assault Carbine	Keywords: 5.56, Automatic, 20 (10-50) round mags.
/obj/item/gun/ballistic/automatic/assault_carbine
	name = "assault carbine"
	desc = "The U.S. army carbine version of the R91, made by Colt and issued to special forces."
	icon_state = "assault_carbine"
	item_state = "assault_carbine"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	fire_delay = 3.5
	burst_shot_delay = 2.5
	spread = 8
	recoil = 0.1
	can_attachments = TRUE
	can_scope = TRUE
	scope_state = "scope_short"
	scope_x_offset = 4
	scope_y_offset = 15
	can_suppress = TRUE
	suppressor_state = "rifle_suppressor"
	suppressor_x_offset = 26
	suppressor_y_offset = 28
	actions_types = list(/datum/action/item_action/toggle_firemode)
	fire_sound = 'sound/f13weapons/assault_carbine.ogg'

//H&K G11			Keywords: 4.73mm, Automatic, 50 round mags.
/obj/item/gun/ballistic/automatic/g11
	name = "G11"
	desc = "This gun revolutionized assault weapon design. The weapon fires a caseless cartridge consisting of a block of propellant with a bullet buried inside. The resultant weight and space savings allow this weapon to have a very high magazine capacity. Chambered in 4.73mm."
	icon_state = "g11"
	item_state = "g11"
	mag_type = /obj/item/ammo_box/magazine/m473
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 25
	burst_size = 2
	fire_delay = 2
	burst_shot_delay = 2
	can_suppress = FALSE
	can_attachments = TRUE
	spread = 10
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	can_attachments = TRUE
	can_scope = FALSE
	burst_size = 1
	can_automatic = TRUE
	semi_auto = TRUE
	pin = null
	extra_damage = 0
	extra_penetration = 0


////////////////
//MACHINE-GUNS//
////////////////

//R84			Keywords: NCR, 5.56, 60 round mags.
/obj/item/gun/ballistic/automatic/r84
	name = "R84 LMG"
	desc = "A post war lmg, traditionally manufactured by NCR forces. It is designed as a suppressive support weapon, generally granted to Heavy Troopers to compliment their stripped power armor."
	icon_state = "R84"
	item_state = "R84"
	slot_flags = 0
	//automatic = 1
	mag_type = /obj/item/ammo_box/magazine/lmg
	fire_sound = 'sound/f13weapons/assaultrifle_fire.ogg'
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 3
	burst_shot_delay = 3
	slowdown = 1.0
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	spread = 25
	randomspread = 1

/obj/item/gun/ballistic/automatic/r84/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select += 1
			burst_size = 2
			spread = 35
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(1)
			select += 1
			burst_size = 3
			spread = 45
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(2)
			select = 0
			burst_size = 1
			spread = 25
			to_chat(user, "<span class='notice'>You switch to semi-automatic.</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

//Bastard Gun		Keywords: 5.56, 60 round mags. Notes: Snowflake gun based on the Metro bastard gun. More spread, lower damage; inferior R-84.
/obj/item/gun/ballistic/automatic/bastard
	name = "'Bastard' LMG"
	desc = "A post-war design made of various gun parts from various models, ranging from R-91 parts to even parts from the R84, CAR-15 or the Type 93. Some gun gun-nut really got this abomination to work.."
	icon_state = "bastard"
	item_state = "bastard"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/lmg
	fire_sound = 'sound/f13weapons/assaultrifle_fire.ogg'
	can_attachments = TRUE
	can_suppress = TRUE
	suppressor_x_offset = 27
	suppressor_y_offset = 28
	suppressor_state = "suppressor"
	burst_size = 2
	fire_delay = 3
	burst_shot_delay = 3
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	spread = 30
	randomspread = 1
	extra_damage = -2

//LSW Squad Support Weapon		Keywords: 5.56,20 (10-50) round mags, Scoped.
/obj/item/gun/ballistic/automatic/lsw
	name = "Light Support Weapon"
	desc = "This squad-level support weapon has a bullpup design. The bullpup design makes it difficult to use while lying down. Because of this it was remanded to National Guard units. It, however, earned a reputation as a reliable weapon that packs a lot of punch for its size."
	icon_state = "lsw"
	item_state = "lsw"
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 25
	burst_size = 2
	fire_delay = 5
	burst_shot_delay = 2
	can_suppress = FALSE
	spawnwithmagazine = TRUE
	can_bayonet = FALSE
	spread = 15
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	can_attachments = TRUE
	can_scope = FALSE

/obj/item/gun/ballistic/automatic/lsw/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select += 1
			burst_size = 2
			spread = 10
			extra_damage = -3
			recoil = 0.25
			to_chat(user, "<span class='notice'>You switch to burst fire.</span>")
		if(1)
			select = 0
			burst_size = 4
			spread = 14
			extra_damage = -6
			recoil = 0.5
			to_chat(user, "<span class='notice'>You switch to full auto.</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

//X170E3		Keywords: 5.56, 20 (10-50) round mags, scoped.
/obj/item/gun/ballistic/automatic/xl70e3
	name = "Xl70E3"
	desc = "This was an experimental weapon at the time of the war. Manufactured, primarily, from high-strength polymers, the weapon is almost indestructible. It's light, fast firing, accurate, and can be broken down without the use of any tools. Chamebered in 5.56mm."
	icon_state = "xl70e3"
	item_state = "xl70e3"
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 25
	burst_size = 2
	fire_delay = 1
	burst_shot_delay = 1
	can_suppress = FALSE
	spawnwithmagazine = TRUE
	can_bayonet = FALSE
	spread = 4
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	can_attachments = TRUE
	can_scope = FALSE
	extra_damage = 1.2
	fire_sound = 'sound/f13weapons/assault_carbine.ogg'

//M1919 Machinegun		Keywords: .308/7.62, Automatic, 80 round belt. Notes: DAKA DAKA DAKA - Careful with these. High damage.
/obj/item/gun/ballistic/automatic/m1919
	name = "Browning M1919"
	desc = "An old pre-war machine gun used in service by the US Military around the time of the war. Rechambered in 7.62x51."
	icon_state = "M38"
	item_state = "M38"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/mm762
	fire_sound = 'sound/f13weapons/assaultrifle_fire.ogg'
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 3
	slowdown = 1
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	spread = 20
	var/cover_open = FALSE

/obj/item/gun/ballistic/automatic/m1919/update_icon()
	icon_state = "M38[cover_open ? "open" : "closed"][magazine ? CEILING(get_ammo(0)/20, 1)*20 : "-empty"]"
	item_state = "M38[cover_open ? "open" : "closed"][magazine ? "mag" : "nomag"]"

/obj/item/gun/ballistic/automatic/m1919/examine(mob/user)
	. = ..()
	if(cover_open && magazine)
		. += "<span class='notice'>It seems like you could use an <b>empty hand</b> to remove the magazine.</span>"

/obj/item/gun/ballistic/automatic/m1919/attack_self(mob/user)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	if(cover_open)
		playsound(user, 'sound/weapons/sawopen.ogg', 60, 1)
	else
		playsound(user, 'sound/weapons/sawclose.ogg', 60, 1)
	update_icon()

/obj/item/gun/ballistic/automatic/m1919/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is open! Close it before firing!</span>")
	else
		. = ..()
		update_icon()

/obj/item/gun/ballistic/automatic/m1919/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.forceMove(drop_location())
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")
		playsound(user, 'sound/weapons/magout.ogg', 60, 1)

/obj/item/gun/ballistic/automatic/m1919/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, mag_type))
		to_chat(user, "<span class='warning'>[src]'s cover is closed! You can't insert a new mag.</span>")
		return
	..()

/obj/item/gun/ballistic/automatic/m1919/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select += 1
			burst_size = 2
			spread = 30
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(1)
			select += 1
			burst_size = 3
			spread = 40
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(2)
			select += 1
			burst_size = 4
			spread = 50
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(3)
			select = 0
			burst_size = 1
			spread = 20
			to_chat(user, "<span class='notice'>You switch to semi-automatic.</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

//M2A1 HMG			Keywords: .50 Cal, Automatic, ??? .50 belts. Notes: Holy shit a .50 machine gun. Don't use this often; admin spawn only for the love of god.
/obj/item/gun/ballistic/automatic/m2a1
	name = "Browning M2A1"
	desc = "An old pre-war heavy machine gun used in service by the US Military around the time of the war."
	icon_state = "M38"
	item_state = "M38"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/mm50
	fire_sound = 'sound/f13weapons/antimaterielfire.ogg'
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 3
	slowdown = 1
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	spread = 20
	var/cover_open = FALSE

/obj/item/gun/ballistic/automatic/m2a1/update_icon()
	icon_state = "m2a1[cover_open ? "open" : "closed"][magazine ? CEILING(get_ammo(0)/20, 1)*20 : "-empty"]"
	item_state = "m2a1[cover_open ? "open" : "closed"][magazine ? "mag" : "nomag"]"

/obj/item/gun/ballistic/automatic/m2a1/examine(mob/user)
	. = ..()
	if(cover_open && magazine)
		. += "<span class='notice'>It seems like you could use an <b>empty hand</b> to remove the magazine.</span>"

/obj/item/gun/ballistic/automatic/m2a1/attack_self(mob/user)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	if(cover_open)
		playsound(user, 'sound/weapons/sawopen.ogg', 60, 1)
	else
		playsound(user, 'sound/weapons/sawclose.ogg', 60, 1)
	update_icon()

/obj/item/gun/ballistic/automatic/m2a1/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is open! Close it before firing!</span>")
	else
		. = ..()
		update_icon()

/obj/item/gun/ballistic/automatic/m2a1/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.forceMove(drop_location())
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")
		playsound(user, 'sound/weapons/magout.ogg', 60, 1)

/obj/item/gun/ballistic/automatic/m2a1/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, mag_type))
		to_chat(user, "<span class='warning'>[src]'s cover is closed! You can't insert a new mag.</span>")
		return
	..()

/obj/item/gun/ballistic/automatic/m2a1/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select += 1
			burst_size = 2
			spread = 30
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(1)
			select += 1
			burst_size = 3
			spread = 40
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(2)
			select += 1
			burst_size = 4
			spread = 50
			to_chat(user, "<span class='notice'>You switch to [burst_size]-rnd burst.</span>")
		if(3)
			select = 0
			burst_size = 1
			spread = 20
			to_chat(user, "<span class='notice'>You switch to semi-automatic.</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return


////////
//MISC//
////////

//M72 Gauss Rifle		Keywords: 2mm cartriage, 8 round capacity, scoped, ballistic-'energy' sniper.
/obj/item/gun/ballistic/automatic/m72
	name = "M72 Gauss Rifle"
	desc = "The M72 rifle is of German design. It uses an electromagnetic field to propel rounds at tremendous speed... and pierce almost any obstacle. Its range, accuracy and stopping power is almost unparalleled."
	icon_state = "m72"
	item_state = "shotgun"
	slot_flags = SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/m2mm
	fire_sound = 'sound/f13weapons/gauss_rifle.ogg'
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 15
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	//projectile_speed = 0
	recoil = 2
	semi_auto = TRUE

//Auto-pipe rifle		Keywords: .357, 30 round belts, improvised.
//Select fire removed, too fancy. Belt fed and can tape bayonets to it now. Can't figure out how to make it change icons as the belt is depleted, like the L6 and C20r, sprites there, just dont know the code.
/obj/item/gun/ballistic/automatic/autopipe
	name = "Auto pipe rifle (.357)"
	desc = "Crude automatic weapon, no safety, overheats almost instantly, but what do you expect from pipes and duct tape?"
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	icon_state = "autopipe"
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	item_state = "autopipe"
	burst_size = 4
	fire_delay = 30
	burst_shot_delay = 3
	spread = 24
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	/*slot_flags = ITEM_SLOT_BACK   sprite won't show up for some reason */
	mag_type = /obj/item/ammo_box/magazine/autopipe
	fire_sound = 'sound/f13weapons/357magnum.ogg'
	can_suppress = FALSE
	can_bayonet = TRUE
	bayonet_state = "lasmusket"
	knife_x_offset = 22
	knife_y_offset = 21
	semi_auto = FALSE
