(cl:in-package :cl-user)


(asdf:defsystem :bodge-autowrap
  :description "Autowrap wrapper for quick wrapping bodge wrappers"
  :author "Pavel Korolev <dev@borodust.org>"
  :version "1.0.0"
  :depends-on (cl-autowrap)
  :components ((:file "autowrap")))
