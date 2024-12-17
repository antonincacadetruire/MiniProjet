-- Nous allons maintenant regarder de près quelques plans de l’optimiseur du SGBD Oracle (sans les
-- exécuter).
-- Soit le schéma suivant :
CREATE TABLE Artiste (
ID - artiste NUMBER (4) ,
Nom VARCHAR2 (32) ,
Adresse VARCHAR2 (32) ) ;
CREATE TABLE Film (
ID - film NUMBER (4) ,
Titre VARCHAR2 (32) ,
Ann ée NUMBER (4) ,
ID - ré alisateur NUMBER (4) );
CREATE TABLE Joue (
ID - artiste NUMBER (4) ,
ID - film NUMBER (4) );
-- 1. Donner l’ordre SQL pour la requˆete : Afficher le nom des acteurs et le titre des films o`u ils
-- ont joué


-- 2. Donner l’expression algébrique correspondante (PEL)


-- 3. Dans chacun des cas suivants, le plan d’exécution PEP routourné par Oracle vous est donné
-- (a) 1er cas : il n’existe que deux index, un sur FILM(ID−realisateur), et un sur ARTISTE(ID−
-- artiste)
SELECT STATEMENT
MERGE JOIN
SORT JOIN
NESTED LOOPS
TABLE ACCESS FULL JOUE
TABLE ACCESS BY ROWID ARTISTE
INDEX UNIQUE SCAN ARTISTE_IDX

SORT JOIN
TABLE ACCESS FULL

-- (b) 2ème cas: un index sur FILM(ID − F ilm), et un sur JOUE(ID − Artiste)
SELECT STATEMENT
NESTED LOOPS
NESTED LOOPS
TABLE ACCESS FULL ARTISTE
TABLE ACCESS BY ROWID JOUE
INDEX RANGE SCAN JOUE_ARTISTE
TABLE ACCESS BY ROWID FILM
INDEX UNIQUE SCAN FILM_IDX

-- (c) 3ème cas: un index sur FILM(ID − F ilm), et un sur JOUE(ID − F ilm)
SELECT STATEMENT
MERGE JOIN
SORT JOIN
NESTED LOOPS
TABLE ACCESS FULL JOUE
TABLE ACCESS BY ROWID FILM
INDEX UNIQUE SCAN FILM_IDX

SORT JOIN
TABLE ACCESS FULL ARTISTE

-- • Analysez les PEP retourné par Oracle en répondant aux questions suivantes:
-- – Pour le 1er cas (a), le parcours séquentiel est fait sur quelle(s) table(s)? Quel(s)
-- index sont utilisés pour la jointure? Avec quel autre table on aurait pu faire
-- le parcours séquentiel? L’index sur ID − realisateur est-il utilisable pour la
-- jointure? Pourquoi?
-- – Pour le 2ème cas (b), pourquoi la table (ARTISTE) est elle choisi pour effectuer
-- le parcours séquentiel initial dans la jointure?
-- – Pour le 3ème cas (c), les index existant ont servi à la jointure entre quelles tables?
-- Pourrait on inverser l’ordre dans cette jointure? Quel algorithme est utilisé pour
-- la seconde jointure?
-- • Pour chacun des cas (a), (b) et (c):
-- – Donnez le PEP (sous forme arborescente) correspondant au plan retourné par
-- Oracle, en l’annotant par les algorithmes de jointure et les méthodes d’accès aux
-- tables utilisés