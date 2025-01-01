local unstbex = SMODS.current_mod
local filesystem = NFS or love.filesystem
local path = unstbex.path

--Localization Messages
--local loc = filesystem.load(path..'localization.lua')()

-- Debug message

local function print(message)
    sendDebugMessage('[UnstableEX] - '..(tostring(message) or '???'))
end

print("Starting UnstableEX")

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
  path = "rank_ex.png",
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
if (SMODS.Mods["Bunco"] or {}).can_load then

print("Inject Bunco Jokers")

local bunc_pawn = SMODS.Centers['j_bunc_pawn']

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

local bunc_zero_shapiro = SMODS.Centers['j_bunc_zero_shapiro']

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

local bunc_crop_circles = SMODS.Centers['j_bunc_crop_circles']

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

if (SMODS.Mods["familiar"] or {}).can_load then

print('Inject Familiar set_sprite_suits')

local ref_set_sprite_suits = set_sprite_suits

function set_sprite_suits(card, juice)
	ref_set_sprite_suits(card, juice)
	
	--If the rank is one of the UnStable Rank, and has one of the ability
	if unstb_ranks_pos[card.base.value] and (card.ability.is_spade or card.ability.is_heart or card.ability.is_club or card.ability.is_diamond or card.ability.suitless) then
		print('UnstbEX Set Sprite Suit Hook Active')
	
		local suit_check = {card.base.suit == 'Spades' or card.ability.is_spade,
							card.base.suit == 'Hearts' or card.ability.is_heart,
							card.base.suit == 'Clubs' or card.ability.is_club,
							card.base.suit == 'Diamonds' or card.ability.is_diamond}
							
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

local familiar_vigor = SMODS.Centers['c_fam_vigor']

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

if (SMODS.Mods["ortalab"] or {}).can_load then

print('Inject Ortalab Index Card')

--Inject new property into Ortalab index card
local ortalab_index = SMODS.Centers['m_ortalab_index']

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

local ortalab_lot_flag = SMODS.Centers['c_ortalab_lot_flag']

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