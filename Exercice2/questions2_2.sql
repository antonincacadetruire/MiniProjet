-- Pour chacune des requêtes (REQi) ci-dessous, rédigez une requête SQL qui répond à la question,
-- et demandez à PostgreSQL une analyse de la requête en vous aidant de la synthaxe suivante:
-- EXPLAIN ( analyse , buffers )
-- select ...
-- from ...
-- etc ...
-- La commande EXPLAIN a pour effet de vous afficher le plan d’exécution choisi par l’optimiseur
-- de requêtes. L’option “analyse” entre parenthèses va entrainer l’exécution effective de la requête,
-- ce qui permet de comparer le coût du plan avec le temps réel, ainsi que le nombre réel de tuples
-- générés à chaque étape. Enfin, “buffers” permet d’afficher le nombre de blocs lus, soit dans la
-- mémoire cache (shared hits) soit sur le disque (shared read).

-- • Pour chaque requête (REQi) effectuée, faites des observations et des analyses dans votre
-- rapport (et en commentaire dans votre fichier sql) en vous aidant des critères suivants:
-- ,→ Le coût total estimé pour le plan d’exécution et le temps réel de l’exécution
-- ,→ Le nombre de tuples estimé en sortie et la taille en octets de chaque tuple
-- ,→ Le nombre de blocs lus
-- ,→ L’accès utilisés vers les tables
-- ,→ Les algorithmes utilisés


-- 1. (REQ1) Listez toutes les informations sur les produits

SELECT *
FROM optimisation.produits;

------------------------------------------------------------------------------------

-- 2. (REQ2) Listez le numéro et le nom de tous les produits
SELECT NumP,NomP
FROM optimisation.produits;

------------------------------------------------------------------------------------

-- 3. (REQ3) Idem, en ajoutant la clause ”distinct”
SELECT distinct NumP,NomP
FROM optimisation.produits;

------------------------------------------------------------------------------------

-- 4. (REQ4) Même question en ordonnant le résultat selon le nom des produits
SELECT distinct NumP,NomP
FROM optimisation.produits
ORDER BY NomP asc;

------------------------------------------------------------------------------------

-- 5. (REQ5) Listez les produits dont le nom est ’nomp_327’
SELECT *
FROM optimisation.produits
where NomP='nomp_327'

------------------------------------------------------------------------------------

-- 6. (REQ6) Donnez le nombre de commandes par client (numc, nombre)
SELECT distinct cl.NumC,COUNT(*) as nombre
FROM optimisation.clients as cl,optimisation.commandes as co
WHERE cl.NumC = co.NumC
GROUP BY cl.NumC;

------------------------------------------------------------------------------------

-- 7. (REQ7) Donnez les infos sur chaque commande, sous la forme (’nom du client’, ’date de la
-- commande’). Quelle est la méthode de jointure utilisée ? Pourquoi les relations sont elles
-- considérées dans cet ordre dans le plan d’exécution ? Pourquoi la table commande n’est pas
-- utilisée en fait ? Vous pouvez écrire différentes variations syntaxiques de la jointure pour
-- observer ce qui se passe
SELECT
    cl.NomC AS "nom du client",
    co.DateCom AS "date de la commande"
FROM
    optimisation.clients AS cl
INNER JOIN
    optimisation.commandes AS co
ON
    cl.NumC = co.NumC; 

------------------------------------------------------------------------------------

-- On souhaite mantenant afficher les produits commandés par les clients. Soit la requête (REQ8)
-- suivante:
explain -- Attention , pas de mot clé " analyse " ici car la requ ê te ne termine pas !
select distinct nomc , nomp
from optimisation.clients , optimisation.concerne , optimisation.produits , optimisation.commandes ,
optimisation.livraisons
where optimisation.clients.numc = optimisation.commandes.numc
and optimisation.commandes.datecom = optimisation.concerne.datecom
and optimisation.commandes.numc = optimisation.concerne.numc
and optimisation.produits.nump = optimisation.concerne.nump

------------------------------------------------------------------------------------

-- 8. Etudiez le plan d’exécution de la requête (REQ8), observez le coût et le volume de tuples
-- attendu, commentez

-- "QUERY PLAN":"HashAggregate  (cost=96619.68..97457.22 rows=83754 width=16)"
-- "QUERY PLAN":"  Group Key: clients.nomc, produits.nomp"
-- "QUERY PLAN":"  ->  Merge Join  (cost=553.53..52759.87 rows=8771963 width=16)"
-- "QUERY PLAN":"        Merge Cond: ((commandes.datecom = concerne.datecom) AND (commandes.numc = clients.numc))"
-- "QUERY PLAN":"        ->  Nested Loop  (cost=0.28..37049.68 rows=2956076 width=8)"
-- "QUERY PLAN":"              ->  Index Only Scan using commandes_pkey on commandes  (cost=0.28..70.22 rows=1996 width=8)"
-- "QUERY PLAN":"              ->  Materialize  (cost=0.00..32.22 rows=1481 width=0)"
-- "QUERY PLAN":"                    ->  Seq Scan on livraisons  (cost=0.00..24.81 rows=1481 width=0)"
-- "QUERY PLAN":"        ->  Sort  (cost=553.23..568.04 rows=5923 width=28)"
-- "QUERY PLAN":"              Sort Key: concerne.datecom, clients.numc"
-- "QUERY PLAN":"              ->  Hash Join  (cost=58.50..182.09 rows=5923 width=28)"
-- "QUERY PLAN":"                    Hash Cond: (concerne.nump = produits.nump)"
-- "QUERY PLAN":"                    ->  Hash Join  (cost=29.25..137.16 rows=5923 width=24)"
-- "QUERY PLAN":"                          Hash Cond: (concerne.numc = clients.numc)"
-- "QUERY PLAN":"                          ->  Seq Scan on concerne  (cost=0.00..92.23 rows=5923 width=12)"
-- "QUERY PLAN":"                          ->  Hash  (cost=23.00..23.00 rows=500 width=12)"
-- "QUERY PLAN":"                                ->  Seq Scan on clients  (cost=0.00..23.00 rows=500 width=12)"
-- "QUERY PLAN":"                    ->  Hash  (cost=23.00..23.00 rows=500 width=12)"
-- "QUERY PLAN":"                          ->  Seq Scan on produits  (cost=0.00..23.00 rows=500 width=12)"

-- On remarque que les coûts les plus importants sont le HashAggregate (c'est à dire ce qui fait office de distinct) 
-- et le Merge Join, ainsi que la Nested Loop.
-- Vu qu'on fait un grand join sur l'ensemble des tables, et qu'on y adjoint L'ENSEMBLE des livraisons, 
-- on est amené à traiter beaucoup de lignes
-- Ainsi, 
-- Ce qui peut paraître étonnant est que la requête HashAggregate ne manipule que 83754 rows, mais est plus longue que
-- le Merge JOIN qui en manipule 100 fois plus.