port module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Geolocation exposing (..)
import Http
import Json.Decode as Json
import Json.Decode exposing ((:=))
import Task

main: Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Weather =
  { id: Int
  , main: String
  , description: String
  , icon: String
  }

type alias Main =
  { temp: Float
  , pressure: Float
  , humidity: Float
  , temp_min: Float
  , temp_max: Float
  }

type alias Wind =
  { speed: Float
  , deg: Float
  }

type alias Sys =
  { country: String
  , sunrise: Int
  , sunset: Int
  }

type alias LocalWeather =
    { weather: List Weather
    , main: Main
    , wind: Wind
    , dt: Int
    , sys: Sys
    , id: Int
    , name: String
    }

type alias Model =
  { location : Maybe Geolocation.Location
  , localWeather: Maybe LocalWeather
  }

init : (Model, Cmd Msg)
init =
  ( Model Nothing Nothing
  , getLocation
  )


-- UPDATE

type Msg
  = RequestLocation
  | LocationSucceed Geolocation.Location
  | LocationFail Error
  | FetchWeather
  | WeatherSucceed LocalWeather
  | WeatherFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    RequestLocation ->
      (model, getLocation)

    LocationSucceed newLocation ->
      ({ model | location = Just newLocation }, getWeather)

    LocationFail _->
      (model, Cmd.none)

    FetchWeather ->
      (model, Cmd.none)

    WeatherSucceed newWeather->
      ({ model | localWeather = Just newWeather }, Cmd.none)

    WeatherFail _->
      (model, Cmd.none)

getLocation: Cmd Msg
getLocation =
  Task.perform LocationFail LocationSucceed (Geolocation.now)

getWeather: Cmd Msg
getWeather =
  let url=
    "http://"
  in
    Task.perform WeatherFail WeatherSucceed (Http.get decodeLocalWeather url)


decodeWeather: Json.Decoder Weather
decodeWeather =
  Json.object4 Weather
    ("id" := Json.int)
    ("main" := Json.string)
    ("description" := Json.string)
    ("icon" := Json.string)

decodeMain: Json.Decoder Main
decodeMain =
  Json.object5 Main
    ("humidity" := Json.float)
    ("pressure" := Json.float)
    ("temp" := Json.float)
    ("temp_max" := Json.float)
    ("temp_min" := Json.float)

decodeWind: Json.Decoder Wind
decodeWind =
  Json.object2 Wind
    ("deg" := Json.float)
    ("speed" := Json.float)

decodeSys: Json.Decoder Sys
decodeSys =
  Json.object3 Sys
    ("country" := Json.string)
    ("sunrise" := Json.int)
    ("sunset" := Json.int)

decodeLocalWeather: Json.Decoder LocalWeather
decodeLocalWeather =
  Json.object7 LocalWeather
    ("weather" := Json.list decodeWeather)
    ("main" := decodeMain)
    ("wind" := decodeWind)
    ("dt" := Json.int)
    ("sys" := decodeSys)
    ("id" := Json.int)
    ("name" := Json.string)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [text (toString model)]
