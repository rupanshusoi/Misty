;;; Dictionary utilities
(define new-entry build)

(define lookup-in-entry
  (lambda (name entry entry-f)
    (lookup-in-entry-help name (first entry) (second entry) entry-f)))

(define lookup-in-entry-help
  (lambda (name names values entry-f)
    (cond ((null? names) (entry-f name))
	  ((eq? name (car names)) (car values))
	  (else (lookup-in-entry-help name (cdr names) (cdr values) entry-f)))))
