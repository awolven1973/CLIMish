(in-package :climish)

(defobject error-report-mixin (essential-error-report-mixin homemade-window-mixin)
  :inputs
  ((title "Error Report")
   (parent-width/height (multiple-value-list (clui:window-framebuffer-size (the parent))))
   (x (- (first (the parent-width/height)) (the width) 120))
   (height 120)))

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
       (push (scene-add-text-primitive (the scene)
				       (the group)
				       nil
				       (the font)
				       #x000000ff
				       (the client-rect x0)
				       (+ 36 (the client-rect y0))
				       (format nil "~A" error)
				       (the object-id)
				       (1+ (the elevation)))
	     (the primitive-handles)))))
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
  
