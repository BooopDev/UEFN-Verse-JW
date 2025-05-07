using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

#* Creative Objects
(P:positional).Translation<public>()<transacts>:vector3 = P.GetTransform().Translation
(P:positional).Rotation<public>()<transacts>:rotation = P.GetTransform().Rotation
(P:positional).Scale<public>()<transacts>:vector3 = P.GetTransform().Scale

(Billboard: billboard_device).UpdateText<public>(Message: message):void={
    Billboard.SetText(Message)
    Billboard.UpdateDisplay()
}

GetObjectsWithTag<public>(Tag:tag, CreativeDevice: creative_device):[]creative_object_interface={
    Objects := CreativeDevice.FindCreativeObjectsWithTag(Tag)
    var Array:[]creative_object_interface = array{}
    for (Object:Objects) do set Array += array{Object}
    return Array
}

#* Async/Concurrency
DelayTicks<public>(Ticks:int)<suspends>:void = for (Tick := 0..Ticks) do Sleep(0.0)

ArrayRace(Array:[]t, Function(Element:t)<suspends>:u where t:type, u:type)<suspends>:u=
    if:
        Array.Length > 1
        Mid := Floor(Array.Length / 2)
        LeftArray := Array.Slice[0, Mid]
        RightArray := Array.Slice[Mid]
    then:
        race:
            ArrayRace(LeftArray, Function)
            ArrayRace(RightArray, Function)
    else if:
        First := Array[0]
    then:
        Function(First)
    else:
        # A race with no subtasks never completes, so sleep infinitely and call Err() because we shouldn't return a value here.
        # Debug.LogWarning("ArrayRace Called with No Subtasks, Sleeping Infinitely!")
        Sleep(Inf)
        Err()

ArraySync(Array:[]t, Function(Element:t)<suspends>:u where t:type, u:type)<suspends>:[]u=
    if:
        Array.Length > 1
        Mid := Floor(Array.Length / 2)
        LeftArray := Array.Slice[0, Mid]
        RightArray := Array.Slice[Mid]
    then:
        SyncResult := sync:
            ArraySync(LeftArray, Function)
            ArraySync(RightArray, Function)
    
        SyncResult(0) + SyncResult(1)
    else if:
        First := Array[0]
    then:
        # Grab the only element in the array and call the async function with it as the argument and add the result to an array.
        array{Function(First)}
    else:
        # No element in the given Array so return an empty array.
        array{}

#* Player / Agent / FortCharacter
(Playspace:fort_playspace).GetPlayerCount<public>()<transacts>:int = Playspace.GetPlayers().Length
(Playspace:fort_playspace).GetPlayer<public>(Index:int)<transacts><decides>:player = Playspace.GetPlayers()[Index]

(Playspace:fort_playspace).GetAgents<public>()<transacts>:[]agent = Playspace.GetPlayers()
(Playspace:fort_playspace).GetAgent<public>(Index:int)<transacts><decides>:agent = Playspace.GetPlayer[Index]

(Playspace:fort_playspace).GetFortCharacters<public>()<transacts>:[]fort_character = for (A:Playspace.GetAgents(), FC := A.GetFortCharacter[]) do FC
(Playspace:fort_playspace).GetFortCharacter<public>(Index:int)<transacts><decides>:fort_character = Playspace.GetFortCharacters()[Index]

#* User Interface
(M:margin).All(Padding:float)<transacts>:margin = margin{Left :=Padding, Right :=Padding, Top :=Padding, Bottom :=Padding}
(A:anchors).FullScreen():anchors = anchors{Minimum :=vector2{X :=0.0, Y :=0.0}, Maximum :=vector2{X :=1.0, Y :=1.0}}
(L:logic).ToInputMode():ui_input_mode = if (L?) then ui_input_mode.All else ui_input_mode.None

#* String / Message
P2M<localizes><public>(P:player)<transacts>:message = "{P}"
S2M<localizes><public>(S:string)<transacts>:message = "{S}"

operator'+'<localizes><public>(M1:message, M2:message)<transacts>:message = "{M1} {M2}"
operator'+'<localizes><public>(S:string, M:message)<transacts>:message = "{S} {M}"
operator'+'<localizes><public>(M:message, S:string)<transacts>:message = "{M} {S}"
operator'+'<localizes><public>(M:message, P:player)<transacts>:message = "{M} {P}"
operator'+'<localizes><public>(P:player, M:message)<transacts>:message = "{P} {M}"

(L:logic).ToString<public>()<transacts>:string = if (L?) then "true" else "false"
(V3:vector3).ToString<public>()<transacts>:string = "X:{V3.X} Y:{V3.Y} Z:{V3.Z}"
(V2:vector2).ToString<public>()<transacts>:string = "X:{V2.X} Y:{V2.Y}"
(F:float).ToString<public>(Decimal:int)<transacts>:string={
    WholeNumbers := Floor[F] or 0
    if (Decimal <= 0). return "{WholeNumbers}"

    DecimalNumbers := Abs(F - WholeNumbers * 1.0)
    DecimalString := ToString(DecimalNumbers)
    Sliced := DecimalString.Slice[1, 2 + Clamp(Decimal, 0, DecimalString.Length-1)] or ""

    return "{WholeNumbers}{Sliced}"
}

(F:float).ToTime<public>()<transacts>:string=
    Hours := Floor[F / 3600.0] or 0
    Mins := Floor[(F - Hours * 3600.0) / 60.0] or 0
    Secs := Floor[F - Hours * 3600.0 - Mins * 60.0] or 0
    Ms := Floor[(F - Floor[F] * 1.0) * 1000.0] or 0

    HourText := if (Hours < 10) then "0{Hours}" else "{Hours}"
    MinuteText := if (Mins < 10) then "0{Mins}" else "{Mins}"
    SecondText := if (Secs < 10) then "0{Secs}" else "{Secs}"
    MillisecondText := if (Ms < 10) then "0{Ms}" else "{Ms}"
    
    if (Hours = 0):
        return "{MinuteText}:{SecondText}.{MillisecondText.Slice[0,2] or MillisecondText}"
    else:
        return "{HourText}:{MinuteText}:{SecondText}.{MillisecondText.Slice[0,2] or MillisecondText}"

(F:float).ToMeters<public>()<transacts>:string={
    Meters: int := Floor[F * 0.01] or 0
    Remainder: int := Round[(F * 0.01 - ((Floor[F * 0.01] or 0)*1.0)) * 10.0] or 0
    RemainderStr := if (Remainder >= 10) then "9" else "{Remainder}"
    return "{Meters}.{RemainderStr}"
}

#* Arrays / Maps
(Input:[]int).SumInts<public>()<transacts>:int= 
    var Total:int = 0
    for(Num:Input):
        set Total += Num
    return Total

(Input:[]float).SumFloats<public>()<transacts>:float= 
    var Total:float = 0.0
    for(Num:Input):
        set Total += Num
    return Total

(Input:[]t where t:type).Sort<public>(Comparer:type{_(:t, :t)<transacts>:int}, SortOrder:OrderBy)<transacts>:[]t=
    if (Input.Length > 1, Pivot := Input[Floor[Input.Length * 0.5]]):
        Less := for(Item : Input, Comparer(Item, Pivot) < 0) do Item 
        Equal := for(Item : Input, Comparer(Item, Pivot) = 0) do Item
        Greater := for(Item : Input, Comparer(Item, Pivot) > 0) do Item
        if(SortOrder = OrderBy.Asc):
            Less.Sort(Comparer, SortOrder) + Equal + Greater.Sort(Comparer, SortOrder)
        else: 
            Greater.Sort(Comparer, SortOrder) + Equal + Less.Sort(Comparer, SortOrder)
    else:    
        Input

(Input:[]int).SortInts<public>(SortOrder:OrderBy)<transacts>:[]int= 
    return Input.Sort(CompareInts, SortOrder)

(Input:[]float).SortFloats<public>(SortOrder:OrderBy)<transacts>:[]float= 
    return Input.Sort(CompareFloats, SortOrder)

(Input:[comparable]t where t:type).SortMap<public>(Comparer:type{_(:t, :t)<transacts>:int}, SortOrder:OrderBy)<transacts>:[]t=
    Input.ToArray().Sort(Comparer, SortOrder)
    
CompareInts<public>(A:int, B:int)<transacts>:int=
    if (A > B) then 1
    if (A < B) then -1
    return 0

CompareFloats<public>(A:float, B:float)<transacts>:int=
    if (A > B) then 1
    if (A < B) then -1
    return 0

OrderBy<public> := enum{Asc, Desc}

(Map:[comparable]comparable).RemoveElementFromMap<public>(Element:comparable):[comparable]comparable=
    var NewMap:[comparable]comparable = map{}
    for (Key -> Value : Map, Key <> Element):
        set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
    return NewMap

(Map:[comparable]t where t:type).ToArray<public>()<transacts>:[]t=
    for (Value:Map) do Value

#* Math
RoundToDecimals<public>(Value: float, Decimal:int):float={
    Factor := Pow(10.0, Decimal * 1.0)
    RoundedValue := Round[Value * Factor] or 0
    return RoundedValue * 1.0 / Factor
}

#* Vectors
(V2:vector2).Up():vector2 = vector2{X :=0.0, Y :=1.0}
(V3:vector3).Up():vector3 = vector3{X :=0.0, Y :=0.0, Z :=1.0}
(T:transform).Up():vector3 = T.Rotation.GetLocalUp()

(V2:vector2).Down():vector2 = vector2{X :=0.0, Y :=-1.0}
(V3:vector3).Down():vector3 = vector3{X :=0.0, Y :=0.0, Z :=-1.0}
(T:transform).Down():vector3 = -T.Rotation.GetLocalUp()

(V2:vector2).Right():vector2 = vector2{X :=1.0, Y :=0.0}
(V3:vector3).Right():vector3 = vector3{X :=1.0, Y :=0.0, Z :=0.0}
(T:transform).Right():vector3 = T.Rotation.GetLocalRight()

(V2:vector2).Left():vector2 = vector2{X :=-1.0, Y :=0.0}
(V3:vector3).Left():vector3 = vector3{X :=-1.0, Y :=0.0, Z :=0.0}
(T:transform).Left():vector3 = -T.Rotation.GetLocalRight()

(V3:vector3).Forward():vector3 = vector3{X :=0.0, Y :=1.0, Z :=0.0}
(T:transform).Forward():vector3 = T.Rotation.GetLocalForward()

(V3:vector3).Backward():vector3 = vector3{X :=0.0, Y :=-1.0, Z :=0.0}
(T:transform).Backward():vector3 = -T.Rotation.GetLocalForward()

(V2:vector2).One():vector2 = vector2{X :=1.0, Y :=1.0}
(V3:vector3).One():vector3 = vector3{X :=1.0, Y :=1.0, Z :=1.0}

#* Event Functions

(Listenable : listenable(agent)).SubscribeAgent<public>(OutputFunc : tuple(agent, t)->void, ExtraData : t where t:type) : cancelable =
    Wrapper := wrapper_agent(t){ExtraData := ExtraData, OutputFunc := OutputFunc}
    Listenable.Subscribe(Wrapper.InputFunc)

wrapper_agent(t : type) := class():
    ExtraData<public>: t;
    OutputFunc<public>: tuple(agent, t) -> void
    InputFunc<public>(Agent : agent):void = OutputFunc(Agent, ExtraData)

(Listenable : listenable(player)).SubscribePlayer<public>(OutputFunc : tuple(player, t)->void, ExtraData : t where t:type) : cancelable =
    Wrapper := wrapper_player(t){ExtraData := ExtraData, OutputFunc := OutputFunc}
    Listenable.Subscribe(Wrapper.InputFunc)

wrapper_player(t : type) := class():
    ExtraData<public>: t;
    OutputFunc<public>: tuple(player, t) -> void
    InputFunc<public>(Player : player):void = OutputFunc(Player, ExtraData)

(Listenable : listenable(tuple(agent, float))).SubscribeReleased<public>(OutputFunc : tuple(agent, float, t)->void, ExtraData : t where t:type) : cancelable =
            Wrapper := wrapper_released(t){ExtraData := ExtraData, OutputFunc := OutputFunc}
            Listenable.Subscribe(Wrapper.InputFunc)

wrapper_released(t : type) := class():
    ExtraData<public>: t;
    OutputFunc<public>: tuple(agent, float, t) -> void
    InputFunc<public>(Agent : agent, Float : float):void = OutputFunc(Agent, Float, ExtraData)

(WidgetMessage : listenable(widget_message)).SubscribeWidget<public>(OutputFunc : tuple(widget_message, t)->void, ExtraData : t where t:type) : cancelable =
    Wrapper := wrapper_widget_optional(t){ExtraData := ExtraData, OutputFunc := OutputFunc}
    WidgetMessage.Subscribe(Wrapper.InputFunc)

wrapper_widget_optional(t : type) := class():
    ExtraData<public>: t;
    OutputFunc<public>: tuple(widget_message, t) -> void
    InputFunc<public>(WidgetMessage : widget_message):void = OutputFunc(WidgetMessage, ExtraData)

(ListenableOptional : listenable(?agent)).SubscribeAgentOptional<public>(OutputFunc : tuple(?agent, t)->void, ExtraData : t where t:type) : cancelable =
    Wrapper := wrapper_agent_optional(t){ExtraData := ExtraData, OutputFunc := OutputFunc}
    ListenableOptional.Subscribe(Wrapper.InputFunc)

wrapper_agent_optional<public>(t : type) := class():
    ExtraData<public>: t;
    OutputFunc<public>: tuple(?agent, t) -> void
    InputFunc<public>(Agent : ?agent):void = OutputFunc(Agent, ExtraData)

(ListenableDamage : listenable(damage_result)).SubscribeDamage<public>(OutputFunc : tuple(damage_result, t)->void, ExtraData : t where t:type) : cancelable =
    Wrapper := wrapper_damage_optional(t){ExtraData := ExtraData, OutputFunc := OutputFunc}
    ListenableDamage.Subscribe(Wrapper.InputFunc)

wrapper_damage_optional(t : type) := class():
    ExtraData<public>: t;
    OutputFunc<public>: tuple(damage_result, t) -> void
    InputFunc<public>(Damage : damage_result):void = OutputFunc(Damage, ExtraData)

(Listenable : listenable(tuple())).SubscribeEmpty<public>(OutputFunc : t -> void, ExtraData : t where t:type) : cancelable =
    Wrapper := wrapper_empty(t) {ExtraData := ExtraData, OutputFunc := OutputFunc}
    Listenable.Subscribe(Wrapper.InputFunc)

wrapper_empty<public>(t : type) := class():
    ExtraData<public>: t;
    OutputFunc<public>: t -> void
    InputFunc<public>():void = OutputFunc(ExtraData)

#* Animation Easing Functions

EaseInQuad<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.11, Y0 := 0.0, X1 := 0.5, Y1 := 0.0}
EaseOutQuad<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.5, Y0 := 1.0, X1 := 0.89, Y1 := 1.0}
EaseInOutQuad<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.45, Y0 := 0.0, X1 := 0.55, Y1 := 1.0}

EaseInCubic<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.32, Y0 := 0.0, X1 := 0.67, Y1 := 0.0}
EaseOutCubic<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.33, Y0 := 1.0, X1 := 0.68, Y1 := 1.0}
EaseInOutCubic<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.65, Y0 := 0.0, X1 := 0.35, Y1 := 1.0}

EaseInQuart<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.5, Y0 := 0.0, X1 := 0.75, Y1 := 0.0}
EaseOutQuart<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.25, Y0 := 1.0, X1 := 0.5, Y1 := 1.0}
EaseInOutQuart<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.76, Y0 := 0.0, X1 := 0.24, Y1 := 1.0}

EaseInQuint<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.64, Y0 := 0.0, X1 := 0.78, Y1 := 0.0}
EaseOutQuint<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.22, Y0 := 1.0, X1 := 0.36, Y1 := 1.0}
EaseInOutQuint<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.83, Y0 := 0.0, X1 := 0.17, Y1 := 1.0}

EaseInExpo<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.7, Y0 := 0.0, X1 := 0.84, Y1 := 0.0}
EaseOutExpo<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.16, Y0 := 1.0, X1 := 0.3, Y1 := 1.0}
EaseInOutExpo<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.87, Y0 := 0.0, X1 := 0.13, Y1 := 1.0}

EaseInCirc<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.55, Y0 := 0.0, X1 := 1.0, Y1 := 0.45}
EaseOutCirc<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.0, Y0 := 0.55, X1 := 0.45, Y1 := 1.0}
EaseInOutCirc<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.85, Y0 := 0.0, X1 := 0.15, Y1 := 1.0}

EaseInBack<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.36, Y0 := 0.0, X1 := 0.66, Y1 := -0.56}
EaseOutBack<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.34, Y0 := 1.56, X1 := 0.64, Y1 := 1.0}
EaseInOutBack<public>:cubic_bezier_parameters= cubic_bezier_parameters {X0 := 0.68, Y0 := -0.6, X1 := 0.32, Y1 := 1.6}

#* Debug

Debug<public> := module:
    DebugDrawChannel := class(debug_draw_channel){}
    DebugLogChannel := class(log_channel){}

    LogError<public>(String:string)<transacts>:void=
        Print("{String}", ?Color :=color{R :=1.0,G :=0.0,B :=0.0}, ?Duration :=10.0)
        log{Channel :=DebugLogChannel}.PrintCallStack()

    LogWarning<public>(String:string)<transacts>:void = Print("{String}", ?Color :=color{R :=1.0,G :=1.0,B :=0.0}, ?Duration :=5.0)
    LogInfo<public>(String:string)<transacts>:void = Print("{String}", ?Color :=color{R :=0.0,G :=0.0,B :=1.0})

    DrawSphere<public>(Loc:vector3, Radius:float, ?Duration:float = 3.0, ?DurationPolicy:debug_draw_duration_policy = debug_draw_duration_policy.FiniteDuration, ?Colour:color = NamedColors.Red):void=
        debug_draw{Channel := DebugDrawChannel}.DrawSphere(Center := Loc, ?Radius := Radius, ?Duration := Duration, ?DrawDurationPolicy := DurationPolicy)

    DrawCube<public>(Loc:vector3, Rot:rotation, ?Extents:vector3 = vector3{X := 1.0, Y := 1.0, Z := 1.0}, ?Duration:float = 3.0, ?DurationPolicy:debug_draw_duration_policy = debug_draw_duration_policy.FiniteDuration, ?Colour:color = NamedColors.Red):void=
        debug_draw{Channel := DebugDrawChannel}.DrawBox(Center := Loc, Rotation := Rot, ?Extent := Extents / 2.0, ?Duration := Duration, ?DrawDurationPolicy := DurationPolicy)
