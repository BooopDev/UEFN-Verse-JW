using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

telemetry := class<concrete>:
    @editable PlayersJoined:analytics_device = analytics_device{} # Done
    @editable CollectiblesUIOpened:analytics_device = analytics_device{} # Done

    @editable ListeningStationTrigger: trigger_device = trigger_device{}
    @editable UniqueListeningStationActivations:analytics_device = analytics_device{} # Done
    @editable TotalListeningStationActivations:analytics_device = analytics_device{} # Done

    @editable CollectiblesCollected:analytics_device = analytics_device{} # Done

    @editable CollectiblesCollected10:analytics_device = analytics_device{} # Done
    @editable CollectiblesCollected20:analytics_device = analytics_device{} # Done
    @editable CollectiblesCollected30:analytics_device = analytics_device{} # Done
    @editable CollectiblesCollected40:analytics_device = analytics_device{} # Done

    @editable Collected10CollectiblesIn15Mins:analytics_device = analytics_device{}
    @editable Collected10CollectiblesIn45Mins:analytics_device = analytics_device{}
    @editable Collected20CollectiblesIn30Mins:analytics_device = analytics_device{}
    @editable Collected20CollectiblesIn60Mins:analytics_device = analytics_device{}
    @editable Collected40CollectiblesIn60Mins:analytics_device = analytics_device{}
    @editable Collected40CollectiblesIn120Mins:analytics_device = analytics_device{}

    @editable PlayersReachedChillzone1:analytics_device = analytics_device{} # Done
    @editable PlayersReachedChillzone2:analytics_device = analytics_device{} # Done
    @editable PlayersReachedChillzone3:analytics_device = analytics_device{} # Done

    @editable PlayersReachedChillzone1In10Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone1In15Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone1In20Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone1In30Mins:analytics_device = analytics_device{}

    @editable PlayersReachedChillzone2In10Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone2In15Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone2In20Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone2In30Mins:analytics_device = analytics_device{}

    @editable PlayersReachedChillzone3In10Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone3In15Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone3In20Mins:analytics_device = analytics_device{}
    @editable PlayersReachedChillzone3In30Mins:analytics_device = analytics_device{}

    @editable Spent3MinsInChillzone1:analytics_device = analytics_device{}
    @editable Spent6MinsInChillzone1:analytics_device = analytics_device{}
    @editable Spent10MinsInChillzone1:analytics_device = analytics_device{}

    @editable Spent3MinsInChillzone2:analytics_device = analytics_device{}
    @editable Spent6MinsInChillzone2:analytics_device = analytics_device{}
    @editable Spent10MinsInChillzone2:analytics_device = analytics_device{}

    @editable Spent3MinsInChillzone3:analytics_device = analytics_device{}
    @editable Spent6MinsInChillzone3:analytics_device = analytics_device{}
    @editable Spent10MinsInChillzone3:analytics_device = analytics_device{}

    @editable Chillzone1Restarts2:analytics_device = analytics_device{}
    @editable Chillzone1Restarts5:analytics_device = analytics_device{}
    @editable Chillzone1Restarts10:analytics_device = analytics_device{}

    @editable Chillzone2Restarts2:analytics_device = analytics_device{}
    @editable Chillzone2Restarts5:analytics_device = analytics_device{}
    @editable Chillzone2Restarts10:analytics_device = analytics_device{}

    @editable Chillzone3Restarts2:analytics_device = analytics_device{}
    @editable Chillzone3Restarts5:analytics_device = analytics_device{}
    @editable Chillzone3Restarts10:analytics_device = analytics_device{}

    @editable Chillzone1TeleporterUsed:analytics_device = analytics_device{} # Done
    @editable Chillzone2TeleporterUsed:analytics_device = analytics_device{} # Done
    @editable Chillzone3TeleporterUsed:analytics_device = analytics_device{} # Done

telemetry_flags := class<unique>:
    var UsedListeningStationInSession:logic = false

telemetry_manager := class:
    var Telemetry:telemetry = telemetry{} # Reference, not copy
    var Flags:telemetry_flags = telemetry_flags{}

    Initialize(PlayerData:player_data)<suspends>:void={
        set Telemetry = PlayerData.Core.Telemetry
        Telemetry.ListeningStationTrigger.TriggeredEvent.SubscribeAgentOptional(ListeningStationActivation, PlayerData)
    }

    ListeningStationActivation(OptionalAgent: ?agent, PlayerData:player_data):void={
        if (not PlayerData.Telemetry.Flags.UsedListeningStationInSession?):
            Telemetry.UniqueListeningStationActivations.Submit(PlayerData.Player)
            set PlayerData.Telemetry.Flags.UsedListeningStationInSession = true
        Telemetry.TotalListeningStationActivations.Submit(PlayerData.Player)
    }