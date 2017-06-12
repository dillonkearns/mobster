module StylesheetHelper exposing (CssClasses(..), class, classList, id)

import Html.CssHelpers


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"


type CssClasses
    = BufferTop
    | BufferRight
    | Green
    | Orange
    | Red
    | DropAreaInactive
    | DropAreaActive
    | LargeButtonText
    | TooltipContainer
    | Tooltip
    | ShowOnParentHover
    | ShowOnParentHoverParent
    | HasHoverActions
    | DragBelow
    | HasError
    | RpgIcon1
    | RpgIcon2
    | ButtonMuted
    | HandPointer
    | Title
