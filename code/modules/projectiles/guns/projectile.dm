
#define HOLD_CASINGS	0 //do not do anything after firing. Manual action, like pump shotguns, or guns that want to define custom behaviour. Incompatible with magazines.
#define EJECT_CASINGS	1 //drop spent casings on the ground after firing
#define CYCLE_CASINGS 	2 //experimental: cycle casings, like a revolver. Also works for multibarrelled guns


/obj/item/gun/projectile
	name = "gun"
	desc = "A gun that fires bullets."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "revolver"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 1)
	recoil_buildup = 1
	bad_type = /obj/item/gun/projectile
	spawn_tags = SPAWN_TAG_GUN_PROJECTILE

	var/caliber = CAL_357		//determines which casings will fit
	var/handle_casings = EJECT_CASINGS	//determines how spent casings should be handled
	var/load_method = SINGLE_CASING|SPEEDLOADER //1 = Single shells, 2 = box or quick loader, 3 = magazine
	var/obj/item/ammo_casing/chambered // is a reference to the first casing in either mag

	//gunporn stuff
	var/unload_sound = 'sound/weapons/guns/interact/pistol_magout.ogg'
	var/reload_sound = 'sound/weapons/guns/interact/pistol_magin.ogg'
	var/cocked_sound = 'sound/weapons/guns/interact/pistol_cock.ogg'
	var/bulletinsert_sound = 'sound/weapons/guns/interact/bullet_insert.ogg'

	//For SINGLE_CASING or SPEEDLOADER guns
	var/max_shells = 0			//the number of casings that will fit inside
	var/ammo_type		//the type of ammo that the gun comes preloaded with
	var/list/internal_piles = list() // tracks stored ammo piles
	var/list/bullet_order = list()	// tracks the bullet order by referencing the piles list
	var/ammo_amount // tracks how much ammo is in the gun

	//For MAGAZINE guns
	var/magazine_type		//the type of magazine that the gun comes preloaded with
	var/obj/item/ammo_magazine/ammo_magazine	 //stored magazine
	var/mag_well = MAG_WELL_GENERIC	//What kind of magazines the gun can load
	var/auto_eject = FALSE			//if the magazine should automatically eject itself when empty.
	var/auto_eject_sound
	var/ammo_mag = "default" // magazines + gun itself. if set to default, then not used
	var/tac_reloads = TRUE	// Enables guns to eject mag and insert new magazine.
	var/no_internal_mag = FALSE // to bar sniper and double-barrel from installing overshooter.

/obj/item/gun/projectile/Destroy()
	// QDEL_NULL(chambered)
	QDEL_NULL(ammo_magazine)
	QDEL_NULL(internal_piles)
	return ..()

/obj/item/gun/projectile/proc/cock_gun(mob/user)
	set waitfor = 0
	if(cocked_sound)
		sleep(3)
		if(user && loc) playsound(src.loc, cocked_sound, 75, 1)

/obj/item/gun/projectile/consume_next_projectile()
	//get the next casing
	if(ammo_amount)
		chambered = internal_piles[bullet_order[1]] //load next casing.
	else if(ammo_magazine && ammo_magazine.ammo_amount)
		chambered = ammo_magazine.internal_piles[bullet_order[1]]

	if (chambered && !chambered.spent)
		return chambered.projectile_type

/obj/item/gun/projectile/handle_post_fire()
	..()
	if(chambered)
		process_chambered()


/obj/item/gun/projectile/proc/process_chambered()
	if (!chambered) return
	var/obj/item/ammo_casing/spent_ammo = chambered.expend() // returns one casing from the pile chambered references, spends it
	var/isthesame = chambered == spent_ammo ? TRUE : FALSE // if should edit internal_piles
	if(chambered.is_caseless)
		qdel(spent_ammo)
		var/pilelistposition = bullet_order[1]
		bullet_order.Cut(1,2)
		if (isthesame)
			for(var/bulletindex in bullet_order)
				if (bulletindex > pilelistposition)
					bulletindex --
			internal_piles.Remove(spent_ammo)
		return
	// Aurora forensics port, gunpowder residue.
	if(chambered.leaves_residue)
		var/mob/living/carbon/human/H = loc
		if(istype(H))
			if(!H.gloves)
				H.gunshot_residue = chambered.caliber
			else
				var/obj/item/clothing/G = H.gloves
				G.gunshot_residue = chambered.caliber

	switch(handle_casings)
		if(EJECT_CASINGS) //eject casing onto ground.
			if (ammo_amount)
				ammo_amount --
				bullet_order.Cut(1,2)
				if (isthesame)
					internal_piles.Remove(spent_ammo)
					chambered = null
			else if (ammo_magazine && ammo_magazine.ammo_amount)
				ammo_magazine.ammo_amount --
				ammo_magazine.bullet_order.Cut(1,2)
				if (isthesame)
					ammo_magazine.internal_piles.Remove(spent_ammo)
					chambered = null
			spent_ammo.forceMove(get_turf(src))
			for(var/obj/item/ammo_casing/temp_casing in spent_ammo.loc)
				if(temp_casing == spent_ammo)
					continue
				if((temp_casing.desc == spent_ammo.desc) && temp_casing.spent)
					var/temp_amount = temp_casing.amount + spent_ammo.amount
					if(temp_amount > spent_ammo.maxamount)
						temp_casing.amount -= (spent_ammo.maxamount - spent_ammo.amount)
						spent_ammo.amount = spent_ammo.maxamount
						temp_casing.update_icon()
					else
						spent_ammo.amount = temp_amount
						QDEL_NULL(temp_casing)
					spent_ammo.update_icon()

			playsound(src.loc, casing_sound, 50, 1)
		if(CYCLE_CASINGS) //cycle the casing back to the end.
			if(ammo_magazine)
				ammo_magazine.bullet_order.Cut(1,2)
				if (isthesame)
					var/pilelistposition = ammo_magazine.bullet_order[1]
					for(var/bulletindex in ammo_magazine.bullet_order)
						if(bulletindex > pilelistposition)
							bulletindex --
					ammo_magazine.internal_piles.Remove(spent_ammo)
					chambered = null
				ammo_magazine.insertCasing(spent_ammo, cycle_casings = TRUE)
			else
				bullet_order.Cut(1,2)
				if (isthesame)
					var/pilelistposition = bullet_order[1]
					for(var/bulletindex in bullet_order)
						if(bulletindex > pilelistposition)
							bulletindex --
					internal_piles.Remove(spent_ammo)
					chambered = null
				insertCasing(spent_ammo, cycle_casings = TRUE)



//Attempts to load A into src, depending on the type of thing being loaded and the load_method
//Maybe this should be broken up into separate procs for each load method?
/obj/item/gun/projectile/proc/load_ammo(obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = A
		if(!(load_method & AM.mag_type) || caliber != AM.caliber)
			to_chat(user, SPAN_WARNING("[AM] won't fit into the magwell. This mag and ammunition inside it is incompatible with [src]."))
			return //incompatible

		//How are we trying to apply this magazine to this gun?
		//Its possible for both magazines and guns to support multiple load methods.
		//In the case of that, we use a fixed order to determine whats most desireable
		var/method_for_this_load = 0

		//Magazine loading takes precedence first
		if ((load_method & AM.mag_type) & MAGAZINE)
			method_for_this_load = MAGAZINE
		//Speedloading second
		else if ((load_method & AM.mag_type) & SPEEDLOADER)
			method_for_this_load = SPEEDLOADER
		else if ((load_method & AM.mag_type) & SINGLE_CASING)
			method_for_this_load = SINGLE_CASING
		else
			//Not sure how this could happen, sanity check. Abort and return if none of the above were true
			return

		switch(method_for_this_load)
			if(MAGAZINE)
				//if(AM.ammo_mag != ammo_mag && ammo_mag != "default")	Not needed with mag_wells
				//	to_chat(user, SPAN_WARNING("[src] requires another magazine.")) //wrong magazine
				//	return
				if(tac_reloads && ammo_magazine)
					unload_ammo(user)	// ejects the magazine before inserting the new one.
					to_chat(user, SPAN_NOTICE("You tactically reload your [src] with [AM]!"))
				else if(ammo_magazine)
					to_chat(user, SPAN_WARNING("[src] already has a magazine loaded.")) //already a magazine here
					return
				if(!(AM.mag_well & mag_well))
					to_chat(user, SPAN_WARNING("[AM] won't fit into the magwell.")) //wrong magazine
					return
				user.remove_from_mob(AM)
				AM.loc = src
				ammo_magazine = AM

				if(reload_sound) playsound(src.loc, reload_sound, 75, 1)
				cock_gun(user)
				update_firemode()
			if(SPEEDLOADER)
				if(ammo_amount >= max_shells)
					to_chat(user, SPAN_WARNING("[src] is full!"))
					return
				var/count = 0
				if(AM.reload_delay)
					to_chat(user, SPAN_NOTICE("It takes some time to reload [src] with [AM]..."))
				if (do_after(user, AM.reload_delay, user))
					var/obj/item/ammo_casing/temp_casing = AM.removeCasing(max_shells - ammo_amount, FALSE)
					count = max_shells - ammo_amount
					insertCasing(temp_casing, temp_casing.amount)
				if(count)
					user.visible_message("[user] reloads [src].", SPAN_NOTICE("You load [count] round\s into [src]."))
					if(reload_sound) playsound(src.loc, reload_sound, 75, 1)
					cock_gun(user)
				update_firemode()
		AM.update_icon()
	else if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = A
		if(!(load_method & SINGLE_CASING) || caliber != C.caliber)
			to_chat(user, SPAN_WARNING("[src] is incompatible with [C]."))
			return //incompatible
		if(ammo_amount >= max_shells)
			to_chat(user, SPAN_WARNING("[src] is full."))
			return

		if(C.reload_delay)
			to_chat(user, SPAN_NOTICE("It takes some time to reload [src] with [C]..."))
		if (!do_after(user, C.reload_delay, user))
			return

		insertCasing(C)
		update_firemode()
		user.visible_message("[user] inserts \a [C] into [src].", SPAN_NOTICE("You insert \a [C] into [src]."))
		if(bulletinsert_sound) playsound(src.loc, bulletinsert_sound, 75, 1)

	update_icon()

//attempts to unload src. If allow_dump is set to 0, the speedloader unloading method will be disabled
/obj/item/gun/projectile/proc/unload_ammo(mob/user, var/allow_dump=1)
	if(ammo_magazine)
		user.put_in_hands(ammo_magazine)

		if(unload_sound)
			playsound(src.loc, unload_sound, 75, 1)
		ammo_magazine.update_icon()
		ammo_magazine = null
	else if(ammo_amount)
		//presumably, if it can be speed-loaded, it can be speed-unloaded.
		if(allow_dump && (load_method & SPEEDLOADER))
			var/count = 0
			var/turf/T = get_turf(user)
			if(T)
				for(var/obj/item/ammo_casing/pile in internal_piles)
					pile.forceMove(T)
					pile.set_dir(pick(cardinal))
					count ++
				bullet_order.Cut()
				ammo_amount = 0
			if(count)
				user.visible_message("[user] unloads [src].", SPAN_NOTICE("You unload [count] pile\s from [src]."))
				if(bulletinsert_sound) playsound(src.loc, bulletinsert_sound, 75, 1)
		else if(load_method & SINGLE_CASING)
			var/obj/item/ammo_casing/C = removeCasing()
			if (istype(user.get_inactive_hand(), /obj/item/ammo_casing))
				C.mergeCasing(user.get_inactive_hand(), noMessage = TRUE)
			user.put_in_hands(C)
			user.visible_message("[user] removes \a [C] from [src].", SPAN_NOTICE("You remove \a [C] from [src]."))
			if(bulletinsert_sound) playsound(src.loc, bulletinsert_sound, 75, 1)
	else
		to_chat(user, SPAN_WARNING("[src] is empty."))
	update_icon()

/obj/item/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob)
	.=..()
	if (!.) //Parent returns true if attackby is handled
		load_ammo(A, user)

/obj/item/gun/projectile/attack_self(mob/user as mob)
	if(firemodes.len > 1)
		..()
	else
		unload_ammo(user)

/obj/item/gun/projectile/attack_hand(mob/user as mob)
	if(user.get_inactive_hand() == src)
		unload_ammo(user, allow_dump=0)
	else
		return ..()

/obj/item/gun/projectile/MouseDrop(over_object, src_location, over_location)
	..()
	if(src.loc == usr && istype(over_object, /obj/screen/inventory/hand))
		unload_ammo(usr, allow_dump=0)

/obj/item/gun/projectile/afterattack(atom/A, mob/living/user)
	..()
	if(auto_eject && !ammo_magazine?.ammo_amount)
		ammo_magazine.forceMove(get_turf(src.loc))
		user.visible_message(
			"[ammo_magazine] falls out and clatters on the floor!",
			SPAN_NOTICE("[ammo_magazine] falls out and clatters on the floor!")
			)
		if(auto_eject_sound)
			playsound(user, auto_eject_sound, 40, 1)
		ammo_magazine.update_icon()
		ammo_magazine = null
		update_icon() //make sure to do this after unsetting ammo_magazine

/obj/item/gun/projectile/examine(mob/user)
	..(user)
	if(ammo_magazine)
		to_chat(user, "It has \a [ammo_magazine] loaded.")
	to_chat(user, "Has [get_ammo()] round\s remaining.")
	return

/obj/item/gun/projectile/proc/get_ammo()
	var/bullets = 0
	if(ammo_amount)
		bullets += ammo_amount
	if(ammo_magazine && ammo_magazine.ammo_amount)
		bullets += ammo_magazine.ammo_amount
	return bullets

/obj/item/gun/projectile/proc/get_max_ammo()
	var/bullets = 0
	if (load_method & MAGAZINE)
		if(ammo_magazine)
			bullets += ammo_magazine.max_ammo
	if (load_method & SPEEDLOADER)
		bullets += max_shells
	return bullets

/* Unneeded -- so far.
//in case the weapon has firemodes and can't unload using attack_hand()
/obj/item/gun/projectile/verb/unload_gun()
	set name = "Unload Ammo"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained()) return

	unload_ammo(usr)
*/

/obj/item/gun/projectile/ui_data(mob/user)
	var/list/data = ..()
	data["caliber"] = caliber
	data["current_ammo"] = get_ammo()
	data["max_shells"] = get_max_ammo()

	return data

/obj/item/gun/projectile/get_dud_projectile()
	var/proj_type
	if(ammo_amount)
		var/obj/item/ammo_casing/A = internal_piles[1]
		if(A.spent)
			return null
		proj_type = A.projectile_type
	else if(ammo_magazine && ammo_magazine.ammo_amount)
		var/obj/item/ammo_casing/A = ammo_magazine.internal_piles[1]
		if(A.spent)
			return null
		proj_type = A.projectile_type
	if(!proj_type)
		return null
	return new proj_type

/obj/item/gun/projectile/refresh_upgrades()
	max_shells = initial(max_shells)
	..()

/obj/item/gun/projectile/generate_guntags()
	..()
	gun_tags |= GUN_PROJECTILE
	switch(caliber)
		if(CAL_PISTOL)
			gun_tags |= GUN_CALIBRE_35
		//Others to be implemented when needed
	if(max_shells && !no_internal_mag) // so the overshooter can't be attached to the AMR and double-barrel anymore
		gun_tags |= GUN_INTERNAL_MAG

// cycle sends it to the end of bullet_order instead of the start
/obj/item/gun/projectile/proc/insertCasing(var/obj/item/ammo_casing/C, var/inserted_amount = 1, var/cycle_casings = FALSE)
	if(!istype(C))
		return FALSE
	if(C.caliber != caliber)
		return FALSE
	if(ammo_amount >= max_shells)
		return FALSE
	if (C.amount < inserted_amount)
		inserted_amount = C.amount
	if (inserted_amount > max_shells - ammo_amount)
		inserted_amount = max_shells - ammo_amount
	C.amount -= inserted_amount
	for(var/loop = 0, loop < inserted_amount, loop ++)
		var/needsnewpile = TRUE
		var/pilenum = 0
		for(var/obj/item/ammo_casing/ammo_pile in internal_piles)
			pilenum ++
			if(ammo_pile.amount < ammo_pile.maxamount)
				if(C.projectile_type == ammo_pile.projectile_type && C.spent == ammo_pile.spent)
					ammo_pile.amount ++
					needsnewpile = FALSE
					break
		if(needsnewpile)
			var/obj/item/ammo_casing/newpile = C.duplicate()
			internal_piles.Add(newpile)
			pilenum ++
		if (cycle_casings)
			bullet_order.Add(1, pilenum)
		else
			bullet_order.Insert(1, pilenum)
	C.update_icon()
	ammo_amount += inserted_amount
	if(C.amount <= 0)
		if(ismob(C.loc))
			var/mob/M = C.loc
			M.remove_from_mob(C)
		qdel(C)
	update_icon()
	return TRUE

// disabling pile makes the casings returned be in order instead of stacked
// disabling create makes it never create the casings
/obj/item/gun/projectile/proc/removeCasing(var/removed_amount = 1, var/pile = TRUE, var/create = TRUE)
	if(ammo_amount)
		if (removed_amount == 1)
			var/obj/item/ammo_casing/piletoget = internal_piles[bullet_order[1]]
			var/obj/item/ammo_casing/returned_casing = create ? piletoget.duplicate() : 1
			piletoget.amount --		
			ammo_amount --
			if(piletoget.amount <= 0)
				var/pilelistposition = bullet_order[1]
				for(var/bulletindex in bullet_order)
					if(bulletindex > pilelistposition)
						bulletindex --
				internal_piles.Remove(piletoget)
				qdel(piletoget)
			bullet_order.Cut(1,2)
			update_icon()
			return returned_casing
		else if (removed_amount > 1)
			if (removed_amount > ammo_amount)
				removed_amount = ammo_amount
			if (create)
				var/list/returned_piles = list()
				for(var/loop = 0, loop < removed_amount, loop++)
					var/obj/item/ammo_casing/piletoget = internal_piles[bullet_order[1]]
					var/needsnewpile = TRUE
					if (pile)
						for(var/obj/item/ammo_casing/ammo_pile in returned_piles)
							if(piletoget.projectile_type == ammo_pile.projectile_type && piletoget.spent == ammo_pile.spent)
								ammo_pile.amount ++
								needsnewpile = FALSE
								break
					else
						var/obj/item/ammo_casing/ammo_pile = returned_piles[length(returned_piles)]
						if(piletoget.projectile_type == ammo_pile.projectile_type && piletoget.spent == ammo_pile.spent)
							ammo_pile.amount ++
							needsnewpile = FALSE
					if(needsnewpile)
						var/newpile = piletoget.duplicate()
						returned_piles += newpile
					piletoget.amount --
					ammo_amount --
					bullet_order.Cut(1,2)
					if (piletoget.amount <= 0)
						var/pilelistposition = bullet_order[1]
						for(var/bulletindex in bullet_order)
							if(bulletindex > pilelistposition)
								bulletindex --
						internal_piles.Remove(piletoget)
						qdel(piletoget)
				return returned_piles
				
			else
				for(var/loop = 0, loop < removed_amount, loop++)
					var/obj/item/ammo_casing/piletoget = internal_piles[bullet_order[loop+1]]
					piletoget.amount --
					if (piletoget.amount <= 0)
						internal_piles.Remove(piletoget)
						qdel(piletoget)
				ammo_amount -= removed_amount
				bullet_order.Cut(1,removed_amount+1)
				return removed_amount
		else
			return FALSE





