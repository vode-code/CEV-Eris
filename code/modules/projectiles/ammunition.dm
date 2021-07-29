/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 1
	w_class = ITEM_SIZE_TINY

	var/leaves_residue = 1
	var/is_caseless = FALSE
	var/caliber = ""					//Which kind of guns it can be loaded into
	var/obj/item/projectile_type = /obj/item/projectile		//The bullet type to create when New() is called
	var/spent = FALSE
	var/spent_icon
	var/amount = 1
	var/maxamount = 15
	var/reload_delay = 0

	var/sprite_update_spawn = FALSE		//defaults to normal sized sprites
	var/sprite_max_rotate = 16
	var/sprite_scale = 1
	var/sprite_use_small = TRUE 		//A var for a later global option to use all big sprites or small sprites for bullets, must be used before startup

/obj/item/ammo_casing/Initialize()
	. = ..()
	if(sprite_update_spawn)
		var/matrix/rotation_matrix = matrix()
		rotation_matrix.Turn(round(45 * rand(0, sprite_max_rotate) / 2))
		if(sprite_use_small)
			src.transform = rotation_matrix * sprite_scale
		else
			src.transform = rotation_matrix
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	if(amount > 1)
		update_icon()

// returns a spent casing, which is a removed duplicate if amount is bigger than one, and is it otherwise
/obj/item/ammo_casing/proc/expend()
	if(amount > 1)
		var/obj/item/ammo_casing/duplicate = duplicate()
		duplicate.spent = TRUE
		amount --
		duplicate.set_dir(pick(cardinal)) //spin spent casings
		duplicate.update_icon()
		update_icon()
		return duplicate
	else
		spent = TRUE
		set_dir(pick(cardinal)) //spin spent casings
		update_icon()
		return src

/obj/item/ammo_casing/attack_hand(mob/user)
	if((src.amount > 1) && (src == user.get_inactive_hand()))
		src.amount -= 1
		var/obj/item/ammo_casing/new_casing = new /obj/item/ammo_casing(get_turf(user))
		new_casing.name = src.name
		new_casing.desc = src.desc
		new_casing.caliber = src.caliber
		new_casing.projectile_type = src.projectile_type
		new_casing.icon_state = src.icon_state
		new_casing.spent_icon = src.spent_icon
		new_casing.maxamount = src.maxamount
		new_casing.spent = src.spent
		new_casing.sprite_max_rotate = src.sprite_max_rotate
		new_casing.sprite_scale = src.sprite_scale
		new_casing.sprite_use_small = src.sprite_use_small
		new_casing.sprite_update_spawn = src.sprite_update_spawn

		if(new_casing.sprite_update_spawn)
			var/matrix/rotation_matrix = matrix()
			rotation_matrix.Turn(round(45 * rand(0, new_casing.sprite_max_rotate) / 2))
			if(new_casing.sprite_use_small)
				new_casing.transform = rotation_matrix * new_casing.sprite_scale
			else
				new_casing.transform = rotation_matrix

		new_casing.is_caseless = src.is_caseless


		new_casing.update_icon()
		src.update_icon()
		user.put_in_active_hand(new_casing)
	else
		return ..()

/obj/item/ammo_casing/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/merging_casing = I
		if(isturf(src.loc))
			if(merging_casing.amount == merging_casing.maxamount)
				to_chat(user, SPAN_WARNING("[merging_casing] is fully stacked!"))
				return FALSE
			if(merging_casing.mergeCasing(src, null, user))
				return TRUE
		else if (mergeCasing(I, 1, user))
			return TRUE

/obj/item/ammo_casing/proc/mergeCasing(var/obj/item/ammo_casing/AC, var/amountToMerge, var/mob/living/user, var/noMessage = FALSE, var/noIconUpdate = FALSE)
	if(!AC)
		return FALSE
	if(!user && noMessage == FALSE)
		error("Passed no user to mergeCasing() when output messages is active.")
	if(src.caliber != AC.caliber)
		if(!noMessage)
			to_chat(user, SPAN_WARNING("Ammo are different calibers."))
		return FALSE
	if(src.projectile_type != AC.projectile_type)
		if(!noMessage)
			to_chat(user, SPAN_WARNING("Ammo are different types."))
		return FALSE
	if(src.amount == src.maxamount)
		if(!noMessage)
			to_chat(user, SPAN_WARNING("[src] is fully stacked!"))
		return FALSE
	if((!spent && AC.spent) || (spent && !spent))
		if(!noMessage)
			to_chat(user, SPAN_WARNING("Fired and non-fired ammo wont stack."))
		return FALSE

	var/mergedAmount
	if(!amountToMerge)
		mergedAmount = AC.amount
	else
		mergedAmount = amountToMerge
	if(mergedAmount + src.amount > src.maxamount)
		mergedAmount = src.maxamount - src.amount
	AC.amount -= mergedAmount
	src.amount += mergedAmount
	if(!noIconUpdate)
		src.update_icon()
	if(AC.amount == 0)
		QDEL_NULL(AC)
	else
		if(!noIconUpdate)
			AC.update_icon()
	return TRUE

/obj/item/ammo_casing/on_update_icon()
	if(spent_icon && spent)
		icon_state = spent_icon
	src.cut_overlays()
	if(amount > 1)
		src.pixel_x = 0
		src.pixel_y = 0

	for(var/icon_amount = 1; icon_amount < src.amount, icon_amount++)
		var/image/temp_image = image(src.icon, src.icon_state)
		var/coef = round(14 * icon_amount/src.maxamount)

		temp_image.pixel_x = rand(coef, -coef)
		temp_image.pixel_y = rand(coef, -coef)
		var/matrix/temp_image_matrix = matrix()
		temp_image_matrix.Turn(round(45 * rand(0, sprite_max_rotate) / 2))
		temp_image.transform = temp_image_matrix
		src.add_overlays(temp_image)

/obj/item/ammo_casing/examine(mob/user)
	..()
	to_chat(user, "There [(amount == 1)? "is" : "are"] [amount] round\s left!")
	if (spent)
		to_chat(user, "[(amount == 1)? "This one is" : "These ones are"] spent.")

/obj/item/ammo_casing/proc/duplicate() // call this on a casing to get an identical casing
	var/obj/item/ammo_casing/returned_casing = new()
	returned_casing.name = name
	returned_casing.desc = desc
	returned_casing.caliber = caliber
	returned_casing.projectile_type = projectile_type
	returned_casing.icon_state = icon_state
	returned_casing.spent_icon = spent_icon
	returned_casing.maxamount = maxamount
	returned_casing.spent = spent
	returned_casing.sprite_max_rotate = sprite_max_rotate
	returned_casing.sprite_scale = sprite_scale
	returned_casing.sprite_use_small = sprite_use_small
	returned_casing.sprite_update_spawn = sprite_update_spawn
	if(returned_casing.sprite_update_spawn)
		var/matrix/rotation_matrix = matrix()
		rotation_matrix.Turn(round(45 * rand(0, returned_casing.sprite_max_rotate) / 2))
		if(returned_casing.sprite_use_small)
			returned_casing.transform = rotation_matrix * returned_casing.sprite_scale
		else
			returned_casing.transform = rotation_matrix
	returned_casing.is_caseless = is_caseless
	returned_casing.update_icon()
	return returned_casing

//An item that holds casings and can be used to put them inside guns
/obj/item/ammo_magazine
	name = "magazine"
	desc = "A magazine for some kind of gun."
	icon_state = "place-holder-box"
	icon = 'icons/obj/ammo_mags.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	matter = list(MATERIAL_STEEL = 2)
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 10

	spawn_tags = SPAWN_TAG_AMMO
	rarity_value = 10
	bad_type = /obj/item/ammo_magazine

	var/ammo_color = ""		//For use in modular sprites

	var/list/internal_piles = list() // tracks stored ammo piles
	var/list/bullet_order = list() // tracks the bullet order by referencing the piles list
	var/ammo_amount // tracks how much ammo is actually in the magazine
	var/mag_type = SPEEDLOADER //ammo_magazines can only be used with compatible guns. This is not a bitflag, the load_method var on guns is.
	var/mag_well = MAG_WELL_GENERIC
	var/caliber = CAL_357
	var/ammo_mag = "default"
	var/max_ammo = 7
	var/reload_delay = 0 //when we need to make reload slower

	var/ammo_type = /obj/item/ammo_casing //ammo type that is initially loaded
	var/initial_ammo

	var/multiple_sprites = 0
	//because BYOND doesn't support numbers as keys in associative lists
	var/list/icon_keys = list()		//keys
	var/list/ammo_states = list()	//values

/obj/item/ammo_magazine/New()
	..()
	if(multiple_sprites)
		initialize_magazine_icondata(src)

	if(isnull(initial_ammo))
		initial_ammo = max_ammo

	if(initial_ammo)
		var/remainder = initial_ammo
		while(remainder > 0) //giant magazines make limiting this implausible
			var/obj/item/ammo_casing/current_pile = new ammo_type(src)
			internal_piles += current_pile
			if (remainder >= current_pile.maxamount)
				current_pile.amount = current_pile.maxamount
				ammo_amount += current_pile.maxamount
				remainder -= current_pile.maxamount
			else
				current_pile.amount = remainder
				ammo_amount += remainder
				remainder = 0
		var/pilenum = 0
		for(var/obj/item/ammo_casing/pile in internal_piles)
			pilenum ++
			for(var/i = 0, i < pile.amount, i++)
				bullet_order.Add(pilenum)
	update_icon()

/obj/item/ammo_magazine/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = W
		if(ammo_amount >= max_ammo)
			to_chat(user, SPAN_WARNING("\The [src] is full!"))
			return
		if(C.caliber != caliber)
			to_chat(user, SPAN_WARNING("\The [C] does not fit into \the [src]."))
			return
		insertCasing(C)
	else if(istype(W, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/other = W
		if(!src.ammo_amount)
			to_chat(user, SPAN_WARNING("There is no ammo in \the [src]!"))
			return
		if(other.ammo_amount >= other.max_ammo)
			to_chat(user, SPAN_NOTICE("\The [other] is already full."))
			return
		var/diff = FALSE
		var/moved_ammo = 0 //used to avoid creating casings then deleting them
		while(other.ammo_amount + moved_ammo < other.max_ammo && ammo_amount > moved_ammo)
			if(do_after(user, reload_delay/other.max_ammo, src))
				diff = TRUE
				moved_ammo++
				continue
			break
		other.insertCasing(removeCasing(moved_ammo), moved_ammo)
		if(diff)
			to_chat(user, SPAN_NOTICE("You finish loading \the [other]. It now contains [other.ammo_amount] rounds, and \the [src] now contains [ammo_amount] rounds."))
		else
			to_chat(user, SPAN_WARNING("You fail to load anything into \the [other]"))
	if(istype(W, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/gun_to_load = W
		if(gun_to_load.can_dual && !gun_to_load.ammo_magazine)
			if(!do_after(user, 0.5 SECONDS, src))
				return
			gun_to_load.load_ammo(src, user)
			to_chat(user, SPAN_NOTICE("It takes a bit of time for you to reload your [W] with [src] using only one hand!"))
			visible_message("[user] tactically reloads [W] using only one hand!")	

/obj/item/ammo_magazine/attack_hand(mob/user)
	if(user.get_inactive_hand() == src && ammo_amount)
		var/stackposition = bullet_order[1]
		var/obj/item/ammo_casing/stack = internal_piles[stackposition]
		for(var/bulletindex in bullet_order)
			if(bulletindex == stackposition)
				bullet_order.Remove(bulletindex)
			else if(bulletindex > stackposition)
				bulletindex --
		internal_piles.Remove(stack)
		ammo_amount -= stack.amount
		user.put_in_active_hand(stack)
		return
	..()

/obj/item/ammo_magazine/AltClick(var/mob/living/user)
	var/obj/item/W = user.get_active_hand()
	if(istype(W, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = W
		if(ammo_amount >= max_ammo)
			to_chat(user, SPAN_WARNING("[src] is full!"))
			return
		if(C.caliber != caliber)
			to_chat(user, SPAN_WARNING("[C] does not fit into [src]."))
			return
		if(ammo_amount)
			var/obj/item/ammo_casing/T = removeCasing()
			if(T)
				if(!C.mergeCasing(T, null, user))
					insertCasing(T)
	else if(!W)
		if(user.get_inactive_hand() == src && ammo_amount)
			var/obj/item/ammo_casing/AC = removeCasing()
			if(AC)
				user.put_in_active_hand(AC)

// cycle sends it to the end of bullet_order instead of the start
/obj/item/ammo_magazine/proc/insertCasing(var/obj/item/ammo_casing/C, var/inserted_amount = 1, var/cycle_casings = FALSE)
	if(!istype(C))
		return FALSE
	if(C.caliber != caliber)
		return FALSE
	if(ammo_amount >= max_ammo)
		return FALSE
	if (C.amount < inserted_amount)
		inserted_amount = C.amount
	if (inserted_amount > max_ammo - ammo_amount)
		inserted_amount = max_ammo - ammo_amount
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
/obj/item/ammo_magazine/proc/removeCasing(var/removed_amount = 1, var/pile = TRUE, var/create = TRUE)
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
					var/test = internal_piles[bullet_order[1]]
					var/obj/item/ammo_casing/piletoget = test
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
					if (piletoget.amount <= 0)
						var/pilelistposition = internal_piles.Find(piletoget)
						var/DANGERloop = 1 // used because subtraction did not work here, so I replaced instead. Also as a reference.
						for(var/bulletindex in bullet_order)
							if(bulletindex > pilelistposition)
								bullet_order.Cut(DANGERloop, DANGERloop+1) // bullet_order.Splice: undefined proc
								bullet_order.Insert(DANGERloop, bulletindex - 1) // I guess I'm just cursed.
							DANGERloop ++
						qdel(piletoget)
						internal_piles.Remove(piletoget)
					bullet_order.Cut(1,2)
				return returned_piles
				
			else
				for(var/loop = 0, loop < removed_amount, loop++)
					var/obj/item/ammo_casing/piletoget = internal_piles[bullet_order[1]]
					piletoget.amount --
					if (piletoget.amount <= 0)
						var/pilelistposition = bullet_order[1]
						for(var/bulletindex in bullet_order)
							if(bulletindex > pilelistposition)
								bulletindex --
						internal_piles.Remove(piletoget)
						qdel(piletoget)
					bullet_order.Cut(1,2)
				ammo_amount -= removed_amount

				return removed_amount
		else
			return FALSE

/obj/item/ammo_magazine/resolve_attackby(atom/A, mob/user)
	//Clicking on tile with no collectible items will empty it, if it has the verb to do that.
	if(isturf(A) && !A.density)
		dump_it(A)
		return TRUE
	return ..()

/obj/item/ammo_magazine/verb/quick_empty()
	set name = "Empty Ammo Container"
	set category = "Object"
	set src in view(1)

	if((!ishuman(usr) && (src.loc != usr)) || usr.stat || usr.restrained())
		return

	var/turf/T = get_turf(src)
	if(!istype(T))
		return
	dump_it(T, usr)

/obj/item/ammo_magazine/proc/dump_it(var/turf/target) //bogpilled
	if(!istype(target))
		return
	if(!Adjacent(usr))
		return
	if(!ammo_amount)
		to_chat(usr, SPAN_NOTICE("[src] is already empty!"))
		return
	to_chat(usr, SPAN_NOTICE("You take out ammo from [src]."))
	for(var/obj/item/ammo_casing/pile in internal_piles)
		pile.forceMove(target)
		pile.set_dir(pick(cardinal))
	bullet_order.Cut()
	ammo_amount = 0
	update_icon()

/obj/item/ammo_magazine/on_update_icon()
	if(multiple_sprites)
		//find the lowest key greater than or equal to ammo_amount
		var/new_state = null
		for(var/idx in 1 to icon_keys.len)
			var/ammo_count = icon_keys[idx]
			if (ammo_count >= ammo_amount)
				new_state = ammo_states[idx]
				break
		icon_state = (new_state)? new_state : initial(icon_state)

/obj/item/ammo_magazine/examine(mob/user)
	..()
	to_chat(user, "There [(ammo_amount == 1)? "is" : "are"] [ammo_amount] round\s left!")

//magazine icon state caching
/var/global/list/magazine_icondata_keys = list()
/var/global/list/magazine_icondata_states = list()

/proc/initialize_magazine_icondata(var/obj/item/ammo_magazine/M)
	var/typestr = "[M.type]"
	if(!(typestr in magazine_icondata_keys) || !(typestr in magazine_icondata_states))
		magazine_icondata_cache_add(M)

	M.icon_keys = magazine_icondata_keys[typestr]
	M.ammo_states = magazine_icondata_states[typestr]

/proc/magazine_icondata_cache_add(var/obj/item/ammo_magazine/M)
	var/list/icon_keys = list()
	var/list/ammo_states = list()
	var/list/states = icon_states(M.icon)
	for(var/i = 0, i <= M.max_ammo, i++)
		var/ammo_state = "[M.icon_state]-[i]"
		if(ammo_state in states)
			icon_keys += i
			ammo_states += ammo_state

	magazine_icondata_keys["[M.type]"] = icon_keys
	magazine_icondata_states["[M.type]"] = ammo_states
