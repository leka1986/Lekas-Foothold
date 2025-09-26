ZoneTimers = {}
CountdownTimers = {}

if not zones.khasab.wasBlue then
    local zone = ZONE:FindByName("No FlyZone")
    local ClientList = SET_CLIENT:New():FilterCoalitions("blue"):FilterCategories("plane"):FilterCategories("helicopter"):FilterActive(true):FilterStart()

    zone:Trigger(ClientList)

    function zone:OnAfterEnteredZone(From, Event, To, Controllable)
        if Controllable and Controllable:IsAlive() and not zones.khasab.wasBlue then
            BASE:I("OnAfterEnteredZone Triggered")
            local client = CLIENT:FindByName(Controllable:GetName())
            if client then
                MESSAGE:New("WARNING! YOU HAVE ENTERED A NO-FLY ZONE!\n\nYOUR NOT CLEARED TO ENTER THIS REGION YET. CAPTURE KHASAB FIRST!\n\nMAKE A 180 OR YOU WILL BE DESTROYED.\n\n90 SECONDS UNTIL DESTRUCTION", 30, Information, true):ToClient(client)

                ZoneTimers[Controllable:GetName()] = timer.scheduleFunction(function()
                    if Controllable and Controllable:IsAlive() and not zones.khasab.wasBlue then
                        local pos = Controllable:GetPositionVec3()
                        if pos then
                            trigger.action.explosion(pos, 100)
                            BASE:I("Explosion Triggered Triggered NoFlyZone")
                        end
                        ZoneTimers[Controllable:GetName()] = nil
                    end
                end, {}, timer.getTime() + 90)

                local countdownTime = 60
                local function countdown()
                    if Controllable and Controllable:IsAlive() and not zones.khasab.wasBlue then
                        MESSAGE:New("Time remaining until destruction: " .. countdownTime .. " seconds", 4, Information, true):ToClient(client)
                        countdownTime = countdownTime - 5

                        if countdownTime > 0 then
                            CountdownTimers[Controllable:GetName()] = timer.scheduleFunction(countdown, {}, timer.getTime() + 5)
                        else
                            CountdownTimers[Controllable:GetName()] = nil
                        end
                    else
                        CountdownTimers[Controllable:GetName()] = nil
                    end
                end

                CountdownTimers[Controllable:GetName()] = timer.scheduleFunction(countdown, {}, timer.getTime() + 30)
            end
        end
    end

    function zone:OnAfterLeftZone(From, Event, To, Controllable)
        if Controllable and Controllable:IsAlive() and not zones.khasab.wasBlue then
            local client = CLIENT:FindByName(Controllable:GetName())
            if client then
                MESSAGE:New("You're out of the no-fly zone. Good job!", 30, Information, true):ToClient(client)

                if ZoneTimers[Controllable:GetName()] then
                    timer.removeFunction(ZoneTimers[Controllable:GetName()])
                    ZoneTimers[Controllable:GetName()] = nil
                end

                if CountdownTimers[Controllable:GetName()] then
                    timer.removeFunction(CountdownTimers[Controllable:GetName()])
                    CountdownTimers[Controllable:GetName()] = nil
                end
            end
        end
    end
end
