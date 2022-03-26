// This is the base type that handles everything. Subtypes can be easily created by tweaking variables in this file to your liking.

/obj/item/modular_computer
	name = "Modular Computer"
	desc = "A modular computer. You shouldn't see this."
	spawn_blacklisted = TRUE
	bad_type = /obj/item/modular_computer
	var/enabled = 0											// Whether the computer is turned on.
	var/screen_on = 1										// Whether the computer is active/opened/it's screen is on.
	var/datum/computer_file/program/active_program			// A currently active program running on the computer.
	var/hardware_flag = 0									// A flag that describes this device type
	var/last_power_usage = 0								// Last tick power usage of this computer
	var/last_battery_percent = 0							// Used for deciding if battery percentage has chandged
	var/last_world_time = "00:00"
	var/list/last_header_icons
	var/computer_emagged = FALSE							// Whether the computer is emagged.
	var/apc_powered = FALSE									// Set automatically. Whether the computer used APC power last tick.
	var/base_active_power_usage = 50						// Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_idle_power_usage = 5							// Power usage when the computer is idle and screen is off (currently only applies to laptops)
	var/bsod = FALSE										// Error screen displayed
	var/ambience_last_played								// Last time sound was played

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	icon = null												// This thing isn't meant to be used on it's own. Subtypes should supply their own icon.
	icon_state = null
	center_of_mass = null									// No pixelshifting by placing on tables, etc.
	randpixel = 0											// And no random pixelshifting on-creation either.
	var/icon_state_menu = "menu"							// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/icon_state_screensaver = "standby"
	var/max_hardware_size = 0								// Maximal hardware size. Currently, tablets have 1, laptops 2 and consoles 3. Limits what hardware types can be installed.
	var/hardware_capacity = 0								// maximum combined sizes of contained hardware parts, tablets 13, laptops 26, and consoles 39
	var/steel_sheet_cost = 5								// Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/screen_light_strength = 0							// Intensity of light this computer emits. Comparable to numbers light fixtures use.
	var/screen_light_range = 2								// Intensity of light this computer emits. Comparable to numbers light fixtures use.
	var/list/all_threads = list()							// All running programs, including the ones running in background

	// Damage of the chassis. If the chassis takes too much damage it will break apart.
	var/damage = 0				// Current damage level
	var/broken_damage = 50		// Damage level at which the computer ceases to operate
	var/max_damage = 100		// Damage level at which the computer breaks apart.
	var/list/terminals          // List of open terminal datums.


	var/list/hardware = list() // this list contains the hardware and smuggled items in the computer
	var/suitable_cell = /obj/item/cell/medium
	var/casing_open = FALSE // whether the computer interior is accessible

	var/modifiable = TRUE	// can't be modified or damaged if false

