# Scheme Interpreter in Swift
This interpreter was developed for the lecture "Design und Implementation fortgeschrittener Programmiersprachen" at HdM Stuttgart in SS2021.
The lecture was given by Claus Gittinger. 

The interpreter was built in Swift 5.4.2 as an executable Swift package. For full functionality, swift-tools-version:5.3 is required. As an alternative, the interpreter was also created as a command line project for Xcode 10.1, which can be found at: [Xcode 10.1 project](https://github.com/niklasschildhauer/Scheme-Swift-Xcode10.1/tree/main/Scheme-Swift-Xcode10.1)   

### Build
The build process can either be executed automatically in Xcode 12 or manually in the terminal using the following commands:

```
$ cd ./Scheme-Swift
$ swift build
$ swift run
```

### Syntax
| syntax                   |       symbol       | example                              |                                                    result |
|--------------------------|:------------------:|--------------------------------------|----------------------------------------------------------:|
| define                   |         `define`   | `(define a "value")`                 |                                                      ` `  |
| if                       |         `if`       | `(if #t (display "true") (display "false"))`   |                                          `true` |
| set                      |         `set!`     | `(set! a "new value")`               |                                                      ` `  |
| begin                    |         `begin`    | `(begin (define a 2) (+ 3 a))`       |                                                       `5` |
| lambda                   |         `lambda`   | `((lambda (x y) (+ x y)) 1 2)`       |                                                       `3` |
| quote                    |         `quote`    | `(quote 42)`                            |                                                   `42` |



### Functions

| function                 |       symbol       | type    | example                              |                                                    result |
|--------------------------|:------------------:|---------|--------------------------------------|----------------------------------------------------------:|
| addition                 |         `+`        | builtin | `(+ 1 2 5)`                          |                                                       `8` |
| subtraction              |         `-`        | builtin | `(- 10 5)`                           |                                                       `5` |
| multiplication           |         `*`        | builtin | `(* 3 2)`                            |                                                       `6` |
| division                 |         `/`        | builtin | `(/ 5 2)`                            |                                                     `2.5` |
| modulo                   |         `%`        | builtin | `(% 5 2)`                            |                                                       `1` |
| equal numbers            |         `=`        | builtin | `(= 1 11)`                           |                                                      `#f` |
| equal objects            |        `eq?`       | builtin | `(eq? 1 1)`                          |                                                      `#t` |
| greater than             |         `>`        | builtin | `(> 5 2)`                            |                                                      `#t` |
| lesser than              |         `<`        | builtin | `(< 5 2)`                            |                                                      `#f` |
| greater than or equal    |        `>=`        | udf     | `(>= 5 5)`                           |                                                      `#t` |
| lesser than or equal     |        `<=`        | udf     | `(<= 5 5)`                           |                                                      `#t` |
| display                  |      `display`     | builtin | `(display "string")`                 |                                        displays `string`  |
| print                    |      `print`       | builtin | `(print "string")`                   |                                        displays `"string"`|
| truncate                 |      `truncate`    | builtin | `(truncate 32.7)`                    |                                        displays `32`      |
| list                     |       `list`       | builtin | `(list 1 2 3)`                       |                                                 `(1 2 3)` |
| list                     |       `'`          | builtin | `'(1 2 4 3)`                         |                                               `(1 2 4 3)` |
| cons                     |       `cons`       | builtin | `(cons 5 '(4 3))`                    |                                                 `(5 4 3)` |
| car                      |        `car`       | builtin | `(car '(1 2 3))`                     |                                                       `1` |
| cdr                      |        `cdr`       | builtin | `(cdr '(1 2 3))`                     |                                                   `(2 3)` |
| load                     |       `load`       | builtin | `(load "absolute path to file") `    |                   Executes all statements in the file.    |
| equal strings            |   `string=?`       | builtin | `(string=? "a" "a")`                 |                                                      `#t` |
| char in string           |   `string-ref`     | builtin | `(string-ref "Hallo" 4)`             |                                                     `'o'` |
| append strings           |   `string-append`  | builtin | `(string-append "Hallo" "..." "!")`  |                                             `"Hallo...!"` |
| length of string         |   `string-length`  | builtin | `(string-length "Hallo")`            |                                                       `5` |
| is string                |      `string?`     | builtin | `(string? "asd")`                    |                                                      `#t` |
| is number                |      `number?`     | builtin | `(number? 0)`                        |                                                      `#t` |
| is cons                  |       `cons?`      | builtin | `(cons? '(1 2 3))`                   |                                                      `#t` |
| is function              |     `function?`    | builtin | `(function? +)`                      |                                                      `#t` |
| is function              |`builtin-funciton?` | builtin | `(builtin-funciton? +)`              |                                                      `#t` |
| is user defined function |  `user-function?`  | builtin | `(user-function? +)`                 |                                                      `#f` |
| is bool value            |       `bool?`      | builtin | `(bool? #f)`                         |                                                      `#t` |
| power of n               | `pow`              | udf     | `(pow 10 3)`                         | `1000`                                                    |
| factorial                |     `factorial`    | udf     | `(factorial 4)`                      |                                                      `24` |
| fibonacci                |        `fibonacci` | udf     | `(fibonacci 10)`                     |                                                      `55` |


