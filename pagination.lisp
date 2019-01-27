(defstruct pagination
  (size 10)
  (page nil)
  (total nil)
  (tpl-range? t))

(def-pagination pagination-offset (pagination)
  (* size (-- page)))

(def-pagination pagination-pages (pagination)
  (+ (integer (/ total size))
     (? (zero? (mod total size))
        0
        1)))

(def-pagination pagination-from (pagination)
  (++ (pagination-offset pagination)))

(def-pagination pagination-to (pagination)
  (alet (+ size (pagination-offset pagination))
    (? (< total !)
       total
       !)))

(def-pagination pagination-first-page? (pagination)
  (== 1 page))

(def-pagination pagination-last-page? (pagination)
  (== (pagination-pages pagination) page))

(fn page-span (cls component-maker page &key (edge? nil) (txt nil))
  `(,@(? edge? '(span) '(a))
     :class ,(? edge?
                (+ cls " .off")
                cls)
     ,@(unless edge?
         (list :href (funcall component-maker page)))
     ,@txt
     ""))

(def-pagination paginate (pagination &key (component-maker nil) (item-maker nil))
  (with (make-item #'((typ idx alternative)
                        (? item-maker
                           (funcall item-maker typ idx)
                           alternative))
         pages (pagination-pages pagination))
    (when (< size total)
      `((div :class "pages"
          ,(page-span "first" component-maker 1 :edge? (pagination-first-page? pagination) :txt (make-item 'first 1 '("")))
          ,(page-span "prev" component-maker (-- page) :edge? (pagination-first-page? pagination) :txt (make-item 'prev (-- page) '("")))
          (div :class "items"
            ,@(with-queue q
                (dotimes (i pages (queue-list q))
                  (alet (++ i)
                    (enqueue q (page-span "item" component-maker ! :edge? (== page !) :txt (make-item 'page ! (list !))))))))
          ,(page-span "next" component-maker (++ page) :edge? (pagination-last-page? pagination) :txt (make-item 'next (++ page) '("")))
          ,(page-span "last" component-maker pages :edge? (pagination-last-page? pagination) :txt (make-item 'last pages'(""))))))))
