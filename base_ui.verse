using { /UnrealEngine.com/Temporary/UI }

base_ui := class<unique>: # Base class for all UI elements
    var PlayerDataOP:?player_data = false
    var Canvas:canvas = canvas{}
    var IsOpen:logic = false

    Init<final>(PlayerData:player_data):void=
        set PlayerDataOP = option{PlayerData}
        set Canvas = CreateCanvas()
        Initialize(PlayerData)

    Initialize(PlayerData:player_data):void={}

    CreateCanvas():canvas=
        canvas{}
        
    ShowInteractive():void=
        if(PlayerUI := GetPlayerUI[PlayerDataOP?.Player], not IsOpen?):
            PlayerUI.AddWidget(Canvas, player_ui_slot{InputMode := ui_input_mode.All})
            set IsOpen = true

    Show():void=
        if(PlayerUI := GetPlayerUI[PlayerDataOP?.Player], not IsOpen?):
            PlayerUI.AddWidget(Canvas, player_ui_slot{InputMode := ui_input_mode.None})
            set IsOpen = true

    Hide():void=
        if(PlayerUI := GetPlayerUI[PlayerDataOP?.Player]):
            PlayerUI.RemoveWidget(Canvas)    
            set IsOpen = false 