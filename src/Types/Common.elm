module Types.Common exposing
    ( Route(..)
    , AppError(..)
    )

{-| Shared type definitions across the application.

@docs Route, AppError
-}


{-| Application routes for navigation
-}
type Route
    = Home
    | DataExtractor
    | DataMerger
    | NotFound


{-| Global application error types
-}
type AppError
    = UrlParsingError String
    | NavigationError String
    | UnknownRouteError String