-- Nous allons maintenant regarder de pr`es quelques plans de l’optimiseur du SGBD Oracle (sans les
-- ex ́ecuter).
-- Soit le sch ́ema suivant :
CREATE TABLE Artiste (
ID - artiste NUMBER (4) ,
Nom VARCHAR2 (32) ,
Adresse VARCHAR2 (32) ) ;
CREATE TABLE Film (
ID - film NUMBER (4) ,
Titre VARCHAR2 (32) ,
Ann  ́ee NUMBER (4) ,
ID - r ́e alisateur NUMBER (4) );
CREATE TABLE Joue (
ID - artiste NUMBER (4) ,
ID - film NUMBER (4) );
-- 1. Donner l’ordre SQL pour la requˆete : Afficher le nom des acteurs et le titre des films o`u ils
-- ont jou ́e
-- 2. Donner l’expression alg ́ebrique correspondante (PEL)
-- 3. Dans chacun des cas suivants, le plan d’ex ́ecution PEP routourn ́e par Oracle vous est donn ́e
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

-- (b) 2`eme cas: un index sur FILM(ID − F ilm), et un sur JOUE(ID − Artiste)
SELECT STATEMENT
NESTED LOOPS
NESTED LOOPS
TABLE ACCESS FULL ARTISTE
TABLE ACCESS BY ROWID JOUE
INDEX RANGE SCAN JOUE_ARTISTE
TABLE ACCESS BY ROWID FILM
INDEX UNIQUE SCAN FILM_IDX

-- (c) 3`eme cas: un index sur FILM(ID − F ilm), et un sur JOUE(ID − F ilm)
SELECT STATEMENT
MERGE JOIN
SORT JOIN
NESTED LOOPS
TABLE ACCESS FULL JOUE
TABLE ACCESS BY ROWID FILM
INDEX UNIQUE SCAN FILM_IDX

SORT JOIN
TABLE ACCESS FULL ARTISTE

-- • Analysez les PEP retourn ́e par Oracle en r ́epondant aux questions suivantes:
-- – Pour le 1er cas (a), le parcours s ́equentiel est fait sur quelle(s) table(s)? Quel(s)
-- index sont utilis ́es pour la jointure? Avec quel autre table on aurait pu faire
-- le parcours s ́equentiel? L’index sur ID − realisateur est-il utilisable pour la
-- jointure? Pourquoi?
-- – Pour le 2`eme cas (b), pourquoi la table (ARTISTE) est elle choisi pour effectuer
-- le parcours s ́equentiel initial dans la jointure?
-- – Pour le 3`eme cas (c), les index existant ont servi `a la jointure entre quelles tables?
-- Pourrait on inverser l’ordre dans cette jointure? Quel algorithme est utilis ́e pour
-- la seconde jointure?
-- • Pour chacun des cas (a), (b) et (c):
-- – Donnez le PEP (sous forme arborescente) correspondant au plan retourn ́e par
-- Oracle, en l’annotant par les algorithmes de jointure et les m ́ethodes d’acc`es aux
-- tables utilis ́es