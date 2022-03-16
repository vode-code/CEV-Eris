/datum/individual_objective/entertainment
	bad_type = /datum/individual_objective/entertainment
	req_department = list(DEPARTMENT_ENTERTAINMENT)

/datum/individual_objective/entertainment/assign()
	..()
	var/datum/departmental_point_holder/entertainment_pointer = GLOB?.point_holders[DEPARTMENT_ENTERTAINMENT]
	if(!mind_holder.comp_lookup.Find(COMSIG_MISCHIEF))
		entertainment_pointer.register_rewarding_tasks(mind_holder)

/datum/individual_objective/entertainment/completed()
	if(completed)
		return
	SEND_SIGNAL(mind_holder, COMSIG_MISCHIEF)
	..()

/datum/individual_objective/entertainment/slip_n_slide
	name = "Slip N Slide"
	var/mob/living/carbon/human/target

/datum/individual_objective/entertainment/slip_n_slide/can_assign(mob/living/L)
	if(!..())
		return FALSE
	var/list/candidates = (GLOB.player_list & GLOB.living_mob_list & GLOB.human_mob_list) - L
	return candidates.len

/datum/individual_objective/entertainment/slip_n_slide/assign()
	..()
	units_requested = rand(6, 8)
	var/list/candidates = (GLOB.player_list & GLOB.living_mob_list & GLOB.human_mob_list) - mind_holder
	target = pick(candidates)
	desc = "Slip [target] [units_requested] times."
	RegisterSignal(mind_holder, COMSIG_SLIPPED, .proc/task_completed)

/datum/individual_objective/entertainment/slip_n_slide/task_completed(n_target)
	if(n_target == target)
		completed()

/datum/individual_objective/entertainment/slip_n_slide/completed()
	if(completed)
		return
	UnregisterSignal(mind_holder, COMSIG_SLIPPED)
	..()

/datum/individual_objective/entertainment/monkeys
	name = "Monkey Business"
	units_requested =  5
	var/area/target

/datum/individual_objective/entertainment/monkeys/assign() // copied from Guild Stripping Operation
	..()
	units_requested = rand(5,7)
	var/list/monkeyed_areas = list()
	for(var/area/A in ship_areas)
		var/current_monkey_quantity = 0
		if(A in monkeyed_areas)
			continue
		if (istype(A, /area/shuttle))
			continue
		if (A.is_maintenance)
			continue
		for(var/mob/living/carbon/human/monkey/M in A.contents)
			current_monkey_quantity += 1
		if(current_monkey_quantity >= units_requested)
			continue
		monkeyed_areas += A
	target = pick(monkeyed_areas)
	desc = "Ensure that [target] has at least [units_requested] monkeys in it."
	RegisterSignal(mind_holder, COMSIG_MOB_LIFE, .proc/task_completed)

/datum/individual_objective/entertainment/monkeys/task_completed()
	if(mind_holder.stat == DEAD)
		return
	units_completed = 0
	for(var/mob/living/carbon/human/monkey/M in target.contents)
		units_completed += 1
	if(units_completed >= units_requested)
		completed()

/datum/individual_objective/entertainment/monkeys/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_MOB_LIFE)
	..()


