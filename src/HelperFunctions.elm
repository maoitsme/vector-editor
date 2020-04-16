module HelperFunctions exposing (..)

import CustomTypes exposing (..)

import Array

initShape : ShapeData
initShape = 
    { shapeType = Rect
    , position = (50, 50)
    , followMouse = False
    , id = 1
    , size = (50, 50)
    , updateSize = (False, False)
    , fillColor = "grey"
    , points = [[20,20], [100, 100]]
    , updatePoints = Nothing
    , zIndex = 1
    , strokeWidth = 5
    , strokeColor = "black"
    }

dragShape : Model -> List ShapeData
dragShape model =
    List.map (\shape -> 
        let
            mousex = Tuple.first model.mousePosition
            mousey = Tuple.second model.mousePosition
            shapex = Tuple.first shape.position
            shapey = Tuple.second shape.position
            shapew = Tuple.first shape.size
            shapeh = Tuple.second shape.size

            newSizeX = mousex - shapex
            newSizeY = mousey - shapey
            newSize =
                if newSizeX > 10 && newSizeY > 10 then
                    (newSizeX, newSizeY)
                else if newSizeX > 10 && newSizeY < 10 then
                    (newSizeX, 10)
                else if newSizeX < 10 && newSizeY > 10 then
                    (10, newSizeY)
                else (10, 10)

            newPosition =
                case shape.shapeType of
                    Rect -> 
                        ( mousex - shapew / 2
                        , mousey - shapeh / 2
                        )
                    Ellipse -> 
                        ( mousex, mousey )
                    Polyline -> 
                        ( mousex, mousey )

            dragPointPoints = 
                case shape.updatePoints of
                    Just pointsId ->
                        List.indexedMap (\index points ->
                            if index == pointsId then
                                [mousex, mousey]
                            else points
                        ) shape.points
                    Nothing -> shape.points
            followMousePoints =
                List.map (\point ->
                    let ap = Array.fromList point
                        px = Maybe.withDefault 0 <| Array.get 0 ap
                        py = Maybe.withDefault 0 <| Array.get 1 ap
                    in
                    [px, py]
                ) shape.points
        in
        { shape
        | position =
            if shape.followMouse then newPosition else shape.position
        , size = 
            ( if Tuple.first shape.updateSize then Tuple.first newSize else Tuple.first shape.size
            , if Tuple.second shape.updateSize then Tuple.second newSize else Tuple.second shape.size
            )
        , points = 
            if shape.followMouse then followMousePoints else dragPointPoints
        }) model.shapes

pointsToString points =
    List.map (\item -> 
        List.map (\ii -> String.fromFloat ii) item 
            |> String.join ",") points
            |> String.join " "

addNewPoint : Model -> Model
addNewPoint model =
    let mousex = Tuple.first model.mousePosition
        mousey = Tuple.second model.mousePosition
        selectedShapeData =
            Maybe.withDefault initShape 
                <| List.head 
                <| List.filter 
                    (\shape -> shape.id == model.selectedShape) 
                    model.shapes
        
        newShapes = 
            List.map (\shape -> 
                if shape.id == model.selectedShape && selectedShapeData.shapeType == Polyline then
                   { shape | points = shape.points ++ [[mousex, mousey]] }
                else shape
            ) model.shapes
    in
    { model | shapes = newShapes }

getSelectedShapeData model =
    Maybe.withDefault initShape 
        <| List.head 
        <| List.filter 
            (\shape -> shape.id == model.selectedShape) 
            model.shapes