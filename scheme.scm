(define print-debug
  (lambda (x)
    (print "Hi, there!")))

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
      (else *identifier))))

(define list-to-action
  (lambda (e)
    (cond ((atom? (car e))
	   (cond ((eq? (car e) 'quote) *quote)
		 ((eq? (car e) 'lambda) *lambda)
		 ((eq? (car e) 'cond) *cond)
		 (else *application)))
	  (else *application))))

;;; Actions
(define *const
  (lambda (e env)
    (cond ((number? e) e)
	  ((eq? #t e) e)
	  ((eq? #f e) e)
	  (else (build 'primitive e)))))

(define *quote
  (lambda (e env)
    (cdr e)))

(define *identifier
  (lambda (e env)
    (lookup-in-table e env (lambda (name) (car '())))))

;; lambda helpers
(define table-of first)
(define formals-of second)
(define body-of third)

(define *lambda
  (lambda (e env)
    (build 'non-primitive (cons env (cdr e)))))

;; cond helpers
(define else?
  (lambda (x)
    (cond ((atom? x) (eq? x 'else))
	  (else #f))))

(define question-of first)
(define answer-of second)

(define evcond
  (lambda (lines table)
    (cond ((else? (question-of (car lines))) (meaning (answer-of (car lines)) table))
	  ((meaning (question-of (car lines)) table) (meaning (answer-of (car lines)) table))
	  (else (evcon (cdr lines) table)))))

(define *cond
  (lambda (e env)
    (evcond (cdr e) env)))

;; application helpers
(define evlist
  (lambda (args env)
    (cond ((null? args) '())
	  (else (cons (meaning (car args) env) (evlist (cdr args) env))))))

(define function-of car)
(define arguments-of cdr)

(define *application
  (lambda (e env)
    (my-apply (meaning (function-of e) env) (evlist (arguments-of e) env))))

;; apply helpers
(define primitive?
  (lambda (l)
    (eq? (car l) 'primitive)))

(define non-primitive?
  (lambda (l)
    (eq? (car l) 'non-primitive)))

(define :atom?
  (lambda (x)
    (cond ((atom? x) #t)
	  ((null? x) #f)
	  ((eq? (car x) 'primitive) #t)
	  ((eq? (car x) 'non-primitive) #t)
	  (else #f))))

(define apply-primitive
  (lambda (fun vals)
    (cond ((eq? (car fun) 'cons) (cons (car vals) (cdr vals)))
	  ((eq? (car fun) 'car) (car (car vals)))
	  ((eq? (car fun) 'cdr) (cdr (car vals)))
	  ((eq? (car fun) 'null?) (null? (car vals)))
	  ((eq? (car fun) 'eq?) (eq? (car vals) (cdr vals)))
	  ((eq? (car fun) 'atom?) (:atom? (car vals)))
	  ((eq? (car fun) 'zero?) (zero? (car vals)))
	  ((eq? (car fun) 'add1) (add1 (car vals)))
	  ((eq? (car fun) 'sub1) (sub1 (car vals)))
	  ((eq? (car fun) 'number?) (number? (car vals))))))

(define my-apply
  (lambda (fun vals)
    (cond ((primitive? fun) (apply-primitive (cdr fun) vals))
	  ((non-primitive? fun) (apply-closure (cdr fun) vals)))))

(define apply-closure
  (lambda (closure vals)
    (meaning (body-of closure) (extend-table (new-entry (formals-of closure) vals) (table-of closure)))))

;;; Interpreter starts here
(define meaning
  (lambda (e env)
    ((expression-to-action e) e env)))

(define value
  (lambda (e)
    (meaning e '())))
