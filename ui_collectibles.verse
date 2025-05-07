using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { CollectibleStickers }

collectible_tab := class:
    BackgroundImage:texture
    StickerImages:[]texture

ui_collectibles := class(base_ui):

    Tabs:[]collectible_tab = array:
        collectible_tab:
            BackgroundImage := UI.CD1BG
            StickerImages := array:
                LND.LND_Sticker1
                LND.LND_Sticker2
                LND.LND_Sticker3
                LND.LND_Sticker4
                LND.LND_Sticker5
                LND.LND_Sticker6
        collectible_tab:
            BackgroundImage := UI.CD2BG
            StickerImages := array:
                FD.FD_Sticker1
                FD.FD_Sticker2
                FD.FD_Sticker3
                FD.FD_Sticker4
                FD.FD_Sticker5
                UI.Sticker2
        collectible_tab:
            BackgroundImage := UI.CD3BG
            StickerImages := array:
                DRFL.DRFL_Sticker1
                DRFL.DRFL_Sticker2
                DRFL.DRFL_Sticker3
                DRFL.DRFL_Sticker4
                DRFL.DRFL_Sticker5
                DRFL.DRFL_Sticker6
        collectible_tab:
            BackgroundImage := UI.CD4BG
            StickerImages := array:
                GBGR.GBGR_Sticker1
                GBGR.GBGR_Sticker2
                GBGR.GBGR_Sticker3
                GBGR.GBGR_Sticker4
                GBGR.GBGR_Sticker5
                GBGR.GBGR_Sticker6

    BackgroundImage:texture_block = texture_block{DefaultImage := UI.CD1BG}
    Lines:texture_block = texture_block{DefaultImage := UI.Lines}

    Stickers:[]texture_block = array:
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 200.0, Y := 200.5}}
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 200.0, Y := 200.5}}
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 200.0, Y := 200.5}}
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 200.0, Y := 200.5}}
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 200.0, Y := 200.5}}
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 200.0, Y := 200.5}}

    StickerPlaceholders:[]texture_block = array:
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 186.5, Y := 185.0}}
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 186.5, Y := 185.0}}
        texture_block{DefaultImage := UI.StickerSquare, DefaultDesiredSize := vector2{X := 159.5, Y := 158.0}}
        texture_block{DefaultImage := UI.StickerSquare, DefaultDesiredSize := vector2{X := 159.5, Y := 158.0}}
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 186.5, Y := 185.0}}
        texture_block{DefaultImage := UI.StickerCircle, DefaultDesiredSize := vector2{X := 186.5, Y := 185.0}}

    AlbumOverlays:[]texture_block = array:
        texture_block{DefaultImage := UI.TopLeft}
        texture_block{DefaultImage := UI.TopRight}
        texture_block{DefaultImage := UI.BottomLeft}
        texture_block{DefaultImage := UI.BottomRight}

    TabButton1:button_regular = button_regular{}
    TabButton2:button_regular = button_regular{}
    TabButton3:button_regular = button_regular{}
    TabButton4:button_regular = button_regular{}
    CloseButton:button_loud = button_loud{}

    var TabIndex:int = 0
    
    Initialize<override>(PlayerData:player_data):void={
        SetupButtons()
        UpdateCanvas()
    }

    CloseMenu(Message:widget_message):void = Hide()

    SetupButtons():void={
        CloseButton.OnClick().Subscribe(CloseMenu)
        TabButton1.OnClick().SubscribeWidget(UpdateTab, 0)
        TabButton2.OnClick().SubscribeWidget(UpdateTab, 1)
        TabButton3.OnClick().SubscribeWidget(UpdateTab, 2)
        TabButton4.OnClick().SubscribeWidget(UpdateTab, 3)

        CloseButton.SetText(S2M("Close"))
        TabButton1.SetText(S2M("CD 1"))
        TabButton2.SetText(S2M("CD 2"))
        TabButton3.SetText(S2M("CD 3"))
        TabButton4.SetText(S2M("CD 4"))
    }

    UpdateTab(Message:widget_message, Index:int):void={
        set TabIndex = Index
        UpdateCanvas()
    }

    UpdateCanvas():void={
        TabButton1.SetText(S2M("CD 1"))
        TabButton2.SetText(S2M("CD 2"))
        TabButton3.SetText(S2M("CD 3"))
        TabButton4.SetText(S2M("CD 4"))

        case(TabIndex):
                0=> TabButton1.SetText(S2M("   CD 1 ⭐"))
                1=> TabButton2.SetText(S2M("   CD 2 ⭐"))
                2=> TabButton3.SetText(S2M("   CD 3 ⭐"))
                3=> TabButton4.SetText(S2M("   CD 4 ⭐"))
                _=> {}
        
        if:
            PlayerData := PlayerDataOP?
            Collectibles := PlayerPersistenceMap[PlayerData.Player].Collectibles
        then:
            StickersUnlocked := UpdateStickers(Collectibles)
            AlbumsUnlocked := UpdateAlbums(Collectibles)
            BackgroundImage.SetImage(Tabs[TabIndex].BackgroundImage or UI.CD1BG)  
    }

    UpdateStickers(Collectibles:[]logic):int={
        var Total:int = 0
        for:
            Index := 0..5
            IsUnlocked := Collectibles[Index + (TabIndex * 10)] or false
            Sticker := Stickers[Index]
            StickerImage := Tabs[TabIndex].StickerImages[Index]
            StickerPlaceholder := StickerPlaceholders[Index]
        do:
            if (IsUnlocked?):
                StickerPlaceholder.SetVisibility(widget_visibility.Hidden)
                Sticker.SetImage(StickerImage)
                Sticker.SetVisibility(widget_visibility.Visible)
                set Total += 1
            else:
                StickerPlaceholder.SetVisibility(widget_visibility.Visible)
                Sticker.SetVisibility(widget_visibility.Hidden)

        if (Total = 4):
            Lines.SetVisibility(widget_visibility.Hidden)
        else:
            Lines.SetVisibility(widget_visibility.Visible)

        return Total
    }

    UpdateAlbums(Collectibles:[]logic):int={
        var Total:int = 0
        for:
            Index := 0..3
            IsUnlocked := Collectibles[Index + (TabIndex * 10) + 6] or false
            AlbumOverlay := AlbumOverlays[Index]
        do:
            if (IsUnlocked?):
                AlbumOverlay.SetVisibility(widget_visibility.Hidden)
                set Total += 1
            else:
                AlbumOverlay.SetVisibility(widget_visibility.Visible)

        return Total
    }

    CreateCanvas<override>():canvas={
        canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Offsets := margin{Right := 1866.0, Bottom := 1017.5}
                    ZOrder := 0
                    Widget := BackgroundImage
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Offsets := margin{Left := -720.0, Top := -400.0, Right := 240.0, Bottom := 70.0}
                    ZOrder := 1
                    Widget := CloseButton
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Offsets := margin{Left := 507.0, Top := 57.0, Right := 565.0, Bottom := 575.5}
                    ZOrder := 1
                    Widget := CreateAlbumOverlay()
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Offsets := margin{Left := -215.0, Top := 68.0, Right := 720.0, Bottom := 740.0}
                    ZOrder := 1
                    Widget := CreateStickerPlaceHolders()
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Offsets := margin{Left := -215.0, Top := 68.0, Right := 720.0, Bottom := 740.0}
                    ZOrder := 1
                    Widget := CreateStickers()
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Offsets := margin{Left := -730.0, Top := 66.0, Right := 260.0, Bottom := 722.0}
                    ZOrder := 1
                    Widget := CreateTabs()
    }

    CreateAlbumOverlay():overlay={
        overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := AlbumOverlays[0] or texture_block{DefaultImage := UI.TopLeft}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := AlbumOverlays[1] or texture_block{DefaultImage := UI.TopLeft}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := AlbumOverlays[2] or texture_block{DefaultImage := UI.TopLeft}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := AlbumOverlays[3] or texture_block{DefaultImage := UI.TopLeft}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := Lines
    }

    CreateStickerPlaceHolders():overlay={
        overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Top := 44.0, Right := 177.0}
                    Widget := StickerPlaceholders[0] or texture_block{DefaultImage := UI.Sticker1}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Top := 44.0, Left := 112.0}
                    Widget := StickerPlaceholders[1] or texture_block{DefaultImage := UI.Sticker1}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Bottom := 10.0, Right := 177.0}
                    Widget := StickerPlaceholders[2] or texture_block{DefaultImage := UI.Sticker1}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Bottom := 10.0, Left := 112.0}
                    Widget := StickerPlaceholders[3] or texture_block{DefaultImage := UI.Sticker1}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Bottom
                    Padding := margin{Bottom := 62.0, Right := 177.0}
                    Widget := StickerPlaceholders[4] or texture_block{DefaultImage := UI.Sticker1}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Bottom
                    Padding := margin{Bottom := 62.0, Left := 112.0}
                    Widget := StickerPlaceholders[5] or texture_block{DefaultImage := UI.Sticker1}
    }

    CreateStickers():overlay={
        overlay:
                Slots := array:
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Top
                        Padding := margin{Top := 44.0, Right := 177.0}
                        Widget := Stickers[0] or texture_block{DefaultImage := UI.Sticker1}
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Top
                        Padding := margin{Top := 44.0, Left := 112.0}
                        Widget := Stickers[1] or texture_block{DefaultImage := UI.Sticker1}
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Center
                        Padding := margin{Right := 177.0}
                        Widget := Stickers[2] or texture_block{DefaultImage := UI.Sticker1}
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Center
                        Padding := margin{Left := 112.0}
                        Widget := Stickers[3] or texture_block{DefaultImage := UI.Sticker1}
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Bottom
                        Padding := margin{Bottom := 44.0, Right := 177.0}
                        Widget := Stickers[4] or texture_block{DefaultImage := UI.Sticker1}
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Bottom
                        Padding := margin{Bottom := 44.0, Left := 112.0}
                        Widget := Stickers[5] or texture_block{DefaultImage := UI.Sticker1}
    }

    CreateTabs():stack_box={
        stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left :=15.0, Top := 15.0, Right := 15.0, Bottom := 15.0}
                    Widget := TabButton1
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left :=15.0, Top := 15.0, Right := 15.0, Bottom := 15.0}
                    Widget := TabButton2
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left :=15.0, Top := 15.0, Right := 15.0, Bottom := 15.0}
                    Widget := TabButton3
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left :=15.0, Top := 15.0, Right := 15.0, Bottom := 15.0}
                    Widget := TabButton4
    }