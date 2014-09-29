(cl:in-package #:cleavir-ast-interpreter)

(defgeneric interpret-ast (ast static-env dynamic-env))

(defun interpret (ast)
  (let ((static-env (list (make-hash-table :test #'eq)))
	(dynamic-env '()))
    (interpret-ast ast static-env dynamic-env)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Utility function.

(defun interpret-sequence (sequence static-env dynamic-env)
  (loop for ast in sequence
	for value = (interpret-ast ast static-env dynamic-env)
	finally (return value)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Methods on INTERPRET-AST.

(defmethod interpret-ast ((ast cleavir-ast:constant-ast)
			  static-env dynamic-env)
  (declare (ignore static-env dynamic-env))
  (cleavir-ast:value ast))

(defmethod interpret-ast ((ast cleavir-ast:progn-ast)
			  static-env dynamic-env)
  (interpret-sequence (cleavir-ast:form-asts ast) static-env dynamic-env))

(defmethod interpret-ast ((ast cleavir-ast:setq-ast)
			  static-env dynamic-env)
  (set-lexical
   (cleavir-ast:lhs-ast ast)
   (interpret-ast (cleavir-ast:value-ast ast) static-env dynamic-env)
   static-env))

(defmethod interpret-ast ((ast cleavir-ast:lexical-ast)
			  static-env dynamic-env)
  (declare (ignore dynamic-env))
  (lookup-lexical ast static-env))
