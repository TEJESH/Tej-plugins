;tux

(define (tuxcomputers-split-tone theImage theLayer
                                 highColour highOpacity
                                 shadColour shadOpacity
                                 edgeDetection)
  (let*( (layerEdgeDetect (car (gimp-layer-copy theLayer FALSE)))
         ;Read the current colours
         (myBackground (car (gimp-context-get-background)))
         ;Read the image width and height
         (imageWidth (car (gimp-image-width theImage)))
         (imageHeight (car (gimp-image-height theImage)))
         )
    
    ;define helper function    
    (define (layer-colour-add image layer layermask
                              name width height
                              colour opacity
                              invertMask)
      (let* ((layerCopy (car (gimp-layer-copy layer 1)))
             (newLayer (car (gimp-layer-new image width height 1 "Overlay" 100 5)))
             (mergedLayer 0)
             (mask 0)
             )
        ;main layer
        (gimp-context-set-background colour)
        (gimp-image-add-layer image layerCopy 0)
        (gimp-drawable-set-name layerCopy name)
        
        ;overlay layer
        (gimp-image-add-layer image newLayer 0)
        (gimp-layer-set-mode newLayer 5)
        (gimp-edit-fill newLayer 1)
        (set! mergedLayer (car (gimp-image-merge-down image newLayer 0)))
        
        ;Add a layer mask
        (set! mask (car (gimp-layer-create-mask layermask 5)))
        (gimp-layer-add-mask mergedLayer mask)
        (if (= invertMask TRUE) (gimp-invert mask))
        
        ;Change the merged layers opacity
        (gimp-layer-set-opacity mergedLayer opacity)
        )
      ) ;end of layer-colour-add 
    
    ;init
    (gimp-image-undo-group-start theImage)
    (gimp-selection-none theImage)
    (if (= (car (gimp-drawable-is-gray theLayer )) TRUE)
        (gimp-image-convert-rgb theImage)
        )
    
    ;Edge Detection
    (if (= edgeDetection TRUE)
        (begin
          (gimp-image-add-layer theImage layerEdgeDetect 1)
          (plug-in-edge 1 theImage layerEdgeDetect 2.0 1 0)
          )
        )
    
    ;Desaturate the layer
    (gimp-desaturate theLayer)
    
    ;Add the shadows layer
    (layer-colour-add theImage theLayer layerEdgeDetect
                      "Shadows"
                      imageWidth imageHeight
                      shadColour shadOpacity
                      TRUE)
    
    ;Add the highlights layer
    (layer-colour-add theImage theLayer layerEdgeDetect
                      "Highlights"
                      imageWidth imageHeight
                      highColour highOpacity
                      FALSE)
    
    ;tidy up
    (gimp-image-undo-group-end theImage)
    (gimp-context-set-background myBackground)
    (gimp-displays-flush)
    )
  )

(script-fu-register "tuxcomputers-split-tone"
                    _"_Split Tone with ED"
                    "Turns a B&W image into a split tone image"
                    "Tejesh"
                    "Surya"
                    "Oct. 03 2013"
                    "*"
                    SF-IMAGE        "Image"     0
                    SF-DRAWABLE     "Drawable"  0
                    SF-COLOR        _"Highlight colour"  '(255 144 0)
                    SF-ADJUSTMENT   _"Highlight opacity" '(100 0 100 1 1 0 0)
                    SF-COLOR        _"Shadows colour"    '(0 204 255)
                    SF-ADJUSTMENT   _"Shadow opacity"    '(100 0 100 1 1 0 0)
                    SF-TOGGLE       _"Edge Detection"     FALSE
                    )

(script-fu-menu-register "tuxcomputers-split-tone" _"<Image>/Filters/new")
