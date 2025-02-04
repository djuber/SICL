(cl:in-package #:sicl-ast-evaluator)

(defun cst-to-ast (client cst environment)
   (handler-bind
       ((trucler:no-function-description
          (lambda (condition)
            (warn "Unknown function ~s" (trucler:name condition))
            (invoke-restart 'cleavir-cst-to-ast:consider-global)))
        (trucler:no-variable-description
          (lambda (condition)
            (warn "Unknown variable ~s" (trucler:name condition))
            (invoke-restart 'cleavir-cst-to-ast:consider-special)))
        (cleavir-cst-to-ast::encapsulated-condition
          (lambda (condition)
            (declare (ignore condition))
            (invoke-restart 'cleavir-cst-to-ast:signal-original-condition))))
     (cleavir-cst-to-ast:cst-to-ast
      client cst environment)))

(defun translate-top-level-ast (client ast)
  (let* ((table (make-hash-table :test #'eq))
         (lexical-environment (list table))
         (function-cell-finder-var (gensym))
         (*run-time-environment-name* (gensym))
         (*function-cells* '())
         (code (translate-ast client ast lexical-environment))
         (vars
           (remove-duplicates
            (loop for name being each hash-value of table
                  collect name))))
    `(lambda (,*run-time-environment-name*)
       (declare (ignorable ,*run-time-environment-name*))
       (declare (optimize (speed 0) (compilation-speed 3) (debug 0) (safety 3) (space 0)))
       #+sbcl (declare (sb-ext:muffle-conditions sb-ext:compiler-note))
       (let* ((,function-cell-finder-var
                (sicl-environment:fdefinition
                 (sicl-environment:client ,*run-time-environment-name*)
                 ,*run-time-environment-name*
                 'sicl-data-and-control-flow:function-cell))
              ,@(loop for (function-name . variable-name) in *function-cells*
                      collect `(,variable-name
                                (funcall ,function-cell-finder-var ',function-name))))
         (declare (ignorable ,function-cell-finder-var))
         (let ,vars
           (declare (ignorable ,@vars))
           ,code)))))
