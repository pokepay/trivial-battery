(defpackage #:trivial-battery/os/windows
  (:use #:cl)
  (:import-from #:uiop)
  (:export #:battery-info))
(in-package #:trivial-battery/os/windows)

(defun get-wmic-battery-remaining ()
  (with-output-to-string (s)
    (let ((process
            (uiop:run-program `(,(uiop:native-namestring #P"C:/Windows/System32/Wbem/WMIC.exe")
                                "Path" "Win32_Battery" "Get" "EstimatedChargeRemaining")
                              :output s
                              :error-output :interactive)))
      ;; Call process-status for Windows to close process handles.
      ;; ref. https://bugs.launchpad.net/sbcl/+bug/1724472
      #+sbcl (sb-ext:process-status process)
      process)))

(defun get-wmic-battery-status ()
  (with-output-to-string (s)
    (let ((process
            (uiop:run-program `(,(uiop:native-namestring #P"C:/Windows/System32/Wbem/WMIC.exe")
                                "Path" "Win32_Battery" "Get" "BatteryStatus")
                              :output s
                              :error-output :interactive)))
      ;; Call process-status for Windows to close process handles.
      ;; ref. https://bugs.launchpad.net/sbcl/+bug/1724472
      #+sbcl (sb-ext:process-status process)
      process)))

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
