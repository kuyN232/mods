-- Находим и исправляем базовую технологию артиллерии
local artillery_tech = data.raw.technology["artillery"]
if artillery_tech then
    -- Полностью заменяем эффекты
    artillery_tech.effects = {
        {
            type = "unlock-recipe",
            recipe = "artillery-wagon"
        },
        {
            type = "unlock-recipe",
            recipe = "artillery-turret"
        },
        {
            type = "unlock-recipe",
            recipe = "artillery-projectile-infinite-1"  -- Заменяем на наш новый рецепт
        }
    }
end

-- Создаем масштабированные версии снарядов
local projectile = data.raw["artillery-projectile"]["artillery-projectile"]

for i = 1, 10 do
    local scale_factor = 1.5 + (i * 0.5)
    
    -- Создаем снаряд
    local new_projectile = table.deepcopy(projectile)
    new_projectile.name = "artillery-projectile-infinite-" .. i
    
    if new_projectile.action and new_projectile.action.action_delivery and new_projectile.action.action_delivery.target_effects then
        for _, effect in pairs(new_projectile.action.action_delivery.target_effects) do
            if effect.type == "nested-result" and effect.action.type == "area" then
                effect.action.radius = effect.action.radius * scale_factor
                
                if effect.action.action_delivery and effect.action.action_delivery.target_effects then
                    for _, damage_effect in pairs(effect.action.action_delivery.target_effects) do
                        if damage_effect.type == "damage" then
                            damage_effect.damage.amount = damage_effect.damage.amount * scale_factor
                        end
                    end
                end
            end
        end
    end
    
    -- Создаем предмет снаряда
    local new_item = {
        type = "ammo",
        name = "artillery-projectile-infinite-" .. i,
        icon = "__base__/graphics/icons/artillery-shell.png",
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "ammo",
        order = "d[artillery]-a[shell]-a[basic]",
        stack_size = 1,
        ammo_type = {
            category = "artillery-shell",
            target_type = "position",
            action = {
                type = "direct",
                action_delivery = {
                    type = "artillery",
                    projectile = "artillery-projectile-infinite-" .. i,
                    starting_speed = 1,
                    direction_deviation = 0,
                    range_deviation = 0,
                    source_effects = {
                        type = "create-explosion",
                        entity_name = "artillery-cannon-muzzle-flash"
                    }
                }
            }
        }
    }
    
    -- Создаем рецепт
    local new_recipe = {
        type = "recipe",
        name = "artillery-projectile-infinite-" .. i,
        enabled = false,
        energy_required = 15,
        ingredients = {
            {"explosive-cannon-shell", 4},
            {"radar", 1},
            {"explosives", 8}
        },
        result = "artillery-projectile-infinite-" .. i,
        category = "crafting"
    }
    
    data:extend({new_projectile, new_item, new_recipe})
    
    -- Создаем технологию для этого уровня
    local new_technology = {
        type = "technology",
        name = "artillery-explosion-radius-" .. i,
        icon = "__base__/graphics/technology/artillery.png",
        icon_size = 256,
        icon_mipmaps = 4,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "artillery-projectile-infinite-" .. i
            }
        },
        prerequisites = i == 1 and {"artillery"} or {"artillery-explosion-radius-" .. (i-1)},
        unit = {
            count = 1000 * i,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 30
        },
        order = "d-e-f-" .. i
    }
    
    data:extend({new_technology})
end