-- operators.sql

/*
Prise en compte des conjonctions et disjonctions de prédicats booléens et flous. 
Ex : SELECT * FROM employe WHERE age ~= 'jeune' && (dept = 'finance' || salary ~= 'high'
*/



/*
Les scores retournés par chaque condition floue ou booléenne sont combinés suivant
l'expression fournie dans la clause where. Notons que d'un point de vue théorique, la sémantique des  opérateurs  and et  or sont définis dans la logique floue  comme des  normes et  co-normes. Comme le montre la requête suivante, nous les avons fait correspondre aux opérateurs SQL  && et ||, utilisables comme alternatives aux AND et OR classiques :

SELECT * FROM employes WHERE age ~= ‘jeune’ && salaire ~= ‘eleve’;
L’emploi d’éléments de type boolean avec && et || engendre une conversion implicite vers des nombres flottants vers des booléen à l’aide d’un opérateur de CAST qui appelle la procédure bool2fuzzy(BOOLEAN) .

SELECT * FROM employes WHERE age ~= ‘jeune’ && salaire > 25000;

Par ailleurs, les opérateurs && et || sont associés aux fonctions C fuzzy_and_operator et fuz-zy_or_operator qui réalisent le calcul de la norme/co-norme.
Paramétrage de la norme
Les fonctions C fuzzy_and_operator et fuzzy_or_operator  effectuent le calcul des normes/co-normes selon la valeur de la variable C « char * norm ». 
Elle peut prendre les valeurs ‘zadeh’, ‘probabiliste’, ‘lukasiewicz’ et ‘weber’ et peut être paramétrée à l’aide de set_norm(n) dans la clause FROM d’une requête SQL : 
Le calcul des différentes normes est implémenté en langage C, comme par exemple pour la disjonction probabiliste :

  float8 or_probabiliste(float8 a, float8 b){
      return a + b - a * b;
  }

*/


CREATE OR REPLACE FUNCTION fuzzy_or_operator(FLOAT, FLOAT) RETURNS FLOAT LANGUAGE C STRICT AS 
'$libdir/sqlf', 'fuzzy_or_operator';

CREATE OR REPLACE FUNCTION fuzzy_and_operator(FLOAT, FLOAT) RETURNS FLOAT LANGUAGE C STRICT AS 
'$libdir/sqlf', 'fuzzy_and_operator';

CREATE OR REPLACE FUNCTION fuzzy_not_operator(FLOAT) RETURNS FLOAT LANGUAGE C STRICT AS 
'$libdir/sqlf', 'fuzzy_not_operator';



CREATE OPERATOR && (LEFTARG = FLOAT, RIGHTARG = FLOAT, PROCEDURE = fuzzy_and_operator);
CREATE OPERATOR || (LEFTARG = FLOAT, RIGHTARG = FLOAT, PROCEDURE = fuzzy_or_operator);
CREATE OPERATOR ! (RIGHTARG = FLOAT, PROCEDURE = fuzzy_not_operator);