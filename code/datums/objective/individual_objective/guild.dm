/datum/individual_objective/guild
	bad_type = /datum/individual_objective/guild
	req_department = list(DEPARTMENT_GUILD)

/datum/individual_objective/guild/repossession
	name = "Repossession"
	limited_antag = TRUE
	rarity = 4
	var/obj/item/target

/datum/individual_objective/guild/repossession/can_assign(mob/living/L)
	if(!..())
		return FALSE
	return pick_faction_item(L)

/datum/individual_objective/guild/repossession/assign()
	..()
	target = pick_faction_item(mind_holder)
	desc = "Sell \the [target] item of other faction via cargo."
	RegisterSignal(SSsupply.shuttle, COMSIG_SHUTTLE_SUPPLY, .proc/task_completed)

/datum/individual_objective/guild/repossession/task_completed(atom/movable/AM)
	if(target.type == AM.type)
		..(1)

/datum/individual_objective/guild/repossession/completed()
	if(completed) return
	UnregisterSignal(SSsupply.shuttle, COMSIG_SHUTTLE_SUPPLY)
	..()

/datum/individual_objective/guild/museum
	name = "It Belongs in a Museum"
	desc = "Ensure that 3-4 oddities were sold via cargo."

/datum/individual_objective/guild/museum/assign()
	..()
	units_requested = rand(3,4)
	desc = "Ensure that [units_requested] oddities are sold via cargo."
	RegisterSignal(SSsupply.shuttle, COMSIG_SHUTTLE_SUPPLY, .proc/task_completed)

/datum/individual_objective/guild/museum/task_completed(atom/movable/AM)
	if(AM.GetComponent(/datum/component/inspiration))
		..(1)

/datum/individual_objective/guild/museum/completed()
	if(completed) return
	UnregisterSignal(SSsupply.shuttle, COMSIG_SHUTTLE_SUPPLY)
	..()

/datum/individual_objective/guild/order
	name = "Special Order"
	var/obj/item/target

/datum/individual_objective/guild/order/proc/pick_candidates()
	return pickweight(list(
	/obj/item/tool_upgrade/reinforcement/guard = 1,
	/obj/item/tool_upgrade/productivity/ergonomic_grip = 1,
	/obj/item/tool_upgrade/productivity/red_paint = 1,
	/obj/item/tool_upgrade/productivity/diamond_blade = 1,
	/obj/item/tool_upgrade/productivity/motor = 1,
	/obj/item/tool_upgrade/refinement/laserguide = 1,
	/obj/item/tool_upgrade/refinement/stabilized_grip = 1,
	/obj/item/tool_upgrade/augment/expansion = 1,
	/obj/item/tool_upgrade/augment/dampener = 0.5,
	/obj/item/tool/screwdriver/combi_driver = 3,
	/obj/item/tool/wirecutters/armature = 3,
	/obj/item/tool/omnitool = 2,
	/obj/item/tool/crowbar/pneumatic = 3,
	/obj/item/tool/wrench/big_wrench = 3,
	/obj/item/tool/weldingtool/advanced = 3,
	/obj/item/tool/saw/circular/advanced = 2,
	/obj/item/tool/saw/chain = 1,
	/obj/item/tool/saw/hyper = 1,
	/obj/item/tool/pickaxe/diamonddrill = 2,
	/obj/item/gun_upgrade/mechanism/glass_widow = 1,
	/obj/item/gun_upgrade/barrel/excruciator = 1,
	/obj/item/device/destTagger = 1,
	/obj/item/device/makeshift_electrolyser = 1,
	/obj/item/device/makeshift_centrifuge = 1
	))

/datum/individual_objective/guild/order/assign()
	..()
	target = pick_candidates()
	target = new target()
	desc = "A friend of yours on the other side on trade teleporter is waiting for a [target]. Ensure it will be sold via cargo."
	RegisterSignal(SSsupply.shuttle, COMSIG_SHUTTLE_SUPPLY, .proc/task_completed)

/datum/individual_objective/guild/order/task_completed(atom/movable/AM)
	if(AM.type == target.type)
		completed()

/datum/individual_objective/guild/order/completed()
	if(completed) return
	UnregisterSignal(SSsupply.shuttle, COMSIG_SHUTTLE_SUPPLY)
	..()

/datum/individual_objective/guild/stripping
	name = "Stripping Operation"
	limited_antag = TRUE
	rarity = 4
	var/price_target = 2000
	var/area/target

/datum/individual_objective/guild/stripping/assign()
	..()
	var/list/valied_areas = list()
	for(var/area/A in ship_areas)
		var/current_price = 0
		if(A in valied_areas)
			continue
		if (istype(A, /area/shuttle))
			continue
		if (A.is_maintenance)
			continue
		for(var/obj/item/I in A.contents)
			current_price += I.get_item_cost()
		if(current_price < price_target)
			continue
		valied_areas += A
	target = pick(valied_areas)
	desc = "Ensure that [target] does not have a cumulative price of items inside it that is higher than [price_target][CREDITS]."
	RegisterSignal(mind_holder, COMSIG_MOB_LIFE, .proc/task_completed)

/datum/individual_objective/guild/stripping/task_completed()
	if(mind_holder.stat == DEAD)
		return
	units_completed = 0
	for(var/obj/item/I in target.contents)
		units_completed += I.get_item_cost()
	if(units_completed < price_target)
		completed()

/datum/individual_objective/guild/stripping/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_MOB_LIFE)
	..()

/datum/individual_objective/guild/transfer
	name = "Family Business"
	var/datum/money_account/target

/datum/individual_objective/guild/transfer/can_assign(mob/living/L)
	if(!..())
		return FALSE
	if(!L.mind.initial_account)
		return FALSE
	var/list/valids_targets = list()
	for(var/mob/living/carbon/human/H in ((GLOB.player_list & GLOB.living_mob_list & GLOB.human_mob_list) - L))
		if(H.mind && H.mind.initial_account)
			valids_targets += H.mind.initial_account
	valids_targets -= L.mind.initial_account
	return valids_targets.len

/datum/individual_objective/guild/transfer/assign()
	..()
	var/list/valids_targets = list()
	for(var/mob/living/T in GLOB.human_mob_list)
		if(T.mind && T.mind.initial_account)
			valids_targets += T.mind.initial_account
	valids_targets -= owner.initial_account
	target = pick(valids_targets)
	units_requested = rand(2000, 5000)
	desc = "Some of your relative asked you to procure and provide this account number: \"[target.account_number]\" with sum of [units_requested][CREDITS]. \
			You dont know exactly why, but this is important."
	RegisterSignal(owner.initial_account, COMSIG_TRANSACTION, .proc/task_completed)

/datum/individual_objective/guild/transfer/task_completed(datum/money_account/S, datum/money_account/T, amount)
	if(S == owner.initial_account && T == target)
		..(amount)

/datum/individual_objective/guild/transfer/completed()
	if(completed) return
	UnregisterSignal(owner.initial_account, COMSIG_TRANSACTION)
	..()
