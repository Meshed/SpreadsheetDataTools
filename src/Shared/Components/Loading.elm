module Shared.Components.Loading exposing (view, getLoadingMessage, LoadingConfig, LoadingType(..))

{-| Loading state components for user feedback during operations.

@docs view, getLoadingMessage, LoadingConfig, LoadingType

-}

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (attribute, class)
import Types.Errors exposing (LoadingState(..))


{-| Type of loading display
-}
type LoadingType
    = Spinner
    | ProgressBar
    | Overlay


{-| Configuration for loading display
-}
type alias LoadingConfig =
    { loadingType : LoadingType
    , message : String
    , isVisible : Bool
    }


{-| Display loading state with appropriate styling
-}
view : LoadingConfig -> Html msg
view config =
    if not config.isVisible then
        text ""

    else
        case config.loadingType of
            Spinner ->
                viewSpinner config.message

            ProgressBar ->
                viewProgressBar config.message

            Overlay ->
                viewOverlay config.message


{-| Loading spinner component
-}
viewSpinner : String -> Html msg
viewSpinner message =
    div
        [ class "loading-spinner"
        , attribute "data-testid" "loading-spinner"
        ]
        [ div [ class "loading-spinner__icon" ] []
        , p [ class "loading-spinner__message" ]
            [ text message ]
        ]


{-| Progress bar component
-}
viewProgressBar : String -> Html msg
viewProgressBar message =
    div
        [ class "loading-progress"
        , attribute "data-testid" "loading-progress"
        ]
        [ div [ class "loading-progress__bar" ]
            [ div [ class "loading-progress__fill" ] [] ]
        , p [ class "loading-progress__message" ]
            [ text message ]
        ]


{-| Overlay loading component
-}
viewOverlay : String -> Html msg
viewOverlay message =
    div
        [ class "loading-overlay"
        , attribute "data-testid" "loading-overlay"
        ]
        [ div [ class "loading-overlay__content" ]
            [ div [ class "loading-overlay__spinner" ] []
            , p [ class "loading-overlay__message" ]
                [ text message ]
            ]
        ]


{-| Get loading message for different states
-}
getLoadingMessage : LoadingState -> String
getLoadingMessage state =
    case state of
        NotLoading ->
            ""

        LoadingRoute ->
            "Loading page..."

        ProcessingFile ->
            "Processing your file..."

        GeneratingPreview ->
            "Generating preview..."

        DownloadingFile ->
            "Preparing download..."

        ValidatingData ->
            "Validating data..."
