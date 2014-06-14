;escape-lines

(define (escape-lines aimg adraw x0 y0 phi1 phi2 dphi1 number length roffset randomness xoffset yoffset aoffset color)
  (let* ((img (car (gimp-drawable-get-image adraw)))
         (owidth (car (gimp-image-width img)))
         (oheight (car (gimp-image-height img)))
         (coord (cons-array 4 'double))
         (iter 0)
         (x1 x0)
         (y1 y0)
         (x2 0)
         (y2 0)
         (x3 0)
         (y3 0)
         (dphi2 (/ (- (- phi2 dphi1) phi1) (- number 1)) )
         (roffiter roffset)
         )
    
    ;init
    (define (triangle_array x0 y0 x1 y1 x2 y2)
      (let* ((n_array (cons-array 6 'double)))
        (aset n_array 0 x0 )
        (aset n_array 1 y0 )
        (aset n_array 2 x1)
        (aset n_array 3 y1)
        (aset n_array 4 x2)
        (aset n_array 5 y2)
        n_array)
      )
    
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
        )
    (gimp-selection-none img)
    (gimp-context-set-foreground color)
    ;(gimp-context-set-background '(255 255 255))
    (srand (realtime))
    
    ;select lines    
    (while (< iter number)
           
           (if (> randomness 0)
               (set! roffiter  (+ roffset (- (modulo (rand) randomness) (/ randomness 2)))))
           
           (set! x1 (+ xoffset x0 (* roffiter (cos (/ (* (+ aoffset phi1 (/ dphi1 2)) *pi*) 180)) )))
           (set! y1 (+ yoffset y0 (* roffiter (sin (/ (* (+ aoffset phi1 (/ dphi1 2)) *pi*) 180)) )))
           (set! x2 (+ x0 (* length  (cos (/ (*    phi1              *pi*) 180)) )))
           (set! y2 (+ y0 (* length  (sin (/ (*    phi1              *pi*) 180)) )))
           (set! x3 (+ x0 (* length  (cos (/ (* (+ phi1 dphi1)       *pi*) 180)) )))
           (set! y3 (+ y0 (* length  (sin (/ (* (+ phi1 dphi1)       *pi*) 180)) )))
           
           (gimp-free-select img 6
                             (triangle_array x1 y1
                                             x2 y2
                                             x3 y3)
                             CHANNEL-OP-ADD TRUE FALSE 0) 
           (set! phi1 (+ phi1 dphi2))
           (set! iter (+ iter 1))
           )
    
    ;fill lines
    (gimp-edit-bucket-fill adraw FG-BUCKET-FILL NORMAL-MODE 100 0 FALSE 0 0)    
    
    ; tidy up
    (gimp-selection-none img)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(script-fu-register "escape-lines"
                    _"_Escape Lines"
                    "Paint Escape Lines
 "
                    "tejesh <tejeshagrawal@gmail.com>"
                    "surya <suryakant.bharti@gmail.com>"
                    "03/10/13"
                    "*"
                    SF-IMAGE       "Input image"           0
                    SF-DRAWABLE    "Input drawable"        0
                    SF-ADJUSTMENT _"x0"                '(  0 -5000  5000 1 100 0 1)
                    SF-ADJUSTMENT _"y0"                '(  0 -5000  5000 1 100 0 1)
                    SF-ADJUSTMENT _"Start Angle (deg)" '( 10  -720   720 1  10 1 1)
                    SF-ADJUSTMENT _"End Angle (deg)"   '( 80  -720   720 1  10 1 1)
                    SF-ADJUSTMENT _"Thickness (deg)"   '(  2   0.1   720 1  10 1 1)
                    SF-ADJUSTMENT _"Number of Lines"   '( 10     1   300 1  10 0 1)
                    SF-ADJUSTMENT _"Length"           '(300 -10000 10000 1  10 0 1)
                    SF-ADJUSTMENT _"Inner Radius Offset"    '(100 -10000 10000 1  10 1 1)
                    SF-ADJUSTMENT _"Inner Radius Randomness" '(0   -5000  5000 1  10 1 1)
                    SF-ADJUSTMENT _"x Offset"          '( 0 -10000 10000 1  10 1 1)
                    SF-ADJUSTMENT _"y Offset"          '( 0 -10000 10000 1  10 1 1)
                    SF-ADJUSTMENT _"Angle Offset"      '(  0  -720   720 1  10 1 1)
                    SF-COLOR      _"Color"             '(255 0 0)
                    )

(script-fu-menu-register "escape-lines" _"<Image>/Filters/new")
