Sets
    G Generators /Coal, CC, CT, Nuclear, Solar, Wind, Hydro/
    T(G) Thermal generators /Coal, CC, CT, Nuclear/
    R(G) Renewable generators /Solar, Wind, Hydro/
    U(G) Uncontrolled generators /Solar, Wind, Nuclear/
    OnR(G) On reserve generators /Coal, CC, CT, Nuclear, Hydro/
    S(*) Season
    H(*) Hours
;

Parameters
    cf(G,H,S)   capacity factor
    cf_wind
    cf_solar
    load(H,S)   demand kWh
    hr(G)       heat rate Btu per kWh
    em(G)       emissions tons per Btu
    cap(G,H,S)  hourly capacity
    fuel(G)     dollars per MBtu
;

Scalars
    bigM            coal on indicator constant
    hydro_tot       hydro daily limit
    peak_load       peak demand kW 
    peak_cap        peak capacity
    penalty         load shed penalty
;

$gdxin load_profiles_agg.gdx
$load H=dim1, S=dim2, load

$gdxin cf_wind_agg.gdx
$onMulti
$load H=dim1, S=dim2, cf_wind=factor

$gdxin cf_solar_agg.gdx
$load  H=dim1, S=dim2, cf_solar=factor

cf('Wind',H,S) = cf_wind(H,S);
cf('Solar',H,S) = cf_solar(H,S);
cf(OnR,H,S) = 1;

$onexternalinput
Set M(S) Month to model /'July'/;

Scalar
    carbon_price    Carbon Cost (dollars per Ton)      / 0 /
    reserve_margin  Percentage that non-solar non-wind generators exceed peak     / 15 /
    cost_gas        CC cost (dollars per MBtu)        / 2.56 /
    coal_level      Coal Minimum Operating Percent     / 50 /
    cost_coal       Coal cost (dollars per MBtu)       / 2.02 /
    hydro_hours     hours per day hydro can run at capacity     / 12 /
;

Parameter    gen_mix(G)  percentage of each generator / Coal 0.241, CC 0.089, CT 0.27, Nuclear 0.291, Solar 0.001, Wind 0.107, Hydro 0.001/;
$offexternalinput

$if not set M $set M
$if not set coal_level $set coal_level
$if not set gen_mix $set gen_mix
$if not set hydro_hours $set hydro_hours
$if not set cost_coal $set cost_coal
$if not set cost_gas $set cost_gas

* Parameter assignment
hr('Coal') = 10944;
hr('CC') = 7025.4;
hr('CT') = 12416.9;
hr('Nuclear') = 10456;
* Heat rates from IL_CHI generators in Werewolf data
em('Coal') = 215;
em('CC') = 117.0;
em('CT') = 117.0;
* Emissions data from EIA at https://www.eia.gov/tools/faqs/faq.php?id=73&t=11
fuel('Coal') = cost_coal;
fuel('CC') = cost_gas;
fuel('CT') = cost_gas;
fuel('Nuclear') = 0;
* fuel costs source:
*   https://www.eia.gov/dnav/ng/hist/rngwhhdD.htm
*   https://www.eia.gov/electricity/annual/html/epa_07_04.html - have to pick which kind of coal

peak_load = 12092;
* peak for July load profile (Werewolf)
peak_cap = peak_load*(1 + reserve_margin/100)/sum( OnR, gen_mix(OnR));

bigM = gen_mix('Coal')*peak_cap;

* hourly generation limits
cap(G,H,S) = gen_mix(G)*cf(G,H,S)*peak_cap;

* enforcing total hydro usage
hydro_tot = peak_cap*gen_mix('Hydro')*hydro_hours/24;

penalty = 1000;

binary variable coal_on coal indicator;

variable obj objective;

positive variables x(G,H) generating level, cost_op, cost_carb, cost_shed;

equations
    obj_eq          total cost
    carbon_eq       carbon cost
    operating_eq    operating cost
    demand(H,M)     meet demand
    atMax(H,U,M)
    capacity(G,H,M) hourly capacity constraint
    coal_bin(H)     coal on or off enforcement
    coal_eq(H,M)    coal minimal level enforcement
    hydro_tot_eq(M)    hydro total
;

obj_eq..        obj =e= cost_op + cost_carb;

carbon_eq..     cost_carb =e= sum( T, carbon_price*em(T)*1/(2000*1000000)*hr(T)*sum( H, x(T,H) ) );

operating_eq..  cost_op =e= sum( T, fuel(T)*(hr(T))*sum( H, x(T,H) ) )/1000000;

demand(H,M)..   sum( G, x(G,H)) =g= load(H,M);

atMax(H,U,M)..  x(U,H) =e= cap(U,H,M);

capacity(G,H,M)..x(G,H) =l= cap(G,H,M);

coal_bin(H)..   x('Coal',H) =l= coal_on*bigM;

coal_eq(H,M)..  x('Coal',H) =g= coal_on*coal_level*cap('Coal',H,M)/100;

hydro_tot_eq(M)..   sum( H, x('Hydro',H)) =l= sum( H, cap('Hydro',H,M))*hydro_hours/24;

model proj /all/;

solve proj using MIP minimizing obj;
 
sets
    F flow / Generation, Load, Curtailment /
    C comparison set / Power, Ave_power /
;

$onexternaloutput
parameter
    xval(H,G)   Hourly generation level
    tot_gen(G)  Total generation by source
    sum_x(H,S,F)  Sum of all demand and all load
    over_gen(H,S) Hourly overgeneration
    co2_em(H,T) hourly CO2 emissions (tons)
    cap_power(G,M) Total generator capacity (power)
    compare(G,C) Capacity and average power by generator
;

scalar TotalCO2 Total CO2 emissions for the day;
$offexternaloutput

xval(H,G) = x.l(G,H);
tot_gen(G) = sum( H, xval(H,G));
sum_x(H,M,'Generation') = sum(G, xval(H,G));
sum_x(H,M,'Load') = load(H,M);
over_gen(H,M)$(abs(sum_x(H,M,'Generation') - sum_x(H,M,'Load')) > 0.01) = sum_x(H,M,'Generation') - sum_x(H,M,'Load');
sum_x(H,M,'Curtailment') = over_gen(H,M);
co2_em(H,T) = xval(H,T)*hr(T)*em(T)*1/(1000000);
cap_power(G,M) = smax( H, cap(G,H,M));
compare(G,'Power') = gen_mix(G)*peak_cap;
compare(G,'Ave_power') = tot_gen(G)/24;
TotalCO2 = sum( (H,T), co2_em(H,T));
option xval:0:1:1
option sum_x:0:1:2
option over_gen:0:1:1
option co2_em:2:0:1
display
    xval
    tot_gen
    sum_x
    over_gen
    co2_em
;
