; Copyright (c) 2012,2016 Sven Michael Klose <pixel@copei.de>

(defmacro define-sql-editor (&key name singular-name
                                  template item-template
                                  (item-presets nil)
                                  (parent-name nil)
                                  (parent-reference-field nil)
                                  (children-name nil))
  (& parent-name
     (not parent-reference-field)
     (error "PARENT-REFERENCE-FIELD must be set with PARENT-NAME"))
  (with (action        name
         action-item   (| children-name singular-name)
         action-add    ($ 'add- singular-name)
         action-edit   ($ 'edit- singular-name)
         action-remove ($ 'remove- singular-name)
         tpl-list      ($ 'tpl- name)
         tpl-item      ($ 'tpl- singular-name)
         fn-find       ($ 'find- name)
         fn-delete     ($ 'delete- name)
         fn-insert     ($ 'insert- singular-name))
        (print
    `(progn
       (define-template ,tpl-list :path ,template)
       (define-template ,tpl-item :path ,item-template)

       (defun ,action-add (x)
         (set-port
           (,fn-inserter (+ ,item-presets
                            ,@(!? parent-reference-field
                                  `((list (. ',! (integer (cadr x))))))
                            (form-data)))
           (action-redirect :remove ',action-add))
         nil)

       (define-action ,action-add)

       (defun ,action-remove (x)
         (set-port
           (,fn-delete `(id . ,.x.))
           (action-redirect :remove ',action-remove))
         nil)

       (define-action ,action-remove)

       (defun ,action (x)
         (set-port
           (,tpl-list `((records . ,,`(template-list [,tpl-item (+ (list (. 'link-item   (action-url :add (list ',action-item   (assoc-value 'id _))))
                                                                         (. 'link-edit   (action-url :add (list ',action-edit   (assoc-value 'id _))))
                                                                         (. 'link-remove (action-url :add (list ',action-remove (assoc-value 'id _)))))
                                                                   _)]
                                                     (,fn-find ,@(!? parent-name
                                                                     `((list (. ',parent-reference-field (integer (| .x. 0)))))))))
                        (link-add . ,,`(action-url :add (list ',action-add ,@(& parent-reference-field
                                                                                `((| (param 'id) 0)))))))))
         (values (list x. (| .x. 0)) ..x))

       (define-action ,action)))))
