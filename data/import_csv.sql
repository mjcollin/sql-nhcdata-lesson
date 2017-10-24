-- Use like "sqlite3 new_database_name.sqlite < import_csv.sql"
.separator ","
CREATE TABLE "localities" ("localityID" INTEGER, "countryCode" TEXT, "stateProvince" TEXT, "county" TEXT, "decimalLatitude" REAL, "decimalLongitude" REAL);
.import localities.csv localities
CREATE TABLE "species" ("speciesID" INTEGER, "genus" TEXT, "specificEpithet" TEXT, "scientificName" TEXT);
.import species.csv species
CREATE TABLE "specimens" ("uuid" TEXT, "speciesID" INTEGER, "localityID" INTEGER, "institutionCode" TEXT, "collectionCode" TEXT, "catalogNumber" TEXT, "recordedBy" TEXT, "eventDate" TEXT, "year" INTEGER, "month" INTEGER, "day" INTEGER, "weight" REAL, "length" REAL, "sex" TEXT);
.import specimens.csv specimens
