
local switches = {
    vector3(-1380.69, -607.28, 30.04),
    vector3(-1376.5, -608.72, 31.28),
}

local bubbleSpawns = {
    vector3(-1381.27, -606.21, 29.91),
    vector3(-1384.2, -605.15, 29.91),
    vector3(-1380.73, -602.59, 29.91),
    vector3(-1377.34, -612.51, 29.91),
    vector3(-1373.75, -613.31, 29.91),
    vector3(-1377.51, -615.68, 29.91),
}

local activeBubbles = {}

local function loadParticleDict(dict)
    if not HasNamedPtfxAssetLoaded(dict) then
        RequestNamedPtfxAsset(dict)
        while not HasNamedPtfxAssetLoaded(dict) do
            Wait(100)
        end
    end
end

local function getWaterSurfaceHeight(position)
    local waterHeight = 0.0
    if GetWaterHeight(position.x, position.y, position.z, waterHeight) then
        return waterHeight
    end
    return position.z
end

local function createBubbleSwarm(center, heading)
    loadParticleDict("core")
    UseParticleFxAsset("core")

    local waterHeight = getWaterSurfaceHeight(center)
    local radius = 0.08  -- Reduced radius for each bubble swarm
    local bubbleDensity = 120  -- Increased number of bubbles per swarm

    for i = 1, bubbleDensity do
        local offsetX = math.random() * radius * 2 - radius
        local offsetY = math.random() * radius * 2 - radius

        local fx = StartParticleFxLoopedAtCoord(
            "ent_amb_tnl_bubbles_sml",  -- Using the correct particle effect
            center.x + offsetX,
            center.y + offsetY,
            waterHeight,
            0.0, 0.0, heading, 2.5,  -- Increased size from 1.5 to 2.5
            false, false, false, false
        )

        table.insert(activeBubbles, fx)
    end
end

local function createTightBullseyeBubbleSwarms(center)
    local rings = {
        {radius = 0.3, count = 2},  -- Inner ring
        {radius = 0.6, count = 7}, -- Middle ring
        {radius = 0.9, count = 8}  -- Outer ring
    }

    for _, ring in ipairs(rings) do
        for i = 1, ring.count do
            local angle = (math.pi * 2) * (i / ring.count)  -- Divide the circle into equal parts
            local offsetX = math.cos(angle) * ring.radius
            local offsetY = math.sin(angle) * ring.radius
            local spawnPos = vector3(center.x + offsetX, center.y + offsetY, center.z)
            local heading = math.random() * 360  -- Random heading for each swarm
            createBubbleSwarm(spawnPos, heading)
        end
    end

    for i = 1, 4 do
        createBubbleSwarm(center, math.random() * 360)
    end
end

local function toggleBubbleSwarms()
    if #activeBubbles > 0 then
        print("^1[BubbleEffect] Deactivating all bubble swarms.")
        for _, fx in ipairs(activeBubbles) do
            StopParticleFxLooped(fx, false)
        end
        activeBubbles = {}
    else
        print("^2[BubbleEffect] Activating all bubble swarms.")
        for _, bubbleSpawn in ipairs(bubbleSpawns) do
            createTightBullseyeBubbleSwarms(bubbleSpawn)
        end
    end
end

-- Add interactions for each switch using ox_target
for i, switchLocation in ipairs(switches) do
    exports.ox_target:addBoxZone({
        coords = switchLocation,
        size = vec3(0.5, 0.5, 1.0), -- Interaction zone size
        rotation = 0,
        debug = false,
        options = {
            {
                name = "bubble_swarm_toggle",
                event = "bubble:activateAllSwarms",
                icon = "fas fa-water",
                label = "Toggle Bubble Swarms",
            },
        },
    })
end

RegisterNetEvent('bubble:activateAllSwarms', toggleBubbleSwarms)
