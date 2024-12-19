# MiniProjet

TESTS : https://sqliteonline.com/

# Ex1
## 1.1
### q3, 4
**Le nom et prénom du client numéro 5**
```sql
SELECT cli_nom, cli_prenom FROM client WHERE cli_id = 5;
```
```bash
Seq Scan on client  (cost=0.00..12.88 rows=1 width=156)
  Filter: (cli_id = 5)
```
Accès sequentiel sur client puis selection sur cli_id

**Les jours où le client numéro 5 a occupé une chambre**
```sql 
SELECT jour FROM occupation WHERE cli_id = 5;
```
```bash
Seq Scan on occupation  (cost=0.00..22.38 rows=5 width=38)
  Filter: (cli_id = 5)
```
Accès sequentiel sur occupation puis selection sur cli_id

**Les chambres occupées le 1999-01-22**
```sql 
SELECT chb_id FROM occupation WHERE jour = '1999-01-22';
```
```bash
Seq Scan on occupation  (cost=0.00..22.38 rows=5 width=4)
  Filter: ((jour)::text = '1999-01-22'::text)
```
Accès sequentiel sur occupation puis selection sur jour

**Le nom et prénom des clients ayant pris une chambre le 1999-01-22**
```sql 
SELECT cli_nom, cli_prenom FROM occupation o, client cl WHERE 
    cl.cli_id = o.cli_id AND jour = '1999-01-22';
```
```bash
Hash Join  (cost=22.44..35.66 rows=6 width=156) (actual time=0.029..0.031 rows=0 loops=1)
  Hash Cond: (cl.cli_id = o.cli_id)
  ->  Seq Scan on client cl  (cost=0.00..12.30 rows=230 width=160) (actual time=0.027..0.028 rows=0 loops=1)
  ->  Hash  (cost=22.38..22.38 rows=5 width=4) (never executed)
        ->  Seq Scan on occupation o  (cost=0.00..22.38 rows=5 width=4) (never executed)
              Filter: ((jour)::text = '1999-01-22'::text)
Planning Time: 0.167 ms
Execution Time: 0.106 ms
```

Accès sequentiel sur client, accès sequentiel sur occupation et filtrage sur jour avant de construire une table de hashage, puis jointure avec un hash-join entre la table de hashage et les clients.
![image](./Exercice1/PEPex1.drawio.png)

## 1.2
### q1
```sql
CREATE UNIQUE INDEX idx_client_cli_id ON client(cli_id);
CREATE INDEX idx_occupation_cli_id ON occupation(cli_id);
CREATE INDEX idx_occupation_jour ON occupation(jour);
```
### q2

a) Ne change pas :
```bash
Seq Scan on client  (cost=0.00..12.88 rows=1 width=156) (actual time=0.015..0.015 rows=0 loops=1)
  Filter: (cli_id = 5)
Planning Time: 0.082 ms
Execution Time: 0.042 ms
```
A priori, on n'utilise pas l'index car... ?

b) Pour faire simple, cela revient à un index scan sur cli_id = 5
```bash
Bitmap Heap Scan on occupation  (cost=4.19..12.66 rows=5 width=38) (actual time=0.018..0.019 rows=0 loops=1)
  Recheck Cond: (cli_id = 5)
  ->  Bitmap Index Scan on idx_occupation_cli_id  (cost=0.00..4.19 rows=5 width=0) (actual time=0.005..0.006 rows=0 loops=1)
        Index Cond: (cli_id = 5)
Planning Time: 0.498 ms
Execution Time: 0.053 ms
```

c) index scan :
```bash
Bitmap Heap Scan on occupation  (cost=4.19..12.66 rows=5 width=4) (actual time=0.021..0.022 rows=0 loops=1)
  Recheck Cond: ((jour)::text = '1999-01-22'::text)
  ->  Bitmap Index Scan on idx_occupation_jour  (cost=0.00..4.19 rows=5 width=0) (actual time=0.009..0.010 rows=0 loops=1)
        Index Cond: ((jour)::text = '1999-01-22'::text)
Planning Time: 0.189 ms
Execution Time: 0.058 ms
```
d) hash, hash join et index scan à droite (plus rentable pour le cas d'une petite table)
```bash
Hash Join  (cost=12.72..25.94 rows=5 width=156) (actual time=0.007..0.008 rows=0 loops=1)
  Hash Cond: (cl.cli_id = o.cli_id)
  ->  Seq Scan on client cl  (cost=0.00..12.30 rows=230 width=160) (actual time=0.006..0.006 rows=0 loops=1)
  ->  Hash  (cost=12.66..12.66 rows=5 width=4) (never executed)
        ->  Bitmap Heap Scan on occupation o  (cost=4.19..12.66 rows=5 width=4) (never executed)
              Recheck Cond: ((jour)::text = '1999-01-22'::text)
              ->  Bitmap Index Scan on idx_occupation_jour  (cost=0.00..4.19 rows=5 width=0) (never executed)
                    Index Cond: ((jour)::text = '1999-01-22'::text)
Planning Time: 0.169 ms
Execution Time: 0.034 ms
```

![image](./Exercice1/PEPex1.2.drawio.png)


# Ex3
## 3.2 Donner l’expression algébrique correspondante (PEL)
$
\pi_{a.Nom,f.Titre}((\rho_{Artiste\to a}(\sigma_{a.ID-artiste=j.ID-artiste})\rho_{Joue\to j})(\sigma_{j.ID-film=f.ID-film})\rho_{Film\to f})
$
```SQL
SELECT a.Nom,f.Titre
FROM Artiste as a, Film as f, Joue as j
WHERE f.ID-film = j.ID-film
AND J.ID-artiste = a.ID-artiste
```
