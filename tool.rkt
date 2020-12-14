#lang racket/base
(require drracket/tool
         framework
         racket/contract
         racket/list
         racket/format
         racket/match
         racket/class
         racket/gui/base
         racket/unit)
(provide tool@)

(define data-key 'drracket-restore-workspace:data)
(define offset-key 'drracket-restore-workspace:offset)
(define menu-items '())

;; data = list of saved ok tabs
;; offset is either
;; - #f which means there's no save
;; - nat which means the index of the active tabs in the saved ok tabs
;; invariant: offset = #f iff data = '()
(preferences:set-default data-key '() list?)
(preferences:set-default offset-key #f (or/c #f exact-nonnegative-integer?))

(define (maybe-enable-menu-items)
  (define enabled? (preferences:get offset-key))
  (for ([menu-item (in-list menu-items)])
    (send menu-item enable enabled?)))

(define (disable-menu-items)
  (for ([menu-item (in-list menu-items)])
    (send menu-item enable #f)))

(define (goto frame pos)
  (send (send frame get-definitions-text) set-position pos))

(define tool@
  (unit
    (import drracket:tool^)
    (export drracket:tool-exports^)

    (define restore-workspace-mixin
      (mixin (drracket:unit:frame<%>) ()
        (super-new)
        (inherit get-tabs get-show-menu)
        (define/private (get-ok-tabs)
          (for*/list ([tab (in-list (get-tabs))]
                      [defs (in-value (send tab get-defs))]
                      [filename (in-value (send defs get-filename))]
                      #:when filename)
            (list (~a filename) (send defs get-end-position))))

        (define/private (restore)
          (define offset (preferences:get offset-key))
          (match (preferences:get data-key)
            [(list first-tab rest-tab ...)
             (define the-frame
               (cond
                 [(send this still-untouched?) this]
                 [else (drracket:unit:open-drscheme-window #f)]))
             (send the-frame change-to-file (first first-tab))
             (goto the-frame (second first-tab))

             (for ([tab (in-list rest-tab)])
               (send the-frame open-in-new-tab (first tab))
               (goto the-frame (second tab)))

             (send the-frame change-to-tab
                   (list-ref (send the-frame get-tabs) offset))

             (preferences:set data-key '())
             (preferences:set offset-key #f)
             (disable-menu-items)]
            [_ (void)]))

        (define the-menu-item
          (new menu-item%
               [label "Restore tabs in the last closed window"]
               [callback (λ (c e) (restore))]
               [parent (get-show-menu)]))

        (set! menu-items (cons the-menu-item menu-items))
        (maybe-enable-menu-items)

        (define/augment (on-close)
          (define ok-tabs (get-ok-tabs))
          (unless (empty? ok-tabs)
            (define the-index (index-of ok-tabs (~a (send+ this
                                                           (get-current-tab)
                                                           (get-defs)
                                                           (get-filename)))
                                        (λ (a b) (equal? (first a) b))))
            (preferences:set data-key ok-tabs)
            (preferences:set offset-key (or the-index 0))
            (maybe-enable-menu-items))
          (set! menu-items (remq the-menu-item menu-items))

          (inner (void) on-close))))

    (define phase1 void)
    (define phase2 void)

    (drracket:get/extend:extend-unit-frame restore-workspace-mixin)))
