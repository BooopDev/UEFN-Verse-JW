using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

checkpoint := class<concrete><unique>:
    @editable Volume:mutator_zone_device = mutator_zone_device{}
    @editable Teleporter:teleporter_device = teleporter_device{}
    @editable XboxLounge:logic = false
    var Time:float = 0.0
    var Index:int = 0

checkpoint_manager := class: # Instance created per player_data object

    var Checkpoints:[]checkpoint = array{}
    var ActiveCheckpointOP:?checkpoint = false
    var UnavailableHUDMessage:hud_message_device = hud_message_device{}
    var CheckpointHUDMessage:hud_message_device = hud_message_device{}

    var CurrentTime:float = 0.0
    var TimerRunning:logic = false
    StartTimer:event(float) = event(float){}
    StopTimer:event() = event(){}

    Initialize(PlayerData:player_data)<suspends>:void={
        set Checkpoints = for (Checkpoint:PlayerData.Core.Checkpoints): # Creates a copy instead of a grabbing a reference
            checkpoint:
                Volume := Checkpoint.Volume
                Teleporter := Checkpoint.Teleporter
                XboxLounge := Checkpoint.XboxLounge

        set UnavailableHUDMessage = PlayerData.Core.UnavailablePrompt
        set CheckpointHUDMessage = PlayerData.Core.CheckpointPrompt

        SetupCheckpoints(PlayerData)

        race:
            PlayerData.RemovedEvent.Await()
            TimerLoop(PlayerData)
    }

    SetupCheckpoints(PlayerData:player_data):void={
        if (Checkpoints.Length <> 10):
            Print("Incorrect Number of Race Sections: {Checkpoints.Length}")
            return

        for (Index -> Checkpoint:Checkpoints):
            set Checkpoint.Index = Index
            set Checkpoint.Time = PlayerData.Persistence.GetCheckpointTime(PlayerData.Player, Checkpoint.Index)

            Checkpoint.Volume.AgentEntersEvent.SubscribeAgent(OnRaceSectionEvent, (PlayerData, Checkpoint, true))
            Checkpoint.Volume.AgentExitsEvent.SubscribeAgent(OnRaceSectionEvent, (PlayerData, Checkpoint, false))

        for (Index -> Zone:PlayerData.Core.XboxLoungeTeleportZones):
            case (Index):
                0 => Zone.AgentEntersEvent.SubscribeAgent(TeleportToXboxLounge, (PlayerData, Checkpoints[3] or checkpoint{}))
                1 => Zone.AgentEntersEvent.SubscribeAgent(TeleportToXboxLounge, (PlayerData, Checkpoints[6] or checkpoint{}))
                2 => Zone.AgentEntersEvent.SubscribeAgent(TeleportToXboxLounge, (PlayerData, Checkpoints[9] or checkpoint{}))
                _ => {}
    }

    OnRaceSectionEvent(Agent:agent, Params:tuple(player_data, checkpoint, logic)):void={
        PlayerData := Params(0), Checkpoint := Params(1), IsEntered := Params(2)
        
        if (PlayerData.Player <> player[Agent]) then return
        if (not PlayerData.IsActive[]) then return
        if (PlayerData.CheatMode?) then return

        if (IsEntered?):
            OnEnterEvent(PlayerData, Checkpoint)
        else:
            OnExitEvent(PlayerData, Checkpoint)
    }

    OnEnterEvent(PlayerData:player_data, Checkpoint:checkpoint):void={
        StopTimer.Signal()

        if:
            ActiveCheckpoint := ActiveCheckpointOP? # Is There An Active Checkpoint?
            Checkpoint.Index = ActiveCheckpoint.Index + 1 # Have We Entered The Next Checkpoint?
        then:
            SaveCheckpointTime(PlayerData, Checkpoint)
        else:                
            LoadCheckpointTime(PlayerData, Checkpoint)
    }

    OnExitEvent(PlayerData:player_data, Checkpoint:checkpoint):void={
        if (Checkpoint.Index = Checkpoints.Length - 1) then return # Exiting Last Checkpoint So Do Nothing
        if (not ActiveCheckpointOP?) then return # No Active Checkpoint So Do Nothing
        if (PlayerData.CheatMode?) then return

        StartTimer.Signal(Checkpoint.Time)
    }

    SaveCheckpointTime(PlayerData:player_data, Checkpoint:checkpoint):void={
        if (PlayerData.CheatMode?) then return

        # Award xp if first time reaching checkpoint & its Xbox Lounge
        if (Checkpoint.Time = 0.0 and Checkpoint.XboxLounge?):
            PlayerData.Accolades.AwardXboxLoungeReached(PlayerData, Checkpoint)
            # Telemetry
            case (Checkpoint.Index):
                3 => PlayerData.Telemetry.Telemetry.PlayersReachedChillzone1.Submit(PlayerData.Player)
                6 => PlayerData.Telemetry.Telemetry.PlayersReachedChillzone2.Submit(PlayerData.Player)
                9 => PlayerData.Telemetry.Telemetry.PlayersReachedChillzone3.Submit(PlayerData.Player)
                _ => {}

        if (CurrentTime < Checkpoint.Time or Checkpoint.Time = 0.0):
            set Checkpoint.Time = CurrentTime
            case (Checkpoint.Index):
                3 => PlayerData.Accolades.AwardNewBestTime(PlayerData)
                6 => PlayerData.Accolades.AwardNewBestTime(PlayerData)
                9 => PlayerData.Accolades.AwardNewBestTime(PlayerData)
                _ => {}
        set ActiveCheckpointOP = option {Checkpoint}

        ShowCheckpointPrompt(PlayerData, Checkpoint)
        PlayerData.Interface.TimerUI.UpdateTime(Checkpoint.Time)
        PlayerData.Interface.MinimapUI.UpdateLocks(Checkpoint.Index)

        PlayerData.Persistence.SaveCheckpointTime(PlayerData, Checkpoint)

        Print(P2M(PlayerData.Player) + "reached checkpoint {Checkpoint.Index} in {Checkpoint.Time}")
    }

    LoadCheckpointTime(PlayerData:player_data, Checkpoint:checkpoint):void={
        if (not Checkpoint.IsAvailable()? or PlayerData.CheatMode?): # Clear Active Checkpoint If Current Checkpoint Is Not Valid
            set ActiveCheckpointOP = false
        else:
            set ActiveCheckpointOP = option {Checkpoint}
            set CurrentTime = Checkpoint.Time
            
            PlayerData.Interface.TimerUI.UpdateTime(CurrentTime)
            PlayerData.Interface.MinimapUI.UpdateLocks(Checkpoint.Index)

            Print(P2M(PlayerData.Player) + "loaded checkpoint {Checkpoint.Index} with {CurrentTime}")
    }

    (Checkpoint:checkpoint).IsAvailable()<transacts>:logic={
        if (Checkpoint.Index = 0) then return true

        for:
            Index := 1..Checkpoint.Index #Start At Index 1 To Skip Ground Checkpoint
            CheckpointTime := Checkpoints[Index].Time
        do:
            if (CheckpointTime = 0.0) then return false
        
        return true
    }

    GetLastCheckpoint():checkpoint={
        var CheckpointIndex:int = 0
        for (Index->Checkpoint:Checkpoints):
            if (Checkpoint.Time > 0.0) then set CheckpointIndex = Index

        return Checkpoints[CheckpointIndex] or checkpoint{}
    }

    ShowCheckpointPrompt(PlayerData:player_data, Checkpoint:checkpoint):void={
        PromptMessage := case (Checkpoint.Index):
            3=> S2M("Xbox Lounge 1 Reached in {Checkpoint.Time}!")
            6=> S2M("Xbox Lounge 2 Reached in {Checkpoint.Time}!")
            9=> S2M("Xbox Lounge 3 Reached in {Checkpoint.Time}!")
            _=> S2M("Checkpoint {Checkpoint.Index} Reached in {Checkpoint.Time.ToTime()}!")

        CheckpointHUDMessage.Show(PlayerData.Player, PromptMessage, ?DisplayTime := 5.0)
    }

    TeleportToCheckpoint(PlayerData:player_data, Checkpoint:checkpoint):void={
        if:
            Checkpoint.IsAvailable()?
            Checkpoint.Index <> 0
            Checkpoint.Time <> 0.0
        then:
            ResetClimb(PlayerData)
            set ActiveCheckpointOP = option {Checkpoint}
            Checkpoint.Teleporter.Teleport(PlayerData.Player)
            if (Checkpoint.XboxLounge?):
                case (Checkpoint.Index):
                    3 => PlayerData.Telemetry.Telemetry.Chillzone1TeleporterUsed.Submit(PlayerData.Player)
                    6 => PlayerData.Telemetry.Telemetry.Chillzone2TeleporterUsed.Submit(PlayerData.Player)
                    9 => PlayerData.Telemetry.Telemetry.Chillzone3TeleporterUsed.Submit(PlayerData.Player)
                    _ => {}
        else:
            if (Checkpoint.XboxLounge?):
                UnavailableHUDMessage.Show(PlayerData.Player, S2M("You Have Not Unlocked This Xbox Lounge Yet"), ?DisplayTime := 5.0)
            else:
                UnavailableHUDMessage.Show(PlayerData.Player, S2M("You Have Not Unlocked Any Checkpoints Yet"), ?DisplayTime := 5.0)
    }

    TeleportToXboxLounge(Agent:agent, Params:tuple(player_data, checkpoint)):void={
        if (player[Agent] <> Params(0).Player) then return
        TeleportToCheckpoint(Params(0), Params(1))
    }  

    TeleportToLatestCheckpoint(PlayerData:player_data):void={
        LastCheckpoint := GetLastCheckpoint()
        TeleportToCheckpoint(PlayerData, LastCheckpoint)
    }

    ResetClimb(PlayerData:player_data):void={
        StopTimer.Signal()
        set ActiveCheckpointOP = false
        set PlayerData.CurrentTileZone = false
    }

    TimerLoop(PlayerData:player_data)<suspends>:void={
        loop:
            set TimerRunning = false
            CheckpointTime := StartTimer.Await()
            StartTime := GetSimulationElapsedTime() - CheckpointTime
            set TimerRunning = true

            race:
                block:
                    StopTimer.Await()
                    set CurrentTime = GetSimulationElapsedTime() - StartTime
                loop:
                    DelayTicks(1)
                    set CurrentTime = GetSimulationElapsedTime() - StartTime
                    PlayerData.Interface.TimerUI.UpdateTime(CurrentTime)
    }