# Misty

A Scheme Interpreter in Lua.

## Dependencies
Misty has been developed with Lua 5.4.2.

## Motivation
This project is a personal exercise in understanding programming language implementation. The goal was to implement a few major features, therefore, I have not made an attempt to match the semantics of Scheme in detail. As such, Misty can be considered a separate language that derives from Scheme.

## Usage
`lua src/test.lua` will evaluate each expression in a file (set to `src/test.scm` by default) and return the evaluation of the last one. Note that Misty currently has no `display` method.

Misty exposes two public methods: `Misty.run` which will evaluate a single expression given as a string, and `Misty.run_file` which is used in `src/test.lua`.

## Features
On a high-level, Misty supports lexical scoping, higher-order functions, and has tail-call optimization. A full list of primitives can easily be found in `src/misty.lua`; it is easy to add new primitives there.

## Potential Improvements
One of the main disadvantages of implementing a language using the control-flow of another high-level language is the difficulty in reconciling subtle semantic differences. For instance, which values are _falsy_ for the two languages might be different. A better implementation would be to implement a virtual machine for Scheme.

Moreover, it would be nice to have support for floats, strings, macros, and `call/cc`.

## Old Misty
`old-src` contains the original implementation of Misty. I wrote it in Jan 2021 but consider it to be very bloated. For e.g., it has a basic notion of types that it doesn't really need. The latest version is rewritten (almost) from scratch.

## Scheme Implementation
This project includes a Scheme interpreter for Scheme as well. The code is lifted almost entirely from Chapter 10 of The Little Schemer (see below). I wrote it when I was reading the book, and decided to include it for completeness. Perhaps it will be useful to others as the book never presents the entire implementation together in a single place.

## Why Misty?
The name should be reminiscent of M-expressions, an early syntax for Lisp (of which Scheme is a dialect).

## Author
Rupanshu Soi, Department of Computer Science, BITS Pilani - Hyderabad Campus, India.

## References
- [(How to Write a (Lisp) Interpreter (in Python)) by Peter Norvig](https://norvig.com/lispy.html)
- [The Little Schemer by Friedman and Felleisen](https://mitpress.mit.edu/books/little-schemer-fourth-edition)
- [(An ((Even Better) Lisp) Interpreter (in Python))](http://norvig.com/lispy2.html)
