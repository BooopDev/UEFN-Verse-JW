using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

tile_zone_manager := class:

    var TileZones:[]tile_zone = array{}

    Initialize(Core:core_device):void={
        set TileZones = SetupTileZones(Core)
    }

    SetupTileZones(Core:core_device):[]tile_zone={
        for (Index -> Volume:Core.TileVolumes):
            TileZone := tile_zone:
                Volume := Volume
                Core := Core
                ID := Index
            TileZone.Initialize()
            TileZone
    }