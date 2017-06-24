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

(defun battery-percentage (battery)
  (values
   (parse-integer
    (with-output-to-string (s)
      (uiop:run-program `("cat" ,(format nil "/sys/class/power_supply/~A/capacity" battery))
                        :output s)))))

(defun battery-charging-p (battery)
  (let ((res
          (with-output-to-string (s)
            (uiop:run-program `("cat" ,(format nil "/sys/class/power_supply/~A/status" battery))
                              :output s))))
    (not (string= "Discharging"
                  (string-right-trim '(#\newline) res)))))

(defun battery-info ()
  (let ((battery (first (batteries))))
    (when battery
      `(("percentage" . ,(battery-percentage battery))
        ("charging" . ,(battery-charging-p battery))))))
