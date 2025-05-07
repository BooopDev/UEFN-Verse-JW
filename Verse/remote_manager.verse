using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }

remote_manager := class<concrete>:

    @editable RespawnTrigger:trigger_device = trigger_device{}
    @editable CollectibleMenuTrigger:trigger_device = trigger_device{}
    @editable LoadLastCheckpointTrigger:trigger_device = trigger_device{}
    @editable CheatModeRemover:item_remover_device = item_remover_device{}
    @editable SpawnTeleporter:teleporter_device = teleporter_device{}
    @editable ResetDataPopup:popup_dialog_device = popup_dialog_device{}

    var CoreOP:?core_device = false

    Initialize(Core:core_device):void={
        set CoreOP = option {Core}
        RespawnTrigger.TriggeredEvent.Subscribe(OnRespawn)
        CollectibleMenuTrigger.TriggeredEvent.Subscribe(OnCollectibleMenu)
        LoadLastCheckpointTrigger.TriggeredEvent.Subscribe(OnLoadLastCheckpoint)
        ResetDataPopup.RespondingButtonEvent.Subscribe(ResetData)
    }

    OnRespawn(AgentOP:?agent):void={
        if:
            Player := player[AgentOP?]
            PlayerData := CoreOP?.PlayerDataMap[Player]
            PlayerData.IsActive[]
            CheatModeHUDMessage := CoreOP?.CheatModePrompt
        then:
            CheatModeHUDMessage.Hide(Player)
            CheatModeRemover.Remove(Player)
            set PlayerData.CheatMode = false
            PlayerData.Checkpoints.ResetClimb(PlayerData)
            SpawnTeleporter.Teleport(Player)
            PlayerData.Accolades.IncrementAttemptAndAwardIfDue(PlayerData)
    }

    OnCollectibleMenu(AgentOP:?agent):void={
        if:
            Player := player[AgentOP?]
            PlayerData := CoreOP?.PlayerDataMap[Player]
            PlayerData.IsActive[]
        then:
            PlayerData.Interface.CollectiblesUI.UpdateCanvas()
            PlayerData.Interface.CollectiblesUI.ShowInteractive()
            PlayerData.Telemetry.Telemetry.CollectiblesUIOpened.Submit(Player)
    }

    OnLoadLastCheckpoint(AgentOP:?agent):void={
        if:
            Player := player[AgentOP?]
            PlayerData := CoreOP?.PlayerDataMap[Player]
            PlayerData.IsActive[]
        then:
            Print(P2M(PlayerData.Player) + "Loaded Last Checkpoint")
            PlayerData.Checkpoints.TeleportToLatestCheckpoint(PlayerData)
            PlayerData.Accolades.IncrementAttemptAndAwardIfDue(PlayerData)
    }

    ResetData(Agent:agent, ButtonIndex:int):void=
        if (ButtonIndex = 0, Core:= CoreOP?, Player:= player[Agent]):
            Core.PersistenceManager.ResetData(Player)
            Core.UnavailablePrompt.Show(Player, S2M("DATA RESET\nRejoin the island to see your changes"))