(defpackage #:trivial-battery
  (:nicknames #:trivial-battery/main)
  #+linux
  (:import-from #:trivial-battery/os/linux
                #:battery-info)
  #+darwin
  (:import-from #:trivial-battery/os/mac
                #:battery-info)
  #+(or win32 windows)
  (:import-from #:trivial-battery/os/windows
                #:battery-info)
  (:export #:battery-info))

#-(or linux darwin win32 windows)
(error "Unsupported operating system.")
