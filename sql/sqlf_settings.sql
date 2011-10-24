-- settings.sql

/*
 Modification et accès à des variables globales (alpha, k, norme, quantifier).

 Les fonctions set_var(val) doivent être employées dans la clause FROM.
 L'emploi dans la clause SELECT pose problème car les fonctions qui y sont executées ne sont évaluées une fois que la clause WHERE est évaluée. 
 Il serait donc nécessaire d'executer deux fois la requête pour avoir la bonne valeur à affecter pour la variable.
 De manière alternative, on peut écrire : 
 SELECT set_alpha(0.5) ; SELECT * FROM employes WHERE age IS jeune;
 SELECT * FROM employes, set_alpha(0.5) WHERE age IS jeune;


  En vue d’une optimisation, le stockage des variables a été ré-implémenté en C pour remplacer dictionnaire global Python (GD) dont l'utilisation pouvait engendrer une surconsomation de mémoire.
  Deux niveaux de définition sont nécessaires pour faire correspondre les fonctions C et leur appel en PG/PLSQL.
  Par exemple, la fonction set_alpha est définie en langage C (fichier « sqlf.c »)  de la manière suivante :
    Datum set_alpha(PG_FUNCTION_ARGS){
	ALPHA = PG_GETARG_FLOAT8(0);
	PG_RETURN_FLOAT8(ALPHA);
    }
    PG_FUNCTION_INFO_V1(set_alpha);

  Cette fonction est appelée par la procédure PL/PGSQL correspondante:
    CREATE OR REPLACE FUNCTION set_alpha(alpha FLOAT) RETURNS FLOAT
    AS '$libdir/sqlf', 'set_alpha'
    LANGUAGE C STRICT;
*/



/*
Paramétrage de la norme pour la prise en compte des modifications dynamiques de la t-norme et de la t-conorme.
Normes implémentées : zadeh, probabiliste, lukasiewich, weber.
ex. : SELECT set_norme('probabiliste');

Les fonctions C fuzzy_and_operator et fuzzy_or_operator  effectuent le calcul des normes/co-normes selon la valeur de la variable C « char * norm ». 
Elle peut prendre les valeurs ‘zadeh’, ‘probabiliste’, ‘lukasiewicz’ et ‘weber’ et peut être paramétrée à l’aide de set_norm(n) dans la clause FROM d’une requête SQL : 

  SELECT * FROM set_norm(‘probabiliste’), employes 
  WHERE fuzzy_and_operator(age ~= ‘jeune’, salaire ~= ‘eleve’);

  De manière alternative, on aussi peut écrire :
  SELECT set_norm(‘probabiliste’) ; 
  SELECT * FROM employes WHERE fuzzy_and_operator(age ~= ‘jeune’, salaire ~= ‘eleve’);
*/

CREATE OR REPLACE FUNCTION set_norme(TEXT)
RETURNS TEXT
LANGUAGE C STRICT AS
'$libdir/sqlf', 'set_norm';

CREATE OR REPLACE FUNCTION get_norme()
RETURNS TEXT
LANGUAGE C STRICT AS 
'$libdir/sqlf', 'get_norm';


/*
Propositions quantifiées :
Prise en compte des modifications dynamiques de la méthode de calcul de la proposition quantifiées (Zadeh ou Owa de Yager).
ex. : SELECT set_quantifier('zadeh');
*/

CREATE OR REPLACE FUNCTION set_quantifier(TEXT)
RETURNS TEXT
LANGUAGE C STRICT AS 
'$libdir/sqlf', 'set_quantifier';

CREATE OR REPLACE FUNCTION get_quantifier()
RETURNS TEXT
LANGUAGE C STRICT AS
'$libdir/sqlf', 'get_quantifier';


/*
Prise en compte des seuils quantitatifs et qualitatifs dans la définition de la requête. 
*/


/* 
Le seuil quantitatif K permet de limiter le nombre de résultats retournés
*/
CREATE OR REPLACE FUNCTION set_k(INTEGER)
RETURNS INTEGER 
LANGUAGE C STRICT
AS '$libdir/sqlf', 'set_k';

CREATE OR REPLACE FUNCTION get_k()
RETURNS INTEGER 
LANGUAGE C STRICT
AS '$libdir/sqlf', 'get_k';


/*
Le seuil qualitatif ALPHA de filtrer les résultats peu satisfaisants, 
c'est à dire dont le degré de satisfaction MU > ALPHA. 
*/
CREATE OR REPLACE FUNCTION get_alpha()
RETURNS FLOAT
LANGUAGE C STRICT
AS '$libdir/sqlf', 'get_alpha';

CREATE OR REPLACE FUNCTION set_alpha(FLOAT)
RETURNS FLOAT
LANGUAGE C STRICT
AS '$libdir/sqlf', 'set_alpha';


CREATE OR REPLACE FUNCTION set_mu(FLOAT)
RETURNS FLOAT
LANGUAGE C STRICT
AS '$libdir/sqlf', 'set_mu';

CREATE OR REPLACE FUNCTION get_mu()
RETURNS FLOAT
LANGUAGE C STRICT
AS '$libdir/sqlf', 'get_mu';
