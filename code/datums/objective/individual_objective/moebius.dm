/datum/individual_objective/moebius
	bad_type = /datum/individual_objective/moebius
	req_department = list(DEPARTMENT_SCIENCE, DEPARTMENT_MEDICAL)

/datum/individual_objective/moebius/big_brain
	name = "The Biggest Brain"
	var/target_stat = STAT_COG
	var/target_val
	var/delta = 10

/datum/individual_objective/moebius/big_brain/assign()
	..()
	target_val = mind_holder.stats.getStat(STAT_COG) + delta
	desc = "Ensure that your COG stat will be increased to [target_val]."
	RegisterSignal(mind_holder, COMSIG_STAT, .proc/task_completed)

/datum/individual_objective/moebius/big_brain/task_completed(stat_name, stat_value, stat_value_pure)
	if(target_stat == stat_name && (stat_value >= target_val))
		completed()

/datum/individual_objective/moebius/big_brain/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_STAT)
	..()

/datum/individual_objective/moebius/get_nsa
	name = "Blow the Lid"
	units_requested = 250
	units_completed = 0

/datum/individual_objective/moebius/get_nsa/assign()
	..()
	desc = "Reach [units_requested] of NSA. Survive."
	RegisterSignal(mind_holder, COMSING_NSA, .proc/task_completed)

/datum/individual_objective/moebius/get_nsa/task_completed(n_nsa)
	units_completed = n_nsa ? n_nsa : 0
	if(check_for_completion())
		completed()

/datum/individual_objective/moebius/get_nsa/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSING_NSA)
	..()

/datum/individual_objective/moebius/derail
	name = "Observe a Derail"
	limited_antag = TRUE
	rarity = 4

/datum/individual_objective/moebius/derail/assign()
	..()
	units_requested = rand(3,4)
	desc = "Observe a sum of [units_requested] mental breakdowns of you, orother non people."
	RegisterSignal(mind_holder, COMSIG_HUMAN_BREAKDOWN, .proc/task_completed)

/datum/individual_objective/moebius/derail/task_completed(mob/living/L, datum/breakdown/breakdown)
	..(1)

/datum/individual_objective/moebius/derail/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_HUMAN_BREAKDOWN)
	..()

/datum/individual_objective/moebius/addiction
	name = "On The Hook"
	limited_antag = TRUE
	rarity = 4

/datum/individual_objective/moebius/addiction/assign()
	..()
	units_requested = rand(3,4)
	desc = "Observe a sum of [units_requested] occasions on where people will get addicted to any chems."
	RegisterSignal(mind_holder, COMSIG_CARBON_ADICTION, .proc/task_completed)

/datum/individual_objective/moebius/addiction/task_completed(mob/living/carbon/C, datum/reagent/reagent)
	if(C != mind_holder)
		..(1)

/datum/individual_objective/moebius/addiction/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_CARBON_ADICTION)
	..()

/datum/individual_objective/moebius/autopsy
	name = "Death is the Answer"
	var/list/cadavers = list()

/datum/individual_objective/moebius/autopsy/assign()
	..()
	units_requested = rand(2,3)
	desc = "Perform [units_requested] autopsies."
	RegisterSignal(mind_holder, COMSING_AUTOPSY, .proc/task_completed)

/datum/individual_objective/moebius/autopsy/task_completed(mob/living/carbon/human/H)
	if(H in cadavers)
		return
	cadavers += H
	..(1)

/datum/individual_objective/moebius/autopsy/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSING_AUTOPSY)
	..()

/datum/individual_objective/moebius/more_research
	name = "Mandate of Science"
	limited_antag = TRUE
	rarity = 4
	var/obj/item/target

/datum/individual_objective/moebius/more_research/can_assign(mob/living/L)
	if(!..())
		return FALSE
	return pick_faction_item(L)

/datum/individual_objective/moebius/more_research/assign()
	..()
	target = pick_faction_item(mind_holder)
	desc = "\The [target] is wasted in their hands. Put it into a destructive analyzer."
	RegisterSignal(mind_holder, COMSIG_DESTRUCTIVE_ANALYZER, .proc/task_completed)

/datum/individual_objective/moebius/more_research/task_completed(obj/item/I)
	if(target.type == I.type)
		..(1)

/datum/individual_objective/moebius/more_research/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_DESTRUCTIVE_ANALYZER)
	..()

/datum/individual_objective/moebius/damage
	name = "A Different Perspective"
	var/last_health

/datum/individual_objective/moebius/damage/assign()
	..()
	units_requested = rand(120,160)
	desc = "Receive cumulative [units_requested] damage of any kind, to ensure that you see things in a different light."
	last_health = mind_holder.health
	RegisterSignal(mind_holder, COMSIG_HUMAN_HEALTH, .proc/task_completed)

/datum/individual_objective/moebius/damage/task_completed(health)
	if(last_health > health)
		units_completed += last_health - health
	last_health = health
	if(check_for_completion())
		completed()

/datum/individual_objective/moebius/damage/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_HUMAN_HEALTH)
	..()

/datum/individual_objective/moebius/for_science
	name = "Call of Science"
	limited_antag = TRUE
	rarity = 4
	var/mob/living/carbon/human/target
	var/list/valid_organs = list()

/datum/individual_objective/moebius/for_science/can_assign(mob/living/L)
	if(!..())
		return FALSE
	var/list/candidates = (GLOB.player_list & GLOB.living_mob_list & GLOB.human_mob_list) - L
	return candidates.len

/datum/individual_objective/moebius/for_science/assign()
	..()
	var/list/valid_targets = (GLOB.player_list & GLOB.living_mob_list & GLOB.human_mob_list) - mind_holder
	target = pick(valid_targets)
	for(var/obj/item/organ/external/E in target.organs)
		valid_organs += E
	for(var/obj/item/organ/O in target.internal_organs)
		valid_organs += O
	desc = "[target] looks interesting. Put any of their organ in destructive analyzer."
	RegisterSignal(mind_holder, COMSIG_DESTRUCTIVE_ANALYZER, .proc/task_completed)

/datum/individual_objective/moebius/for_science/task_completed(obj/item/I)
	if(I in valid_organs)
		..(1)

/datum/individual_objective/moebius/for_science/completed()
	if(completed) return
	UnregisterSignal(mind_holder, COMSIG_DESTRUCTIVE_ANALYZER)
	..()
