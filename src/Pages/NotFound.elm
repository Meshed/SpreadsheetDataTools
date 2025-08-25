module Pages.NotFound exposing (view)

{-| 404 Not Found page component.

@docs view

-}

import Html exposing (Html, a, div, h1, p, text)
import Html.Attributes exposing (attribute, class, href)


{-| 404 Not Found page view with navigation back to home
-}
view : Html msg
view =
    div [ class "not-found", attribute "data-testid" "not-found-page" ]
        [ div [ class "not-found__content" ]
            [ h1 [ class "not-found__title" ]
                [ text "Page Not Found" ]
            , p [ class "not-found__message" ]
                [ text "The page you're looking for doesn't exist." ]
            , a
                [ class "not-found__home-link"
                , href "/"
                , attribute "data-testid" "error-home-link"
                ]
                [ text "Return to Homepage" ]
            ]
        ]
