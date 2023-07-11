/obj/item/grenade/smokebomb
	name = "FS SG \"Reynolds\""
	desc = "Smoke grenade, used to create a cloud of smoke providing cover and hiding movement."
	icon_state = "smokegrenade"
	item_state = "smokegrenade"
	det_time = 20
	matter = list(MATERIAL_STEEL = 3, MATERIAL_SILVER = 1)
	var/datum/effect/effect/system/smoke_spread/bad/smoke

/obj/item/grenade/smokebomb/New()
	..()
	smoke = new
	smoke.attach(src)

/obj/item/grenade/smokebomb/Destroy()
	qdel(smoke)
	smoke = null
	return ..()

/obj/item/grenade/smokebomb/prime()
	playsound(loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.set_up(10, 0, usr.loc)
	spawn(0)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()

	sleep(80)
	icon_state = initial(icon_state) + "_off"
	desc = "[initial(desc)] It has already been used."
	return

/obj/item/grenade/smokebomb/nt
	name = "NT SG \"Holy Fog\""
	desc = "Smoke grenade, used to create a cloud of smoke providing cover and hiding movement."
	icon_state = "smokegrenade_nt"
	item_state = "smokegrenade_nt"
	matter = list(MATERIAL_BIOMATTER = 10)
