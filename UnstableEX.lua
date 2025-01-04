local unstbex = SMODS.current_mod
local filesystem = NFS or love.filesystem
local path = unstbex.path

--Global Table
unstbex_global = {}

--Localization Messages
--local loc = filesystem.load(path..'localization.lua')()

-- Debug message

local function print(message)
    sendDebugMessage('[UnstableEX] - '..(tostring(message) or '???'))
end

print("Starting UnstableEX")

--Compat List

unstbex_global.compat = {
	Bunco = (SMODS.Mods["Bunco"] or {}).can_load,
	Familiar = (SMODS.Mods["familiar"] or {}).can_load,
	Ortalab = (SMODS.Mods["ortalab"] or {}).can_load,
	Six_Suit = (SMODS.Mods["SixSuits"] or {}).can_load,
	Inks_Color = (SMODS.Mods["InkAndColor"] or {}).can_load,
	Cryptid = (SMODS.Mods["Cryptid"] or {}).can_load,
}

local function check_mod_active(mod_id)
	return unstbex_global.compat[mod_id]
end

--Utility

--Auto event scheduler, based on Bunco
local function event(config)
    local e = Event(config)
    G.E_MANAGER:add_event(e)
    return e
end

local function big_juice(card)
    card:juice_up(0.7)
end

local function extra_juice(card)
    card:juice_up(0.6, 0.1)
end

local function play_nope_sound()
	--Copied from Wheel of Fortune lol
	event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
           play_sound('tarot2', 0.76, 0.4);return true end})
    play_sound('tarot2', 1, 0.4)
end

local function forced_message(message, card, color, delay, juice)
    if delay == true then
        delay = 0.7 * 1.25
    elseif delay == nil then
        delay = 0
    end

    event({trigger = 'before', delay = delay, func = function()

        if juice then big_juice(juice) end

        card_eval_status_text(
            card,
            'extra',
            nil, nil, nil,
            {message = message, colour = color, instant = true}
        )
        return true
    end})
end

-- Index-based coordinates generation

local function get_coordinates(position, width)
    if width == nil then width = 10 end -- 10 is default for Jokers
    return {x = (position) % width, y = math.floor((position) / width)}
end

--Mod Icon
SMODS.Atlas {
  -- Key for code to find it with
  key = "modicon",
  -- The name of the file, for the code to pull the atlas from
  path = "modicon.png",
  -- Width of each sprite in 1x size
  px = 32,
  -- Height of each sprite in 1x size
  py = 32
}

--Creates an atlas for cards to use
--[[SMODS.Atlas {
  -- Key for code to find it with
  key = "unstbEX_jokers",
  -- The name of the file, for the code to pull the atlas from
  path = "unstbEX_jokers.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}]]

--Updated Enhancement atli to include modded suits
SMODS.Atlas {
  key = "enh_slop",
  path = "enh_slop.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "enh_slop_hc",
  path = "enh_slop_hc.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "enh_res",
  path = "enh_res.png",
  px = 71,
  py = 95
}

--Atlas for extra ranks
SMODS.Atlas {
  -- Key for code to find it with
  key = "rank_ex",
  -- The name of the file, for the code to pull the atlas from
  path = "rank_ex.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

SMODS.Atlas {
  -- Key for code to find it with
  key = "rank_ex_hc",
  -- The name of the file, for the code to pull the atlas from
  path = "rank_ex_hc.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

--Familiar's Multi-Suit Cards Fallback
--(I don't think it is possible to make all combinations by myself, especially to account for modded suits)
SMODS.Atlas {
  -- Key for code to find it with
  key = "rank_ex_multi",
  -- The name of the file, for the code to pull the atlas from
  path = "rank_ex_multi.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

--Remap Additional Rank atlas with the expanded version

local rank_suit_map = {
            Hearts = 0,
            Clubs = 1,
            Diamonds = 2,
            Spades = 3,
			
			bunc_Fleurons = 4,
			bunc_Halberds = 5,
			
			six_Stars = 6,
			six_Moons = 7,
			
			ink_Inks = 8,
			ink_Colors = 9,
}

--SMODS.Ranks['unstb_0.5'].lc_atlas = 'unstbex_rank_ex'
--SMODS.Ranks['unstb_0.5'].hc_atlas = 'unstbex_rank_ex_hc'
--SMODS.Ranks['unstb_0.5'].suit_map = rank_suit_map

local function inject_rank_atlas(prefix)
	for k,v in pairs(SMODS.Ranks) do
		if k:find(prefix) then
			local rank = SMODS.Ranks[k]
			
			rank.lc_atlas = 'unstbex_rank_ex'
			rank.hc_atlas = 'unstbex_rank_ex_hc'
			rank.suit_map = rank_suit_map

			print("Injecting the graphic for rank "..rank.key)
		end
	end
end

inject_rank_atlas('unstb_')

--Register Suits for UnStable suit system

--Modded Suits Code in UnStableEX

--Bunco
--[[register_suit_group("suit_black", "bunc_Halberds")
register_suit_group("suit_red", "bunc_Fleurons")

register_suit_group("suit_black", "six_Moons")
register_suit_group("suit_red", "six_Stars")

register_suit_group("no_smear", "Inks_Inks")
register_suit_group("no_smear", "Inks_Color")]]

--Update extended atlas for Slop and Resource Cards

local center_unstb_slop = SMODS.Centers['m_unstb_slop'] or {}
center_unstb_slop.suit_map = rank_suit_map
center_unstb_slop.atlas = 'unstbex_enh_slop'
center_unstb_slop.lc_atlas = 'unstbex_enh_slop'
center_unstb_slop.hc_atlas = 'unstbex_enh_slop_hc'

local center_unstb_resource = SMODS.Centers['m_unstb_resource'] or {}
center_unstb_resource.suit_map = rank_suit_map
center_unstb_resource.atlas = 'unstbex_enh_res'

if check_mod_active("Bunco") then

print("Inject Bunco Jokers")

local bunc_pawn = SMODS.Centers['j_bunc_pawn'] or {}

--Blacklist ranks for Pawn
local pawn_rank_blacklist = {
	['Ace'] = true,
	['unstb_21'] = true,
	['unstb_???'] = true,
}

bunc_pawn.calculate = function(self, card, context)
	if context.after and context.scoring_hand and not context.blueprint then
		for i = 1, #context.scoring_hand do
			local condition = false
			local other_card = context.scoring_hand[i]
			local rank = math.huge
			for _, deck_card in ipairs(G.playing_cards) do
				local newrank = deck_card.base.nominal + (deck_card.base.face_nominal or 0)
				if newrank < rank and (not deck_card.config.center.no_rank or deck_card.config.center ~= G.P_CENTERS.m_stone) then
					rank = newrank
				end
			end
			if other_card.base.nominal == rank and not pawn_rank_blacklist[other_card.base.value] then
				condition = true
				event({trigger = 'after', delay = 0.15, func = function() other_card:flip(); play_sound('card1', 1); other_card:juice_up(0.3, 0.3); return true end })
				event({
					trigger = 'after',
					delay = 0.1,
					func = function()
						local new_rank = get_next_x_rank(other_card.base.value, 1)
						assert(SMODS.change_base(other_card, nil, new_rank))
						return true
					end
				})
				event({trigger = 'after', delay = 0.15, func = function() other_card:flip(); play_sound('tarot2', 1, 0.6); big_juice(card); other_card:juice_up(0.3, 0.3); return true end })
			end
			if condition then delay(0.7 * 1.25) end
		end
	end
end

local bunc_zero_shapiro = SMODS.Centers['j_bunc_zero_shapiro'] or {}

local zeroshapiro_zerorank = {
	['unstb_0'] = true,
	['unstb_???'] = true,
	['Jack'] = true,
	['Queen'] = true,
	['King'] = true,
}

bunc_zero_shapiro.calculate = function(self, card, context)
	if context.individual and context.cardarea == G.play then
		--print("UnStbEX version")
		if context.other_card.config.center.no_rank or zeroshapiro_zerorank[context.other_card.base.value] then

			local old_amount = card.ability.extra.amount
			card.ability.extra.amount = card.ability.extra.amount + card.ability.extra.bonus

			for k, v in pairs(G.GAME.probabilities) do
				G.GAME.probabilities[k] = G.GAME.probabilities[k] / old_amount * card.ability.extra.amount
			end

			return { --TO DO: Adds a proper localization for this
				extra = {message = '+X'..card.ability.extra.bonus..' '..'Chance', colour = G.C.GREEN},
				card = card
			}
		end
	end

	if context.end_of_round and not context.other_card then
		if card.ability.extra.amount ~= 1 then
			for k, v in pairs(G.GAME.probabilities) do
				G.GAME.probabilities[k] = v / card.ability.extra.amount
			end

			card.ability.extra.amount = 1

			forced_message(localize('k_reset'), card, G.C.GREEN, true)
		end
	end

	if context.selling_self then
		for k, v in pairs(G.GAME.probabilities) do
			G.GAME.probabilities[k] = v / card.ability.extra.amount
		end

		card.ability.extra.amount = 1
	end
end

local bunc_crop_circles = SMODS.Centers['j_bunc_crop_circles'] or {}

local crop_circles_rank_mult = {
	['unstb_0'] = 1,
	['unstb_0.5'] = 1,
	['6'] = 1,
	['8'] = 2,
	['9'] = 1,
	['10'] = 1,
	['Queen'] = 1,
}

--Implemented differently than in Bunco, but should yield the same result
bunc_crop_circles.calculate = function(self, card, context)
	if context.individual and context.cardarea == G.play then
		local other_card = context.other_card
		local total_mult = 0
		
		--Check suit
		if not other_card.config.center.no_suit then
			if other_card.base.suit == 'bunc_Fleurons' then
				total_mult = total_mult + 4
			elseif other_card.base.suit == 'Clubs' then
				total_mult = total_mult + 3
			end			
		end
		
		--Check rank
		if not other_card.config.center.no_rank then
			if crop_circles_rank_mult[other_card.base.value] then
				total_mult = total_mult + crop_circles_rank_mult[other_card.base.value]
			end
		end
		
		--If the amount is greater than 0, grant the bonus w/ animation
		if total_mult > 0 then
			return {
				mult = total_mult,
				card = card
            }
		end
	end
end

end


--Hook to Familiar's set_sprite_suits to account for new ranks
local unstb_ranks_pos = {['unstb_0'] = 6,
						['unstb_0.5'] = 2,
						['unstb_1'] = 5,
						['unstb_r2'] = 7,
						['unstb_e'] = 3,
						['unstb_Pi'] = 4,
						['unstb_21'] = 0,
						['unstb_???'] = 1}

if check_mod_active("Familiar") then

print('Inject Familiar set_sprite_suits')

local ref_set_sprite_suits = set_sprite_suits

function set_sprite_suits(card, juice)
	ref_set_sprite_suits(card, juice)
	
	--If the rank is one of the UnStable Rank, and has one of the ability
	if unstb_ranks_pos[card.base.value] and (card.ability.is_spade or card.ability.is_heart or card.ability.is_club or card.ability.is_diamond or card.ability.suitless) then
		print('UnstbEX Set Sprite Suit Hook Active')
	
		local suit_check = {card.base.suit == 'Spades' or card.ability.is_spade or false,
							card.base.suit == 'Hearts' or card.ability.is_heart or false,
							card.base.suit == 'Clubs' or card.ability.is_club or false,
							card.base.suit == 'Diamonds' or card.ability.is_diamond or false}
							
		local suit_count = 0
		for i=1, #suit_check do
			if suit_check[i] then
				suit_count = suit_count+1
			end
		end
		
		--Suitless, or has more than 1 suits
		if card.ability.suitless or suit_count>1 then
			--Technically, if anyone wants to make it works properly, this would be where to check
			--Unfortunately, I don't think I can write them all because there's a lot of combination + lots of graphic to make
			--Hopefully there is a more elegant solution found in the future.
		
			card.children.front.atlas = G.ASSET_ATLAS['unstbex_rank_ex_multi']
			card.children.front:set_sprite_pos({x = unstb_ranks_pos[card.base.value], y = 0})
		end
		
	end
end

print("Inject Familiar Vigor Fortune Card")

local familiar_vigor = SMODS.Centers['c_fam_vigor'] or {}

--Reimplemented Familiar Vigor Fortune Card to use get_next_x_rank instead
familiar_vigor.use = function(self, card)
	for i = 1, #G.hand.highlighted do
		for j = 1, 3 do
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
				local card = G.hand.highlighted[i]
				local new_rank = get_next_x_rank(card.base.value, 1)
				assert(SMODS.change_base(card, nil, new_rank))
				card:juice_up(0.3, 0.5)
			return true end }))
		end
	end  
end
	
end


--Re-implementation of Ortalab's Index Card functions to support UNSTB Ranks

--Notice: this rank changes the behavior from vanilla slightly, where rank 0 and 1 is immediately available
local main_rankList = {'unstb_0', 'unstb_1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}

--Special UNSTB Rank is pre-defined
local rankMap = { 	['unstb_0.5'] = {UP = 'unstb_1', MID = 'unstb_0.5' , DOWN = 'unstb_0'},
					['unstb_r2'] = {UP = '2', MID = 'unstb_r2' , DOWN = 'unstb_1'},
					unstb_e = {UP = '3', MID = 'unstb_e' , DOWN = '2'},
					unstb_Pi = {UP = '4', MID = 'unstb_Pi' , DOWN = '3'},
					unstb_21 = {UP = 'unstb_21', MID = 'unstb_21' , DOWN = 'unstb_21'},
					['unstb_???'] = {UP = 'unstb_???', MID = 'unstb_???' , DOWN = 'unstb_???'},
}

for i=1, #main_rankList do
	rankMap[main_rankList[i]] = {UP = main_rankList[i+1] or main_rankList[1], MID = main_rankList[i], DOWN = main_rankList[i-1] or main_rankList[#main_rankList]}
end

--print(inspectDepth(rankMap))

if check_mod_active("Ortalab") then

print('Inject Ortalab Index Card')

--Inject new property into Ortalab index card
local ortalab_index = SMODS.Centers['m_ortalab_index'] or {}

ortalab_index.set_ability = function(self, card, initial, delay_sprites)
		print('call set ability')

		if card.base and card.ability and card.ability.extra and type(card.ability.extra) == 'table' then
			if card.ability.extra.index_state == 'MID' then
				card.ability.extra.mainrank = card.base.value
            elseif card.ability.extra.index_state == 'UP' then
				card.ability.extra.mainrank = rankMap[card.base.value]['DOWN']
            elseif card.ability.extra.index_state == 'DOWN' then
				card.ability.extra.mainrank = rankMap[card.base.value]['UP']
			end
		end
    end

ortalab_index.set_sprites = function(self, card, front)
        if card.ability and card.ability.extra and type(card.ability.extra) == 'table' then 
			
            if card.ability.extra.index_state == 'MID' then
				card.children.center:set_sprite_pos({x = 2, y = 0}) 
            elseif card.ability.extra.index_state == 'UP' then
				--card.ability.extra.mainrank = rankMap[card.base.value]['DOWN']
				card.children.center:set_sprite_pos({x = 1, y = 2}) 
            elseif card.ability.extra.index_state == 'DOWN' then
				card.children.center:set_sprite_pos({x = 0, y = 2})
			end
			
			--print('main card value is '.. card.ability.extra.mainrank)
        end
end

ortalab_index.update = function(self, card)
		--Jank, handles special case where Tarot like Strength was used
		if (card.VT.w <= 0) then
			local isCollection = (card.area and card.area.config.collection) or false
		
			if not isCollection then
				if card.ability.extra.index_state == 'MID' then
					card.ability.extra.mainrank = card.base.value
				elseif card.ability.extra.index_state == 'UP' then
					card.ability.extra.mainrank = rankMap[card.base.value]['DOWN']
				elseif card.ability.extra.index_state == 'DOWN' then
					card.ability.extra.mainrank = rankMap[card.base.value]['UP']
				end
			end
			
			--print('main card value changed to '.. card.ability.extra.mainrank)
		end
    end

G.FUNCS.increase_index = function(e, mute, nosave)
	--print('using unstbex implementation of func')

    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local change = 1
    if card.ability.extra.index_state == 'DOWN' then change = 2 end
    card.ability.extra.index_state = 'UP'
    card.children.center:set_sprite_pos({x = 1, y = 2})
	
    SMODS.change_base(card, nil, rankMap[card.ability.extra.mainrank] and rankMap[card.ability.extra.mainrank]['UP'] or 'unstb_???')
end

G.FUNCS.mid_index = function(e, mute, nosave)
	--print('using unstbex implementation of func')

    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local change = 1
    if card.ability.extra.index_state == 'UP' then change = -1 end
    card.ability.extra.index_state = 'MID'
    card.children.center:set_sprite_pos({x = 2, y = 0})
    --card.base.id = card.base.id + change
    SMODS.change_base(card, nil, rankMap[card.ability.extra.mainrank] and rankMap[card.ability.extra.mainrank]['MID'] or 'unstb_???')
end

G.FUNCS.decrease_index = function(e, mute, nosave)
	--print('using unstbex implementation of func')

    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local change = 1
    if card.ability.extra.index_state == 'UP' then change = 2 end
    card.ability.extra.index_state = 'DOWN'
    card.children.center:set_sprite_pos({x = 0, y = 2}) 
    --card.base.id = card.base.id - change
	
    SMODS.change_base(card, nil, rankMap[card.ability.extra.mainrank] and rankMap[card.ability.extra.mainrank]['DOWN'] or 'unstb_???')
end

--More safety check
--[[
G.FUNCS.index_card_increase = function(e)
	
	if not e.config.ref_table.ability.extra or type(e.config.ref_table.ability.extra) ~= 'table' then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		
		return
	end
	
    if e.config.ref_table.ability.extra.index_state ~= 'UP' then 
        e.config.colour = G.C.RED
        e.config.button = 'increase_index'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.index_card_mid = function(e)
	if not e.config.ref_table.ability.extra or type(e.config.ref_table.ability.extra) ~= 'table' then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		return
	end
	
    if e.config.ref_table.ability.extra.index_state ~= 'MID' then 
        e.config.colour = G.C.RED
        e.config.button = 'mid_index'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.index_card_decrease = function(e)
	if not e.config.ref_table.ability.extra or type(e.config.ref_table.ability.extra) ~= 'table' then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		
		return
	end
	
    if e.config.ref_table.ability.extra.index_state ~= 'DOWN' then 
        e.config.colour = G.C.RED
        e.config.button = 'decrease_index'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end]]

print("Inject Ortalab Flag Loteria")

local ortalab_lot_flag = SMODS.Centers['c_ortalab_lot_flag'] or {}

--Reimplementation to use UnStable version of get_next_x_rank
ortalab_lot_flag.use = function(self, card, area, copier)
	--print("UnStbEX version")

	track_usage(card.config.center.set, card.config.center_key)
	local options = {}
	for i=1, card.ability.extra.rank_change do
		table.insert(options, i)
	end
	for i=1, #G.hand.highlighted do
		local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
	end
	for _, card in pairs(G.hand.highlighted) do
		local sign = pseudorandom(pseudoseed('flag_sign')) > 0.5 and 1 or -1
		local change = pseudorandom_element(options, pseudoseed('flag_change'))
		for i=1, change do
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.4,func = function()	
				local new_rank = get_next_x_rank(card.base.value, sign)
				assert(SMODS.change_base(card, nil, new_rank))
			return true end }))
		end
		-- card_eval_status_text(card, 'extra', nil, nil, nil, {message = tostring(sign*change), colour = G.ARGS.LOC_COLOURS.loteria, delay = 0.4})
	end
	for i=1, #G.hand.highlighted do
		local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
	end
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
	delay(0.5)
end

end

--Cryptid Compat

if check_mod_active("Cryptid") then
--Add appropiate Jokers to the pool

--Placeholder, there's no food jokers yet in UNSTB and/or EX
--[[
if Cryptid.food then
	local food_jokers = {
	
	}
	
	for i = 1, #meme_jokers do
	  Cryptid.food[#Cryptid.food+1] = food_jokers[i]
	end
end]]

if Cryptid.memepack then
	--Adds pretty much most shitpost-centric Joker onto it
	local meme_jokers = {
		"j_unstb_joker2", --Joker 2
		"j_unstb_joker_stairs", --Joker Stairs
		"j_unstb_plagiarism", --Plagiarism
		"j_unstb_prssj", --prssj
		"j_unstb_the_jolly_joker", --The Jolly too just because
		"j_unstb_what", --69, 420. Unsure if this would break the in_pool tho
	}
	
	for i = 1, #meme_jokers do
	  Cryptid.memepack[#Cryptid.memepack+1] = meme_jokers[i]
	end
end

end

--Hook for the game's splash screen, to initialize any data that is sensitive to the mod's order (mainly rank stuff)

local ref_gamesplashscreen = Game.splash_screen

function Game:splash_screen()
 	ref_gamesplashscreen(self)
	
	--Cryptid stuff has to be done on Splash Screen because of its high priority
	if check_mod_active("Cryptid") then
		print("Inject new nominal code override for Cryptid")
		
		--Make a dedicated table of rank id and the nominal order
		--This is because Cryptid randomize nominal chips in Misprint Deck and Glitched Edition
		
		local rank_nominal_order = {}
		
		for key, rank in pairs(SMODS.Ranks) do
			rank_nominal_order[key] = rank.nominal
		end
		
		--Override 
		
		local ref_card_set_base = Card.set_base
		
		--Basically the same code from the basegame, but swap nominal out with the new rank_nominal_order property
		function Card:get_nominal(mod)
			local mult = 1
			local rank_mult = 1
			if mod == 'suit' then mult = 30000 end
			if self.ability.effect == 'Stone Card' or (self.config.center.no_suit and self.config.center.no_rank) then 
				mult = -10000
			elseif self.config.center.no_suit then
				mult = 0
			elseif self.config.center.no_rank then
				rank_mult = 0
			end
			--Temporary fix so the card with the lowest nominal can still be sorted properly
			local nominal = rank_nominal_order[self.base.value] or 0
			
			if self.base.value == 'unstb_???' then
				nominal = 0.3
			elseif nominal < 0.4 then
				nominal = 0.31 + nominal*0.1
			end
			return 10*(nominal)*rank_mult + self.base.suit_nominal*mult + (self.base.suit_nominal_original or 0)*0.0001*mult + 10*self.base.face_nominal*rank_mult + 0.000001*self.unique_val
		end
		
		--Secret interaction: The "Jolly Joker" (UnStable Joker) counts as Jolly as well
		local ref_card_is_jolly = Card.is_jolly
		function Card:is_jolly()
			if self.config.center.key == 'j_unstb_the_jolly_joker' then
				return true
			end
			
			return ref_card_is_jolly(self)
		end
		
		--Inject Blinds effect
		
		print("Inject Blind effects for Cryptid")
		
		local blind_hammer = SMODS.Blinds['bl_cry_hammer'] or {}
		
		blind_hammer.recalc_debuff = function(self, card, from_blind)
			if card.area ~= G.jokers and not G.GAME.blind.disabled then
				if
					card.ability.effect ~= "Stone Card"
					and (
						card.base.value == "3"
						or card.base.value == "5"
						or card.base.value == "7"
						or card.base.value == "9"
						or card.base.value == "Ace"
						or card.base.value == "unstb_1"
						or card.base.value == "unstb_21"
						or card.base.value == "unstb_???"
					)
				then
					return true
				end
				return false
			end
		end
		
		local blind_magic = SMODS.Blinds['bl_cry_magic'] or {}
		
		blind_magic.recalc_debuff = function(self, card, from_blind)
			if card.area ~= G.jokers and not G.GAME.blind.disabled then
				if
					card.ability.effect ~= "Stone Card"
					and (
						card.base.value == "2"
						or card.base.value == "4"
						or card.base.value == "6"
						or card.base.value == "8"
						or card.base.value == "10"
						or card.base.value == "unstb_0"
						or card.base.value == "unstb_???"
					)
				then
					return true
				end
				return false
			end
		end
	
		--Override ://VARIABLE Code card's code
		--Because the original code has problem with the card with modded rank
		--Also, switch over to SMODS.change_base instead of manually building card key,
		--which was the cause of the problem
		
		unstbex_global.cryptid_variable_rank = {'', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace', '', '', '', 'unstb_0', 'unstb_21', 'unstb_0.5', 'unstb_r2', 'unstb_e', 'unstb_Pi', 'unstb_1', 'unstb_???'}
		
		G.FUNCS.variable_apply = function()
			local rank_table = {
				{},
				{ "2", "Two", "II" },
				{ "3", "Three", "III" },
				{ "4", "Four", "IV" },
				{ "5", "Five", "V" },
				{ "6", "Six", "VI" },
				{ "7", "Seven", "VII" },
				{ "8", "Eight", "VIII" },
				{ "9", "Nine", "IX" },
				{ "10", "1O", "Ten", "X", "T" },
				{ "J", "Jack" },
				{ "Q", "Queen" },
				{ "K", "King" },
				{ "A", "Ace"}, --Notably, 1 is now 1 and not Ace :P
				{ "M" },
				{ "nil" },
				{}, --Not sure if I should left it blank but its used for a cheat check below??
				
				--UNSTB Rank
				{"0", "O", "Zero"},
				{"21", "Twenty-One", "TwentyOne", "XXI", "BJ"},
				{"0.5", "O.5", "Half"},
				{"1.4", "1.41", "Root2", "Sqrt2", "Root", "Sqrt", "r", "sq"},
				{"2.7", "2.71","e", "Euler"},
				{"3.1", "3.14", "22/7", "Pi", "P"},
				{"1", "One", "1", "I"},
				{"?", "???", "Question", "idk"},
			}

			local rank_suffix = nil

			for i, v in pairs(rank_table) do
				for j, k in pairs(v) do
					if string.lower(G.ENTERED_RANK) == string.lower(k) then
						rank_suffix = i
					end
				end
			end

			if rank_suffix then
				G.PREVIOUS_ENTERED_RANK = G.ENTERED_RANK
				G.GAME.USING_CODE = false
				if rank_suffix == 15 then
					check_for_unlock({ type = "cheat_used" })
					local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_jolly")
					card:add_to_deck()
					G.jokers:emplace(card)
				elseif rank_suffix == 16 then
					check_for_unlock({ type = "cheat_used" })
					local card = create_card("Code", G.consumeables, nil, nil, nil, nil, "c_cry_crash")
					card:add_to_deck()
					G.consumeables:emplace(card)
				elseif rank_suffix == 17 then
					check_for_unlock({ type = "cheat_used" })
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.4,
						func = function()
							play_sound("tarot1")
							return true
						end,
					}))
					for i = 1, #G.hand.highlighted do
						local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.15,
							func = function()
								G.hand.highlighted[i]:flip()
								play_sound("card1", percent)
								G.hand.highlighted[i]:juice_up(0.3, 0.3)
								return true
							end,
						}))
					end
					delay(0.2)
					for i = 1, #G.hand.highlighted do
						local CARD = G.hand.highlighted[i]
						local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.15,
							func = function()
								CARD:flip()
								CARD:set_ability(
									G.P_CENTERS[pseudorandom_element(G.P_CENTER_POOLS.Consumeables, pseudoseed("cry_variable")).key],
									true,
									nil
								)
								play_sound("tarot2", percent)
								CARD:juice_up(0.3, 0.3)
								return true
							end,
						}))
					end
				else
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.4,
						func = function()
							play_sound("tarot1")
							return true
						end,
					}))
					for i = 1, #G.hand.highlighted do
						local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.15,
							func = function()
								G.hand.highlighted[i]:flip()
								play_sound("card1", percent)
								G.hand.highlighted[i]:juice_up(0.3, 0.3)
								return true
							end,
						}))
					end
					delay(0.2)
					for i = 1, #G.hand.highlighted do
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.1,
							func = function()
								local card = G.hand.highlighted[i]								
								local new_rank = unstbex_global.cryptid_variable_rank[rank_suffix]
								
								--Fallback
								if not new_rank or new_rank == '' then
									new_rank = 'unstb_???'
								end
								
								SMODS.change_base(card, nil, new_rank)
								return true
							end,
						}))
					end
					for i = 1, #G.hand.highlighted do
						local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.15,
							func = function()
								G.hand.highlighted[i]:flip()
								play_sound("tarot2", percent, 0.6)
								G.hand.highlighted[i]:juice_up(0.3, 0.3)
								return true
							end,
						}))
					end
					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.2,
						func = function()
							G.hand:unhighlight_all()
							return true
						end,
					}))
					delay(0.5)
				end
				G.CHOOSE_RANK:remove()
			end
		end
	
	end
end