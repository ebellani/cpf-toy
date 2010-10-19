#lang racket
(require "fetcher.rkt"
         rackunit
         srfi/19)

(check-equal? (csv-date->date "01/02/1990")
              (make-date 0 0 0 0 1 2 1990 -7200))

(check-equal? (csv-file->list-of-people
               (open-input-string "12345678901,fulano da silva,01/01/1990
                                   09876543210,cicrano dos santos,01/09/1980"))
              '((make-person "12345678901"
                             "fulano da silva"
                             (make-date 0 0 0 0 1 2 1990 -7200))
                (make-person "09876543210"
                             "cicrano dos santos"
                             (make-date 0 0 0 0 1 9 1980 -7200))))



