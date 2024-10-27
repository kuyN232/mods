-- Модифицируем базовую технологию артиллерии
local artillery_tech = data.raw.technology["artillery"]
if artillery_tech and artillery_tech.effects then
    -- Находим и удаляем старый эффект разблокировки рецепта
    for i, effect in pairs(artillery_tech.effects) do
        if effect.type == "unlock-recipe" and effect.recipe == "artillery-projectile-infinite" then
            table.remove(artillery_tech.effects, i)
            break
        end
    end
    -- Добавляем новый эффект для первого уровня
    table.insert(artillery_tech.effects, {
        type = "unlock-recipe",
        recipe = "artillery-projectile-infinite-1"
    })
end

-- Создаем масштабированные версии снарядов
local projectile = data.raw["artillery-projectile"]["artillery-projectile"]

for i = 1, 10 do
    local scale_factor = 1.5 + (i * 0.5)
    
    -- Создаем снаряд
    local new_projectile = table.deepcopy(projectile)
    new_projectile.name = "artillery-projectile-infinite-" .. i
    
    -- Копируем оригинальные эффекты и модифицируем только радиус и урон
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
        pictures = {
            layers = {
                {
                    size = 64,
                    filename = "__base__/graphics/icons/artillery-shell.png",
                    scale = 1,
                    mipmap_count = 4
                }
            }
        },
        subgroup = "ammo",
        order = "d[artillery]-a[shell]-a[basic]",
        stack_size = 1,
        ammo_category = "artillery-shell",
        magazine_size = 1,
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
            {
                type = "item",
                name = "explosive-cannon-shell",
                amount = 4
            },
            {
                type = "item",
                name = "radar",
                amount = 1
            },
            {
                type = "item",
                name = "explosives",
                amount = 8
            }
        },
        results = {
            {
                type = "item",
                name = "artillery-projectile-infinite-" .. i,
                amount = 1
            }
        },
        category = "crafting"
    }
    
    data:extend({new_projectile, new_item, new_recipe})
end

-- Создаем технологии для каждого уровня
for i = 1, 10 do
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