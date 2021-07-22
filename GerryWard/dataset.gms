$title	Read Data

$if not set ds $set ds milwaukee

set	rec(*)		Records
	s(*)		Shape identifiers
	x(*)		Coordinates (longitude),
	y(*)		Coordinates (latitude),
	id(*)		Ward identifiers,
	city(*)		City names
	cnty(*)		County names
	ward(*)		Ward numbers
	mcdf(*)		"FIPS code for metro census district (?)",
	ctyf(*)		"County fips number",
	lsad(*)		"Legislative district",
	asm(*)		"Assembly district",
	sen(*)		"State senate district",
	con(*)		"Congressional district",
	csdf(*)		"County subdivision FIPS code",
	obj1(*)		"Alternative object identifier (objectid_1)",
	geoid(*)	"Geographic ID code";

$if exist '%ds%.gdx' $gdxin '%ds%.gdx'

$if exist ..\build\%ds%.gdx $gdxin '..\build\%ds%.gdx'

$load	rec s x y id city cnty ward mcdf ctyf lsad asm sen con csdf obj1 geoid

sets	citymap(id,city)	Map from ward to city,
	cntymap(id,cnty)	Map from ward to county,
	wardmap(id,ward)	Map from ward id to ward number,
	mcdfmap(id,mcdf)	Map from ward id to FIPS code for metro census district (?)
	ctyfmap(id,ctyf)	Map from ward id to County fips number
	lsadmap(id,lsad)	Map from ward id to Legislative district
	asmmap(id,asm)		Map from ward id to assembly district
	senmap(id,sen)		Map from ward id to state senate district"
	conmap(id,con)		Map from ward id to Congressional district"
	csdfmap(id,csdf)	Map from ward id to County subdivision FIPS code
	obj1map(id,obj1)	Map from ward id to object identifier (objectid_1),
	geoidmap(id,geoid)	Map from ward id to Geographic ID code
	smap(id,s)		Shapes making up each ward,
	sr(s)			Shapes with rings,
	p(x,y)			Node points;

$loaddc citymap cntymap wardmap smap sr p  
$loaddc mcdfmap ctyfmap lsadmap asmmap senmap conmap csdfmap obj1map geoidmap 

set	race /
	PRE	President
	USS	US Senate
	USH	US House
	GOV	WI Governor
	WSS	WI State Senate
	WSA	WI State Assembly
	CDA	County District Attorney
	DP	Direct petition (?),
	WAG	WI Attorney General
	TRS	WI Treasurer
	SOS	WI Secretary of State
	M	?/;

set	party /
	TOT	Total
	DEM	Democrat
	REP	Republican, REP2,
	GRN	Green
	LIB	Libertarian, LIB2,
	CON	Congressional
	IND	Independent, IND2*IND5,
	SCT	Scatter
	OTH	Other
	YES
	NO
	NA	Not associated/,

	yr Year /
	90 1990, 92 1992, 94 1994, 96 1996, 98 1998, 00 2000, 02 2002, 
	04 2004, 06 2006, 08 2008, 10 2010, 12 2012, 14 2014, 16 2016 /;

set demodata  Data column headers /
	PERSONS		"Total Population",
	PERSONS18	"Total Population over 18",
	WHITE		"Non-Hispanic White",
	BLACK		"Non-Hispanic Black + Non Hispanic Black and White",
	HISPANIC	"Hispanic Alone",
	ASIAN		"Non-Hispanic Asian + Non Hispanic Asian and White",
	AMINDIAN	"Non-Hispanic American Indian and Alaska Native ",
	PISLAND		"Non-Hispanic Native Hawaiian and Other Pacific Islander ",
	OTHER		"Non-Hispanic Some Other Race",
	OTHERMLT	"Non-Hispanic Other Multiple Race",
	WHITE18		"18 Non-Hispanic White",
	BLACK18		"18 Non-Hispanic Black",
	HISPANIC18	"18 Hispanic Alone",
	ASIAN18		"18 Non-Hispanic Asian",
	AMINDIAN18	"18 Non-Hispanic American Indian and Alaska Native",
	PISLAND18	"18 Non-Hispanic Native Hawaiian and Other Pacific Islander ",
	OTHER18		"18 Non-Hispanic Some Other Race",
	OTHERMLT18	"18 Non-Hispanic Other Multiple Race",
	nshape		"Number of shapes in ward",
	Shape__Are	"Shape area",
	Shape__Len	"Shape length"/;

parameter 
	votes(id,race,party,yr)		Voting data**********************,
	attributes(id,demodata)		Demographic data for each ward;

$loaddc votes attributes

alias (id,id1,id2), (s,s1,s2);

set	nodes(rec,s,x,y)	Nodes in the map,
	b(s1,s2)		Shapes with borders,
	common(s1,s2,x,y)	Common points;

parameter	area(s)			Area of individual shapes;
$load nodes b area common 

*

alias (asm,ad,k), (i,j,id), (s,si,sj), (smap,simap,sjmap);

parameter	n(i)	Number of persons in each ward;

n(i) = attributes(i,"persons");

parameter	nref(k)			Benchmark population by district;
nref(k) = sum(asmmap(i,k),n(i));
*display nref;

set	metric(demodata) /persons, persons18/;

parameter size(k,demodata) Benchmark district sizes (index);
size(k,metric) = sum(asmmap(i,k),attributes(i,metric))*card(k)/
		 sum(i,attributes(i,metric));
*display size;

parameter	voteshare;
voteshare(i,yr)$votes(i,"wsa","tot",yr) = votes(i,"wsa","dem",yr)/votes(i,"wsa","tot",yr);
*display voteshare;

set xy /x,y/;

parameter	center(*,*,xy)	Center points of border nodes;
center(i,"ward",xy) = sum((smap(i,s),nodes(rec,s,x,y)),x.val$sameas(xy,"x")+y.val$sameas(xy,"y")) /
		sum((smap(i,s),nodes(rec,s,x,y)),1);
center(ad,"district",xy) = sum(asmmap(i,ad), n(i) * center(i,"ward",xy)) /
		sum(asmmap(i,ad), n(i));

parameter	d(i,asm)		Distance to the geographic center;
d(i,ad) = sqrt(sum(xy,sqr(center(i,"ward",xy)-center(ad,"district",xy))));

set		centroid(id,asm)	Wards fixed to a district;
centroid(asmmap(i,ad)) = yes$(d(i,ad) = smin(i.local$asmmap(i,ad),d(i,ad)));
option centroid:0:0:1;

$if set centroid execute_load '%centroid%.gdx', centroid;

parameter centroid_temp(id);
set centroid_hess(id) * contain the centroid for Hess mode*****************;
centroid_temp(id) = sum(asm$centroid(id,asm), 1);
centroid_hess(id)$(centroid_temp(id)>0.5) = yes;
*display centroid;

*	Redefine d(i,ad) as distance to the assembly district centroid***************

d(i,ad) = sum(centroid(id,ad), 
	      sqrt(sum(xy,sqr(center(i,"ward",xy)-center(id,"ward",xy)))));

set	border(i,j)	Bordering wards (based on constituent shapes)************;

b(si,sj)$b(sj,si) = yes;

border(i,j) = yes$sum(b(si,sj)$(simap(i,si) and sjmap(j,sj)),1);
border(i,j)$border(j,i) = yes;
option border:0:0:1;
*display border;

parameter	f(i)	Fraction of voters supporting the GOP in 2010;

f(i)$votes(i,"wsa","tot","10") = votes(i,"wsa","rep","10")/votes(i,"wsa","tot","10");

*display f;

