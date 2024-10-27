require("prototypes.technology")

-- Создаем снаряд (item)
local artillery_shell = table.deepcopy(data.raw["ammo"]["artillery-shell"])
artillery_shell.name = "artillery-shell-infinite"
artillery_shell.localised_name = {"item-name.artillery-shell-infinite"}
artillery_shell.localised_description = {"item-description.artillery-shell-infinite"}
artillery_shell.stack_size = 1
artillery_shell.subgroup = "ammo"
artillery_shell.order = "d[artillery-shell]-a[infinite]"

-- Создаем projectile
local artillery_projectile = table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
artillery_projectile.name = "artillery-projectile-infinite"
artillery_projectile.action = {
    type = "direct",
    action_delivery = {
        type = "instant",
        target_effects = {
            {
                type = "nested-result",
                action = {
                    type = "area",
                    radius = 5,
                    action_delivery = {
                        type = "instant",
                        target_effects = {
                            {
                                type = "damage",
                                damage = {amount = 1500, type = "explosion"}
                            },
                            {
                                type = "create-entity",
                                entity_name = "big-explosion"
                            }
                        }
                    }
                }
            }
        }
    }
}

-- Обновляем ammo_type для снаряда
artillery_shell.ammo_type = {
    category = "artillery-shell",
    target_type = "position",
    action = {
        type = "direct",
        action_delivery = {
            type = "artillery",
            projectile = "artillery-projectile-infinite",
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

-- Создаем рецепт
local recipe = table.deepcopy(data.raw["recipe"]["artillery-shell"])
recipe.name = "artillery-shell-infinite"
recipe.results = {{
    type = "item",
    name = "artillery-shell-infinite",
    amount = 1
}}
recipe.enabled = false

-- Создаем технологию
local technology = {
    type = "technology",
    name = "artillery-shell-radius",
    icon_size = 256,
    icon = "__base__/graphics/technology/artillery.png",
    effects = {
        {
            type = "unlock-recipe",
            recipe = "artillery-shell-infinite"
        }
    },
    prerequisites = {"artillery"},
    unit = {
        count_formula = "2^L * 1000",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1},
            {"chemical-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    order = "d-e-f"
}

-- Регистрируем все созданные объекты
data:extend({
    artillery_shell,
    artillery_projectile,
    recipe,
    technology,
    massive_explosion
})

-- Создаем бесконечную технологию для увеличения радиуса
data:extend({
    {
        type = "technology",
        name = "artillery-shell-radius",
        icon = "__artillery-explosion-radius-infinite__/graphics/technology/artillery-shell-radius.png", -- измените здесь путь
        icon_size = 256,
        icon_mipmaps = 4,
        max_level = "infinite",
        prerequisites = {"artillery"},
        unit = {
            count_formula = "2^L * 1000",
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1}
            },
            time = 30
        },
        upgrade = true,
        order = "e-l-b"
    }
})

-- Создаем предмет артиллерийского снаряда
data:extend({
    {
        type = "ammo",
        name = "artillery-projectile-infinite",
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
        magazine_size = 1,
        ammo_type = {
            category = "artillery-shell",
            target_type = "position",
            action = {
                type = "direct",
                action_delivery = {
                    type = "artillery",
                    projectile = "artillery-projectile-infinite",
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
})

-- Создаем предмет артиллерийского снаряда
data:extend({
    {
        type = "ammo",
        name = "artillery-projectile-infinite",
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
        ammo_category = "artillery-shell", -- Исправленный комментарий
        magazine_size = 1,
        ammo_type = {
            category = "artillery-shell",
            target_type = "position",
            action = {
                type = "direct",
                action_delivery = {
                    type = "artillery",
                    projectile = "artillery-projectile-infinite",
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
})
-- Добавляем разблокировку рецепта в технологию артиллерии
local artillery_tech = data.raw.technology["artillery"]
if artillery_tech then
    if not artillery_tech.effects then
        artillery_tech.effects = {}
    end
    table.insert(artillery_tech.effects, {
        type = "unlock-recipe",
        recipe = "artillery-projectile-infinite"
    })
end