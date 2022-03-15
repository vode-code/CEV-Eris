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
