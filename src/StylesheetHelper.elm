module StylesheetHelper exposing (CssClasses(..), class, classList, id)

import Html.CssHelpers


{ id, class, classList } =
    Html.CssHelpers.withNamespace "setup"


type CssClasses
    = RpgIcon1
    | RpgIcon2
