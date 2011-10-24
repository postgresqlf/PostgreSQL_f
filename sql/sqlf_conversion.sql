-- conversion.sql


/* ----------------------------------------------------------------------------------------
Fonctions de conversion utilisées par les opérateurs de cast.

FLOAT est le type utilisé pour la représentation du degré de satisfaction des prédicats flous.

- http://docs.postgresql.fr/9.1/sql-createcast.html
*/



/* 
Nom : fonction bool2fuzzy(BOOLEAN)
Description
Conversion d'une valeur booléene de la manière suivante :
- bool2fuzzy(TRUE)=1.0 et bool2fuzzy(FALSE)=0.0
Note : cette conversion est utilisée par l'opérateur CAST (BOOLEAN AS FLOAT).

Arguments
$1 BOOLEAN : valeur booléene à convertir en nombre flottant. 

Valeur de retour 
Nombre flottant issue de la conversion de l'argument booléen $1.
*/

CREATE OR REPLACE FUNCTION bool2fuzzy(BOOLEAN)
RETURNS FLOAT LANGUAGE SQL AS 'SELECT $1::int::FLOAT';

/*
Nom : CAST (BOOLEAN AS FLOAT)
Description 
Opérateur de cast implicite qui utilise la fonction de conversion bool2fuzzy(BOOLEAN).

--Cette conversion est nécessaire lorsque l'on souhaite appliquer une norme/conorme (opérateurs && et ||) entre un prédicat flou et un prédicat booléen.
Soit un prédicat booléen p, son degré de statisfaction MU est 1.0 ou 0.0 selon que le ce prédicat est vérifié (TRUE) ou non (FALSE).
Par exemple, pour p=(salaire > 25000), on obtient la transformation de requête suivante :
- SELECT * FROM employes WHERE age ~= 'jeune' && salaire > 25000;
- SELECT * FROM employes WHERE age ~= 'jeune' && (salaire > 25000)::BOOLEAN;
- SELECT * FROM employes WHERE age ~= 'jeune' && bool2fuzzy(salaire > 25000);

Argument
Un booléen à convertir en nombre flottant.

Type de retour
Un booléen déterminé par bool2fuzzy(BOOLEAN).
*/

CREATE CAST (BOOLEAN AS FLOAT) 
WITH FUNCTION bool2fuzzy(BOOLEAN) AS IMPLICIT;


/*
Nom : fuzzy2bool(FLOAT) RETURNS BOOLEAN

Description
Procédure pour convertir en booléen le degré de satisfaction MU d’un prédicat flou.
- SELECT * FROM employes WHERE fuzzy2bool(0.5);
- SELECT * FROM employes WHERE TRUE;

La degré de satisfaction MU associé au prédicat est stocké dans une variable C à l’aide de la fonction set_mu(FLOAT).
Seuls, les prédicats vérifiant (MU > get_alpha()) sont conservés (fitrage de type alpha-cut).


Argument :
MU : un degré de satisfaction (REAL ou FLOAT) MU à convertir en booléen.

Type de retour : 
Un booléene correspondant au test (MU > get_alpha()).
*/
CREATE OR REPLACE FUNCTION fuzzy2bool(FLOAT) RETURNS BOOLEAN LANGUAGE SQL AS 
'SELECT set_mu($1);SELECT $1 > get_alpha()';

CREATE OR REPLACE FUNCTION fuzzy2bool(REAL) RETURNS BOOLEAN LANGUAGE SQL AS 
'SELECT set_mu($1::FLOAT);SELECT $1 > get_alpha()'; 

/*
Nom : opérateur CAST (FLOAT AS BOOLEAN)

Descrition :
Conversion de FLOAT AS BOOLEAN avec la fonction fuzzy2bool(FLOAT).

L'appel de l'opérateur de CAST peut être explicite(f::BOOLEAN).
Dans le cas ou le type attendu est BOOLEAN la conversion de f est implicite.
Souligons que cette conversion implicite est employée juste avant l’évaluation d’un prédicat flou terminal dans la clause WHERE.
Voici un exemple de transformation d'une requête ayant pour condition floue (age ~= 'jeune') dont le comme degré de satisfaction est 0.5 : 
    SELECT * FROM employes WHERE age ~= 'jeune';
    SELECT * FROM employes WHERE 0.5;
    SELECT * FROM employes WHERE 0.5::BOOLEAN;
    SELECT * FROM employes WHERE fuzzy2bool(0.5);


Argument :
Une valeur réele f à convertir en booléen.

Type de retour : 
Une valeur booléene déterminée par fuzzy2bool(FLOAT).
*/
CREATE CAST (FLOAT AS BOOLEAN) WITH FUNCTION fuzzy2bool(FLOAT) AS IMPLICIT;
CREATE CAST (REAL AS BOOLEAN) WITH FUNCTION fuzzy2bool(REAL) AS IMPLICIT;



-- Conversion de REAL et NUMERIC vers FLOAT.
-- float2fuzzy(NUMERIC) RETURNS FLOAT
-- float2fuzzy(REAL) RETURNS FLOAT

CREATE OR REPLACE FUNCTION float2fuzzy(REAL) RETURNS FLOAT LANGUAGE SQL AS 
'SELECT $1::FLOAT';

--CREATE CAST (REAL AS FLOAT) WITH FUNCTION float2fuzzy(REAL) AS IMPLICIT;

CREATE OR REPLACE FUNCTION float2fuzzy(NUMERIC) RETURNS FLOAT LANGUAGE SQL AS 
'SELECT $1::FLOAT';

--CREATE CAST (NUMERIC AS FLOAT) WITH FUNCTION float2fuzzy(NUMERIC) AS IMPLICIT;

