(fn cart-current ()      (!?   (session 'cart)      (properties-alist !)))
(fn cart-undos ()        (!?   (session 'cart-undo) (array-list !)))
(fn cart-redos ()        (!?   (session 'cart-redo) (array-list !)))
(fn (= cart-current) (x) (=    (session 'cart)      (alist-properties x)))
(fn (= cart-undos) (x)   (=    (session 'cart-undo) (list-phparray x))) ; TODO fix
(fn (= cart-redos) (x)   (=    (session 'cart-redo) (list-phparray x))) ; TODO fix
(fn cart-add-undo ()     (push (session 'cart)      (cart-undos)))
(fn cart-add-redo ()     (push (session 'cart)      (cart-redos)))
(fn cart-pop-undo ()     (=    (session 'cart)      (pop (cart-undos))))
(fn cart-pop-redo ()     (=    (session 'cart)      (pop (cart-redos))))

(fn cart-num-undos ()    (length (session 'cart-undo)))
(fn cart-num-redos ()    (length (session 'cart-redo)))
(fn cart-has-undo? ()    (not (zero? (cart-num-undos))))
(fn cart-has-redo? ()    (not (zero? (cart-num-redos))))

(fn cart-item (x)
  (assoc x (cart-current)))

(fn has-cart? ()
  (not (zero? (length (cart-current)))))

(defmacro filter-cart (&rest body)
  `(= (cart-current) (@ [,@body] (cart-current))))

(fn cart-redirect ()
  (action-redirect :update 'cart))

(fn cart-undo (x)
  (cart-add-redo)
  (cart-pop-undo)
  (cart-redirect)
  .x)

(fn cart-redo (x)
  (cart-add-undo)
  (cart-pop-redo)
  (cart-redirect)
  .x)

(fn cart-remove (x)
  (cart-add-undo)
  (= (cart-current) (aremove .x. (cart-current)))
  (cart-redirect))

(fn cart-add (x)
  (cart-add-undo)
  (let id (number .x.)
    (!? (cart-item id)
        (filter-cart (? (== _. id)
                        (. _. (++ ._))
                        _))
        (acons! id 1 (cart-current))))
  (cart-redirect))

(fn cart-price-total ()
  (let total 0
    (dolist (i (cart-current) total)
      (+! total (number (assoc-value 'price (cart-find-article i.)))))))

(fn cart-items ()
  (template-list #'tpl-cart-item (@ [cart-find-article _.] (cart-current))))

(fn cart-num-items ()
  (length (cart-current)))

(fn cart-item-count (id)
  (assoc-value id (cart-current)))

(fn cart-update-item (x)
  (filter-cart (? (eql _. (assoc-value 'id))
                  (. _. (assoc-value 'n x))
                  _)))

(fn cart-update ()
  (when (has-form?)
    (cart-add-undo)
    (@ #'cart-update-item (form-alists))
    (action-redirect)))

(fn cart (x)
  (set-port
;    (cart-update)
    (? (has-cart?)
       (tpl-cart)
       (tpl-cart-empty)))
  1)

(defmacro define-cart-action (name)
  `(define-action ,name :group cart))

(define-cart-action cart)
(define-cart-action cart-add)
(define-cart-action cart-remove)
(define-cart-action cart-undo)
(define-cart-action cart-redo)
