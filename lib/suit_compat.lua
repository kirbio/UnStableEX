--Utility to auto-generate atlas and metadata
--mod_suffix: the folder name inside "rank_ex" folder, also used to append the rank atlas key
--lc_only: if true, high contrast atlas is set to be the same as lc atlas
function unstbex_lib.init_suit_compat(suit, mod_suffix, lc_only)

SMODS.Atlas {
  key = "rank_ex_"..mod_suffix,
  path = "rank_ex/"..mod_suffix.."/rank_ex.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "rank_ex2_"..mod_suffix,
  path = "rank_ex/"..mod_suffix.."/rank_ex2.png",
  px = 71,
  py = 95
}

if not lc_only then
	SMODS.Atlas {
	  key = "rank_ex_hc_"..mod_suffix,
	  path = "rank_ex/"..mod_suffix.."/rank_ex_hc.png",
	  px = 71,
	  py = 95
	}

	SMODS.Atlas {
	  key = "rank_ex2_hc_"..mod_suffix,
	  path = "rank_ex/"..mod_suffix.."/rank_ex2_hc.png",
	  px = 71,
	  py = 95
	}
end

unstbex_lib.extra_suits[suit] = {modname = mod_suffix,
	lc_atlas = {"unstbex_rank_ex_"..mod_suffix, "unstbex_rank_ex2_"..mod_suffix},
	hc_atlas = {(lc_only and "unstbex_rank_ex_" or "unstbex_rank_ex_hc_")..mod_suffix, (lc_only and "unstbex_rank_ex2_" or "unstbex_rank_ex2_hc_")..mod_suffix}}

end