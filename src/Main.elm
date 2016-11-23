port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onCheck)
import Html.App as App
import Geolocation exposing (..)
import Http
import Json.Decode as Json
import Json.Decode exposing ((:=))
import Task
import Secrets
import Icons


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
  , fahrenheit: Bool
  }


init : (Model, Cmd Msg)
init =
  ( Model Nothing Nothing False
  , getLocation
  )



-- UPDATE


type Msg
  = RequestLocation
  | LocationSucceed Geolocation.Location
  | LocationFail Error
  | WeatherSucceed LocalWeather
  | WeatherFail Http.Error
  | FahrenheitView Bool


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    RequestLocation ->
      (model, getLocation)

    LocationSucceed newLocation ->
      ({ model | location = Just newLocation }, getWeather newLocation )

    LocationFail _->
      ({ model | location = Nothing }, Cmd.none)

    WeatherSucceed newWeather->
      ({ model | localWeather = Just newWeather }, Cmd.none)

    WeatherFail _->
      ({ model | localWeather = Nothing }, Cmd.none)

    FahrenheitView status ->
      ({ model | fahrenheit = status }, Cmd.none)

getLocation: Cmd Msg
getLocation =
  Task.perform LocationFail LocationSucceed (Geolocation.now)


getWeather: Geolocation.Location -> Cmd Msg
getWeather location =
  let url =
    "http://api.openweathermap.org/data/2.5/weather?" ++
      "lat=" ++ toString location.latitude ++
      "&lon=" ++ toString location.longitude ++
      "&APPID=" ++ Secrets.openWeatherApiKey
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
    ("temp" := Json.float)
    ("humidity" := Json.float)
    ("pressure" := Json.float)
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


renderWeather: Maybe Weather -> Html Msg
renderWeather weatherItem =
  case weatherItem of
    Just weather ->
      div [] [ text weather.main ]
    Nothing ->
      div [] [ text "No description available." ]


toFahrenheitInt: Float -> Int
toFahrenheitInt kelvin =
  round ( 1.8 * (kelvin - 273.15) + 32 )

toCentigradeInt: Float -> Int
toCentigradeInt kelvin =
  round ( kelvin - 273.15 )

renderTemp: Float -> Bool -> String
renderTemp temp fahrenheit =
  case fahrenheit of
    True ->
      toString (toFahrenheitInt temp) ++ "°F"
    False ->
      toString (toCentigradeInt temp) ++ "°C"

renderIcon: Maybe Weather -> Html Msg
renderIcon weatherItem =
  case weatherItem of
    Nothing ->
      Icons.sunny
    Just weatherItem ->
      if weatherItem.id < 300 then
        Icons.thunderstorm
      else if weatherItem.id < 600 then
        Icons.rainy
      else if weatherItem.id < 700 then
        Icons.flurries
      else if weatherItem.id == 800 then
        Icons.sunny
      else if weatherItem.id < 900 then
        Icons.cloudy
      else
        Icons.sunny

renderToggleButton =
{-<div class="switch">
    <input type="radio" class="switch-input" name="view" value="week" id="week" checked>
    <label for="week" class="switch-label switch-label-off">F</label>
    <input type="radio" class="switch-input" name="view" value="month" id="month">
    <label for="month" class="switch-label switch-label-on">C</label>
    <span class="switch-selection"></span>
  </div>
-}
  div [ class "switch" ]
    [ input
      [ onClick (FahrenheitView False)
      , type' "radio"
      , class "switch-input"
      , name "view"
      , value "Centigrade"
      , id "centigrade"
      , checked True
      ] []
    , label
      [ for "centigrade"
      , class "switch-label switch-label-off"
      ] [ text "°C"]
    , input
      [ onClick (FahrenheitView True)
      , type' "radio"
      , class "switch-input"
      , name "view"
      , value "Fahrenheit"
      , id "fahrenheit"
      ] []
    , label
      [ for "fahrenheit"
      , class "switch-label switch-label-on"
      ] [ text "°F"]
    , span
      [ class "switch-selection" ] []
    ]

renderLocalWeather: LocalWeather -> Bool -> Html Msg
renderLocalWeather localWeather fahrenheit=
  div []
    [ h1 [] [ text "My Weather App" ]
    , p [] [ text localWeather.name ]
    , p []
      [ span [] [ text ( renderTemp localWeather.main.temp fahrenheit ) ]
      , renderToggleButton
      ]
    , p [] [ renderWeather ( List.head localWeather.weather ) ]
    , div [] [ renderIcon ( List.head localWeather.weather ) ]
    ]


renderLoading: String -> Html Msg
renderLoading message =
  div [] [text message]


view : Model -> Html Msg
view model =
  case model.localWeather of
    Just weather ->
      renderLocalWeather weather model.fahrenheit

    Nothing ->
      renderLoading "Loading local weather...."
