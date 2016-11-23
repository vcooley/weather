module Icons exposing (..)

import Html exposing (..)
import Html.Attributes as Attr

sunShower : Html a
sunShower =
    Html.node "div" [ Attr.attribute "class" "icon sun-shower" ]
        [ Html.node "div" [ Attr.attribute "class" "cloud" ] []
        , Html.node "div" [ Attr.attribute "class" "sun" ]
            [ Html.node "div" [ Attr.attribute "class" "rays" ] []
            ]
        , Html.node "div" [ Attr.attribute "class" "rain" ] []
        ]

thunderstorm : Html a
thunderstorm =
    Html.node "div" [ Attr.attribute "class" "icon thunder-storm" ]
        [ Html.node "div" [ Attr.attribute "class" "cloud" ] []
        , Html.node "div" [ Attr.attribute "class" "lightning" ]
            [ Html.node "div" [ Attr.attribute "class" "bolt" ] []
            , Html.node "div" [ Attr.attribute "class" "bolt" ] []
            ]
        ]

cloudy =
    Html.node "div" [ Attr.attribute "class" "icon cloudy" ]
        [ Html.node "div" [ Attr.attribute "class" "cloud" ] []
        , Html.node "div" [ Attr.attribute "class" "cloud" ] []
        ]

flurries =
    Html.node "div" [ Attr.attribute "class" "icon flurries" ]
        [ Html.node "div" [ Attr.attribute "class" "cloud" ] []
        , Html.node "div" [ Attr.attribute "class" "snow" ]
            [ Html.node "div" [ Attr.attribute "class" "flake" ] []
            , Html.node "div" [ Attr.attribute "class" "flake" ] []
            ]
        ]

sunny =
    Html.node "div" [ Attr.attribute "class" "icon sunny" ]
        [ Html.node "div" [ Attr.attribute "class" "sun" ]
            [ Html.node "div" [ Attr.attribute "class" "rays" ] []
            ]
        ]

rainy =
    Html.node "div" [ Attr.attribute "class" "icon rainy" ]
        [ Html.node "div" [ Attr.attribute "class" "cloud" ] []
        , Html.node "div" [ Attr.attribute "class" "rain" ] []
        ]
