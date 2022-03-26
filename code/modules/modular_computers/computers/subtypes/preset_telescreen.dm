/obj/item/modular_computer/telescreen/preset/install_default_hardware()
	..()
	hardware["processor_unit"] = new/obj/item/computer_hardware/processor_unit(src)
	hardware["tesla_link"] = new/obj/item/computer_hardware/tesla_link(src)
	hardware["hard_drive"] = new/obj/item/computer_hardware/hard_drive(src)
	hardware["network_card"] = new/obj/item/computer_hardware/network_card(src)

/obj/item/modular_computer/telescreen/preset/generic/install_default_programs()
	..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = hardware["hard_drive"]
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor())
	set_autorun("cammon")

/obj/item/modular_computer/telescreen/preset/medical/install_default_programs()
	..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = hardware["hard_drive"]
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor())
	hard_drive.store_file(new/datum/computer_file/program/records())
	hard_drive.store_file(new/datum/computer_file/program/suit_sensors())
	set_autorun("sensormonitor")

/obj/item/modular_computer/telescreen/preset/engineering/install_default_programs()
	..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = hardware["hard_drive"]
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor())
	hard_drive.store_file(new/datum/computer_file/program/shield_control())
	hard_drive.store_file(new/datum/computer_file/program/supermatter_monitor())
	set_autorun("alarmmonitor")
