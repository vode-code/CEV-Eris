// this is not for departmental score, see code/game/gamemodes/scores.dm for scores.
GLOBAL_LIST_EMPTY(point_holders)

/datum/controller/subsystem/department_points/proc/SetupPoint_Holders()
	for(var/P in subtypesof(/datum/departmental_point_holder))
		new P(NULLSPACE) // they gotta get made somehow and the map is not gonna do it for datums.

/datum/departmental_point_holder
	var/associated_department //which department uses this
	var/points = 0


// this is how signals that increase points are registered for departmental point holder contributing players
/datum/departmental_point_holder/proc/register_rewarding_tasks(mob/to_register_on)
	//nothin'
// this unregisters in case the player switches departments in an official enough way that code can tell
/datum/departmental_point_holder/proc/UNregister_rewarding_tasks(mob/to_UNregister_on)
	//nada
/datum/departmental_point_holder/proc/increment_points(number_to_award = 1)
	points += number_to_award

/datum/departmental_point_holder/entertainment
	associated_department = DEPARTMENT_ENTERTAINMENT

/datum/departmental_point_holder/entertainment/register_rewarding_tasks(mob/to_register_on)
	RegisterSignal(to_register_on, COMSIG_MISCHIEF,  new/datum/callback(src, .proc/increment_points, 3))
	// if it is a callback from the start(it transforms proc references into callbacks) RegisterSignal can send arguments.
	RegisterSignal(to_register_on, COMSIG_PERFORMANCE, .proc/increment_points)

/datum/departmental_point_holder/UNregister_rewarding_tasks(mob/to_UNregister_from)
	UnregisterSignal(to_UNregister_from, COMSIG_MISCHIEF)
	UnregisterSignal(to_UNregister_from, COMSIG_PERFORMANCE)

