module Shared.Components.ErrorDisplay exposing (view, ErrorConfig, ErrorSeverity(..), ErrorAction(..))

{-| ErrorDisplay component for showing user-friendly error messages.

@docs view, ErrorConfig, ErrorSeverity, ErrorAction

-}

import Html exposing (Html, button, div, h3, p, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)


{-| Error severity levels for styling
-}
type ErrorSeverity
    = Warning
    | Error
    | Critical


{-| Available error actions
-}
type ErrorAction msg
    = Retry msg
    | Dismiss msg
    | Restart msg
    | GoHome msg


{-| Configuration for error display
-}
type alias ErrorConfig msg =
    { severity : ErrorSeverity
    , title : String
    , message : String
    , actions : List (ErrorAction msg)
    }


{-| Display error message with user-friendly formatting
-}
view : ErrorConfig msg -> Html msg
view config =
    div
        [ class ("error-display " ++ severityClass config.severity)
        , attribute "data-testid" "error-display"
        ]
        [ div [ class "error-display__content" ]
            [ h3 [ class "error-display__title" ]
                [ text config.title ]
            , p [ class "error-display__message" ]
                [ text config.message ]
            , if List.isEmpty config.actions then
                text ""

              else
                div [ class "error-display__actions" ]
                    (List.map viewAction config.actions)
            ]
        ]


{-| Get CSS class for error severity
-}
severityClass : ErrorSeverity -> String
severityClass severity =
    case severity of
        Warning ->
            "error-display--warning"

        Error ->
            "error-display--error"

        Critical ->
            "error-display--critical"


{-| Render error action button
-}
viewAction : ErrorAction msg -> Html msg
viewAction action =
    case action of
        Retry msg ->
            button
                [ class "error-display__action btn btn--primary"
                , onClick msg
                , attribute "data-testid" "error-action-retry"
                ]
                [ text "Try Again" ]

        Dismiss msg ->
            button
                [ class "error-display__action btn btn--secondary"
                , onClick msg
                , attribute "data-testid" "error-action-dismiss"
                ]
                [ text "Dismiss" ]

        Restart msg ->
            button
                [ class "error-display__action btn btn--secondary"
                , onClick msg
                , attribute "data-testid" "error-action-restart"
                ]
                [ text "Start Over" ]

        GoHome msg ->
            button
                [ class "error-display__action btn btn--secondary"
                , onClick msg
                , attribute "data-testid" "error-action-home"
                ]
                [ text "Go Home" ]
