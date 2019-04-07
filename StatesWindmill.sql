-- ============================================================
-- Spatial data represents information about the physical 
-- location and shape of geometric objects. These objects can 
-- be point locations or more complex objects such as countries, 
-- roads, or lakes.
-- ============================================================
-- Author:		Feiock, Lucas
-- Create date: April 1, 2019
-- Description:	Starting SQL Server Spatial Data
-- ============================================================

-- Table of contents
-- ============================================================
-- Introduction
-- Documentation and Links
-- Create a Point
-- Create a Line
-- Spatial Reference Systems 
-- KiZAN Offices
-- OGC Methods
-- GIS File Formats
-- Wind Turbine Demo
-- Spatial Indexes
-- Envelope and Aggregates


-- Microsoft SQL Documentation - Spatial Data
-- https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-data-sql-server
-- ============================================================
-- SQL Server supports two spatial data types: 
-- the geometry data type and the geography data type.
-- * The geometry type represents data in a Euclidean (flat) 
--   coordinate system.
-- * The geography type represents data in a round-earth 
--   coordinate system.
-- Both data types are implemented as .NET common language 
-- runtime (CLR) data types in SQL Server.
-- ============================================================
-- Both data types support two groups, objects and collections.
-- Single objects: Point, LineString, CircularString, 
-- CompoundCurve, Polygon, and CurvePolygon
--
-- Collections: MultiPoint, MultiLineString, MultiPolygon, 
-- GeometryCollection



/*
The Open Geospatial Consortium (OGC) is an international not for profit organization 
committed to making quality open standards for the global geospatial community. 
These standards are made through a consensus process and are freely available for 
anyone to use to improve sharing of the world's geospatial data.

Simple Feature Access - Part 1: Common Architecture
http://www.opengeospatial.org/standards/sfa

Simple Feature Access - Part 2: SQL Option
http://www.opengeospatial.org/standards/sfs

More information at their website:
https://www.opengeospatial.org
*/

/*
Books and Blogs
============================================================
Alastair Aitchison
Beginning Spatial with SQL Server 2008
Pro Spatial with SQL Server 2012

Redgate - Roy Ernest
============================================================

Introduction to SQL Server Spatial Data
https://www.red-gate.com/simple-talk/sql/t-sql-programming/introduction-to-sql-server-spatial-data/

SQL Server Spatial Indexes
https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-spatial-indexes/

============================================================
MSSQLTips - SQL Server 2008 Geography and Geometry Data Types
https://www.mssqltips.com/sqlservertip/1847/sql-server-2008-geography-and-geometry-data-types/

============================================================
SQLShack - Spatial data types in SQL Server
https://www.sqlshack.com/spatial-data-types-in-sql-server/
============================================================


SQL Server 2008 introduced spatial data support into the database server. 
New Spatial Features in SQL Server Code-Named “Denali” 
This paper describes and discusses the new spatial features in SQL Server 
Code-Named “Denali” CTP1 and CTP3 that augment existing SQL Server 2008 and 
SQL Server 2008 R2 spatial functionality.
Denali added new curved and circular objects along with performance Improvements.
https://go.microsoft.com/fwlink/?LinkId=226407


Additional links
https://github.com/Microsoft/SQLServerSpatialTools

*/


/*  
Microsoft SQL Docs for Spatial Types - geometry
https://docs.microsoft.com/en-us/sql/t-sql/spatial-geometry/spatial-types-geometry-transact-sql
Geometry: Stores data based on a flat (Euclidean) X and Y coordinate system. 

Microsoft SQL Docs for Spatial Types - geography
https://docs.microsoft.com/en-us/sql/t-sql/spatial-geography/spatial-types-geography
Geography: Stores data based on a round-earth latitude and longitude coordinate system.

Microsoft Spatial Data Types Overview
https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-data-types-overview

Both data types are implemented as .NET common language runtime (CLR) data types in SQL Server.
https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/introduction-to-sql-server-clr-integration

*/

-- ============================================================
-- Open Object Explorer -> Expand a Database Programmability -> 
-- Types -> System Data Types -> Spatial Data Types

-- ============================================================
-- Define a point, line, polygon
-- Create a variable of geometry data type
-- The :: makes the engine call the CLR method
-- This can also be a one line SELECT statement
DECLARE @point geometry
SET @point = geometry::Parse('POINT(3 4)')
SELECT @point

SELECT geometry::Parse('POINT(3 4)')

-- ============================================================
-- The results that are shown are in a binary format
-- This is defined by the OGC as Well-Known Binary (WKB)
-- The spatial results tab will display the point and is not 
-- easily visible. Since the data type is defined by a CLR 
-- Assembly each object has additional methods and properties.
-- STBuffer returns a geography object that represents 
-- the union of all points whose distance from a geography 
-- instance is less than or equal to a specified value.
-- ST standards for Spatial Type
DECLARE @point_buffer geometry
SET @point_buffer = geometry::Parse('POINT(3 4)').STBuffer(1)
SELECT @point_buffer



-- ============================================================
-- A LineString is a one-dimensional object representing a 
-- sequence of points and the line segments connecting them.
-- https://docs.microsoft.com/en-us/sql/relational-databases/spatial/linestring

DECLARE @g1 geometry = 'LINESTRING EMPTY';  
DECLARE @g2 geometry = 'LINESTRING(1 1, 3 3)';  
DECLARE @g3 geometry = 'LINESTRING(1 1, 3 3, 2 4, 2 0)';  
DECLARE @g4 geometry = 'LINESTRING(1 1, 3 3, 2 4, 2 0, 1 1)';  
DECLARE @g5 geometry = 'LINESTRING(1 1, 1 1)'; -- This is acceptable, but is not valid.

SELECT @g1.STIsValid() g1IsValid, @g2.STIsValid() g2IsValid, 
@g3.STIsValid() g3IsValid, @g4.STIsValid() g4IsValid, @g5.STIsValid() g5IsValid;  

SELECT @g1 SELECT @g2.STBuffer(0.1) SELECT @g3.STBuffer(0.1) SELECT @g4.STBuffer(0.1)



-- This is not accepted and will throw a System.FormatException
DECLARE @g geometry = 'LINESTRING(1 1)';  

-- ============================================================
-- In addition to Parse the OGC has developed Static Methods for 
-- controlling the expected type of data for performance improvements.
-- This example shows returning a geometry instance from Text.
-- The format is know as Well-Known Text (WKT).
SELECT geometry::STGeomFromText('POINT(4 5)', 0).STBuffer(1);


-- ============================================================
-- The 0 in the above example is an int expression representing
-- the spatial reference ID (SRID) of the geometry instance.
-- https://docs.microsoft.com/en-us/sql/t-sql/spatial-geography/stsrid-geography-data-type
SELECT geometry::STGeomFromText('POINT(4 5)', 0).STSrid;


-- ============================================================
-- Spatial reference identifier (SRID)
-- The SRID corresponds to a spatial reference system based on 
-- the specific ellipsoid used for either flat-earth mapping or
-- round-earth mapping.
-- 
-- A spatial column can contain objects with different SRIDs. 
-- However, only spatial instances with the same SRID can be 
-- used when performing operations with SQL Server spatial data 
-- methods on your data. 
-- The result of any spatial method derived from two spatial 
-- data -- instances is valid only if those instances have the 
-- same SRID -- that is based on the same unit of measurement, 
-- datum, and projection used to determine the coordinates 
-- of the instances. The most common units of measurement of a 
-- SRID are meters or square meters.
-- 
-- 1 meter ≈ 3.281 foot
-- 
-- If two spatial instances do not have the same SRID, the 
-- results -- from a geometry or geography Data Type method 
-- used on the instances will return NULL.
-- https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-reference-identifiers-srids

-- ============================================================
-- Geodesy is the study of Earth to accurately measure and 
-- understanding Earth's geometric shape.
-- The European Petroleum Survey Group (EPSG) (1986-2005) was a 
-- scientific organization that defined many of the standards 
-- used today. 
-- http://www.epsg.org/
-- The current organization is called IOGP
-- International Associate of Oil & Gas Producers 

-- ============================================================
-- Lists the spatial reference systems (SRIDs) supported by SQL Server.
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-spatial-reference-systems-transact-sql

SELECT 
  [spatial_reference_id]
, [authority_name]
, [authorized_spatial_reference_id]
, [well_known_text]
, [unit_of_measure]
, [unit_conversion_factor]
FROM [sys].[spatial_reference_systems]



-- ============================================================
-- SRID 4326 is a common standard coordinate frame
-- World Geodetic System is a standard used in cartography, 
-- geodesy, satellite navigation and Global Positioning System.
-- https://en.wikipedia.org/wiki/World_Geodetic_System
--
-- http://spatialreference.org/ref/epsg/wgs-84/
--
-- GEOGCS["WGS 84"
-- , DATUM["World Geodetic System 1984"
-- , ELLIPSOID["WGS 84", 6378137, 298.257223563]]
-- , PRIMEM["Greenwich", 0]
-- , UNIT["Degree", 0.0174532925199433]]


-- ============================================================
-- KiZAN Technologies
-- Louisville ( 38.270203 , -85.504507 )
-- https://www.google.com/maps/@38.2703783,-85.5047808,188m/data=!3m1!1e3
--
-- Cincinnati ( 39.329036 , -84.441227 )
-- https://www.google.com/maps/@39.329036,-84.441227,188m/data=!3m1!1e3

DECLARE @kz_office geography;  
SET @kz_office = geography::STPolyFromText(
	'POLYGON((
		-85.504373 38.270055, 
		-85.504436 38.270433, 
		-85.504647 38.270412, 
		-85.504581 38.270033, 
		-85.504373 38.270055
	))', 4326);  
SELECT @kz_office;










-- ============================================================
-- OGC Methods on Geography Instances
-- https://docs.microsoft.com/en-us/sql/t-sql/spatial-geography/ogc-methods-on-geography-instances

SELECT 
  KZ.STArea() STArea
, KZ.STLength() STLength
, KZ.STSrid STSrid
, KZ.STNumPoints() STNumPoints
, KZ.STNumGeometries() STNumGeometries
, KZ.STStartPoint().ToString() STStartPoint
, KZ.STEndPoint().ToString() STEndPoint
, KZ.STGeometryType() STGeometryType
, KZ.STIsClosed() STIsClosed
, KZ.STIsEmpty() STIsEmpty
, KZ.STIsValid() STIsValid
, KZ.STAsBinary() STAsBinary
, KZ.STAsText() STAsText
FROM (
SELECT geography::STPolyFromText(
	'POLYGON((
		-85.504373 38.270055, 
		-85.504436 38.270433, 
		-85.504647 38.270412, 
		-85.504581 38.270033, 
		-85.504373 38.270055
	))', 4326) KZ
) office




/*
There are many GIS formats that are used.
https://en.wikipedia.org/wiki/GIS_file_formats#Popular_GIS_file_formats

Shapefile – a popular vector data GIS format, developed by Esri
TIGER – Topologically Integrated Geographic Encoding and Referencing
GeoJSON – a lightweight format based on JSON, used by many open source GIS packages
Keyhole Markup Language (KML) – XML based open standard (by OpenGIS) for GIS data exchange
Geography Markup Language (GML) – XML based open standard (by OpenGIS) for GIS data exchange
*/









-- The U.S. Wind Turbine Database
-- ============================================================
-- The United States Wind Turbine Database (USWTDB) provides 
-- the locations of land-based and offshore wind turbines in 
-- the United States, corresponding wind project information, 
-- and turbine technical specifications. 
-- https://eerscmap.usgs.gov/uswtdb/


-- United States Census Bureau
-- Cartographic Boundary Shapefiles - States
-- ============================================================
-- The cartographic boundary files are simplified 
-- representations of selected geographic areas from the Census
-- Bureau’s MAF/TIGER geographic database.
-- https://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
-- cb_2017_us_state_500k.zip
--
--
-- census.gov has been updated in the last few days to the following
-- https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.2018.html
-- TIGER = Topologically Integrated Geographic Encoding and Referencing

-- ============================================================
-- SQL Scripts to load the files
-- C:\SQLStack\SpatialData\windmill_load.sql
-- C:\SQLStack\SpatialData\StatesLoad.sql


SELECT 
  [case_id]
, [t_state]
, [p_name]
, [p_year]
, [p_tnum]
, [p_cap]
, [t_manu]
, [t_model]
, [t_cap]
, [t_hh]
, [t_rd]
, [t_rsa]
, [t_ttlh]
, [t_conf_atr]
, [t_conf_loc]
, [xlong]
, [ylat]
, [geo]
FROM [dbo].[mill]




SELECT 
  [rnum]
, [featurekey]
, [geoid]
, [statename]
, [geomtype]
, [polygonID]
, [coor]
, [geo]
FROM [dbo].[states]





SELECT 
  geo.STArea() STArea
, geo.STLength() STLength
, geo.STSrid STSrid
, geo.STNumPoints() STNumPoints
, geo.STNumGeometries() STNumGeometries
, geo.STStartPoint().ToString() STStartPoint
, geo.STEndPoint().ToString() STEndPoint
, geo.STGeometryType() STGeometryType
, geo.STIsClosed() STIsClosed
, geo.STIsEmpty() STIsEmpty
, geo.STIsValid() STIsValid
, geo.STAsBinary() STAsBinary
, geo.STAsText() STAsText
FROM dbo.states
WHERE statename = 'Kentucky'



-- The second polygon for Kentucky is the Kentucky Bend
-- https://en.wikipedia.org/wiki/Kentucky_Bend

SELECT * FROM dbo.states WHERE statename = 'Kentucky'



-- ============================================================
-- OGC Methods on Geography Instances
-- Additional methods that work with more than a single object
-- are included in the same OGC Methods.
-- Some of these are STDifference, STEquals, STIntersects
-- https://docs.microsoft.com/en-us/sql/t-sql/spatial-geography/ogc-methods-on-geography-instances

SELECT geo
FROM dbo.states
WHERE statename = 'Indiana'
union all
SELECT geo.STBuffer(0.003)
FROM dbo.mill
WHERE t_state = 'IN'


-- ============================================================
-- STIntersects (geography Data Type)
-- Returns 1 if a geography instance intersects another geography instance. Returns 0 if it does not.
-- https://docs.microsoft.com/en-us/sql/t-sql/spatial-geography/stintersects-geography-data-type

SELECT s.rnum, s.statename, m.case_id
FROM dbo.states s
INNER JOIN dbo.mill m 
ON m.geo.STIntersects(s.geo) = 1

-- This query can take up to two minutes to complete.
-- 46,934,547 operations to determine the location 
select 58449 * 803






-- ============================================================
-- Spatial Indexes
-- A spatial index can more efficiently perform certain 
-- operations on a column of the geometry or geography data 
-- type (a spatial column). More than one spatial index can be 
-- specified on a spatial column. This is useful, for example, 
-- for indexing different tessellation parameters in a single 
-- column.
-- https://docs.microsoft.com/en-us/sql/relational-databases/spatial/create-modify-and-drop-spatial-indexes
-- https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-indexes-overview


DROP INDEX STIX_GEO ON dbo.mill
DROP INDEX STIX_GEO ON dbo.states


CREATE SPATIAL INDEX STIX_GEO ON dbo.mill(geo) 
USING GEOMETRY_AUTO_GRID
WITH 
(
	BOUNDING_BOX = 
	( 
		  xmin = -125.0
		, ymin = 25.0
		, xmax = -67.0
		, ymax = 50.0
	) 
);

CREATE SPATIAL INDEX STIX_GEO ON dbo.states(geo) 
USING GEOMETRY_AUTO_GRID
WITH 
(
	BOUNDING_BOX = 
	( 
		  xmin = -125.0
		, ymin = 25.0
		, xmax = -67.0
		, ymax = 50.0
	) 
);




-- Adding the indexes speeds up the query to under ten seconds.

SELECT s.rnum, s.statename, m.case_id
FROM dbo.states s
INNER JOIN dbo.mill m 
ON m.geo.STIntersects(s.geo) = 1














-- How to find the bounding box from the data.
-- STEnvelope - Returns the minimum axis-aligned bounding rectangle of the instance.
-- UnionAggregate - Performs a union operation on a set of geography objects. 
-- https://docs.microsoft.com/en-us/sql/t-sql/spatial-geometry/stenvelope-geometry-data-type
-- https://docs.microsoft.com/en-us/sql/t-sql/spatial-geometry/unionaggregate-geometry-data-type


select geometry::UnionAggregate(geo) from dbo.mill
union all
select geometry::UnionAggregate(geo).STEnvelope() from dbo.mill

-- EnvelopeAggregate - Returns a bounding box for a given set of geometry objects.
-- https://docs.microsoft.com/en-us/sql/t-sql/spatial-geometry/envelopeaggregate-geometry-data-type
select geometry::EnvelopeAggregate(geo) from dbo.mill

-- Find the number of points that are in the envelope
select geometry::EnvelopeAggregate(geo).STNumPoints() NumPoints from dbo.mill


-- Query each point in the envelope
SELECT nums.rnum , 
bb.bounding_box.STPointN(nums.rnum).STX STX , 
bb.bounding_box.STPointN(nums.rnum).STY STY
FROM ( select geometry::EnvelopeAggregate(geo) bounding_box from dbo.mill ) bb
CROSS APPLY (SELECT TOP 5 ROW_NUMBER() OVER(ORDER BY name) rnum FROM sys.columns) nums

-- Calculate the min/max of each point
SELECT MIN(STX) MIN_STX, MIN(STY) MIN_STY, MAX(STX) MAX_STX, MAX(STY) MAX_STY
FROM (
SELECT nums.rnum , 
bb.bounding_box.STPointN(nums.rnum).STX STX , 
bb.bounding_box.STPointN(nums.rnum).STY STY
FROM ( select geometry::UnionAggregate(geo).STEnvelope() bounding_box from dbo.mill ) bb
CROSS APPLY (SELECT TOP 5 ROW_NUMBER() OVER(ORDER BY name) rnum FROM sys.columns) nums
) bound































/* 

!!! But Wait, There's More !!!

Nearest neighbor search is a proximity search and is an optimization problem of finding the closest point in a given set.
https://en.wikipedia.org/wiki/Nearest_neighbor_search
https://docs.microsoft.com/en-us/sql/relational-databases/spatial/query-spatial-data-for-nearest-neighbor
*/