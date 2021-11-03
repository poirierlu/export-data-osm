@ECHO OFF
REM Tutoriel récupéré sur le site : https://portailsig.org/content/recuperer-des-donnees-openstreetmap-gdalogr.html

SET ogr2ogr="C:\Program Files\QGIS 3.16\bin\ogr2ogr.exe"


REM Télécharger des donnéés OSM sur l'emprise voulue au format .osm ou .pbf sur OpenStreetMap, ou Geofabrik, ... >> %source%
REM Les données sont catégorisées en 5 types (lines, multipolygons, points, multilines, other_) qu'il faut "extraire"
REM Pour cela, modifier le fichier  C:\Program Files\QGIS 3.16\share\gdal\osmconf.ini et l'enregistrer sous "D:\..."
REM Il faut rajouter les "keys" voulues (ex : amenity, railway, highway,...)
SET osmconf="D:\DONNEES\OSM\custom_osmconf.ini"
SET source=bretagne-latest.osm


REM créer un shape des routes
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" roads.shp -sql "SELECT * FROM lines WHERE highway IS NOT NULL" -lco ENCODING=UTF-8 %source%

REM créer un shape des places
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" places.shp -sql "SELECT * FROM points WHERE place IS NOT NULL" -lco ENCODING=UTF-8  %source%

REM créer un shape des buildings
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" buildings.shp -sql "SELECT * FROM multipolygons WHERE building is not null" -lco ENCODING=UTF-8 %source%

REM créer un shape des railways
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" railways.shp -sql "SELECT * FROM lines WHERE railway is not null" -lco ENCODING=UTF-8 %source%

REM créer un shape des waterways
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" waterways.shp -sql "SELECT * FROM lines WHERE waterway is not null" -lco ENCODING=UTF-8 %source%

REM créer un shape des points
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" points.shp -dialect SQLITE -sql "SELECT osm_id, GEOMETRY, name, coalesce(REPLACE(highway,'yes','highway'), REPLACE(man_made,'yes','man_made'), REPLACE(amenity,'yes','amenity'), REPLACE(shop,'yes','shop'), REPLACE(tourism,'yes','tourism'), REPLACE(railway,'yes','railway'), REPLACE(historic,'yes','historic'), REPLACE(office,'yes','office'), REPLACE(craft,'yes','craft')) AS type FROM points WHERE highway is not null OR man_made is not null OR amenity is not null OR shop is not null OR tourism is not null OR railway is not null OR historic is not null OR office is not null OR craft is not null" -lco ENCODING=UTF-8 %source%

REM créer un shape des naturals
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" natural.shp -dialect SQLITE -sql "SELECT osm_id, GEOMETRY, name, coalesce(waterway,leisure,landuse,REPLACE(natural,'wood','forest')) AS type from multipolygons where waterway is not null or leisure='park' or landuse='forest' or landuse='park' or natural='wood' or natural='water'" -lco ENCODING=UTF-8 %source%

REM créer un shape des landuses
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" landuse.shp -dialect SQLITE -sql "SELECT osm_way_id AS osm_id, GEOMETRY, name, coalesce(landuse,leisure) AS type from multipolygons where (landuse is not null and landuse <> 'forest' and landuse <> 'park') OR (leisure = 'pitch')" -lco ENCODING=UTF-8 %source%

REM créer un shape des bars
%ogr2ogr% --config OSM_CONFIG_FILE %osmconf% -f "ESRI Shapefile" bars.shp -dialect SQLITE -sql "SELECT * FROM (SELECT st_pointonsurface(GEOMETRY) AS GEOMETRY, coalesce(osm_way_id,osm_id) AS ID, name, amenity FROM multipolygons UNION SELECT GEOMETRY, osm_id AS ID, name, amenity FROM points) WHERE amenity='pub' OR amenity='cafe' OR amenity= 'bar'" -lco ENCODING=UTF-8 %source%

PAUSE
