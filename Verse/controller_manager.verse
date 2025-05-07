using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

button := enum:
    A
    B
    X
    Y

vfx := class<unique>:
    @editable ItemGranter:item_granter_device = item_granter_device{}
    @editable VisualEffect:visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable ClearTrigger:trigger_device = trigger_device{}
    @editable Code:[]button = for (I :=0..5) do button.A
    @editable Cheat:logic = false

controller := class<unique>:
    @editable ATrigger:volume_device = volume_device{}
    @editable BTrigger:volume_device = volume_device{}
    @editable XTrigger:volume_device = volume_device{}
    @editable YTrigger:volume_device = volume_device{}

controller_manager := class:
    
    var CoreOP:?core_device = false
    var Controllers:[]controller = array{}
    var CheatVFX:[]vfx = array{}
    var CheatHUDMessage:hud_message_device = hud_message_device{}
    var CheatModeHUDMessage:hud_message_device = hud_message_device{}

    var ButtonInputs:[player][]button = map{}
    var EnabledCheats:[player][]vfx = map{}

    CancelButtonEvent:event(player) = event(player){}

    Initialize(Core:core_device)<suspends>:void={
        set CoreOP = option {Core}
        set Controllers = Core.Controllers
        set CheatVFX = Core.CheatVFX
        set CheatHUDMessage = Core.CheatCodePrompt
        set CheatModeHUDMessage = Core.CheatModePrompt

        for (Controller:Controllers):
            Controller.ATrigger.AgentEntersEvent.SubscribeAgent(OnEnter, button.A)
            Controller.BTrigger.AgentEntersEvent.SubscribeAgent(OnEnter, button.B)
            Controller.XTrigger.AgentEntersEvent.SubscribeAgent(OnEnter, button.X)
            Controller.YTrigger.AgentEntersEvent.SubscribeAgent(OnEnter, button.Y)

            Controller.ATrigger.AgentExitsEvent.Subscribe(OnExit)
            Controller.BTrigger.AgentExitsEvent.Subscribe(OnExit)
            Controller.XTrigger.AgentExitsEvent.Subscribe(OnExit)
            Controller.YTrigger.AgentExitsEvent.Subscribe(OnExit)
    }

    OnEnter(Agent:agent, Button:button):void={
        if (Player := player[Agent], Player.IsActive[]):
            CancelButtonEvent.Signal(Player)
            spawn { AwaitButtonPress(Player, Button) }
    }

    OnExit(Agent:agent):void={
        if (Player := player[Agent], Player.IsActive[]):
            CancelButtonEvent.Signal(Player)
            spawn { ClearButtonInputs(Player) }
    }

    AwaitButtonPress(Player:player, Button:button)<suspends>:void={
        race:
            loop:
                NewPlayer := CancelButtonEvent.Await()
                if (Player = NewPlayer) then break
            block:
                Sleep(0.5)
                TriggerButtonPress(Player, Button)
    }

    TriggerButtonPress(Player:player, Button:button):void={
        if (not Player.IsActive[]) then return

        var CurrentInput:[]button = ButtonInputs[Player] + array{Button} or array{Button}
        set CurrentInput = CurrentInput.LimitLength()
        if (set ButtonInputs[Player] = CurrentInput){}
        
        MatchingCheats := for (Vfx:CheatVFX, Vfx.Code = CurrentInput) do Vfx 
        
        if (CheatCode := MatchingCheats[0], Cheats := EnabledCheats[Player] or array{}):
            if (not Cheats.Find[CheatCode]):
                ActivateCheat(Player, CurrentInput, CheatCode, Cheats)
            else if (not CheatCode.Cheat?):
                DeactivateCheat(Player, CurrentInput, CheatCode, Cheats)
            else:
                if (set ButtonInputs[Player] = array{}){}
        else:
            CheatHUDMessage.Show(Player, S2M("{CurrentInput.ButtonToText()}"))
    }

    ActivateCheat(Player:player, CurrentInput:[]button, CheatCode:vfx, Cheats:[]vfx):void={
        if (set EnabledCheats[Player] = Cheats + array{CheatCode}){}
        if (set ButtonInputs[Player] = array{}){}

        CheatCode.ItemGranter.GrantItem(Player)
        CheatCode.VisualEffect.Pickup(Player)
        CheatHUDMessage.Show(Player, S2M("{CurrentInput.ButtonToText()} Cheat Activated!"))

        if (CheatCode.Cheat?, set CoreOP?.PlayerDataMap[Player].CheatMode = true):
            Print("Cheat")
            CheatModeHUDMessage.Show(Player)
    }

    DeactivateCheat(Player:player, CurrentInput:[]button, CheatCode:vfx, Cheats:[]vfx):void={
        if (set EnabledCheats[Player] = Cheats.RemoveAllElements(CheatCode)){}
        if (set ButtonInputs[Player] = array{}){}

        CheatCode.ClearTrigger.Trigger(Player)
        CheatHUDMessage.Show(Player, S2M("{CurrentInput.ButtonToText()} Cheat Deactivated!"))
    }

    (Buttons:[]button).LimitLength():[]button={
        if (Buttons.Length > 6):
            Buttons.Slice[1, Buttons.Length] or Buttons
        else:
            Buttons
    }

    ClearButtonInputs(Player:player)<suspends>:void={
        race:
            loop:
                NewPlayer := CancelButtonEvent.Await()
                if (Player = NewPlayer) then break
            block:
                Sleep(10.0)
                Print("ClearedInput")
                if (set ButtonInputs[Player] = array{}){}
    }

    (Buttons:[]button).ButtonToText():string={
        var Result:string = ""
        for (Button:Buttons):
            set Result += case (Button):
                button.A => "A"
                button.B => "B"
                button.X => "X"
                button.Y => "Y"
        return Result
    }