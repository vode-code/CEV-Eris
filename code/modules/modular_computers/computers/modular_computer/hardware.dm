// Attempts to install the hardware into apropriate slot.
/obj/item/modular_computer/proc/try_install_component(obj/item/H, mob/living/user)
	var/found = FALSE
	var/obj/item/computer_hardware/CH //if it's anything other than a battery, then we need to set its holder2 var whatever the fuck that is
	if(istype(H, /obj/item/computer_hardware))
		CH = H
		if(!(CH.usage_flags & hardware_flag))
			to_chat(user, SPAN_WARNING("This computer isn't compatible with [CH]."))
			return

	var/capacity_filled = 0
	for(var/obj/item/fillingitem in hardware)
		capacity_filled += fillingitem.w_class
	if(H.w_class > max_hardware_size)
		to_chat(user, SPAN_WARNING("This [CH ? "component" : "item"] is too large for \the [src]."))
		return
	if(capacity_filled+H.w_class > hardware_capacity)
		to_chat(user, SPAN_WARNING("This item is too large to fit in the remaining space in \the [src]."))
		return

	var/list/indexlist = list("portable_drive","led","hard_drive","network_card","printer","card_slot","cell","processor_unit","ai_slot","tesla_link","scanner","gps_sensor")
	var/typelist = list("portable_drive" = /obj/item/computer_hardware/hard_drive/portable,"led" = /obj/item/computer_hardware/led,\
	"hard_drive" = /obj/item/computer_hardware/hard_drive,"network_card" = /obj/item/computer_hardware/network_card,\
	"printer" = /obj/item/computer_hardware/printer,"card_slot" = /obj/item/computer_hardware/card_slot,\
	"cell" = /obj/item/cell,"processor_unit" = /obj/item/computer_hardware/processor_unit,"ai_slot" = /obj/item/computer_hardware/ai_slot,\
	"tesla_link" = /obj/item/computer_hardware/tesla_link,"scanner" = /obj/item/computer_hardware/scanner,"gps_sensor" = /obj/item/computer_hardware/gps_sensor)
	var/namelist = list("portable_drive" = "portable drive","led" = "LED","hard_drive" = "hard drive","network_card" = "network card",\
	"printer" = "printer","card_slot" = "card","cell" = "battery","processor_unit" = "processor",\
	"ai_slot" = "intellicard","tesla_link" = "tesla link","scanner" = "scanner","gps_sensor" = "gps")

	for(var/index in indexlist)
		if(istype(H, typelist[index]))
			if(hardware[index])
				to_chat(user, SPAN_WARNING("This computer's [namelist[index]] slot is already occupied by \the [hardware[index]]."))
				return
			found = TRUE
			hardware[index] = H
			to_chat(user, SPAN_NOTICE("You slot [H] into \the [src]'s [namelist[index]] slot."))
	if(!found)
		hardware.Add(H)
		user.visible_message("[user] places [H] into \the [src]\'s casing.",SPAN_NOTICE("You place [H] into \the [src]\'s casing."), null)

	if(insert_item(H, user))
		if(CH)
			CH.holder2 = src
			if(CH.enabled)
				CH.enabled()
			if(istype(CH, /obj/item/computer_hardware/hard_drive) && enabled)
				autorun_program(hardware["portable_drive"]) // Autorun malware: now in SS13!
		update_verbs()

// Uninstalls component.
/obj/item/modular_computer/proc/uninstall_component(obj/item/H, mob/living/user)
	var/foundit = FALSE
	if(!(hardware.Find(H)))
		for(var/totest in hardware)
			if(isobj(totest))
				continue
			else if(hardware[totest] == H)
				foundit = totest
				break
		if(!foundit)
			return
	else
		foundit = H
	var/critical = FALSE
	var/obj/item/computer_hardware/to_remove //If it is not computer hardware don't try to delete the snowflake vars

	if(istype(H, /obj/item/computer_hardware))
		to_remove = H
		critical = to_remove.critical && to_remove.enabled

		if(to_remove.enabled)
			to_remove.disabled()

		to_remove.holder2 = null


	if(istype(H, /obj/item/computer_hardware/scanner))
		var/obj/item/computer_hardware/scanner/scanner = H
		scanner.do_before_uninstall()
	hardware.Remove(foundit)


	to_chat(user, SPAN_NOTICE("You remove \the [H] from \the [src]."))
	H.forceMove(drop_location())

	if(critical)
		to_chat(user, SPAN_DANGER("\The [src]'s screen freezes for a split second and then flickers to black."))
		shutdown_computer()
	update_verbs()
	update_icon()


// Returns list of all components
/obj/item/modular_computer/proc/get_all_components()
	var/list/all_components = list()
	for(var/obj/item/computer_hardware/slot in hardware)
		if(istype(slot) || istype(slot, /obj/item/cell))
			all_components += slot

	return all_components

// Checks all hardware pieces to determine if name matches, if yes, returns the hardware piece, otherwise returns null
/obj/item/modular_computer/proc/find_hardware_by_name(name)
	for(var/c in hardware)
		if(!isobj(c))
			c = hardware[c] // from index to value, only some of hardware has custom indexes and that needs to be accounted for
		var/obj/item/component = c
		if(component.name == name)
			return component
	return null
