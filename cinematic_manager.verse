using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

cinematic_manager := class(creative_device):
    
    @editable var SequenceDevices:[]cinematic_sequence_device = array{}
    @editable PlayerStasis:logic = true
    @editable InputTrigger:input_trigger_device = input_trigger_device{}
    @editable Trigger:trigger_device = trigger_device{}
    @editable AudioMix:audio_mixer_device = audio_mixer_device{}
    StopEvent:event(agent) = event(agent){}
    var ActivePlayers:[]player = array{}
 
    PlayCinematic(Player:player):void = spawn{Player.PlaySequence()}
    
    PlayTriggeredCinematic(Agent:?agent):void= 
        if(Player := player[Agent?]) then spawn{Player.PlaySequence()}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(PlayTriggeredCinematic)
 
    (Agent:agent).ReturnSequence()<transacts><decides>:cinematic_sequence_device=
        SelectedSequenceDevice := SequenceDevices[0]
        set SequenceDevices = for (Index -> SequenceDevice : SequenceDevices, Index <> 0):
            SequenceDevice
 
        SelectedSequenceDevice
 
    (Player:player).PlaySequence()<suspends>:void=
        if (ActivePlayers.Find[Player]) then return
        
        set ActivePlayers += array{Player}
        InputTrigger.Unregister(Player)
        AudioMix.Register(Player)
        if (Sequence := Player.ReturnSequence[], FortCharacter := Player.GetFortCharacter[]):
            if (PlayerStasis?):
                FortCharacter.PutInStasis(stasis_args{})
            Sequence.Play(Player)

            race:
                Sequence.StoppedEvent.Await()
                PlayerSkipEvent(Player)

            InputTrigger.Register(Player)
            AudioMix.Unregister(Player)
            FortCharacter.ReleaseFromStasis()
            set SequenceDevices += array{Sequence}
            set ActivePlayers = ActivePlayers.RemoveAllElements(Player)
            StopEvent.Signal(Player)

    PlayerSkipEvent(Player:player)<suspends>:void=
        loop:
            InputAgent := InputTrigger.PressedEvent.Await()
            if (InputAgent = Player). break