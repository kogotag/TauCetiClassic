
//spawns one of the specified animal type
/obj/effect/landmark/animal_spawner
	icon_state = "x3"
	var/spawn_type
	var/mob/living/spawned_animal

/obj/effect/landmark/animal_spawner/atom_init()
	. = ..()

	if(!spawn_type)
		var/new_type = pick(subtypesof(/obj/effect/landmark/animal_spawner))
		new new_type(get_turf(src))
		return INITIALIZE_HINT_QDEL

	START_PROCESSING(SSobj, src)

/obj/effect/landmark/animal_spawner/process()
	//if any of our animals are killed, spawn new ones
	if(!spawned_animal || spawned_animal.stat == DEAD)
		spawned_animal = new spawn_type(src)
		//after a random timeout, and in a random position (6-30 seconds)
		spawn(rand(1200,2400))
			spawned_animal.loc = locate(src.x + rand(-12,12), src.y + rand(-12,12), src.z)

/obj/effect/landmark/animal_spawner/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/landmark/animal_spawner/panther
	name = "panther spawner"
	spawn_type = /mob/living/simple_animal/hostile/panther

/obj/effect/landmark/animal_spawner/parrot
	name = "parrot spawner"
	spawn_type = /mob/living/simple_animal/parrot

/obj/effect/landmark/animal_spawner/monkey
	name = "monkey spawner"
	spawn_type = /mob/living/carbon/monkey

/obj/effect/landmark/animal_spawner/snake
	name = "snake spawner"
	spawn_type = /mob/living/simple_animal/hostile/snake


//*********//
// Panther //
//*********//

/mob/living/simple_animal/hostile/panther
	name = "panther"
	desc = "A long sleek, black cat with sharp teeth and claws."
	icon = 'icons/misc/jungle.dmi'
	icon_state = "panther"
	icon_living = "panther"
	icon_dead = "panther_dead"
	icon_gib = "panther_dead"
	speak_chance = 0
	turns_per_move = 3
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	stop_automated_movement_when_pulled = FALSE
	maxHealth = 50
	health = 50
	w_class = SIZE_HUMAN

	harm_intent_damage = 8
	melee_damage = 15
	attacktext = "gnaw"
	attack_sound = list('sound/weapons/bite.ogg')

	layer = 3.1		//so they can stay hidde under the /obj/structure/bush
	var/stalk_tick_delay = 3

/mob/living/simple_animal/hostile/panther/ListTargets()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(src, 10))
		targets += H
	return targets

/mob/living/simple_animal/hostile/panther/FindTarget()
	. = ..()
	if(.)
		me_emote("nashes at [.]")

/mob/living/simple_animal/hostile/panther/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(3)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/panther/AttackTarget()
	..()
	if(stance == HOSTILE_STANCE_ATTACKING && get_dist(src, target))
		stalk_tick_delay -= 1
		if(stalk_tick_delay <= 0)
			src.loc = get_step_towards(src, target)
			stalk_tick_delay = 3

//*******//
// Snake //
//*******//

/mob/living/simple_animal/hostile/snake
	name = "snake"
	desc = "A sinuously coiled, venomous looking reptile."
	icon = 'icons/misc/jungle.dmi'
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	icon_gib = "snake_dead"
	speak_chance = 0
	turns_per_move = 1
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 2)
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	stop_automated_movement_when_pulled = FALSE
	maxHealth = 25
	health = 25
	w_class = SIZE_HUMAN

	harm_intent_damage = 2
	melee_damage = 7
	attacktext = "gnaw"
	attack_sound = list('sound/weapons/bite.ogg')

	layer = 3.1		//so they can stay hidde under the /obj/structure/bush
	var/stalk_tick_delay = 3

/mob/living/simple_animal/hostile/snake/ListTargets()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(src, 10))
		targets += H
	return targets

/mob/living/simple_animal/hostile/snake/FindTarget()
	. = ..()
	if(.)
		me_emote("hisses wickedly")

/mob/living/simple_animal/hostile/snake/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		L.apply_damage(rand(3,12), TOX)

/mob/living/simple_animal/hostile/snake/AttackTarget()
	..()
	if(stance == HOSTILE_STANCE_ATTACKING && get_dist(src, target))
		stalk_tick_delay -= 1
		if(stalk_tick_delay <= 0)
			src.loc = get_step_towards(src, target)
			stalk_tick_delay = 3
