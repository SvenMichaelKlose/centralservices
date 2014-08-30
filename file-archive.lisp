;;;;; Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defstruct file-archive
  path)

(def-file-archive make-file-archive-path (file-archive tail)
  (+ (href *_SERVER* "DOCUMENT_ROOT") *gallery-archive-path* tail))

(def-file-archive create-file-archive-path (file-archive tail)
  (alet (make-file-archive-path file-archive tail)
    (| (file_exists !)
       (mkdir ! 255 t))))
