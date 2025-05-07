using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }   

ui_manager := class:

    var MinimapUI:ui_minimap = ui_minimap{}
    var TimerUI:ui_timer = ui_timer{}
    var CollectiblesUI:ui_collectibles = ui_collectibles{}

    Initialize(PlayerData:player_data)<suspends>:void=
        MinimapUI.Init(PlayerData)
        TimerUI.Init(PlayerData)
        CollectiblesUI.Init(PlayerData)

        MinimapUI.Show()
        TimerUI.Show()