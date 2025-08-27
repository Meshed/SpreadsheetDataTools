module Shared.Utils.BrowserDetection exposing (checkCompatibility, isDesktopScreen, getSupportedBrowsers, formatCompatibilityMessage)

{-| Browser compatibility detection utilities.

@docs checkCompatibility, isDesktopScreen, getSupportedBrowsers, formatCompatibilityMessage

-}

import Types.Errors exposing (AppError(..), BrowserInfo)


{-| Minimum screen width for desktop support (pixels)
-}
minDesktopWidth : Int
minDesktopWidth =
    1024


{-| Check if browser and environment are compatible
-}
checkCompatibility : BrowserInfo -> List AppError
checkCompatibility browserInfo =
    let
        errors =
            []

        screenError =
            if not (isDesktopScreen browserInfo.screenWidth) then
                [ BrowserCompatibilityError
                    ("This application requires a desktop computer with at least "
                        ++ String.fromInt minDesktopWidth
                        ++ "px screen width. Your current screen is "
                        ++ String.fromInt browserInfo.screenWidth
                        ++ "px wide."
                    )
                ]

            else
                []

        fileApiError =
            if not browserInfo.supportsFileAPI then
                [ BrowserCompatibilityError
                    "Your browser doesn't support file uploads. Please use a modern browser like Chrome, Firefox, Safari, or Edge."
                ]

            else
                []

        sheetJsError =
            if not browserInfo.supportsSheetJS then
                [ BrowserCompatibilityError
                    ("Your browser (" ++ browserInfo.browserName ++ " " ++ browserInfo.version ++ ") doesn't support Excel file processing. " ++ getSupportedBrowsers ())
                ]

            else
                []
    in
    errors ++ screenError ++ fileApiError ++ sheetJsError


{-| Check if screen width meets desktop requirements
-}
isDesktopScreen : Int -> Bool
isDesktopScreen width =
    width >= minDesktopWidth


{-| Get list of supported browsers
-}
getSupportedBrowsers : () -> String
getSupportedBrowsers _ =
    "Please use Chrome 80+, Firefox 75+, Safari 13+, or Edge 80+ for the best experience."


{-| Format compatibility message for display
-}
formatCompatibilityMessage : BrowserInfo -> String
formatCompatibilityMessage browserInfo =
    let
        deviceType =
            if browserInfo.isDesktop then
                "desktop"

            else
                "mobile"

        screenInfo =
            String.fromInt browserInfo.screenWidth ++ "x" ++ String.fromInt browserInfo.screenHeight

        browserInfo_ =
            browserInfo.browserName ++ " " ++ browserInfo.version
    in
    "Detected: " ++ browserInfo_ ++ " on " ++ deviceType ++ " (" ++ screenInfo ++ ")"
