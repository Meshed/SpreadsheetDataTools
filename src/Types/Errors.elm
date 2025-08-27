module Types.Errors exposing
    ( AppError(..), ValidationDetails, NetworkDetails, ErrorReport, BrowserInfo, LoadingState(..)
    , toUserFriendlyMessage, getErrorSeverity
    )

{-| Comprehensive error handling types for the application.

@docs AppError, ValidationDetails, NetworkDetails, ErrorReport, BrowserInfo, LoadingState
@docs toUserFriendlyMessage, getErrorSeverity

-}

import Shared.Components.ErrorDisplay exposing (ErrorSeverity(..))


{-| Comprehensive application error types
-}
type AppError
    = FileParseError String
    | ValidationError ValidationDetails
    | NetworkError NetworkDetails
    | BrowserCompatibilityError String
    | FileSizeError { fileName : String, actualSize : Int, maxSize : Int }
    | FileTypeError { fileName : String, fileType : String, supportedTypes : List String }
    | UnexpectedError String
    | UrlParsingError String
    | NavigationError String
    | UnknownRouteError String


{-| Validation error details
-}
type alias ValidationDetails =
    { field : String
    , reason : String
    , suggestions : List String
    }


{-| Network error details
-}
type alias NetworkDetails =
    { operation : String
    , status : Maybe Int
    , timeout : Bool
    }


{-| Error report for development debugging
-}
type alias ErrorReport =
    { error : String
    , context : String
    , userAgent : String
    , timestamp : Float
    , sessionId : String
    }


{-| Browser information for compatibility checking
-}
type alias BrowserInfo =
    { isDesktop : Bool
    , supportsFileAPI : Bool
    , supportsSheetJS : Bool
    , browserName : String
    , version : String
    , screenWidth : Int
    , screenHeight : Int
    }


{-| Loading states for different operations
-}
type LoadingState
    = NotLoading
    | LoadingRoute
    | ProcessingFile
    | GeneratingPreview
    | DownloadingFile
    | ValidatingData


{-| Convert technical errors to user-friendly messages
-}
toUserFriendlyMessage : AppError -> { title : String, message : String }
toUserFriendlyMessage error =
    case error of
        FileParseError _ ->
            { title = "File Processing Error"
            , message = "We couldn't read your file. Please make sure it's a valid Excel or CSV file and try again."
            }

        ValidationError details ->
            { title = "Invalid Data"
            , message = "There's an issue with the " ++ details.field ++ " field: " ++ details.reason
            }

        NetworkError details ->
            if details.timeout then
                { title = "Connection Timeout"
                , message = "The operation took too long. Please check your internet connection and try again."
                }

            else
                { title = "Connection Problem"
                , message = "We're having trouble connecting. Please check your internet and try again."
                }

        BrowserCompatibilityError message ->
            { title = "Browser Not Supported"
            , message = message
            }

        FileSizeError { fileName, actualSize, maxSize } ->
            { title = "File Too Large"
            , message = "The file '" ++ fileName ++ "' is " ++ String.fromInt (actualSize // 1024 // 1024) ++ "MB, but the maximum allowed size is " ++ String.fromInt (maxSize // 1024 // 1024) ++ "MB. Please try a smaller file or remove unused data."
            }

        FileTypeError { fileName, fileType, supportedTypes } ->
            { title = "File Type Not Supported"
            , message = "The file '" ++ fileName ++ "' is a " ++ fileType ++ " file. Please upload a " ++ String.join ", " supportedTypes ++ " file."
            }

        UnexpectedError _ ->
            { title = "Something Went Wrong"
            , message = "We encountered an unexpected problem. Your files are safe and haven't been stored. Please try again or start over."
            }

        UrlParsingError _ ->
            { title = "Invalid Web Address"
            , message = "The web address couldn't be understood. Please check the URL and try again."
            }

        NavigationError _ ->
            { title = "Navigation Problem"
            , message = "We couldn't navigate to that page. Please try using the menu or go back to the home page."
            }

        UnknownRouteError _ ->
            { title = "Page Not Found"
            , message = "The page you're looking for doesn't exist. Please use the menu to navigate or return to the home page."
            }


{-| Get error severity for styling
-}
getErrorSeverity : AppError -> ErrorSeverity
getErrorSeverity error =
    case error of
        FileParseError _ ->
            Error

        ValidationError _ ->
            Warning

        NetworkError _ ->
            Warning

        BrowserCompatibilityError _ ->
            Critical

        FileSizeError _ ->
            Warning

        FileTypeError _ ->
            Warning

        UnexpectedError _ ->
            Critical

        UrlParsingError _ ->
            Error

        NavigationError _ ->
            Error

        UnknownRouteError _ ->
            Error
