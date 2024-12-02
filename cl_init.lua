RegisterNetEvent( 'sample_rpchat:SendOocMessage' )
AddEventHandler( 'sample_rpchat:SendOocMessage', function( message )
    ExecuteCommand( 'ooc ' .. message )
end )

Citizen.CreateThread( function()
    while not COMMANDS do
        Citizen.Wait( 0 )
    end

    for k, v in pairs(COMMANDS) do
        if v.ARGUMENTS then
            for k2, v2 in ipairs(v.ARGUMENTS) do
                v2.name = v2[1]
                v2.help = v2[2]
            end
        
            TriggerEvent("chat:addSuggestion", "/"..k, v.DESCRIPTION, v.ARGUMENTS)
        end
    end
    
    TriggerEvent("chat:addSuggestion", "/whois", "Get a player's name from the server id", {
        { name = "server id", help = "Player server identifier" }
    })
end )