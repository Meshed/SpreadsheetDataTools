module Types.Common exposing (Route(..))

{-| Shared type definitions across the application.

@docs Route

-}


{-| Application routes for navigation
-}
type Route
    = Home
    | DataExtractor
    | DataMerger
    | NotFound
