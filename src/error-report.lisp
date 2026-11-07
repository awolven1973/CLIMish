(in-package :climish)

(defobject backtrace-expand-button (iconify-button))

(defmethod clim:handle-event ((self backtrace-expand-button) (event clim:pointer-button-press-event))
  (if (the value)
      (progn
	(setf (the value) nil)
	(setf (the window height) (- (second (the window parent-width/height)) (the window y)))
	)
      (progn
	(setf (the value) t)
	(setf (the window height) (the window default-height))
	))
  (values))

(defobject error-report-title-bar (title-bar)
  :inputs
  ((title-bar-color #xCC4E24FF)))
      

(defobject error-report-mixin (essential-error-report-mixin homemade-window-mixin)
  :inputs
  ((title "Error Report")
   (parent-width/height (multiple-value-list (clui:window-framebuffer-size (the parent))))
   (x (- (first (the parent-width/height)) (the width) 130))
   (default-height 120)
   (width (+ (the style default-initial-window-width) 120))
   (height :visual (the default-height)))

  :components
  ((title-bar :type (if (the title-bar?) 'error-report-title-bar 'null-object)
	      :eager t
	      title (the title)
	      iconify-button? (the iconify-button?)
	      close-button? (the close-button?)
	      transparency-button? (the transparency-button?)
	      button-size (font-size (the font)))
   
   (backtrace-expand-button :type 'backtrace-expand-button
			    visible? (not (the iconified?))
			    size (font-size (the font))
			    y (+ 64 (the y) (the title-bar height)))))

(defmethod initialize-instance :after ((self error-report-mixin) &rest initargs)
  (declare (ignore initargs))
  (setf (the y)
	(let ((proposed (incf (send (the parent) current-error-report-y) (1+ (the height)))))
	  (if (> (+ proposed (the height)) (second (the parent-width/height)))
	      (progn (setf (send (the parent) current-error-report-y) 0)
		     (incf (send (the parent) current-error-report-y) (1+ (the height))))
	      proposed)))
  (values))

(defmethod rm-draw-node :after ((self error-report))
  (unless (the iconified?)
    (ignore-errors
     (let ((node (the adhoc-scene-graph::node))
	   (error (the adhoc-scene-graph::error)))
       (push (scene-add-text-primitive (the scene)
				       (the group)
				       nil
				       (the font)
				       #x000000ff
				       (the client-rect x0)
				       (the client-rect y0)
				       (format nil "Error on: ~S:" node)
				       (the object-id)
				       (1+ (the elevation)))
	     (the primitive-handles))
       (let ((error-list (uiop/utility:split-string (format nil "~A" error) :separator '(#\Newline))))
	 (loop for error-line in error-list
	       for i from 0 by (font-size (the font))
	       do
		  (push (scene-add-text-primitive (the scene)
						  (the group)
						  nil
						  (the font)
						  #x000000ff
						  (the client-rect x0)
						  (+ 36 (the client-rect y0))
						  error-line
						  (the object-id)
						  (1+ (the elevation)))
			(the primitive-handles))))
       (unless (the backtrace-expand-button value)
	 (let ((backtrace-list (uiop/utility:split-string (the adhoc-scene-graph::backtrace) :separator '(#\Newline))))
	   (loop for backtrace-line in backtrace-list
		 for i from (font-size (the font)) by (font-size (the font))
		 do
		    (push (scene-add-text-primitive (the scene)
						    (the group)
						    nil
						    (the font)
						    #x000000ff
						    (the client-rect x0)
						    (+ (the backtrace-expand-button y) i)
						    backtrace-line
						    (the object-id)
						    (1+ (the elevation)))
			  (the primitive-handles))))))))
  (values))
    

(defobject error-report (error-report-mixin) ;; redefinition.

  )

(defobject test-error-node (node-mixin)
  :inputs
  ((rotation (error "test-error-node sample error"))))

(defobject test-error-view (homemade-window-mixin)
  :components
  ((test :type 'test-error-node)))

(defmethod cad-command-p (thing)
  nil)

(define-presentation-method accept ((type climish::not-everywhere-command)
				    (stream application-frame-mixin) view &key)
  (with-input-context (stream 'climish::not-everywhere-command)
      (object ptype nil nil)
      (recursive-command-loop stream)
    (t (values object type))))
  
