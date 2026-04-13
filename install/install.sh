#!/bin/sh
source ../.env
luarocks install base64
psql -d $DATABASE_NAME -a -f install/seeds.sql;
touch ../xml.lua
chown ../xml.lua $DATABASE_USERNAME
