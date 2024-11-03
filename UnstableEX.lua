--- STEAMODDED HEADER
--- MOD_NAME: UnStableEX
--- MOD_ID: UNSTBEX
--- MOD_AUTHOR: [Kirbio, Ram]
--- MOD_DESCRIPTION: Add-on for the UnStable mod to extend the support to other mods
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- BADGE_COLOR: 41c300
--- PRIORITY: 99999
--- PREFIX: unstbex
----------------------------------------------
------------MOD CODE -------------------------

local unStbEX = SMODS.current_mod
local filesystem = NFS or love.filesystem
local path = unStbEX.path

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

----------------------------------------------
------------MOD CODE END----------------------
