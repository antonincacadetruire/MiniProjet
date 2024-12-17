-- 3. Exprimez les requêtes suivantes dans la fenêtre d’exécution et exécutez les.

-- (a) Le nom et prénom du client numéro 5
SELECT cli_nom, cli_prenom FROM client WHERE cli_id = 5;

-- (b) Les jours o`u le client numéro 5 a occupé une chambre
SELECT jour FROM occupation WHERE cli_id = 5;

-- (c) Les chambres occupées le 1999-01-22
SELECT chb_id FROM occupation WHERE jour = '1999-01-22';

-- (d) Le nom et prénom des clients ayant pris une chambre le 1999-01-22
SELECT cli_nom, cli_prenom FROM occupation o, client cl WHERE 
    cl.cli_id = o.cli_id AND jour = '1999-01-22';

--4. Pour chacune des requêtes précédentes :
-- • Obtenez le plan d’exécution retourné par le SGBD
-- • Interprétez et expliquez à chaque fois le plan d’exécution proposé par le
-- système (types d’accès aux tables/index, types de jointure, coût du plan) (la
-- réponse doit être brève et concise)
-- • Dessinez ce plan sous forme arborescente en utilisant la syntaxe vue en cours