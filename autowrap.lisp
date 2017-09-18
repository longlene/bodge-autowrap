(cl:defpackage :bodge-autowrap
  (:use :cl)
  (:export c-include))
(cl:in-package :bodge-autowrap)


(defun make-prefix-cutter (prefix-length)
  (lambda (name matches regex)
    (declare (ignore matches regex))
    (subseq name prefix-length)))


(defun expand-symbol-exceptions (symbol-exceptions)
  (loop for (name symbol) in symbol-exceptions
     collect (cons name (symbol-name symbol))))


(defun expand-symbol-regex (symbol-regex)
  (loop for (regex idx) in symbol-regex
     collect (list regex nil (list 'make-prefix-cutter idx))))


(defun parse-sysincludes (system includes)
  (loop for include in includes
     collect (if (stringp include)
                 include
                 (namestring
                  (asdf:component-pathname
                   (asdf:find-component (asdf:find-system system) include))))))


(defmacro c-include (header system-name &body body
                     &key package sources definitions
                       symbol-exceptions symbol-regex
                       sysincludes)
  (declare (ignore body))
  `(autowrap:c-include
    ',(list system-name header)
    :spec-path ',(list system-name :spec)
    :definition-package ,package
    :include-arch ,(append #+unix '("x86_64-pc-linux-gnu" "i686-pc-linux-gnu")
                            #+windows '("x86_64-pc-windows-" "i686-pc-windows")
                            #+darwin '("x86_64-apple-darwin" "i686-apple-darwin"))
    :sysincludes ',(append (parse-sysincludes system-name sysincludes)
                           #+unix
                           (list "/usr/include/x86_64-pc-linux-gnu/")
                           #+windows
                           (list "c:/msys64/mingw64/x86_64-w64-mingw32/include/"
                                 "c:/msys64/mingw64/include/"
                                 "c:/msys64/usr/local/include/"))
    :exclude-sources (".*\\.h")
    :include-sources ,sources
    :include-definitions ,definitions
    :no-accessors t
    :filter-spec-p t
    :symbol-exceptions ,(expand-symbol-exceptions symbol-exceptions)
    :symbol-regex ,(expand-symbol-regex symbol-regex)))
