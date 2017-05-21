module Keyboard.Combo
    exposing
        ( KeyCombo
        , Key
        , Model
        , Msg
        , update
        , init
        , subscriptions
        , combo1
        , combo2
        , combo3
        , combo4
        , super
        , command
        , shift
        , control
        , alt
        , option
        , enter
        , tab
        , escape
        , space
        , backspace
        , delete
        , a
        , b
        , c
        , d
        , e
        , f
        , g
        , h
        , i
        , j
        , k
        , l
        , m
        , n
        , o
        , p
        , q
        , r
        , s
        , t
        , u
        , v
        , w
        , x
        , y
        , z
        , zero
        , one
        , two
        , three
        , four
        , five
        , six
        , seven
        , eight
        , nine
        , left
        , right
        , up
        , down
        , period
        , comma
        , semicolon
        , singleQuote
        , minus
        , equals
        , openBracket
        , closeBracket
        , backSlash
        , forwardSlash
        , backTick
        )

{-| Provides helpers to call messages on the given key combinations

## Types

@docs Model, Msg, KeyCombo, Key

## Setup

    import Keyboard.Combo

    type alias Model =
        { keys : Keyboard.Combo.Model Msg }

    type Msg
        = Save
        | SaveAll
        | RandomThing
        | ComboMsg Keyboard.Combo.Msg

    keyboardCombos : List (Keyboard.Combo.KeyCombo Msg)
    keyboardCombos =
        [ Keyboard.Combo.combo2 ( Keyboard.Combo.control, Keyboard.Combo.s ) Save
        , Keyboard.Combo.combo2 ( Keyboard.Combo.control, Keyboard.Combo.a ) SelectAll
        , Keyboard.Combo.combo3 ( Keyboard.Combo.control, Keyboard.Combo.alt, Keyboard.Combo.e ) RandomThing
        ]

    init : ( Model, Cmd Msg )
    init =
        { keys =
            Keyboard.Combo.init { toMsg = ComboMsg , combos = keyboardCombos }
        }
            ! []


    subscriptions : Model -> Sub Msg
    subscriptions model =
        Keyboard.Combo.subscriptions model.keys

@docs init, subscriptions, update

## Combo Helpers

    import Keyboard.Combo

    type Msg
        = Save
        | SaveAll
        | RandomThing

    keyboardCombos : List (Keyboard.Combo.KeyCombo Msg)
    keyboardCombos =
        [ Keyboard.Combo.combo2 ( Keyboard.Combo.control, Keyboard.Combo.s ) Save
        , Keyboard.Combo.combo2 ( Keyboard.Combo.control, Keyboard.Combo.a ) SelectAll
        , Keyboard.Combo.combo3 ( Keyboard.Combo.control, Keyboard.Combo.alt, Keyboard.Combo.e ) RandomThing
        ]

@docs combo1, combo2, combo3, combo4

## Modifiers

@docs super, command, shift, control, alt, option, enter, tab, escape, space, backspace, delete


## Letters

@docs a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z

## Number Helpers

@docs zero, one, two, three, four, five, six, seven, eight, nine

## Arrow Helpers

@docs left, right, up, down


## Punctuation

@docs period, comma, semicolon, singleQuote, minus, equals, openBracket, closeBracket, backSlash, forwardSlash, backTick
-}

import Keyboard.Extra
import Task


-- Model


{-| Internal state that keeps track of keys currently pressed and key combos
-}
type alias Model msg =
    { keys : Keyboard.Extra.State
    , combos : List (KeyCombo msg)
    , toMsg : Msg -> msg
    , activeCombo : Maybe (KeyCombo msg)
    }


{-| Each key uses this type
-}
type alias Key =
    Keyboard.Extra.Key


{-| Combo length types
-}
type KeyCombo msg
    = KeyCombo Key msg
    | KeyCombo2 Key Key msg
    | KeyCombo3 Key Key Key msg
    | KeyCombo4 Key Key Key Key msg



-- Init


{-| Initialize the module
-}
init : { a | toMsg : Msg -> msg, combos : List (KeyCombo msg) } -> Model msg
init config =
    { keys = Keyboard.Extra.initialState
    , combos = config.combos
    , toMsg = config.toMsg
    , activeCombo = Nothing
    }


{-| Subscribe to module key events
-}
subscriptions : Model parentMsg -> Sub parentMsg
subscriptions model =
    Sub.map model.toMsg Keyboard.Extra.subscriptions



-- Update


{-| Internal update messages
-}
type alias Msg =
    Keyboard.Extra.Msg


{-| Update the internal model. The command should be forwarded by the parent `update`.

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            ComboMsg msg ->
                let
                    ( updatedKeys, comboCmd ) =
                        Keyboard.Combo.update msg model.keys
                in
                    ( { model | keys = updatedKeys }, comboCmd )

-}
update : Msg -> Model msg -> ( Model msg, Cmd msg )
update msg model =
    updateActiveCombo
        { model | keys = Keyboard.Extra.update msg model.keys }



-- Combo helpers


{-| Helper to define a key combo of one key
-}
combo1 : Key -> msg -> KeyCombo msg
combo1 key msg =
    KeyCombo key msg


{-| Helper to define a key combo of two keys
-}
combo2 : ( Key, Key ) -> msg -> KeyCombo msg
combo2 ( key1, key2 ) msg =
    KeyCombo2 key1 key2 msg


{-| Helper to define a key combo of three keys
-}
combo3 : ( Key, Key, Key ) -> msg -> KeyCombo msg
combo3 ( key1, key2, key3 ) msg =
    KeyCombo3 key1 key2 key3 msg


{-| Helper to define a key combo of four keys
-}
combo4 : ( Key, Key, Key, Key ) -> msg -> KeyCombo msg
combo4 ( key1, key2, key3, key4 ) msg =
    KeyCombo4 key1 key2 key3 key4 msg



-- Modifier Keys


{-| Helper for super key
-}
super : Key
super =
    Keyboard.Extra.Super


{-| Helper for macOS command key
-}
command : Key
command =
    super


{-| Helper for shift key
-}
shift : Key
shift =
    Keyboard.Extra.Shift


{-| Helper for alt key
-}
alt : Key
alt =
    Keyboard.Extra.Alt


{-| Helper for macOS option key
-}
option : Key
option =
    alt


{-| Helper for control key
-}
control : Key
control =
    Keyboard.Extra.Control


{-| Helper for enter key
-}
enter : Key
enter =
    Keyboard.Extra.Enter


{-| Helper for tab key
-}
tab : Key
tab =
    Keyboard.Extra.Tab


{-| Helper for escape key
-}
escape : Key
escape =
    Keyboard.Extra.Escape


{-| Helper for space key
-}
space : Key
space =
    Keyboard.Extra.Space


{-| Helper for backspace key
-}
backspace : Key
backspace =
    Keyboard.Extra.BackSpace


{-| Helper for delete key
-}
delete : Key
delete =
    Keyboard.Extra.Delete



-- Letter helpers


{-| -}
a : Key
a =
    Keyboard.Extra.CharA


{-| -}
b : Key
b =
    Keyboard.Extra.CharB


{-| -}
c : Key
c =
    Keyboard.Extra.CharC


{-| -}
d : Key
d =
    Keyboard.Extra.CharD


{-| -}
e : Key
e =
    Keyboard.Extra.CharE


{-| -}
f : Key
f =
    Keyboard.Extra.CharF


{-| -}
g : Key
g =
    Keyboard.Extra.CharG


{-| -}
h : Key
h =
    Keyboard.Extra.CharH


{-| -}
i : Key
i =
    Keyboard.Extra.CharI


{-| -}
j : Key
j =
    Keyboard.Extra.CharJ


{-| -}
k : Key
k =
    Keyboard.Extra.CharK


{-| -}
l : Key
l =
    Keyboard.Extra.CharL


{-| -}
m : Key
m =
    Keyboard.Extra.CharM


{-| -}
n : Key
n =
    Keyboard.Extra.CharN


{-| -}
o : Key
o =
    Keyboard.Extra.CharO


{-| -}
p : Key
p =
    Keyboard.Extra.CharP


{-| -}
q : Key
q =
    Keyboard.Extra.CharQ


{-| -}
r : Key
r =
    Keyboard.Extra.CharR


{-| -}
s : Key
s =
    Keyboard.Extra.CharS


{-| -}
t : Key
t =
    Keyboard.Extra.CharT


{-| -}
u : Key
u =
    Keyboard.Extra.CharU


{-| -}
v : Key
v =
    Keyboard.Extra.CharV


{-| -}
w : Key
w =
    Keyboard.Extra.CharW


{-| -}
x : Key
x =
    Keyboard.Extra.CharX


{-| -}
y : Key
y =
    Keyboard.Extra.CharY


{-| -}
z : Key
z =
    Keyboard.Extra.CharZ



-- Number helpers


{-| -}
zero : Key
zero =
    Keyboard.Extra.Number0


{-| -}
one : Key
one =
    Keyboard.Extra.Number1


{-| -}
two : Key
two =
    Keyboard.Extra.Number2


{-| -}
three : Key
three =
    Keyboard.Extra.Number3


{-| -}
four : Key
four =
    Keyboard.Extra.Number4


{-| -}
five : Key
five =
    Keyboard.Extra.Number5


{-| -}
six : Key
six =
    Keyboard.Extra.Number6


{-| -}
seven : Key
seven =
    Keyboard.Extra.Number7


{-| -}
eight : Key
eight =
    Keyboard.Extra.Number8


{-| -}
nine : Key
nine =
    Keyboard.Extra.Number9



-- Arrow helpers


{-| -}
left : Key
left =
    Keyboard.Extra.ArrowLeft


{-| -}
right : Key
right =
    Keyboard.Extra.ArrowRight


{-| -}
up : Key
up =
    Keyboard.Extra.ArrowUp


{-| -}
down : Key
down =
    Keyboard.Extra.ArrowDown



-- Punctuation Helpers


{-| Helper for a `.`
-}
period : Key
period =
    Keyboard.Extra.Period


{-| Helper for a `,`
-}
comma : Key
comma =
    Keyboard.Extra.Comma


{-| Helper for a `;`
-}
semicolon : Key
semicolon =
    Keyboard.Extra.Semicolon


{-| Helper for a `'`
-}
singleQuote : Key
singleQuote =
    Keyboard.Extra.Quote


{-| Helper for a `-`
-}
minus : Key
minus =
    Keyboard.Extra.Minus


{-| Helper for a `=`
-}
equals : Key
equals =
    Keyboard.Extra.Equals


{-| Helper for a `[`
-}
openBracket : Key
openBracket =
    Keyboard.Extra.OpenBracket


{-| Helper for a `]`
-}
closeBracket : Key
closeBracket =
    Keyboard.Extra.CloseBracket


{-| Helper for a `\`
-}
backSlash : Key
backSlash =
    Keyboard.Extra.BackSlash


{-| Helper for a `/`
-}
forwardSlash : Key
forwardSlash =
    Keyboard.Extra.Quote


{-| Helper for a `` ` ``
-}
backTick : Key
backTick =
    Keyboard.Extra.BackQuote



-- Utils


updateActiveCombo : Model msg -> ( Model msg, Cmd msg )
updateActiveCombo model =
    let
        possibleCombo =
            matchesCombo model
    in
        { model | activeCombo = possibleCombo }
            ! getComboCmd possibleCombo model


getComboCmd : Maybe (KeyCombo msg) -> Model msg -> List (Cmd msg)
getComboCmd possibleCombo model =
    if possibleCombo == model.activeCombo then
        []
    else
        possibleCombo
            |> Maybe.map (\combo -> [ performComboTask combo ])
            |> Maybe.withDefault []


performComboTask : KeyCombo msg -> Cmd msg
performComboTask combo =
    getComboMsg combo
        |> Task.succeed
        |> Task.perform (\x -> x)


arePressed : Keyboard.Extra.State -> List Key -> Bool
arePressed keyTracker keysPressed =
    List.all
        (\key -> Keyboard.Extra.isPressed key keyTracker)
        keysPressed


matchesCombo : Model msg -> Maybe (KeyCombo msg)
matchesCombo model =
    find (\combo -> arePressed model.keys <| keyList combo) model.combos


keyList : KeyCombo msg -> List Key
keyList combo =
    case combo of
        KeyCombo key msg ->
            [ key ]

        KeyCombo2 key1 key2 msg ->
            [ key1, key2 ]

        KeyCombo3 key1 key2 key3 msg ->
            [ key1, key2, key3 ]

        KeyCombo4 key1 key2 key3 key4 msg ->
            [ key1, key2, key3, key4 ]


getComboMsg : KeyCombo msg -> msg
getComboMsg combo =
    case combo of
        KeyCombo _ msg ->
            msg

        KeyCombo2 _ _ msg ->
            msg

        KeyCombo3 _ _ _ msg ->
            msg

        KeyCombo4 _ _ _ _ msg ->
            msg


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first
            else
                find predicate rest
