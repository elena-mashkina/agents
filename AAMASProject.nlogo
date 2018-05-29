;;; Variable we will use

;resize-world -5 5 -5 5 !!!!!!


globals [num_moves gold_x gold_y gold_count gridSize currentTurtle bExit epoch time_steps epsilon visited_map offset temperature]


;;; Entitities
;;breed   [ pits pit]
breed [players player]
;;;

;;; Extentions
extensions [array]
;;;

players-own [ init_xcor init_ycor has_gold is_cool Q_values reward total_reward]

;;; Setting up
to setup
  clear-all
  init-globals
  summon-players
  summon-pits
  summon-gold
  summon-exits
 ; set has_gold 0
 ; create-turtles 1 [ setxy 8 8 ]
  set epoch (epoch + 1)
  set time_steps 0
  set bExit 0
  reset-ticks
end

;; Basic setup

to init-globals
  set gridSize 8
  set offset ((world-width - 1) / 2)
  set currentTurtle 0
  set num_moves 5
  set epoch 0
  set epsilon 0.9
  set visited_map init-visited-map
  set temperature 100
end

to-report init-visited-map
  report array:from-list n-values world-width [ array:from-list n-values world-height [0] ]
end

to-report init-Q-values
  report array:from-list n-values ( world-width  )  [
    array:from-list n-values ( world-height ) [
      array:from-list n-values num_moves [0] ]]
end

to summon-players
    create-players 1
  [
   set init_xcor 8
   set init_ycor 8
   set has_gold 0
   set reward 0
   set total_reward 0
   set shape "moth_white"
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
   set shape "moth_blue"
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
   set shape "moth_green"
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
   set shape "moth_lila"
   set Q_values init-Q-values
   setxy init_xcor init_ycor
  ]
end

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
  ask patch offset offset [ set pcolor red]
end

to go
  ifelse ( can-exit = 0 ) or ( not any? turtles with [hidden? = false ])
  [

    ifelse (can-exit = 0)[print ("moths won!")][print("game over")]

    ;reset
    clear-turtles
    setup
    if epoch >= max_epochs
    [stop]
  ]

  [
    agent-loop
    set time_steps (time_steps + 1)
  ]
  tick
end

;to reset
;  ask players [
;   set xcor init_xcor
;   set ycor init_ycor
;   set has_gold 0
;   set total_reward 0
;   set hidden? false
;  ]
;   ;; new pits ?
;   set epoch (epoch + 1)
;   set time_steps 0
;   set bExit 0
;   ask patch gold_x gold_y [set pcolor yellow]
;   set visited_map init-visited-map
;end

;to go
;  if can-exit = 0 [stop]
;  ifelse any? turtles
;  [
;  agent-loop
;  ]
;  [ stop ]
;  tick
;end

to agent-loop
  set currentTurtle 0
  ;; loops through all agents
  while [ currentTurtle != 4]
  [
    if ( [hidden?] of turtle currentTurtle ) != true
    [
      ; go-random ; <<< naive agent
      let cur_xcor ([xcor] of turtle currentTurtle)
      let cur_ycor ([ycor] of turtle currentTurtle)

      ; determines where it should move
      let cur_move next-move cur_xcor cur_ycor
     ; let cur_reward (get-Q-value cur_xcor cur_ycor cur_move)
      ; gets the reward from the upcoming move
      ask turtle currentTurtle [set reward get-reward cur_move ]
      ask turtle currentTurtle [set total_reward ( reward + total_reward) ]

      ;; Updates the environment
      update-Q-value cur_move cur_xcor cur_ycor
      go-next cur_move
    ]
    set currentTurtle currentTurtle + 1
  ;;  print currentTurtle


  ]
end

;;;
; Movement functions
;;;

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
  ]
end

to pit-fall
      if ( [pcolor] of patch xcor ycor = brown)
  [ask turtle currentTurtle [ set hidden? true ]]
end

;; Manually Controlled

to turtle-go-up
  let pl_num to-num your_color
  let cur_xcor [xcor] of player pl_num
  let cur_ycor [ycor] of player pl_num

  if( cur_ycor != offset)
  [
    turtle-pit-fall cur_xcor (cur_ycor + 1) pl_num
    ask (player pl_num) [set ycor (cur_ycor + 1)]
  ]
end

to turtle-go-right
  let pl_num to-num your_color
  let cur_xcor [xcor] of player pl_num
  let cur_ycor [ycor] of player pl_num

  if( cur_xcor != offset)
  [
    turtle-pit-fall (cur_xcor + 1) cur_ycor pl_num
    ask (player pl_num) [set xcor (xcor + 1)]
  ]
end

to turtle-go-down
  let pl_num to-num your_color
  let cur_xcor [xcor] of player pl_num
  let cur_ycor [ycor] of player pl_num

  if( cur_ycor != (- offset))
  [
    turtle-pit-fall cur_xcor (cur_ycor - 1) pl_num
    ask (player pl_num) [set ycor (cur_ycor - 1)]
  ]
end

to turtle-go-left
  let pl_num to-num your_color
  let cur_xcor [xcor] of player pl_num
  let cur_ycor [ycor] of player pl_num

  if( cur_xcor != (- offset))
  [
    turtle-pit-fall (cur_xcor - 1) cur_ycor pl_num
    ask (player pl_num) [set xcor (cur_xcor - 1)]
  ]
end

to turtle-go-grab
  let pl_num to-num your_color
  if ([xcor] of turtle pl_num) = gold_x
  [
    if ([ycor] of turtle pl_num) = gold_y
    [
      ask patch gold_x gold_y [set pcolor black]
      ask turtle pl_num [ set has_gold 1 ]
    ]
  ]
end

to turtle-pit-fall [x y pl_num]
  if ( [pcolor] of patch x y = brown)
  [
  ask player pl_num [ set hidden? true ]
  ]
end


;; Environment functions

to-report get-time-steps
  report time_steps
end

;; Does this work before adding the reward ??
to-report can-exit
  ask turtles with [ has_gold = 1 ]
 [      if ( [pcolor] of patch xcor ycor = red)
    [ set bExit 1 ] ]

  if bExit = 1
    [ report 0]
  report 1

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

;;; Reinforcement Learning

to-report next-move [x y]
  ifelse move_algo = "Greedy"
     [report new-move-e-greedy x y]
     [ifelse move_algo = "Soft"
     [report new-move-soft x y]
     [report new-move-reactive x y]]
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

to-report new-move-soft [ x y]
   let moves array:to-list ( get-Q-values x y)
  let probs map [ [?1] -> (exp (?1 / temperature)) ] moves
  let sum_q sum probs
  set probs map [ [?1] -> ?1 / sum_q] probs

  let rand random-float 1
  let probs_sum item 0 probs
  let action_index 0
  while [ (probs_sum < rand ) and (action_index != 5 )]
  [
   set action_index ( action_index + 1)
   set probs_sum (probs_sum + (item action_index probs))
  ]
  report item action_index [ 0 1 2 3 4 ]
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

to update-Q-value [ move x y]
  ifelse reward_algo = "Q learning"
  [ update-Q-learning move x y]
  [ update-SARSA move x y]
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

;;; Reactive Learning

to-report new-move-reactive [x y]
  ifelse (update-neighbors x y = 1)
  [
  report 4 ;grab
  ]
  [
   let rand random-float 1
   ifelse rand < epsilon
   [report random num_moves]
   [report position (max (get-neighbor-values x y )) (get-neighbor-values x y )] ;go in the direction of safety (safety == 1)
  ]
end

to-report generate-probab [neighb_vals]
  let danger_cells 0
  let cnt 0
  let probab 0

  repeat 4
  [
    if ((item cnt neighb_vals) != 1)
    [set danger_cells (danger_cells + 1)]
    set cnt (cnt + 1)
  ]

  set probab (1 - (1 / danger_cells))
  report probab
end

to-report update-neighbors [x y]
  let neighb_val get-neighbor-values x y
  let col [pcolor] of patch x y

  let temp_col magenta

  if (col = black or col = red or col = grey)
  [
    set-value-2d x y visited_map 1
    set-cell-grey x y

    if ( y != (- offset))  ; if x y cell is not on an the lower world border
    [
      if ((item 0 neighb_val) != 1)
      [set-value-2d x (y - 1) visited_map 1]
      set-cell-grey x (y - 1)
    ]

    if ( x != offset) ; if x y cell is not on an the right world border
    [
      if ((item 1 neighb_val) != 1)
      [set-value-2d (x + 1) y visited_map 1]
      set-cell-grey (x + 1) y
    ]

    if ( y != offset) ; if x y cell is not on the upper world border
    [
      if ((item 2 neighb_val) != 1)
      [set-value-2d x (y + 1) visited_map 1]
      set-cell-grey x (y + 1)
    ]

    if ( x != (- offset)) ; if x y cell is not on an the left world border
    [
      if ((item 3 neighb_val) != 1)
      [set-value-2d (x - 1) y visited_map 1]
      set-cell-grey (x - 1) y
    ]
  ]

  if (col = cyan)
  [
    set-value-2d x y visited_map 1
    ask patch x y [set pcolor white]

    let prob generate-probab neighb_val

    if ( y != (- offset))  ; if x y cell is not on an the lower world border
    [
      if ((item 0 neighb_val) != 1)
      [set-value-2d x (y - 1) visited_map prob]
      set-cell-grey x (y - 1)
    ]

    if ( x != offset) ; if x y cell is not on an the right world border
    [
      if ((item 1 neighb_val) != 1)
      [set-value-2d (x + 1) y visited_map prob]
      set-cell-grey (x + 1) y
    ]

    if ( y != offset) ; if x y cell is not on the upper world border
    [
      if ((item 2 neighb_val) != 1)
      [set-value-2d x (y + 1) visited_map prob]

      set-cell-grey x (y + 1)
    ]

    if ( x != (- offset)) ; if x y cell is not on an the left world border
    [
      if ((item 3 neighb_val) != 1)
      [set-value-2d (x - 1) y visited_map prob]
    ]
  ]

  if (col = yellow)
  [
    report 1
  ]
  ;print-matrix visited_map

  report 0

end

;;;
; Helper functions (printing, getters, setters, coordinate converters, etc)
;;;

to-report get-value-2d [x y matrix]
  let x_idx (coord-to-idx x)
  let y_idx (coord-to-idx y)
  ifelse ((valid-idx x_idx) and (valid-idx y_idx))
  [
  report array:item (array:item matrix x_idx) y_idx
  ]
  [;carefully [print (word "error getting val of " x y)] [ print error-message ]
   report -100]
end

to set-value-2d [x y matrix value]
  let x_idx (coord-to-idx x)
  let y_idx (coord-to-idx y)
  ifelse ((valid-idx x_idx) and (valid-idx y_idx))
  [
   array:set (array:item matrix x_idx) y_idx value
  ]
  [carefully [ print (word "error setting a val of " x y) ] [ print error-message ]]
end

to print-matrix [matrix]
  let i 0

  while [i != world-width]
  [print (array:item matrix i)
    set i (i + 1)
  ]
  print ("========================")
end

to-report coord-to-idx [coord]
  report (coord + offset)
end

to-report idx-to-coord [idx]
  report (idx - offset)
end

to-report valid-idx [idx]
  ifelse (idx >= 0 and idx < world-width)
  [report true]
  [report false]
end

to-report get-neighbor-values [x y]
  let up_val (get-value-2d x (y + 1) visited_map)
  let down_val (get-value-2d x (y - 1) visited_map)
  let right_val (get-value-2d (x + 1) y visited_map)
  let left_val (get-value-2d (x - 1) y visited_map)

  let my_neighbors []
  set my_neighbors lput down_val my_neighbors
  set my_neighbors lput right_val my_neighbors
  set my_neighbors lput up_val my_neighbors
  set my_neighbors lput left_val my_neighbors

  report my_neighbors
end

to set-cell-grey [x y]
  let col [pcolor] of patch x y

  if (col = black)
  [
   ask patch x y [set pcolor grey]
  ]

  if (col = cyan)
  [
    ask patch x y [set pcolor white]
  ]
end

to-report get-Q-values [x y]
  report array:item (array:item ( [Q_values] of turtle currentTurtle ) (x + 8))( y + 8)
end

to-report get-Q-value [x y move]
  report array:item ( array:item (array:item ( [Q_values] of turtle currentTurtle ) (x + 8)) (y + 8) ) move
end

;; sets the value for the current agent
to set-agent-Q-value [x y move val ]
 ask turtle currentTurtle [ array:set (get-Q-values x  y  ) move val]
end

to-report to-num [chosen_value]
  ifelse (chosen_value = "white")
  [report 0]
  [ifelse (chosen_value = "blue")
    [report 1]
    [ifelse(chosen_value = "green")
      [report 2][report 3]]]
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
355
345
420
378
right
turtle-go-right\n
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
215
347
278
380
left
turtle-go-left
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
285
305
348
338
up
turtle-go-up\n
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
282
388
352
421
down
turtle-go-down
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
425
295
490
328
grab
turtle-go-grab
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
max_epochs
max_epochs
0
100
99.0
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
1

SLIDER
14
170
186
203
learning_rate
learning_rate
0
1
0.7
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
0.85
0.01
1
NIL
HORIZONTAL

MONITOR
476
36
547
81
time-steps
get-time-steps
17
1
11

CHOOSER
257
247
396
292
your_color
your_color
"white" "blue" "green" "pink"
0

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
false
2
Polygon -6459832 true false 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -6459832 true false 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -955883 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -955883 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60
Polygon -2674135 true false 60 135

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

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

moth
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

moth_blue
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -13345367 true false 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -13345367 true false 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -13791810 true false 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -13791810 true false 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

moth_green
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -13840069 true false 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -13840069 true false 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -14835848 true false 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -14835848 true false 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

moth_lila
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -5825686 true false 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -5825686 true false 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -2064490 true false 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -2064490 true false 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

moth_white
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -1 true false 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -1 true false 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -1 true false 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -1 true false 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

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

violet_moth
false
3
Polygon -8630108 true false 150 165 209 199 270 225 285 285 225 285 165 255 150 240
Polygon -8630108 true false 150 165 89 198 30 225 15 285 90 285 135 255 150 240
Polygon -8630108 true false 139 148 100 105 75 30 11 15 0 105 10 135 25 180 40 195 85 194 139 163
Polygon -8630108 true false 162 150 200 105 210 30 290 9 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 285 120 240 120 150 135 120 150 105 165 120 180 150 180 240
Circle -16777216 true false 105 60 90
Line -16777216 false 150 90 195 45
Line -16777216 false 135 75 90 30
Polygon -2674135 true false 60 135
Polygon -955883 true false 99 164 55 115

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

white_moth
false
3
Polygon -1 true false 150 165 209 199 270 225 285 285 225 285 165 255 150 240
Polygon -1 true false 150 165 89 198 30 225 15 285 90 285 135 255 150 240
Polygon -1 true false 139 148 100 105 75 30 11 15 0 105 10 135 25 180 40 195 85 194 139 163
Polygon -1 true false 162 150 200 105 210 30 290 9 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 285 120 240 120 150 135 120 150 105 165 120 180 150 180 240
Circle -16777216 true false 105 60 90
Line -16777216 false 150 90 195 45
Line -16777216 false 135 75 90 30
Polygon -2674135 true false 60 135
Polygon -955883 true false 99 164 55 115

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
