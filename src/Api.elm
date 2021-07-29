module Api exposing (..)

import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData(..))
import StarWars.Query as Query



-- GRAPHQL API


query : SelectionSet String RootQuery
query =
    SelectionSet.map identity Query.hello


makeRequest : Cmd Msg
makeRequest =
    query
        |> Graphql.Http.queryRequest "https://elm-graphql.herokuapp.com"
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)



-- MODEL


type alias Response =
    String


type alias Model =
    RemoteData (Graphql.Http.Error Response) Response


initialModel : Model
initialModel =
    RemoteData.NotAsked



-- UPDATE


type Msg
    = GotResponse Model
    | Request


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Request ->
            ( model, makeRequest )

        GotResponse newModel ->
            ( newModel, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Request ] [ text "load" ]
        , case model of
            Success response ->
                text response

            Loading ->
                text "loading"

            _ ->
                text "not success"
        ]
