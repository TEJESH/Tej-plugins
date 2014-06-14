;wb-puzzle

(define (wb-puzzle aimg adraw puzzlewidth puzzleheight feathervalue)
  (let* ((img (car (gimp-drawable-get-image adraw)))
         (wblayer (car (gimp-layer-copy adraw FALSE)))
         (owidth (car (gimp-image-width img)))
         (oheight (car (gimp-image-height img)))
         (itermaxX (/ owidth puzzlewidth))
         (itermaxY (/ oheight puzzleheight))
         (iterwidth 0) ;iterators
         (iterheight 0)
         )
    
    ; init
    (define (block-select aimg x0 y0 blockwidth blockheight x y);x=0..itermaxX-1 y=0..itermaxY-1
      (let*	((startx (+ x0 (* x blockwidth))) 
                 (starty (+ y0 (* y blockheight)))
                 )
        (gimp-rect-select aimg startx starty (+ blockwidth 0) (+ blockheight 0) CHANNEL-OP-REPLACE FALSE 0)
        )
      )
    
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
        )
    ;(gimp-context-set-foreground '(0 0 0))
    ;(gimp-context-set-background '(255 255 255))
    
    ;select rectangular blocks and auto white balance them
    (gimp-image-add-layer img wblayer -1)
    
    (while (< iterwidth itermaxX)
           (while (< iterheight itermaxY)
                  (block-select img 0 0 puzzlewidth puzzleheight iterwidth iterheight)
                  (if (> feathervalue 0)
                      (gimp-selection-feather img feathervalue)
                      )
                  (gimp-levels-stretch wblayer)
                  (set! iterheight (+ iterheight 1))
                  )
           (set! iterheight 0)
           (set! iterwidth (+ iterwidth 1))
           )
    
    ; tidy up
    (gimp-selection-none img)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(script-fu-register "wb-puzzle"
                    _"_White Balance Puzzle"
                    "Creating a Puzzle of white balanced pieces.
  "
                    "tejesh <tejeshagrawal@gmail.com>"
                    "surya <suryakant.bharti@gmail.com>"
                    "02/09/08"
                    "*"
                    SF-IMAGE       "Input image"          0
                    SF-DRAWABLE    "Input drawable"       0
                    SF-ADJUSTMENT _"Block Width" '(40 1 2000 1 10 0 1)
                    SF-ADJUSTMENT _"Block Height" '(40 1 2000 1 10 0 1)
                    SF-ADJUSTMENT _"Feather" '(0 0 1000 1 10 0 1)
                    )
(script-fu-menu-register "wb-puzzle" _"<Image>/Filters/new")
