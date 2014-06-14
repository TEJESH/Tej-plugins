


(define (technicolor-2-color aimg adraw redpart greenpart cyanfill redfill yellowfill sharpen)
  (let* ((img          (car (gimp-drawable-get-image adraw)))
         (owidth       (car (gimp-image-width img)))
         (oheight      (car (gimp-image-height img)))
         (sharpenlayer (car (gimp-layer-copy adraw FALSE)))
         (redlayer     (car (gimp-layer-copy adraw FALSE)))
         (cyanlayer    (car (gimp-layer-copy adraw FALSE)))
         (yellowlayer  (car (gimp-layer-new img
                                            owidth 
                                            oheight
                                            1
                                            "Yellow" 
                                            30 ;opacity
                                            OVERLAY-MODE)))
         ;decomposing filter colors, you may change these
         (red-R redpart)
         (red-G (/ (- 1 redpart) 2) )
         (red-B (/ (- 1 redpart) 2) )
         (cyan-R 0)
         (cyan-G greenpart)
         (cyan-B (- 1 greenpart) )
         )
    
    ; init
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
        )
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(255 255 255))
    (gimp-drawable-set-visible adraw FALSE)
    
    ;red and cyan filter
    (gimp-drawable-set-name cyanlayer "Cyan")
    (gimp-drawable-set-name redlayer "Red")
    
    (gimp-image-add-layer img redlayer -1)
    (gimp-image-add-layer img cyanlayer -1)
    
    (plug-in-colors-channel-mixer 1 img redlayer TRUE
                                  red-R red-G red-B ;R
                                  0 0 0 ;G
                                  0 0 0 ;B
                                  )
    (plug-in-colors-channel-mixer 1 img cyanlayer TRUE
                                  cyan-R cyan-G cyan-B ;R
                                  0 0 0 ;G
                                  0 0 0 ;B
                                  )
    
    ;colorize filter layers back
    (gimp-context-set-foreground cyanfill)
    (gimp-context-set-background redfill)
    
    (gimp-selection-all img)
    (gimp-edit-bucket-fill redlayer FG-BUCKET-FILL SCREEN-MODE 100 0 FALSE 0 0)
    (gimp-edit-bucket-fill cyanlayer BG-BUCKET-FILL SCREEN-MODE 100 0 FALSE 0 0)
    
    (gimp-layer-set-mode cyanlayer MULTIPLY-MODE)
    
    ;add yellow layer
    (gimp-image-add-layer img yellowlayer -1)
    (gimp-context-set-foreground yellowfill)
    (gimp-edit-bucket-fill yellowlayer FG-BUCKET-FILL NORMAL-MODE 100 0 FALSE 0 0)
    
    ;sharpness + contrast layer
    (if(= sharpen TRUE)
       (begin
         (gimp-image-add-layer img sharpenlayer -1)
         (gimp-desaturate-full sharpenlayer DESATURATE-LIGHTNESS)
         (plug-in-unsharp-mask 1 img sharpenlayer 5 1 0)
         (gimp-layer-set-mode sharpenlayer OVERLAY-MODE)
         (gimp-layer-set-opacity sharpenlayer 40)
         )
       )
    
    ; tidy up
    (gimp-selection-none img)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(script-fu-register " technicolor-2-color"
                    _"_Technicolor 2 Color"
                    "Simulating Technicolor Film.
Newest version can be downloaded from http://registry.gimp.org/node/9129"
                    "elsamuko <elsamuko@web.de>"
                    "elsamuko"
                    "09/09/08"
                    "*"
                    SF-IMAGE       "Input image"      0
                    SF-DRAWABLE    "Input drawable"   0
                    SF-ADJUSTMENT _"Red Part of Red Filter"    '(1.0 0 1 0.1 0.2 1 0)
                    SF-ADJUSTMENT _"Green Part of Cyan Filter" '(0.5 0 1 0.1 0.2 1 0)
                    SF-COLOR      _"Recomposing Cyan" '(0 255 255)
                    SF-COLOR      _"Recomposing Red"  '(255 0 0)
                    SF-COLOR      _"Additive Yellow"  '(255 255 0)
                    SF-TOGGLE     _"Sharpen"  TRUE
                    )

(script-fu-menu-register " technicolor-2-color" _"<Image>/Colors")
