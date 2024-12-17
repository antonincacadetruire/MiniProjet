# MiniProjet

TESTS : https://sqliteonline.com/

# Ex1
## 1
### q3, 4
**Le nom et prénom du client numéro 5**
```sql
SELECT cli_nom, cli_prenom FROM client WHERE cli_id = 5;
```
Accès sequentiel sur client puis selection sur cli_id

**Les jours où le client numéro 5 a occupé une chambre**
```sql 
SELECT jour FROM occupation WHERE cli_id = 5;
```
Accès sequentiel sur occupation puis selection sur cli_id

**Les chambres occupées le 1999-01-22**
```sql 
SELECT chb_id FROM occupation WHERE jour = '1999-01-22';
```
Accès sequentiel sur occupation puis selection sur jour

**Le nom et prénom des clients ayant pris une chambre le 1999-01-22**
```sql 
SELECT cli_nom, cli_prenom FROM occupation o, client cl WHERE 
    cl.cli_id = o.cli_id AND jour = '1999-01-22';
```
```bash
Hash Join  (cost=3.25..364.68 rows=11 width=15) (actual time=0.219..3.324 rows=11 loops=1)
  Hash Cond: (o.cli_id = cl.cli_id)
  ->  Seq Scan on occupation o  (cost=0.00..361.27 rows=11 width=4) (actual time=0.082..3.173 rows=11 loops=1)
        Filter: ((jour)::text = '1999-01-22'::text)
        Rows Removed by Filter: 18171
  ->  Hash  (cost=2.00..2.00 rows=100 width=19) (actual time=0.090..0.090 rows=100 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 14kB
        ->  Seq Scan on client cl  (cost=0.00..2.00 rows=100 width=19) (actual time=0.038..0.052 rows=100 loops=1)

Planning Time: 1.262 ms
Execution Time: 3.402 ms
```

Accès sequentiel sur client pour construire une table de hashage, accès sequentiel sur occupation et filtrage sur jour, puis jointure avec un hash-join entre la table de hashage et les occupations filtrées.
![image](./Exercice1/PELex1.drawio.png)

## 2
### q1
```sql
CREATE UNIQUE INDEX idx_client_cli_id ON client(cli_id);
CREATE INDEX idx_occupation_cli_id ON occupation(cli_id);
CREATE INDEX idx_occupation_jour ON occupation(jour);
```

$
\pi_{a.Nom,f.Titre}(\rho_{Artiste\to a})
$