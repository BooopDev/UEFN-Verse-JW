using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
var PlayerPersistenceMap: weak_map(player, persistent_player_data) = map{}

persistent_player_data := class<final><persistable>:
    Version:int = 0

    CheckpointTimes:[]float = for (I := 0..9) do 0.0
    BestHeight:float = 0.0
    BestHeightTime:float = 0.0

    Collectibles:[]logic = for (I := 0..39) do false

    TimesReachedChillzone1: int = 0
    TimesReachedChillzone2: int = 0
    TimesReachedChillzone3: int = 0

    AttemptsMade: int = 0

    GameBeaten:logic = false

ConstructPersistentPlayerData<constructor>(OldPersistentData:persistent_player_data)<transacts> :={
    persistent_player_data:
        Version := OldPersistentData.Version
        CheckpointTimes := OldPersistentData.CheckpointTimes
        BestHeight := OldPersistentData.BestHeight
        BestHeightTime := OldPersistentData.BestHeightTime
        Collectibles := OldPersistentData.Collectibles
        TimesReachedChillzone1 := OldPersistentData.TimesReachedChillzone1
        TimesReachedChillzone2 := OldPersistentData.TimesReachedChillzone2
        TimesReachedChillzone3 := OldPersistentData.TimesReachedChillzone3
        AttemptsMade := OldPersistentData.AttemptsMade
        GameBeaten := OldPersistentData.GameBeaten
}

persistence_manager := class:

    ResetData(Player:player):void=
        if (set PlayerPersistenceMap[Player] = persistent_player_data{}){}

    MigrateExistingData(Player:player)<transacts>:persistent_player_data={
        if (NewData := PlayerPersistenceMap[Player]):
            return NewData
        else if (OldData := PersistantMap[Player]):
            return persistent_player_data:
                Version := OldData.Version
                CheckpointTimes := ConvertOldToNewTimes(OldData.SectionsTime)
                BestHeight := OldData.ClimbBest.Height
                BestHeightTime := OldData.ClimbBest.Time
                Collectibles := for (Value:OldData.CollectiblesMap) do Value
                TimesReachedChillzone1 := OldData.TimesReachedChillzone1
                TimesReachedChillzone2 := OldData.TimesReachedChillzone2
                TimesReachedChillzone3 := OldData.TimesReachedChillzone3
                AttemptsMade := OldData.AttemptsMade
                GameBeaten := OldData.GameBeaten
        else:
            return persistent_player_data{}
    }

    ConvertOldToNewTimes(OldTimes:[]float)<transacts>:[]float={
        OffsetTimes := array{0.0} + OldTimes
        for (Index := 0..9):
            var NewTime:float = 0.0
            for (I := 0..Index, OldTime := OffsetTimes[I]) do set NewTime += OldTime
            NewTime
    }

    SaveCheckpointTime(PlayerData:player_data, Index:int, Time:float):void={
        if (not PlayerData.Player.IsActive[] or PlayerData.CheatMode?) then return

        OldPersistentData := PlayerPersistenceMap[PlayerData.Player] or persistent_player_data{}

        OldCheckpointTimes := OldPersistentData.CheckpointTimes
        NewCheckpointTimes := OldCheckpointTimes.ReplaceElement[Index, Time] or OldCheckpointTimes

        NewPersistentData := persistent_player_data:
            ConstructPersistentPlayerData<constructor>(OldPersistentData)
            CheckpointTimes := NewCheckpointTimes
            GameBeaten := if (Index = 9) then true else OldPersistentData.GameBeaten

        if (set PlayerPersistenceMap[PlayerData.Player] = NewPersistentData){}
    }

    SaveCheckpointTime(PlayerData:player_data, Checkpoint:checkpoint):void={
        SaveCheckpointTime(PlayerData, Checkpoint.Index, Checkpoint.Time)
    }

    GetCheckpointTime(Player:player, Index:int)<transacts>:float={
        if (not Player.IsActive[]) then 0.0
        PlayerPersistenceMap[Player].CheckpointTimes[Index] or 0.0
    }

    GetAllCheckpointTimes(Player:player):[]float={
        if (not Player.IsActive[]) then 0.0
        PlayerPersistenceMap[Player].CheckpointTimes or array{}
    }

    SaveBestHeight(PlayerData:player_data, BestHeight:float, BestHeightTime:float):void={
        if (not PlayerData.Player.IsActive[] or PlayerData.CheatMode?) then return

        OldPersistentData := PlayerPersistenceMap[PlayerData.Player] or persistent_player_data{}

        NewPersistentData := persistent_player_data:
            ConstructPersistentPlayerData<constructor>(OldPersistentData)
            BestHeight := BestHeight
            BestHeightTime := BestHeightTime

        if (set PlayerPersistenceMap[PlayerData.Player] = NewPersistentData){}
    }

    GetBestHeight(Player:player):tuple(float, float)={
        if (not Player.IsActive[]) then (0.0, 0.0)
        (PlayerPersistenceMap[Player].BestHeight or 0.0, PlayerPersistenceMap[Player].BestHeightTime or 0.0)
    }

    SaveCollectible(PlayerData:player_data, ID:int):void=
        if (not PlayerData.Player.IsActive[] or PlayerData.CheatMode?) then return

        OldPersistentData := PlayerPersistenceMap[PlayerData.Player] or persistent_player_data{}

        OldCollectibles := OldPersistentData.Collectibles
        NewCollectibles := OldCollectibles.ReplaceElement[ID, true] or OldCollectibles

        # Only triggers when new collectible is unlocked
        if (OldCollectibleState := OldCollectibles[ID], not OldCollectibleState?):
            PlayerData.Accolades.AwardCdOrMemoribiliaIfDue(PlayerData, NewCollectibles, ID)
            PlayerData.Telemetry.Telemetry.CollectiblesCollected.Submit(PlayerData.Player)

        NewPersistentData := persistent_player_data:
            ConstructPersistentPlayerData<constructor>(OldPersistentData)
            Collectibles := NewCollectibles
        
        if (set PlayerPersistenceMap[PlayerData.Player] = NewPersistentData){}

    GetTotalCollectibles(Player:player):int={
        if (not Player.IsActive[]) then 0
        TotalCollected:[]logic = for (L:PlayerPersistenceMap[Player].Collectibles, L?) do L
        return TotalCollected.Length
    }
    
    IncrementAttempts(PlayerData: player_data):int={
        if (not PlayerData.Player.IsActive[] or PlayerData.CheatMode?) then return 0
        OldPersistentData := PlayerPersistenceMap[PlayerData.Player] or persistent_player_data{}

        NewPersistentData := persistent_player_data:
            ConstructPersistentPlayerData<constructor>(OldPersistentData)
            AttemptsMade := OldPersistentData.AttemptsMade + 1
        
        if (set PlayerPersistenceMap[PlayerData.Player] = NewPersistentData){}
        
        return OldPersistentData.AttemptsMade + 1
    }
    
    GetTotalAttempts(Player:player):int={
        if (not Player.IsActive[]) then return 0
        return PlayerPersistenceMap[Player].AttemptsMade or 0
    }
