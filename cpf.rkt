#lang racket
(require srfi/19
         net/url
         racket/string
         (planet neil/csv:1:6)
         (planet jaz/mysql:1:7))

(define CURRENT-PASSWORD "passwd")
(define SQL-DATE-FORMAT "~Y-~m-~d ~H:~M:~S")
(define WEB-DATE-FORMAT "~Y-~m-~d")
(define TABLE-NAME "people")
(define TABLE-COLUMNS (list "cpf"
                            "name"
                            "birth-date"))
(define WEB-INTERFACE-ADDRESS
  "http://0.0.0.0:3000/products")

(define CURRENT-INSERT-FUNCTION insert-into-web!)

;;http://cadastrointerno.xpto.com/pessoas

(define (save-people! people)
  (CURRENT-INSERT-FUNCTION people))

(define (db-handle)
  (connect
   "localhost"
   3306
   "root"
   CURRENT-PASSWORD
   #:schema "cnxs_production"))

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
(define (people->insert-query people)
  (format "INSERT INTO ~a (~a) VALUES ~a;"
          TABLE-NAME
          (string-join TABLE-COLUMNS ",")
          (string-join (map (λ (person)
                              (format "(~a)" (person->query person)))
                            people)
                       ",")))

(define (insert-into-db! people)
  (query #:connection
         (db-handle)
         (people->insert-query people)))

(define (insert-into-web! people)
  (for-each
   (λ (person)
     (post-pure-port
      (string->url WEB-INTERFACE-ADDRESS)
      (person->url-parameters person)))
   people))

(define (person->url-parameters a-person)
  (string->bytes/utf-8
   (format "cpf=~a;name=~a;birth-date='~a'"
           (person-cpf a-person)
           (person-name a-person)
           (date->string (person-birth-date a-person) WEB-DATE-FORMAT))))


(provide csv->people
         person->url-parameters
         insert-into-db!
         insert-into-web!
         csv-date->date
         save-people!
         person->query
         people->insert-query
         (struct-out person))