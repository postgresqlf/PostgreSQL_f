EXTENSION = sqlf
##EXTVERSION=1.0

EXTVERSION   = $(shell grep default_version $(EXTENSION).control | \
               sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")

MODULES      = sqlf
SQL_BITS     =  sql/sqlf_predicates.sql sql/sqlf_settings.sql sql/sqlf_operators.sql sql/sqlf_conversion.sql sql/sqlf_quantifiers.sql sql/sqlf_gradual.sql
DATA	     = $(EXTENSION)--$(EXTVERSION).sql
PG_CONFIG    = pg_config
PG91         = $(shell $(PG_CONFIG) --version | grep -qE " 8\.| 9\.0" && echo no || echo yes)


ifeq ($(PG91),yes)
all: $(EXTENSION)--$(EXTVERSION).sql

$(EXTENSION)--$(EXTVERSION).sql: $(SQL_BITS)
	cat $^ > $@

EXTRA_CLEAN = $(EXTENSION)--$(EXTVERSION).sql
endif



#SQL_BITS     = $(wildcard sql/sqlf_*.sql)


# DOCS         = $(wildcard doc/*.mmd)
# TESTS        = $(wildcard test/sql/*.sql)
# REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
# REGRESS_OPTS = --inputdir=test


# sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql
# 	cp $< $@
# # 
# # ifeq ($(PG91),yes)
# # all: sql/$(EXTENSION).sql: $(DATA)
# # 	cat $^ > $@
# # sql/$(EXTENSION)--$(EXTVERSION).sql
# # 
# # # sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql
# # # 	cp $< $@
# # 
# # DATA = $(wildcard sql/*--*.sql) sql/$(EXTENSION)--$(EXTVERSION).sql
# # EXTRA_CLEAN = sql/$(EXTENSION)--$(EXTVERSION).sql
# # endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)



# $(patsubst %.c,%,$(wildcard src/*.c))
# DATA = $(sqlf--1.0.sql , $(wildcard sql/sqlf_*.sql))
# MODULES = $(wildcard *.c)
# MODULE_big = sqlf
# OBJS = sqlf.o
# 
# SRC = sqlf.c
# 
# 
# SQL_BITS     = $(wildcard sql/sqlf_*.sql)
# 
# EXTRA_CLEAN += sql/$(EXTENSION).sql
# sql/$(EXTENSION).sql: $(SQL_BITS)
# 	cat $^ > $@
# 
# PG_CONFIG = pg_config
# PGXS := $(shell $(PG_CONFIG) --pgxs)
# include $(PGXS)
# 
# 
# 


# 
# EXTENSION = sqlf
# EXTVERSION=1.0
# 
# DATA = sqlf--1.0.sql $(wildcard sql/*.sql)
# MODULE_big = sqlf
# OBJS = sqlf.o
# 
# PG_CONFIG = pg_config
# PGXS := $(shell $(PG_CONFIG) --pgxs)
# include $(PGXS)
