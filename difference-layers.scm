;difference-layers 


(define (difference-layers img draw)
  (if (< 1 (car (gimp-image-get-layers img)))
      (let*
          ((layer-list (cadr (gimp-image-get-layers img)))
           (top-layer (aref layer-list 0))
           (bottom-layer (aref layer-list 1))
           (additive-layer 0)
           (subtractive-layer 0)
           )
        
        ;init
        (gimp-context-push)
        (gimp-image-undo-group-start img)
        
        ;subtract first from second
        (gimp-layer-set-mode top-layer SUBTRACT-MODE)
        (gimp-edit-copy-visible img)
        (set! subtractive-layer (car (gimp-layer-new-from-visible img img "Subtractive") ))
        (gimp-image-add-layer img subtractive-layer 0)
        (gimp-drawable-set-visible subtractive-layer FALSE)
        
        ;subtract second from first
        (gimp-image-lower-layer img top-layer)
        (gimp-layer-set-mode top-layer NORMAL-MODE)
        (gimp-layer-set-mode bottom-layer SUBTRACT-MODE)
        (gimp-edit-copy-visible img)
        (set! additive-layer (car (gimp-layer-new-from-visible img img "Additive") ))
        (gimp-image-add-layer img additive-layer 0)    
        
        (gimp-drawable-set-visible subtractive-layer TRUE)
        (gimp-layer-set-mode additive-layer ADDITION-MODE)
        (gimp-layer-set-mode subtractive-layer SUBTRACT-MODE)
        
        (gimp-layer-set-mode bottom-layer NORMAL-MODE)
        
        ; tidy up
        (gimp-image-undo-group-end img)
        (gimp-displays-flush)
        (gimp-context-pop)
        )
      ;number of layers is less than 2
      (gimp-message "Number of layers is less than 2")
      )
  )

(script-fu-register "difference-layers"
                    _"_Difference Layers"
                    "Creates difference layers from first two layers.
 "
                   "tejesh <tejeshagrawal@gmail.com>"
                    "surya <suryakant.bharti@gmail.com>"
                    "03/10/13"
                    "*"
                    SF-IMAGE       "Input image"           0
                    SF-DRAWABLE    "Input drawable"        0
                    )

(script-fu-menu-register "difference-layers" _"<Image>/Layer")
