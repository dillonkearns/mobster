module View.UpdateAvailableBeta exposing (view)

import Element
import Element.Attributes as Attr
import Element.Events
import Ipc
import Setup.Msg as Msg
import Styles


view : Maybe String -> Styles.StyleElement
view availableUpdateVersion =
    case availableUpdateVersion of
        Nothing ->
            Element.empty

        Just version ->
            Element.row Styles.UpdateAlertBox
                [ Attr.paddingXY 20 15, Attr.spacing 10 ]
                [ Element.el Styles.None [ Attr.class "fa fa-flag" ] Element.empty
                , Element.row Styles.None
                    [ Attr.spacing 5 ]
                    [ Element.text "A new version is downloaded and ready to install."
                    , Element.el Styles.UpdateNow
                        [ Element.Events.onClick (Msg.SendIpc Ipc.QuitAndInstall) ]
                        (Element.text "Update now")
                    ]
                ]
