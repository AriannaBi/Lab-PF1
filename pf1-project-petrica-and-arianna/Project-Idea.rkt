;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname Project-Idea) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; Option MAZE GAME
; MAZE
; We create a maze generator.
; The difficulty of the levels is random because it depends on the function that creates the maze.

; PLAYER
; The player is a bouncing ball.
; It should go from start point A to end point B trough the maze.
; - move thanks to the function big-bang.
; - move affected by the gravity.
; - bounce when there's a wall.

; BIG-BANG
; We define a function for big-bang that will have a full screen, an handle key, handle mouse
; on-tick.
; The application runs with big-bang so we need the package (require 2htdp/universe).
; - pressing "esc" quit the application's window.
; - pressing the arrow, the player will move.
; - pressing a button that wi will decide the player return in his inizial position.

; We will use the racket language:
; - construct the maze with structs, scene+line, make-pen, empty-scene and more.
; - handle-key for move the player.
; - create a timer that starts when the game begins.

; If we have enough time we will develop more levels.



; Option SURVIVAL MAZE
; The rules are the same of MAZE GAME but here the player don't have to arrive at a B point because
; it should avoid the enemy player that runs in the maze.
; So the player should survive in the maze for all timer long. 



; Feedback
; You were suppose to describe the application state: the World type of your program.
; What changes during the execution? What can be configured?
; You need to make a maze generator, otherwise the project will likely be too small. Come talk to a TA.
