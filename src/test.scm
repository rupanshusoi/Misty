(define n-timer (lambda (n) (lambda (x) (* n x))))
(define doubler (n-timer 2))
(doubler 9)

