/obj/item/modular_computer/pda
	name = "PDA"
	desc = "A very compact computer, designed to keep its user always connected."
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda"
	matter = list(MATERIAL_STEEL = 3, MATERIAL_GLASS = 1)
	hardware_flag = PROGRAM_PDA
	max_hardware_size = 1
	hardware_capacity = 13
	w_class = ITEM_SIZE_SMALL
	screen_light_strength = 1.1
	screen_light_range = 2
	slot_flags = SLOT_ID | SLOT_BELT
	var/obj/item/pen/stored_pen = /obj/item/pen
	price_tag = 50
	suitable_cell = /obj/item/cell/small //We take small battery

	var/scanner_type = null
	var/tesla_link_type = null
	var/hard_drive_type = /obj/item/computer_hardware/hard_drive/small
	var/processor_unit_type = /obj/item/computer_hardware/processor_unit/small
	var/network_card_type = /obj/item/computer_hardware/network_card

/obj/item/modular_computer/pda/Initialize()
	. = ..()
	enable_computer()

/obj/item/modular_computer/pda/AltClick(var/mob/user)
	if(!CanPhysicallyInteract(user))
		return
	var/obj/item/computer_hardware/card_slot/card_slot = hardware["card_slot"]
	if(card_slot && istype(card_slot.stored_card))
		eject_id()
	else
		..()

/obj/item/modular_computer/pda/attackby(obj/item/W, mob/user, sound_mute = FALSE)
	if(istype(W, /obj/item/pen))
		var/obj/item/modular_computer/pda/penholder = src
		if(istype(penholder.stored_pen))
			to_chat(user, "<span class='notice'>There is already a pen in [src].</span>")
			return
		if(!insert_item(W, user))
			return
		penholder.stored_pen = W
		update_verbs()
		return
	else
		..()
