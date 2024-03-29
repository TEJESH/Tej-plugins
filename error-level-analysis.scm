;analysis 

(define (error-level-analysis img draw quality filename)
  (let* ((img-tmp 0)
         (img-tmp-2 0)
         (draw-tmp 0)
         (error-layer 0)
         )
    
    ;init
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    
    ;save image as 70% jpeg
    (set! img-tmp (car (gimp-image-duplicate img)))
    (gimp-image-merge-visible-layers img-tmp EXPAND-AS-NECESSARY)
    (set! draw-tmp (car (gimp-image-get-active-drawable img-tmp)))
    (file-jpeg-save RUN-NONINTERACTIVE img-tmp draw-tmp filename filename quality 0 0 0 "GIMP ELA Temporary Image" 0 0 0 0)
    
    ;open 70% jpeg, set as diff layer
    (set! draw-tmp (car(gimp-file-load-layer RUN-NONINTERACTIVE img-tmp filename)))
    (gimp-image-add-layer img-tmp draw-tmp -1)
    (gimp-layer-set-mode draw-tmp DIFFERENCE-MODE)
    (file-delete filename)
    
    ;error layer on top
    (gimp-edit-copy-visible img-tmp)
    (set! error-layer (car (gimp-layer-new-from-visible img-tmp img-tmp "Error Levels") ))
    (gimp-image-add-layer img-tmp error-layer -1)    
    (gimp-levels-stretch error-layer)
    ;(gimp-display-new img-tmp)
    
    ;add error levels as layer on orig image
    (gimp-edit-copy-visible img-tmp)
    (set! error-layer (car (gimp-layer-new-from-visible img-tmp img "Error Levels") ))
    (gimp-image-add-layer img error-layer -1)
    (gimp-drawable-set-name error-layer "Error Levels")
    
    ; tidy up
    (gimp-image-delete img-tmp)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(script-fu-register "error-level-analysis"
                    _"_Error Level Analysis"
                    "Error level analysis shows differing error levels throughout this image,
 :
 "
                    "tejesh <tejeshagrawal@gmail.com>"
                    "surya <suryakant.bharti@gmail.com>"
                    "03/10/13"
                    "*"
                    SF-IMAGE       "Input image"           0
                    SF-DRAWABLE    "Input drawable"        0
                    SF-ADJUSTMENT _"Quality"               '(0.7 0 1 0.1 1 1 0)
                    SF-STRING      "Temporary File Name"   "error-level-analysis-tmp.jpg" 
                    )

(script-fu-menu-register "error-level-analysis" _"<Image>/Image")
