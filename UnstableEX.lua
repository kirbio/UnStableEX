--- STEAMODDED HEADER
--- MOD_NAME: UnStableEX
--- MOD_ID: UNSTBEX
--- MOD_AUTHOR: [Kirbio, RamChops Games]
--- MOD_DESCRIPTION: Add-on for the UnStable mod to extend the support to other mods
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- BADGE_COLOR: 41c300
--- PRIORITY: 99999
--- PREFIX: unstbex
----------------------------------------------
------------MOD CODE -------------------------

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

-- Index-based coordinates generation

local function get_coordinates(position, width)
    if width == nil then width = 10 end -- 10 is default for Jokers
    return {x = (position) % width, y = math.floor((position) / width)}
end

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

--Inject new property into Ortalab index card
if (SMODS.Mods["ortalab"] or {}).can_load then

print('Inject Ortalab Index Card')

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

end

----------------------------------------------
------------MOD CODE END----------------------
