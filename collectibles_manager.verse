using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

collectibles_manager := class:

    var CoreOP:?core_device = false

    Initialize(Core:core_device):void={
        set CoreOP = option {Core}
        for (Index -> Collectible:Core.Collectibles):
            Collectible.CollectedEvent.SubscribeAgent(OnCollected, Index)
    }

    OnCollected(Agent:agent, ID:int):void={
        if:
            Player := player[Agent]
            Core := CoreOP?
            PlayerData := Core.PlayerDataMap[Player]
            PersistenceManager := Core.PersistenceManager
        then:
            PreviousTotal := PersistenceManager.GetTotalCollectibles(PlayerData.Player)
            PersistenceManager.SaveCollectible(PlayerData, ID)
            Total := PersistenceManager.GetTotalCollectibles(PlayerData.Player)
            if (PreviousTotal <> Total):
                case (Total):
                    10 => PlayerData.Telemetry.Telemetry.CollectiblesCollected10.Submit(Player)
                    20 => PlayerData.Telemetry.Telemetry.CollectiblesCollected20.Submit(Player)
                    30 => PlayerData.Telemetry.Telemetry.CollectiblesCollected30.Submit(Player)
                    40 => PlayerData.Telemetry.Telemetry.CollectiblesCollected40.Submit(Player)
                    _ => {}
            PlayerData.Interface.MinimapUI.UpdateCollectibles(Total)
    }

