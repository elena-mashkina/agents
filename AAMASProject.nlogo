;;; Variable we will use

globals [num_actions gold_x gold_y gold_count gridSize currentTurtle bExit]


;;; Entitities
;;breed   [ pits pit]
breed [players player]
;;;

;;; Extentions
extensions [array]
;;;

;;;

players-own [ init_xcor init_ycor has_gold is_cool Q-values]

;pits-own [ init_xcor init_ycor ]


;;; Setting up.
to setup
  clear-all
  summon-players
  summon-pits
  summon-gold
  summon-exits
  set gridSize 8
  set currentTurtle 0

  set num_actions 5
 ; set has_gold 0
 ; create-turtles 1 [ setxy 8 8 ]
  reset-ticks
end


;; Summonings

to summon-players
    create-players 1
  [
   set init_xcor 8
   set init_ycor 8
   set has_gold 0
   set Q-values init-Q-values
    setxy init_xcor init_ycor
  ]
      create-players 1
  [
   set init_xcor -8
   set init_ycor -8
   set has_gold 0
   set Q-values init-Q-values

    setxy init_xcor init_ycor
  ]
      create-players 1
  [
   set init_xcor 8
   set init_ycor -8
   set has_gold 0

    set Q-values init-Q-values
    setxy init_xcor init_ycor
  ]
      create-players 1
  [
   set init_xcor -8
   set init_ycor  8
   set has_gold 0
   set Q-values init-Q-values
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
  let cnt 0
  set currentTurtle 0
  while [ currentTurtle != 4]
  [
    if is-turtle? turtle currentTurtle
    [
    go-random
    ]
    set currentTurtle currentTurtle + 1
    
  ]
end

to go-random
    let move random 5
  ifelse move = 0;-gridSize
  [ask turtle currentTurtle [go-down]]
  [ifelse move = 1
    [ask turtle currentTurtle [go-right]]
    [ifelse move = 2
      [ask turtle currentTurtle [go-up]]
      [ifelse move = 3
        [ask turtle currentTurtle [go-left]]
        [ask turtle currentTurtle [go-grab]]]]]
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
   print gold_x
    print xcor
     print ycor
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
  report array:from-list n-values world-width [
    array:from-list n-values world-height [
      array:from-list n-values num_actions [0] ]]
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


  if bExit = 1
    [ report 0]
  report 1

end

