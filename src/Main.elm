module Main exposing (main)

import Browser
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)


type alias Model =
    { message : String
    }


type Msg
    = NoOp


init : () -> ( Model, Cmd Msg )
init _ =
    ( { message = "Hello World" }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ h1 [ class "app__title" ]
            [ text "Spreadsheet Data Tools" ]
        , div [ class "app__content" ]
            [ text model.message ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }