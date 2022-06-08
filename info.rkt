#lang info
(define deps '("drracket-plugin-lib"
               "gui-lib"
               "base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/drracket-restore-workspace.scrbl" ())))
(define pkg-desc "Restore workspace for DrRacket")
(define version "0.0")
(define pkg-authors '(sorawee))
(define drracket-tool-names (list "Restore workspace"))
(define drracket-tools (list (list "tool.rkt")))
(define license '(Apache-2.0 OR MIT))
