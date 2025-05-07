using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

tag_tile := class(tag){}

zone := class:
    Position:vector3
    Radius:float
    var Tiles:[]tile = array{}

tile := class:
    Position:vector3
    Radius:float
    Prop:creative_prop
    Material:JuiceWorld_W.PlatformMat.MM_Dissolve_material
    var Animating:logic = false

tile_zone := class<unique>:
    
    Core:core_device
    Volume:volume_device
    ID:int
    var Tiles:[]tile = array{}

    Initialize():void={
        Volume.AgentEntersEvent.Subscribe(EnteredVolume)
        Volume.AgentExitsEvent.Subscribe(ExitedVolume)
        set Tiles = SetupTiles()
    }

    EnteredVolume(Agent:agent):void={
        if:
            Player := player[Agent]
            PlayerData := Core.PlayerDataMap[Player]
        then:
            set PlayerData.CurrentTileZone = option {Self}
            spawn {CollisionLoop(PlayerData)}
    }

    ExitedVolume(Agent:agent):void={
        if:
            Player := player[Agent]
            PlayerData := Core.PlayerDataMap[Player]
        then:
            set PlayerData.CurrentTileZone = false
    }

    SetupTiles():[]tile={
        VolumePosition := Volume.Translation()
        VolumeRadius := 2560.0 * Volume.Scale().X
        TaggedTiles := GetObjectsWithTag(tag_tile{}, Core)

        for:
            TaggedTile:TaggedTiles
            TileProp := creative_prop[TaggedTile]
            TileTransform := TileProp.GetTransform()
            Distance(TileTransform.Translation, VolumePosition) < VolumeRadius
        do:
            Material := JuiceWorld_W.PlatformMat.MM_Dissolve_material{}
            TileProp.SetMaterial(Material)

            Tile := tile:
                Position := TileTransform.Translation
                Radius := 100.0 * TileTransform.Scale.X
                Prop := TileProp
                Material := Material
    }

    CollisionLoop(PlayerData:player_data)<suspends>:void={
        race:
            PlayerData.RemovedEvent.Await()
            loop:
                DelayTicks(5)
                if (PlayerData.CurrentTileZone = false or PlayerData.CurrentTileZone? <> Self) then break

                for (Tile:Tiles, not Tile.Animating?):
                    PlayerPosition := PlayerData.FortChar.Translation()
                    if:
                        Abs(Tile.Position.X - PlayerPosition.X) < Tile.Radius
                        PlayerPosition.Z - Tile.Position.Z > 0.0
                        PlayerPosition.Z - Tile.Position.Z < 120.0
                        Abs(Tile.Position.Y - PlayerPosition.Y) < Tile.Radius
                    then:
                        spawn {Tile.TimedHide()}
    }

    (Tile:tile).TimedHide()<suspends>:void={
        set Tile.Animating = true

        for (index := 0..30):
            DelayTicks(1)
            set Tile.Material.Dissolve += (0.033)

        Tile.Prop.Hide()
        Sleep(1.0)
        Tile.Prop.Show()

        for (index := 0..30):
            DelayTicks(1)
            set Tile.Material.Dissolve -= 0.033
            
        set Tile.Material.Dissolve = 0.0
        set Tile.Animating = false
    }