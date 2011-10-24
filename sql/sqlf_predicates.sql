-- sqlf_predicates.sql


/*
Prise en compte de l'intégration de prédicats flous en format dans la clause WHERE de la requête. 
ex. : SELECT * FROM employe WHERE jeune(age);

Prise en compte la définition de prédicats flous à l'aide de l'opérateur ~= qui représente l'opérareur is.
Ex. : SELECT * FROM employe WHERE age ~= 'jeune'
*/


/*
 Nom : ISf 
 calcule la valeur d'un prédicat pk(pk-1(...p1(att))) étant donnés : 
 - un attribut réel "att" ;
 - et une chaîne "funcs" représentant une séquence de fonctions 'p1 p2...pn'.

Arguments
- FLOAT att : valeur de l'attribut sur lequel le prédicat est appliqué.
- funcs VARCHAR : séquence 'p1 p2...pk' de token séparés par un espace. La séquence est convertie en un prédicats p1(p2..pn(att)...) qui est évalué comme un procédure PL/PGSQL.

Valeur de retour
- Nombre réel associé à la valeur du prédicat p1(p2(...pn(att)))

Description
 La fonction ISf traite une chaîne de caractères "funcs" qui représente une séquence 'p1 p2...pn'.
 Cette séquence est convertie en 'p1(p2(...pn(att)))' pour être ensuite évaluée comme une procédure PL/PLSQL à l’aide de l’instruction EXECUTE.
 Cette conversion est illustrée par l'exemple suivant :
    isF(age, 'tres jeune') -> tres(jeune(age))

Ainsi les requêtes suivantes sont équivalentes :
- SELECT * FROM employes WHERE isF(age, 'tres jeune');
- SELECT * FROM employes WHERE tres(jeune(age));
*/

CREATE OR REPLACE FUNCTION ISf(att FLOAT, funcs VARCHAR) RETURNS FLOAT AS $$ 
  DECLARE
    tokens text[];
    len int;
    a record;
    sql text;
  BEGIN
    len = 0;
    -- tokenisation de la chaine 'funcs'
    tokens := string_to_array($2, ' ');
    sql := 'SELECT ';
    
    -- construction du prédicat avec chaque token.
    FOR i IN 1..array_upper(tokens, 1) LOOP
     sql := sql  || tokens[i] || '(';
     len := len +1 ;
    END LOOP;
    -- ajout de l'attribut et des parenthèses manquantes.
    sql := sql || att ||  repeat(')', len) || ' as val' ;
    --RAISE NOTICE '%', sql;
    -- évaluation de la chaîne sql
    FOR a IN EXECUTE sql LOOP
     return a.val;
    END LOOP;
  END
$$ LANGUAGE 'plpgsql' IMMUTABLE;




/* Nom : opérateur ~=
L'opérateur ~= est défini par la fonction ISf.

Arguments
- FLOAT att : Argument gauche qui désigne valeur de l'attribut sur lequel le prédicat est appliqué.
- funcs VARCHAR : argument droite qui représente une séquence 'p1 p2...pk' de token séparés par un espace. La séquence est convertie en un prédicats p1(p2..pn(att)...) qui est évalué comme un procédure PL/PGSQL.

Valeur de retour
 Nombre réel associée à la valeur de pk(pk-1(...p1(att)))

Description
L'opérateur ~= représente l'opérateur IS défini en SQLf.
Il permet de réaliser les conversions suivantes :
- age ~= 'jeune' -> isF(age, 'jeune') -> jeune(age)
- age ~= 'tres jeune' -> isF(age, 'tres jeune') -> tres(jeune(age))

On peut ainsi executer la requête suivante :
    SELECT * FROM employes WHERE age ~= 'tres jeune'; 
*/
CREATE OPERATOR ~= (LEFTARG = FLOAT, RIGHTARG = VARCHAR, PROCEDURE = isF);

CREATE OR REPLACE FUNCTION very(x FLOAT)
RETURNS FLOAT LANGUAGE SQL IMMUTABLE AS $$SELECT $1 * $1;$$;


/*
nom : FUNCTION trapezoidal_fuzzy_predicate
Prédicat flou décrit par une fonction trapezoïdale.

Aguments
  val FLOAT : 
  support1 FLOAT :
  core1 FLOAT :
  core2 FLOAT :
  support2 FLOAT :


Type de retour
  FLOAT
*/


CREATE OR REPLACE FUNCTION trapezoidal_fuzzy_predicate(val FLOAT, support1 FLOAT, core1 FLOAT, core2 FLOAT, support2 FLOAT)
RETURNS FLOAT LANGUAGE C STRICT AS '$libdir/sqlf', 'trapezoidal_fuzzy_predicate';
/*
CREATE OR REPLACE FUNCTION trapezoidalFuzzyPredicate(val real, support1 real, core1 real, core2 real, support2 real)
RETURNS real
AS $$
BEGIN
 IF (core1 is null) THEN
    IF (val <= core2) THEN
        RETURN 1;
    ELSE
        IF (val < support2) THEN
            RETURN (support2-val)/(support2-core2);
        ELSE
            RETURN 0;
        END IF;
    END IF;
 ELSE 
    IF (core2 is null) THEN
        IF (val >= core1) THEN
            RETURN 1;
        ELSE
            IF (val > support1) THEN
                RETURN (val-support1)/(core1-support1);
            ELSE
                RETURN 0;
            END IF;
        END IF;
    ELSE
        IF ((val >= core1) AND (val <= core2)) THEN
            RETURN 1;
        ELSE
            IF ((val > support1) AND (val < core1))THEN
                RETURN (val-support1)/(core1-support1);
            ELSE
                IF ((val < support2) AND (val > core2))THEN
                    RETURN (support2-val)/(support2-core2);
                ELSE
                    RETURN 0;
                END IF;
            END IF;
        END IF;
            
    END IF;
 END IF;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
*/



/*
nom : FUNCTION create_predicate

Fonction pour faciliter la création de prédicats flous décrit par une fonction trapezoïdale.

Aguments
  func_name FLOAT : nom du prédicat à définir.
  support1 FLOAT :
  core1 FLOAT :
  core2 FLOAT :
  support2 FLOAT :


Type de retour
  VOID
*/
CREATE OR REPLACE FUNCTION create_predicate(func_name TEXT, support1 FLOAT, core1 FLOAT, core2 FLOAT, support2 FLOAT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
output TEXT;
BEGIN
output:= 'CREATE OR REPLACE FUNCTION ' || func_name || '(val FLOAT) RETURNS FLOAT AS ''
	  SELECT trapezoidal_fuzzy_predicate($1, '||support1||','||core1||',' ||core2||',' ||support2||');''
	  LANGUAGE SQL;';
EXECUTE output;
RETURN;
END;
$$;



