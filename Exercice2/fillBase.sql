drop procedure if exists rempli_tables;

create procedure rempli_tables (nbtuples integer) as $ $ declare k integer;

un_numP integer;

compt integer;

une_date date;

curs_com cursor for
select
    DateCom,
    numc
from
    optimisation.commandes;

begin
INSERT INTO
    optimisation.clients (numc, nomc, adressec)
SELECT
    g,
    'nomc_ ' ||((random () * nbtuples * 4 / 5) :: integer) :: varchar,
    md5 (g :: text) || md5 ((2 * g) :: text) || md5 ((3 * g) :: text)
FROM
    generate_series (0, nbtuples -1) as g;

INSERT INTO
    optimisation.produits (nump, nomp, descriptif)
SELECT
    g,
    'nomp_ ' ||((random () * nbtuples * 4 / 5) :: integer) :: varchar,
    md5 (g :: text) || md5 ((2 * g) :: text) || md5 ((3 * g) :: text)
FROM
    generate_series (0, nbtuples -1) as g;

for g in 1..4 *(nbtuples -1) loop une_date = CURRENT_TIMESTAMP - ((random () * 3650) :: integer || 'day ') :: interval;

un_nump =(random () *(nbtuples -1)) :: integer;

insert into
    optimisation.commandes (DateCom, numc, commentaire)
select
    une_date,
    un_nump,
    md5 (g :: text) || md5 ((2 * g) :: text) || md5 ((3 * g) :: text) on conflict do nothing;

end loop;

for t in curs_com loop k =(random () * 6) :: integer;

for i in 1..k loop un_numP = (random () *(nbtuples -1)) :: integer;

insert into
    optimisation.concerne (NumP, datecom, numc, quantite)
values
    (
        un_nump,
        t.Datecom,
        t.numc,
        (random () * 100) :: integer
    ) on conflict do nothing;

if i > 3 then une_date = t.datecom +((random () * 30) :: integer || '
days ') :: interval;

insert into
    optimisation.livraisons (DateLiv, DateCom, numC, prestataire)
values
    (
        une_date,
        t.datecom,
        t.numc,
        'prest ' ||((random () * 20) :: integer) :: varchar
    ) on conflict do nothing;

end if;

end loop;

end loop;

end;

$ $ language plpgsql;

do $ $ begin call rempli_tables (500);

end $ $;