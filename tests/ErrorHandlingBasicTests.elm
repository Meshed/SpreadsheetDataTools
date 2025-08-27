module ErrorHandlingBasicTests exposing (..)

import Expect
import Test exposing (..)
import Types.Errors exposing (AppError(..), toUserFriendlyMessage, getErrorSeverity)
import Shared.Components.ErrorDisplay exposing (ErrorSeverity(..))


suite : Test
suite =
    describe "Basic Error Handling Tests"
        [ describe "Error Message Generation"
            [ test "file parse error has correct title" <|
                \_ ->
                    let
                        error = FileParseError "Invalid Excel format"
                        friendlyMessage = toUserFriendlyMessage error
                    in
                    friendlyMessage.title
                        |> Expect.equal "File Processing Error"
            
            , test "file parse error mentions valid file types" <|
                \_ ->
                    let
                        error = FileParseError "Invalid Excel format"
                        friendlyMessage = toUserFriendlyMessage error
                    in
                    String.contains "Excel" friendlyMessage.message
                        |> Expect.equal True
            
            , test "file size error includes file name" <|
                \_ ->
                    let
                        error = FileSizeError 
                            { fileName = "large_data.xlsx"
                            , actualSize = 75 * 1024 * 1024
                            , maxSize = 50 * 1024 * 1024
                            }
                        friendlyMessage = toUserFriendlyMessage error
                    in
                    String.contains "large_data.xlsx" friendlyMessage.message
                        |> Expect.equal True
                        
            , test "browser compatibility error has correct title" <|
                \_ ->
                    let
                        error = BrowserCompatibilityError "IE not supported"
                        friendlyMessage = toUserFriendlyMessage error
                    in
                    friendlyMessage.title
                        |> Expect.equal "Browser Not Supported"
            ]
        
        , describe "Error Severity"
            [ test "file parse error is Error severity" <|
                \_ ->
                    FileParseError "corrupt"
                        |> getErrorSeverity
                        |> Expect.equal Error
            
            , test "browser compatibility error is Critical severity" <|
                \_ ->
                    BrowserCompatibilityError "unsupported"
                        |> getErrorSeverity  
                        |> Expect.equal Critical
                        
            , test "unexpected error is Critical severity" <|
                \_ ->
                    UnexpectedError "system failure"
                        |> getErrorSeverity
                        |> Expect.equal Critical
            ]
        ]