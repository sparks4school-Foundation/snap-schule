# Snap!Schule install

## Create cloud user

```
sudo adduser cloud
sudo su - cloud
```

## Cloning repos and setting up folder structure

```
git clone https://github.com/jmoenig/Snap.git

git clone https://gitlab.com/bromagosa/snapschule.git
cd snapschule/
ln -s ../Snap/ snap

git checkout backend-only
git submodule set-url lib/raven-lua https://github.com/snap-cloud/raven-lua.git
git submodule update --init lib/raven-lua/
```

## Modify the prereqs file

OpenResty lacks a release file for debian trixie. Manually change `codename` to
`bookworm` in bin/prereqs.sh:

```
echo "deb http://openresty.org/package/debian bookworm openresty" \
```

Additionally, force Debian to trust this package even though it won't be signed
for the current release. Change the apt-get update line to:

```
apt update --allow-insecure-repositories
```
Note you should use **apt**, not **apt-get**!

Also change the following line:

```
apt-get -y install openresty --allow-unauthenticated
```

Additionally, remove xml from both the rockspec and luarocks.lock files, and
change the `luarocks install` line in bin/prereqs.sh to:

```
luarocks install snapcloud-dev-0.rockspec --pin
```

## Run the prereqs file

```
sudo bin/prereqs.sh
```

# Environment file

Create an .env file with the following contents:

```
export LAPIS_ENVIRONMENT=production
export DATABASE_HOST=127.0.0.1
export DATABASE_PORT=5432
export DATABASE_USERNAME=cloud
export DATABASE_PASSWORD=snap-cloud-password
export DATABASE_NAME=snapcloud
export HOSTNAME=snap.berkeley.edu

```

# Database

```
sudo service postgresql start
```

Add postgres user to cloud group

```
sudo usermod -a -G cloud postgres
```

Now give full permissions for cloud home dir to the cloud group.

```
chmod 770 ~
```

Become postgres:

```
sudo su - postgres
```

Run the postgres console:

```
psql postgres
# Enter these in the PSQL command line
> CREATE USER cloud WITH PASSWORD 'snap-cloud-password';
> ALTER ROLE cloud WITH LOGIN;
> CREATE DATABASE snapcloud OWNER cloud;
```

Now become cloud again, create the db schema and run migrations:

```
cd /home/cloud/snapschule
source .env
db/init.sh
lapis migrate
```

And finally run the Schule-specific DB init script:

```
cd frontend
install/install.sh
```

