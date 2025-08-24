module Main exposing (main, parseUrl, routeToString)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div, nav, a, text)
import Html.Attributes exposing (class, href, attribute)
import Pages.Home
import Pages.NotFound
import Tools.DataExtractor.View
import Tools.DataMerger.View
import Types.Common exposing (Route(..), AppError(..))
import Url
import Url.Parser exposing (Parser, oneOf, s, top, parse)


type alias Model =
    { key : Nav.Key
    , route : Route
    , globalError : Maybe AppError
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        route = parseUrl url
    in
    ( { key = key
      , route = route
      , globalError = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                newRoute = parseUrl url
            in
            ( { model | route = newRoute, globalError = Nothing }
            , Cmd.none
            )


{-| Parse URL to Route
-}
parseUrl : Url.Url -> Route
parseUrl url =
    case parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFound


{-| URL parser for application routes
-}
routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ Url.Parser.map Home top
        , Url.Parser.map Home (s "home")
        , Url.Parser.map DataExtractor (s "data-extractor")
        , Url.Parser.map DataMerger (s "data-merger")
        ]


{-| Convert Route to URL string
-}
routeToString : Route -> String
routeToString route =
    case route of
        Home ->
            "/"

        DataExtractor ->
            "/data-extractor"

        DataMerger ->
            "/data-merger"

        NotFound ->
            "/not-found"


view : Model -> Browser.Document Msg
view model =
    { title = pageTitle model.route
    , body = 
        [ div [ class "app" ]
            [ viewNavigation model.route
            , viewMainContent model.route model.globalError
            ]
        ]
    }


{-| Get page title based on current route
-}
pageTitle : Route -> String
pageTitle route =
    case route of
        Home ->
            "Spreadsheet Data Tools"

        DataExtractor ->
            "Data Extractor - Spreadsheet Data Tools"

        DataMerger ->
            "Data Merger - Spreadsheet Data Tools"

        NotFound ->
            "Page Not Found - Spreadsheet Data Tools"


{-| Navigation bar component
-}
viewNavigation : Route -> Html Msg
viewNavigation currentRoute =
    nav [ class "app__nav" ]
        [ a
            [ class ("app__nav-link" ++ if currentRoute == Home then " app__nav-link--active" else "")
            , href "/"
            , attribute "data-testid" "nav-home"
            ]
            [ text "Home" ]
        , a
            [ class ("app__nav-link" ++ if currentRoute == DataExtractor then " app__nav-link--active" else "")
            , href "/data-extractor"
            , attribute "data-testid" "nav-data-extractor"
            ]
            [ text "Data Extractor" ]
        , a
            [ class ("app__nav-link" ++ if currentRoute == DataMerger then " app__nav-link--active" else "")
            , href "/data-merger"
            , attribute "data-testid" "nav-data-merger"
            ]
            [ text "Data Merger" ]
        ]


{-| Main content area based on current route
-}
viewMainContent : Route -> Maybe AppError -> Html Msg
viewMainContent route globalError =
    div [ class "app__content" ]
        [ case globalError of
            Just error ->
                viewError error

            Nothing ->
                case route of
                    Home ->
                        Pages.Home.view

                    DataExtractor ->
                        Tools.DataExtractor.View.view

                    DataMerger ->
                        Tools.DataMerger.View.view

                    NotFound ->
                        Pages.NotFound.view
        ]


{-| Error display component
-}
viewError : AppError -> Html Msg
viewError error =
    div [ class "app__error" ]
        [ case error of
            UrlParsingError message ->
                text ("URL Parsing Error: " ++ message)

            NavigationError message ->
                text ("Navigation Error: " ++ message)

            UnknownRouteError message ->
                text ("Unknown Route Error: " ++ message)
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }