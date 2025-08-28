module BrowserDetectionBasicTests exposing (..)

import Expect
import Shared.Utils.BrowserDetection as BrowserDetection
import Test exposing (..)
import Types.Errors exposing (AppError(..), BrowserInfo)


suite : Test
suite =
    describe "Basic Browser Detection Tests"
        [ describe "Desktop Screen Detection"
            [ test "detects desktop screen correctly" <|
                \_ ->
                    BrowserDetection.isDesktopScreen 1024
                        |> Expect.equal True
            , test "rejects mobile screen correctly" <|
                \_ ->
                    BrowserDetection.isDesktopScreen 768
                        |> Expect.equal False
            ]
        , describe "Browser Compatibility"
            [ test "passes compatibility for good browser" <|
                \_ ->
                    let
                        goodBrowser =
                            { isDesktop = True
                            , supportsFileAPI = True
                            , supportsSheetJS = True
                            , browserName = "Chrome"
                            , version = "120"
                            , screenWidth = 1920
                            , screenHeight = 1080
                            }
                    in
                    BrowserDetection.checkCompatibility goodBrowser
                        |> List.length
                        |> Expect.equal 0
            , test "fails compatibility for mobile" <|
                \_ ->
                    let
                        mobileBrowser =
                            { isDesktop = False
                            , supportsFileAPI = True
                            , supportsSheetJS = True
                            , browserName = "Chrome"
                            , version = "120"
                            , screenWidth = 375
                            , screenHeight = 667
                            }
                    in
                    BrowserDetection.checkCompatibility mobileBrowser
                        |> List.length
                        |> Expect.greaterThan 0
            ]
        , describe "Supported Browsers"
            [ test "includes major browsers" <|
                \_ ->
                    let
                        supportedText =
                            BrowserDetection.getSupportedBrowsers ()
                    in
                    String.contains "Chrome" supportedText
                        |> Expect.equal True
            ]
        ]
