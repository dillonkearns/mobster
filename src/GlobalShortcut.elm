module GlobalShortcut exposing (isInvalid)

import Regex exposing (Regex)


isInvalid : String -> Bool
isInvalid shortcutKey =
    Regex.contains invalidRegex shortcutKey


invalidRegex : Regex
invalidRegex =
    Regex.regex "[^a-zA-Z0-9]"
