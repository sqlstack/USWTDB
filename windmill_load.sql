drop table if exists dbo.mill
GO
CREATE TABLE [dbo].[mill]
(
	[case_id] [int] NOT NULL,
	[t_state] [varchar](100) NULL,
	[p_name] [varchar](100) NULL,
	[p_year] [int] NULL,
	[p_tnum] [int] NULL,
	[p_cap] [float] NULL,
	[t_manu] [varchar](100) NULL,
	[t_model] [varchar](100) NULL,
	[t_cap] [int] NULL,
	[t_hh] [int] NULL,
	[t_rd] [int] NULL,
	[t_rsa] [int] NULL,
	[t_ttlh] [int] NULL,
	[t_conf_atr] [int] NULL,
	[t_conf_loc] [int] NULL,
	[xlong] [float] NULL,
	[ylat] [float] NULL,
	[geo] [geometry] NULL
)
GO

-- Table must have a clustered primary key as required by the spatial index. 
-- Make sure that the primary key column exists on the table before creating a spatial index.
ALTER TABLE dbo.Mill
ADD CONSTRAINT PK_CASEID 
PRIMARY KEY CLUSTERED (case_id); 
GO

declare @json as nvarchar(max)

SELECT @json = BulkColumn
FROM OPENROWSET (BULK 'C:\SQLStack\SpatialData\uswtdbGeoJSON\uswtdb_v1_3_20190107.geojson', SINGLE_CLOB) as j

INSERT INTO dbo.MILL
select *, geometry::Point(xlong,ylat,4326) geo
from OPENJSON( @json , '$.features') WITH 
(
    case_id		int '$.properties.case_id',
	t_state		varchar(100) '$.properties.t_state',
	p_name		varchar(100) '$.properties.p_name',
	p_year		int '$.properties.p_year',
	p_tnum		int '$.properties.p_tnum',
	p_cap		float '$.properties.p_cap',
	t_manu		varchar(100) '$.properties.t_manu',
	t_model		varchar(100) '$.properties.t_model',
	t_cap		int '$.properties.t_cap',
	t_hh		int '$.properties.t_hh',
	t_rd		int '$.properties.t_rd',
	t_rsa		int '$.properties.t_rsa',
	t_ttlh		int '$.properties.t_ttlh',
	t_conf_atr	int '$.properties.t_conf_atr',
	t_conf_loc	int '$.properties.t_conf_loc',
	xlong		float '$.properties.xlong',
	ylat		float '$.properties.ylat'
)


select 
t_state ,
count(0)
from mill
group by t_state
order by t_state

delete from dbo.mill where case_id = 3063607

select * from mill