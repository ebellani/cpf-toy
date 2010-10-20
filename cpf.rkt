#lang racket
(require srfi/19
         net/url
         racket/string
         (planet neil/csv:1:6)
         (planet jaz/mysql:1:7))

(define SQL-DATE-FORMAT "~Y-~m-~d ~H:~M:~S")
(define TABLE-NAME "people")

(struct person (cpf name birth-date) #:transparent)

;; csv->people -> input-port -> (listof person)
(define (csv->people csv-input-port)
  (csv-map (λ (row)
             (person (first row)
                     (second row)
                     (csv-date->date (third row))))
           (cpf-csv-reader csv-input-port)))

(define cpf-csv-reader
  (make-csv-reader-maker
   '((strip-leading-whitespace? . #t)
     (strip-trailing-whitespace? . #t))))

;; csv-date->date -> string -> date
;; Formats the CSV date day/month/year into a date struct.
(define (csv-date->date csv-date)
  (string->date csv-date "~d/~m/~Y"))  

;; person->query : person -> string
(define (person->query a-person)
  (format "'~a', '~a', '~a'"
          (person-cpf a-person)
          (person-name a-person)
          (date->string (person-birth-date a-person) SQL-DATE-FORMAT)))

;; build-query : (listof person) -> string
(define (people->insert-query people0)
  (local [(define (people->values people)
            (string-join
             (map (λ (person)
                    (format "(~a)" (person->query person)))
                  people) ","))]
    (format "INSERT INTO ~a (~a) VALUES ~a;"
            TABLE-NAME
            "cpf, name, birth-date"
            (people->values people0))))

(provide csv->people
         csv-date->date
         person->query
         people->insert-query
         (struct-out person))