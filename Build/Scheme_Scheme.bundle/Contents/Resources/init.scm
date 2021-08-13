; (display "hier init.scm\n")

; get the void object (this is the ret-value of display)
(define #void (display))
(define nil ())
(define (not b) (if b #f #t))

(define (< n1 n2) (> n2 n1))
(define (<= n1 n2) (not (> n1 n2)))
(define (>= n1 n2) (not (< n1 n2)))
(define (!= n1 n2) (not (= n1 n2)))

(define first car)
(define (second cell) (car (cdr cell)))

(define (fac n)
    ; a deep recursive version of factorial
    (if (< n 1)
	1
    ;
	(* n (fac (- n 1)))))

(define (fac_t n)
    ; a tail-recursive version of factorial
    (define (helper accu n)
	(if (= n 1)
	    accu
	;
	    (helper (* n accu) (- n 1))))

    (helper 1 n))

(define (count-down n)
    ; for measurements
    (if (= n 0)
	0
    ;
	(count-down (- n 1))))

(define (foreach list func)
    ; evaluate func for each element in a list
    (if (eq? list ())
	#void
    ; else
	(begin
	    (func (car list))
	    (foreach (cdr list) func))))

(define (range start stop)
    ; generate a list start..stop - similar to python's range
    (define (helper start stop listTail)
	(if (> start stop)
	    listTail
	;
	    (helper start (- stop 1) (cons stop listTail))))
    (helper start stop ()))
    
(define factorial (lambda (n) (if (= n 0) 1 (* n (factorial (- n 1))))))
(define fibonacci (lambda (n) (if (< n 2) 1 (+ (fibonacci (- n 1)) (fibonacci (- n 2))))))

; (load "compiler.scm")

; (display "end of init.scm\n")
