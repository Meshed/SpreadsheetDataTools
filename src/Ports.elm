port module Ports exposing
    ( clearMemory
    , downloadCSV
    , fileDataReceived
    , readExcelFile
    )

import Json.Encode as Encode


port readExcelFile : Encode.Value -> Cmd msg


port fileDataReceived : (Encode.Value -> msg) -> Sub msg


port downloadCSV : { filename : String, content : String } -> Cmd msg


port clearMemory : () -> Cmd msg