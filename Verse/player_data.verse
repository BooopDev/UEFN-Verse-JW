using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

player_data := class<unique>:

    Core:core_device
    Player:player
    FortChar:fort_character
    Persistence:persistence_manager
    RemovedEvent:event() = event(){}

    Checkpoints:checkpoint_manager = checkpoint_manager{}
    Altimeter:altimeter_manager = altimeter_manager{}
    Interface:ui_manager = ui_manager{}
    Accolades:accolade_manager = accolade_manager{}
    Telemetry:telemetry_manager = telemetry_manager{}

    var CheatMode:logic = false
    var CurrentTileZone:?tile_zone = false

    Initialize():void={
        spawn {Checkpoints.Initialize(Self)}
        spawn {Altimeter.Initialize(Self)}
        spawn {Interface.Initialize(Self)}
        spawn {Accolades.Initialize(Self)}
        spawn {Telemetry.Initialize(Self)}

        Telemetry.Telemetry.PlayersJoined.Submit(Player)

        if (PlayerPersistenceMap[Player].GameBeaten?):
            Core.CrownVFX.Pickup(Player)
    }

    IsActive()<decides><transacts>:void={
        Player.IsActive[]
        FortChar.IsActive[]
    }
