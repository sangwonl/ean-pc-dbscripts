ean-pc-dbscripts
================

Partner Connect database scripts for Partners to create relational database based on V2 downloadable files.
-----------------------------------------------------------------------------------------------------------


The Partners will need to run:

1. MySQL_create_eanprod.sql - This create all of eanprod database structure from scratch, indexes and stored procedures as well.
2. MySQL_extend_eanprod_xx_XX.sql - This will add tables to support extra languages, it will need to be edited to the proper LOCALE information (like es_es for Spanish/Spain).
3. EAN_MySQL_refresh.sh - The script that updates the database, the top lines will need to be adjusted for database name, dbserver, user name, password, etc. Run this to create the database.

 MySQL Version 5.6+ changed the security model, you need to FIRST use:
 mysql_config_editor set --login-path=local --host=localhost --user=localuser –password
 then uncomment the lines with the remarks that will use --login-path parameter instead of --user, --password and --host .

/Queries - Contain multiple queries that show how to relate the data in the database.

/MS-SQL - Script and database creation script. Only English files are covered by this script. Translated files and the extra functions supplied in the MySQL script set are not yet supported.

/MySQL - all MySQL versions of the scripts including my Server my.cnf configuration file, as some changes will be needed to support proper UTF-8 sorting.

/doc - Documentation that I am currently working on to better explain how to use the database files.
-> How-to EAN Database files - How to create the database files (not finished yet).
-> EAN Database Working with Geography - Documentation showing how to relate tables to solve geography, using the stored procedures to support even better (more accurate) searches. 
-> Using external data to add geography information. It includes the geonames table usage to solve questions like: nearby Train Stations.

/perl - Perl scripts that we have created as simple solutions to verify data, reformat data, etc.
-> extract_pet_fee.pl - Extract the information from the database into a new file that is easier to use.

New Geography correct information:
Our data lack the proper StateProvince for a lot of countries, we created the script:
-> get_real_address.pl - use the Nominatim API from OpenStreetMap.org to discover the real address of a given GPS point. Currently wired to the activepropertylist but you could use it for any of the tables with latitude & longitude information. 

/MAC - Mac adjusted versions of the scripts
 It include my compiled version of the wget utility that is REQUIRED for this scripts to work.

** Use of these scripts are at your own risk. The scripts are provided “as is” without any warranty of any kind and Expedia disclaims any and all liability regarding any use of the scripts. **

Please contact us with any questions / concern / suggestions.

Partner:Connect Team
apihelp@expedia.com


Using dockerized ean-pc-dbscripts
=================================

# Build docker image
```
$ docker build -t eandb .
```

# Run mysql first
```
$ cd ean-pc-dbscripts
$ docker run --name eandb --rm -it -p 3306:3306 -v $PWD/mysql-data:/var/lib/mysql -v $PWD/eanfiles:/home/eanuser/eanfiles -e MYSQL_USER=eanuser -e MYSQL_PASSWORD=Passw@rd1 -e MYSQL_DATABASE=eanprod -e MYSQL_ROOT_PASSWORD=Passw@rd1 eandb
```

# Connect to container and Run refresh script
```
$ docker exec -it eandb bash
# cd /home/eanuser
# ./EAN_MySQL_refresh.sh
```
