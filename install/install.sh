#!/bin/sh
luarocks install base64
psql -d $DATABASE_NAME -a -f install/seeds.sql;
