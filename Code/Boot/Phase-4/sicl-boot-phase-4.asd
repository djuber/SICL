(cl:in-package #:asdf-user)

(defsystem #:sicl-boot-phase-4
  :depends-on (#:sicl-ast-compiler
               #:sicl-boot-base
               #:sicl-clos-boot-support)
  :serial t
  :components
  ((:file "packages")
   (:file "environment")
   (:file "pre-fill-environment")
   (:file "enable-typep")
   (:file "enable-object-creation")
   (:file "enable-method-combinations")
   (:file "enable-defgeneric")
   (:file "enable-defmethod")
   (:file "enable-defclass")
   (:file "prepare-this-phase")
   (:file "ast-evaluator-configuration")
   (:file "boot")))
