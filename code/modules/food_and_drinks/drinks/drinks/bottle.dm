

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/reagent_containers/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	throwforce = 15
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/is_glass = TRUE //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

/obj/item/reagent_containers/drinks/bottle/proc/smash(mob/living/target, mob/living/user, ranged = FALSE)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	var/new_location = get_turf(loc)
	var/obj/item/broken_bottle/B = new /obj/item/broken_bottle(new_location)
	if(ranged)
		B.loc = new_location
	else
		user.drop_item()
		user.put_in_active_hand(B)
	B.icon_state = icon_state

	var/icon/I = new(broken_bottle_icon, icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	if(is_glass)
		if(prob(33))
			new/obj/item/shard(new_location)
		playsound(src, "shatter", 70, 1)
	else
		B.name = "broken carton"
		B.force = 0
		B.throwforce = 0
		B.desc = "A carton with the bottom half burst open. Might give you a papercut."
	transfer_fingerprints_to(B)

	qdel(src)

/obj/item/reagent_containers/drinks/bottle/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(user.a_intent != INTENT_HARM)
		return ..()

/obj/item/reagent_containers/drinks/bottle/pre_attack(atom/A, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(isliving(A))
		if(!is_glass)
			mob_act(A, user)
			return FINISH_ATTACK

		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to harm [A]!</span>")
			return FINISH_ATTACK

/obj/item/reagent_containers/drinks/bottle/attack(mob/living/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	force = 15 //Smashing bottles over someoen's head hurts.

	var/obj/item/organ/external/affecting = user.zone_selected //Find what the player is aiming at

	var/armor_block = 0 //Get the target's armor values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	if(ishuman(target))

		var/mob/living/carbon/human/H = target
		var/headarmor = 0 // Target's head armor
		armor_block = H.run_armor_check(affecting, MELEE, null, null, armour_penetration_flat, armour_penetration_percentage) // For normal attack damage

		//If they have a hat/helmet and the user is targeting their head.
		if(istype(H.head, /obj/item/clothing/head) && affecting == "head")

			// If their head has an armor value, assign headarmor to it, else give it 0.
			if(H.head.armor.getRating(MELEE))
				headarmor = H.head.armor.getRating(MELEE)
			else
				headarmor = 0
		else
			headarmor = 0

		//Calculate the weakening duration for the target.
		armor_duration = (duration - headarmor) + force

	else
		//Only humans can have armor, right?
		armor_block = target.run_armor_check(affecting, MELEE)
		if(affecting == "head")
			armor_duration = duration + force
	armor_duration /= 10

	//Apply the damage!
	armor_block = min(90, armor_block)
	target.apply_damage(force, BRUTE, affecting, armor_block)

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/head_attack_message = ""
	if(affecting == "head" && iscarbon(target))
		head_attack_message = " on the head"
		//Weaken the target for the duration that we calculated and divide it by 5.
		if(armor_duration)
			var/knockdown_time = (min(armor_duration, 10)) STATUS_EFFECT_CONSTANT
			target.KnockDown(knockdown_time)

	//Display an attack message.
	if(target != user)
		target.visible_message("<span class='danger'>[user] has hit [target][head_attack_message] with a bottle of [name]!</span>", \
				"<span class='userdanger'>[user] has hit [target][head_attack_message] with a bottle of [name]!</span>")
	else
		user.visible_message("<span class='danger'>[target] hits [target.p_themselves()] with a bottle of [name][head_attack_message]!</span>", \
				"<span class='userdanger'>[target] hits [target.p_themselves()] with a bottle of [name][head_attack_message]!</span>")

	//Attack logs
	add_attack_logs(user, target, "Hit with [src]")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	SplashReagents(target)

	//Finally, smash the bottle. This kills (qdel) the bottle.
	smash(target, user)

/obj/item/reagent_containers/drinks/bottle/proc/SplashReagents(mob/M)
	if(reagents && reagents.total_volume)
		M.visible_message("<span class='danger'>The contents of \the [src] splashes all over [M]!</span>")
		reagents.reaction(M, REAGENT_TOUCH)
		reagents.clear_reagents()

/obj/item/reagent_containers/drinks/bottle/throw_impact(atom/target,mob/thrower)
	..()
	SplashReagents(target)
	smash(target, thrower, ranged = TRUE)

/obj/item/reagent_containers/drinks/bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!reagents.total_volume)
		C.stored_comms["glass"] += 3
		qdel(src)
		return TRUE
	return ..()

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle
	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	item_state = "beer"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stabbed", "slashed", "attacked")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	sharp = TRUE

/obj/item/broken_bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["glass"] += 3
	qdel(src)
	return TRUE

/obj/item/reagent_containers/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	list_reagents = list("gin" = 100)

/obj/item/reagent_containers/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	list_reagents = list("whiskey" = 100)

/obj/item/reagent_containers/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/drinks/bottle/vodka/badminka
	name = "Badminka Vodka"
	desc = "The label's written in Cyrillic. All you can make out is the name and a word that looks vaguely like 'Vodka'."
	icon_state = "badminka"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	list_reagents = list("tequila" = 100)

/obj/item/reagent_containers/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing."
	icon_state = "bottleofnothing"
	list_reagents = list("nothing" = 100)

/obj/item/reagent_containers/drinks/bottle/bottleofbanana
	name = "Jolly Jug"
	desc = "A jug filled with banana juice."
	icon_state = "bottleofjolly"
	list_reagents = list("banana" = 100)

/obj/item/reagent_containers/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	list_reagents = list("patron" = 100)

/obj/item/reagent_containers/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	list_reagents = list("rum" = 100)

/obj/item/reagent_containers/drinks/bottle/holywater
	name = "flask of holy water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	list_reagents = list("holywater" = 100)

/obj/item/reagent_containers/drinks/bottle/holywater/hell
	desc = "A flask of holy water...it's been sitting in the Necropolis a while though."
	list_reagents = list("hell_water" = 100)

/obj/item/reagent_containers/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	list_reagents = list("vermouth" = 100)

/obj/item/reagent_containers/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK."
	icon_state = "kahluabottle"
	list_reagents = list("kahlua" = 100)

/obj/item/reagent_containers/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	list_reagents = list("goldschlager" = 100)

/obj/item/reagent_containers/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	list_reagents = list("cognac" = 100)

/obj/item/reagent_containers/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	list_reagents = list("wine" = 100)

/obj/item/reagent_containers/drinks/bottle/absinthe
	name = "Yellow Marquee Absinthe"
	desc = "A strong alcoholic drink brewed and distributed by Yellow Marquee."
	icon_state = "absinthebottle"
	list_reagents = list("absinthe" = 100)

/obj/item/reagent_containers/drinks/bottle/absinthe/premium
	name = "Gwyn's Premium Absinthe"
	desc = "A potent alcoholic beverage, almost makes you forget the ash in your lungs."
	icon_state = "absinthepremium"

/obj/item/reagent_containers/drinks/bottle/hcider
	name = "Jian Hard Cider"
	desc = "Apple juice for adults."
	icon_state = "hcider"
	volume = 50
	list_reagents = list("suicider" = 50)

/obj/item/reagent_containers/drinks/bottle/fernet
	name = "Fernet Bronca"
	desc = "A bottle of pure Fernet Bronca, produced in Cordoba Space Station."
	icon_state = "fernetbottle"
	list_reagents = list("fernet" = 100)

/obj/item/reagent_containers/drinks/bottle/beer
	name = "space beer"
	desc = "Contains only water, malt and hops."
	icon_state = "beer"
	volume = 50
	list_reagents = list("beer" = 50)

/obj/item/reagent_containers/drinks/bottle/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	volume = 50
	list_reagents = list("ale" = 50)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/reagent_containers/drinks/bottle/orangejuice
	name = "orange juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	throwforce = 0
	is_glass = FALSE
	gender = PLURAL
	list_reagents = list("orangejuice" = 100)

/obj/item/reagent_containers/drinks/bottle/cream
	name = "milk cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	throwforce = 0
	is_glass = FALSE
	gender = PLURAL
	list_reagents = list("cream" = 100)

/obj/item/reagent_containers/drinks/bottle/tomatojuice
	name = "tomato juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	throwforce = 0
	is_glass = FALSE
	gender = PLURAL
	list_reagents = list("tomatojuice" = 100)

/obj/item/reagent_containers/drinks/bottle/limejuice
	name = "lime juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	throwforce = 0
	is_glass = FALSE
	gender = PLURAL
	list_reagents = list("limejuice" = 100)

/obj/item/reagent_containers/drinks/bottle/milk
	name = "milk"
	desc = "Soothing milk."
	icon_state = "milk"
	item_state = "carton"
	throwforce = 0
	is_glass = FALSE
	gender = PLURAL
	list_reagents = list("milk" = 100)

////////////////////////// MOLOTOV ///////////////////////
/obj/item/reagent_containers/drinks/bottle/molotov
	name = "molotov cocktail"
	desc = "A throwing weapon used to ignite things, typically filled with an accelerant. Recommended highly by rioters and revolutionaries. Light and toss."
	icon_state = "vodkabottle"
	list_reagents = list()
	var/list/accelerants = list(/datum/reagent/consumable/ethanol,/datum/reagent/fuel,/datum/reagent/clf3,/datum/reagent/phlogiston,
							/datum/reagent/napalm,/datum/reagent/hellwater,/datum/reagent/plasma,/datum/reagent/plasma_dust)
	var/active = FALSE

/obj/item/reagent_containers/drinks/bottle/molotov/update_desc()
	. = ..()
	desc = initial(desc)
	if(!is_glass)
		desc += " You're not sure if making this out of a carton was the brightest idea."

/obj/item/reagent_containers/drinks/bottle/molotov/update_icon_state()
	var/obj/item/reagent_containers/drinks/bottle/B = locate() in contents
	if(B)
		icon_state = B.icon_state

/obj/item/reagent_containers/drinks/bottle/molotov/update_overlays()
	. = ..()
	if(active)
		. += GLOB.fire_overlay

/obj/item/reagent_containers/drinks/bottle/molotov/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/drinks/bottle/B = locate() in contents
	if(B)
		B.reagents.copy_to(src, 100)
		if(!B.is_glass)
			is_glass = FALSE
		update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/item/reagent_containers/drinks/bottle/molotov/throw_impact(atom/target,mob/thrower)
	var/firestarter = FALSE
	for(var/datum/reagent/R in reagents.reagent_list)
		for(var/A in accelerants)
			if(istype(R, A))
				firestarter = TRUE
				break
	..()
	if(firestarter && active)
		target.fire_act()
		var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(target)
		hotspot.temperature = 1000
		hotspot.recolor()

/obj/item/reagent_containers/drinks/bottle/molotov/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(used.get_heat() && !active)
		active = TRUE
		var/turf/bombturf = get_turf(src)
		var/area/bombarea = get_area(bombturf)
		message_admins("[key_name(user)][ADMIN_QUE(user,"?")] has primed a [name] for detonation at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[bombarea] (JMP)</a>.")
		log_game("[key_name(user)] has primed a [name] for detonation at [bombarea] ([bombturf.x],[bombturf.y],[bombturf.z]).")

		to_chat(user, "<span class='notice'>You light [src] on fire.</span>")
		if(!is_glass)
			spawn(50)
				if(active)
					var/counter
					var/target = loc
					for(counter = 0, counter < 2, counter++)
						if(isstorage(target))
							var/obj/item/storage/S = target
							target = S.loc
					if(istype(target, /atom))
						var/atom/A = target
						SplashReagents(A)
						A.fire_act()
					qdel(src)
		return ITEM_INTERACT_COMPLETE

/obj/item/reagent_containers/drinks/bottle/molotov/activate_self(mob/user)
	if(..())
		return

	if(active)
		if(!is_glass)
			to_chat(user, "<span class='danger'>The flame's spread too far on it!</span>")
			return
		to_chat(user, "<span class='notice'>You snuff out the flame on \the [src].</span>")
		active = FALSE
		update_icon(UPDATE_OVERLAYS)
