-- Nous allons maintenant regarder de près quelques plans de l’optimiseur du SGBD Oracle (sans les
-- exécuter).
-- Soit le schéma suivant :
CREATE TABLE Artiste (
    ID-artiste NUMBER (4),
    Nom VARCHAR2 (32),
    Adresse VARCHAR2 (32)
);

CREATE TABLE Film (
    ID-film NUMBER (4),
    Titre VARCHAR2 (32),
    Année NUMBER (4),
    ID-réalisateur NUMBER (4)
);

CREATE TABLE Joue (
    ID-artiste NUMBER (4), 
    ID-film NUMBER (4)
);

-- 1. Donner l’ordre SQL pour la requête : Afficher le nom des acteurs et le titre des films où ils
-- ont joué

SELECT a.Nom,f.Titre
FROM Artiste as a, Film as f, Joue as j
WHERE f.ID-film = j.ID-film
AND J.ID-artiste = a.ID-artiste

-- 2. Donner l’expression algébrique correspondante (PEL)


-- 3. Dans chacun des cas suivants, le plan d’exécution PEP routourné par Oracle vous est donné
-- (a) 1er cas : il n’existe que deux index, un sur FILM(ID−realisateur), et un sur ARTISTE(ID−
-- artiste)

--      SELECT STATEMENT
--          MERGE JOIN
--              SORT JOIN
--                  NESTED LOOPS
--                      TABLE ACCESS FULL JOUE
--                      TABLE ACCESS BY ROWID ARTISTE
--                          INDEX UNIQUE SCAN ARTISTE_IDX
--              SORT JOIN
--                  TABLE ACCESS FULL FILM
    
-- (b) 2ème cas: un index sur FILM(ID − F ilm), et un sur JOUE(ID − Artiste)

--      SELECT STATEMENT
--          NESTED LOOPS
--              NESTED LOOPS
--                  TABLE ACCESS FULL ARTISTE
--                  TABLE ACCESS BY ROWID JOUE
--                      INDEX RANGE SCAN JOUE_ARTISTE
--              TABLE ACCESS BY ROWID FILM
--                  INDEX UNIQUE SCAN FILM_IDX

-- (c) 3`eme cas: un index sur FILM(ID −Film), et un sur JOUE(ID −Film)

--      SELECT STATEMENT
--          MERGE JOIN
--              SORT JOIN
--                  NESTED LOOPS
--                      TABLE ACCESS FULL JOUE
--                      TABLE ACCESS BY ROWID FILM
--                          INDEX UNIQUE SCAN FILM_IDX
--              SORT JOIN
--                  TABLE ACCESS FULL ARTISTE
    
-- • Analysez les PEP retourné par Oracle en répondant aux questions suivantes:
-- – Pour le 1er cas (a), le parcours séquentiel est fait sur quelle(s) table(s)? Quel(s)
-- index sont utilisés pour la jointure? Avec quel autre table on aurait pu faire
-- le parcours séquentiel? L’index sur ID − realisateur est-il utilisable pour la
-- jointure? Pourquoi?


-- le parcours séquentiel est fait sur les tables FILM et JOUE
-- Pour la jointure les index
-- L'index ID-realisateur n'est pas utilisable ici car on cherche avant à faire une jointure sur Joue, et pas directement  sur Artiste
-- Ce n'est donc âs possible d'utiliser ID-Realisateur ici

-- – Pour le 2ème cas (b), pourquoi la table (ARTISTE) est elle choisie pour effectuer
-- le parcours séquentiel initial dans la jointure?

-- Car cette fois-ci c'est Joue qui a l'index sur ID Artiste, ce qui permet directement d'identifier les acteurs parmi 
-- les artistes.

-- – Pour le 3ème cas (c), les index existant ont servi à la jointure entre quelles tables?
-- Pourrait on inverser l’ordre dans cette jointure? Quel algorithme est utilisé pour
-- la seconde jointure?

-- Ils ont servis à la jointure entre FILM et JOUE. On pourrait inverser en effet l'ordre dans cette jointure sans impacter le
-- résultat de la boucle.
-- L'algorithme utilisé pour la deuxième jointure est le Tri-Fusion

-- • Pour chacun des cas (a), (b) et (c):
-- – Donnez le PEP (sous forme arborescente) correspondant au plan retourné par
-- Oracle, en l’annotant par les algorithmes de jointure et les méthodes d’accès aux
-- tables utilisés

-- fait