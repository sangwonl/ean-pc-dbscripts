/*******************************************************
** SQLite Version									  **
** EAN Extras - additional custom tables & examples   **
** SCRIPT TO GENERATE EAN DATABASE IN MYSQL ENGINE    **
** BE CAREFUL AS IT WILL ERASE THE EXISTING DATABASE  **
** YOU CAN USE SECTIONS OF IT TO RE-CREATE TABLES     **
** WILL CREATE USER: eanuser / expedia                **
** table names are lowercase so it will work  in all  ** 
** platforms the same.                                */


USE eanextras;


/*######################################################
##                                                    ##
## TABLES & STORED PROCEDURES CREATED TO ENHANCE THE  ##
## SYSTEM FUNCTIONALITY                               ##
##                                                    ##
########################################################

########################################################
## Full Text Search
## We keep it as a separate table for efficiency
## as we move this table to RAM for faster processing
## DEFINITION:
## Name - fast text search name to use
## SearchBy - what to pass to the API for searching (Name,GPS,HotelID)
## Type - 1=Cities, 2=Landmarks, 3=Airports, 4=HotelId
## GPS are comma separated (123.434336,-54443.767445)
*/
DROP TABLE IF EXISTS fasttextsearch;
CREATE TABLE fasttextsearch
(
	Name VARCHAR(510),
	SearchBy VARCHAR(510),
	Type CHAR(1)
);

CREATE FULLTEXT INDEX ft_name ON fasttextsearch(Name);



*/######################################################
## airports
## This data comes from http://www.ourairports.com/data/
## using the file: airports.csv
## it is about 25K records long
## This file could be joined to the regular EAN Airports
## using the IATACode file, the normal 3x letters code
## 
## This table include Small, Medium and Large Airports
## it includes the ISO Country, Region and also Municipality
*/
DROP TABLE IF EXISTS airports;
CREATE TABLE airports
(
	ID INT,
	AirportCode VARCHAR(10) NOT NULL,
	AirportType VARCHAR(14),
	AirportName VARCHAR(80),
	Latitude NUMERIC(9,6),
	Longitude NUMERIC(9,6),
	Elevation INT,
	ContinentCode VARCHAR(2),
	ISOCountry VARCHAR(2),
	ISORegion VARCHAR(8),
	Municipality VARCHAR(65),
	ScheduledService VARCHAR(3),
	GPSCode VARCHAR(10),
	IATACode VARCHAR(3),
	LocalCode VARCHAR(10),
	HomeLink VARCHAR(128),
	WikipediaLink VARCHAR(128),
	Keywords VARCHAR(255),
	PRIMARY KEY (AirportCode)
);

-- index by Latitude, Longitude to use for geosearches
CREATE INDEX ourairportscoordinate_geoloc ON airports(Latitude, Longitude);

-- ISO list of Countries
DROP TABLE IF EXISTS countries;
CREATE TABLE countries
(
	ID INT,
	CountryCode VARCHAR(2) NOT NULL,
	CountryName VARCHAR(50),
	ContinentCode VARCHAR(2),
	WikipediaLink VARCHAR(128),
	Keywords VARCHAR(255),
    TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (CountryCode)
);


DROP TABLE IF EXISTS regions;
CREATE TABLE regions
(
	ID INT,
	RegionCode VARCHAR(8) NOT NULL,
	RegionLocalCode VARCHAR(4),
	RegionName VARCHAR(50),
	ContinentCode VARCHAR(2),
	ISOCountry VARCHAR(2),
	WikipediaLink VARCHAR(128),
	Keywords VARCHAR(255),
	PRIMARY KEY (RegionCode)
);
 

/*########################################################################
## Airport Data from: http://openflights.org/data.html#airport
##########################################################################
## Airport ID 	Unique OpenFlights identifier for this airport.
## Name 	Name of airport. May or may not contain the City name.
## City 	Main city served by airport. May be spelled differently from Name.
## Country 	Country or territory where airport is located.
## IATA/FAA 	3-letter FAA code, for airports located in Country "United States of America".
## 3-letter IATA code, for all other airports. Blank if not assigned.
## ICAO 	4-letter ICAO code. Blank if not assigned.
## Latitude 	Decimal degrees, usually to six significant digits. Negative is South, positive is North.
## Longitude 	Decimal degrees, usually to six significant digits. Negative is West, positive is East.
## Altitude 	In feet.
## Timezone 	Hours offset from UTC. Fractional hours are expressed as decimals, eg. India is 5.5.
## DST 	Daylight savings time. One of E (Europe), A (US/Canada), S (South America), O (Australia), Z (New Zealand), N (None) or U (Unknown). See also: Help: Time
## The data is ISO 8859-1 (Latin-1) encoded, with no special characters
*/
DROP TABLE IF EXISTS openflightsairports;
CREATE TABLE openflightsairports
(
	AirportID INT NOT NULL,
	Name VARCHAR(80),
	City VARCHAR(80),
    Country VARCHAR(80),
    IATA VARCHAR(3),
	ICAO VARCHAR(4),
	Latitude NUMERIC(9,6),
	Longitude NUMERIC(9,6),
	Altitude INT,
	Timezone VARCHAR(20),
	DST VARCHAR(20),
	PRIMARY KEY (AirportID)
);



/*#######################
### EAN Special Files ###
#########################
## table based in the file: Destination IDs
*/
DROP TABLE IF EXISTS destinationids;

CREATE TABLE destinationids (
  DestinationID TEXT,
  Destination TEXT,
  StateProvince TEXT DEFAULT NULL,
  Country TEXT DEFAULT NULL,
  CenterLatitude decimal(12,8) DEFAULT NULL,
  CenterLongitude decimal(12,8) DEFAULT NULL,
  PRIMARY KEY (DestinationID)
);
CREATE INDEX destinationids_idx_dest_name ON destinationids (Destination);

DROP TABLE IF EXISTS landmark;
CREATE TABLE landmark
(
DestinationID 	varchar(100) NOT NULL,
Name			varchar(280),
City			varchar(4000),
StateProvince 	varchar(2),
Country			varchar(3),
CenterLatitude 	DECIMAL(14,8),
CenterLongitude DECIMAL(14,8),
Type 	    	int,
PRIMARY KEY (DestinationID)
);
CREATE INDEX idx_landmk_name ON landmark(Name);

/*###############################################
#RegionID to DestinationID
#################################################
*/
DROP TABLE IF EXISTS regionidtodestinationid;
CREATE TABLE regionidtodestinationid
(
DestinationID 	varchar(100) NOT NULL,
DestinationINT 	int,
Destination 	varchar(280),
DestinationType int,
RegionID        int NOT NULL,
RegionName      varchar(255),
RegionType      varchar(255),
PRIMARY KEY (DestinationID)
);
CREATE INDEX idx_dest_namemap ON regionidtodestinationid(RegionID);

DROP TABLE IF EXISTS destinationid_comparable;
CREATE TABLE destinationid_comparable (
  DestinationID 	varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  DestinationName 	varchar(280) COLLATE utf8_unicode_ci DEFAULT NULL,
  DestinationCNT 	int(11) DEFAULT NULL,
  MatchPercent 		decimal(12,8) DEFAULT NULL,
  RegionCNT 		int(11) DEFAULT NULL,
  RegionID 			int(11) NOT NULL,
  RegionNameLong 	varchar(510) COLLATE utf8_unicode_ci DEFAULT NULL,
  RegionType 		varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  RegionSubClass 	varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
);
CREATE INDEX idx_dest_comp_regid ON destinationid_comparable(RegionID);
CREATE INDEX idx_dest_comp_destid ON destinationid_comparable(DestinationID);

/************************************************
* Reverse Engineering to obtain the amount of
* properties on each DestinationID
* loaded using Destinations & Landmarks
************************************************/
DROP TABLE IF EXISTS destinationid_list;
CREATE TABLE destinationid_list (
  DestinationID varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  DestinationCNT int(11) DEFAULT NULL,
  DestinationHotelList TEXT,
  TimeStamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (DestinationID)
);

-- file based in the file: Property ID Cross Reference
DROP TABLE IF EXISTS propertyidcrossreference;
CREATE TABLE propertyidcrossreference
(
	ExpediaID INT NOT NULL,
	AirportCodes VARCHAR(50),
	EANHotelID INT NOT NULL,
	Hotel_Name VARCHAR(70),
	City VARCHAR(50),
	StateProvince VARCHAR(2),
	Country VARCHAR(2),
	PRIMARY KEY (EANHotelID)
);
-- index by Expedia Property ID to use for reverse searches
CREATE INDEX idx_expediaid ON propertyidcrossreference(ExpediaID);

/*
## file based in the file: PropertySupplierMapping
## Supplier Type is the same as in activepropertylist
##  2: Expedia Collect hotels
##  3: Sabre hotels
##  9: Expedia Collect condos
## 10: Worldspan hotels 
## 13: Expedia.com properties
## 14: Venere.com properties
*/
DROP TABLE IF EXISTS propertysuppliermapping;
CREATE TABLE propertysuppliermapping
(
	EANPropertyID INT NOT NULL,
	SupplierPropertyID VARCHAR(20),
	StatusCode VARCHAR(1),
    SupplierID INT NOT NULL,
--    PRIMARY KEY (EANPropertyID,SupplierID)
);
-- index by Supplier Property ID to use for reverse searches
CREATE INDEX idx_eanpropertyid ON propertysuppliermapping(EANPropertyID);
CREATE INDEX idx_supplierpropertyid ON propertysuppliermapping(SupplierPropertyID);

-- table to store the allCountries.txt file from http://download.geonames.org/export/dump/
-- will be best to run once with allCountries, then just apply the daily updates
DROP TABLE IF EXISTS geonames;
CREATE TABLE geonames
(
GeoNameID INT NOT NULL,
Name VARCHAR(200),
AsciiName VARCHAR(200),
AlternateNames TEXT,
Latitude numeric(9,6),
Longitude numeric(9,6),
FeatureClass char(1),
FeatureCode varchar(10),
CountryCode  char(2),
AlternativeCountryCode varchar(60),
AdminCode1 varchar(20),
AdminCode2 varchar(80), 
AdminCode3 varchar(20),
AdminCode4 varchar(20),
Population BIGINT,
Elevation INT,
Dem INT,
Timezone varchar(40),
ModificationDate date,
	PRIMARY KEY (GeoNameID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
-- index by Latitude, Longitude to use for geosearches
-- we add the FeatureCode to the index to spped up filtered searches
CREATE INDEX geonames_geoloc ON geonames(Latitude, Longitude,FeatureCode);
-- index to speed the usual search by name,country filtered by FeatureClass and code
CREATE INDEX geonames_fastasciiname ON geonames(AsciiName, CountryCode, FeatureClass, FeatureCode);

DROP TABLE IF EXISTS geonames;
CREATE TABLE geonames
(
GeoNameID INT NOT NULL,
Name VARCHAR(200),
AsciiName VARCHAR(200),
AlternateNames TEXT,
Latitude numeric(9,6),
Longitude numeric(9,6),
FeatureClass char(1),
FeatureCode varchar(10),
CountryCode  char(2),
AlternativeCountryCode varchar(60),
AdminCode1 varchar(20),
AdminCode2 varchar(80), 
AdminCode3 varchar(20),
AdminCode4 varchar(20),
Population BIGINT,
Elevation INT,
Dem INT,
Timezone varchar(40),
ModificationDate date,
	PRIMARY KEY (GeoNameID)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
-- index by Latitude, Longitude to use for geosearches
-- we add the FeatureCode to the index to spped up filtered searches
CREATE INDEX geonames_geoloc ON geonames(Latitude, Longitude,FeatureCode);
-- index to speed the usual search by name,country filtered by FeatureClass and code
CREATE INDEX geonames_fastasciiname ON geonames(AsciiName, CountryCode, FeatureClass, FeatureCode);

/*##################################################################
## table to keep track of cloud update process
## loggign the EANHotelIDs and the record type
####################################################################
*/
DROP TABLE IF EXISTS cloudupdateslog;
CREATE TABLE cloudupdateslog (
EANHotelID INT NOT NULL,
DocType varchar(20),
Locale varchar(5),
TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- index
CREATE INDEX cloudupdates_log ON cloudupdateslog(TimeStamp, EANHotelID, DocType, Locale);

-- eof(SQLite_create_eanextras.sql)
