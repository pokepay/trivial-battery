(defpackage #:trivial-battery
  (:nicknames #:trivial-battery/main)
  #+linux
  (:import-from #:trivial-battery/os/linux
                #:battery-info #:battery-details)
  #+darwin
  (:import-from #:trivial-battery/os/mac
                #:battery-info #:battery-details)
  #+(or win32 windows)
  (:import-from #:trivial-battery/os/windows
                #:battery-info #:battery-details)
  (:export #:battery-info #:battery-details))

#-(or linux darwin win32 windows)
(error "Unsupported operating system.")
