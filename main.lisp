(in-package #:org.my.project)

(defclass main (trial:main)
  ())

(setf +app-system+ "my-project")

(define-action-set in-game)
(define-action move (directional-action in-game))
(define-action hide (in-game))

(defun launch (&rest args)
  (let ((*package* #.*package*))
    (load-keymap)
    (setf (active-p (action-set 'in-game)) T)
    (apply #'trial:launch 'main args)))

(define-asset (trial cat) image
    #p"cat.png")

(define-shader-entity my-cube (vertex-entity colored-entity textured-entity transformed-entity listener)
  ((vertex-array :initform (// 'trial 'unit-cube))
   (texture :initform (// 'trial 'cat))
   (color :initform (vec 1 1 1 1))))

(define-handler (my-cube hide) ()
  (setf (vw (color my-cube)) (if (= (vw (color my-cube)) 1.0) 0.1 1.0)))

(define-handler (my-cube tick) (tt dt)
  (setf (orientation my-cube) (qfrom-angle +vy+ tt))
  (let ((movement (directional 'move))
        (speed 10.0))
    (incf (vx (location my-cube)) (* dt speed (- (vx movement))))
    (incf (vz (location my-cube)) (* dt speed (vy movement)))))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'my-cube) scene)
  (enter (make-instance '3d-camera :location (vec 0 0 -3)) scene)
  (enter (make-instance 'render-pass) scene)
  (preload (make-instance 'bullet) scene))

(define-shader-entity bullet (vertex-entity colored-entity transformed-entity listener)
  ((vertex-array :initform (// 'trial 'unit-sphere))
   (color :initform (vec 1 0 0 1))
   (velocity :initform (vec 0 0 0) :initarg :velocity :accessor velocity)))

(define-handler (bullet tick) (dt)
  (nv+* (location bullet) (velocity bullet) dt))

(define-handler (my-cube key-press) (key)
  (case key
    (:f (enter (make-instance 'bullet :location (location my-cube)
                                      :scaling (vec 0.1 0.1 0.1)
                                      :velocity (nv* (q* (orientation my-cube) +vx3+) 5))
               (container my-cube)))))
