/*-------------------------------------------------------------------------
 *
 * sqlf.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef SQLF_H
#define SQLF_H

#include "postgres.h"
#include "fmgr.h"

#include "executor/spi.h"
#include "utils/builtins.h"


PG_MODULE_MAGIC;

#define ZADEH		1
#define PROBABILISTIC	2
#define LUKASIEWICZ	3
#define HAMACHER	4
#define WEBER		5
#define CTA             6
#define OWA             7



static float8 ALPHA = 0.0;
static float8 MU = 0.0;
static int32 K = 0; 
static int NORM = ZADEH;
static int QUANTIFIER = ZADEH;


Datum trapezoidal_fuzzy_predicate(PG_FUNCTION_ARGS);
Datum fuzzy_or_operator(PG_FUNCTION_ARGS);
Datum fuzzy_and_operator(PG_FUNCTION_ARGS);
Datum fuzzy_not_operator(PG_FUNCTION_ARGS);

Datum set_norm(PG_FUNCTION_ARGS);
Datum get_norm(PG_FUNCTION_ARGS);

Datum set_quantifier(PG_FUNCTION_ARGS);
Datum get_quantifier(PG_FUNCTION_ARGS);

Datum set_k(PG_FUNCTION_ARGS);
Datum get_k(PG_FUNCTION_ARGS);

Datum set_alpha(PG_FUNCTION_ARGS);
Datum get_alpha(PG_FUNCTION_ARGS);

Datum set_mu(PG_FUNCTION_ARGS);
Datum get_mu(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(trapezoidal_fuzzy_predicate);
PG_FUNCTION_INFO_V1(fuzzy_or_operator);
PG_FUNCTION_INFO_V1(fuzzy_and_operator);
PG_FUNCTION_INFO_V1(fuzzy_not_operator);
PG_FUNCTION_INFO_V1(set_alpha);
PG_FUNCTION_INFO_V1(get_alpha);
PG_FUNCTION_INFO_V1(set_mu);
PG_FUNCTION_INFO_V1(get_mu);
PG_FUNCTION_INFO_V1(set_k);
PG_FUNCTION_INFO_V1(get_k);
PG_FUNCTION_INFO_V1(set_norm);
PG_FUNCTION_INFO_V1(get_norm);
PG_FUNCTION_INFO_V1(set_quantifier);
PG_FUNCTION_INFO_V1(get_quantifier);



float8 and_zadeh(float8 a, float8 b);
float8 or_zadeh(float8 a, float8 b);
float8 and_probabiliste(float8 a, float8 b);
float8 or_probabiliste(float8 a, float8 b);
float8 and_lukasiewicz(float8 a, float8 b);
float8 or_lukasiewicz(float8 a, float8 b);
float8 and_weber(float8 a, float8 b);
float8 or_weber(float8 a, float8 b);


#endif   /* SQLF_H  */
