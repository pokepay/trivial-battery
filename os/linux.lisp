(defpackage #:trivial-battery/os/linux
  (:use #:cl)
  (:import-from #:split-sequence
                #:split-sequence)
  (:import-from #:uiop)
  (:export #:battery-info))
(in-package #:trivial-battery/os/linux)

(defun batteries ()
  (let ((supplies
          (with-output-to-string (s)
            (uiop:run-program '("ls" "/sys/class/power_supply/")
                              :output s
                              :ignore-error-status t))))
    (remove-if-not (lambda (supply)
                     (and (< 3 (length supply))
                          (string= supply "BAT" :end1 3)))
                   (split-sequence #\Newline supplies :remove-empty-subseqs t))))

(defun slurp-line (pathname)
  (with-open-file (s pathname)
    (read-line s)))

(defun try-int (value)
  (handler-case
      (values (parse-integer value))
    (error (e) (declare (ignore e)) value)))

(defun battery-percentage (battery)
  (values
   (parse-integer
    (slurp-line (format nil "/sys/class/power_supply/~A/capacity" battery)))))

(defun battery-charging-p (battery)
  (not (string=
        "Discharging"
        (slurp-line (format nil "/sys/class/power_supply/~A/status" battery)))))

(defun battery-details (battery)
  (cons
   (cons "name" battery)
   (loop for f in (uiop:directory-files (format nil "/sys/class/power_supply/~A/" battery))
      for name = (file-namestring f)
      unless (string= "uevent" name)
      collect (cons name (try-int (slurp-line f))))))

(defun battery-info ()
  (mapcar
   (lambda (battery)
     `(("percentage" . ,(battery-percentage battery))
       ("charging" . ,(battery-charging-p battery))
       ("name" . ,battery)))
   (batteries)))
