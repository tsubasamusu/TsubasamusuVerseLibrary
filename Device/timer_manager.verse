using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }

timer_manager := class(creative_device)
{
    @editable
    StartTimerTrigger:trigger_device = trigger_device{}

    @editable
    StopTimerTrigger:trigger_device = trigger_device{}

    @editable
    ResetTimerTrigger:trigger_device = trigger_device{}

    @editable
    StopAndHideTimerTrigger:trigger_device = trigger_device{}

    @editable
    TimerHud:hud_message_device = hud_message_device{}

    @editable
    UpdateSpan:float = 0.1

    @editable
    ShowDecimalPlace:int = 0

    @editable
    ShowHours:logic = false

    var PlayerTimers:[player]player_timer = map{}

    OnBegin<override>()<suspends>:void =

        StartTimerTrigger.TriggeredEvent.Subscribe(OnTriggeredStartTimer)

        StopTimerTrigger.TriggeredEvent.Subscribe(OnTriggeredStopTimer)

        ResetTimerTrigger.TriggeredEvent.Subscribe(OnTriggeredResetTimer)

        StopAndHideTimerTrigger.TriggeredEvent.Subscribe(OnTriggeredStopAndHideTimer)

    OnTriggeredStartTimer(TriggeredAgent:?agent):void =
        
        if(Agent := TriggeredAgent?)
        {
            if(Player := player[Agent])
            {
                if(PlayerTimer := PlayerTimers[Player])
                {
                    PlayerTimer.PrepareStartTimer(Agent, TimerHud, UpdateSpan, ShowDecimalPlace, ShowHours)
                }
                else
                {
                    CreatedPlayerTimer := player_timer{}

                    if(set PlayerTimers[Player] = CreatedPlayerTimer)
                    {
                        CreatedPlayerTimer.PrepareStartTimer(Agent, TimerHud, UpdateSpan, ShowDecimalPlace, ShowHours)
                    }
                    else
                    {
                        Print("Failed to create a player_timer class instance.")
                    }
                }
            }
        }

    OnTriggeredStopTimer(TriggeredAgent:?agent):void =

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

    OnTriggeredResetTimer(TriggeredAgent:?agent):void =
        
        if(Agent := TriggeredAgent?)
        {
            if(Player := player[Agent])
            {
                if(PlayerTimer := PlayerTimers[Player])
                {
                    PlayerTimer.ResetTimer(Agent)
                }
            }
        }

    OnTriggeredStopAndHideTimer(TriggeredAgent:?agent):void =
        
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
}

player_timer := class
{
    var CurrentTime:float = 0.0

    var TimerIsActive:logic = false

    var ShowHours:logic = false
    
    var ShowDecimalPlace:int = 0
    
    var TimerHud:hud_message_device = hud_message_device{}

    PrepareStartTimer(OwnerAgent:agent, _TimerHud:hud_message_device, UpdateSpan:float, _ShowDecimalPlace:int, _ShowHours:logic):void =

        if(TimerIsActive?)
        {
            return
        }
        
        set TimerIsActive = true
        set TimerHud = _TimerHud
        set ShowHours = _ShowHours
        set ShowDecimalPlace = _ShowDecimalPlace

        UpdateTimerText(OwnerAgent)

        spawn
        {
            StartTimer(OwnerAgent, UpdateSpan)
        }
    
    StartTimer(OwnerAgent:agent, UpdateSpan:float)<suspends>:void =

        loop
        {
            if(TimerIsActive?)
            {
                set CurrentTime += 10.0

                UpdateTimerText(OwnerAgent)
                
                Sleep(UpdateSpan)
            }
            else
            {
                break
            }
        }

    StopAndHideTimer(OwnerAgent:agent):void =

        StopTimer()

        TimerHud.Hide(OwnerAgent)

    StopTimer():void =

        set TimerIsActive = false

    ResetTimer(OwnerAgent:agent):void =

        set CurrentTime = 0.0

    UpdateTimerText(OwnerAgent:agent):void =

        TimerHud.Show(OwnerAgent, StringToMessage(GetCurrentTimerText()))

    StringToMessage<localizes>(StringValue:string):message = "{StringValue}"
    
    GetCurrentTimerText():string =

        var CurrentTimerText:string = GetCurrentMinutesText() + ":" + GetCurrentSecondsText()

        if(ShowHours?)
        {
            set CurrentTimerText = GetCurrentHoursText() + ":" + CurrentTimerText
        }

        if(ShowDecimalPlace > 0)
        {
            set CurrentTimerText += "." + GetCurrentDecimalFractionText()
        }

        return CurrentTimerText

    GetCurrentHoursText():string =
        
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
    
    GetCurrentMinutesText():string =

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

    GetCurrentSecondsText():string =
        
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

    GetCurrentDecimalFractionText():string =

        var DecimalFractionText:string = ""

        if(Integer := Int[CurrentTime])
        {
            var DecimalFraction:float = 0.0
            
            set DecimalFraction = CurrentTime - (Integer * 1.0)

            if(DecimalFractionInt := Int[DecimalFraction * (ShowDecimalPlace * 10.0)])
            {
                set DecimalFractionText = ToString(DecimalFractionInt)
            }
        }

        return DecimalFractionText
}