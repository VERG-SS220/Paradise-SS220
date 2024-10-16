/* Lootdrop food spawners */
/obj/effect/spawner/lootdrop/CCfood

/obj/effect/spawner/lootdrop/CCfood/desert
	lootcount = 5
	loot = list(
		/obj/item/food/baguette=10,
		/obj/item/food/applepie=10,
		/obj/item/food/bananabreadslice=10,
		/obj/item/food/bananacakeslice=10,
		/obj/item/food/carrotcakeslice=10,
		/obj/item/food/croissant=10,
		/obj/item/reagent_containers/drinks/cans/cola=10,""=70)

/obj/effect/spawner/lootdrop/CCfood/meat
	lootcount = 5
	loot = list(
		/obj/item/food/lasagna=10,
		/obj/item/food/burger/bigbite=10,
		/obj/item/food/fishandchips=10,
		/obj/item/food/fishburger=10,
		/obj/item/food/hotdog=10,
		/obj/item/food/meatpie=10,
		/obj/item/reagent_containers/drinks/cans/cola=10,""=70)

/obj/effect/spawner/lootdrop/CCfood/alcohol
	lootcount = 1
	loot = list(
		/obj/item/reagent_containers/drinks/flask/detflask=10,
		/obj/item/reagent_containers/drinks/cans/tonic=10,
		/obj/item/reagent_containers/drinks/cans/thirteenloko=10,
		/obj/item/reagent_containers/drinks/cans/synthanol=10,
		/obj/item/reagent_containers/drinks/cans/space_mountain_wind=10,
		/obj/item/reagent_containers/drinks/cans/lemon_lime=10,""=70)

/* Lootdrop */
/obj/effect/spawner/lootdrop/maintenance
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'

/obj/effect/spawner/lootdrop/maintenance/three
	icon_state = "trippleloot"

/obj/effect/spawner/lootdrop/maintenance/five
	name = "maintenance loot spawner (5 items)"
	icon_state = "moreloot"
	lootcount = 5

/obj/effect/spawner/lootdrop/trash
	name = "trash spawner"
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "trash"
	loot = list(
		/obj/item/trash/bowl,
		/obj/item/trash/can,
		/obj/item/trash/candle,
		/obj/item/trash/candy,
		/obj/item/trash/cheesie,
		/obj/item/trash/chips,
		/obj/item/trash/fried_vox,
		/obj/item/trash/gum,
		/obj/item/trash/liquidfood,
		/obj/item/trash/pistachios,
		/obj/item/trash/plate,
		/obj/item/trash/popcorn,
		/obj/item/trash/raisins,
		/obj/item/trash/semki,
		/obj/item/trash/snack_bowl,
		/obj/item/trash/sosjerky,
		/obj/item/trash/spacetwinkie,
		/obj/item/trash/spentcasing,
		/obj/item/trash/syndi_cakes,
		/obj/item/trash/tapetrash,
		/obj/item/trash/tastybread,
		/obj/item/trash/tray,
		/obj/item/trash/waffles,
		""=20
		)

/* Random spawners */
/obj/effect/spawner/random_spawners/mod
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "mod"

/obj/effect/spawner/random_spawners/syndicate/loot
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "common"

/obj/effect/spawner/random_spawners/syndicate/loot/level2
	icon_state = "rare"

/obj/effect/spawner/random_spawners/syndicate/loot/level3
	icon_state = "officer"

/obj/effect/spawner/random_spawners/syndicate/loot/level4
	icon_state = "armory"

/obj/effect/spawner/random_spawners/syndicate/loot/stetchkin
	icon_state = "stetchkin"

/obj/item/reagent_containers/pill/random_drugs
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "pills"

/obj/item/reagent_containers/pill/random_drugs/Initialize(mapload)
	icon = 'icons/obj/chemical.dmi'
	. = ..()

/obj/item/reagent_containers/drinks/bottle/random_drink
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "drinks"

/obj/item/reagent_containers/drinks/bottle/random_drink/Initialize(mapload)
	icon = 'icons/obj/drinks.dmi'
	. = ..()

/obj/effect/mob_spawn/human/alive
	/// Tells if it can spawn saved characters
	var/can_spawn_saved = FALSE
	/// Storage in which loadout gear is placed
	var/loadout_storage_type = /obj/item/storage/backpack
	/// Job name for an ID photo
	var/id_photo_job

/obj/effect/mob_spawn/human/alive/attack_ghost(mob/user)
	if(!valid_to_spawn(user))
		return
	if(can_spawn_saved && tgui_alert(user, "Хотите ли Вы использовать одного из сохраненных персонажей?", "Syndicate Space Base", list("Да", "Нет")) == "Да")
		var/list/our_characters_names = list()
		var/list/our_character_saves = list()
		for(var/index in 1 to length(user.client.prefs.character_saves))
			var/datum/character_save/saves = user.client.prefs.character_saves[index]
			var/slot_name = "[saves.real_name] (Слот #[index])"
			our_characters_names += slot_name
			our_character_saves += list("[slot_name]" = saves)

		var/character_name = tgui_input_list(user, "Выберите персонажа", "Выбор персонажа", our_characters_names)
		if(!character_name || QDELETED(user))
			return
		if(!loc || !uses && !permanent || QDELETED(src))
			to_chat(user, span_warning("[name] больше не доступен!"))
			return
		var/datum/character_save/save_to_load = our_character_saves[character_name]
		create_saved(user.ckey, user, save_to_load)
	else
		return ..()

/obj/effect/mob_spawn/human/alive/proc/create_saved(ckey, mob/user = usr, datum/character_save/save)
	var/mob/living/carbon/human/H = create(ckey, name = save.real_name)
	save.copy_to(H)

	var/obj/item/card/id/id_card = H.wear_id
	if(id_card)
		id_card.registered_name = H.real_name
		id_card.UpdateName()
		id_card.SetOwnerInfo(H)
		id_card.photo = get_id_photo(H, id_photo_job)
		id_card.owner_uid = H.UID()
		id_card.owner_ckey = ckey
		id_card.RebuildHTML()

	var/obj/item/storage/backpack/loadout_storage = new loadout_storage_type(get_turf(loc))
	for(var/gear in save.loadout_gear)
		var/datum/gear/G = GLOB.gear_datums[text2path(gear) || gear]
		if(isnull(G))
			continue
		if(G.allowed_roles)
			continue
		G.spawn_item(loadout_storage)
	if(length(loadout_storage.contents))
		H.put_in_any_hand_if_possible(loadout_storage)
		to_chat(H, span_notice("Доступные предметы из лодаута помещены в сумку."))
	else
		qdel(loadout_storage)

/* Space Battle */
/obj/effect/mob_spawn/human/corpse/spacebattle
	var/list/pocketloot = list(/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift,
		/obj/item/storage/fancy/cigarettes/cigpack_random,
		/obj/item/cigbutt,
		/obj/item/clothing/mask/cigarette/menthol,
		/obj/item/clothing/mask/cigarette,
		/obj/item/clothing/mask/cigarette/random,
		/obj/item/lighter/random,
		/obj/item/assembly/igniter,
		/obj/item/storage/fancy/matches,
		/obj/item/match,
		/obj/item/food/donut,
		/obj/item/food/candy/candybar,
		/obj/item/food/tastybread,
		/obj/item/reagent_containers/drinks/cans/dr_gibb,
		/obj/item/pen,
		/obj/item/screwdriver,
		/obj/item/stack/tape_roll,
		/obj/item/radio,
		/obj/item/coin,
		/obj/item/coin/twoheaded,
		/obj/item/coin/iron,
		/obj/item/coin/silver,
		/obj/item/flashlight,
		/obj/item/stock_parts/cell,
		/obj/item/paper/crumpled,
		/obj/item/extinguisher/mini,
		/obj/item/deck/cards,
		/obj/item/reagent_containers/pill/salbutamol,
		/obj/item/reagent_containers/patch/silver_sulf/small,
		/obj/item/reagent_containers/patch/styptic/small,
		/obj/item/reagent_containers/pill/salicylic,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/weldingtool/mini,
		/obj/item/flashlight/flare/glowstick/emergency,
		/obj/item/flashlight/flare,
		/obj/item/toy/crayon/white,
		)

/obj/effect/mob_spawn/human/corpse/spacebattle/Initialize()
	l_pocket = pick(pocketloot)
	r_pocket = pick(pocketloot)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/assistant
	name = "Dead Civilian"
	mob_name = "Ship Personnel"
	id = /obj/item/card/id/away/old
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black

/obj/effect/mob_spawn/human/corpse/spacebattle/security
	name = "Dead Officer"
	mob_name = "Ship Officer"
	id = /obj/item/card/id/away/old/sec
	uniform = /obj/item/clothing/under/retro/security
	belt = /obj/item/clothing/accessory/holster/waist
	suit = /obj/item/clothing/suit/armor/vest/security
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet
	gloves = /obj/item/clothing/gloves/fingerless
	back = /obj/item/storage/backpack/satchel_sec

/obj/effect/mob_spawn/human/corpse/spacebattle/security/Initialize()
	var/secgun = rand(1,10)
	switch(secgun)
		//70%
		if(1 to 7)
			suit_store = /obj/item/gun/projectile/automatic/pistol/enforcer/lethal
			backpack_contents = list(
				/obj/item/storage/box/survival = 1,
				/obj/item/ammo_box/magazine/enforcer/lethal = 1
				)
		//20%
		if(8 to 9)
			suit_store = /obj/item/gun/projectile/automatic/wt550
			backpack_contents = list(
				/obj/item/storage/box/survival = 1,
				/obj/item/ammo_box/magazine/wt550m9 = 1
				)
		//10%
		if(10)
			suit_store = /obj/item/gun/projectile/shotgun/riot
			backpack_contents = list(
				/obj/item/storage/box/survival = 1,
				/obj/item/storage/box/buck = 1
				)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/engineer
	name = "Dead Engineer"
	mob_name = "Engineer"
	id = /obj/item/card/id/away/old/eng
	uniform = /obj/item/clothing/under/retro/engineering
	belt = /obj/item/storage/belt/utility/full
	suit = /obj/item/clothing/suit/storage/hazardvest
	shoes = /obj/item/clothing/shoes/workboots
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/hardhat/orange
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	back = /obj/item/storage/backpack/duffel/engineering
	backpack_contents = /obj/item/storage/box/engineer

/obj/effect/mob_spawn/human/corpse/spacebattle/engineer/Initialize()
	var/engstaff = rand(1,3)
	switch(engstaff)
		if(1)
			backpack_contents = list(
			/obj/item/clothing/head/welding = 1,
			/obj/item/weldingtool/largetank = 1,
			/obj/item/stack/sheet/metal{amount = 10} = 1,
			/obj/item/stack/rods{amount = 3} = 1
			)
		if(2)
			backpack_contents = list(
			/obj/item/apc_electronics = 1,
			/obj/item/stock_parts/cell/high = 1,
			/obj/item/t_scanner = 1,
			/obj/item/stack/cable_coil{amount = 7} = 1
			)
		if(3)
			backpack_contents = list(
			/obj/item/storage/briefcase/inflatable = 1,
			/obj/item/stack/sheet/glass{amount = 5} = 1,
			/obj/item/grenade/gas/oxygen = 1,
			/obj/item/analyzer = 1
			)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/engineer/space
	suit = /obj/item/clothing/suit/space/hardsuit/ancient
	head = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	shoes = /obj/item/clothing/shoes/magboots

/obj/effect/mob_spawn/human/corpse/spacebattle/medic
	name = "Dead Medic"
	mob_name = "Medic"
	id = /obj/item/card/id/away/old/med
	uniform = /obj/item/clothing/under/retro/medical
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	id = /obj/item/card/id/medical
	back = /obj/item/storage/backpack/satchel_med

/obj/effect/mob_spawn/human/corpse/spacebattle/medic/Initialize()
	backpack_contents = list(
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/pill_bottle/random_drug_bottle = 1,
		)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/bridgeofficer
	name = "Bridge Officer"
	mob_name = "Bridge Officer"
	id = /obj/item/card/id/away/old/sec
	uniform = /obj/item/clothing/under/rank/procedure/blueshield{name = "Bridge Officer uniform"}
	belt = /obj/item/clothing/accessory/holster/waist
	suit = /obj/item/clothing/suit/armor/vest/security
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet/night
	gloves = /obj/item/clothing/gloves/fingerless
	back = /obj/item/storage/backpack/satchel

/obj/effect/mob_spawn/human/corpse/spacebattle/bridgeofficer/Initialize()
	backpack_contents = list(
		/obj/item/reagent_containers/patch/silver_sulf/small,
		/obj/item/reagent_containers/patch/styptic/small,
		/obj/item/stock_parts/cell/high = 1,
		/obj/item/storage/box/buck = 1
		)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/scientist
	name = "Dead Scientist"
	mob_name = "Scientist"
	id = /obj/item/card/id/away/old/sci
	uniform = /obj/item/clothing/under/retro/science
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/storage/labcoat/science

/obj/effect/mob_spawn/human/alive/spacebase_syndicate
	can_spawn_saved = TRUE
	loadout_storage_type = /obj/item/storage/backpack/duffel/syndie
	id_photo_job = "Syndicate Agent"
