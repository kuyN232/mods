script.on_init(function()
    if not global then global = {} end
    global.projectile_radius = 28
    global.artillery_shots = {}
end)

-- При исследовании технологии
script.on_event(defines.events.on_research_finished, function(event)
    if event.research.name == "artillery-shell-radius" then
        local force = event.research.force
        local level = force.technologies["artillery-shell-radius"].level
        -- Увеличиваем радиус более значительно
        global.projectile_radius = 28 + (level * 10)  -- Увеличили множитель с 2 до 10
        -- Выводим сообщение для проверки
        game.print("Радиус артиллерийского взрыва увеличен до " .. global.projectile_radius)
    end
end)

-- При выстреле из артиллерии
script.on_event(defines.events.on_trigger_created_entity, function(event)
    if event.entity.name == "artillery-projectile-infinite" then
        if not global.artillery_shots then
            global.artillery_shots = {}
        end
        
        global.artillery_shots[event.entity.unit_number] = {
            position = event.entity.position,
            surface = event.entity.surface,
            force = event.entity.force,
            radius = global.projectile_radius or 28
        }
    end
end)

-- При попадании снаряда
script.on_event(defines.events.script_raised_destroy, function(event)
    if event.entity and event.entity.name == "artillery-projectile-infinite" then
        local shot_data = global.artillery_shots[event.entity.unit_number]
        if shot_data then
            -- Создаем несколько взрывов для большего эффекта
            for i = 1, 5 do
                shot_data.surface.create_entity({
                    name = "massive-explosion",
                    position = {
                        x = shot_data.position.x + math.random(-5, 5),
                        y = shot_data.position.y + math.random(-5, 5)
                    },
                    force = shot_data.force
                })
            end
            
            -- Наносим урон в увеличенной области
            local entities = shot_data.surface.find_entities_filtered({
                position = shot_data.position,
                radius = shot_data.radius,
                force = {"enemy", "neutral"}  -- Только вражеские и нейтральные объекты
            })
            
            for _, target in pairs(entities) do
                if target.valid and target.health then
                    target.damage(2000, shot_data.force, "explosion")
                end
            end
            
            -- Создаем кратер
            shot_data.surface.create_entity({
                name = "ground-explosion",
                position = shot_data.position,
                force = shot_data.force
            })
            
            global.artillery_shots[event.entity.unit_number] = nil
            game.print("Взрыв с радиусом: " .. shot_data.radius)
        end
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    -- Проверяем, является ли умерший объект нашим снарядом
    if event.entity.name:find("artillery-projectile-infinite-") then
        -- Извлекаем уровень из имени снаряда
        local level = tonumber(event.entity.name:match("infinite%-(%d+)"))
        if level then
            local scale_factor = 1.5 + (level * 0.5)
            local position = event.entity.position
            
            game.surfaces[1].create_entity{
                name = "artillery-shell-infinite-explosion-" .. scale_factor,
                position = position
            }
        end
    end
end)

script.on_load(function()
    if not global then global = {} end
    if not global.projectile_radius then
        global.projectile_radius = 28
    end
    if not global.artillery_shots then
        global.artillery_shots = {}
    end
end)