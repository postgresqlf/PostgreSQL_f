-- employes.sql


DROP TABLE IF EXISTS employes CASCADE;

CREATE TABLE employes
(
  id integer NOT NULL,
  nom character varying(30) NOT NULL,
  age real,
  salaire real,
  departement character varying(30) NOT NULL,
  ville character varying(30) NOT NULL,
  CONSTRAINT employes_pkey PRIMARY KEY (id)
);


INSERT INTO employes VALUES (1, 'Spongebob', 16 , 10000, 'restauration', 'Bikini Bottom');
INSERT INTO employes VALUES (2, 'Bernard Madoff',  31, 7500, 'compta', 'Prison de New York');
INSERT INTO employes VALUES (3, 'Homer Simpson',  38,  35000, 'energie', 'Springfield');
INSERT INTO employes VALUES (4, 'Mr Krabs',  58,  135000, 'direction', 'Bikini Bottom');
INSERT INTO employes VALUES (5, 'Lady Gaga',  24,  235000,  'divertissement', 'Londres');
INSERT INTO employes VALUES (6, 'Laure Manaudou',  26,  50000,  'sport', 'Aqualand');
INSERT INTO employes VALUES (7, 'Igor Bogdanoff',  34,  35000, 'r&d', 'Lune');
INSERT INTO employes VALUES (8, 'JC Vandamme',  41,  22000, 'securité', 'Mons');
INSERT INTO employes VALUES (9, 'Michael Vandetta',  21,  15000,  'divertissement', 'St Tropez');
INSERT INTO employes VALUES (10, 'Walker Texas Ranger',  45,  100000, 'securité', 'Confidentiel');
INSERT INTO employes VALUES (11, 'Pascal Brutal',  26,  20000,  'securité', 'Rennes');
INSERT INTO employes VALUES (12, 'Georges Abitbol',  45,  45000,  'logistique', 'Brest');

CREATE OR REPLACE FUNCTION jeune(salaire real)
RETURNS real AS $$
SELECT trapezoidalFuzzyPredicate($1::real, null, null, 20::real, 30::real);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION eleve(salaire real)
RETURNS real AS $$
SELECT trapezoidalFuzzyPredicate($1::real, 20000::real, 50000::real, null, null);
$$ LANGUAGE SQL;



CREATE OR REPLACE VIEW v_employes AS
    SELECT *, get_mu() as mu
    FROM employes
    ORDER BY mu DESC;
--    LIMIT get_k();



/*
Utilisation de types spécifiques à chaque colonne pour spécifier les fonctions de distnce à employer.

Une fonction distance dont le calcul dépend du type des arguments.

Besoin d'un opérateur de cast 
- pour la conversion explicite et implicite de FLOAT vers AGE.



opérateur de CAST Pour spécifier la distance à utiliser
-- encapsule un attribut flottant dans un type pour lequel une distance est définie. 
-- L’opérateur « :: » est alors employé pour spécifier le type d’un élément. Voici un exemple de définitions relatives au type age :

Nous pouvons ensuite définir des fonctions distance spécifiques à chaque type. Dans le cas du type age, la distance peut être représentée comme une fonction trapézoïdale ou triangulaire. Par exemple, pour  distance(age ::age,  50 ::age), on pourrait avoir :
	µ=1 si age == 50 ;  µ= 0.9 si age == 45 ou age == 55 ; µ=0.8 si age == 40 ou age == 60.
*/

DROP TYPE age cascade;
CREATE TYPE age AS (value float, mu float);

CREATE OR REPLACE FUNCTION age(float) RETURNS age AS 
'SELECT ROW($1,get_mu())::age;' 
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION age(numeric) RETURNS age AS 
'SELECT ROW($1::float, get_mu())::age;' 
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION distance(age, age) RETURNS FLOAT AS 
'SELECT trapezoidalFuzzyPredicate($1.value::real, ($2.value - 50.0)::real, $2.value::real, $2.value::real, ($2.value + 50.0)::real)::float;'
LANGUAGE SQL IMMUTABLE;

CREATE CAST (FLOAT AS age) WITH FUNCTION age(float);
CREATE CAST (NUMERIC AS age) WITH FUNCTION age(NUMERIC);
CREATE CAST (REAL AS age) WITH FUNCTION age(REAL);


CREATE OPERATOR ~ (LEFTARG = age, RIGHTARG = age, PROCEDURE = distance);





-- tests.sql

SELECT * FROM v_employes WHERE age ~= 'jeune';


SELECT * FROM v_employes WHERE age ~= 'jeune' && salaire ~= 'eleve';


SELECT * FROM v_employes WHERE age ~= 'jeune' || salaire ~= 'eleve';


--  id |         nom         | age | salaire |  departement   |     ville     |    mu     
-- ----+---------------------+-----+---------+----------------+---------------+-----------
--  10 | Walker Texas Ranger |  45 |  100000 | securité       | Confidentiel  |         1
--   5 | Lady Gaga           |  24 |  235000 | divertissement | Londres       |         1
--   6 | Laure Manaudou      |  26 |   50000 | sport          | Aqualand      |         1
--   4 | Mr Krabs            |  58 |  135000 | direction      | Bikini Bottom |         1
--  12 | Georges Abitbol     |  45 |   45000 | logistique     | Brest         |  0.833333
--   7 | Igor Bogdanoff      |  34 |   35000 | r&d            | Lune          |       0.5
--   3 | Homer Simpson       |  38 |   35000 | energie        | Springfield   |       0.5
--   8 | JC Vandamme         |  41 |   22000 | securité       | Mons          | 0.0666667
-- (8 rows)


SELECT * FROM employe WHERE age ~= jeune AND (departement = 'divertissement' || salary ~= 'eleve');


-- t1 : J=0.5 ; F=1 ; E=0.2 ; M=0.4 ; I=0.6
-- t2 : J=0.1 ; F=1 ; E=0.5 ; M=0 ; I=0.1

SELECT zadeh(0.5, 1.0, 0.2, 0.4, 0.6);
-- 0.2916
SELECT zadeh(0.1, 1.0 , 0.5, 0.0, 0.1);
--  0.1156
SELECT cta(0.5, 1.0, 0.2, 0.4, 0.6);
-- 0.4
SELECT cta(0.1, 1.0 , 0.5, 0.0, 0.1);
-- 0.16
SELECT owa(0.5, 1.0, 0.2, 0.4, 0.6);
--  0.396
SELECT owa(0.1, 1.0 , 0.5, 0.0, 0.1);
-- 0.148

SELECT * FROM v_employes WHERE zadeh(age ~= 'jeune', salaire ~= 'eleve');
SELECT * FROM v_employes WHERE cta(age ~= 'jeune', salaire ~= 'eleve');
SELECT * FROM v_employes WHERE owa(age ~= 'jeune', salaire ~= 'eleve');

SELECT set_quantifier('zadeh');
SELECT * FROM v_employes WHERE la_plupart(age ~= 'jeune', salaire ~= 'eleve');




-- probleme avec set/get_quantifier et set/get_norme


