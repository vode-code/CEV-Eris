/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department = DEPARTMENT_ENTERTAINMENT
	department_flag = ENTERTAINMENT
	faction = "CEV Eris"
	total_positions = 3
	spawn_positions = 3
	supervisors = "your sense of humor"
	selection_color = "#FF007F" // bright pink
	also_known_languages = list(LANGUAGE_JIVE = 100) // mimes and clowns understand each other
	access = list(access_maint_tunnels, access_theatre, access_clown_shuttle)
	outfit_type = /decl/hierarchy/outfit/job/entertainment/clown
	wage = WAGE_LABOUR_DUMB // clowns are resourceful and don't need tons of money for pranks
	stat_modifiers = list(STAT_TGH = 30)
	perks = list(PERK_CLOWN)

	description = "You are the comic relief of CEV Eris. Sent by the Circus, you must do your best to ensure the crew's mental health is at its peak... or at least slightly off the rock bottom.<br>\
	You can improve your clowning toolset by showcasing dedication to comedy. Each time you level up, you will come up with a specific prank to pull off, which rewards your department with points that can be spent on advanced clowning tools via the console in your shuttle."

	duties = "Entertain the crew by performing and keeping their sanity in check.<br>\
	Prank and advance your clowning ability.<br>\
	Remember to keep it in good spirits - an asshole clown is a dead clown."

	loyalties = "You are loyal to your sense of humour. Use it to the best of your ability to ensure that everyone - not just you - is having a good time.<br>\
	Your second loyalty is to the Circus. Should your clowning be too much to bear for the crew, and the Mimes are dispatched, it's your solemn duty to make the best possible show out of the ensuing chase."

/obj/landmark/join/start/clown
	name = "Clown"
	icon_state = "player-black"
	join_tag = /datum/job/clown

