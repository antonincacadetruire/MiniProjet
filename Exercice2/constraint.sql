alter table
    optimisation.commandes
add
    CONSTRAINT fk_commande_client foreign key (numc) references optimisation.clients (NumC) on delete cascade not valid;

alter table
    optimisation.livraisons
add
    constraint fk_livraison_commande foreign key (DateCom, NumC) references optimisation.commandes (DateCom, NumC) on delete cascade not valid;

alter table
    optimisation.concerne
add
    constraint fk_concerne_commande foreign key (DateCom, NumC) references optimisation.commandes (DateCom, NumC) on delete cascade not valid;

alter table
    optimisation.concerne
add
    constraint fk_concerne_produit foreign key (NumP) references optimisation.produits (NumP) not valid;

analyse optimisation.clients,
optimisation.commandes,
optimisation.produits,
optimisation.concerne,
optimisation.livraisons;

analyse verbose optimisation.clients,
optimisation.commandes,
optimisation.produits,
optimisation.concerne,
optimisation.livraisons;