/decl/hierarchy/outfit/job/entertainment
	l_ear = /obj/item/device/radio/headset/entertainment
	hierarchy_type = /decl/hierarchy/outfit/job/entertainment

/decl/hierarchy/outfit/job/entertainment/clown
	name = OUTFIT_JOB_NAME("Clown")
	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(/obj/item/bananapeel = 1, /obj/item/storage/fancy/crayons = 1, /obj/item/toy/waterflower = 1, /obj/item/stamp/clown = 1, /obj/item/handcuffs/fake = 1)
	pda_type = /obj/item/modular_computer/pda/clown

/decl/hierarchy/outfit/job/entertainment/clown/New()
	..()
	backpack_overrides[/decl/backpack_outfit/backpack] = /obj/item/storage/backpack/clown
	backpack_overrides[/decl/backpack_outfit/satchel] = /obj/item/storage/backpack/satchel/leather


/decl/hierarchy/outfit/job/entertainment/clown/post_equip(var/mob/living/carbon/human/H)
	..()
	H.mutations.Add(CLUMSY)
