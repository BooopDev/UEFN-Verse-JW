using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

ui_timer := class(base_ui):

    TimeText:text_block = text_block:
        DefaultTextColor := NamedColors.Gold
        DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
        DefaultShadowOpacity := 1.0
        DefaultJustification := text_justification.Center

    HeightText:text_block = text_block:
        DefaultTextColor := NamedColors.Cyan
        DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
        DefaultShadowOpacity := 1.0
        DefaultJustification := text_justification.Center

    Initialize<override>(PlayerData:player_data):void={
        TimeText.SetText(S2M("00:00.00"))
        HeightText.SetText(S2M("0.0"))
    }

    CreateCanvas<override>():canvas={
        canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Left := 0.0, Top := 30.0, Right := 240.0, Bottom := 80.0}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    SizeToContent := false
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := color_block:
                                    DefaultColor := NamedColors.Black
                                    DefaultOpacity := 0.2
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin{Left := 15.0, Right := 15.0}
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := array:
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := TimeText
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := HeightText
    }

    UpdateTime(CurrentTime:float):void={
        CurrentTimeText := CurrentTime.ToTime()
        TimeText.SetText(S2M(CurrentTimeText))
    }

    UpdateHeight(CurrentHeight:float):void={
        CurrentHeightText := CurrentHeight.ToMeters()
        HeightText.SetText(S2M(CurrentHeightText))
    }