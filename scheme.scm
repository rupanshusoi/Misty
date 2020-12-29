;;; Pair utilities
(define build
  (lambda (s1 s2)
    (cons s1 (cons s2 '()))))

;;; Dictionary utilities
(define new-entry build)

(define extend-table cons)

(define lookup-in-entry
  (lambda (name entry entry-f)
    (lookup-in-entry-help name (first entry) (second entry) entry-f)))

(define lookup-in-entry-help
  (lambda (name names values entry-f)
    (cond ((null? names) (entry-f name))
	  ((eq? name (car names)) (car values))
	  (else (lookup-in-entry-help name (cdr names) (cdr values) entry-f)))))

;;; Environment lookup
(define lookup-in-table
  (lambda (name table table-f)
    (cond ((null? table) (table-f name))
	  (else (lookup-in-entry name (car table) (lambda (name)
						    (lookup-in-table
						      name (cdr table) table-f)))))))

;;; Types are implemented as actions
(define expression-to-action
  (lambda (e)
    (cond ((atom? e) (atom-to-action e))
	  (else (list-to-action e)))))

(define atom-to-action
  (lambda (e)
    (cond
      ((number? e) *const)
      ((eq? e #t) *const)
      ((eq? e #f) *const)
      ((eq? e 'cons) *const)
      ((eq? e 'car) *const)
      ((eq? e 'cdr) *const)
      ((eq? e 'null?) *const)
      ((eq? e 'eq?) *const)
      ((eq? e 'atom?) *const)
      ((eq? e 'zero) *const)
      ((eq? e 'add1) *const)
      ((eq? e 'sub1) *const)
      (else *identifer))))

(define list-to-action
  (lambda (e)
    (cond ((atom? (car e))
	   (cond ((eq? (car e) 'quote) *quote)
		 ((eq? (car e) 'lambda) *lambda)
		 ((eq? (car e) 'cond) *cond)
		 (else *application)))
	  (else *application))))
