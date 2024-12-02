function SendWebhook(player, text)
    Citizen.CreateThread(function()
        local content = json.encode {
            username = GetPlayerName(player).. " ["..tostring(player).."]",
            content = text,
            avatar_url = "https://sample.wtf/i/sample/possessive-cynical-jackal.png"
        }
    
        PerformHttpRequest("https://canary.discord.com/api/webhooks/923872614919860254/5YKa3u1iC0nWAKtXGLsSyktxVCmiBkLiCcjcSos73jI_gDXhFf1G54701aSxhiT06nDa", function()end, 'POST', content, { ['Content-Type'] = 'application/json' })    
    end)
end

AddEventHandler('chatMessage', function(player, name, message)
    local realName = GetPlayerName(player)

    if exports.sample_air_conditioner and exports.sample_air_conditioner.ValidateChatMessage then
        local valid = exports["sample_air_conditioner"]:ValidateChatMessage(player, name)
        if not valid then
            print("^1HACKER DETECTED: ^8\""..realName.."\" ["..player.."] USED NAME \""..name.."\" WHEN SENDING \"chatMessage\"")
            return
        end
    end

    if string.sub( message, 1, string.len( "/" ) ) ~= "/" then
        message = Emojify(message)

        SendWebhook( player, "[OOC] | " .. message )
        TriggerClientEvent( 'sample_rpchat:SendOocMessage', player, message )
    end

    CancelEvent()
end)

function string:ToTable()
    local t = {}

    for i = 1, self:len() do
        t[i] = self:sub(i, i)
    end

    return t
end

function string:Explode(sep, pattern)
    if sep == "" then return self:ToTable() end
    pattern = pattern or false

    local ret = {}
    local currentPos = 1

    for i = 1, self:len() do
        local startPos, endPos = self:find(sep, currentPos, not pattern)
        if not startPos then break end
        ret[i] = self:sub(currentPos, startPos - 1)
        currentPos = endPos + 1
    end

    ret[#ret + 1] = self:sub(currentPos)
    return ret
end

Citizen.CreateThread(function()
    repeat Citizen.Wait(0) until COMMANDS

    for k, v in pairs(COMMANDS) do
        RegisterCommand(k, function(player, _, raw)
            if exports.sample_air_conditioner and exports.sample_air_conditioner.CheckForBlacklistedWords then
                local valid2, word = exports["sample_air_conditioner"]:CheckForBlacklistedWords(player, raw)
                if not valid2 then
                    print("^1BLACKLISTED WORD DETECTED: ^8\""..GetPlayerName(player).."\" ["..player.."] SAID \""..(word or "").."\"!^0")
                    return
                end
            end

            local args = raw:Explode " "
            table.remove(args, 1)

            local useDefault = false
            if not args[1] or not args[1]:match "%S" then
                if not v.MESSAGE then return end
                if v.MESSAGE:format("test") ~= v.MESSAGE then
                    if not v.DEFAULT then return else 
                        useDefault = true 
                    end
                end
            end
            
            local message = table.concat(args, " ")
            local msg = v.MESSAGE
            if not useDefault then
                if msg == false then msg = nil
                elseif msg == nil then msg = message
                else msg = msg:format(message) end
            else
                msg = msg:format(v.DEFAULT)
            end

            msg = Emojify(msg)

            local name = GetPlayerName(player)

            if v.ONLY_LOCAL_PLAYER then
                TriggerClientEvent("chat:addMessage", player, {
                    args = { v.PREFIX and v.PREFIX:format(name) or table.concat(args, " "), msg },
                    color = v.PREFIX_COLOR and v.PREFIX_COLOR or { 255, 255, 255 }
                })
            elseif v.PROXIMITY then
                SendWebhook(player, "["..string.upper(k).."] | "..msg)

                local p = GetPlayerPed( player )
                local c = GetEntityCoords( p )

                local event = {
                    args = { v.PREFIX and v.PREFIX:format( name, tostring( v2 ) ) or msg, v.PREFIX and msg or nil },
                    color = v.PREFIX_COLOR or { 255, 255, 255 }
                }

                for _, v2 in ipairs( GetPlayers() ) do
                    local p2 = GetPlayerPed( v2 )
                    local c2 = GetEntityCoords( p2 )

                    if #( c - c2 ) <= v.RANGE then
                        TriggerClientEvent( 'chat:addMessage', v2, event )
                    end
                end
            elseif not v.PROXIMITY then
                SendWebhook(player, "["..string.upper(k).."] | "..msg)
                TriggerClientEvent("chat:addMessage", -1, {
                    args = { v.PREFIX and v.PREFIX:format(name) or table.concat(args, " "), msg },
                    color = v.PREFIX_COLOR and v.PREFIX_COLOR or { 255, 255, 255 }
                }, v.SHOW_WITH_CHAT_OFF or false)
            end
        end)
    end
end)

function Emojify(text)
    for k, v in pairs(EMOJIS) do
        text = text:gsub(k, v)
    end

    return text
end
exports( 'Emojify', Emojify )

function string.ToTable( str )
	local tbl = {}

	for i = 1, string.len( str ) do
		tbl[i] = string.sub( str, i, i )
	end

	return tbl
end

-- AddEventHandler( 'chatMessage', function( text )
--     if string.ToTable( text )[1] == '/' then
--         CancelEvent()
--     end
-- end )

RegisterNetEvent('asrp:sendchattweet')
AddEventHandler('asrp:sendchattweet', function(name, msg)
    TriggerClientEvent("chat:addMessage", -1, { args = {"^4Tweet ^7| ^4@"..name.."", msg}})
end)

RegisterCommand("whois", function(player, args, _)
    TriggerClientEvent("chat:addMessage", player, {
        args = { "Server ID "..tostring(args[1]), GetPlayerName(args[1]) }
    })
end)

--[[RegisterCommand("text", function(player, args, _)
    local message = table.concat(args, " ", 2)

    SendWebhook(player, ("[TEXT TO %s] | %s"):format(GetPlayerName(args[1]):upper(), message))

    TriggerClientEvent("chat:addMessage", args[1], {
        args = { ("^3Text Received | %s"):format(GetPlayerName(player), tostring(player)), message }
    })

    TriggerClientEvent("chat:addMessage", player, {
        args = { ("^3Text Sent | %s"):format(GetPlayerName(args[1]), args[1]), message }
    })
end)]]--

exports.chat:registerMode( {
    name = "looc",
    displayName = "LOOC",
    color = "#0099CC",
    cb = function( player, args, cbs )
        local v = COMMANDS.looc
        local message = args.args[2]

        if exports.sample_air_conditioner and exports.sample_air_conditioner.CheckForBlacklistedWords then
            local valid2, word = exports["sample_air_conditioner"]:CheckForBlacklistedWords( player, message )
            if not valid2 then
                print("^1BLACKLISTED WORD DETECTED: ^8\""..GetPlayerName( player ).."\" [".. player .."] SAID \""..( word or "" ).."\"!^0")
                return
            end
        end

        message = Emojify( message )

        SendWebhook(player, "[LOOC] | " .. message )

        local p = GetPlayerPed( player )
        local c = GetEntityCoords( p )

        local name = GetPlayerName( player )
        local event = {
            args = { v.PREFIX:format( name ), message },
            color = v.PREFIX_COLOR or { 255, 255, 255 }
        }

        for _, v2 in ipairs( GetPlayers() ) do
            local p2 = GetPlayerPed( v2 )
            local c2 = GetEntityCoords( p2 )

            if #( c - c2 ) <= v.RANGE then
                TriggerClientEvent( 'chat:addMessage', v2, event )
            end
        end

        cbs.cancel()
    end
} )