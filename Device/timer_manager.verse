using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

timer_manager := class(creative_device)
{
    @editable
    StartTimerTrigger<private>:trigger_device = trigger_device{}

    @editable
    StopTimerTrigger<private>:trigger_device = trigger_device{}

    @editable
    ResetTimerTrigger<private>:trigger_device = trigger_device{}

    @editable
    StopAndHideTimerTrigger<private>:trigger_device = trigger_device{}

    @editable
    TimerHud<private>:hud_message_device = hud_message_device{}

    @editable
    ShowHours<private>:logic = false

    @editable
    ShowDecimalFraction<private>:logic = false

    @editable
    UpdateDisplayTextOnReset<private>:logic = false

    var PlayerTimers<private>:[player]player_timer = map{}

    OnBegin<override>()<suspends>:void =

        StartTimerTrigger.TriggeredEvent.Subscribe(OnTriggeredStartTimer)

        StopTimerTrigger.TriggeredEvent.Subscribe(OnTriggeredStopTimer)

        ResetTimerTrigger.TriggeredEvent.Subscribe(OnTriggeredResetTimer)

        StopAndHideTimerTrigger.TriggeredEvent.Subscribe(OnTriggeredStopAndHideTimer)

    OnTriggeredStartTimer<private>(TriggeredAgent:?agent):void =
        
        if(Agent := TriggeredAgent?)
        {
            if(Player := player[Agent])
            {
                if(PlayerTimer := PlayerTimers[Player])
                {
                    PlayerTimer.PrepareStartTimer(Agent, TimerHud, Self, ShowHours, ShowDecimalFraction)
                }
                else
                {
                    CreatedPlayerTimer := player_timer{}

                    if(set PlayerTimers[Player] = CreatedPlayerTimer)
                    {
                        CreatedPlayerTimer.PrepareStartTimer(Agent, TimerHud, Self, ShowHours, ShowDecimalFraction)
                    }
                    else
                    {
                        Print("Failed to create a player_timer class instance.")
                    }
                }
            }
        }

    OnTriggeredStopTimer<private>(TriggeredAgent:?agent):void =

        if(Agent := TriggeredAgent?)
        {
            if(Player := player[Agent])
            {
                if(PlayerTimer := PlayerTimers[Player])
                {
                    PlayerTimer.StopTimer()
                }
            }
        }

    OnTriggeredResetTimer<private>(TriggeredAgent:?agent):void =
        
        if(Agent := TriggeredAgent?)
        {
            if(Player := player[Agent])
            {
                if(PlayerTimer := PlayerTimers[Player])
                {
                    PlayerTimer.ResetTimer(Agent, UpdateDisplayTextOnReset)
                }
            }
        }

    OnTriggeredStopAndHideTimer<private>(TriggeredAgent:?agent):void =
        
        if(Agent := TriggeredAgent?)
        {
            if(Player := player[Agent])
            {
                if(PlayerTimer := PlayerTimers[Player])
                {
                    PlayerTimer.StopAndHideTimer(Agent)
                }
            }
        }

    DestroyInvalidPlayerTimer<public>():void =

        var NewPlayerTimers:[player]player_timer = map{}

        for (Player -> PlayerTimer : PlayerTimers)
        {
            if(Player.IsActive[])
            {
                set NewPlayerTimers = ConcatenateMaps(NewPlayerTimers, map{Player => PlayerTimer})
            }
            else
            {
                if(InvalidPlayerTimer := PlayerTimers[Player])
                {
                    InvalidPlayerTimer.StopTimer()
                }
                else
                {
                    Print("Failed to get a player_timer class instance of the invalid player.")
                }
            }
        }

        set PlayerTimers = NewPlayerTimers
}

player_timer := class
{
    var CurrentTime<private>:float = 0.0

    var TimerIsActive<private>:logic = false

    var TimerHud<private>:hud_message_device = hud_message_device{}

    var TimerManager:timer_manager = timer_manager{}

    var ShowHours<private>:logic = false
    
    var ShowDecimalFraction<private>:logic = false

    PrepareStartTimer<public>(OwnerAgent:agent, _TimerHud:hud_message_device, _TimerManager:timer_manager, _ShowHours:logic, _ShowDecimalFraction:logic):void =

        if(TimerIsActive?)
        {
            return
        }
        
        set TimerIsActive = true
        set TimerHud = _TimerHud
        set TimerManager = _TimerManager
        set ShowHours = _ShowHours
        set ShowDecimalFraction = _ShowDecimalFraction

        UpdateTimerText(OwnerAgent)

        spawn
        {
            StartTimer(OwnerAgent)
        }
    
    StartTimer<private>(OwnerAgent:agent)<suspends>:void =

        UpdateSpan:float = 0.1

        loop
        {
            if(TimerIsActive?)
            {
                set CurrentTime += UpdateSpan

                UpdateTimerText(OwnerAgent)
                
                Sleep(UpdateSpan)
            }
            else
            {
                break
            }
        }

    StopAndHideTimer<public>(OwnerAgent:agent):void =

        StopTimer()

        TimerHud.Hide(OwnerAgent)

    StopTimer<public>():void =

        set TimerIsActive = false

    ResetTimer<public>(OwnerAgent:agent, UpdateDisplayText:logic):void =

        set CurrentTime = 0.0

        if(UpdateDisplayText?)
        {
            UpdateTimerText(OwnerAgent)
        }

    UpdateTimerText<private>(OwnerAgent:agent):void =

        if(TimerIsActive?)
        {
            if(Player := player[OwnerAgent])
            {
                if(Player.IsActive[])
                {
                    TimerHud.Show(OwnerAgent, StringToMessage(GetCurrentTimerText()))
                }
                else
                {
                    TimerManager.DestroyInvalidPlayerTimer()
                }
            }
            else
            {
                TimerManager.DestroyInvalidPlayerTimer()
            }
        }

    StringToMessage<private><localizes>(StringValue:string):message = "{StringValue}"
    
    GetCurrentTimerText<private>():string =

        var CurrentTimerText:string = GetCurrentMinutesText() + ":" + GetCurrentSecondsText()

        if(ShowHours?)
        {
            set CurrentTimerText = GetCurrentHoursText() + ":" + CurrentTimerText
        }

        if(ShowDecimalFraction?)
        {
            set CurrentTimerText += "." + GetCurrentDecimalFractionText()
        }

        return CurrentTimerText

    GetCurrentHoursText<private>():string =
        
        var HoursText:string = ""

        if(Hours := Int[CurrentTime / 3600.0])
        {
            if(Hours < 10)
            {
                set HoursText = "0" + ToString(Hours)
            }
            else
            {
                set HoursText = ToString(Hours)
            }
        }

        return HoursText
    
    GetCurrentMinutesText<private>():string =

        var MinutesText:string = ""

        if(Minutes := Int[CurrentTime / 60.0])
        {
            if(Minutes < 10)
            {
                set MinutesText = "0" + ToString(Minutes)
            }
            else
            {
                if(ShowHours?)
                {
                    if(Hours := Int[(Minutes * 1.0) / 60.0])
                    {
                        TwoDigitMinutes:int = Minutes - (Hours * 60)

                        if(TwoDigitMinutes < 10)
                        {
                            set MinutesText = "0" + ToString(TwoDigitMinutes)
                        }
                        else
                        {
                            set MinutesText = ToString(TwoDigitMinutes)
                        }
                    }
                }
                else
                {
                    set MinutesText = ToString(Minutes)
                }
            }
        }

        return MinutesText

    GetCurrentSecondsText<private>():string =
        
        var SecondsText:string = ""

        if(Minutes := Int[CurrentTime / 60.0])
        {
            if(Seconds := Int[CurrentTime - (Minutes * 60.0)])
            {
                if(Seconds < 10)
                {
                    set SecondsText = "0" + ToString(Seconds)
                }
                else
                {
                    set SecondsText = ToString(Seconds)
                }
            }
        }

        return SecondsText

    GetCurrentDecimalFractionText<private>():string =

        var DecimalFractionText:string = ""

        if(CurrentTimeInt := Int[CurrentTime])
        {
            var DecimalFraction:float = 0.0
            
            set DecimalFraction = CurrentTime - (CurrentTimeInt * 1.0)

            if(DecimalFractionInt := Int[DecimalFraction * 10.0])
            {
                set DecimalFractionText = ToString(DecimalFractionInt)
            }
        }

        return DecimalFractionText
}