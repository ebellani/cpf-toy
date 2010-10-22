#lang racket
(require srfi/19
         net/url
         racket/string
         (planet neil/csv:1:6)
         (planet jaz/mysql:1:7))

(define CURRENT-PASSWORD "root")
(define SQL-DATE-FORMAT "~Y-~m-~d ~H:~M:~S")
(define WEB-DATE-FORMAT "~Y-~m-~d")
(define TABLE-NAME "people")
(define TABLE-COLUMNS (list "cpf"
                            "name"
                            "birthdate"))
(define WEB-INTERFACE-ADDRESS
  "http://0.0.0.0:3000/products")

;;http://cadastrointerno.xpto.com/pessoas

;; save-people! : (listof person)
;; uses the desired function to insert the list of person
;; into the correct location.
(define (save-people! people)
  (CURRENT-INSERT-FUNCTION people))

(define (DB-HANDLE)
  (connect
   "localhost"
   3306
   "root"
   CURRENT-PASSWORD
   #:schema "cpf"))

(struct person (cpf name birth-date) #:transparent)

;; input-port->people -> input-port -> (listof person)
;; Turns an input port containing a csv list in the format
;; cpf,name,birth-date
;; into a list of person struct.
(define (input-port->people csv-input-port)
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

;;  people->insert-query : (listof person) -> string
(define (people->insert-query people)
  (format "INSERT INTO ~a (~a) VALUES ~a;"
          TABLE-NAME
          (string-join TABLE-COLUMNS ",")
          (string-join (map (λ (person)
                              (format "(~a)" (person->query person)))
                            people)
                       ",")))

;; insert-into-db! : (listof person)
;; executes the query to insert the list of person
;; into the db, using the current db handle.
(define (insert-into-db! people)
  (query #:connection
         (DB-HANDLE)
         (people->insert-query people)))

;; insert-into-web! : (listof person)
;; cycle though a list of person doing post calls using
;; to a web interface for each person.
(define (insert-into-web! people)
  (for-each
   (λ (person)
     (post-pure-port
      (string->url WEB-INTERFACE-ADDRESS)
      (person->url-parameters person)))
   people))

;; person->url-parameters : person -> bytes
;; takes a person and builds up bytes that are
;; url parameters that represent that person.
(define (person->url-parameters a-person)
  (string->bytes/utf-8
   (format "cpf=~a;name=~a;birth-date='~a'"
           (person-cpf a-person)
           (person-name a-person)
           (date->string (person-birth-date a-person) WEB-DATE-FORMAT))))

(define CURRENT-INSERT-FUNCTION insert-into-web!)

(provide input-port->people
         person->url-parameters
         insert-into-db!
         insert-into-web!
         csv-date->date
         save-people!
         person->query
         people->insert-query
         (struct-out person))