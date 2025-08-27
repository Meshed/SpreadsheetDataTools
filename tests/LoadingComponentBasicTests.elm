module LoadingComponentBasicTests exposing (..)

import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Types.Errors exposing (LoadingState(..))
import Shared.Components.Loading as Loading


suite : Test
suite =
    describe "Basic Loading Component Tests"
        [ describe "Loading Messages"
            [ test "LoadingRoute has correct message" <|
                \_ ->
                    Loading.getLoadingMessage LoadingRoute
                        |> Expect.equal "Loading page..."
            
            , test "ProcessingFile has correct message" <|
                \_ ->
                    Loading.getLoadingMessage ProcessingFile
                        |> Expect.equal "Processing your file..."
            
            , test "NotLoading has empty message" <|
                \_ ->
                    Loading.getLoadingMessage NotLoading
                        |> Expect.equal ""
            ]
        
        , describe "Loading Component Rendering"
            [ test "spinner loading renders with message" <|
                \_ ->
                    let
                        config =
                            { loadingType = Loading.Spinner
                            , message = "Loading..."
                            , isVisible = True
                            }
                    in
                    Loading.view config
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "loading-spinner" ]
            
            , test "hidden loading does not render" <|
                \_ ->
                    let
                        config =
                            { loadingType = Loading.Spinner
                            , message = "Loading..."
                            , isVisible = False
                            }
                    in
                    Loading.view config
                        |> Query.fromHtml
                        |> Query.hasNot [ Selector.class "loading-spinner" ]
            ]
        ]