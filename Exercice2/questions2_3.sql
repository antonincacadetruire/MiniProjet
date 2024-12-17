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
"QUERY PLAN":"Index Scan using commandes_pkey on commandes  (cost=0.28..8.30 rows=1 width=105)"
"QUERY PLAN":"  Index Cond: ((datecom = '2020-09-17'::date) AND (numc = 10))"

-- • Requête-2:
"QUERY PLAN":"Index Scan using commandes_pkey on commandes  (cost=0.28..8.29 rows=1 width=105)"
"QUERY PLAN":"  Index Cond: (datecom = '2020-09-17'::date)"

-- • Requête-3:
"QUERY PLAN":"Seq Scan on commandes  (cost=0.00..59.95 rows=3 width=105)"
"QUERY PLAN":"  Filter: (numc = 10)"

-- (b) Observez l’utilisation de l’index de clé primaires, et trouvez dans la documentation
-- de PostgreSQL à quoi correspondent les chemins d’accès

-- Index Scan:

-- Utilisation d'un index pour récupérer les lignes dans un ordre spécifique.
-- Peut être utilisé pour des requêtes avec des conditions de filtrage sur des colonnes indexées.
-- et
-- Sequential Scan (Seq Scan):

-- Lecture séquentielle de toutes les lignes de la table.
-- Utilisé lorsque la table est petite ou lorsque l'index n'est pas disponible ou efficace.

-- (c) Dessinez ce plan sous forme arborescente en utilisant la syntaxe vue en cours
-- En conclusion de cette question, que faire si dans les requêtes sur la relation “commande”,
-- la recherche par numéro de client est beaucoup plus fréquente que la recherche par date
-- de commande ?
-- Il faut créer un deuxième index sur numéro de client

à faire

-- 3. Soit la requête ReqA suivante
-- --ReqA - - Noms de produits command és par les clients qui portent le nom : 'nomc_1287 '- -
Select nomp
from optimisation.produits p
join optimisation.concerne co using ( nump )
join optimisation.clients c using ( numc )
where nomc ='nomc_1287';
-- (a) Donnez le plan d’exécution PEP retourné par PostgreSQL
"QUERY PLAN":"Nested Loop  (cost=24.54..135.83 rows=12 width=8)"
"QUERY PLAN":"  ->  Hash Join  (cost=24.26..132.17 rows=12 width=4)"
"QUERY PLAN":"        Hash Cond: (co.numc = c.numc)"
"QUERY PLAN":"        ->  Seq Scan on concerne co  (cost=0.00..92.23 rows=5923 width=8)"
"QUERY PLAN":"        ->  Hash  (cost=24.25..24.25 rows=1 width=4)"
"QUERY PLAN":"              ->  Seq Scan on clients c  (cost=0.00..24.25 rows=1 width=4)"
"QUERY PLAN":"                    Filter: ((nomc)::text = 'nomc_1287'::text)"
"QUERY PLAN":"  ->  Index Scan using produits_pkey on produits p  (cost=0.27..0.30 rows=1 width=12)"
"QUERY PLAN":"        Index Cond: (nump = co.nump)"

-- (b) Dessinez ce plan sous forme arborescente en utilisant la syntaxe vue en cours, et en
-- annotant avec les algorithmes et méthodes d’accès aux tables

à faire

-- (c) Optimisez par deux index la requête ReqA. N’oubliez pas de reporter les commandes de
-- création de vos index dans votre rapport
-- Reférez vous à la documentation de PostgreSQL et à la syntaxe suivante pour créer des
-- index
-- create index ... ;
-- create index ... ;

à faire

-- (d) Donnez le plan d’exécution PEP retourné par PostgreSQL après la création des index et
-- comparer avec le plan précédent
-- A la fin de cette question, supprimez les index crées (Reférez vous à la documentation de
-- PostgreSQL)

à faire

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

-- 5. Soit la requête suivante, qui est souvent utilisée pour éviter de manquer des recherches pour
-- un problème de casse.
-- -- Recherche et affichage des clients avec passage en majuscules
select upper ( nomc ) , adressec
from clients
where upper ( nomc )='nomc_1287';
-- (a) Donnez le plan d’exécution de cette requête en utilisant cette syntaxe:
-- Explain analyse
-- equ ê te à expliciter >
-- (b) Dessinez ce plan PEP sous forme arborescente (syntaxe vu en cours) en l’annotant et
-- expliquez-le
-- (c) Suggérez l’ajout d’un index pour optimiser la requête. N’oubliez pas de reportez la
-- commande de création de votre index dans votre rapport
-- (d) Redonnez le PEP correspondant après la création de votre index et expliquez
-- A la fin de cette question, supprimez les index crées (Reférez vous à la documentation de
-- PostgreSQL)

-- 6. Soit maintenant la requête suivante
-- SELECT COUNT (*)
-- FROM commandes
-- WHERE EXTRACT ( YEAR FROM datecom ) = 2017;
-- (a) Donnez le plan d’exécution de cette requête en utilisant la syntaxe:
-- Explain analyse
-- requête à expliciter >
-- (b) Dessinez ce plan PEP sous forme arborescente (syntaxe vu en cours) en l’annotant et
-- expliquez-le en indiquant notamment les chemins d’accès aux tables et les algorithmes
--.. .
-- (c) La clé primaire est-elle utilisée ? Pourquoi ?
-- (d) Plutôt que de créer un nouvel index couteux, proposez une ré-écriture de la requête qui
-- utilisera l’index existant via la clé primaire.