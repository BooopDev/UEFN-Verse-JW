using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

ui_minimap := class(base_ui):

    CurrentSizeAdjust:color_block = color_block:
        DefaultOpacity := 0.0
        DefaultDesiredSize := vector2{Y := 450.0}

    BestSizeAdjust:color_block = color_block:
        DefaultOpacity := 0.0
        DefaultDesiredSize := vector2{Y := 450.0}

    CurrentHeightText:text_block = text_block:
        DefaultTextColor := NamedColors.Black

    CurrentMarker:texture_block = texture_block:
        DefaultImage := UI.PlayerMarker
        DefaultDesiredSize := vector2{X := 200.0, Y := 90.0}

    BestHeightText:text_block = text_block:
        DefaultTextColor := color{R :=0.723055, G :=0.020289, B :=0.386429}
        DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
        DefaultShadowOpacity := 1.0

    Chillzone1:texture_block = texture_block:
        DefaultImage := UI.ChillzoneLockFilled
        DefaultDesiredSize := vector2{X := 30.0, Y := 42.0}

    Chillzone2:texture_block = texture_block:
        DefaultImage := UI.ChillzoneLockFilled
        DefaultDesiredSize := vector2{X := 30.0, Y := 42.0}

    Chillzone3:texture_block = texture_block:
        DefaultImage := UI.ChillzoneLock
        DefaultDesiredSize := vector2{X := 39.0, Y := 52.0}

    TimerText:text_block = text_block:
        DefaultJustification := text_justification.Center
        DefaultTextColor := color{R :=0.723055, G :=0.020289, B :=0.386429}
        DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
        DefaultShadowOpacity := 1.0

    CollectiblesText:text_block = text_block:
        DefaultJustification := text_justification.Center
        DefaultTextColor := NamedColors.Gold
        DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
        DefaultShadowOpacity := 1.0

    Initialize<override>(PlayerData:player_data):void={
        SectionTimes := PlayerData.Persistence.GetAllCheckpointTimes(PlayerData.Player)
        for (Index -> Time:SectionTimes) do if (Time > 0.0) then UpdateLocks(Index)

        UpdateHeight(0.0, PlayerData.Persistence.GetBestHeight(PlayerData.Player)(0))
        UpdateCollectibles(PlayerData.Persistence.GetTotalCollectibles(PlayerData.Player))
        UpdateBestTime(PlayerData.Altimeter.BestHeightTime)
    }

    CreateCanvas<override>():canvas={
        canvas:
            Slots := array:
                canvas_slot: #* Background
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 0.0}}
                    Alignment := vector2{X := 1.0, Y := 0.0}
                    SizeToContent := true
                    ZOrder := 0
                    Widget := CreateMinimapBackground()
                canvas_slot: #* Markers
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 0.0}}
                    Alignment := vector2{X := 1.0, Y := 0.0}
                    SizeToContent := false
                    Offsets := margin{Right := 370.0, Bottom := 528.0}
                    ZOrder := 1
                    Widget := CreateMarkers()
                canvas_slot: #* Locks
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 0.0}}
                    Alignment := vector2{X := 1.0, Y := 0.0}
                    SizeToContent := false
                    Offsets := margin{Right := 384.0, Bottom := 528.0}
                    ZOrder := 2
                    Widget := CreateLocks()
                canvas_slot: #* Extra UI
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 0.0}}
                    Alignment := vector2{X := 1.0, Y := 0.0}
                    SizeToContent := false
                    Offsets := margin{Left := -7.0, Top := 465.0, Right := 335.0, Bottom := 58.0}
                    ZOrder := 3
                    Widget := CreateExtraUI()
    }

    CreateMinimapBackground():overlay={
        overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Top := -10.0}
                    Widget := texture_block:
                        DefaultImage := UI.MinimapBG
                        DefaultDesiredSize := vector2{X := 350.0, Y := 575.0}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Top := -50.0, Right := -50.0}
                    Widget := texture_block:
                        DefaultImage := UI.StaticBG2
                        DefaultDesiredSize := vector2{X := 455.0, Y := 600.0}
    }

    CreateMarkers():overlay={
        overlay:
            Slots := array:
                overlay_slot: #* Best Marker
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin{Left := 15.0}
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Left
                                VerticalAlignment := vertical_alignment.Top
                                Widget := BestSizeAdjust
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Top
                                Widget := overlay:
                                    Slots := array:
                                        overlay_slot:
                                            HorizontalAlignment := horizontal_alignment.Left
                                            VerticalAlignment := vertical_alignment.Top
                                            Padding := margin{Left := 70.0, Top := 26.0}
                                            Widget := BestHeightText
                                        overlay_slot:
                                            HorizontalAlignment := horizontal_alignment.Left
                                            VerticalAlignment := vertical_alignment.Top
                                            Widget := texture_block:
                                                DefaultImage := UI.BestMarker
                                                DefaultDesiredSize := vector2{X := 200.0, Y := 90.0}
                overlay_slot: #* Current Marker
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin{Left := 15.0}
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Left
                                VerticalAlignment := vertical_alignment.Top
                                Widget := CurrentSizeAdjust
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Top
                                Widget := overlay:
                                    Slots := array:
                                        overlay_slot:
                                            HorizontalAlignment := horizontal_alignment.Left
                                            VerticalAlignment := vertical_alignment.Top
                                            Padding := margin{Left := 70.0, Top := 26.0}
                                            Widget := CurrentHeightText
                                        overlay_slot:
                                            HorizontalAlignment := horizontal_alignment.Left
                                            VerticalAlignment := vertical_alignment.Top
                                            Widget := CurrentMarker
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Right := 350.0}
                    Widget := color_block:
                        DefaultOpacity := 0.2
    }

    CreateLocks():overlay={
        overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Left := 100.0, Top := 295.0}
                    Widget := Chillzone1
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Left := 70.0, Top := 160.0}
                    Widget := Chillzone2
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Left := 70.0, Top := 25.0}
                    Widget := Chillzone3
    }

    CreateExtraUI():overlay={
        overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left := 10.0}
                    Widget := TimerText
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Right := 10.0}
                    Widget := CollectiblesText
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left := 65.0, Bottom := 10.0}
                    Widget := text_block{DefaultText := S2M("🕛")}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Right := 30.0, Bottom := 10.0}
                    Widget := text_block{DefaultText := S2M("💿")}
    }

    UpdateHeight(CurrentHeight:float, BestHeight:float):void={
        CurrentAdjustOffset := GetAdjustOffset(CurrentHeight)
        BestAdjustOffset := GetAdjustOffset(BestHeight)
        UIDifference := CurrentAdjustOffset.Y - BestAdjustOffset.Y

        CurrentHeightMessage := S2M(CurrentHeight.ToMeters() + " m")
        BestHeightMessage := S2M(BestHeight.ToMeters() + " m")

        CurrentHeightText.SetText(CurrentHeightMessage)
        BestHeightText.SetText(BestHeightMessage)

        CurrentSizeAdjust.SetDesiredSize(CurrentAdjustOffset)
        BestSizeAdjust.SetDesiredSize(BestAdjustOffset)

        CurrentHeightText.SetText(CurrentHeightMessage)
        BestHeightText.SetText(BestHeightMessage)

        MarkerVisiblity := logic{UIDifference > 1.0}.ToWidgetVisibility()
        BestTextVisibility := logic{UIDifference > 15.0}.ToWidgetVisibility()

        CurrentMarker.SetVisibility(MarkerVisiblity)
        BestHeightText.SetVisibility(BestTextVisibility)

        CurrentHeightColor := if (UIDifference < 0.55). color{R :=0.723055, G :=0.020289, B :=0.386429} else NamedColors.Black
        CurrentHeightText.SetTextColor(CurrentHeightColor)
    }

    UpdateLocks(CheckpointIndex:int):void={
        case (CheckpointIndex):
            3 => Chillzone1.SetVisibility(widget_visibility.Hidden)
            6 => Chillzone2.SetVisibility(widget_visibility.Hidden)
            9 => Chillzone3.SetVisibility(widget_visibility.Hidden)
            _ => {}
    }

    UpdateBestTime(Time:float):void={
        TimerText.SetText(S2M("\n{Time.ToTime()}"))
    }

    UpdateCollectibles(TotalCollected:int):void={
        CollectiblesText.SetText(S2M("\n{TotalCollected} / 40"))
    }

    GetAdjustOffset(Height:float):vector2={
        vector2{Y := (1.0 - (Height / 147515.0)) * 375.0}
    }

    (L:logic).ToWidgetVisibility():widget_visibility=
        if (L?) then widget_visibility.Visible else widget_visibility.Hidden