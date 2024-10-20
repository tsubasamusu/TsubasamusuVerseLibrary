using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

look_player_prop_manager := class(creative_device)
{
    @editable
    UpdateSpan<private>:float = 0.01

    @editable
    StartFollowingTrigger<private>:trigger_device = trigger_device{}

    @editable
    StopFollowingTrigger<private>:trigger_device = trigger_device{}

    @editable
    TargetPropDataArray<private>:[]prop_data = array{}

    var IsFollowing<private>:logic = false

    OnBegin<override>()<suspends>:void =

        StartFollowingTrigger.TriggeredEvent.Subscribe(OnTriggeredStartFollowing)

        StopFollowingTrigger.TriggeredEvent.Subscribe(OnTriggeredStopFollowing)

    OnTriggeredStartFollowing<private>(TriggeredAgent:?agent):void =
        
        if(IsFollowing?)
        {
            return
        }

        if(Agent := TriggeredAgent?)
        {
            spawn
            {
                StartFollowing(Agent)
            }
        }

    StartFollowing<private>(TargetAgent:agent)<suspends>:void=
        
        if(TargetCharacter:fort_character = TargetAgent.GetFortCharacter[])
        {
            set IsFollowing = true
    
            loop
            {
                if(IsFollowing?)
                {
                    if(Player := player[TargetAgent])
                    {
                        if(Player.IsActive[])
                        {
                            for(TargetPropData : TargetPropDataArray)
                            {
                                PropLocation := TargetPropData.TargetProp.GetTransform().Translation
        
                                CharacterLocation := TargetCharacter.GetTransform().Translation
        
                                if(LookDirection := (CharacterLocation - PropLocation).MakeUnitVector[])
                                {
                                    var Yaw:float = 0.0
                                    var Pitch:float = 0.0
        
                                    if(TargetPropData.RotateYaw?)
                                    {
                                        set Yaw = RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X))
                                    }
        
                                    if(TargetPropData.RotatePitch?)
                                    {
                                        set Pitch = RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
                                    }
        
                                    NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, 0.0)
                                    
                                    TargetPropData.TargetProp.MoveTo(PropLocation, NewRotation, UpdateSpan)
                                }
                            }
                        }
                        else
                        {
                            StopFollowing()
    
                            break
                        }
                    }
                    else
                    {
                        StopFollowing()

                        break
                    }

                    Sleep(UpdateSpan)
                }
                else
                {
                    break
                }
            }
        }

    OnTriggeredStopFollowing<private>(TriggeredAgent:?agent):void =

        if(Agent := TriggeredAgent?)
        {
            StopFollowing()
        }

    StopFollowing<private>():void =

        set IsFollowing = false
}

prop_data := class<concrete>
{
    @editable
    TargetProp<public>:creative_prop = creative_prop{}

    @editable
    RotateYaw<public>:logic = true

    @editable
    RotatePitch<public>:logic = true
}