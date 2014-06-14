;sharpen 

(define (erosion-sharpen img draw op gauss_blur)
  (let*
      ((owidth (car (gimp-image-width img)))
       (oheight (car (gimp-image-height img)))
       (blurred-layer (car (gimp-layer-copy draw FALSE)))
       (erode-layer (car (gimp-layer-copy draw FALSE)))
       (dilate-layer (car (gimp-layer-copy draw FALSE)))
       (erode-layermask (car (gimp-layer-create-mask erode-layer ADD-WHITE-MASK)))
       (dilate-layermask (car (gimp-layer-create-mask dilate-layer ADD-WHITE-MASK)))
       (additive-layer 0)
       (subtractive-layer 0)
       )
    
    ;init
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    
    ; add and blur copy
    (gimp-image-add-layer img blurred-layer -1)
    (gimp-drawable-set-name blurred-layer "Blurred")
    (plug-in-gauss TRUE img blurred-layer gauss_blur gauss_blur TRUE)
    
    ; subtract first from second
    (gimp-layer-set-mode blurred-layer SUBTRACT-MODE)
    (gimp-edit-copy-visible img)
    (set! subtractive-layer (car (gimp-layer-new-from-visible img img "Subtractive") ))
    (gimp-image-add-layer img subtractive-layer 0)
    (gimp-drawable-set-visible subtractive-layer FALSE)
    
    ; subtract second from first
    (gimp-image-lower-layer img blurred-layer)
    (gimp-layer-set-mode blurred-layer NORMAL-MODE)
    (gimp-layer-set-mode draw SUBTRACT-MODE)
    (gimp-edit-copy-visible img)
    (set! additive-layer (car (gimp-layer-new-from-visible img img "Additive") ))
    (gimp-image-add-layer img additive-layer 0)    
    
    ; set modes back to normal
    (gimp-drawable-set-visible subtractive-layer TRUE)
    (gimp-layer-set-mode draw NORMAL-MODE)
    
    ; add and erode copy
    (gimp-image-add-layer img erode-layer -1)
    (gimp-drawable-set-name erode-layer "Erode")
    (plug-in-vpropagate TRUE img erode-layer 1 1 0.7 15 0 255)
    
    ; add and dilate copy
    (gimp-image-add-layer img dilate-layer -1)
    (gimp-drawable-set-name dilate-layer "Dilate")
    (plug-in-vpropagate TRUE img dilate-layer 0 1 0.7 15 0 255)
    
    ; add layer masks
    (gimp-layer-add-mask erode-layer erode-layermask)
    (gimp-selection-all img)
    (gimp-edit-copy additive-layer)
    (gimp-floating-sel-anchor (car (gimp-edit-paste erode-layermask TRUE)))
    
    (gimp-layer-add-mask dilate-layer dilate-layermask)
    (gimp-selection-all img)
    (gimp-edit-copy subtractive-layer)
    (gimp-floating-sel-anchor (car (gimp-edit-paste dilate-layermask TRUE)))
    
    ; adjust levels
    (gimp-levels erode-layermask HISTOGRAM-VALUE 0 30 2 0 255)
    (gimp-levels dilate-layermask HISTOGRAM-VALUE 0 30 2 0 255)
    
    ; anti aliasing of layer masks
    (plug-in-antialias TRUE img erode-layermask)
    (plug-in-antialias TRUE img dilate-layermask)
    
    ; adjust levels 2nd
    (gimp-levels erode-layermask HISTOGRAM-VALUE 0 128 2 0 255)
    (gimp-levels dilate-layermask HISTOGRAM-VALUE 0 128 2 0 255)
    
    ; anti aliasing of layer masks 2nd
    (plug-in-antialias TRUE img erode-layermask)
    (plug-in-antialias TRUE img dilate-layermask)
    
    ; remove unnecessary layers
    (gimp-image-remove-layer img subtractive-layer)
    (gimp-image-remove-layer img additive-layer)
    (gimp-image-remove-layer img blurred-layer)
    
    ; set opacities
    (gimp-layer-set-opacity erode-layer op)
    (gimp-layer-set-opacity dilate-layer op)
    
    ; tidy up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(script-fu-register "erosion-sharpen"
                    _"_Erosion Sharpen"
                    "Sharpens the image with erosion and dilation"
                    "tejesh <tejeshagrawal@gmail.com>"
                    "surya <suryakant.bharti@gmail.com>"
                    "03/10/13"
                    "*"
                    SF-IMAGE       "Input image"           0
                    SF-DRAWABLE    "Input drawable"        0
                    SF-ADJUSTMENT _"Strength"             '(60 0 100 1 20 0 0)
                    SF-ADJUSTMENT _"Radius"               '(2 1 20 1 5 0 0)
                    )

(script-fu-menu-register "erosion-sharpen" _"<Image>/Filters/new")
