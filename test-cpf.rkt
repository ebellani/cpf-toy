#lang racket
(require "cpf.rkt"
         rackunit
         srfi/19)

(define people
  (list (person "12345678901"
                "fulano da silva"
                (make-date 0 0 0 0 1 2 1990 -7200))
        (person "09876543210"
                "cicrano dos santos"
                (make-date 0 0 0 0 1 9 1980 -7200))))

(check-equal? (csv-date->date "01/02/1990")
              (make-date 0 0 0 0 1 2 1990 -7200))

(check-equal? (input-port->people
               (open-input-string
                "12345678901,fulano da silva,01/02/1990
                 09876543210,cicrano dos santos,01/09/1980"))
              people)

(check-equal?
 (person->query (person "09876543210"
                        "cicrano dos santos"
                        (make-date 0 0 0 0 1 9 1980 -7200)))
 "'09876543210', 'cicrano dos santos', '1980-09-01 00:00:00'")



(check-equal? (people->insert-query people)
              "INSERT INTO people (cpf,name,birthdate) VALUES ('12345678901', 'fulano da silva', '1990-02-01 00:00:00'),('09876543210', 'cicrano dos santos', '1980-09-01 00:00:00');")

(check-equal?
 (person->url-parameters
  (person "09876543210"
          "cicrano dos santos"
          (make-date 0 0 0 0 1 9 1980 -7200)))
 #"cpf=09876543210;name=cicrano dos santos;birth-date='1980-09-01'")


;(insert-into-db! people)
(insert-into-web! people)