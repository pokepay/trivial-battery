(defpackage #:trivial-battery/os/windows
  (:use #:cl)
  (:import-from #:uiop)
  (:export #:battery-info))
(in-package #:trivial-battery/os/windows)

(defun get-wmic-battery-remaining ()
  (with-output-to-string (s)
    (uiop:run-program '("WMIC" "Path" "Win32_Battery" "Get" "EstimatedChargeRemaining")
                      :output s
                      :error-output :interactive
                      :force-shell t)))

(defun get-wmic-battery-status ()
  (with-output-to-string (s)
    (uiop:run-program '("WMIC" "Path" "Win32_Battery" "Get" "BatteryStatus")
                      :output s
                      :error-output :interactive
                      :force-shell t)))

(defun parse-response (res)
  (let ((nl-pos (position #\Newline res)))
    (values
     (parse-integer res :start nl-pos :junk-allowed t))))

(defun battery-percentage ()
  (parse-response (get-wmic-battery-remaining)))

(defun battery-charging-p ()
  (not (eql (parse-response (get-wmic-battery-status)) 1)))

(defun battery-info ()
  `(("percentage" . ,(battery-percentage))
    ("charging" . ,(battery-charging-p))))
