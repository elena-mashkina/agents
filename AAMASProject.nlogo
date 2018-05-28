;;; Variable we will use


globals [num_moves gold_x gold_y gold_count gridSize currentTurtle bExit epoch time_steps epsilon visited_map color_map]


;;; Entitities
;;breed   [ pits pit]
breed [players player]
;;;

;;; Extentions
extensions [array]
;;;

;;;

players-own [ init_xcor init_ycor has_gold is_cool Q_values reward total_reward]
;pits-own [ init_xcor init_ycor ]

;;; Setting up.
to setup
  clear-all
  init-globals
  summon-players
  summon-pits
  summon-gold
  summon-exits
 ; set has_gold 0
 ; create-turtles 1 [ setxy 8 8 ]
  reset-ticks
end

;; Summonings

to init-globals
  set gridSize 8
  set currentTurtle 0
  set num_moves 5
  set epoch 0
  set epsilon 0.9
  set color_map init-color-map
  set visited_map init-visited-map
end

to summon-players
    create-players 1
  [
   set init_xcor 8
   set init_ycor 8
   set has_gold 0
   set reward 0
   set total_reward 0
    set Q_values init-Q-values
    setxy init_xcor init_ycor

  ]
      create-players 1
  [
   set init_xcor -8
   set init_ycor -8
   set has_gold 0
   set reward 0
   set total_reward 0
    set Q_values init-Q-values
    setxy init_xcor init_ycor
  ]
      create-players 1
  [
   set init_xcor 8
   set init_ycor -8
   set has_gold 0
   set reward 0
   set total_reward 0
    set Q_values init-Q-values
    setxy init_xcor init_ycor
  ]
      create-players 1
  [
   set init_xcor -8
   set init_ycor  8
   set has_gold 0
   set reward 0
   set total_reward 0
   set Q_values init-Q-values
    setxy init_xcor init_ycor
  ]
end

;; Movement function

to summon-pits
  let counter 0
  while [ counter != pit_count]
  [
  let some_ycor 0
  set some_ycor random-pycor
  let some_xcor 0
  set some_xcor random-pxcor
    while [abs some_ycor + abs some_xcor = 16]
    [
        set some_ycor random-pycor
        set some_xcor random-pxcor
    ]


  ask patch some_xcor some_ycor [ set pcolor brown]
    set counter counter + 1
  ]
  add-breeze
end

to add-breeze
  ask patches [ if pcolor = brown
 [
   ask neighbors4 [ if pcolor != brown
       [ set pcolor cyan]
  ] ]]
end

;; to go
;; ifelse epoch-finished? [
;  reset
;  if epoch >= max_epochs [stop]
;]
;[
; agent-loop
; set time_steps (time_steps + 1)
; ]
; end

to reset
  ask players [

   set xcor init_xcor
   set ycor init_ycor
   set has_gold 0
   set total_reward 0
  ]
   ;; new pits ?
   set epoch (epoch + 1)
   set time_steps 0
end

to go
  if can-exit = 0 [stop]
  ifelse any? turtles
  [
  agent-loop
  ]
  [ stop ]
  tick
end

to agent-loop
  set currentTurtle 0
  ;;count-reward
  ;; loops through all agents
  while [ currentTurtle != 4]
  [
    if is-turtle? turtle currentTurtle
    [
      ; go-random ; <<< naive agent
      let cur_xcor ([xcor] of turtle currentTurtle)
      let cur_ycor ([ycor] of turtle currentTurtle)

      ; determines where it should move
      let cur_move next-move cur_xcor cur_ycor
     ; let cur_reward (get-Q-value cur_xcor cur_ycor cur_move)
      ; gets the reward from the upcoming move
      ;ask turtle currentTurtle [set reward get-reward cur_move ]
      ;ask turtle currentTurtle [set total_reward ( reward + total_reward) ]

      ;; Updates the environment
      ;update-Q-value cur_move cur_xcor cur_ycor
      go-next cur_move


    ]
    set currentTurtle currentTurtle + 1
  ;;  print currentTurtle


  ]
end

to go-next [ move ]
  ifelse move = 0
  [ask turtle currentTurtle [go-down]]
  [ifelse move = 1
    [ask turtle currentTurtle [go-right]]
    [ifelse move = 2
      [ask turtle currentTurtle [go-up]]
      [ifelse move = 3
        [ask turtle currentTurtle [go-left]]
        [ask turtle currentTurtle [go-grab]]]]]
end

to go-random
    let move random 5
    go-next move
end

to go-down
  let new-ycor 0
  if( ycor - 1 != -9)
  [set new-ycor ycor - 1
  ask turtle currentTurtle [ setxy xcor new-ycor]
  ]
  pit-fall
end

to go-up
  let new-ycor 0
    if( ycor + 1 != 9)
  [set new-ycor ycor + 1
  ask turtle currentTurtle [ setxy xcor  new-ycor]
  ]
  pit-fall
end

to go-left
  let new-xcor 0
    if( xcor - 1 != -9)
  [set new-xcor xcor - 1
  ask turtle currentTurtle [ setxy new-xcor ycor ]
  ]
  pit-fall
end

to go-right
  let new-xcor 0
   if( xcor + 1 != 9)
  [set new-xcor xcor + 1
  ask turtle currentTurtle [ setxy new-xcor ycor]
  ]
  pit-fall
end

to go-grab
  ifelse xcor = gold_x
 [ if ycor = gold_y
    [
      ask patch gold_x gold_y [set pcolor black]
      ask turtle currentTurtle [ set has_gold 1 ]
    ]]
  [
  ; print gold_x
  ;  print xcor
   ;  print ycor
  ]
end



;; Environment function

to summon-gold
  let check  0
  let some_ycor 0
  set some_ycor random-pycor
  let some_xcor 0
  set some_xcor random-pxcor
      while [abs some_ycor + abs some_xcor = 16]
    [
        set some_ycor random-pycor
        set some_xcor random-pxcor
    ]
  if ( [pcolor] of patch some_xcor some_ycor = brown)
  [ set check 1]
  while [ check = 1]
  [

        set some_ycor random-pycor
        set some_xcor random-pxcor
    set check 0
    if ( [pcolor] of patch some_xcor some_ycor = brown)
    [ set check 1]
  ]


  set gold_x some_xcor
  set gold_y some_ycor
  ask patch some_xcor some_ycor [ set pcolor yellow]

end

to summon-exits

  ask patch 8 8 [ set pcolor red]

end

to-report init-Q-values
  report array:from-list n-values ( world-width  )  [
    array:from-list n-values ( world-height ) [
      array:from-list n-values num_moves [0] ]]
end


to-report init-visited-map
  report array:from-list n-values world-width [ array:from-list n-values world-height [0] ]
end


to-report init-color-map
  report array:from-list n-values world-width [array:from-list n-values world-height ["none"] ]
end

to-report get-Q-values [x y]
  report array:item (array:item ( [Q_values] of turtle currentTurtle ) (x + 8))( y + 8)
end

to-report get-Q-value [x y move]
  report array:item ( array:item (array:item ( [Q_values] of turtle currentTurtle ) (x + 8)) (y + 8) ) move
end

to-report get-value-2d [x y matrix]
  let x_idx (coord-to-idx x)
  let y_idx (coord-to-idx y)
  ifelse ((valid-idx x_idx) and (valid-idx y_idx))
  [
  report array:item (array:item matrix x_idx) y_idx
  ]
  [carefully [print ("a wall!")] [ print error-message ] report -100]
end

to set-value-2d [x y matrix value]
  let x_idx (coord-to-idx x)
  let y_idx (coord-to-idx y)
  ifelse ((valid-idx x_idx) and (valid-idx y_idx))
  [
   array:set (array:item matrix x_idx) y_idx value
  ]
  [carefully [ print ("a wall!") ] [ print error-message ]]
end

;; sets the value for the current agent
to set-agent-Q-value [x y move val ]
 ask turtle currentTurtle [ array:set (get-Q-values x  y  ) move val]
end


;;;; Environment functions.

to pit-fall
      if ( [pcolor] of patch xcor ycor = brown)
  [ask turtle currentTurtle [ die ]]
end

to-report can-exit
  ask turtles with [ has_gold = 1 ]
 [      if ( [pcolor] of patch xcor ycor = red)
    [ set bExit 1 ] ]

  if bExit = 1
    [ report 0]
  report 1

end

to-report max_q_val [ x y move]
   let loc_x x
   let loc_y y
      ifelse move = 0
   [ set loc_y (loc_y - 1 )
      if loc_y = -9
      [set loc_y -8]
  ]
  [ifelse move = 1
    [set loc_x (loc_x + 1)
      if loc_x = 9
      [set loc_x 8]
    ]
    [ifelse move = 2
      [ set loc_y (loc_y + 1 )
        if loc_y = 9
        [set loc_y 8]
      ]
        [ set loc_x (loc_x - 1)
        if loc_x = -9
        [set loc_x -8] ]]]

   report max array:to-list get-q-values loc_x loc_y
end

to-report get-next-move [ x y move]
  let loc_x x
   let loc_y y
      ifelse move = 0
   [ set loc_y (loc_y - 1 )
      if loc_y = -9
      [set loc_y -8]
  ]
  [ifelse move = 1
    [set loc_x (loc_x + 1)
      if loc_x = 9
      [set loc_x 8]
    ]
    [ifelse move = 2
      [ set loc_y (loc_y + 1 )
        if loc_y = 9
        [set loc_y 8]
      ]
        [ set loc_x (loc_x - 1)
        if loc_x = -9
        [set loc_x -8] ]]]

    report next-move loc_x loc_y

end

to-report get-next-q-value [ x y move new_move]
     let loc_x x
   let loc_y y
      ifelse move = 0
   [ set loc_y (loc_y - 1 )
      if loc_y = -9
      [set loc_y -8]
  ]
  [ifelse move = 1
    [set loc_x (loc_x + 1)
      if loc_x = 9
      [set loc_x 8]
    ]
    [ifelse move = 2
      [ set loc_y (loc_y + 1 )
        if loc_y = 9
        [set loc_y 8]
      ]
        [ set loc_x (loc_x - 1)
        if loc_x = -9
        [set loc_x -8] ]]]

    report get-q-value loc_x loc_y new_move
end

;;; Reinforcement Learning

to-report next-move [x y]
  ifelse move_algo = "Greedy"
     [report new-move-e-greedy x y]
     [ifelse move_algo = "Soft"
     [report new-move-soft x y]
     [report new-move-reactive x y]]
end


to-report new-move-soft [ x y]
end

to-report new-move-reactive [x y]
  update-maps x y
  report random num_moves
end

to update-maps [x y]
  let patch_color [pcolor] of patch x y
  let cur_value get-value-2d x y visited_map

  set-value-2d x y visited_map 1
  set-value-2d x y color_map patch_color

  update-neighbor x y patch_color cur_value

end

to-report coord-to-idx [coord]
  let offset ((world-width + 1) / 2)
  report (coord + offset)
end

to-report idx-to-coord [idx]
  let offset ((world-width + 1) / 2)
  report (idx - offset)
end

to-report valid-idx [idx]
  ifelse (idx > 0 and idx < world-width)
  [report true]
  [report false]
end

to update-neighbor [x y col cur_val]
  let x_idx  (coord-to-idx x)
  let y_idx  (coord-to-idx y)


  if (col = black or col = red)
  [
    set-value-2d x_idx y_idx visited_map 1
    ask patch x y [set pcolor magenta]

    if (valid-idx (y_idx + 1))
    [
      ;getting the value of the upper cell
      let up_val (get-value-2d x_idx (y_idx + 1) visited_map)
      if (up_val != 1)
      [set-value-2d x_idx (y_idx + 1) visited_map 1]

      ask patch (idx-to-coord x_idx) (idx-to-coord (y_idx + 1)) [set pcolor magenta]

    ]

    if (valid-idx (y_idx - 1))
    [
      ;getting the value of the lower cell
      let down_val (get-value-2d x_idx (y_idx - 1) visited_map)
      if (down_val != 1)
      [set-value-2d x_idx (y_idx - 1) visited_map 1]

      ask patch (idx-to-coord x_idx) (idx-to-coord (y_idx - 1)) [set pcolor magenta]
    ]

    if (valid-idx (x_idx + 1))
    [
      ;getting the value of the cell to the right
      let right_val (get-value-2d (x_idx + 1) y_idx visited_map)
      if (right_val != 1)
      [set-value-2d (x_idx + 1) y_idx visited_map 1]

      ask patch (idx-to-coord (x_idx + 1)) (idx-to-coord y_idx) [set pcolor magenta]
    ]

    if (valid-idx (x_idx - 1))
    [
      ;getting the value of the cell to the left
      let left_val (get-value-2d (x_idx - 1) y_idx visited_map)
      if (left_val != 1)
      [set-value-2d (x_idx - 1) y_idx visited_map 1]

      ask patch (idx-to-coord (x_idx - 1)) (idx-to-coord y_idx) [set pcolor magenta]
    ]
  ]

  if (col = cyan)
  [

  ]

  print-matrix visited_map


end

to print-matrix [matrix]
  let i 0

  while [i != world-width]
  [print (array:item matrix i)
    set i (i + 1)
  ]
  print ("========================")
end

to update-Q-value [ move x y]
  ifelse reward_algo = "Q learning"
  [ update-Q-learning move x y]
  [ update-SARSA move x y]

end

to-report new-move-e-greedy [ x y]
   let rand random-float 1
   ifelse rand < epsilon
   [
    report random num_moves
   ]

   [
    let move_values array:to-list (get-Q-values x y)
    report ( position (max move_values) move_values )
   ]

end

to-report get-reward [ move ]

  let cur_xcor ([xcor] of turtle currentTurtle)
  let cur_ycor ([ycor] of turtle currentTurtle)
  ;did it grab the gold
  ifelse move = 4
  [
  if ( [pcolor] of patch cur_xcor cur_ycor = yellow)
  [ report 100 ]
  ]
  [ report -10]

  ;; get new position
  ifelse move = 0
   [ set cur_ycor (cur_ycor - 1 )
      if cur_ycor = -9
      [report -15] ; hit the wall
  ]
  [ifelse move = 1
    [set cur_xcor (cur_xcor + 1)
      if cur_xcor = 9
      [report -15] ; hit the wall
    ]
    [ifelse move = 2
      [ set cur_ycor (cur_ycor + 1 )
        if cur_ycor = 9
        [report -15] ; hit the wall
      ]
        [ set cur_xcor (cur_xcor - 1)
        if cur_xcor = -9
        [report -15] ; hit the wall
         ]]]


  ;did it fall into a pit
   if ( [pcolor] of patch cur_xcor cur_ycor = brown)
  [ report -250 ]

  ;did it sense a breeze
     if ( [pcolor] of patch cur_xcor cur_ycor = blue)
  [ report -5]

  ; did it exit with a gold
  if ( [pcolor] of patch cur_xcor cur_ycor = red ) and ([has_Gold] of turtle currentTurtle = 1)
  [ report 1000]


  ;; case when hitting another agent

  report -1
end

to update-Q-learning [move x y]
  ;; reward before the move
   let q_val (get-Q-value x y move)
   let cur_reward ( [reward] of turtle currentTurtle)
   let cur_error  ( cur_reward + (discount_factor * ( max_q_val x y move )) - q_val )

   let new_q_val ( q_val + (learning_rate * cur_error))
   set-agent-Q-value x y move new_q_val


end

to update-SARSA [move x y]
  let q_val (get-Q-value x y move)
  let cur_reward ( [reward] of turtle currentTurtle)
  let new_move (get-next-move x y move )

  let cur_error ( cur_reward + (discount_factor * get-next-q-value x y move new_move) - q_val )

     let new_q_val ( q_val + (learning_rate * cur_error))
   set-agent-Q-value x y move new_q_val


end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
439
240
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-8
8
-8
8
1
1
1
ticks
30.0

BUTTON
14
20
78
53
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
278
273
341
306
Right
go-right
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
1

BUTTON
213
273
276
306
left
go-left
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
1

BUTTON
212
238
275
271
Up
go-up
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
1

BUTTON
277
238
340
271
Down
go-down\n
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
1

BUTTON
80
20
143
53
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
343
240
406
273
Grab
go-grab
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
1

SLIDER
14
65
186
98
pit_count
pit_count
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
14
100
186
133
max_epoch
max_epoch
0
100
0.0
1
1
NIL
HORIZONTAL

CHOOSER
14
206
152
251
move_algo
move_algo
"Greedy" "Soft" "Reactive"
2

CHOOSER
14
253
152
298
reward_algo
reward_algo
"Q learning" "SARSA"
0

SLIDER
14
170
186
203
learning_rate
learning_rate
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
14
135
186
168
discount_factor
discount_factor
0
1
0.0
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
