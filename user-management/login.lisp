(var *login-status* nil)

(fn user-id ()    (session 'id))
(fn user-alias () (session 'alias))
(fn logged-in? () (user-id))

(fn logout (x)
  (session_destroy)
  (= (session 'id)    nil)
  (= (session 'alias) nil)
  (action-redirect :remove 'login :add 'logoutdone))

(fn login-ok (user)
  (= (session 'id)    (assoc-value 'id user))
  (= (session 'alias) (assoc-value 'alias user))
  (action-redirect :remove 'login :add 'logindone))

(fn encrypt-password (x)
  (areplace x (list (. 'password (md5 (assoc-value 'password x))))))

(fn process-login ()
  (!? (find-user (encrypt-password (form-data)))
      (login-ok !)
      (= *login-status* (lang de "Dieser Benutzer ist uns nicht bekannt oder das Passwort stimmt nicht."
                              en "Sorry, but the username or password is incorrect."))))

(fn login (x)
  (?
    (form-complete?) (process-login)
    (has-form?)      (= *login-status* (lang de "Das Formular ist unvollst&auml;ndig."
                                             en "Sorry, but the form is incomplete.")))
  (set-port
    (tpl-login))
  1)

(define-action login  :group login)
(define-action logout :group login)
