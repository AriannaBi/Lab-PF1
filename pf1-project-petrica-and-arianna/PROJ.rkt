;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname PROJ) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
(require racket/list)

;Razvan Petrica Onciu
;Arianna Bianchi 
;;;;;;;;;;;;;;;;;;;;;;;;; THE LABIRINTH ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The ball will bounce whether there is a wall in the grid or not,
; The ball will bounce only if in the random generated list there
; is a 0 in the specific position.
; The list that contains the walls is structured as follows
; A list containing lists of 4 numbers, that represents respectively
; UP RIGHT DOWN LEFT, and the value 0 is for closed, and 1 for open'
; WHAT CHANGES: the position of the ball and its velocity
; WHAT DOES NOT CHANGE: the global constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Structures--------------


; A World-game is a (make-world)
; where
; - player is a Player
; - maze? is a number 0 or 1
; Interpretation: the current state of the world, given by the
; state of a player and the maze.
(define-struct world-game [player maze?])


; A Player is a (make-player x y dx dy)
; where: x, y, dx, dy are Number.
; Interpretation: the position (x,y) of a ball on the screen,
; and the velocity (dx,dy) of the ball, in pixels/tick.
(define-struct player [x y dx dy])

;;; -------------------------



;;; CONSTANT DEFINITIONS -----
(define LOGO (bitmap "logo.png"))
(define FRAME (bitmap "frame.jpg"))
(define WIDTH 1000)
(define HEIGHT 1000)
(define SCALE 10)
(define BACKGROUND-COLOR 'red);;;
(define COLUMNS (/ WIDTH SCALE))
(define ROWS  (/ HEIGHT SCALE))
(define CANVAS (rectangle WIDTH HEIGHT 'solid BACKGROUND-COLOR));;;
(define TOTAL-CELLS (* SCALE SCALE))
(define INSTRUCTIONS
  (text
   "Use the arrows key to move in the Maze:

     - Up key to go up 
     - Down key to go down
     - Right key to go right
     - Left key to go left
     - R key to restart from the origin point
     - ESC key to quit
 

You should reach the end point of this maze

The ball is bouncing on the white walls, so use this to your advantage.

You can pass throught the later walls (not the up and down ones)

Have fun
"
   15 'white))
(define END
  (place-image
   (square 25 'solid 'white)
   25
   25
   (rectangle 50 50 'solid 'red)))


;;; ---------------------------



;;; LIST SECTION---------------



; Number -> List<List<Number>>
; Given an index from 0 to 99, return a list of a list
; Each list have four argument that are random among 0 (close) and 1 (open).
; Interp: List<List<Number>> as the walls of each cell, i a non-negative integer (counter)
(define (list-of-walls i)
  (cond
    [(>= i 100) (drop-right (list (random 2) (random 2) (random 2) (random 2)) 4)]
    [(= i 10)
     (append (list (list 1 1 (random 2) 1)) (list-of-walls (add1 i)))]

    [else
     (append (list (list (random 2) (random 2) (random 2) (random 2))) (list-of-walls (add1 i)))]))


(define LIST-OF-WALLS
  (list-of-walls 0))




;;;;;;;;;;;;;;  MAKE PATH  ;;;;;;;;;;;;;;

; List Number Number -> List
; Given a list return the list with changed argument in the diagonal.
; The make-path take the LIST-OF-WALLS and for every cell to the right and down (in diagonal)
; set a 1 in the wall to the right if the i is a number btw [0 11 22 33.... 99] and recall the function with (a + 1)
; set a 1 in the wall to the down position if the i is a number btw [1 12 23 34 .... 89]
; and recall the function with (i + 11)
; Interp: a [0, 99], i [0 89] (both counters)
(define (path walls-list a i)
  (cond
    [(= a 88) (append (list (list-set (list-ref walls-list a) 2 1))
                      (path walls-list (add1 a) (+ i 11)))]
    [(= a 99) (list (list-set (list-ref walls-list a) 3 1))]
    [(= a i)
     (append (list (list-set (list-ref walls-list a) 1 1)) ; right
             (path walls-list (add1 a) (+ i 11)))]
    [else
     (append (list (list-set (list-ref walls-list a) 2 1)) ; down
             (path walls-list (+ a 10) i))])) 
 

   
(define LIST-PATH
  (path LIST-OF-WALLS 0 0))



; List Number Number List -> List
; Given a list return another completed list.
; It addresses the list created in the previus function (step-1) to the LIST-OF-WALLS in the respective position.
; On the alterning path  "up" "right" "down", "up" "right" "down" and so on, it append the element in the LIST-PATH
; (0 1 11, 11 12 22, 22 23 33 ...)
; for the other positions it appends the element in that position in the LIST-OF-WALLS
; The formula used for the recursive and for choosing the right cell position is
; Formula: (22 modulo 10 = 2) (44 modulo 10 = 4) ..., and so for cells in the alterning path, we have the modulo10 of i,
; and we multiply it by 2
; Interp a and i non negative integers (start from 0, both are counters)
; test
; for example at i = 44 we need the element in the LIST-PATH at position 8
(check-expect (* 2 (modulo 44 10)) 8) 
; for example at i = 23 we need the element in the LIST-PATH at position 5, so we sub 1 to the prev formula
(check-expect (sub1 (* 2 (modulo 23 10))) 5)
 
(define (final-list path a i l)
  (cond
    [(= a 99) (list (list-ref path (* 2 (modulo i 10))))]
    [(= a 0) (append (list (list-ref path 0)) (final-list path (add1 a) i l))]
    [(= a i)
     (append (list (list-ref path (* 2 (modulo i 10)))) (final-list path (add1 a) (+ i 11) l))]
    [(= a (- i 10))
     (append (list (list-ref path (sub1 (* 2 (modulo i 10))))) (final-list path (add1 a) i l))]
    [else
     (append (list (list-ref l a)) (final-list path (add1 a) i l))]))


(define FINAL-LIST
  (final-list LIST-PATH 0 11 LIST-OF-WALLS ))




; Number Lista -> Lista
; Given a list and a counter, return a list with the value of the rows changed.
; (0 x 0 0) -> (0 0 0 x)
; Set the value of the right wall in a cell to the value of the left wall in the next cell
; Interp: a non negative integer, must starts from 0 (counter)
(define (list-rows l a)
  (cond
    [(= a (- (length l) 1))
     (list (list-set (list-ref l a) 0 (list-ref (list-ref l a) 1)))]
    [else
     (append (list (list-set (list-ref l (+ a 1)) 3 (list-ref (list-ref l a) 1))) (list-rows l (add1 a)))]))
 
(define LIST-ROWS
  (append (list (list-ref FINAL-LIST 0)) (list-rows FINAL-LIST 0)))

(check-expect (list-rows (list (list 0 1 0 0)
                               (list 0 2 0 0)
                               (list 0 3 0 0)) 0)
              (list
               (list 0 2 0 1)
               (list 0 3 0 2)
               (list 3 3 0 0)))   



; Number Lista -> Lista
; Given a list and a counter, return a list with the value of the columns changed.
; (0 0 Y 0) -> (Y 0 0 0)
; Set the value of the down wall in a cell to the value of the up wall in the cell 10 positions down
; Interp: a non negative integer, must starts from 0 (counter)
(define (list-cols l a)
  (cond
    [(= a 89)  (list (list-set (list-ref l (+ a 10)) 0 (list-ref (list-ref l a) 2)))]
    [else
     (append (list (list-set (list-ref l (+ a 10)) 0 (list-ref (list-ref l a) 2))) (list-cols l (add1 a)))]))



(define LIST-COLS
  (append (drop-right LIST-ROWS 90) (list-cols LIST-ROWS 0)))
  

;;------------------------------END OF LIST SECTION-------------------------


 

; World -> World
; Given a world, return a new world with the velocity compenent inverted appropriately for the player
; if the player hits the walls.
; For each cells it checks if there are walls , and if there are it bounces 
(define (bounce w) 
  (make-world-game
   (make-player
    (player-x (world-game-player w))
    (player-y (world-game-player w))
    (invert-velocity-x (player-x (world-game-player w)) 
                       (cond
                         [(<= (player-x (world-game-player w)) 10)
                          0]
                         [else
                          (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                              (player-x (world-game-player w))
                                                                              (player-y (world-game-player w))
                                                                              0)) 3)
                                 0) 
                              (+ (range-left w 0 0) 20)
                              0)])
                       (cond
                         [(>= (player-x (world-game-player w)) 990)
                          1000]
                         [else
                          (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                              (player-x (world-game-player w))
                                                                              (player-y (world-game-player w))
                                                                              0)) 1)
                                 0)
                              (- (range-right w 0 0) 20)
                              990)])
                       (player-dx (world-game-player w)))
    (invert-velocity-y (player-y (world-game-player w))
                       (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                           (player-x (world-game-player w))
                                                                           (player-y (world-game-player w))
                                                                           0)) 0)
                              0)
                           (+ (range-up (player-y (world-game-player w)) 0) 20)
                           0)
                       (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                           (player-x (world-game-player w))
                                                                           (player-y (world-game-player w))
                                                                           0)) 2)
                              0)
                           (- (range-down (player-y (world-game-player w)) 0) 20)
                           990)
                       (player-dy (world-game-player w)))) 0 ))



; Player -> Player
; Given a player, return a new player at the closest position within the bounds of the scene.
; Ensures the player is in the box (WALLS).
(define (ensure-in-bounds w)
  (make-world-game
   (make-player (clamp (player-x (world-game-player w))
                       (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                           (player-x (world-game-player w))
                                                                           (player-y (world-game-player w))
                                                                           0)) 3)
                              0)
                           (+ (range-left w 0 0) 10)
                           10)
                       (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                           (player-x (world-game-player w))
                                                                           (player-y (world-game-player w))
                                                                           0)) 1)
                              0)
                           (- (range-right w 0 0) 10)
                           990))
                (clamp (player-y (world-game-player w))
                       (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                           (player-x (world-game-player w))
                                                                           (player-y (world-game-player w))
                                                                           0)) 0)
                              0)
                           (+ (range-up (player-y (world-game-player w)) 0) 10)
                           10)
                       (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                           (player-x (world-game-player w))
                                                                           (player-y (world-game-player w))
                                                                           0)) 2)
                              0)
                           (- (range-down (player-y (world-game-player w)) 0) 10)
                           990))
                (player-dx (world-game-player w))
                (player-dy (world-game-player w))) 0 )) 



; Number Number Number Number -> Number
; Given a velocity component (dv = dx), and a position
; component (value = x), and a range for that position,
; return the inverted velocity if the position is out
; of range, otherwise return the original velocity.
; Assumes lower <= upper.
(define (invert-velocity-x value-x lower upper dv) 
  (cond [(< value-x lower) (- dv)]
        [(> value-x upper) (- dv)]
        [else  dv]))

; TESTS
(check-expect (invert-velocity-x 150 100 200 20) 20)
(check-expect (invert-velocity-x 300 100 200 20) -20)
(check-expect (invert-velocity-x 50 100 200 20) -20)




; Number Number Number Number -> Number
; Given a velocity component (dv = dy), and a position
; component (value-y = y), and a range for that position,
; return the inverted velocity if the position is out
; of range, otherwise return the original velocity.
; Assumes lower <= upper.
(define (invert-velocity-y value-y lower upper dv)
  (cond [(< value-y lower)
         (- dv)]
        [(> value-y upper) (- dv)]
        [else dv]))

; TESTS
(check-expect (invert-velocity-y 350 300 400 10) 10)
(check-expect (invert-velocity-y 50 300 400 10) -10)
(check-expect (invert-velocity-y 450 300 400 10) -10)




; Number Number Number -> Number
; Given a value and lower and upper bounds, return a new value in the range
; of the bounds if the given value is out of bounds (as close as possible to the given value).
; Assumes lower <= upper.
(define (clamp value lower upper)
  (cond [(< value lower) lower]
        [(> value upper) upper]
        [else value])) 


; TESTS
(check-expect (clamp 250 200 300) 250)
(check-expect (clamp 301 200 300) 300)
(check-expect (clamp 190 200 300) 200)




; Player Number -> Player
; Given a playe, return a new player with updated position and velocity
; after one tick.
(define (move-player w)
  (if (void? w)
      sleep
      (ensure-in-bounds
       (bounce
        (make-world-game
         (make-player (+ (player-x (world-game-player w)) (player-dx (world-game-player w)))
                      (+ (+ (player-y (world-game-player w)) (player-dy (world-game-player w))) 2) 
                      (if (>= (player-dx (world-game-player w)) 10)
                          (- (player-dx (world-game-player w)) 5)
                          (player-dx (world-game-player w)))
                      (if (>= (player-dy (world-game-player w)) 10)
                          (player-dy (world-game-player w))
                          (+ (player-dy (world-game-player w)) 1))) 0 )))))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Number Number Number Number -> Number 
; Given index (a and i), position (x and y), return the number of cell 
(define (number-cell-x a x y index)
  (cond
    [(= a 1000)
     99]
    [else
     (if (and (>= x a) (<= x (+ a 100)))
         (if (and (>= y 0) (<= y 100))
             (+ (/ a 100) (sub1 index))
             (+ (/ a 100) (sub1 index)))
         (number-cell-x (+ a 100) x  y index))]))

; TESTS
(check-expect (number-cell-x 0 1100 0 0) 99)


; Number Number Number Number -> Number 
; Given index (a and i), position (x and y), recalls the function number-cell-x 
(define (number-cell-y a x y index)
  (cond
    [(> index 0)
     (number-cell-x 0 x y index)]
    [else
     (cond
       [(= a 1000)
        99]
       [else
        (if (and (>= y a) (<= y (+ a 100)))
            (number-cell-y a x y (add1 (* 10  (/ a 100))))
            (number-cell-y (+ a 100) x y index))])]))

; TESTS
(check-expect (number-cell-y 0 150 250 0) 21)
(check-expect (number-cell-y 0 1100 1100 0) 99)





; Number Number -> Boolean
; Given the indexes x and y return the color black or white for the drawing columns
; by checking if there is a 0 or a 1 in the main list-of-walls
(define (color-picker-columns x y) 
  (cond
    [(>= y 100)
     (if ( = (list-ref (list-ref LIST-COLS
                                 (if
                                  (= (- (+ (/ x 100) (/ y 10)) 1) 100)
                                  99
                                  (- (+ (/ x 100) (/ y 10)) 1))) 1) 1)
         'black
         'white)]
    [else
     (if ( = (list-ref (list-ref LIST-COLS (- (/ x 100) 1)) 1) 1)
         'black
         'white)]))


; Number Number -> Boolean
; Given the indexes x and y return the color black or white for the drawing rows
; by checking if there is a 0 or a 1 in the main list-of-walls

(define (color-picker-rows x y)
  (cond  
    [(>= y 100)
     (if ( = (list-ref (list-ref LIST-COLS
                                 (number-cell-y 0 x y 0)) 2) 1)
         'black
         'white)]
    [else
     (if ( = (list-ref (list-ref LIST-COLS (number-cell-y 0 x y 0)) 2) 1)
         'black
         'white)]))



; Number Number -> Image
; Given the indexes x and y, it recursively draws columns to the grid 100x100,
; The color is based on the results of the color-picker-cols.
; x must start from 100, y start from 0
; Interp: x and y as non negative integers
(define (create-cols x y)
  (add-line
   (if (< y 900)
       (create-cols x (+ y 100))
       (add-line 
        (if (< x WIDTH)
            (create-cols (+ x COLUMNS) 0)
            (add-line
             (empty-scene WIDTH HEIGHT 'black)
             x
             (- (/ HEIGHT 100) SCALE)
             x
             y
             (make-pen "transparent" 0 "solid" 'butt "round")))
        x
        (+ (/ HEIGHT 100) y)
        x
        y
        (make-pen (color-picker-columns x y) 5 "solid" 'butt "round")))
   x
   y
   x
   (+ (/ HEIGHT SCALE) y)
   (make-pen (color-picker-columns x y) 5 "solid" 'butt "round")))




; Number Number -> Image
; Given the indexes x and y, it recursively draws rows to the grid 100x100,
; The color is based on the results of the color-picker-rows.
; x must start from 0, y start from 0
; Interp: x and y as non negative integers
(define (create-rows x y)
  (add-line
   (if (< y 900)
       (create-rows x (+ y 100))
       (add-line 
        (if (< x HEIGHT)
            (create-rows (+ x ROWS) 0)
            (add-line
             (empty-scene WIDTH HEIGHT 'transparent)
             x
             (- (/ HEIGHT 100) SCALE)
             (/ WIDTH SCALE)
             y
             (make-pen "transparent" 0 "solid" 'butt "round")))
        x
        y
        (/ WIDTH SCALE)
        y
        (make-pen (color-picker-rows x y) 5 "solid" 'butt "round")))
   x
   y
   (/ WIDTH SCALE)
   y
   (make-pen (color-picker-rows x y) 5 "solid" 'butt "round")))



; MAZE is the main maze, it uses the two functions that creates rows and cols respectively and adds one on top of the other
(define MAZE
  (place-image
   (create-rows 0 0)
   (/ WIDTH 2)
   (/ HEIGHT 2)
   (create-cols 100 0)))



; Number Number -> List<Number>
; Given the indexes i and a, returns a list of numbers that represents the max number of cells per row
; Interp: i and a non negative integers that start from 0
(define (list-of-ranges i a)
  (cond
    [(= a 10)
     (drop-right (list (+ (* 10 i) a)) 1)]
    [else
     (cond
       [(= i 10) (list-of-ranges 0 (add1 a))] 
       [else
        (append (list (+ (* 10 i) a)) (list-of-ranges (add1 i) a))])]))


(define LIST-OF-RANGES (list-of-ranges 0 0))
;;  0-9, 10-19, 20-29, 30-39, 40-49,..... 90-99 (!! list of numbers, not list of list !!)





; World Number Number -> Number
; Given the struct-player, the indexes i and a, it returns the right max value for the x coordinate
; Interp: i and a as non negative integers
(define (range-right w i a)
  (cond
    [(= (list-ref LIST-OF-RANGES i) (number-cell-y 0
                                                   (player-x (world-game-player w))
                                                   (player-y (world-game-player w))
                                                   0))
     (cond
       [(and (>= i a)
             (<= i (+ a 9)))
        (+ (* a 10) 100)]
       [else
        (range-right w i (+ a 10))])]
    [else
     (range-right w (add1 i) a)]))

; TESTS
(check-expect (range-right (make-world-game
                            (make-player 240
                                         150
                                         0
                                         0)
                            0)
                           0
                           0) 300)
              

; Number Number -> Number
; Given the y coordinate of the player and the index a, it returns the down max value for the y coordinate
; Interp: a and y as non negative integer
(define (range-down y a)
  (cond
    [(and (>= y a)
          (<= y (+ a 100)))
     (+ a 95)]
    [else
     (range-down y (+ a 100))]))

; TESTS
(check-expect (range-down 450 0) 495)



; Player Number Number -> Number
; Given the struct-player, the indexes i and a, it returns the left max value for the x coordinate
; Interp: i and a as non negative integers
(define (range-left w i a)
  (cond
    [(= (list-ref LIST-OF-RANGES i) (number-cell-y 0
                                                   (player-x (world-game-player w))
                                                   (player-y (world-game-player w))
                                                   0))
     (cond
       [(and (>= i a)
             (<= i (+ a 9)))
        (* a 10)]
       [else
        (range-left w i (+ a 10))])]
    [else
     (range-left w (add1 i) a)]))


; TESTS
(check-expect (range-left (make-world-game
                           (make-player 240
                                        150
                                        0
                                        0) 0)
                          0
                          0) 200)



; Number Number -> Number
; Given the y coordinate of the player and the index a, it returns the up max value for the y coordinate
; Interp: a and y as non negative integer
(define (range-up y a)
  (cond
    [(and (>= y a)
          (<= y (+ a 100)))
     (+ a 5)]
    [else
     (range-up y (+ a 100))]))

; TESTS
(check-expect (range-up 450 0) 405)




; **Key handler**
; Player KeyEvent -> Player
; Given a player and an arrow key, returns the player 
; changed in the direction of the arrow;
; otherwise leave the player alone.
(define (handle-key w key)
  (cond
    [(string=? key "up")
     (cond
       [(= (number-cell-y 0
                          (player-x (world-game-player w))
                          (player-y (world-game-player w)) 0) 99)
        (exit)]
       [else
        (make-world-game
         (make-player
          (player-x (world-game-player w)) 
          (- (player-y (world-game-player w)) 5)
          (player-dx (world-game-player w))
          (- (player-dy (world-game-player w)) 5))
         0)])]
    
    [(string=? key "down")
     (cond
       [(= (number-cell-y 0
                          (player-x (world-game-player w))
                          (player-y (world-game-player w)) 0) 99)
        (exit)]
       [else
        (make-world-game
         (make-player
          (player-x (world-game-player w))
          (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                              (player-x (world-game-player w))
                                                              (player-y (world-game-player w))
                                                              0)) 2)
                 0)
              (if (>= (player-y (world-game-player w))
                      (- (range-down (player-y (world-game-player w)) 0) 10))
                  (- (range-down (player-y (world-game-player w)) 0) 10)
                  (+ (player-y (world-game-player w)) 5))
              (+ (player-y (world-game-player w)) 5))
          (player-dx (world-game-player w))
          0)
         0)])]
    
    [(string=? key "left")
     (cond
       [(= (number-cell-y 0
                          (player-x (world-game-player w))
                          (player-y (world-game-player w)) 0) 99) 
        (exit)]
       [else
        (make-world-game
         (make-player
          (cond 
            [(<= (player-x (world-game-player w)) 10)
             (if (or
                  (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                  (player-x (world-game-player w))
                                                                  (player-y (world-game-player w))
                                                                  0)) 3) 0)
                  (= (list-ref (list-ref LIST-COLS (+ (number-cell-y 0
                                                                     (player-x (world-game-player w))
                                                                     (player-y (world-game-player w))
                                                                     0) 9)) 1) 0))
                 (+ (player-x (world-game-player w)) 10)
                 990)]
            [else
             (- (player-x (world-game-player w)) 5)])
          (player-y (world-game-player w))
          (- (player-dx (world-game-player w)) 5)
          (player-dy (world-game-player w)))
         0)])]
    
    [(string=? key "right")
     (cond
       [(= (number-cell-y 0
                          (player-x (world-game-player w))
                          (player-y (world-game-player w)) 0) 99)
        (exit)]
       [else
        (make-world-game
         (make-player
          (cond
            [(>= (player-x (world-game-player w)) 990)
             (if (= (list-ref (list-ref LIST-COLS (number-cell-y 0
                                                                 (player-x (world-game-player w))
                                                                 (player-y (world-game-player w))
                                                                 0)) 1) 0)
                 (player-x (world-game-player w))
                 10)]
            [else
             (+ (player-x (world-game-player w)) 5)])
          (player-y (world-game-player w))
          (+ (player-dx (world-game-player w)) 5) 
          (player-dy (world-game-player w)))
         0)])]
    
    
    [(string=? key "r")
     INITIAL]

    [(string=? key "escape")
     (exit)]
    
    [else w]))

; TESTS

(check-expect (handle-key
               (make-world-game
                (make-player 120 150 10 0) 0)
               "right")
              (make-world-game
               (make-player 125 150 15 0)
               0))


(check-expect (handle-key
               (make-world-game
                (make-player 320 150 10 0) 0)
               "left")
              (make-world-game
               (make-player 315 150 5 0)
               0))

(check-expect (handle-key
               (make-world-game
                (make-player 720 150 10 0) 0)
               "up")
              (make-world-game
               (make-player 720 145 10 -5) 0))

(check-expect (handle-key
               (make-world-game
                (make-player 320 150 0 10) 0)
               "down")
              (make-world-game
               (make-player 320 155 0 0) 0))

(check-expect (handle-key
               (make-world-game
                (make-player 320 150 0 10) 0)
               "r")
              INITIAL)

(check-expect (handle-key
               (make-world-game
                (make-player 320 150 0 10) 0)
               "")
              (make-world-game
               (make-player 320 150 0 10) 0))

              


; Player -> Image
; Given a player, return the player on the image, the logo and the instructions. 
(define (add-player w)
  (place-image
   INSTRUCTIONS
   1250
   500
   (place-image
    (text "The rules of the maze game" 25 'white)
    1250
    300
    (place-image
     (text "λαβύρινθος" 55 'red)
     1200
     150
     (place-image
      LOGO
      1200
      80
      (place-image
       (circle 10 'solid 'red)
       (player-x (world-game-player w))
       (player-y (world-game-player w))
       (place-image
        END
        950
        950
        (place-image
         MAZE
         500
         500
         FRAME))))))))


;; BIG BANG--------

(define INITIAL (make-world-game
                 (make-player 50 50 0 0) 0))


(define (main initial)
  (big-bang initial
    [display-mode 'fullscreen]
    [to-draw add-player]
    [on-tick move-player]
    [on-key handle-key]))