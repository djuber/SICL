(cl:in-package #:cleavir-literals)

(defclass similarity-table ()
  (;; The EQL table is used to ensure that each object is only scanned once.
   ;; This works because if two objects are EQL, they are also similar in
   ;; the sense of CLHS 3.2.4.2.2.
   (%eql-table :initform (make-hash-table :test #'eq) :reader eql-table)
   ;; The EQUAL and EQUALP tables are used to coalesce literal objects
   ;; where the rules of similarity are less restrictive, e.g., specialized
   ;; arrays or hash tables.
   (%equal-table :initform (make-hash-table :test #'equal) :reader equal-table)
   (%equalp-table :initform (make-hash-table :test #'equalp) :reader equalp-table)))

(defmacro literal-record-cache (object)
  `(gethash ,object (eql-table *similarity-table*)))

;;; An ENTRY holds a creation form or an initialization form, and when
;;; fully computed, also the object resulting from the conversion of
;;; the form.  When the ENTRY is created the RESULT slot contains NIL
;;; which means that the result has not yet been computed.
(defclass entry ()
  (;; The creation form or initialization form corresponding to this
   ;; entry.
   (%form :initarg :form :reader form)
   ;; The object resulting from the conversion of the form.
   (%result :initform nil :accessor result)
   ;; A list of instances of ENTRY that this entry depends on.  When
   ;; an ENTRY A depends on an ENTRY B, this means that the code of B
   ;; must be executed before that of A when the compilation unit is
   ;; loaded.  Every entry in this list is an instance of the class
   ;; CREATION-ENTRY.
   (%leaders :initform '() :initarg :leaders :accessor leaders)))

(defclass creation-entry (entry)
  (;; This slot contains the literal that resulted in this entry.  It
   ;; is used only for the purpose of error reporting.
   (%literal :initarg :literal :reader literal)
   ;; This slot holds a lexical location representing a variable that
   ;; will contain the literal once it has been created at load time.
   (%lexical-location :initarg :lexical-location :reader lexical-location)
   ;; A list if instance of ENTRY that depends on this entry.
   (%followers :initform '() :initarg :followers :accessor followers)))

(defclass literal-record ()
  ((%creation-entry
    :initarg :creation-entry
    :reader creation-entry)
   (%initialization-entry
    :initarg :initialization-entry
    :reader initialization-entry)))

(defmethod load-time-literal :around (client object environment)
  (multiple-value-bind (literal-record present-p)
      (literal-record-cache object)
    (if present-p
        (result (creation-entry literal-record))
        (call-next-method))))
