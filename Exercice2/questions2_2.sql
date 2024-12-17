-- Pour chacune des requêtes (REQi) ci-dessous, rédigez une requête SQL qui répond à la question,
-- et demandez à PostgreSQL une analyse de la requête en vous aidant de la synthaxe suivante:
-- EXPLAIN ( analyse , buffers )
-- select ...
-- from ...
-- etc ...
-- La commande EXP LAIN a pour effet de vous afficher le plan d’exécution choisi par l’optimiseur
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


-- 2. (REQ2) Listez le numéro et le nom de tous les produits


-- 3. (REQ3) Idem, en ajoutant la clause ”distinct”


-- 4. (REQ4) Même question en ordonnant le résultat selon le nom des produits


-- 5. (REQ5) Listez les produits dont le nom est ’nomp 327’


-- 6. (REQ6) Donnez le nombre de commandes par client (numc, nombre)


-- 7. (REQ7) Donnez les infos sur chaque commande, sous la forme (’nom du client’, ’date de la
-- commande’). Quelle est la méthode de jointure utilisée ? Pourquoi les relations sont elles
-- considérées dans cet ordre dans le plan d’exécution ? Pourquoi la table commande n’est pas
-- utilisée en fait ? Vous pouvez écrire différentes variations syntaxiques de la jointure pour
-- observer ce qui se passe
-- On souhaite mantenant afficher les produits commandés par les clients. Soit la requête (REQ8)
-- suivante:
-- -- - - - - - - - REQ8 - - - - - - - - - - - - - - - - -
-- explain -- Attention , pas de mot clé " analyse " ici car la requ ^e te ne termine pas !
-- select distinct nomc , nomp
-- from optimisation . clients , optimisation . concerne , optimisation . produits , optimisation . commandes ,
-- optimisation . livraisons
-- where optimisation . clients . numc = optimisation . commandes . numc
-- and optimisation . commandes . datecom = optimisation . concerne . datecom
-- and optimisation . commandes . numc = optimisation . concerne . numc
-- and optimisation . produits . nump = optimisation . concerne . nump


-- 8. Etudiez le plan d’exécution de la requête (REQ8), observez le coût et le volume de tuples
-- attendu, commentez