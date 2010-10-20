#lang racket
#|
Problema 2:

A receita federal disponibiliza mensalmente o cadastro geral de pessoas
físicas num arquivo CSV ordenado por cpf e atualizado, para que todas as
empresas possam manter seus cadastros locais de pessoas físicas
atualizados. Nos meses impares esse arquivo é disponibilizado num servidor
de FTP, nos meses pares em um servidor HTTP.  A empresa Xpto LTDA tem
interesse em manter seus dados atualizados com a base da receita.

O repositório local desse cadastro muda constantemente. Atualmente a forma
de atualizar é gravando em um banco de dados MySQL ou usando um serviço
REST. A escolha em qual guardar depende da equipe que cuida da base de
cadastros e isso muda frequentemente. Essa equipe planeja, no futuro, usar
uma outra forma de atualizar esses dados, baseada em um servidor de filas, e
o programa que usa as informações precisará enviar uma mensagem para esse
servidor. Por enquanto essa implementação não é necessária, mas o diretor da
empresa gostaria que o programa possa sofrer poucas alterações quando essa
nova forma de atualização estiver disponível.

Seguem os dados da receita:

Formato CSV
cpf,nome,data_nascimento
12345678901,fulano da silva,01/01/1990
09876543210,cicrano dos santos,01/01/1980

Os dados dos servidores do cadastro são:
FTP: ftp.receitafederal.aaa.br/cadastros_pf.csv
HTTP: http://receitafederal.aaa.br/cadastros/pf

Seguem os dados dos repositórios locais:

MySQL: localhost:3306
Interface REST: http://cadastrointerno.xpto.com/pessoas

Com base no cenário proposto, desenvolva um programa que faça a coleta
desses dados e atualize o(s) repositório(s) com essas informações.
|#

;; CSV sample -> http://online.wsj.com/public/resources/documents/NYSE.csv

(require net/url
         net/ftp
         cpf)

;(call/input-url (string->url "http://online.wsj.com/public/resources/documents/NYSE.csv")
;                get-pure-port
;                (λ (ip)
;                  (read-text-file-from-input-port ip)
;                  "ok"))

