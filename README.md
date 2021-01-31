# Misty

A Scheme interpreter in Lua.

## Dependencies
Misty has been tested with Lua 5.4.2 and Chicken Scheme 4.12.0.

## Motivation
This project is a personal exercise in understanding programming language implementation. I have tried my best to match the semantics of Chicken Scheme, but I realistically can not make any guarantees of correctness or completeness.

## Lua Implementation

### Setup
No explicit setup is required, except installation of the dependencies.

### Usage
`lua repl.lua` will start Misty in interactive mode, similar to Chicken Scheme's `csi` command.

`lua repl.lua foo.scm` will evaluate every expression in `foo.scm`, similar to doing `csc foo.scm ; ./foo`.

### Primitives

The following primitives are supported:

| S No. | Primitive |
|-------|-----------|
| 1     | car       |
| 2     | cdr       |
| 3     | cons      |
| 4     | cond      |
| 5     | add1      |
| 6     | sub1      |
| 7     | +         |
| 8     | -         |
| 9     | *         |
| 10    | /         |
| 11    | zero?     |
| 12    | null?     |
| 14    | number?   |
| 13    | quote     |
| 14    | define    |
| 15    | print     |
| 16    | lambda    |

### Known Issues / Future Improvements
* Higher order functions do not work.
* Comments are not supported.
* Multi-line input in interactive mode is not supported.
* Types are probably unnecessary for this implementation. I have plans to rewrite a large part of Misty without introducing types inside the implementation.
* Strings are not supported.

## Scheme Implementation
This project includes a Scheme interpreter for Scheme as well. The code is lifted almost entirely from Chapter 10 of The Little Schemer (see below). I wrote it when I was reading the book, and decided to include it for completeness. Perhaps it will be useful to others as the book never presents the entire implementation together in a single place.

## Why "Misty"?
The name should be reminiscent of M-expressions, an early syntax for Lisp.

## Author
Rupanshu Soi, Department of Computer Science, BITS Pilani at Hyderabad, India.

## References
- [(How to Write a (Lisp) Interpreter (in Python)) by Peter Norvig](https://norvig.com/lispy.html)
- [The Little Schemer by Friedman and Felleisen](https://mitpress.mit.edu/books/little-schemer-fourth-edition)
