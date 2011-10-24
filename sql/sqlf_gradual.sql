-- gradual.sql
/* Lot 3 : Prise en compte d'opérateurs graduels (~, in~ ...) associés à des fonctions de distances
  ex. : ``SELECT * FROM employe WHERE age ~ 50;''
  ex. : ``SELECT * FROM employe WHERE dept in~ ('accounting', 'finance', 'R&D');''
*/


/*
Nom
closeness(a FLOAT, b FLOAT) RETURNS FLOAT

Description
  Calcule la proximité mu_#(a,b) = min(a,b)/max(a,b) entre deux élément flottants a et b.
  
Arguments
  a et b nombres flottants 

Type de retour
  Un nombre flottant proche de 1 si a et b sont proches et 0 sinon.
*/
CREATE OR REPLACE FUNCTION closeness(a FLOAT, b FLOAT) RETURNS FLOAT AS $$
BEGIN
if a > b 
THEN RETURN b / a; 
ELSE RETURN a / b;
END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;



/*
Nom : mu_in(att anyelement, recs anyarray)

Description
  Opérateur graduel qui renvoie la distance maximale calculée entre l'élément att et les éléments de recs.
  Par défault la distance choisie est la fonction closeness qui s'applique à des éléments de type FLOAT.
  Remarque : l'opérateur <~ fait appel à la fonction mu_in.
    SELECT * FROM mu_table WHERE att <~  ARRAY;
  Optimisation possible : recherche dichtomique de l'élément le plus proche dans le tableau.

Arguments
  att ANYELEMENT : élément pour lequel le type possède une distance définie.
  recs ANYARRAY : tableau dont les éléments sont de même type que att et pour lequels on cherche à calculer la distance avec att.

Type de retour
   maxval FLOAT : distance maximale calculée entre l'élément att et les éléments de recs.

Exemple
  SELECT * FROM v_employes WHERE mu_in(age::age, ARRAY[25.0, 35.0]::age[]);
  SELECT * FROM v_employes WHERE age::age <~  ARRAY[25.0, 35.0]::age[];
*/


CREATE OR REPLACE FUNCTION mu_in(att ANYNONARRAY, recs ANYARRAY)
RETURNS FLOAT 
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
maxval FLOAT := 0;
tmp FLOAT := 0;
BEGIN
    FOR i IN 1..array_upper(recs, 1) LOOP
     tmp := distance(att, recs[i]);
     -- mise à jour de l'élément correspondant à la distance maximale.
     IF tmp > maxval 
     THEN maxval := tmp;
     END IF;
     END LOOP;
RETURN maxval;
END;
$$;


CREATE OPERATOR ~ (LEFTARG = FLOAT, RIGHTARG = FLOAT, PROCEDURE = closeness);
CREATE OPERATOR <~ (LEFTARG = ANYNONARRAY, RIGHTARG = ANYARRAY, PROCEDURE = mu_in);



/* Lot 4 : Requêtes imbriquées

L'opérateur SQL in permet de tester l'appartenance d'une valeur dans une relation  résultant de l'exécution d'une requête imbriquée. 
Cet opérateur est ici étendu pour tester l'appartenance d'une valeur à une relation floue. 
L'opérateur inF doit être associé à une mesure de distance sur le domaine de définition de l'attribut concerné (nodep dans l'exemple ci-dessous). 
Comme précédemment, des types et des opérateur de CAST sont employées pour déclarer la mesure de distance à utiliser. 
Cet mesure correspond à une fonction pl/pgsql, C ou pl/python prenant deux paramètres sur lesquels la distance doit être calculée et retourne une distance sur l'intervalle unité.
*/


/*
Nom : mu_in_f(att anyelement, recs anyarray)

Description
  Opérateur pour tester l'appartenance d'une valeur à une relation floue (sous-requête flexible) :
    µ_{in_f}(a,E)= sup_{b \in support(E)} (min(distance(a,b),µ_E(b))) 
  Ce test renvoie la distance maximale calculée entre l'élément att et les éléments de la requête flexible imbriquée sql_query en fonction du degré de satisfaction des tuples de sql_query.
  Par défault la distance choisie est la fonction closeness qui s'applique à des éléments de type FLOAT.
  Remarque : l'opérateur <~~ fait appel à la fonction mu_in_f.
    SELECT * FROM mu_table WHERE att <~~ subquery;

Arguments 
  att ANYELEMENT : élément pour lequel une distance est définie. 
		   Le type de att doit être spécifié au préalable (e.g. att::age) et doit comporter les propriétés 'value' et 'mu'.

  sql_query ANYARRAY : tableau contenant les résultats d'une requête imbriquée flexible.
		       cette sous requête doit être de type :
			SELECT mu_table.att::typeX FROM mu_table WHERE conditions_floues;
	      Où :
	      - mu_table est une table sur laquelle on effectue une requête floue qui enregistre le degré de satisfaction mu.
	      - mu_table.att est un attribut pour lequel on doit spécifier le même type que pour att.
    
Type de retour
   maxval FLOAT : distance maximale calculée entre l'élément att et les éléments de la sous requête imbriquée.

Exemple
  SELECT * FROM v_employes WHERE mu_in_f(age::age, array(SELECT age::age FROM employes WHERE age =~ `jeune`));
  SELECT * FROM v_employes WHERE age::age <~~ ARRAY(SELECT age::age FROM employes WHERE age =~ `jeune`));
  
  Optimisation : comment éviter le stockage de la requête imbriquée dans un array ?
*/

CREATE OR REPLACE FUNCTION mu_in_f(att ANYNONARRAY, recs ANYARRAY)
RETURNS FLOAT 
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
maxval FLOAT := 0;
dist FLOAT := 0;
BEGIN
    FOR i IN 1..array_upper(recs, 1) LOOP
     dist := distance(att, recs[i]);
     IF recs[i].mu < dist
     THEN dist := recs[i].mu; 
     END IF;
     -- mise à jour de l'élément correspondant à la distance maximale.
     IF dist > maxval 
     THEN maxval := dist;
     END IF;
     END LOOP;
RETURN maxval;
END;
$$;

CREATE OPERATOR <~~ (LEFTARG = ANYNONARRAY, RIGHTARG = ANYARRAY, PROCEDURE = mu_in_f);
