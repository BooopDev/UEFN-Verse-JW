using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

core_device := class(creative_device):

    var PlayerDataMap:[player]player_data = map{}

    PersistenceManager:persistence_manager = persistence_manager{}
    CollectiblesManager:collectibles_manager = collectibles_manager{}
    ScoreboardManager:scoreboard_manager = scoreboard_manager{}
    TileZoneManager:tile_zone_manager = tile_zone_manager{}
    ControllerManager:controller_manager = controller_manager{}

    @editable Checkpoints:[]checkpoint = array{}
    @editable TileVolumes:[]volume_device = array{}
    @editable Collectibles:[]collectible_object_device = array{}
    @editable Scoreboards:[]scoreboard = array{}
    @editable XboxLoungeTeleportZones:[]mutator_zone_device = array{}
    @editable Controllers:[]controller = array{}
    @editable CheatVFX:[]vfx = array{}
    @editable RemoteManager:remote_manager = remote_manager{}
    @editable OutroCinematic:cinematic_manager = cinematic_manager{}
    @editable CheckpointPrompt:hud_message_device = hud_message_device{}
    @editable UnavailablePrompt:hud_message_device = hud_message_device{}
    @editable CheatCodePrompt:hud_message_device = hud_message_device{}
    @editable CheatModePrompt:hud_message_device = hud_message_device{}
    @editable CurrentHeightStat:stat_creator_device = stat_creator_device{}
    @editable BestHeightStat:stat_creator_device = stat_creator_device{}
    @editable CrownVFX:visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable Accolades: accolades = accolades{}
    @editable Telemetry: telemetry = telemetry{}
    
    OnBegin<override>()<suspends>:void={
        SetupPlayers()
        TileZoneManager.Initialize(Self)
        CollectiblesManager.Initialize(Self)
        ScoreboardManager.Initialize(Self)
        RemoteManager.Initialize(Self)
        ControllerManager.Initialize(Self)
    }

    SetupPlayers():void={
        Playspace := GetPlayspace()
        
        Playspace.PlayerAddedEvent().Subscribe(RegisterPlayer)
        Playspace.PlayerRemovedEvent().Subscribe(RemovePlayer)

        Players := Playspace.GetPlayers()
        for (Player : Players) do RegisterPlayer(Player)
    }

    RegisterPlayer(Player:player):void={
        if:
            NewPlayerData := player_data:
                Player := Player
                FortChar := Player.GetFortCharacter[]
                Core := Self
                Persistence := PersistenceManager
            set PlayerDataMap[Player] = NewPlayerData
            PersistentData := PersistenceManager.MigrateExistingData(Player)
            set PlayerPersistenceMap[Player] = PersistentData
        then:
            Print(P2M(NewPlayerData.Player) + "Registered")
            NewPlayerData.Initialize()
    }

    RemovePlayer(Player:player):void={
        if (PlayerData := PlayerDataMap[Player]):
            PlayerData.RemovedEvent.Signal()
            
            for (Zone:TileZoneManager.TileZones) do Zone.ExitedVolume(Player)
    }
