module Main exposing (..)

import Api
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (text)
import Url



-- TODO: Move navigation logic to its own file
-- TODO: Move URL change/request to own functions
-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlChange = \url -> NavMsg (UrlChanged url)
        , onUrlRequest = \urlRequest -> NavMsg (LinkClicked urlRequest)
        }



-- MODEL


type alias NavModel =
    { key : Nav.Key
    , url : Url.Url
    }


type alias Model =
    { navModel : NavModel
    , apiModel : Api.Model
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { navModel = { url = url, key = key }, apiModel = Api.initialModel }
    , Cmd.none
    )



-- UPDATE


type NavMsg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


type Msg
    = NavMsg NavMsg
    | ApiMsg Api.Msg


navUpdate : NavMsg -> NavModel -> ( NavModel, Cmd NavMsg )
navUpdate msg model =
    case msg of
        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                External href ->
                    ( model, Nav.load href )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavMsg navMsg ->
            let
                ( navModel, navCmd ) =
                    navUpdate navMsg model.navModel
            in
            ( { model | navModel = navModel }, Cmd.map NavMsg navCmd )

        ApiMsg apiMsg ->
            let
                ( apiModel, apiCmd ) =
                    Api.update apiMsg model.apiModel
            in
            ( { model | apiModel = apiModel }, Cmd.map ApiMsg apiCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "homepage"
    , body =
        [ text "hello, world"
        , Html.map ApiMsg (Api.view model.apiModel)
        ]
    }
