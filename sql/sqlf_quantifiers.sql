-- quantifier.sql

/* Modifieurs et propositions quantifiées


Les quantificateurs flous sont un moyen de spécifier des conditions floues. 

Une proposition quantifiée floue peut être déclarée dans une requête à l’aide de l’opérateur « la_plupart » :

SELECT * FROM employe 
WHERE la_plupart(age is jeune, dept = 'finance',
  salaire is élevé, prime is moyenne,
  ancienne is importante);

Parmi les différentes interprétations possibles de ces quantificateurs, nous avons implémenté les méthodes de calcul Zadeh,  Yager-CTA et Yager-OWA.  
Le choix de la méthode de calcul est paramétrable dynamiquement à l’aide de la fonction set_quantifier(q) dans clause FROM (1) de la requête ou dans la clause SELECT d’une requête séparée (2).

1.	SELECT * FROM set_quantifier(‘owa’), employes 
WHERE proposition_quantifiee;
2.	SELECT set_quantifier(‘cta’); 
SELECT * FROM employes WHERE proposition_quantifiee;

La méthode de calcul choisie pour « la_plupart » repose sur la valeur de la variable C QUANTIFIER qui est accessible avec la fonction get_quantifier().
*/


/*
Nom
  la_plupart(VARIADIC arr FLOAT[]) RETURNS FLOAT

Argument
  VARIADIC arr FLOAT[]
Type de retour
  FLOAT

Description
  Une proposition quantifiée floue peut être déclarée dans une requête à l’aide de l’opérateur « la_plupart » :

  SELECT * FROM employe  WHERE la_plupart(age is jeune, dept = 'finance', salaire ~= élevé);


  Le choix de la méthode de calcul est paramétrable dynamiquement à l’aide de la fonction set_quantifier(q) dans clause FROM (1) de la requête ou dans la clause SELECT d’une requête séparée (2).
  1.	SELECT * FROM set_quantifier(‘owa’), employes 
  WHERE proposition_quantifiee;
  2.	SELECT set_quantifier(‘cta’); 
  SELECT * FROM employes WHERE proposition_quantifiee;
*/
/*
CREATE OR REPLACE FUNCTION la_plupart(VARIADIC arr FLOAT[]) RETURNS FLOAT AS $$
DECLARE
    row record;
BEGIN
FOR row in EXECUTE 'SELECT ' || get_quantifier() || '('||arr||') as res' loop
     RETURN row.res;
END LOOP;
END;
$$ LANGUAGE plpgsql;
*/


CREATE OR REPLACE FUNCTION la_plupart(VARIADIC arr FLOAT[]) RETURNS float AS $$
DECLARE
quantifier TEXT := get_quantifier();
BEGIN
IF quantifier = 'zadeh' THEN
RETURN zadeh(VARIADIC arr);
ELSIF quantifier = 'cta' THEN
RETURN cta(VARIADIC arr);
ELSIF quantifier = 'owa' THEN
RETURN owa(VARIADIC arr);
END IF;
RETURN 0.0;
END;
$$ LANGUAGE plpgsql;


/*
Nom
  most_of(x FLOAT) RETURNS FLOAT 

Argument
  x FLOAT
Type de retour
  FLOAT
Description
  quantificateur relatif la_plupart x → x*x
*/
CREATE OR REPLACE FUNCTION most_of(x FLOAT)
RETURNS FLOAT 
LANGUAGE SQL IMMUTABLE
AS $$
SELECT $1 * $1;
$$;

/*
 Zadeh : computational approach to fuzzy quantifiers
 Un quantifieur flou est vu comme une caractérisation floue d'une cardinalité absolue ou relative.
 Considérons ces différentes interprétations :
 µ_a(X) = µQ_1 (Somme_{i<=n} µ_{fc1}(x_i))
 µ_b(X) = µQ_2 (1/n Somme_{i<=n} µ_{fc1}(x_i))
 µ_d(X) = µQ_2 ((Somme_{i<=n} MIN(µ_{fc1}(x_i), µ_{fc2}(x_i) )) / Somme_{i<=n} µ_{fc1}(x_i))
*/



/*
Nom : zadeh(VARIADIC xs FLOAT[])

Argument
  VARIADIC xs FLOAT[] : tableau de nombre flottants.

Type de retour
  FLOAT

Description
Quantificateur Zadeh : moyenne des degrés de satisfaction interprétée par le quantificateur ‘most’. 
      µ(most t1) = most( (0.5 + 1 + 0.2 + 0.4 + 0.6) / 5) = most(0,54) = 0,2916
      µ(most t2) = most( (0.1 + 1 + 0.5 + 0 + 0.1) / 5) = most(0,34) = 0,1156

TODO
Cas d'un quantificateur absolu : faire la somme et l'interpréter par le quantificateur
*/

CREATE OR REPLACE FUNCTION zadeh(VARIADIC xs FLOAT[])
RETURNS FLOAT
LANGUAGE plpgsql IMMUTABLE
AS $$
    DECLARE
    n float;
    s float := 0;
    i int := 0;
    BEGIN
        FOREACH n IN ARRAY $1 LOOP
            s := s + n;
            i := i + 1;
        END LOOP;
        RETURN most_of(s / i::float);
    END;
$$;


/*
Nom : cta(VARIADIC xs FLOAT[])

Argument
  VARIADIC xs FLOAT[] : tableau de nombre flottants.

Type de retour
  FLOAT

Description

Quantificateur Yager-CTA : 
  µ(X) = sup_{1 <= i <= n} min(µ_q(i/n),µ_A(xi))
  Où :
  •       µ(X) est le degré à calculer ;
  •       n est le nombre de prédicats à agréger ;
  •       mu_q(i/n) est l'interprétation de i par la définition du quantificateur (on suppose ici que i est un quantificateur relatif) ;
  •       µ_A(xi) est le degré de satisfaction du prédicat.
*/

--CREATE LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cta(VARIADIC xs FLOAT[]) 
RETURNS FLOAT
LANGUAGE plpythonu
AS $$
    l = len(xs)
    xs.sort(reverse=True) 
    # plpy.execute("SELECT most_of(%d)" % (FLOAT(i + 1) / l))
    mu = [min( (float(i + 1) / l) ** 2,x) for i,x in enumerate(xs)]
    return max(mu)
$$;


/*
Nom : OWA(VARIADIC xs FLOAT[])

Argument
  VARIADIC xs FLOAT[] : tableau de nombre flottants.

Type de retour
  FLOAT

Description

Un opérateur OWA est défini de la manière suivante

        OWA(x1…xn ; w1…wn) = \sum_{1 <= i <= n} ^ w_i * x_ki
Où :
-       x1 .. xn sont les degrés de satisfactions des prédicats à agréger ;
-       les x_ki sont les degrés de satisfactions des prédicats classés par ordre décroissant ;
-       w1 .. wn sont les poids d'importance ;

Le quantificateur Yager-OWA effectue tout d'abord le calcul des poids wi à partir de la définition du quantificateur utilisé :
  wi = µ_Q(i/n) – µ_Q((i-1)/n)  pour les quantificateurs relatifs

TODO
  prendre en compte le cas de quantificateurs absolus : wi = µ_Q(i) – µ_Q(i-1)
*/
CREATE OR REPLACE FUNCTION owa(VARIADIC xs FLOAT[])
RETURNS FLOAT
LANGUAGE plpythonu
AS $$
    w = []
    qi_1 = 0
    l = len(xs)
    for i in range(1, l+1):
	qi = (float(i) / l) ** 2
        # qi = plpy.execute("SELECT most_of(%d)" % (FLOAT(i) / l))
        w.append(qi - qi_1)
        qi_1 = qi

    y = [(xi, i) for i, xi in enumerate(xs)]
    y.sort(reverse=True)
    owa = [yi * w[i] for (i, (yi,j)) in enumerate(y)]
    return sum(owa)
$$;


/*
Nom
  arith_mean(VARIADIC xs FLOAT[]) RETURNS FLOAT 

Argument
  VARIADIC xs FLOAT[] : tableau de nombres flottants pour lesquels on charche à calculer la moyenne

Type de retour
  FLOAT : moyenne arithmétique

Description
La moyenne arithmétique est définie par la formule suivante
moyenne = sum_{1<=i<=n} xi / n

EXEMPLE :
SELECT * FROM employe WHERE arith_mean(age is jeune, 0.5, dept = 'finance', 0.2, salary is high, 0.3)''


TODO

Moyenne arithmétique,
        geométrique,
        harmonique et
éventuellement pondérée avec l'introduction de poids dans la proposition.
*/
CREATE OR REPLACE FUNCTION arith_mean(VARIADIC xs FLOAT[])
RETURNS FLOAT 
LANGUAGE 'plpgsql' IMMUTABLE AS $$ 
DECLARE
    x float;
    w float;
    fp float;
    s float := 0;
    i int := 0;
    impair BOOLEAN := FALSE;
BEGIN
    FOREACH x IN ARRAY $1 LOOP
        IF(impair)
        THEN 
            w := x;
            s := s + (w * fp);
            i := i + 1;
        ELSE 
            fp := x;
	        
        END IF;
        impair := not impair;
    END LOOP;
    RETURN s / i::float;
END;
$$;
