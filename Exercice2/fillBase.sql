DROP PROCEDURE IF EXISTS rempli_tables;

CREATE PROCEDURE rempli_tables (nbtuples INTEGER) AS $$
DECLARE
    k INTEGER;
    un_numP INTEGER;
    compt INTEGER;
    une_date TIMESTAMPTZ;
    curs_com CURSOR FOR
        SELECT DateCom, numc FROM optimisation.commandes;
BEGIN
    -- Insert into clients table
    INSERT INTO optimisation.clients (numc, nomc, adressec)
    SELECT
        g,
        'nomc_' || (random() * nbtuples * 4 / 5)::INTEGER::VARCHAR,
        md5(g::TEXT) || md5((2 * g)::TEXT) || md5((3 * g)::TEXT)
    FROM generate_series(0, nbtuples - 1) AS g;

    -- Insert into produits table
    INSERT INTO optimisation.produits (nump, nomp, descriptif)
    SELECT
        g,
        'nomp_' || (random() * nbtuples * 4 / 5)::INTEGER::VARCHAR,
        md5(g::TEXT) || md5((2 * g)::TEXT) || md5((3 * g)::TEXT)
    FROM generate_series(0, nbtuples - 1) AS g;

    -- Insert into commandes table
    FOR g IN 1..4 * (nbtuples - 1) LOOP
        une_date := CURRENT_TIMESTAMP - (random() * 3650) * interval '1 day';
        un_numP := (random() * (nbtuples - 1))::INTEGER;

        INSERT INTO optimisation.commandes (DateCom, numc, commentaire)
        VALUES (une_date, un_numP, md5(g::TEXT) || md5((2 * g)::TEXT) || md5((3 * g)::TEXT))
        ON CONFLICT DO NOTHING;
    END LOOP;

    -- Insert into concerne and livraisons tables
    OPEN curs_com;
    LOOP
        FETCH curs_com INTO une_date, un_numP;
        EXIT WHEN NOT FOUND;

        k := (random() * 6)::INTEGER;
        FOR i IN 1..k LOOP
            un_numP := (random() * (nbtuples - 1))::INTEGER;

            INSERT INTO optimisation.concerne (NumP, datecom, numc, quantite)
            VALUES (un_numP, une_date, un_numP, (random() * 100)::INTEGER)
            ON CONFLICT DO NOTHING;

            IF i > 3 THEN
                une_date := une_date + (random() * 30) * interval '1 day';

                INSERT INTO optimisation.livraisons (DateLiv, DateCom, numC, prestataire)
                VALUES (une_date, une_date, un_numP, 'prest ' || (random() * 20)::INTEGER::VARCHAR)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END LOOP;
    CLOSE curs_com;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    CALL rempli_tables(500);
END $$;
