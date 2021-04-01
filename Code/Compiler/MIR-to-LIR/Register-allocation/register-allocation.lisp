(cl:in-package #:sicl-register-allocation)

(defun do-register-allocation (enter-instruction)
  (preprocess-instructions enter-instruction)
  (let ((back-arcs (find-back-arcs enter-instruction))
        (*input-pools* (make-hash-table :test #'eq))
        (*output-pools* (make-hash-table :test #'eq))
        (*input-arrangements* (make-hash-table :test #'eq))
        (*output-arrangements* (make-hash-table :test #'eq)))
    (compute-estimated-distance-to-use enter-instruction back-arcs)
    (allocate-registers-for-instructions enter-instruction)))
    
  
