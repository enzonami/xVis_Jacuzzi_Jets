local activeBubbleLocations = {}

RegisterNetEvent('bubble:requestSpawn', function(position)
    local src = source
    if not activeBubbleLocations[position] then
        activeBubbleLocations[position] = true
        print(("[BubbleEffect] Player %s requested spawn at %s"):format(src, position))
        TriggerClientEvent('bubble:spawn', -1, position)
    end
end)

RegisterNetEvent('bubble:requestRemove', function(position)
    local src = source
    if activeBubbleLocations[position] then
        activeBubbleLocations[position] = nil
        print(("[BubbleEffect] Player %s requested removal at %s"):format(src, position))
        TriggerClientEvent('bubble:remove', -1, position)
    end
end)

RegisterCommand("clearbubbles", function(source)
    activeBubbleLocations = {}
    TriggerClientEvent('bubble:remove', -1, nil)
    print("[BubbleEffect] All bubbles cleared!")
end, true)
