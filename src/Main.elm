port module Main exposing (main, parseUrl, routeToString)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, nav, text)
import Html.Attributes exposing (attribute, class, href)
import Pages.Home
import Pages.NotFound
import Shared.Components.ErrorDisplay as ErrorDisplay
import Shared.Components.Loading as Loading
import Shared.Utils.BrowserDetection as BrowserDetection
import Tools.DataExtractor.View as DataExtractorView
import Tools.DataExtractor.Model as DataExtractorModel
import Tools.DataMerger.View
import Types.Common exposing (Route(..))
import Types.Errors exposing (AppError(..), BrowserInfo, ErrorReport, LoadingState(..), getErrorSeverity, toUserFriendlyMessage)
import Url
import Url.Parser exposing (Parser, oneOf, parse, s, top)


type alias Model =
    { key : Nav.Key
    , route : Route
    , globalError : Maybe AppError
    , loadingState : LoadingState
    , browserInfo : Maybe BrowserInfo
    , dataExtractorModel : DataExtractorModel.Model
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GlobalError AppError
    | ClearError
    | SetLoadingState LoadingState
    | BrowserInfoReceived BrowserInfo
    | DataExtractorMsg DataExtractorModel.Msg


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        route =
            parseUrl url

        ( dataExtractorModel, dataExtractorCmd ) =
            DataExtractorView.init
    in
    ( { key = key
      , route = route
      , globalError = Nothing
      , loadingState = NotLoading
      , browserInfo = Nothing
      , dataExtractorModel = dataExtractorModel
      }
    , Cmd.batch
        [ setBrowserInfoCmd
        , Cmd.map DataExtractorMsg dataExtractorCmd
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( { model | loadingState = LoadingRoute }
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                newRoute =
                    parseUrl url
            in
            ( { model
                | route = newRoute
                , globalError = Nothing
                , loadingState = NotLoading
              }
            , Cmd.none
            )

        GlobalError error ->
            ( { model
                | globalError = Just error
                , loadingState = NotLoading
              }
            , Cmd.none
            )

        ClearError ->
            ( { model | globalError = Nothing }
            , Cmd.none
            )

        SetLoadingState loadingState ->
            ( { model | loadingState = loadingState }
            , Cmd.none
            )

        BrowserInfoReceived browserInfo ->
            let
                compatibilityErrors =
                    BrowserDetection.checkCompatibility browserInfo

                newModel =
                    { model | browserInfo = Just browserInfo }
            in
            case compatibilityErrors of
                [] ->
                    ( newModel, Cmd.none )

                firstError :: _ ->
                    ( { newModel | globalError = Just firstError }
                    , Cmd.none
                    )

        DataExtractorMsg extractorMsg ->
            let
                ( updatedExtractorModel, extractorCmd ) =
                    DataExtractorView.update extractorMsg model.dataExtractorModel
            in
            ( { model | dataExtractorModel = updatedExtractorModel }
            , Cmd.map DataExtractorMsg extractorCmd
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
            , viewMainContent model
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
            [ class
                ("app__nav-link"
                    ++ (if currentRoute == Home then
                            " app__nav-link--active"

                        else
                            ""
                       )
                )
            , href "/"
            , attribute "data-testid" "nav-home"
            ]
            [ text "Home" ]
        ]




{-| Main content area based on current route
-}
viewMainContent : Model -> Html Msg
viewMainContent model =
    div [ class "app__content" ]
        [ viewLoadingOverlay model.loadingState
        , case model.globalError of
            Just error ->
                viewError error

            Nothing ->
                case model.route of
                    Home ->
                        Pages.Home.view

                    DataExtractor ->
                        Html.map DataExtractorMsg (DataExtractorView.view model.dataExtractorModel)

                    DataMerger ->
                        Tools.DataMerger.View.view

                    NotFound ->
                        Pages.NotFound.view
        ]


{-| Loading overlay display
-}
viewLoadingOverlay : LoadingState -> Html Msg
viewLoadingOverlay loadingState =
    case loadingState of
        NotLoading ->
            text ""

        LoadingRoute ->
            Loading.view
                { loadingType = Loading.Overlay
                , message = "Loading page..."
                , isVisible = True
                }

        ProcessingFile ->
            Loading.view
                { loadingType = Loading.Spinner
                , message = "Processing your file..."
                , isVisible = True
                }

        GeneratingPreview ->
            Loading.view
                { loadingType = Loading.ProgressBar
                , message = "Generating preview..."
                , isVisible = True
                }

        DownloadingFile ->
            Loading.view
                { loadingType = Loading.Spinner
                , message = "Preparing download..."
                , isVisible = True
                }

        ValidatingData ->
            Loading.view
                { loadingType = Loading.Spinner
                , message = "Validating data..."
                , isVisible = True
                }


{-| Enhanced error display using ErrorDisplay component
-}
viewError : AppError -> Html Msg
viewError error =
    let
        friendlyMessage =
            toUserFriendlyMessage error

        severity =
            getErrorSeverity error

        actions =
            getErrorActions error
    in
    ErrorDisplay.view
        { severity = severity
        , title = friendlyMessage.title
        , message = friendlyMessage.message
        , actions = actions
        }


{-| Get appropriate error actions based on error type
-}
getErrorActions : AppError -> List (ErrorDisplay.ErrorAction Msg)
getErrorActions error =
    case error of
        BrowserCompatibilityError _ ->
            [ ErrorDisplay.Dismiss ClearError ]

        NetworkError _ ->
            [ ErrorDisplay.Retry ClearError
            , ErrorDisplay.Dismiss ClearError
            ]

        UnexpectedError _ ->
            [ ErrorDisplay.Restart (GlobalError (NavigationError "Restarting application"))
            , ErrorDisplay.GoHome ClearError
            , ErrorDisplay.Dismiss ClearError
            ]

        _ ->
            [ ErrorDisplay.Retry ClearError
            , ErrorDisplay.Dismiss ClearError
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ browserInfoReceived BrowserInfoReceived
        , Sub.map DataExtractorMsg (DataExtractorView.subscriptions model.dataExtractorModel)
        ]


{-| Command to request browser information
-}
setBrowserInfoCmd : Cmd Msg
setBrowserInfoCmd =
    getBrowserInfo ()




{-| Port to get browser information
-}
port getBrowserInfo : () -> Cmd msg


{-| Port to receive browser information
-}
port browserInfoReceived : (BrowserInfo -> msg) -> Sub msg




{-| Port to report errors for development debugging
-}
port reportError : ErrorReport -> Cmd msg


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
