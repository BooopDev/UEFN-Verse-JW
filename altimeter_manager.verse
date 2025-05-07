using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

altimeter_manager := class: # Instance created per player_data object

    BaseHeight:float = 77.0
    var OldHeight:float = 0.0 
    var CurrentHeight:float = 0.0
    var BestHeight:float = 0.0
    var BestHeightTime:float = 0.0

    Initialize(PlayerData:player_data)<suspends>:void={
        HeightData := PlayerData.Persistence.GetBestHeight(PlayerData.Player)

        set BestHeight = HeightData(0)
        set BestHeightTime = HeightData(1)

        ScoreboardManager := PlayerData.Core.ScoreboardManager
        ScoreboardManager.UpdateScoreboard(PlayerData, BestHeight, BestHeightTime)
        
        race:
            PlayerData.RemovedEvent.Await()
            UpdatePlayerHeight(PlayerData)
    }

    UpdatePlayerHeight(PlayerData:player_data)<suspends>:void={
        loop:
            DelayTicks(2)
            if (PlayerData.IsActive[]):
                set CurrentHeight = Max(0.0, PlayerData.FortChar.Translation().Z - BaseHeight)
                
                CurrentHeightStat := PlayerData.Core.CurrentHeightStat
                CurrentHeightStat.SetValue[PlayerData.Player, Floor[CurrentHeight * 0.01] or 0] or void
                BestHeightStat := PlayerData.Core.BestHeightStat
                BestHeightStat.SetValue[PlayerData.Player, Floor[BestHeight * 0.01] or 0] or void

                if (CurrentHeight > BestHeight) then SetBestHeight(PlayerData)
            
                if (OldHeight <> CurrentHeight): # Prevent unnecessary UI updates
                    PlayerData.Interface.TimerUI.UpdateHeight(CurrentHeight)
                    PlayerData.Interface.MinimapUI.UpdateHeight(CurrentHeight, BestHeight)
            
            set OldHeight = CurrentHeight
    }

    SetBestHeight(PlayerData:player_data):void={
        set BestHeight = CurrentHeight
        set BestHeightTime = PlayerData.Checkpoints.CurrentTime

        PlayerData.Interface.MinimapUI.UpdateBestTime(BestHeightTime)

        if (PlayerData.CheatMode?) then return # Prevent saving and updating scores for cheat players

        PlayerData.Core.ScoreboardManager.UpdateScoreboard(PlayerData, BestHeight, BestHeightTime)
        PlayerData.Persistence.SaveBestHeight(PlayerData, BestHeight, BestHeightTime)
        
        PlayerData.Accolades.AwardReachXpIfDue(PlayerData)
    }