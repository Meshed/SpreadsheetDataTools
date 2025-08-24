module Example exposing (..)

import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Example tests for project setup verification"
        [ test "handles basic arithmetic correctly" <|
            \_ ->
                Expect.equal 4 (2 + 2)
        , test "string concatenation works as expected" <|
            \_ ->
                Expect.equal "Hello World" ("Hello" ++ " " ++ "World")
        , test "list operations function properly" <|
            \_ ->
                let
                    numbers = [1, 2, 3]
                    doubled = List.map (\x -> x * 2) numbers
                in
                Expect.equal [2, 4, 6] doubled
        ]