local pttg = core:get_static_object("pttg");
local pttg_merc_pool = core:get_static_object("pttg_merc_pool");

local pttg_glory_shop = {
    shop_items = {
        merchandise = { {}, {}, {}, {} },
        units = { {}, {}, {} }
    },
    active_shop_items = {
    },
    excluded_shop_items = {
    }
}

function pttg_glory_shop:add_item(ritual, info)
    pttg:log(string.format('[pttg_glory_shop] Adding ritual: %s (%s, %s, %s)',
            ritual,
            tostring(info.uniqueness),
            tostring(info.category),
            tostring(info.faction_set),
            tostring(info.item)
        )
    )
    local crafting_group = "merchandise"
    if info.category == 'units' then
        crafting_group = 'units'
    end
    local tier = self:item_tier(info.uniqueness)
    if self.shop_items[crafting_group][tier][info.faction_set] then
        table.insert(self.shop_items[crafting_group][tier][info.faction_set], {ritual=ritual, info=info})
    else
        self.shop_items[crafting_group][tier][info.faction_set] = {{ritual=ritual, info=info}}
    end
end

function pttg_glory_shop:add_items(items)
    for ritual, info in pairs(items) do
        self:add_item(ritual, info)
    end
end

function pttg_glory_shop:reset_rituals()
    local rituals = {}
    for ritual, _ in pairs(self.active_shop_items) do
        table.insert(rituals, ritual)
    end
    pttg_glory_shop:lock_rituals(rituals)
    self.active_shop_items = {}
    core:remove_listener('pttg_merc_unlock')
end

function pttg_glory_shop:unlock_ritual(shop_item)
    pttg:log(string.format('[pttg_glory_shop]Unlocking ritual %s', shop_item.ritual))
    local faction = cm:get_local_faction()

    cm:unlock_ritual(faction, shop_item.ritual, 1)
    self.active_shop_items[shop_item.ritual] = shop_item.info
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:unlock_rituals(shop_items)
    local faction = cm:get_local_faction()
    for _, shop_item in pairs(shop_items) do
        pttg:log(string.format('[pttg_glory_shop]Unlocking ritual %s', tostring(shop_item.ritual)))
        cm:unlock_ritual(faction, shop_item.ritual, 1)
        self.active_shop_items[shop_item.ritual] = shop_item.info
    end
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:lock_rituals(shop_items)
    pttg:log(string.format('[pttg_glory_shop]Locking rituals %s', #shop_items))
    local faction = cm:get_local_faction()
    for _, shop_item in pairs(shop_items) do
        cm:lock_ritual(faction, shop_item.ritual)
        self.active_shop_items[shop_item.ritual] = false
    end
    pttg:set_state('active_shop_items', self.active_shop_items)
end

function pttg_glory_shop:lock_ritual(shop_item)
    pttg:log(string.format('[pttg_glory_shop]Locking ritual %s', shop_item.ritual))
    local faction = cm:get_local_faction()

    cm:lock_ritual(faction, shop_item.ritual)
    self.active_shop_items[shop_item.ritual] = false
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
    pttg = core:get_static_object("pttg");
    pttg_merc_pool = core:get_static_object("pttg_merc_pool");
    local shop_sizes = pttg:get_state('shop_sizes')

    pttg:log(string.format('[pttg_glory_shop] Initialising shop with(merch: %i, units:%i)',
            shop_sizes.merchandise,
            shop_sizes.units)
    )

    local tier_to_uniqueness = {29, 49, 99}

    for tier, units in pairs(pttg_merc_pool.merc_pool[cm:get_local_faction():culture()]) do
        for _, unit_info in pairs(units) do
            local item_info = {}
            item_info.uniqueness = tier_to_uniqueness[tier]
            item_info.category = 'units'
            item_info.faction_set = 'all'
            item_info.item = unit_info.key
            self:add_item("pttg_ritual_"..unit_info.key, item_info)
        end
    end

    core:add_listener(
        "pttg_merc_unlock",
        "RitualCompletedEvent",
        function(context)
            return self.active_shop_items[context:ritual():ritual_key()]
        end,
        function(context)
            local performing_faction = context:performing_faction();
            local faction_key = performing_faction:name();
            local ritual_key = context:ritual():ritual_key();

            local shop_item = self.active_shop_items[ritual_key]

            if shop_item and shop_item.category == 'units' then
                pttg_merc_pool:add_unit_to_pool(shop_item.item, 1)
                cm:faction_add_pooled_resource(faction_key, "pttg_unit_reward_glory", "pttg_glory_unit_recruitment", 1)
                return;
            end;
        end,
        true
    );

    self:add_item("pttg_ritual_glorious_weapon", { ["uniqueness"] = 75, ["category"] = "weapon", ["faction_set"] = "all", ["item"] = "pttg_glorious_weapon"})


    
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
            local tier = math.min(random_tiers[pos], #rituals)
            table.remove(random_tiers, pos)

            local faction = cm:get_local_faction()
            local random_rituals = {}
            for faction_set, faction_rituals in pairs(rituals[tier]) do
                ---@diagnostic disable-next-line: undefined-field
                if faction:is_contained_in_faction_set(faction_set) then
                    for _, ritual in pairs(faction_rituals) do
                        table.insert(random_rituals, ritual)
                    end
                end
            end

            if #random_rituals > 0 then
                -- TODO: add weights feature to random selection
                local target = cm:random_number(#random_rituals)

                if not ritual_keys[random_rituals[target].ritual] and not self.excluded_shop_items[random_rituals[target].ritual] then
                    table.insert(targets, target)
                    ritual_keys[random_rituals[target].ritual] = random_rituals[target].info
                end
            end
        end

        local activated_rituals = {}

        for ritual_key, ritual_info in pairs(ritual_keys) do
            pttg:log(string.format('[pttg_glory_shop] Populating %s for %s', ritual_key, category))
            table.insert(activated_rituals, {ritual=ritual_key, info=ritual_info})
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

    button:SetVisible(false)
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

    button:SetVisible(true)
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
