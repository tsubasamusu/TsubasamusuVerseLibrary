using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

look_player_prop_manager := class(creative_device)
{
    @editable
    UpdateSpan:float = 0.01

    @editable
    StartFollowingTrigger:trigger_device = trigger_device{}

    @editable
    StopFollowingTrigger:trigger_device = trigger_device{}

    @editable
    TargetPropDataArray:[]prop_data = array{}

    var IsFollowing:logic = false

    OnBegin<override>()<suspends>:void =

        StartFollowingTrigger.TriggeredEvent.Subscribe(PrepareStartFollowing)
        StopFollowingTrigger.TriggeredEvent.Subscribe(StopFollowing)

    PrepareStartFollowing(TriggeredAgent:?agent):void =
        
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

    StartFollowing(TargetAgent:agent)<suspends>:void=
        
        if(TargetCharacter:fort_character = TargetAgent.GetFortCharacter[])
        {
            set IsFollowing = true
    
            loop:
                
                if(IsFollowing?)
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

                    Sleep(UpdateSpan)
                }
                else
                {
                    break
                }
        }

    StopFollowing(TriggeredAgent:?agent):void =

        set IsFollowing = false
}

prop_data<public> := class<concrete>
{
    @editable
    TargetProp:creative_prop = creative_prop{}

    @editable
    RotateYaw:logic = true

    @editable
    RotatePitch:logic = true
}