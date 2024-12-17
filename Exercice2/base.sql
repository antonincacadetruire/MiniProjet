drop schema if exists optimisation cascade;

create schema optimisation;

set search_path to optimisation;

-- drop table if exists clients cascade ;
create unlogged table clients (
    NumC integer primary key,
    NomC varchar (35),
    AdresseC text
);

-- drop table if exists produits cascade ;
create unlogged table produits (
    NumP integer primary key,
    NomP varchar (35),
    descriptif text
);

-- drop table if exists commandes cascade ;
create unlogged table commandes (
    DateCom date,
    NumC integer,
    Commentaire text,
    primary key (DateCom, NumC)
);

-- drop table if exists livraisons ;
create unlogged table livraisons (
    DateLiv date,
    DateCom date,
    NumC Integer,
    Prestataire varchar,
    primary key (DateLiv, DateCom, NumC)
);

-- drop table if exists Concerne ;
create unlogged table concerne (
    NumP integer,
    DateCom date,
    NumC integer,
    Quantite integer,
    primary key (NumP, DateCom, NumC)
);