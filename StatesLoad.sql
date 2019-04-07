USE Windmill
go

drop table if exists states 
go
create table states (
  rnum int not null
, featurekey int
, geoid int
, statename nvarchar(255)
, geomtype nvarchar(255)
, polygonID int
, coor nvarchar(max)
, geo geometry
)
go

ALTER TABLE dbo.States
ADD CONSTRAINT PK_RNUM
PRIMARY KEY CLUSTERED (rnum); 
GO

declare @json as nvarchar(max)
SET @json = (SELECT BulkColumn FROM OPENROWSET (BULK 'C:\SQLStack\SpatialData\states.geojson', SINGLE_CLOB) as j)

insert into states ( rnum, featurekey, geoid, statename, geomtype, polygonID, coor)
select 
	row_number() over(order by features.[key], coordinates.[key]) rnum
	,features.[key] featurekey
	,geoid.[value] geoid
	,statename.[value] statename
	,geomtype.[value] geomtype
	,coordinates.[key] polygonID
	,replace(replace(coordinates.[value],'[ [ [','[ ['),'] ] ]','] ]') coor
	from OPENJSON( @json , '$.features') features
	cross apply openjson(features.[value] , '$.properties') geoid 
	cross apply openjson(features.[value] , '$.properties') statename
	cross apply openjson(features.[value] , '$.geometry') geomtype
	cross apply openjson(features.[value] , '$.geometry') coorobj
	cross apply openjson(features.[value] , '$.geometry.coordinates') coordinates
	where 1=1
	and geoid.[key] = 'GEOID'
	and statename.[key] = 'NAME'
	and geomtype.[key] = 'type'
	and coorobj.[key] = 'coordinates'
	and statename.[value] not in 
		('Alaska','Hawaii','Guam'
		,'Commonwealth of the Northern Mariana Islands'
		,'American Samoa','Puerto Rico'
		,'United States Virgin Islands')
go


declare @rnum int, @featurekey int, @geoid int
	, @statename as nvarchar(255), @geomtype as nvarchar(255)
	, @polygonID int, @coor nvarchar(max)

declare cur cursor for select rnum,featurekey,geoid,statename,geomtype,polygonID,coor from states
open cur fetch next from cur into @rnum,@featurekey,@geoid,@statename,@geomtype,@polygonID,@coor

while @@fetch_status = 0  begin

	declare @polygon nvarchar(max)
	
	set @polygon = 
	concat('POLYGON((',(
		SELECT STUFF ((
			SELECT ',' + point FROM 
			(	select 
				replace(replace(replace([value],'[',''),']',''),',','') point
				from OPENJSON( @coor , '$' ) coords
			) points
			for xml path('')
		), 1, 1, '')
	),'))')

	update states set geo = geometry::STPolyFromText(@polygon, 4326)
	where rnum = @rnum

fetch next from cur into @rnum,@featurekey,@geoid,@statename,@geomtype,@polygonID,@coor
end  close cur  deallocate cur
go

select * from states

