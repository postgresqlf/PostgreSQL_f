/*-------------------------------------------------------------------------
 *
 * sqlf.c
 *
 * IDENTIFICATION
 *	  contrib/sqlf/sqlf.c
 *
 *-------------------------------------------------------------------------
 */
#include "sqlf.h"
#include "funcapi.h"





Datum set_norm(PG_FUNCTION_ARGS)
{
    if( PG_ARGISNULL(0)){
	  PG_RETURN_NULL();
      }
    NORM = text_to_cstring(PG_GETARG_TEXT_P(0)); 
    PG_RETURN_TEXT_P(cstring_to_text(NORM));
}	


Datum get_norm(PG_FUNCTION_ARGS)
{
    text * t = cstring_to_text(NORM);
    elog(NOTICE, "NORME : %s\n", NORM);

    PG_RETURN_TEXT_P(t);
}



Datum set_quantifier(PG_FUNCTION_ARGS)
{
  strcpy(QUANTIFIER, text_to_cstring(PG_GETARG_TEXT_P(0))); 
//  QUANTIFIER = text_to_cstring(PG_GETARG_TEXT_P(0));
  PG_RETURN_TEXT_P(cstring_to_text(QUANTIFIER));
}


Datum get_quantifier(PG_FUNCTION_ARGS)
{ 
    text * t = cstring_to_text(QUANTIFIER);
    PG_RETURN_TEXT_P(t);
}



Datum get_k(PG_FUNCTION_ARGS)
{
    PG_RETURN_INT32(K);
}


Datum set_k(PG_FUNCTION_ARGS)
{
    K = PG_GETARG_INT32(0);
    PG_RETURN_INT32(K + 2);
}


Datum get_alpha(PG_FUNCTION_ARGS)
{
    PG_RETURN_FLOAT8(ALPHA);
}


Datum set_alpha(PG_FUNCTION_ARGS)
{
    ALPHA = PG_GETARG_FLOAT8(0);
    PG_RETURN_FLOAT8(ALPHA);
}

Datum get_mu(PG_FUNCTION_ARGS)
{
    PG_RETURN_FLOAT8(MU);
}

Datum set_mu(PG_FUNCTION_ARGS)
{
    MU = PG_GETARG_FLOAT8(0);
    PG_RETURN_FLOAT8(MU);
}



/*
 * fuzzy_or_operator
 *
 * this function implements the different interpretation of
 * Fuzzy or operator
 */

Datum
fuzzy_or_operator(PG_FUNCTION_ARGS)
{
  float8 val1 = PG_GETARG_FLOAT8(0);
  float8 val2 = PG_GETARG_FLOAT8(1);

  if(NORM == (char*)"zadeh")
    PG_RETURN_FLOAT8(or_zadeh(val1, val2));
  else if(NORM == (char*)"probabiliste")
    PG_RETURN_FLOAT8(or_probabiliste(val1, val2));
  else if(NORM == (char*)"lukasiewicz")
    PG_RETURN_FLOAT8(or_lukasiewicz(val1, val2));
  else if(NORM == (char*)"weber")
    PG_RETURN_FLOAT8(or_weber(val1, val2));
  else
    PG_RETURN_FLOAT8(or_zadeh(val1, val2));
}

/*
 * fuzzy_and_operator
 *
 * this function implements the different interpretation
 * of fuzzy and operator
 */

Datum 
fuzzy_and_operator(PG_FUNCTION_ARGS) //float4 val1, float4 val2)
{
  float8 val1 = PG_GETARG_FLOAT8(0);
  float8 val2 = PG_GETARG_FLOAT8(1);
  
  if(NORM == (char*)"zadeh")
    PG_RETURN_FLOAT8(and_zadeh(val1, val2));
  else if(NORM == (char*)"probabiliste")
    PG_RETURN_FLOAT8(and_probabiliste(val1, val2));
  else if(NORM == (char*)"lukasiewicz")
    PG_RETURN_FLOAT8(and_lukasiewicz(val1, val2));
  else if(NORM == (char*)"weber")
    PG_RETURN_FLOAT8(and_weber(val1, val2));
  else
    PG_RETURN_FLOAT8(and_zadeh(val1, val2));
}



/*
 * fuzzy_not_operator
 *
 * this function implement negation operator.
 */
Datum
fuzzy_not_operator(PG_FUNCTION_ARGS)
{
  float8 val = PG_GETARG_FLOAT8(0);
  PG_RETURN_FLOAT8(1 - val);
}



float8 and_zadeh(float8 a, float8 b)
{
    return (a < b) ? a : b;
}

float8 or_zadeh(float8 a, float8 b)
{ /* max(a,b) */
    return (a > b) ? a : b;
}


float8 and_probabiliste(float8 a, float8 b)
{
    return a * b;
}

float8 or_probabiliste(float8 a, float8 b)
{
    return a + b - a * b;
}


float8 and_lukasiewicz(float8 a, float8 b)
{
    float8 x = a+b-1;
    return (x > 0) ? x : 0.0;
}

float8 or_lukasiewicz(float8 a, float8 b)
{ /* min(1, a + b) */
    float8 x = a+b;
    return (x < 1) ? x : 1.0;
}


float8 and_weber(float8 a, float8 b)
{
    if (b == 1.0)
        return a;
    else if(a == 1.0)
        return b;
    else
        return 0.0;
}

float8 or_weber(float8 a, float8 b)
{
    if (b == 0.0)
        return a;
    else if(a == 0.0)
        return b;
    else
        return 1.0;
}




Datum trapezoidal_fuzzy_predicate(PG_FUNCTION_ARGS)
{
  float8 val = PG_GETARG_FLOAT8(0);
  float8 support1 = PG_GETARG_FLOAT8(1); 
  float8 core1 = PG_GETARG_FLOAT8(2); 
  float8 core2 = PG_GETARG_FLOAT8(3); 
  float8 support2 = PG_GETARG_FLOAT8(4);
  
  if (core1 == 0)
  {
    if (val <= core2)
      PG_RETURN_FLOAT8(1);
    else if (val < support2)
      PG_RETURN_FLOAT8((support2-val)/(support2-core2));
    else
      PG_RETURN_FLOAT8(0);
  }
  else if (core2 == 0)
  {
    if (val >= core1)
      PG_RETURN_FLOAT8(1);
    else if (val > support1)
      PG_RETURN_FLOAT8((val-support1)/(core1-support1));
    else
      PG_RETURN_FLOAT8(0);
  }
  else if ((val >= core1) && (val <= core2))
    PG_RETURN_FLOAT8(1);
  else if ((val > support1) && (val < core1))
    PG_RETURN_FLOAT8((val-support1)/(core1-support1));
  else if ((val < support2) && (val > core2))
    PG_RETURN_FLOAT8((support2-val)/(support2-core2));
  else
    PG_RETURN_FLOAT8(0);                
}
