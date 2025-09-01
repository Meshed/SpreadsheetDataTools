module Tools.DataExtractor.View exposing (view, init, update, subscriptions)

{-| Data Extractor tool view and state management.

@docs view, init, update, subscriptions

-}

import Html exposing (Html, div, h1, h2, p, text)
import Html.Attributes exposing (attribute, class)
import Ports
import Tools.DataExtractor.Model as ExtractorModel exposing (Model, Msg(..), Step(..))
import Tools.DataExtractor.Steps.Configure as Configure
import Tools.DataExtractor.Steps.Preview as Preview
import Tools.DataExtractor.Steps.SelectFields as SelectFields
import Tools.DataExtractor.Steps.Upload as Upload
import Tools.DataExtractor.Update as ExtractorUpdate


{-| Initialize Data Extractor model
-}
init : ( Model, Cmd Msg )
init =
    ( ExtractorModel.init, Cmd.none )


{-| Update Data Extractor state
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update =
    ExtractorUpdate.update


{-| Data Extractor subscriptions
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.fileDataReceived FileParseResult


{-| Data Extractor main view with wizard
-}
view : Model -> Html Msg
view model =
    div [ class "data-extractor", attribute "data-testid" "data-extractor-page" ]
        [ viewWizardHeader model
        , viewCurrentStep model
        ]


{-| Wizard header with progress indicator
-}
viewWizardHeader : Model -> Html Msg
viewWizardHeader model =
    div [ class "data-extractor__wizard-header" ]
        [ h1 [ class "data-extractor__title" ]
            [ text "Data Extractor Tool" ]
        , p [ class "data-extractor__description" ]
            [ text "Extract matching records from one spreadsheet based on criteria from another." ]
        , viewProgressIndicator model.currentStep
        ]


{-| Progress indicator showing current step
-}
viewProgressIndicator : Step -> Html Msg
viewProgressIndicator currentStep =
    let
        currentIndex =
            ExtractorModel.getStepIndex currentStep

        steps =
            [ ( Upload, "Upload" )
            , ( Configure, "Configure" )
            , ( Preview, "Preview" )
            , ( SelectFields, "Select Fields" )
            , ( Download, "Download" )
            ]
    in
    div [ class "wizard-progress" ]
        [ div [ class "wizard-progress__bar" ]
            (List.map (viewProgressStep currentIndex) steps)
        , p [ class "wizard-progress__text" ]
            [ text ("Step " ++ String.fromInt currentIndex ++ " of 5: " ++ ExtractorModel.stepToString currentStep) ]
        ]


{-| Individual progress step indicator
-}
viewProgressStep : Int -> ( Step, String ) -> Html Msg
viewProgressStep currentIndex ( step, label ) =
    let
        stepIndex =
            ExtractorModel.getStepIndex step

        stepClass =
            if stepIndex < currentIndex then
                "wizard-progress__step wizard-progress__step--completed"

            else if stepIndex == currentIndex then
                "wizard-progress__step wizard-progress__step--active"

            else
                "wizard-progress__step wizard-progress__step--pending"
    in
    div
        [ class stepClass
        , attribute "data-testid" ("progress-step-" ++ String.fromInt stepIndex)
        ]
        [ div [ class "wizard-progress__step-number" ]
            [ text (String.fromInt stepIndex) ]
        , div [ class "wizard-progress__step-label" ]
            [ text label ]
        ]


{-| Render current step content
-}
viewCurrentStep : Model -> Html Msg
viewCurrentStep model =
    case model.currentStep of
        Upload ->
            Upload.view model

        Configure ->
            Configure.view model

        Preview ->
            Html.map PreviewMsg (Preview.view model)

        SelectFields ->
            Html.map SelectFieldsMsg (SelectFields.view model)

        Download ->
            viewPlaceholderStep "Download Results" "Download your processed data as a CSV file."


{-| Placeholder view for future steps
-}
viewPlaceholderStep : String -> String -> Html Msg
viewPlaceholderStep title description =
    div [ class "data-extractor__step-placeholder" ]
        [ h2 [ class "data-extractor__step-title" ]
            [ text title ]
        , p [ class "data-extractor__step-description" ]
            [ text description ]
        , p [ class "data-extractor__placeholder-notice" ]
            [ text "This step will be implemented in a future story." ]
        ]
