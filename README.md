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
Il semblerait que l'on n'utilise pas l'index sur client car pour un petite table ce n'est pas rentable. En effet, quand on utilise explain analyse, on se rend compte que la table tient sur **une seule page**. Ainsi, parcourir l'index ne ferait que parcourir des blocs suplementaires et donc irait plus lentment.

b) Pour faire simple, cela revient à un index scan sur cli_id = 5
```bash
Bitmap Heap Scan on occupation  (cost=4.19..12.66 rows=5 width=38) (actual time=0.018..0.019 rows=0 loops=1)
  Recheck Cond: (cli_id = 5)
  ->  Bitmap Index Scan on idx_occupation_cli_id  (cost=0.00..4.19 rows=5 width=0) (actual time=0.005..0.006 rows=0 loops=1)
        Index Cond: (cli_id = 5)
Planning Time: 0.498 ms
Execution Time: 0.053 ms
```

c) index scan sur occupation(jour):
```bash
Bitmap Heap Scan on occupation  (cost=4.19..12.66 rows=5 width=4) (actual time=0.021..0.022 rows=0 loops=1)
  Recheck Cond: ((jour)::text = '1999-01-22'::text)
  ->  Bitmap Index Scan on idx_occupation_jour  (cost=0.00..4.19 rows=5 width=0) (actual time=0.009..0.010 rows=0 loops=1)
        Index Cond: ((jour)::text = '1999-01-22'::text)
Planning Time: 0.189 ms
Execution Time: 0.058 ms
```
d) hash, hash join et index scan à droite (plus rentable pour le cas d'une petite table, même argument que pour la a))
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

# Ex2

## 2.1 Initialisation
## 2.2 Plans d'execution

A; Cout tot + Temps exec
B; Nb tuples + taille en octets pour chacun
C; Nb bloc lu
D; Type d'accès
E; Algorithmes

### 1
```sql
SELECT *
FROM optimisation.produits;
```
```bash
Seq Scan on produits  (cost=0.00..14.00 rows=500 width=109) (actual time=0.023..0.148 rows=500 loops=1)
  Buffers: shared hit=9
Planning Time: 0.076 ms
Execution Time: 0.232 ms
```
A; Cout total : 14, Temps exec : 0.232ms
B; Nb tuples : 500, Taille en octets : 109
C; Nb blocs : 9
D; Sequentiel
E; -

### 2
```sql
SELECT NumP,NomP
FROM optimisation.produits;
```
```bash
Seq Scan on produits  (cost=0.00..14.00 rows=500 width=12) (actual time=0.027..0.201 rows=500 loops=1)
  Buffers: shared hit=9
Planning Time: 0.074 ms
Execution Time: 0.286 ms
```
A; Cout total : 14, Temps exec : 0.286ms
B; Nb tuples : 500, Taille en octets : 12
C; Nb blocs : 9
D; Sequentiel
E; -

### 3
```sql
SELECT distinct NumP,NomP
FROM optimisation.produits;
```
```bash
HashAggregate  (cost=16.50..21.50 rows=500 width=12) (actual time=0.623..0.830 rows=500 loops=1)
  Group Key: nump, nomp
  Batches: 1  Memory Usage: 73kB
  Buffers: shared hit=9
  ->  Seq Scan on produits  (cost=0.00..14.00 rows=500 width=12) (actual time=0.022..0.150 rows=500 loops=1)
        Buffers: shared hit=9
Planning:
  Buffers: shared hit=13
Planning Time: 0.204 ms
Execution Time: 0.945 ms
```
A; Cout total : 21.50, Temps exec : 0.945ms
B; Nb tuples : 500, Taille en octets : 12
C; Nb blocs : 9
D; Sequentiel
E; Table de hashage pour le distinct

### 4
```sql
SELECT distinct NumP,NomP
FROM optimisation.produits
ORDER BY NomP asc;
```
```bash
Unique  (cost=36.41..40.16 rows=500 width=12) (actual time=3.374..3.688 rows=500 loops=1)
  Buffers: shared hit=9
  ->  Sort  (cost=36.41..37.66 rows=500 width=12) (actual time=3.372..3.451 rows=500 loops=1)
        Sort Key: nomp, nump
        Sort Method: quicksort  Memory: 40kB
        Buffers: shared hit=9
        ->  Seq Scan on produits  (cost=0.00..14.00 rows=500 width=12) (actual time=0.028..0.263 rows=500 loops=1)
              Buffers: shared hit=9
Planning Time: 0.116 ms
Execution Time: 3.786 ms
```
A; Cout total : 40.16, Temps exec : 3.786ms
B; Nb tuples : 500, Taille en octets : 12
C; Nb blocs : 9
D; Sequentiel
E; Tri (quicksort) + Unique pour le order by

### 5
```sql
SELECT *
FROM optimisation.produits
where NomP='nomp_327'
```
```bash
Seq Scan on produits  (cost=0.00..15.25 rows=1 width=109) (actual time=0.186..0.187 rows=0 loops=1)
  Filter: ((nomp)::text = 'nomp_327'::text)
  Rows Removed by Filter: 500
  Buffers: shared hit=9
Planning Time: 0.189 ms
Execution Time: 0.210 ms
```
A; Cout total : 15.25, Temps exec : 0.210ms
B; Nb tuples : 0, Taille en octets : 109
C; Nb blocs : 9
D; Sequentiel
E; -

### 6
```sql
SELECT distinct co.NumC,COUNT(*) as nombre
FROM optimisation.commandes as co
GROUP BY co.NumC;
```
```bash
HashAggregate  (cost=72.23..77.10 rows=487 width=12) (actual time=2.230..2.432 rows=487 loops=1)
  Group Key: numc, count(*)
  Batches: 1  Memory Usage: 73kB
  Buffers: shared hit=35
  ->  HashAggregate  (cost=64.92..69.80 rows=487 width=12) (actual time=1.662..1.900 rows=487 loops=1)
        Group Key: numc
        Batches: 1  Memory Usage: 73kB
        Buffers: shared hit=35
        ->  Seq Scan on commandes co  (cost=0.00..54.95 rows=1995 width=4) (actual time=0.016..0.451 rows=1995 loops=1)
              Buffers: shared hit=35
Planning:
  Buffers: shared hit=31 dirtied=1
Planning Time: 0.405 ms
Execution Time: 2.589 ms
```
A; Cout total : 77.10, Temps exec : 2.589ms
B; Nb tuples : 487, Taille en octets : 12
C; Nb blocs : 35
D; Sequentiel
E; HashAggregate (group by + distinct + count, on utilise une table de hachage)

### 7
```sql
SELECT
    cl.NomC AS "nom du client",
    co.DateCom AS "date de la commande"
FROM
    optimisation.clients AS cl
INNER JOIN
    optimisation.commandes AS co
ON
    cl.NumC = co.NumC; 
```
```bash
Hash Join  (cost=20.25..80.48 rows=1995 width=12) (actual time=0.541..2.232 rows=1995 loops=1)
  Hash Cond: (co.numc = cl.numc)
  Buffers: shared hit=44
  ->  Seq Scan on commandes co  (cost=0.00..54.95 rows=1995 width=8) (actual time=0.018..0.429 rows=1995 loops=1)
        Buffers: shared hit=35
  ->  Hash  (cost=14.00..14.00 rows=500 width=12) (actual time=0.495..0.496 rows=500 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 32kB
        Buffers: shared hit=9
        ->  Seq Scan on clients cl  (cost=0.00..14.00 rows=500 width=12) (actual time=0.016..0.196 rows=500 loops=1)
              Buffers: shared hit=9
Planning:
  Buffers: shared hit=56 dirtied=3
Planning Time: 0.883 ms
Execution Time: 2.534 ms
```
A; Cout total : 80.48, Temps exec : 2.534ms
B; Nb tuples : 1995, Taille en octets : 12
C; Nb blocs : 44
D; Sequentiel 
E; Hash Join via table de hashage

On utilise finalement la table commande, seulement on n'utilise pas l'index dessus : en effet, l'index se trouve être (datecom, numc) ce qui le rend inutilisable pour un join sur numc.
Pour ce qui est de l'ordre, il faut voir du coté du nombre de lignes de chaque table, ce qui permet d'avoir un coût inferieur.

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
