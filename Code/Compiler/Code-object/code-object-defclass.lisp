(cl:in-package #:sicl-compiler)

;;; A CALL-SITE or a "call-site descriptor" is an object that contains
;;; information about a call site, i.e., an instruction that results
;;; in a function being called.  An instance of this class is
;;; generated by the compiler for each call site, and it is used for
;;; two purposes.
;;;
;;;   * It is passed as an implicit argument to the callee.  The
;;;     callee then stores it at a fixed offset from the frame pointer
;;;     in its stack frame.  There, it can be used by the backtrace
;;;     inspector to access source information, and to display values
;;;     of arguments that are known to be live.  It can also be used
;;;     by the debugger to access information about any live variables
;;;     at the call site.  Finally, it is used by the garbage
;;;     collector to determine which stack locations might contain
;;;     objects that need to be traced.
;;;
;;;   * When the call is to a global, named function, it is used by
;;;     the call-site manager to create trampoline snippets between
;;;     the caller and the callee.  Such a snippet is created when the
;;;     code object is tied to a particular global environment, and
;;;     when the named callee is being redefined.

(defgeneric instruction (call-site))

(defgeneric name (call-site))

(defgeneric trace-map (call-site))

(defgeneric (setf trace-map) (trace-map call-site))

(defgeneric origin (call-site))

(defgeneric (setf origin) (origin call-site))

(defgeneric arguments (call-site))

(defgeneric (setf arguments) (arguments call-site))

(defgeneric code (call-site))

(defgeneric (setf code) (code call-site))

(defgeneric offset (call-site))

(defgeneric (setf offset) (offset call-site))

(defclass call-site ()
  ((%instruction :initarg :instruction :reader instruction)
   ;; This slot contains a function name whenever the call is to a
   ;; named function whether global or a lexical.  When the call is to
   ;; an anonymous function, this slot contains NIL.
   (%name :initarg :name :reader name)
   ;; This slot contains a bitmap to be used by the garbage collector.
   ;; Each index represents an offset from the frame pointer into the
   ;; stack frame of the caller.  If the bitmap contains a `1' at some
   ;; index, it means that the stack location contains a Lisp object
   ;; that may need to be traced by the garbage collector.  If the
   ;; bitmap contains a `0', it means either that the stack location
   ;; does not contain a Lisp object, that the object contained in
   ;; that stack location is not live, or that it contains a live Lisp
   ;; object, but the object is of a type that the compiler has
   ;; determined need not be traced.
   (%trace-map :initarg :trace-map :accessor trace-map)
   ;; This slot contains the code vector, which is a vector with
   ;; element-type (UNSIGNED-BYTE 8), of the entire compilation unit
   ;; that this call site is part of.
   (%code :initarg code :accessor code)
   ;; This slot contains a non-negative integer, representing the
   ;; offset in to the code vector containing the unconditional jump
   ;; instruction that will be modified to jump to a new trampoline
   ;; snippet whenever the callee changes in some way.
   (%offset :initarg offset :accessor offset)
   ;; This slot contains source information about the call site.  If
   ;; no source information is available, this slot contains NIL.
   (%origin :initarg :origin :accessor origin)
   ;; When the call site represents a named call to a global function,
   ;; this slot contains a list with an element for each argument
   ;; being passed.  An element can be either a non-negative integer
   ;; (representing a stack location in the form of an offset from the
   ;; frame pointer of the caller into the stack frame of the caller),
   ;; a register (representing itself), or a literal object (also
   ;; representing itself).  This information is used by the call-site
   ;; manager to construct a trampoline snippet that accesses the
   ;; arguments and puts each one in the corresponding location where
   ;; the callee expects it.
   (%arguments :initarg :arguments :accessor arguments)))

(defgeneric instructions (code-object))

(defgeneric (setf instructions) (instructions code-object))

(defgeneric constants (code-object))

(defgeneric call-sites (code-object))

(defgeneric (setf call-sites) (call-sites code-object))

(defgeneric function-names (code-object))

(defgeneric (setf function-names) (function-names code-object))

(defgeneric ast (code-object))

(defgeneric (setf ast) (ast code-object))

(defgeneric ir (code-object))

(defgeneric (setf ir) (ir code-object))

(defgeneric hir-thunks (code-object))

(defgeneric (setf hir-thunks) (hir-thunks code-object))

(defclass code-object ()
  ((%instructions :initform '() :accessor instructions)
   (%constants :initform (make-array 0 :adjustable t :fill-pointer t)
               :reader constants)
   (%call-sites :initform '() :accessor call-sites)
   (%function-names :initform '() :accessor function-names)
   (%ast :initarg :ast :accessor ast)
   (%ir :initarg :ir :accessor ir)
   (%hir-thunks :initform nil :accessor hir-thunks)))
