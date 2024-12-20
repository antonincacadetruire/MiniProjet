SELECT
    tablename,
    indexname,
    indexdef 
FROM pg_indexes 
WHERE schemaname = 'optimisation' 
ORDER BY tablename,
    indexname;

-- 1. Soient les trois requêtes suivantes :
-- 2. NB : les valeurs 109000 de numC et 2020-03-31 de datecom sont un exemple à suivre. Ces
-- valeurs, étant été générée aléatoirement par le script donné précedemment, les valeurs dans
-- votre base seront différentes. C’est à vous de choisir ces valeurs de telle sorte à ce que les
-- requêtes qui suivent vous donnent des résultats.
-- • Requête-1:
Select *
from optimisation.commandes
where numC = 10
and datecom ='2020-09-17';
-- • Requête-2:
Select *
from optimisation.commandes
where datecom ='2020-09-17';
-- • Requête-3:
Select *
from optimisation.commandes
where numC =10;

-- Pour chacune des trois requêtes
-- (a) Donnez le plan d’exécution PEP retourné par PostgreSQL

-- • Requête-1:
-- "QUERY PLAN":"Index Scan using commandes_pkey on commandes  (cost=0.28..8.30 rows=1 width=105)"
-- "QUERY PLAN":"  Index Cond: ((datecom = '2020-09-17'::date) AND (numc = 10))"

-- • Requête-2:
-- "QUERY PLAN":"Index Scan using commandes_pkey on commandes  (cost=0.28..8.29 rows=1 width=105)"
-- "QUERY PLAN":"  Index Cond: (datecom = '2020-09-17'::date)"

-- • Requête-3:
-- "QUERY PLAN":"Seq Scan on commandes  (cost=0.00..59.95 rows=3 width=105)"
-- "QUERY PLAN":"  Filter: (numc = 10)"

------------------------------------------------------------------------------------

-- (b) Observez l’utilisation de l’index de clé primaires, et trouvez dans la documentation
-- de PostgreSQL à quoi correspondent les chemins d’accès

-- Chemins d'accès dans PostgreSQL :
-- Les chemins d'accès (ou "access methods") dans PostgreSQL définissent comment les données sont stockées et accédées. Voici quelques types de chemins d'accès courants :

-- Heap (Tas) :
-- Le chemin d'accès par défaut pour les tables ordinaires. Les données sont stockées sans ordre particulier.

-- B-tree (Arbre B) :
-- Utilisé pour les index, y compris les index de clé primaire. Permet des recherches, des insertions, des suppressions et des accès séquentiels efficaces.

-- Hash :
-- Utilisé pour les index basés sur des tables de hachage. Efficace pour les recherches d'égalité.

-- GiST (Generalized Search Tree) :
-- Un cadre extensible pour les index qui peut être utilisé pour des types de données complexes comme les géométries.

-- GIN (Generalized Inverted Index) :
-- Utilisé pour les index inversés, souvent pour les recherches de texte intégral.

-- BRIN (Block Range INdex) :
-- Utilisé pour les index sur des colonnes où les valeurs sont physiquement proches les unes des autres.

------------------------------------------------------------------------------------

-- (c) Dessinez ce plan sous forme arborescente en utilisant la syntaxe vue en cours
-- En conclusion de cette question, que faire si dans les requêtes sur la relation “commande”,
-- la recherche par numéro de client est beaucoup plus fréquente que la recherche par date
-- de commande ?

-- Il faut créer un deuxième index sur numéro de client

-- fait, voir questions2_3_2_c

------------------------------------------------------------------------------------

-- 3. Soit la requête ReqA suivante
-- --ReqA - - Noms de produits command és par les clients qui portent le nom : 'nomc_1287 '- -
Select nomp
from optimisation.produits p
join optimisation.concerne co using ( nump )
join optimisation.clients c using ( numc )
where nomc ='nomc_1287';

-- (a) Donnez le plan d’exécution PEP retourné par PostgreSQL

-- "QUERY PLAN":"Nested Loop  (cost=24.54..135.83 rows=12 width=8)"
-- "QUERY PLAN":"  ->  Hash Join  (cost=24.26..132.17 rows=12 width=4)"
-- "QUERY PLAN":"        Hash Cond: (co.numc = c.numc)"
-- "QUERY PLAN":"        ->  Seq Scan on concerne co  (cost=0.00..92.23 rows=5923 width=8)"
-- "QUERY PLAN":"        ->  Hash  (cost=24.25..24.25 rows=1 width=4)"
-- "QUERY PLAN":"              ->  Seq Scan on clients c  (cost=0.00..24.25 rows=1 width=4)"
-- "QUERY PLAN":"                    Filter: ((nomc)::text = 'nomc_1287'::text)"
-- "QUERY PLAN":"  ->  Index Scan using produits_pkey on produits p  (cost=0.27..0.30 rows=1 width=12)"
-- "QUERY PLAN":"        Index Cond: (nump = co.nump)"

------------------------------------------------------------------------------------

-- (b) Dessinez ce plan sous forme arborescente en utilisant la syntaxe vue en cours, et en
-- annotant avec les algorithmes et méthodes d’accès aux tables

-- voir questions2_3_3_b.drawio.png

------------------------------------------------------------------------------------

-- (c) Optimisez par deux index la requête ReqA. N’oubliez pas de reporter les commandes de
-- création de vos index dans votre rapport
-- Reférez vous à la documentation de PostgreSQL et à la syntaxe suivante pour créer des
-- index
-- create index ... ;
-- create index ... ;

CREATE INDEX clients_nomc on optimisation.clients (nomc);
CREATE INDEX concerne_nomc on optimisation.concerne (numc);

------------------------------------------------------------------------------------

-- (d) Donnez le plan d’exécution PEP retourné par PostgreSQL après la création des index et
-- comparer avec le plan précédent
-- A la fin de cette question, supprimez les index crées (Reférez vous à la documentation de
-- PostgreSQL)

-- Nested Loop  (cost=4.92..41.47 rows=12 width=8)
--   ->  Nested Loop  (cost=4.65..37.88 rows=12 width=4)
--         ->  Index Scan using clients_nomc on clients c  (cost=0.27..8.29 rows=1 width=4)
--               Index Cond: ((nomc)::text = 'nomc_1287'::text)
--         ->  Bitmap Heap Scan on concerne co  (cost=4.38..29.47 rows=12 width=8)
--               Recheck Cond: (numc = c.numc)
--               ->  Bitmap Index Scan on concerne_nomc  (cost=0.00..4.37 rows=12 width=0)
--                     Index Cond: (numc = c.numc)
--   ->  Index Scan using produits_pkey on produits p  (cost=0.27..0.30 rows=1 width=12)
--         Index Cond: (nump = co.nump)

DROP INDEX optimisation.clients_nomc;
DROP INDEX optimisation.concerne_nomc;

------------------------------------------------------------------------------------

-- 4. Comparer les plans d’exécution des requêtes ci-dessous
-- • Requête-A:
Select numc
from optimisation.clients
where numc not in
( select numc from optimisation.livraisons );
-- • Requête-B:
Select numc
from optimisation.clients
except
select numc
from optimisation.livraisons ;
-- • Requête-C:
Select numc
from optimisation.clients
where not exists
( select numc from optimisation.livraisons
where optimisation.livraisons.numc = optimisation.clients.numc );

------------------------------------------------------------------------------------

-- 5. Soit la requête suivante, qui est souvent utilisée pour éviter de manquer des recherches pour
-- un problème de casse.
-- Recherche et affichage des clients avec passage en majuscules
select upper ( NomC ) , adressec
from optimisation.clients
where upper ( NomC )='NOMC_206';
-- (a) Donnez le plan d’exécution de cette requête en utilisant cette syntaxe:
-- Explain analyse


-- "QUERY PLAN":"Seq Scan on clients  (cost=0.00..25.50 rows=2 width=129) (actual time=0.551..0.552 rows=0 loops=1)"
-- "QUERY PLAN":"  Filter: (upper((nomc)::text) = 'nomc_1287'::text)"
-- "QUERY PLAN":"  Rows Removed by Filter: 500"
-- "QUERY PLAN":"Planning Time: 1.040 ms"
-- "QUERY PLAN":"Execution Time: 0.585 ms"
-- requête à expliciter >

-- à faire

------------------------------------------------------------------------------------

-- (b) Dessinez ce plan PEP sous forme arborescente (syntaxe vu en cours) en l’annotant et
-- expliquez-le

-- Voir questions2_3_5_b

------------------------------------------------------------------------------------

-- (c) Suggérez l’ajout d’un index pour optimiser la requête. N’oubliez pas de reportez la
-- commande de création de votre index dans votre rapport

CREATE INDEX clients_nomc ON optimisation.clients (upper(nomc));



------------------------------------------------------------------------------------

-- (d) Redonnez le PEP correspondant après la création de votre index et expliquez
-- A la fin de cette question, supprimez les index crées (Reférez vous à la documentation de
-- PostgreSQL)

-- "QUERY PLAN":"Bitmap Heap Scan on clients  (cost=4.29..9.49 rows=2 width=129)"
-- "QUERY PLAN":"  Recheck Cond: (upper((nomc)::text) = 'NOMC_206'::text)"
-- "QUERY PLAN":"  ->  Bitmap Index Scan on clients_nomc  (cost=0.00..4.29 rows=2 width=0)"
-- "QUERY PLAN":"        Index Cond: (upper((nomc)::text) = 'NOMC_206'::text)"

-- Le plan de requête montre que l'index clients_nomc est utilisé efficacement pour filtrer les lignes basées sur la colonne nomc.
-- L'index est un index fonctionnel sur la version majuscule de la colonne nomc, ce qui améliore les performances des requêtes qui filtrent sur la version majuscule de la colonne.

------------------------------------------------------------------------------------

-- 6. Soit maintenant la requête suivante
SELECT COUNT (*)
FROM optimisation.commandes
WHERE EXTRACT ( YEAR FROM datecom ) = 2017;
-- (a) Donnez le plan d’exécution de cette requête en utilisant la syntaxe:
-- Explain analyse

-- "QUERY PLAN":"Aggregate  (cost=64.97..64.98 rows=1 width=8) (actual time=0.872..0.873 rows=1 loops=1)"
-- "QUERY PLAN":"  ->  Seq Scan on commandes  (cost=0.00..64.94 rows=10 width=0) (actual time=0.042..0.854 rows=201 loops=1)"
-- "QUERY PLAN":"        Filter: (EXTRACT(year FROM datecom) = '2017'::numeric)"
-- "QUERY PLAN":"        Rows Removed by Filter: 1795"
-- "QUERY PLAN":"Planning Time: 1.085 ms"
-- "QUERY PLAN":"Execution Time: 0.938 ms"
-- requête à expliciter >

------------------------------------------------------------------------------------

-- (b) Dessinez ce plan PEP sous forme arborescente (syntaxe vu en cours) en l’annotant et
-- expliquez-le en indiquant notamment les chemins d’accès aux tables et les algorithmes

-- Voir questions2_3_6_b.drawio.png

------------------------------------------------------------------------------------

-- (c) La clé primaire est-elle utilisée ? Pourquoi ?

-- non, car il y a d'abord une extraction de celle-ci puis un retraitement.

------------------------------------------------------------------------------------

-- (d) Plutôt que de créer un nouvel index couteux, proposez une ré-écriture de la requête qui
-- utilisera l’index existant via la clé primaire.

SELECT COUNT(*)
FROM optimisation.commandes
WHERE datecom > '12-31-2016' AND datecom < '01-01-2018';