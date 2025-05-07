using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

accolades := class<concrete>:
    @editable ReachedChillzone1:accolades_device = accolades_device{} # Done
    @editable ReachedChillzone2:accolades_device = accolades_device{} # Done
    @editable ReachedChillzone3:accolades_device = accolades_device{} # Done
    @editable NewBestTime:accolades_device = accolades_device{} # Done
    @editable Reach50:accolades_device = accolades_device{} # Done
    @editable Reach120:accolades_device = accolades_device{} # Done
    @editable Reach200:accolades_device = accolades_device{} # Done
    @editable Reach330:accolades_device = accolades_device{} # Done
    @editable Reach475:accolades_device = accolades_device{} # Done
    @editable Reach630:accolades_device = accolades_device{} # Done
    @editable Reach800:accolades_device = accolades_device{} # Done
    @editable Reach980:accolades_device = accolades_device{} # Done
    @editable Reach1200:accolades_device = accolades_device{} # Done
    @editable Reach1430:accolades_device = accolades_device{} # Done
    @editable Attempts10:accolades_device = accolades_device{} # Done
    @editable Attempts20:accolades_device = accolades_device{} # Done
    @editable Attempts30:accolades_device = accolades_device{} # Done
    @editable Attempts100:accolades_device = accolades_device{} # Done
    @editable MemoCompletedGAGR:accolades_device = accolades_device{} # Done
    @editable MemoCompletedDRFL:accolades_device = accolades_device{} # Done
    @editable MemoCompletedLND:accolades_device = accolades_device{} # Done
    @editable MemoCompletedFD:accolades_device = accolades_device{} # Done
    @editable CDCompletedGAGR:accolades_device = accolades_device{} # Done
    @editable CDCompletedDRFL:accolades_device = accolades_device{} # Done
    @editable CDCompletedLND:accolades_device = accolades_device{} # Done
    @editable CDCompletedFD:accolades_device = accolades_device{} # Done
    #@editable TimePlayed5:accolades_device = accolades_device{} # Done (Without Verse)
    @editable CollectibleAward:accolades_device = accolades_device{} # Done

accolade_flags := class<unique>:
    var Reach50:logic = false
    var Reach120:logic = false
    var Reach200:logic = false
    var Reach330:logic = false
    var Reach475:logic = false
    var Reach630:logic = false
    var Reach800:logic = false
    var Reach980:logic = false
    var Reach1200:logic = false
    var Reach1430:logic = false

accolade_manager := class:
    var Accolades:accolades = accolades{} # Reference, not copy
    var Flags:accolade_flags = accolade_flags{}

    Initialize(PlayerData:player_data)<suspends>:void={
        set Accolades = PlayerData.Core.Accolades

        InitializeReachData(PlayerData)
    }

    AwardXboxLoungeReached(PlayerData:player_data, Checkpoint:checkpoint):void={
        case (Checkpoint.Index):
            3 => {Accolades.ReachedChillzone1.Award(PlayerData.Player)}
            6 => {Accolades.ReachedChillzone2.Award(PlayerData.Player)}
            9 => {Accolades.ReachedChillzone3.Award(PlayerData.Player)}
            _ => {}
    }
    
    AwardReachXpIfDue(PlayerData:player_data):void={
        BestHeight := PlayerData.Altimeter.BestHeight / 100.0
        if (BestHeight >= 50.0 and not Flags.Reach50?):
            Accolades.Reach50.Award(PlayerData.Player)
            set Flags.Reach50 = true
            return
        if (BestHeight >= 120.0 and not Flags.Reach120?):
            Accolades.Reach120.Award(PlayerData.Player)
            set Flags.Reach120 = true
            return
        if (BestHeight >= 200.0 and not Flags.Reach200?):
            Accolades.Reach200.Award(PlayerData.Player)
            set Flags.Reach200 = true
            return
        if (BestHeight >= 330.0 and not Flags.Reach330?):
            Accolades.Reach330.Award(PlayerData.Player)
            set Flags.Reach330 = true
            return
        if (BestHeight >= 475.0 and not Flags.Reach475?):
            Accolades.Reach475.Award(PlayerData.Player)
            set Flags.Reach475 = true
            return
        if (BestHeight >= 630.0 and not Flags.Reach630?):
            Accolades.Reach630.Award(PlayerData.Player)
            set Flags.Reach630 = true
            return
        if (BestHeight >= 800.0 and not Flags.Reach800?):
            Accolades.Reach800.Award(PlayerData.Player)
            set Flags.Reach800 = true
            return
        if (BestHeight >= 980.0 and not Flags.Reach980?):
            Accolades.Reach980.Award(PlayerData.Player)
            set Flags.Reach980 = true
            return
        if (BestHeight >= 1200.0 and not Flags.Reach1200?):
            Accolades.Reach1200.Award(PlayerData.Player)
            set Flags.Reach1200 = true
            return
        if (BestHeight >= 1430.0 and not Flags.Reach1430?):
            Accolades.Reach1430.Award(PlayerData.Player)
            set Flags.Reach1430 = true
            return
    }
    
    InitializeReachData(PlayerData:player_data):void={
        BestHeight := PlayerData.Altimeter.BestHeight / 100.0
        if (BestHeight >= 50.0). set Flags.Reach50 = true
        if (BestHeight >= 120.0). set Flags.Reach120 = true
        if (BestHeight >= 200.0). set Flags.Reach200 = true
        if (BestHeight >= 330.0). set Flags.Reach330 = true
        if (BestHeight >= 475.0). set Flags.Reach475 = true
        if (BestHeight >= 630.0). set Flags.Reach630 = true
        if (BestHeight >= 800.0). set Flags.Reach800 = true
        if (BestHeight >= 980.0). set Flags.Reach980 = true
        if (BestHeight >= 1200.0). set Flags.Reach1200 = true
        if (BestHeight >= 1430.0). set Flags.Reach1430 = true
    }
    
    RangeInArrayOfLogicIsAllTrue(Array: []logic, LowBoundInclusive: int, HighBoundInclusive: int)<transacts>:logic={
        for (ID := LowBoundInclusive..HighBoundInclusive, Elem := Array[ID], not Elem?):
            return false 
        return true
    }
    
    # Only called on brand new collectible being collected, check if it was last remaining
    # collectible within its album/type range, if it was last then reward XP
    AwardCdOrMemoribiliaIfDue(PlayerData:player_data, Collectibles:[]logic, ID:int):void={
        # Small reward for every new collectible
        Accolades.CollectibleAward.Award(PlayerData.Player)

        # Completion of sets
        if (ID >= 0 and ID <= 5): # Stickers LND
            if (RangeInArrayOfLogicIsAllTrue(Collectibles, 0, 5)?). AwardMemoribilia(0, PlayerData.Player)
        else if (ID >= 6 and ID <= 9): # Disc LND
            if (RangeInArrayOfLogicIsAllTrue(Collectibles, 6, 9)?). AwardCD(0, PlayerData.Player)
            
        else if (ID >= 10 and ID <= 15): # Stickers FD
            if (RangeInArrayOfLogicIsAllTrue(Collectibles, 10, 15)?). AwardMemoribilia(1, PlayerData.Player)
        else if (ID >= 16 and ID <= 19): # Disc FD
            if (RangeInArrayOfLogicIsAllTrue(Collectibles, 16, 19)?). AwardCD(1, PlayerData.Player)
            
        else if (ID >= 20 and ID <= 25): # Stickers DRFL
            if (RangeInArrayOfLogicIsAllTrue(Collectibles, 20, 25)?). AwardMemoribilia(2, PlayerData.Player)
        else if (ID >= 26 and ID <= 29): # Disc DRFL
            if (RangeInArrayOfLogicIsAllTrue(Collectibles, 26, 29)?). AwardCD(2, PlayerData.Player)
            
        else if (ID >= 30 and ID <= 35): # Stickers GAGR
            if (RangeInArrayOfLogicIsAllTrue(Collectibles, 30, 35)?). AwardMemoribilia(3, PlayerData.Player)
        else if (ID >= 36 and ID <= 39): # Disc GAGR
            if (RangeInArrayOfLogicIsAllTrue(Collectibles, 36, 39)?). AwardCD(3, PlayerData.Player)
    }

    AwardMemoribilia(Memoribilia:int, Player:player):void={
        case(Memoribilia):
            0 => Accolades.MemoCompletedLND.Award(Player)
            1 => Accolades.MemoCompletedFD.Award(Player)
            2 => Accolades.MemoCompletedDRFL.Award(Player)
            3 => Accolades.MemoCompletedGAGR.Award(Player)
            _ => {}
    }

    AwardCD(CD:int, Player:player):void={
        case(CD):
            0 => Accolades.CDCompletedLND.Award(Player)
            1 => Accolades.CDCompletedFD.Award(Player)
            2 => Accolades.CDCompletedDRFL.Award(Player)
            3 => Accolades.CDCompletedGAGR.Award(Player)
            _ => {}
    }

    IncrementAttemptAndAwardIfDue(PlayerData: player_data):void={
        AttemptsCount:int = PlayerData.Persistence.IncrementAttempts(PlayerData)
        case (AttemptsCount):
            10 => Accolades.Attempts10.Award(PlayerData.Player)
            20 => Accolades.Attempts20.Award(PlayerData.Player)
            30 => Accolades.Attempts30.Award(PlayerData.Player)
            100 => Accolades.Attempts100.Award(PlayerData.Player)
            _ => {}
    }
    
    AwardNewBestTime(PlayerData:player_data):void={
        Accolades.NewBestTime.Award(PlayerData.Player) 
    }