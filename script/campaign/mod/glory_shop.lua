local pttg = core:get_static_object("pttg");

local pttg_glory_shop = {
    shop_items = {
        merchandise = { {}, {}, {}, {} },
        -- units = { {}, {}, {} }
    },
    active_shop_items = {
    },
    excluded_shop_items = {
    }
}

function pttg_glory_shop:add_ritual(ritual, info)
    pttg:log(string.format('[pttg_glory_shop] Adding ritual: %s (%s, %s, %s)',
            ritual,
            tostring(info.uniqueness),
            tostring(info.category),
            tostring(info.faction_set)
        )
    )
    local crafting_group = "merchandise"
    if info.category == 'unit' then
        crafting_group = 'units'
    end
    local tier = self:item_tier(info.uniqueness)
    if self.shop_items[crafting_group][tier][info.faction_set] then
        table.insert(self.shop_items[crafting_group][tier][info.faction_set], ritual)
    else
        self.shop_items[crafting_group][tier][info.faction_set] = {ritual}
    end
end

function pttg_glory_shop:add_rituals(rituals)
    for ritual, info in pairs(rituals) do
        self:add_ritual(ritual, info)
    end
end

function pttg_glory_shop:reset_rituals()
    local rituals = {}
    for ritual, _ in pairs(self.active_shop_items) do
        table.insert(rituals, ritual)
    end
    pttg_glory_shop:lock_rituals(rituals)
    self.active_shop_items = {}
end

function pttg_glory_shop:unlock_ritual(ritual)
    pttg:log(string.format('[pttg_glory_shop]Unlocking ritual %s', ritual))
    local faction = cm:get_local_faction()

    cm:unlock_ritual(faction, ritual, 1)
    self.active_shop_items[ritual] = true
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:unlock_rituals(rituals)
    local faction = cm:get_local_faction()
    for _, ritual in pairs(rituals) do
        pttg:log(string.format('[pttg_glory_shop]Unlocking ritual %s', tostring(rituals)))
        cm:unlock_ritual(faction, ritual, 1)
        self.active_shop_items[rituals] = true
    end
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:lock_rituals(rituals)
    pttg:log(string.format('[pttg_glory_shop]Locking ritual %s', tostring(rituals)))
    local faction = cm:get_local_faction()
    for _, ritual in pairs(rituals) do
        cm:lock_ritual(faction, ritual)
        self.active_shop_items[rituals] = false
    end
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:lock_ritual(ritual)
    pttg:log(string.format('[pttg_glory_shop]Locking ritual %s', ritual))
    local faction = cm:get_local_faction()

    cm:lock_ritual(faction, ritual)
    self.active_shop_items[ritual] = false
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:item_tier(uniqueness)
    -- wh2_dlc17_anc_group_rune	150	150
    -- wh_main_anc_group_crafted	199	199

    if uniqueness < 30 then -- wh_main_anc_group_common	29	0
        return 1
    elseif uniqueness < 50 then -- wh_main_anc_group_uncommon	49	30
        return 2
    elseif uniqueness < 100 then -- wh_main_anc_group_rare	100	50
        return 3
    else -- wh_main_anc_group_unique	200	200
        return 4
    end

end

function pttg_glory_shop:init_shop()
    local shop_sizes = pttg:get_state('shop_sizes')

    pttg:log(string.format('[pttg_glory_shop] Initialising shop with(merch: %i, units:%i)',
            shop_sizes.merchandise,
            shop_sizes.units)
    )

    local items_all = { ["pttg_ritual_wh2_dlc10_dwf_anc_armour_gate_keepers_helm"] = { ["uniqueness"] = 75,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_weapon_warrior_bane"] = { ["uniqueness"] = 5,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_dragon_cuirass_4"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_balalaika_of_the_arari"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh3_main_anc_armour_shield_of_sacrifice"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_carnosaur_pendant"] = { ["uniqueness"] = 20,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_main_anc_talisman_amber_amulet"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_talisman_talisman_of_saphery"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_armour_boots_of_bracchus"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_the_tricksters_pendant"] = { ["uniqueness"] = 30,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_talisman_opal_amulet"] = { ["uniqueness"] = 15,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_veterans_bracers"] = { ["uniqueness"] = 15,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc03_anc_mark_of_chaos_uncanny_senses"] = { ["uniqueness"] = 10,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_serene_cloud_prayer_flag"] = { ["uniqueness"] = 30,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_weapon_dagger_of_sotek"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_dlc03_anc_magic_standard_totem_of_rust"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_golden_dagger"] = { ["uniqueness"] = 10,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc20_anc_weapon_rapier_of_ecstasy"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_boatswain"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh3_main_anc_weapon_firestorm_blade"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh_main_anc_magic_standard_standard_of_discipline"] = { ["uniqueness"] = 15,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_cleansing_water"] = { ["uniqueness"] = 65,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_magic_standard_banner_of_the_barrows"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_counts",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_eagle_quiver_2"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_stromni_redbeard"] = { ["uniqueness"] = 75,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_radiant_gem_of_hoeth"] = { ["uniqueness"] = 20,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_enchanted_lapis_mace"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_talisman_luckstone"] = { ["uniqueness"] = 5,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc23_anc_enchanted_item_gauntlets_of_bazherak_the_cruel"] = { ["uniqueness"] = 100,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_talisman_ring_of_hotek"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_warpforged_blade"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_dlc23_anc_enchanted_item_major_relic_of_valaya"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc23_anc_weapon_dark_mace"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_hydra_banner"] = { ["uniqueness"] = 80,["category"] = "general",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_crown_of_command"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc17_anc_armour_cloak_of_unreality"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc23_anc_armour_armour_of_bazherak_the_cruel"] = { ["uniqueness"] = 100,["category"] = "armour",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_bull_standard"] = { ["uniqueness"] = 5,["category"] = "general",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh3_main_anc_weapon_siegebreaker"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh3_main_anc_weapon_torment_blade"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_dlc11_anc_weapon_masamune"] = { ["uniqueness"] = 90,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_rune_maw"] = { ["uniqueness"] = 60,["category"] = "general",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_miners_pickaxe"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_dlc20_anc_weapon_aether_sword"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_the_jaguar_standard"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_dlc24_anc_armour_scavenged_laboratory_materials"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh3_main_anc_armour_wyrm_harness"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh_dlc08_anc_enchanted_item_vial_of_troll_blood"] = { ["uniqueness"] = 100,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_main_anc_weapon_web_of_shadows"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_void_pendulum"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_itxi_grubs"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_engineering_rune_of_penetration"] = { ["uniqueness"] = 10,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc03_anc_arcane_item_jagged_dagger"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_starwood_staff"] = { ["uniqueness"] = 40,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_dlc24_anc_armour_unknown_champions_cloak"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh3_prologue_anc_enchanted_item_saint_annushkas_finger_bone"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_sc_pro_kislev",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_banner_of_verminous_scurrying"] = { ["uniqueness"] = 10,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_magic_standard_wailing_banner"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc15_anc_arcane_item_blacktoofs_head_in_a_jar"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_greenskins",}
    ,["pttg_ritual_wh3_main_anc_weapon_blade_of_blood"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_multi_khorne_daemons",}
    ,["pttg_ritual_wh2_dlc12_anc_talisman_warp_field_generator"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_sanctuary"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_ruby_ring_of_ruin"] = { ["uniqueness"] = 25,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_the_seerstaff_of_saphery"] = { ["uniqueness"] = 30,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc09_anc_armour_armour_of_the_ages"] = { ["uniqueness"] = 40,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_diadem_of_power"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_warpstorm_scroll"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_rod_of_command"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_daemons_slaanesh",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_ring_of_hukon"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_arcane_item_lucky_shrunken_head"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_greenskins",}
    ,["pttg_ritual_wh2_dlc09_anc_armour_armour_shield_of_ptra"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_armour_great_bear_pelt"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh3_main_anc_caravan_gryphon_legion_lance"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_armour_the_maiming_shield"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_main_anc_arcane_item_tricksters_shard"] = { ["uniqueness"] = 30,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh3_dlc23_anc_armour_armour_of_the_forge"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_healing_potion"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_twilight_spear_1"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_talisman_loremasters_cloak"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_eagle_vambraces_1"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_rune_rune_of_might"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_weapon_chillblade"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_warp_energy_condenser"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_magic_standard_spider_banner"] = { ["uniqueness"] = 85,["category"] = "general",["faction_set"] = "anc_set_exclusive_sc_greenskins",}
    ,["pttg_ritual_wh_main_anc_weapon_red_axe_of_karak_eight_peaks"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_armour_armour_of_caledor"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_standard_of_nan_gau"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_witstealer_sword"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_engineering_master_rune_of_disguise"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_dwarf_hide_banner"] = { ["uniqueness"] = 15,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_chalice_of_chaos"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_beastmen_chaos",}
    ,["pttg_ritual_wh3_dlc24_anc_item_divining_rod"] = { ["uniqueness"] = 30,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_armour_quicksilver_armour"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_weapon_giant_blade"] = { ["uniqueness"] = 60,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_pendant_of_slaanesh"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_beastmen_chaos",}
    ,["pttg_ritual_wh_main_anc_armour_armour_of_fortune"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_mirror_of_the_ice_queen"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_jade_lion"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_engineering_flakksons_rune_of_seeking"] = { ["uniqueness"] = 10,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_destroyer_of_eternities"] = { ["uniqueness"] = 80,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_totem_pole_of_destiny"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_armour_frost_shard_armour"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh_main_anc_rune_rune_of_striking"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc08_anc_talisman_slave_chain"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_twilight_spear_2"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_weapon_the_mace_of_helsturm"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_multi_kislev_empire",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_ancestor_rune_of_valaya"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_talisman_emerald_collar"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_weapon_dazhs_brazier"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_dragon_spear_2"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_dreaming_bow_4"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_rune_of_luck"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_dlc20_anc_arcane_item_rod_of_torment"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_rock_eye"] = { ["uniqueness"] = 5,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_potion_of_speed"] = { ["uniqueness"] = 5,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_armour_helm_of_khaine"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_weeping_blade"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_darkstar_cloak"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_prologue_anc_armour_frost_shard_armour"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_sc_pro_kislev",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_ironbeards_armour"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_axe_of_men"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc09_anc_armour_armour_armour_of_dawn"] = { ["uniqueness"] = 60,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_snowflake_pendant"] = { ["uniqueness"] = 35,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_praag"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_dragon_slayers_boots"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_ironbeards_ring"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_armour_shield_of_ptolos"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_ragbanner"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc12_anc_weapon_retractable_fistblade"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc09_anc_armour_armour_mortuary_robes"] = { ["uniqueness"] = 10,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_armour_armour_of_darkness"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc15_anc_talisman_sun_dragon_special"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc09_anc_arcane_item_enkhils_kanopi"] = { ["uniqueness"] = 75,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh3_main_anc_weapon_silver_moon_bow"] = { ["uniqueness"] = 55,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_dragon_spear_3"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_incendiary_rounds"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_dlc24_anc_enchanted_item_book_of_secrets"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_inscribed_khopesh"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_armour_shield_of_the_nan_gau"] = { ["uniqueness"] = 70,["category"] = "armour",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_armour_glittering_scales"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_armour_shield_of_distraction"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_talisman_obsidian_amulet"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc07_anc_magic_standard_twilight_banner"] = { ["uniqueness"] = 15,["category"] = "general",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_slayers_ring"] = { ["uniqueness"] = 15,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc08_anc_magic_standard_crimson_reapers"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh_dlc03_anc_mark_of_chaos_many_limbed_fiend"] = { ["uniqueness"] = 20,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_prologue_anc_talisman_blizzard_broach"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_sc_pro_kislev",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_twilight_horn_4"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_eagle_vambraces_3"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_sign_of_the_coiled_one"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_main_anc_weapon_gold_sigil_sword"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_maw_shard"] = { ["uniqueness"] = 30,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_arcane_item_power_stone"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_armour_shield_of_ghrond"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_main_anc_talisman_seed_of_rebirth"] = { ["uniqueness"] = 10,["category"] = "talisman",["faction_set"] = "anc_set_multi_kislev_bretonnia_dwarfs_empire_greenskins",}
    ,["pttg_ritual_wh3_main_anc_weapon_etherblade"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_main_anc_armour_rocket_boots"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_golden_deathmask_of_kharnut"] = { ["uniqueness"] = 40,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_the_vortex_shard"] = { ["uniqueness"] = 75,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc17_anc_weapon_fell_axe_of_the_drakwald"] = { ["uniqueness"] = 10,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_armour_helm_of_many_eyes"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "anc_set_multi_beastmen_chaos",}
    ,["pttg_ritual_wh3_dlc20_anc_item_the_festering_shroud"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh2_dlc11_anc_armour_armour_of_the_depth"] = { ["uniqueness"] = 90,["category"] = "armour",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_eagle_bow_2"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_dlc03_anc_magic_standard_manbane_standard"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_dlc23_anc_weapon_lesser_relic_of_smednir"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_death_mask_of_kharnut"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc23_anc_talisman_lesser_relic_of_thungni"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_weapon_filth_mace"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_multi_beastmen_chaos",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_rune_of_shielding"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_armour_armour_of_destiny"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_weapon_ursuns_claws"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_main_anc_armour_hide_of_the_cold_ones"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_weapon_vorpal_shard"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_master_rune_of_gromril"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_weapon_blade_of_darting_steel"] = { ["uniqueness"] = 45,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_enchanted_item_furnace_blast_gem"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh_main_anc_magic_standard_banner_of_lost_holds"] = { ["uniqueness"] = 40,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_black_dragon_egg"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_armour_major_relic_of_grungni"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_fistful_of_laurels"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc17_anc_talisman_champions_essence"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc15_anc_weapon_moon_dragon_special"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc09_anc_armour_armour_helmet_of_khsar"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_prologue_anc_talisman_star_iron_ring"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_sc_pro_kislev",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_unholy_victory"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_hunting_spear"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc14_anc_weapon_malus_death_warpsword"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc15_anc_enchanted_item_star_dragon_special"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_blade_of_setep"] = { ["uniqueness"] = 45,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_rangers_brooch"] = { ["uniqueness"] = 15,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_skavenpelt_banner"] = { ["uniqueness"] = 65,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_alchemists_elixir_of_puissance"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc12_anc_armour_power_armour"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_pipes_of_piebald"] = { ["uniqueness"] = 25,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc14_anc_banner_rene_de_cartes"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_weapon_slaaneshs_blade"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_the_blood_banner"] = { ["uniqueness"] = 10,["category"] = "general",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_old_guards_armour"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc14_anc_banner_jean_claude_sartre"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_drakwald"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_rune_of_impact"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc13_anc_talisman_sylvania_journal"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_caravan_frozen_pendant"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_talisman_jewel_of_denial"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_daemons_slaanesh",}
    ,["pttg_ritual_wh2_main_anc_armour_chromatic_armour"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_weapon_the_middenland_runefang"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh_dlc08_anc_weapon_stinky_giant_club"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_weapon_ascendant_celestial_blade"] = { ["uniqueness"] = 60,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_the_rock_of_inevitability"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh_dlc08_anc_weapon_forest_dragon_fang"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_standard_of_the_empty_steppe"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_main_anc_armour_cloak_of_hag_graef"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_dlc08_anc_talisman_terrorgheist_skull"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_ostland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_change"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh_dlc08_anc_magic_standard_ancient_mammoth_cub"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh_dlc08_anc_enchanted_item_great_horn_of_dragon_ogre"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_rod_of_the_storm"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_dlc08_anc_enchanted_item_arachnarok_eggs"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh_dlc08_anc_enchanted_item_ancient_frost_wyrm_scale"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_main_anc_talisman_pearl_of_infinite_blackness"] = { ["uniqueness"] = 25,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_dragonhide_banner"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh_dlc07_anc_talisman_dragons_claw"] = { ["uniqueness"] = 20,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_main_anc_talisman_shadow_magnet_trinket"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_main_anc_armour_shield_of_the_merwyrm"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_caravan_warrant_of_trade"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_alchemists_mask"] = { ["uniqueness"] = 40,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_dlc03_anc_armour_blackened_plate"] = { ["uniqueness"] = 20,["category"] = "armour",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc09_anc_talisman_obsidian_pendant"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_weapon_sword_of_bloodshed"] = { ["uniqueness"] = 60,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_warpstone_tokens"] = { ["uniqueness"] = 15,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_dlc21_anc_rune_personal_master_rune_of_cleansing"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_talisman_sapphire_guardian_phoenix"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_caravan_statue_of_zharr"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_rune_rune_of_parrying"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_caravan_sky_titan_relic"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_caravan_luminark_lens"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_cathay_and_the_changeling",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_bangstick"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_shroud_of_sokth"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc09_anc_magic_standard_banner_of_the_hidden_dead"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_main_anc_weapon_mechanical_claw"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_dreaming_bow_2"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_talisman_obsidian_trinket"] = { ["uniqueness"] = 15,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_caravan_grant_of_land"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_ring_of_corin"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc10_anc_enchanted_item_extinguished_phoenix_pinion"] = { ["uniqueness"] = 60,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_banner_of_the_world_dragon"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_ironwardens_shield"] = { ["uniqueness"] = 75,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_caravan_frost_wyrm_skull"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc12_anc_enchanted_item_modulated_doomwheel_assembly_kit"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_main_anc_caravan_bejewelled_dagger"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc10_anc_arcane_item_scroll_of_fear_of_aramar"] = { ["uniqueness"] = 45,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_high_elves_kislev_norsca_chaos_empire",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_daemon_killer_scars"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_the_orthodoxy"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_sc_kislev",}
    ,["pttg_ritual_wh_dlc07_anc_armour_the_grail_shield"] = { ["uniqueness"] = 80,["category"] = "armour",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_tracer_rounds"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_trollslayer_axe"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_armour_shroud_of_death"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_arcane_item_staff_of_damnation"] = { ["uniqueness"] = 40,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_vampire_counts",}
    ,["pttg_ritual_wh2_main_anc_talisman_crown_of_black_iron"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_axes_of_khorgor"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc10_anc_arcane_item_scroll_of_speed_of_lykos"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_tomb_kings_vampire_coast_dark_elves_high_elves_kislev_empire_vampire_counts",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_dreaming_bow_1"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_war_drum_of_xahutec"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_crackleblaze"] = { ["uniqueness"] = 70,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_ironbeards_axe"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_dlc24_anc_talisman_undead_tome"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_cloak_of_po_mei"] = { ["uniqueness"] = 65,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_dlc24_anc_talisman_tree_sap"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh3_dlc24_anc_talisman_pilfered_palanquin"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_veterans_hammer"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_weapon_axe_of_tor"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh_main_anc_mark_of_chaos_mark_of_tzeentch"] = { ["uniqueness"] = 30,["category"] = "general",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh2_dlc09_anc_armour_armour_of_eternity"] = { ["uniqueness"] = 55,["category"] = "armour",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh3_dlc24_anc_talisman_hellforge_flame"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_van_horstmanns_speculum"] = { ["uniqueness"] = 40,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_kislev_empire",}
    ,["pttg_ritual_wh_main_anc_arcane_item_black_periapt"] = { ["uniqueness"] = 55,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_vampire_counts",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_veterans_armour"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_rune_of_fire"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_the_guiding_eye"] = { ["uniqueness"] = 25,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_dragon_pendant_3"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_dlc24_anc_arcane_item_ritual_of_the_beast"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_lore_of_beasts",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_grungni"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_divine_plaque_of_protection"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_main_anc_talisman_amulet_of_fire"] = { ["uniqueness"] = 20,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_armour_null_plate"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_main_anc_armour_armour_of_the_stars"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_talisman_star_iron_ring"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_main_anc_talisman_aura_of_quetzl"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_dlc24_anc_arcane_item_alchemical_notes"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh3_main_anc_talisman_tarnished_torque"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh3_main_anc_weapon_plague_flail"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_horn_of_isha"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_everchanging_shield"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_rubric_of_dark_dimensions"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_spiked_whip"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_fang_of_quaph"] = { ["uniqueness"] = 20,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_skavenbrew"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_ring_of_thorns"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_twilight_standard_3"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_weapon_skabscrath"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_vampire_counts",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_radiating_spike"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_dreaming_boots_1"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_arcane_item_book_of_arkhan"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_vampire_counts",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_stoicism"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_orc_shaman"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_dreaming_boots_4"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_dlc20_anc_item_armour_of_damnation"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh2_dlc09_anc_talisman_collar_of_shakkara"] = { ["uniqueness"] = 55,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc14_anc_enchanted_item_malus_warp_gem"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_talisman_foul_pendant"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_everlasting_glacier"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_weapon_thundermace"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_plaque_of_dominion"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc09_anc_talisman_amulet_of_pha_stah"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_eternal_servant"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_armour_helm_of_fortune"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_armour_worlds_edge_armour"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_crown_of_skulls"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_skullmantle"] = { ["uniqueness"] = 35,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_eagle_bow_3"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_weapon_sword_of_might"] = { ["uniqueness"] = 20,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_bones_of_the_maw"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_dragon_mask_1"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_dlc08_anc_armour_huskarl_plates"] = { ["uniqueness"] = 100,["category"] = "armour",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_master_rune_of_snorri_spangelhelm"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_totem_of_prophecy"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_master_rune_of_skalf_blackhammer"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_master_rune_of_passage"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_armour_dragonhelm"] = { ["uniqueness"] = 10,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc23_anc_enchanted_item_lesser_relic_of_morgrim"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_weapon_wyrmspike"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh3_dlc23_anc_arcane_item_dweomer_leach_orb"] = { ["uniqueness"] = 100,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_master_rune_of_adamant"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_armour_greatskull"] = { ["uniqueness"] = 5,["category"] = "armour",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc17_anc_armour_mutated_ghorgon_hide"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_master_rune_alaric_the_mad"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc03_anc_magic_standard_banner_of_outrage"] = { ["uniqueness"] = 20,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_ancestor_rune_of_grimnir"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_talisman_crystal_of_kunlan"] = { ["uniqueness"] = 55,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_engineering_master_rune_of_immolation"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_dragon_cuirass_2"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_double_crescent_of_neru"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_weapon_shrieking_blade"] = { ["uniqueness"] = 10,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_starbreaker"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_dreaming_bow_3"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_twilight_horn_3"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_weapon_ogre_blade"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_eagle_mask_3"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_dreaming_ring_3"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_warlock_augmented_weapon"] = { ["uniqueness"] = 45,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_main_anc_weapon_hydra_blade"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_dwarfbane"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_dragon_mask_3"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_dragon_slayers_axe"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_magic_standard_banner_of_rage"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_multi_beastmen_chaos",}
    ,["pttg_ritual_wh2_main_anc_talisman_glyph_necklace"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_wand_of_whimsey"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_eagle_quiver_3"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_blade_of_antarhak"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_dreaming_cloak_3"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_ouroboros"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc07_anc_armour_cuirass_of_fortune"] = { ["uniqueness"] = 10,["category"] = "armour",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_main_anc_armour_warpstone_armour"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_great_stag_helm"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_dreaming_boots_3"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_dragon_cuirass_3"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_totem_of_the_spitting_viper"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_dragon_slayers_scales"] = { ["uniqueness"] = 75,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_potion_of_strength"] = { ["uniqueness"] = 20,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc15_anc_arcane_item_black_dragon_special"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_whip_of_agony"] = { ["uniqueness"] = 25,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc14_anc_weapon_malus_dagger_of_souls"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_master_rune_of_flight"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_bloodstone"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_khorne_daemons",}
    ,["pttg_ritual_wh2_dlc14_anc_talisman_malus_amulet_of_defiance"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_mirror_blade"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_the_ankor_chain"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_prospectors_mail"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_wissenland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh3_dlc23_anc_talisman_possessed_amulet"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh_main_anc_armour_armour_of_silvered_steel"] = { ["uniqueness"] = 45,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc03_anc_magic_standard_the_beast_banner"] = { ["uniqueness"] = 75,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_stirland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_vambraces_of_the_sun"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_dragon_pendant_2"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_weapon_vermillion_blade"] = { ["uniqueness"] = 70,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_weapon_crimson_death"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_engineering_rune_of_burning"] = { ["uniqueness"] = 10,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_talisman_golden_crown_of_atrazar"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_talisman_warp_mirror"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_hochland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_prospectors_spyglass"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc08_anc_talisman_giant_cygor_eyeball"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_hieratic_jar"] = { ["uniqueness"] = 20,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh3_main_anc_talisman_the_bloody_shackle"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_khorne_daemons",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_nordland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_middenland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_scar"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_averland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_old_guards_keg"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_weapon_the_rime_blade"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh_main_anc_weapon_hellfire_sword"] = { ["uniqueness"] = 45,["category"] = "weapon",["faction_set"] = "anc_set_multi_beastmen_chaos",}
    ,["pttg_ritual_wh2_dlc13_anc_arcane_item_amplifier"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_ecstacy"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_daemons_slaanesh",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_elfbane"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_rune_of_fear"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_the_ankor_chain_caravan"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_armour_armour_of_living_death"] = { ["uniqueness"] = 100,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_flag_of_grand_cathay"] = { ["uniqueness"] = 90,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_dlc07_anc_arcane_item_sacrament_of_the_lady"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_great_icon_of_despair"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_dlc14_anc_enchanted_item_malus_octagon_medallion"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_ring_of_grimnir"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_anc_magic_standard_banner_of_avelorn"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_dlc03_anc_arcane_item_hagtree_fetish"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_sceptre_of_stone"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_horn_of_the_ancestors"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_starmetal_plate"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_alriks_armour"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_anc_weapon_warptech_arsenal"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_talisman_spangleshard"] = { ["uniqueness"] = 25,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc10_anc_talisman_hydra_head"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_weapon_spirit_qilin_spear"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_talisman_blizzard_broach"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_dreaming_ring_2"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_talisman_of_loec"] = { ["uniqueness"] = 10,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_scrolls_of_astromancy"] = { ["uniqueness"] = 30,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_dlc23_anc_arcane_item_chalice_of_blood_and_darkness"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "chaos_dwarfs",}
    ,["pttg_ritual_wh_dlc08_anc_weapon_flaming_axe_of_cormac"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_weapon_dawn_glaive"] = { ["uniqueness"] = 80,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_weapon_bale_sword"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh3_main_anc_weapon_nuku_chos_crossbow"] = { ["uniqueness"] = 65,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_talisman_gnoblar_thiefstone"] = { ["uniqueness"] = 45,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc10_anc_arcane_item_scroll_of_blast"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_dlc09_anc_armour_scorpion_armour"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh_dlc05_anc_magic_standard_the_banner_of_the_eternal_queen"] = { ["uniqueness"] = 100,["category"] = "general",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_winged_staff"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_rod_of_flaming_death"] = { ["uniqueness"] = 40,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_vampire_counts",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_dead_mans_chest"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_main_anc_weapon_venom_sword"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_portents_of_verminous_doom"] = { ["uniqueness"] = 20,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_icon_of_sorcery"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh_dlc05_anc_enchanted_item_hail_of_doom_arrow"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_book_of_hoeth"] = { ["uniqueness"] = 55,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_blood_statuette_of_spite"] = { ["uniqueness"] = 25,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_main_anc_weapon_blade_of_sea_gold"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_caravan_von_carstein_blade"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_cathay_and_the_changeling",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_eagle_vambraces_4"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_talisman_diamond_guardian_phoenix"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_banner_of_ellyrion"] = { ["uniqueness"] = 15,["category"] = "general",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_talisman_amulet_of_foresight"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_dlc03_anc_talisman_chalice_of_dark_rain"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_dlc24_anc_talisman_kraken_fang"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh_main_anc_magic_standard_steel_standard"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_kislev_empire",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_chest_of_sustenance"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_sun_standard_of_chotec"] = { ["uniqueness"] = 40,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_main_anc_arcane_item_channelling_staff"] = { ["uniqueness"] = 15,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_blessed_tome"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_armour_winged_boots"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_armour_laminate_shield"] = { ["uniqueness"] = 45,["category"] = "armour",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_old_guards_hammer"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_armour_crown_of_authority"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_cupped_hands_of_the_old_ones"] = { ["uniqueness"] = 45,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc17_anc_talisman_shardstone_amulet"] = { ["uniqueness"] = 10,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc09_anc_armour_armour_skull_cap_of_the_moon"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_rune_ancestor_rune"] = { ["uniqueness"] = 20,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_dlc20_anc_enchanted_item_doom_totem"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh2_main_anc_weapon_blade_of_ruin"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_dlc05_anc_weapon_the_spirit_sword"] = { ["uniqueness"] = 85,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_dlc07_anc_weapon_sword_of_the_quest"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_twilight_spear_4"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_mark_of_chaos_mark_of_slaanesh"] = { ["uniqueness"] = 15,["category"] = "general",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_eagle_bow_4"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_the_cloak_of_feathers"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_main_anc_talisman_the_white_cloak_of_ulric"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_kislev_empire",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_everbleed"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_fiery_ring_of_thori"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_dlc24_anc_enchanted_item_blessed_helm_of_the_oblast"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_astromancers_spyglass"] = { ["uniqueness"] = 1,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_dragon_spear_4"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_venom_of_the_firefly_frog"] = { ["uniqueness"] = 10,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_khornes_gift"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_sc_khorne",}
    ,["pttg_ritual_wh2_dlc12_anc_weapon_mechanical_arm"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc11_anc_weapon_lucky_levis_hookhand"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_icon_of_endless_war"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_khorne_daemons",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_dragon_mask_4"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_skalm"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_main_anc_armour_the_bane_shield"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc10_anc_arcane_item_scroll_of_the_amber_trance"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_high_elves_kislev_wood_elves_bretonnia_empire",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_banner_of_the_under_empire"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_the_terrifying_mask_of_eee"] = { ["uniqueness"] = 25,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_twilight_horn_2"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_icon_of_the_spirit_dragon"] = { ["uniqueness"] = 45,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_grand_banner_of_clan_superiority"] = { ["uniqueness"] = 30,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_eagle_quiver_4"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_dreaming_cloak_4"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_weapon_staff_of_change"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh3_main_anc_weapon_frost_shard_glaive"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_dragon_pendant_4"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_feng_shi"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_standard_of_seeping_decay"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_throwing_bombs"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_twilight_standard_2"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_enchanted_item_daemon_flask_of_ashak"] = { ["uniqueness"] = 100,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_dreaming_boots_2"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_miners_lattern"] = { ["uniqueness"] = 15,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_gate_keepers_belt"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_talisman_ruby_guardian_phoenix"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_obedient_mutant"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_weapon_wrath_of_kurnous"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_weapon_righteous_wrath"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_weapon_aventurine_dagger"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_icon_of_rulership"] = { ["uniqueness"] = 5,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_armour_armour_of_gork"] = { ["uniqueness"] = 100,["category"] = "armour",["faction_set"] = "anc_set_exclusive_greenskins",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_rod_of_briars"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_odd_powder_keg"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_shroud_of_chaqua"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_jewel_of_the_dusk"] = { ["uniqueness"] = 199,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_siren_standard"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_daemons_slaanesh",}
    ,["pttg_ritual_wh2_dlc09_anc_talisman_sun_scarab"] = { ["uniqueness"] = 20,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_box_of_eerie_noises"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc20_anc_item_crown_of_everlasting_conquest"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_celestial_silk_robe"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_talisman_ring_of_darkness"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_ironwardens_wardstone"] = { ["uniqueness"] = 75,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_rangers_hammer"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc13_anc_talisman_stadsraad_key"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_ceithin_har_scale"] = { ["uniqueness"] = 100,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc12_anc_enchanted_item_warp_lightning_battery"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_weapon_battleaxe_of_the_last_waaagh"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_greenskins",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_battle"] = { ["uniqueness"] = 100,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_magic_standard_morks_war_banner"] = { ["uniqueness"] = 100,["category"] = "general",["faction_set"] = "anc_set_exclusive_sc_greenskins",}
    ,["pttg_ritual_wh_pro01_anc_rune_rune_of_parrying"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_standard_of_wei_jin"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_groth_one-eye"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_burnt_banner_of_knights"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_satchel_of_potions"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc10_anc_talisman_carnosaur_skull"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh_dlc08_anc_talisman_headband_of_berserker"] = { ["uniqueness"] = 100,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh_dlc08_anc_enchanted_item_frost_wyrm_scale"] = { ["uniqueness"] = 100,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_armour_gut_maw"] = { ["uniqueness"] = 45,["category"] = "armour",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_skull_totem"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_khorne_daemons",}
    ,["pttg_ritual_wh_dlc08_anc_armour_mammoth_hide_cape"] = { ["uniqueness"] = 100,["category"] = "armour",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh_dlc08_anc_magic_standard_drake_hunters"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_talisman_jade_blood_pendant"] = { ["uniqueness"] = 25,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_weapon_axe_of_khorne"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh_dlc07_anc_magic_standard_valorous_standard"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_master_rune_of_spite"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_prologue_anc_talisman_blood_of_the_motherland"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_sc_pro_kislev",}
    ,["pttg_ritual_wh_dlc08_anc_armour_blood_stained_armour_of_morkar"] = { ["uniqueness"] = 100,["category"] = "armour",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_dlc12_anc_weapon_thing_zapper"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_elixir_of_might"] = { ["uniqueness"] = 20,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh_main_anc_weapon_sword_of_battle"] = { ["uniqueness"] = 20,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_weapon_skull_plucker"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh_dlc08_anc_magic_standard_banner_of_wolfclaw"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh_main_anc_armour_spellshield"] = { ["uniqueness"] = 20,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_miners_drinking_horn"] = { ["uniqueness"] = 15,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_weapon_obsidian_blade"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc03_anc_armour_trollhide"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_dlc20_anc_weapon_sword_of_change"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh_dlc03_anc_mark_of_chaos_crown_of_horns"] = { ["uniqueness"] = 75,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh_main_anc_magic_standard_blasted_standard"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_multi_beastmen_chaos",}
    ,["pttg_ritual_wh3_main_anc_talisman_fractured_clasp"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh3_dlc20_anc_enchanted_item_blasphemous_amulet"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh3_dlc23_anc_talisman_talisman_of_obsidian"] = { ["uniqueness"] = 100,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh3_dlc23_anc_talisman_black_gem_of_gnar"] = { ["uniqueness"] = 100,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_khaines_ring_of_fury"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_arcane_item_spell_wrought_sceptre"] = { ["uniqueness"] = 100,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_dlc14_anc_weapon_malus_blood_warpsword"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_sea_gold_parrying_blade"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_spear_of_pakth"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_weapon_the_blade_of_realities"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc17_anc_enchanted_item_blind_eye_of_seeing"] = { ["uniqueness"] = 100,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh_dlc07_anc_weapon_the_wyrmlance"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_dlc11_anc_talisman_kraken_fang"] = { ["uniqueness"] = 90,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_enthralling_musk"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh3_main_anc_weapon_hellblade"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_multi_khorne_daemons",}
    ,["pttg_ritual_wh2_dlc11_anc_weapon_double_barrel"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_alchemists_elixir_of_venom"] = { ["uniqueness"] = 40,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_black_staff"] = { ["uniqueness"] = 55,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_the_great_celestial_banner"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_enriched_warpstone_dust"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_weapon_executioners_axe"] = { ["uniqueness"] = 80,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_pro01_anc_rune_rune_of_striking"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc11_anc_talisman_jellyfish_in_a_jar"] = { ["uniqueness"] = 45,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_banner_of_murder"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_dismay"] = { ["uniqueness"] = 80,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_talisman_wyrdstone_necklace"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_staff_of_wu_xing"] = { ["uniqueness"] = 80,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_magic_standard_the_bad_moon_banner"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_sc_greenskins",}
    ,["pttg_ritual_wh_main_anc_arcane_item_scroll_of_leeching"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_anc_arcane_item_scroll_of_arnizipals_black_horror"] = { ["uniqueness"] = 80,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_culchan_feathered_standard"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_weapon_staff_of_nurgle"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh_dlc07_anc_weapon_the_silver_lance_of_the_blessed"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_main_anc_weapon_the_white_sword"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_blood_feasters_banner"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_sc_khorne",}
    ,["pttg_ritual_wh_dlc05_anc_magic_standard_the_banner_of_the_hunter_king"] = { ["uniqueness"] = 75,["category"] = "general",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_gastuvas_egg"] = { ["uniqueness"] = 100,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_main_anc_talisman_sacred_incense"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_weapon_blade_of_xen_wu"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_corpse_surgeon"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_battle_banner"] = { ["uniqueness"] = 80,["category"] = "general",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_armour_shield_of_the_mirrored_pool"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_dlc03_anc_mark_of_chaos_shadow_hide"] = { ["uniqueness"] = 5,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_dlc23_anc_armour_lesser_relic_of_skavor"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_dragon_cuirass_1"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_ever_full_kovsh"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_tome_of_furion"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_the_piranha_blade"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_armour_armour_of_khorne"] = { ["uniqueness"] = 75,["category"] = "armour",["faction_set"] = "anc_set_multi_khorne_daemons",}
    ,["pttg_ritual_wh2_main_anc_weapon_reaver_bow"] = { ["uniqueness"] = 199,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_abhorrent_lodestone"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_valaya"] = { ["uniqueness"] = 65,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_dreaming_cloak_2"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_dreaming_ring_4"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_stegadon_war_spear"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_main_anc_talisman_talisman_of_endurance"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc24_anc_weapon_weeping_blade"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_the_empress_eye"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_coatlpelt_flagstaff"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc11_anc_enchanted_item_black_buckthorns_treasure_map"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_holed_banner_of_militia"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_twilight_horn_1"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_the_brass_cleaver"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_stonecrusher_mace"] = { ["uniqueness"] = 65,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_potion_of_toughness"] = { ["uniqueness"] = 20,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_ironwardens_hammer"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_gate_keepers_hammer"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc03_anc_armour_ramhorn_helm"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh_dlc08_anc_magic_standard_black_iron_reavers"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_revered_banner_of_the_ancestors"] = { ["uniqueness"] = 80,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_dragon_slayers_fang"] = { ["uniqueness"] = 75,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_dlc24_anc_arcane_item_sentient_stormcloud"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_ironwardens_tankard"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_armour_mastodon_armour"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_twilight_helm_4"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_talisman_talisman_of_preservation"] = { ["uniqueness"] = 60,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc07_anc_enchanted_item_mane_of_the_purebreed"] = { ["uniqueness"] = 70,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_standard_of_shang_yang"] = { ["uniqueness"] = 70,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_armour_void_armour"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_brooch_of_the_great_desert"] = { ["uniqueness"] = 45,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh_main_anc_talisman_pidgeon_plucker_pendant"] = { ["uniqueness"] = 5,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc24_anc_weapon_runefang"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh2_main_anc_weapon_blade_of_leaping_gold"] = { ["uniqueness"] = 70,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_sacred_banner_of_the_horned_rat"] = { ["uniqueness"] = 70,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc11_anc_armour_the_gunnarsson_kron"] = { ["uniqueness"] = 75,["category"] = "armour",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_dlc11_anc_armour_seadragon_buckler"] = { ["uniqueness"] = 45,["category"] = "armour",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_crook_and_flail_of_radiance"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh_main_anc_weapon_sword_of_striking"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_kite_of_the_uttermost_airs"] = { ["uniqueness"] = 65,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_armour_ascendant_celestial_armour"] = { ["uniqueness"] = 65,["category"] = "armour",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_weapon_blade_of_revered_tzunki"] = { ["uniqueness"] = 65,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_main_anc_armour_magnificent_armour_of_borek_beetlebrow"] = { ["uniqueness"] = 60,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_dlc07_anc_magic_standard_banner_of_defence"] = { ["uniqueness"] = 60,["category"] = "general",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh_main_anc_weapon_berserker_sword"] = { ["uniqueness"] = 20,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc03_anc_arcane_item_skull_of_rarkos"] = { ["uniqueness"] = 60,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_the_horn_of_kygor"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_weapon_jade_blade_of_the_great_fleet"] = { ["uniqueness"] = 60,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_catalytic_kiln"] = { ["uniqueness"] = 60,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_armour_scales_of_the_celestial_court"] = { ["uniqueness"] = 60,["category"] = "armour",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_dlc03_anc_mark_of_chaos_slug_skin"] = { ["uniqueness"] = 30,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_dlc24_anc_enchanted_item_mirror_of_knowledge"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh2_main_anc_weapon_bow_of_the_seafarer"] = { ["uniqueness"] = 60,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_father_niklas_mantle"] = { ["uniqueness"] = 5,["category"] = "general",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_main_anc_weapon_blade_of_bel_korhadris"] = { ["uniqueness"] = 60,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_pro01_anc_rune_rune_of_fury"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_twilight_helm_1"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_dlc03_anc_enchanted_item_shard_of_the_herdstone"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_main_anc_armour_armour_of_eternal_servitude"] = { ["uniqueness"] = 60,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_main_anc_magic_standard_scarecrow_banner"] = { ["uniqueness"] = 5,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_arcane_item_book_of_ashur"] = { ["uniqueness"] = 70,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_eagle_mask_1"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_dlc07_anc_armour_gilded_cuirass"] = { ["uniqueness"] = 55,["category"] = "armour",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh3_main_anc_armour_robes_of_shang_yang"] = { ["uniqueness"] = 55,["category"] = "armour",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_main_anc_talisman_vambraces_of_defence"] = { ["uniqueness"] = 55,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_arcane_item_wand_of_jet"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh_main_anc_weapon_runefang"] = { ["uniqueness"] = 85,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_enchanted_spyglass"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_weapon_bashas_axe_of_stunty_smashin"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_greenskins",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_the_portalglyph"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_cloak_of_twilight"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_primeval_club"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_prismatic_amplifier"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh_main_anc_magic_standard_rangers_standard"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc03_anc_mark_of_chaos_gnarled_hide"] = { ["uniqueness"] = 15,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh_main_anc_mark_of_chaos_mark_of_nurgle"] = { ["uniqueness"] = 20,["category"] = "general",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh2_dlc10_anc_arcane_item_scroll_of_assault_of_stone"] = { ["uniqueness"] = 45,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_high_elves_wood_elves",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_mangelder"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc14_anc_banner_pierre_darden"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc05_anc_armour_the_helm_of_the_hunt"] = { ["uniqueness"] = 20,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_talisman_the_black_amulet"] = { ["uniqueness"] = 60,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_main_anc_weapon_sword_of_anti-heroes"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc07_anc_enchanted_item_holy_icon"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh_dlc03_anc_arcane_item_staff_of_darkoth"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_prologue_anc_weapon_frost_shard_glaive"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_pro_kislev",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_skull_wand_of_kaloth"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_greenskins",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_gate_keepers_rat_catcher"] = { ["uniqueness"] = 75,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_slayers_axe"] = { ["uniqueness"] = 15,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc09_anc_weapon_blade_of_mourning_fire"] = { ["uniqueness"] = 90,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_silver_horn_of_vengeance"] = { ["uniqueness"] = 25,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_magic_standard_banner_of_eternal_flame"] = { ["uniqueness"] = 10,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_halfling_cookbook"] = { ["uniqueness"] = 35,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc10_anc_enchanted_item_burning_phoenix_pinion"] = { ["uniqueness"] = 200,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_ostermark"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_main_anc_armour_shadow_armour"] = { ["uniqueness"] = 25,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_talisman_vile_seed"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh3_main_anc_talisman_spore_censer"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh3_main_anc_talisman_ring_of_sensation"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_daemons_slaanesh",}
    ,["pttg_ritual_wh3_dlc23_anc_weapon_life_bane_blade"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_talisman_crystal_pendant"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh3_main_anc_talisman_collar_of_khorne"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_khorne_daemons",}
    ,["pttg_ritual_wh3_main_anc_talisman_blood_of_the_motherland"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh_dlc03_anc_magic_standard_banner_of_the_fallen_kings"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_deaths_head"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh2_dlc14_anc_talisman_malus_idol_of_darkness"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_cloak_of_the_moon_wind"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_armour_tricksters_helm"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_greyback_pelt"] = { ["uniqueness"] = 5,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh_dlc03_anc_mark_of_chaos_gouge_tusks"] = { ["uniqueness"] = 15,["category"] = "general",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh3_main_anc_armour_weird_plate"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_huanchis_blessed_totem"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_armour_iron_ice_armour"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh_main_anc_armour_nightshroud"] = { ["uniqueness"] = 40,["category"] = "armour",["faction_set"] = "anc_set_exclusive_vampire_counts",}
    ,["pttg_ritual_wh3_main_anc_armour_fused_armour"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh3_main_anc_armour_bullgut"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_sceptre_of_entropy"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh_main_anc_weapon_sword_of_swift_slaying"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_cape_of_sniper"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_magic_standard_war_banner"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_gruts_sickle"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_dread_banner"] = { ["uniqueness"] = 75,["category"] = "general",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_torn_banner_of_pilgrims"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_cube_of_darkness"] = { ["uniqueness"] = 30,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_talabecland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh_dlc08_anc_armour_helm_of_reavers"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_dlc23_anc_talisman_malignant_totem"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_cloak_of_beards"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_main_anc_talisman_jet_amulet"] = { ["uniqueness"] = 20,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_weapon_lash_of_despair"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_multi_daemons_slaanesh",}
    ,["pttg_ritual_wh3_main_anc_talisman_cathayan_jet"] = { ["uniqueness"] = 25,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_main_anc_weapon_blade_of_nurglitch"] = { ["uniqueness"] = 10,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_weapon_biting_blade"] = { ["uniqueness"] = 10,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc23_anc_weapon_lesser_relic_of_gazul"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_dragon_spear_1"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_heartseeker"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_moranions_wayshard"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_rune_strollaz_rune"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_twilight_standard_1"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_trophy_of_killers"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_sc_khorne",}
    ,["pttg_ritual_wh_main_anc_rune_rune_of_fury"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc09_anc_arcane_item_neferras_scrolls_of_mighty_incantations"] = { ["uniqueness"] = 45,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh_dlc07_anc_magic_standard_errantry_banner"] = { ["uniqueness"] = 20,["category"] = "general",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh3_dlc23_anc_convoy_powerful_berserker"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh_main_anc_magic_standard_lichbone_pennant"] = { ["uniqueness"] = 16,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_flag_of_the_daystar"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_main_anc_weapon_blood_cleaver"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_main_anc_weapon_dagger_of_hotek"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_scrying_stone"] = { ["uniqueness"] = 15,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc09_anc_talisman_golden_eye_of_rah_nutt"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh_pro01_anc_rune_rune_of_might"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_storm_banner"] = { ["uniqueness"] = 50,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_dreaming_ring_1"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_rune_of_cleaving"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_weapon_the_tenderiser"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh_dlc07_anc_weapon_sword_of_the_ladys_champion"] = { ["uniqueness"] = 45,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh_main_anc_armour_enchanted_shield"] = { ["uniqueness"] = 5,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_weapon_caledors_bane"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_alchemists_elixir_of_iron_skin"] = { ["uniqueness"] = 45,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_dlc20_anc_armour_bronze_armour_of_zhrakk"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh_main_anc_talisman_dawnstone"] = { ["uniqueness"] = 25,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_staff_of_solidity"] = { ["uniqueness"] = 199,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_weapon_relic_sword"] = { ["uniqueness"] = 10,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_potion_of_foolhardiness"] = { ["uniqueness"] = 5,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc08_anc_talisman_lootbag_of_marauders"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_main_anc_armour_obsidian_armour"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh_main_anc_arcane_item_power_scroll"] = { ["uniqueness"] = 20,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_dlc09_anc_arcane_item_blue_khepra"] = { ["uniqueness"] = 40,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_tomb_kings_vampire_coast",}
    ,["pttg_ritual_wh_main_anc_arcane_item_sceptre_of_stability"] = { ["uniqueness"] = 15,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_bloodied_banner_of_slayers"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_main_anc_weapon_burning_blade_of_chotec"] = { ["uniqueness"] = 20,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_dragonhorn"] = { ["uniqueness"] = 15,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_dlc07_anc_armour_armour_of_the_midsummer_sun"] = { ["uniqueness"] = 40,["category"] = "armour",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh_main_anc_armour_helm_of_discord"] = { ["uniqueness"] = 30,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_talisman_greedy_fist"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_dragonfly_of_quicksilver"] = { ["uniqueness"] = 10,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_main_anc_talisman_rival_hide_talisman"] = { ["uniqueness"] = 15,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_eagle_bow_1"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_weapon_serpent_fang"] = { ["uniqueness"] = 60,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_dlc23_anc_armour_blackshard_armour"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_caravan_spy_in_court"] = { ["uniqueness"] = 200,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_bastion_standard"] = { ["uniqueness"] = 90,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_weapon_prospectors_pickaxe"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_icon_of_eternal_virulence"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_daemons_nurgle",}
    ,["pttg_ritual_wh_dlc05_anc_weapon_the_bow_of_loren"] = { ["uniqueness"] = 20,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_weapon_blade_of_corruption"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_magic_standard_the_screaming_banner"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_counts",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_lifetaker_banner"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_sc_khorne",}
    ,["pttg_ritual_wh2_main_anc_armour_skull_helmet"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_saint_annushkas_finger_bone"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_rangers_cloak"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_fan_of_the_magister"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh_main_anc_magic_standard_rampagers_standard"] = { ["uniqueness"] = 55,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_rookie_gunner"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_dlc09_anc_talisman_golden_ankhra"] = { ["uniqueness"] = 45,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_dlc12_anc_magic_standard_exalted_banner_of_xapati"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_prologue_anc_armour_basic"] = { ["uniqueness"] = 20,["category"] = "armour",["faction_set"] = "anc_set_exclusive_sc_pro_kislev",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_troll_slayers_gauntlets"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_the_moon_empress"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_troll_slayers_amulet"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_armour_dragonscale_shield"] = { ["uniqueness"] = 20,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_ships_colors"] = { ["uniqueness"] = 75,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh3_dlc24_anc_arcane_item_captains_horn"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh2_main_anc_talisman_deathmask"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_miners_helm"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_arcane_item_scroll_of_shielding"] = { ["uniqueness"] = 15,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh_main_anc_magic_standard_banner_of_swiftness"] = { ["uniqueness"] = 15,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_dlc24_anc_talisman_facial_scruff"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_brahmir_statue"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh_main_anc_weapon_tormentor_sword"] = { ["uniqueness"] = 5,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_talisman_amulet_of_itzl"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh3_dlc24_anc_arcane_item_corrupted_flame"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh2_main_anc_weapon_deathpiercer"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_dlc07_anc_talisman_siriennes_locket"] = { ["uniqueness"] = 45,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_bretonnia",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_veterans_flask"] = { ["uniqueness"] = 15,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_weapon_the_eternal_blade"] = { ["uniqueness"] = 75,["category"] = "weapon",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_main_anc_weapon_sword_of_the_hornet"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh_main_anc_mark_of_chaos_mark_of_khorne"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh_main_anc_armour_charmed_shield"] = { ["uniqueness"] = 5,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc03_anc_enchanted_item_horn_of_the_first_beast"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_eagle_quiver_1"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_weapon_the_hammer_of_karak_drazh"] = { ["uniqueness"] = 45,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_lion_standard"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_featherfoe_torc"] = { ["uniqueness"] = 25,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_skull_and_crossbones"] = { ["uniqueness"] = 1,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_steppe_hunters_horn"] = { ["uniqueness"] = 5,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_kislev",}
    ,["pttg_ritual_wh_dlc08_anc_talisman_wolf_teeth_amulet"] = { ["uniqueness"] = 30,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_dlc24_anc_talisman_the_golden_eye_of_tzeentch"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh2_dlc11_anc_magic_standard_spell_of_the_necromancers_apprentice"] = { ["uniqueness"] = 5,["category"] = "general",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_troll_slayers_hide"] = { ["uniqueness"] = 35,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_weapon_sword_of_strife"] = { ["uniqueness"] = 40,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_weapon_foe_bane"] = { ["uniqueness"] = 25,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_arcane_item_earthing_rod"] = { ["uniqueness"] = 25,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_reikland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh_main_anc_armour_the_armour_of_meteoric_iron"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_multi_kislev_empire",}
    ,["pttg_ritual_wh_dlc05_anc_weapon_daiths_reaper"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_talisman_jade_amulet"] = { ["uniqueness"] = 40,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_old_guards_tankard"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc11_anc_enchanted_item_pyrotechnic_compound"] = { ["uniqueness"] = 45,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh_main_anc_talisman_talisman_of_protection"] = { ["uniqueness"] = 15,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_ancestor_rune_of_grungni"] = { ["uniqueness"] = 200,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_twilight_helm_3"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_standard_of_chaos_glory"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_dlc11_anc_talisman_blackpearl_eye"] = { ["uniqueness"] = 45,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_vampire_coast",}
    ,["pttg_ritual_wh_dlc08_anc_enchanted_item_manticore_horn"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh_main_anc_weapon_fencers_blades"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc08_anc_weapon_fimir_hammer"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_rangers_pouch"] = { ["uniqueness"] = 15,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_jar_of_all_souls"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_cathay",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_banner_of_hellfire"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_khorne_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_cannibal_totem"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_slayers_belt"] = { ["uniqueness"] = 15,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_armour_gamblers_armour"] = { ["uniqueness"] = 20,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_weapon_scimitar_of_the_sun_resplendent"] = { ["uniqueness"] = 50,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_dragon_mask_2"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_main_anc_enchanted_item_the_chromatic_tome"] = { ["uniqueness"] = 75,["category"] = "enchanted_item",["faction_set"] = "anc_set_multi_tzeentch_daemons_nurgle_slaanesh",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_brass_horn"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc17_anc_rune_personal_rune_of_iron"] = { ["uniqueness"] = 10,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_armour_enchanted_ithilmar_breastplate"] = { ["uniqueness"] = 199,["category"] = "armour",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_enchanted_item_ironbeards_bracers"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh3_main_anc_arcane_item_hellheart"] = { ["uniqueness"] = 50,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_ogre_kingdoms",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_standard_of_hag_graef"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc09_anc_enchanted_item_cloak_of_the_dunes"] = { ["uniqueness"] = 40,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_curse_charm_of_tepok"] = { ["uniqueness"] = 20,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_main_anc_armour_sacred_stegadon_helm_of_itza"] = { ["uniqueness"] = 40,["category"] = "armour",["faction_set"] = "anc_set_exclusive_lizardmen",}
    ,["pttg_ritual_wh2_dlc14_anc_weapon_malus_slaugher_warpsword"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh2_dlc13_anc_weapon_runefang_solland"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_sc_empire",}
    ,["pttg_ritual_wh2_dlc09_anc_magic_standard_standard_of_the_undying_legion"] = { ["uniqueness"] = 40,["category"] = "general",["faction_set"] = "anc_set_exclusive_tomb_kings",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_dragon_pendant_1"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh3_dlc23_anc_talisman_major_relic_of_grimnir"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh_dlc08_anc_weapon_troll_fang_dagger"] = { ["uniqueness"] = 30,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_norsca",}
    ,["pttg_ritual_wh3_dlc23_anc_enchanted_item_the_mask_of_the_furnace"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_the_book_of_the_phoenix"] = { ["uniqueness"] = 35,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_main_anc_arcane_item_forbidden_rod"] = { ["uniqueness"] = 35,["category"] = "arcane_item",["faction_set"] = "all_except_khorne_dwarfs",}
    ,["pttg_ritual_wh2_main_anc_weapon_the_fellblade"] = { ["uniqueness"] = 100,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_talisman_prospectors_charge"] = { ["uniqueness"] = 35,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_magic_standard_griffon_banner"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_multi_kislev_empire",}
    ,["pttg_ritual_wh2_dlc15_anc_armour_forest_dragon_special"] = { ["uniqueness"] = 200,["category"] = "armour",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_folariaths_robe"] = { ["uniqueness"] = 45,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh_dlc03_anc_weapon_the_steel_claws"] = { ["uniqueness"] = 35,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_beastmen",}
    ,["pttg_ritual_wh_main_anc_magic_standard_gleaming_pennant"] = { ["uniqueness"] = 5,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_eagle_vambraces_2"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_twilight_standard_4"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh_main_anc_talisman_dragonbane_gem"] = { ["uniqueness"] = 5,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_shroud_of_dripping_death"] = { ["uniqueness"] = 30,["category"] = "general",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_magic_standard_razor_standard"] = { ["uniqueness"] = 45,["category"] = "general",["faction_set"] = "all",}
    ,["pttg_ritual_wh_main_anc_talisman_obsidian_lodestone"] = { ["uniqueness"] = 45,["category"] = "talisman",["faction_set"] = "all",}
    ,["pttg_ritual_wh3_main_anc_magic_standard_great_standard_of_sundering"] = { ["uniqueness"] = 35,["category"] = "general",["faction_set"] = "anc_set_multi_tzeentch_daemons",}
    ,["pttg_ritual_wh2_dlc16_anc_armour_twilight_helm_2"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_enchanted_item_dreaming_cloak_1"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_enchanted_item_gilded_horn_of_galon_konook"] = { ["uniqueness"] = 199,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh2_dlc12_anc_armour_alloy_shield"] = { ["uniqueness"] = 50,["category"] = "armour",["faction_set"] = "anc_set_exclusive_skaven",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_the_other_tricksters_shard"] = { ["uniqueness"] = 50,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_eagle_mask_4"] = { ["uniqueness"] = 199,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_dlc16_anc_weapon_twilight_spear_3"] = { ["uniqueness"] = 200,["category"] = "weapon",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_arcane_item_the_gem_of_sunfire"] = { ["uniqueness"] = 75,["category"] = "arcane_item",["faction_set"] = "anc_set_exclusive_high_elves",}
    ,["pttg_ritual_wh3_dlc20_anc_enchanted_item_the_beguiling_gem"] = { ["uniqueness"] = 30,["category"] = "enchanted_item",["faction_set"] = "anc_set_exclusive_chaos",}
    ,["pttg_ritual_wh_main_anc_arcane_item_skull_of_katam"] = { ["uniqueness"] = 15,["category"] = "arcane_item",["faction_set"] = "anc_set_multi_beastmen_chaos",}
    ,["pttg_ritual_wh3_dlc24_anc_talisman_corrupted_icon"] = { ["uniqueness"] = 200,["category"] = "talisman",["faction_set"] = "wh3_dlc24_tze_the_deceivers",}
    ,["pttg_ritual_wh2_dlc16_anc_talisman_eagle_mask_2"] = { ["uniqueness"] = 50,["category"] = "talisman",["faction_set"] = "anc_set_exclusive_wood_elves",}
    ,["pttg_ritual_wh2_main_anc_magic_standard_sea_serpent_standard"] = { ["uniqueness"] = 25,["category"] = "general",["faction_set"] = "anc_set_exclusive_dark_elves",}
    ,["pttg_ritual_wh_main_anc_rune_master_rune_of_courage"] = { ["uniqueness"] = 20,["category"] = "general",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,["pttg_ritual_wh_main_anc_enchanted_item_ironcurse_icon"] = { ["uniqueness"] = 5,["category"] = "enchanted_item",["faction_set"] = "all",}
    ,["pttg_ritual_wh2_dlc10_dwf_anc_armour_slayers_gauntlets"] = { ["uniqueness"] = 15,["category"] = "armour",["faction_set"] = "anc_set_exclusive_dwarfs",}
    ,}
    self:add_rituals(items_all)
    
    self.active_shop_items = pttg:get_state('active_shop_items')
    self.excluded_shop_items = pttg:get_state('excluded_items')
end

function pttg_glory_shop:populate_shop()
    local shop_sizes = pttg:get_state('shop_sizes')
    pttg:log(string.format('[pttg_glory_shop] Populating shop with(merch: %i, units:%i)',
            shop_sizes.merchandise,
            shop_sizes.units)
    )

    local random_tiers = {}

    for tier, chance in pairs(pttg:get_state('shop_chances')) do
        for i = 1, chance do
            table.insert(random_tiers, tier)
        end
    end

    for category, rituals in pairs(self.shop_items) do
        local ritual_keys = {}
        local targets = {}
        
        while #targets < shop_sizes[category] do
            local pos = cm:random_number(#random_tiers)
            local tier = random_tiers[pos]
            table.remove(random_tiers, pos)

            -- TODO: Filter all eligible item groups
            local random_rituals = rituals[tier]['all']
            if random_rituals then

                -- TODO: add weights feature to random selection
                local target = cm:random_number(#random_rituals)

                if not ritual_keys[random_rituals[target]] and not self.excluded_shop_items[random_rituals[target]] then
                    table.insert(targets, target)
                    ritual_keys[random_rituals[target]] = true
                end
            end
        end

        local activated_rituals = {}

        for ritual_key, _ in pairs(ritual_keys) do
            pttg:log(string.format('[pttg_glory_shop] Populating %s for %s', ritual_key, category))
            table.insert(activated_rituals, ritual_key)
        end

        pttg_glory_shop:unlock_rituals(activated_rituals)
    end
end

function pttg_glory_shop:disable_shop_button()
    pttg:log("[pttg_glory_shop] Disabling shop button.")
    local root = core:get_ui_root()

    local button = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management", "button_mortuary_cult")

    if not button then
        pttg:log("[pttg_ui] Could not find button.")
        return
    end
    button:SetDisabled(true)
    button:StopPulseHighlight()
    button:Highlight(false)

    return
end

function pttg_glory_shop:enable_shop_button()
    pttg:log("[pttg_glory_shop] Highlighting shop button.")
    local root = core:get_ui_root()

    local button = find_uicomponent(root, "hud_campaign", "faction_buttons_docker", "button_group_management", "button_mortuary_cult")

    if not button then
        pttg:log("[pttg_ui] Could not find button.")
        return
    end

    button:SetDisabled(false)
    button:StartPulseHighlight(1)
    button:Highlight(true)

    return
end


core:add_listener(
    "remove_BoughtItem",
    "RitualCompletedEvent",
    function(context)
        return pttg_glory_shop.active_shop_items[context:ritual():ritual_key()]
    end,
    function(context)
        pttg_glory_shop.excluded_shop_items[context:ritual():ritual_key()] = true
        pttg:set_state('excluded_items', pttg_glory_shop.excluded_shop_items)
    end,
    true
)

core:add_listener(
    "reset_GloryShop",
    "pttg_reset_shop",
    true,
    function(context)
        pttg_glory_shop:reset_rituals()
    end,
    true
)

core:add_listener(
    "populate_GloryShop",
    "pttg_populate_shop",
    true,
    function(context)
        pttg_glory_shop:populate_shop()
    end,
    true
)



core:add_listener(
    "init_GloryShop",
    "pttg_init_complete",
    true,
    function(context)
        pttg_glory_shop:init_shop()
    end,
    true
)


core:add_static_object("pttg_glory_shop", pttg_glory_shop);
