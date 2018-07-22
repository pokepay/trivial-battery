(defpackage #:trivial-battery/os/mac
  (:use #:cl)
  (:import-from #:xmls)
  (:import-from #:assoc-utils
                #:aget)
  (:import-from #:uiop)
  (:export #:battery-info))
(in-package #:trivial-battery/os/mac)

(defun get-response-xml ()
  (with-output-to-string (s)
    (uiop:run-program '("ioreg" "-n" "AppleSmartBattery" "-r" "-a")
                      :output s
                      :error-output :interactive)))

(defun parse-xml (xml)
  (labels ((normalize-value (v)
             (destructuring-bind (type attrs &rest values) v
               (declare (ignore attrs))
               (cond
                 ((string= type "integer")
                  (parse-integer (first values)))
                 ((string= type "array")
                  (mapcar #'normalize-value values))
                 ((string= type "true") t)
                 ((string= type "false") nil)
                 ((or (string= type "string")
                      (string= type "data"))
                  (first values))
                 ((string= type "dict") (parse-dict values))
                 (t (error "Unknown type: ~A" type)))))
           (parse-dict (key-values)
             (loop for (k v . rest) on key-values by #'cddr
                   collect (cons (third k)
                                 (normalize-value v)))))
    (let ((key-values (nthcdr 2 (third (third (xmls:parse xml))))))
      (parse-dict key-values))))

(defun battery-info ()
  (let ((info (parse-xml (get-response-xml))))
    `((("percentage". ,(if (cdr (assoc "FullyCharged" info :test #'string=))
                           100
                           (floor
                            (* (/ (cdr (assoc "CurrentCapacity" info :test #'string=))
                                  (cdr (assoc "MaxCapacity" info :test #'string=)))
                               100))))
       ("charging" . ,(or (cdr (assoc "FullyCharged" info :test #'string=))
                          (cdr (assoc "IsCharging" info :test #'string=))))))))

(defun battery-details (battery)
  (declare (ignore battery))
  (first (battery-info)))
