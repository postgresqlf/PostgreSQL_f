/*-------------------------------------------------------------------------
 *
 * execdesc.h
 *
 * src/contrib/sqlf/sqlf.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef SQLF_H
#define SQLF_H

#include "postgres.h"
#include "fmgr.h"

#include "executor/spi.h"
#include "utils/builtins.h"


//#include "utils/pg_proc.h"


//#include "utils/numeric.h"
/*
#include "executor/instrument.h"
#include "executor/executor.h"
#include "utils/guc.h"
*/



PG_MODULE_MAGIC;
//#endif

// #define MAX_ALPHA_CUT		1
// #define MIN_ALPHA_CUT		0.00001
// double	default_alpha_cut_value;


/*
 * the main defintion of T-norm
 * and T-conorm in fuzzy set.
 */
// #define ZADEH		1
// #define PROBABILISTIC	2
// #define LUKASIEWICZ	3
// #define HAMACHER	4
// #define WEBER		5
// 
// #define DEFAULT_FUZZY_AND_OPERATOR 1
// #define DEFAULT_FUZZY_OR_OPERATOR 1

/* fuzzy AND & OR operator definition to use 
static int fuzzy_and_op_to_use = DEFAULT_FUZZY_AND_OPERATOR; 
static int fuzzy_or_op_to_use = DEFAULT_FUZZY_OR_OPERATOR;
*/



static float8 ALPHA = 0.0;
static float8 MU = 0.0;
static int32 K = 0; 
static char * NORM = "aaaaaaaaa"; // =  "zadeh";
static char * QUANTIFIER = "bbbbbbbbb";// =  "zadeh";


Datum trapezoidal_fuzzy_predicate(PG_FUNCTION_ARGS);
Datum fuzzy_or_operator(PG_FUNCTION_ARGS);
Datum fuzzy_and_operator(PG_FUNCTION_ARGS);
Datum fuzzy_not_operator(PG_FUNCTION_ARGS);
//Datum isF(PG_FUNCTION_ARGS);

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




/*
typedef struct FuzzyPredicate {
    double      x;
  double      y;
} FuzzyPredicate;

static const struct config_enum_entry t_norm_options[] = {
  {"zadeh", ZADEH, false},
  {"probabilistic", PROBABILISTIC, false},
  {"lukasiewicz", LUKASIEWICZ, false},
  {"hamacher", HAMACHER, false},
  {"weber", WEBER, false},
  {NULL, 0, false}
};

static const struct config_enum_entry t_conorm_options[] = {
  {"zadeh", ZADEH, false},
  {"probabilistic", PROBABILISTIC, false},
  {"lukasiewicz", LUKASIEWICZ, false},
  {"hamacher", HAMACHER, false},
  {"weber", WEBER, false},
  {NULL, 0, false}
};



//Node * coerce_to_float(ParseState *pstate, Node *node, const char *constructName);


static ExecutorStart_hook_type prev_ExecutorStart = NULL;
static ExecutorRun_hook_type prev_ExecutorRun = NULL;
static ExecutorFinish_hook_type prev_ExecutorFinish = NULL;
static ExecutorEnd_hook_type prev_ExecutorEnd = NULL;
void _PG_init(void);
void _PG_fini(void);

static void sqlf_ExecutorStart(QueryDesc *queryDesc, int eflags);
static void sqlf_ExecutorRun(QueryDesc *queryDesc,
			     ScanDirection direction,
			     long count);
static void sqlf_ExecutorFinish(QueryDesc *queryDesc);
static void sqlf_ExecutorEnd(QueryDesc *queryDesc);
*/


//#ifdef PG_MODULE_MAGIC
