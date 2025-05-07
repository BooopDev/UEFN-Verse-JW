using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

DefaultMessage<localizes>:message = "Default"

scoreboard := class<concrete>:
    @editable GlobalHeight: billboard_device = billboard_device{}
    @editable GlobalName: billboard_device = billboard_device{}
    @editable GlobalTime: billboard_device = billboard_device{}

    @editable Top3Name: billboard_device = billboard_device{}
    @editable Top3Time: billboard_device = billboard_device{}

    var Top3Scores:[]score = array{}

score := class<unique>:
    var Height:float = 0.0
    var Name:message = DefaultMessage
    var Time:float = 0.0

scoreboard_manager := class:

    var Scoreboards:[]scoreboard = array{}
    var GlobalScores:[player_data]score = map{}

    Initialize(Core:core_device):void={
        set Scoreboards = Core.Scoreboards
        spawn {UpdateLoop(Core)}
    }

    UpdateLoop(Core:core_device)<suspends>:void={
        Sleep(1.0)
        loop:
            UpdateGlobalScoreboards()
            DelayTicks(1)
            UpdateXboxLoungeScoreboards(Core)
            DelayTicks(1)
            UpdateGroundScoreboard(Core)
            Sleep(3.0)
    }

    UpdateScoreboard(PlayerData:player_data, NewHeight:float, NewTime:float):void={
        if (not PlayerData.Player.IsActive[]) then return
        if (PlayerData.CheatMode?) then return
        
        NewScore := score:
            Height := NewHeight
            Name := P2M(PlayerData.Player)
            Time := NewTime

        if (set GlobalScores[PlayerData] = NewScore){}
    }

    UpdateGroundScoreboard(Core:core_device):void={
        var NameMessage:message = S2M("")
        var TimeMessage:message = S2M("")

        for (Index->Scoreboard:Scoreboards, Index <> 0, Score := Scoreboard.Top3Scores[0]):
            set NameMessage = NameMessage + Score.Name + "\n"
            set TimeMessage = TimeMessage + Score.Time.ToTime() + "\n"

        if (Scoreboard := Scoreboards[0]):
            Scoreboard.Top3Name.UpdateText(NameMessage)
            Scoreboard.Top3Time.UpdateText(TimeMessage)
    }

    UpdateGlobalScoreboards():void={
        GlobalScoresArray := for (PlayerData->Score:GlobalScores, PlayerData.Player.IsActive[]) do Score
        SortedGlobalScores := GlobalScoresArray.Sort(CompareScores, OrderBy.Desc)

        var HeightMessage:message = S2M("")
        var NameMessage:message = S2M("")
        var TimeMessage:message = S2M("")

        for (Index->Score:SortedGlobalScores, Index <= 4):
            set HeightMessage = HeightMessage + "{Index + 1}#  " + Score.Height.ToMeters() + "\n"
            set NameMessage = NameMessage + Score.Name + "\n"
            set TimeMessage = TimeMessage + Score.Time.ToTime() + "\n"

        for (ScoreBoard:Scoreboards):
            ScoreBoard.GlobalHeight.UpdateText(HeightMessage)
            ScoreBoard.GlobalName.UpdateText(NameMessage)
            ScoreBoard.GlobalTime.UpdateText(TimeMessage)
    }

    UpdateXboxLoungeScoreboards(Core:core_device):void={
        for (Index->Scoreboard:Scoreboards, Index <> 0):
            set Scoreboard.Top3Scores = for:
                PlayerData->Score:GlobalScores
                PlayerData.Player.IsActive[]
                Time := Core.PersistenceManager.GetCheckpointTime(PlayerData.Player, Index * 3)
                Time <> 0.0
            do:
                NewScore := score:
                    Name := P2M(PlayerData.Player)
                    Time := Time

            var SortedTop3Scores:[]score= Scoreboard.Top3Scores.Sort(CompareTimes, OrderBy.Asc)
            set SortedTop3Scores = for (I->Score:Scoreboard.Top3Scores, Index <= 2) do Score
            set Scoreboard.Top3Scores = SortedTop3Scores

            var NameMessage:message = S2M("")
            var TimeMessage:message = S2M("")

            for (Score:SortedTop3Scores):
                set NameMessage = NameMessage + Score.Name + "\n"
                set TimeMessage = TimeMessage + Score.Time.ToTime() + "\n"

            Scoreboard.Top3Name.UpdateText(NameMessage)
            Scoreboard.Top3Time.UpdateText(TimeMessage)
    }

    CompareScores<public>(A:score, B:score)<transacts>:int={
        if (A.Height > B.Height) then return 1
        if (A.Height < B.Height) then return -1
        return 0
    }

    CompareTimes<public>(A:score, B:score)<transacts>:int={
        if (A.Time > B.Time) then return 1
        if (A.Time < B.Time) then return -1
        return 0
    }