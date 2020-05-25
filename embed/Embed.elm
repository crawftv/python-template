module Main exposing (main)

import Browser
import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Html
import Http
import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { storyList : WebData StoryList }


type alias Story =
    { author : String
    , title : String
    , subtitle : String
    , domain : String
    , url : String
    }


type alias StoryList =
    { storyList : List Story }


type Msg
    = HandleResponse (WebData StoryList)
    | GotJson


init : () -> ( Model, Cmd Msg )
init _ =
    ( { storyList = Loading }
    , RemoteData.Http.getWithConfig RemoteData.Http.defaultConfig "http://localhost:8080/random_three" HandleResponse threeDecoder
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotJson ->
            ( model, Cmd.none )

        HandleResponse data ->
            ( { model | storyList = data }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html.Html Msg
view model =
    case model.storyList of
        Failure error ->
            decodeError error

        Loading ->
            Html.text "Loading"

        Success fullText ->
            v fullText

        NotAsked ->
            Html.text "Not Asked"


decodeError : Http.Error -> Html.Html Msg
decodeError error =
    case error of
        Http.BadUrl string ->
            Html.text ("Error: " ++ string)

        Http.Timeout ->
            Html.text "timeout"

        Http.NetworkError ->
            Html.text "network error"

        Http.BadStatus int ->
            Html.text ("Error: " ++ String.fromInt int)

        Http.BadBody string ->
            Html.text ("Error: " ++ string)


threeDecoder : Decoder StoryList
threeDecoder =
    Decode.succeed StoryList
        |> required "results" (list storyDecoder)


storyDecoder : Decoder Story
storyDecoder =
    Decode.succeed Story
        |> required "author" string
        |> required "title" string
        |> required "subtitle" string
        |> required "domain" string
        |> required "url" string


v : StoryList -> Html.Html Msg
v storyList =
    Element.layout [] (map_v storyList)


map_v : StoryList -> Element msg
map_v storyList =
    Element.wrappedRow [] (List.map vr storyList.storyList)


vr : Story -> Element msg
vr story =
    Element.wrappedRow []
        [ Element.el
            [ Element.width (Element.px 180)
            , Element.height (Element.px 180)
            , Border.rounded 3
            , Border.glow (Element.rgb255 0 0 0) 0.5
            , Border.color (Element.rgb255 0 0 0)
            , Border.solid
            , Border.width 1
            ]
            (cardLink story)
        ]


cardLink : Story -> Element msg
cardLink story =
    Element.newTabLink []
        { url = story.url
        , label = card story
        }


card : Story -> Element msg
card story =
    Element.paragraph
        [ Border.color (Element.rgb255 150 150 150), Element.spacing 15, Element.paddingEach { top = 10, right = 5, left = 5, bottom = 5 } ]
        [ Element.el [ Font.size 18, Font.bold ] (Element.text story.title)
        , Element.el [ Font.italic, Font.size 14 ] (Element.paragraph [ Element.paddingEach { top = 5, right = 0, left = 0, bottom = 5 } ] [ Element.text story.subtitle ])
        , Element.el [ Font.size 12 ] (Element.text (String.concat [ "by: ", story.author ]))
        ]
