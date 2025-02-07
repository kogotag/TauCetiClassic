#define SEARCH_FOR_DISK 0
#define SEARCH_FOR_OBJECT 1

/obj/item/weapon/pinpointer
	name = "pinpointer"
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/active = FALSE
	var/atom/target = null
	var/mode = SEARCH_FOR_DISK  // Need here for GREAT OOP style, 0 - searching disk

/obj/item/weapon/pinpointer/attack_self(mob/user)
	if(!active)
		START_PROCESSING(SSobj, src)
		to_chat(user, "<span class='notice'>You activate the pinpointer</span>")
	else
		icon_state = "pinoff"
		to_chat(user, "<span class='notice'>You deactivate the pinpointer</span>")
	active = !active

/obj/item/weapon/pinpointer/process()
	if(!active)
		return
	if(!target && !mode)
		target = locate(/obj/item/weapon/disk/nuclear)
		if(!target)
			icon_state = "pinonnull"
			return
	if(target)
		set_dir(get_dir(src, target))
		var/turf/self_turf = get_turf(src)
		var/turf/target_turf = get_turf(target)
		if(target_turf.z != self_turf.z)
			icon_state = "pinonalert"
		else if(target_turf == self_turf)
			icon_state = "pinondirect"
		else
			switch(get_dist(target_turf, self_turf))
				if(1 to 8)
					icon_state = "pinonclose"
				if(9 to 16)
					icon_state = "pinonmedium"
				if(16 to INFINITY)
					icon_state = "pinonfar"

/obj/item/weapon/pinpointer/examine(mob/user)
	..()
	for(var/obj/machinery/nuclearbomb/bomb in poi_list)
		if(bomb.timing)
			to_chat(user, "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]")

/obj/item/weapon/pinpointer/proc/reset_target()
	SIGNAL_HANDLER
	if(mode && target)
		UnregisterSignal(target, list(COMSIG_PARENT_QDELETING))

	active = FALSE
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"
	target = null

/obj/item/weapon/pinpointer/Destroy()
	reset_target()
	return ..()

/obj/item/weapon/pinpointer/advpinpointer
	name = "Advanced Pinpointer"
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."

/obj/item/weapon/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	reset_target()

	switch(tgui_alert(usr, "Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", list("Location", "Disk Recovery", "Other Signature")))

		if("Disk Recovery")
			mode = SEARCH_FOR_DISK
		if("Location")
			mode = SEARCH_FOR_OBJECT
			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !(usr in view(1, src)))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !(usr in view(1, src)))
				return
			var/turf/Z = get_turf(src)
			var/area/A = locate(locationx, locationy, Z.z)
			if(A)
				target = A
				to_chat(usr, "You set the pinpointer to locate [locationx],[locationy]")
			else
				to_chat(usr, "No area located at [locationx],[locationy]")

		if("Other Signature")
			mode = SEARCH_FOR_OBJECT
			switch(tgui_alert(usr, "Search for item signature or DNA fragment?" , "Signature Mode Select" , list("Item" , "DNA", "AI System")))
				if("Item")
					var/datum/objective/steal/itemlist
					itemlist = itemlist // To supress a 'variable defined but not used' error.
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in itemlist.possible_items
					if(!targetitem)
						return
					var/turf/Z = get_turf(src)
					var/obj/item/item_path = itemlist.possible_items[targetitem]
					for(var/obj/item/I in global.possible_items_for_steal)
						if(I.z != Z.z)
							continue
						if(!istype(I, item_path))
							continue
						target = I
						break
					if(!target)
						to_chat(usr, "Failed to locate [targetitem]!")
						return
					to_chat(usr, "You set the pinpointer to locate [targetitem]")
				if("DNA")
					var/DNAstring = sanitize(input("Input DNA string to search for." , "Please Enter String." , ""))
					if(!DNAstring)
						return
					for(var/mob/living/carbon/M as anything in carbon_list)
						if(!M.dna)
							continue
						if(M.dna.unique_enzymes == DNAstring)
							target = M
							break
				if("AI System")
					if(!global.ai_list.len)
						to_chat(usr, "Failed to locate active AI system!")
						return
					var/target_ai = input("Select AI to search for", "AI Select") as null|anything in global.ai_list
					if(!target_ai)
						return
					target = target_ai
					to_chat(usr, "You set the pinpointer to locate [target]")

	if(mode && target)
		RegisterSignal(target, list(COMSIG_PARENT_QDELETING), .proc/reset_target)

	return attack_self(usr)

/obj/item/weapon/pinpointer/nukeop

/obj/item/weapon/pinpointer/nukeop/attack_self(mob/user)
	..()
	if(mode == SEARCH_FOR_DISK)
		to_chat(user, "<span class='notice'>Authentication Disk Locator active.</span>")
	else
		to_chat(user, "<span class='notice'>Shuttle Locator active.</span>")

/obj/item/weapon/pinpointer/nukeop/process()
	if(bomb_set)
		mode = SEARCH_FOR_OBJECT
		if(!istype(target, /obj/machinery/computer/syndicate_station))
			target = locate(/obj/machinery/computer/syndicate_station)
			if(!target)
				icon_state = "pinonnull"
				return
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)	//Plays a beep
			visible_message("Shuttle Locator active.")			//Lets the mob holding it know that the mode has changed
			RegisterSignal(target, list(COMSIG_PARENT_QDELETING), .proc/reset_target)
	else
		if(istype(target, /obj/machinery/computer/syndicate_station))
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='notice'>Authentication Disk Locator active.</span>")
			reset_target()
		mode = SEARCH_FOR_DISK
	return ..()

#undef SEARCH_FOR_DISK
#undef SEARCH_FOR_OBJECT
