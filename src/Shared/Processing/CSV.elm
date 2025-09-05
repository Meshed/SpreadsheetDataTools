module Shared.Processing.CSV exposing (generateCSV, escapeCSVField)

{-| CSV generation utilities for the Data Extractor tool.

Provides pure functions for generating RFC 4180 compliant CSV output.

@docs generateCSV, escapeCSVField

-}


{-| Generate CSV string from headers and data rows
-}
generateCSV : List String -> List (List String) -> String
generateCSV headers rows =
    let
        headerRow =
            headers
                |> List.map escapeCSVField
                |> String.join ","

        dataRows =
            rows
                |> List.map (List.map escapeCSVField)
                |> List.map (String.join ",")
                |> String.join "\n"
    in
    if List.isEmpty rows then
        headerRow

    else
        headerRow ++ "\n" ++ dataRows


{-| Escape a CSV field according to RFC 4180 standards
-}
escapeCSVField : String -> String
escapeCSVField field =
    let
        needsQuoting =
            String.contains "," field
                || String.contains "\"" field
                || String.contains "\n" field
                || String.contains "\r" field
                || String.startsWith " " field
                || String.endsWith " " field

        escapedField =
            String.replace "\"" "\"\"" field
    in
    if needsQuoting then
        "\"" ++ escapedField ++ "\""

    else
        field