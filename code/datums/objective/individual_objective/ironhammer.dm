/datum/individual_objective/ironhammer
	bad_type = /datum/individual_objective/ironhammer
	req_department = list(DEPARTMENT_SECURITY)

/datum/individual_objective/ironhammer/familiar_face
	name = "A Familiar Face"
	var/mob/living/carbon/human/target

/datum/individual_objective/ironhammer/familiar_face/can_assign(mob/living/L)
	if(!..())
		return FALSE
	var/list/candidates = (GLOB.player_list & GLOB.living_mob_list & GLOB.human_mob_list) - L
	return candidates.len

/datum/individual_objective/ironhammer/familiar_face/assign()
	..()
	var/list/candidates = (GLOB.player_list & GLOB.living_mob_list & GLOB.human_mob_list) - mind_holder
	target = pick(candidates)
	desc = "You swear you saw [target] somewhere before, and in your line of job it cannot mean good. Search them, \
	remove their backpack or empty their pockets."
	RegisterSignal(mind_holder, COMSIG_EMPTY_POCKETS, .proc/task_completed)

/datum/individual_objective/ironhammer/familiar_face/task_completed(n_target)
	if(n_target == target)
		completed()

/datum/individual_objective/ironhammer/familiar_face/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_EMPTY_POCKETS)
	..()

/datum/individual_objective/ironhammer/time_to_action
	name = "Time for Action"
	units_requested = 20

/datum/individual_objective/ironhammer/time_to_action/assign()
	..()
	desc = "Murder or observe murdering of 20 mobs."
	RegisterSignal(mind_holder, COMSIG_MOB_DEATH, .proc/task_completed)

/datum/individual_objective/ironhammer/time_to_action/task_completed(mob/mob_death)
	..(1)

/datum/individual_objective/ironhammer/time_to_action/completed()
	if(completed) return
	UnregisterSignal(owner, COMSIG_MOB_DEATH)
	..()

/datum/individual_objective/ironhammer/paranoia
	name = "Paranoia"
	var/list/vitims = list()

/datum/individual_objective/ironhammer/paranoia/assign()
	..()
	units_requested = rand(3,4)
	desc = "The criminals are here, somewhere, you can feel that. Search [units_requested] people, \
			remove their backpack or empty their pockets."
	RegisterSignal(mind_holder, COMSIG_EMPTY_POCKETS, .proc/task_completed)

/datum/individual_objective/ironhammer/paranoia/task_completed(mob/living/carbon/n_target)
	if((n_target in vitims) || !n_target.client)
		return
	vitims += n_target
	..(1)

/datum/individual_objective/ironhammer/paranoia/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_EMPTY_POCKETS)
	..()

/datum/individual_objective/ironhammer/danger
	name = "Absolute Danger"
	limited_antag = TRUE
	rarity = 4
	var/obj/item/target

/datum/individual_objective/ironhammer/danger/can_assign(mob/living/L)
	if(!..())
		return FALSE
	return pick_faction_item(L, strict_type = /obj)

/datum/individual_objective/ironhammer/danger/assign()
	..()
	target = pick_faction_item(mind_holder, strict_type = /obj)
	desc = "\The [target] is a clear danger to ship and crew. Destroy it using any means possible."
	RegisterSignal(mind_holder, COMSIG_OBJ_FACTION_ITEM_DESTROY, .proc/task_completed)

/datum/individual_objective/ironhammer/danger/task_completed(obj/item/I)
	if(target.type == I.type)
		..(1)

/datum/individual_objective/ironhammer/danger/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_OBJ_FACTION_ITEM_DESTROY)
	..()

/datum/individual_objective/ironhammer/guard
	name = "Guard"
	var/area/target_area

/datum/individual_objective/ironhammer/guard/assign()
	..()
	target_area = random_ship_area()
	desc = "[target_area] requires to be fortified with a turret."
	RegisterSignal(target_area, COMSIG_TURRET, .proc/task_completed)

/datum/individual_objective/ironhammer/guard/task_completed()
		completed()

/datum/individual_objective/ironhammer/guard/completed()
	if(completed) return
	UnregisterSignal(target_area, COMSIG_TURRET)
	..()
