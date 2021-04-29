$$\text{Introduction}$$
Every day, electricity providers must use the electricity generators in their fleet to meet demand every second of the day. With significant simplifying assumptions made, this application will allow users to design their own fleet of generators and cost parameters in order to determine the least cost way to meet demand on an hourly basis. The model will schedule when to use different types of generators for one day of the year and a specific mix of generation sources. To see the effects of different parameters, the user may adjust the following:
1. The seasonal load profile to model: January, April, July or October.
1. The percentage $P_g$ (by nameplate capacity) of the following types of generators $g$ in the fleet: Coal, CC (gas combined cycle), CT (gas combustion turbine), Nuclear, Solar, Wind, Hydro.
1. The cost of coal $c_{\text{coal}}$.
1. The cost of natural gas $c_\text{gas}$.
1. The cost of CO2 emissions $c_\text{CO2}$.
1. The minimum operating level for coal plants $m_\text{coal}$ (as % of capacity).
1. The number of hours $n$ per day that hydro generators can run at full capacity.
1. The reserve margin $R$ (defined below).


Each of the load profiles is the hourly demand in the Chicago area averaged over the first 14 days of the month (January, April, July, or October) in order to demonstrate smoothed, seasonal differences in electric load. The hourly solar and wind capacity factors for each season are also averaged over the first 14 days of these months. For consistency across different choices of load profiles, the peak load $L_\text{peak}$ for all choices of parameters is the largest hourly load across all four load profiles, which occurs at 5pm in July. The default fleet mix is also that of northern Illinois as a whole. All data for the project except where stated otherwise is from the Werewolf project.

Recently, the cost of natural gas has been low, hovering generally between 1.5 and 5 dollars per million Btu (by the Henry Hub spot price according to eia.gov). The 10-year high was around 8 dollars in 2014, and the 20-year high was a very brief spike to about 18 dollars in 2003. The default value is $2.56, which is the average over the past month.

Coal pricing is more complicated as there are different types of coal that have different thermal properties and associated prices. This model uses the 2019 average for all coal types (bituminous, sub-bituminous, and lignite) of $2.02 per million Btu as the default. See www.eia.gov for more information.

Here, the reserve margin is defined as the percentage by which non-solar and non-wind resource nameplate capacities exceed $L_\text{peak}$ and is used as a way to size the fleet. If we define $S =\{ \text{coal, CC, CT, Nuclear, Hydro}\}$, then we have the maximum capacity $C$ defined by $$C = \frac{L_\text{peak}\cdot (1+R)}{\sum_{g\in S} P_g}.$$

Since solar and wind do not contribute to meeting reserve with this setup, a negative reserve margin may still meet demand, even for July. However, this definition is chosen so that a value of 0 almost guarantees demand can be met. The ${\it almost}$ is because a high percentage of hydro with a small choice of $n$ could cause problems. For example, in the extreme, a 100% hydro fleet with $n=1$ could satisfy demand at the peak hour, but nothing else. Usually, $R \geq 10\%$ and hydro makes up a small portion of a fleet, so this behavior is avoided with reasonable choices for the parameters.

$$\text{Approach}$$

The model will assume one generator of each type listed above with each capacity scaled by $(R+1) \times P_g \times C$. Generators are assumed to behave according to the following rules:
1. The gas generators (both CC and CT) have no restrictions on usage: Their output for each hour can be any value between 0 and $P_\text{CC} \cdot C$ or $P_\text{CT}\cdot C$.
1. The coal generator will be either on or off for the whole day. If it is on, then it must be generating at least $m_\text{coal}\cdot P_\text{coal} \cdot C$.
1. The nuclear generator will be on at full capacity every hour, and nuclear energy is consider free by the model.
1. Solar and wind generators will be on at their hourly capacity for every hour.
1. The hydro generator's total energy output (kWh) over the course of the day must be less than $n \cdot P_\text{hydro} \cdot C$.

These assumptions will create over-generation with certain parameters, which is consistent with the curtailment that is used in practice.

The operating assumptions for the coal generator are intended to approximate the slow ramp rates that most coal generators experience.

The assumptions for the hydro generator models the fact that many hydro generators cannot run at full capacity for all hours of the year. While this is often influenced by season and regulation, the parameter $n$ allows the user a simple way to approximate such restrictions.

$$\text{Model}$$

Given a set of generators $G$, hours $H = \{1,2,\ldots ,24\}$, and hourly loads $L_h$, the model choses an output level $x_{g,h}$ for each generator $g$ at hour $h$ that minimizes total operating cost. The model also considers the following:
1. The set $E \subset G$, $E = \{\text{coal, CT, CC}\}$ of carbon-emitting generators. Since nuclear energy is treated as free in this model, $E$ also corresponds to the set of generators for which cost varies with output.
1. The set $F \subset G$, $F = \{\text{nuclear, solar, wind}\}$ of fixed-output generators.
1. The heat rate $r_g$ for generator $g\in E$ (MBtu per kWh).
1. The CO2 emissions $e_g$ for generator $g$ (tons per MBtu).
1. The capacity factor $f_{g,h}$ for generator $g$ at hour $h$. For non-solar and non-wind generators $g$, $f_{g,h} = 1$ for every $h$.
1. The capacity $p_{g,h} = f_{g,h} \cdot P_g \cdot C$ for generator $g$ at hour $h$.
1. A "big $M$" constraint is enforced with $M = P_\text{coal} \cdot C$.

This setup yields the following mixed-integer program:

$$ \min \sum_{g \in E}\sum_{h \in H} \left( c_g + c_\text{CO2} e_g \right)r_g x_{g,h}$$
$$ \text{subject to   } \sum_{g \in G} x_{g,h} \geq L_h \quad \forall h \in H \hspace{1.5cm}$$
$$ \hspace{1.3cm} x_{g,h} \leq p_{g,h} \quad \forall h \in H, g \in G\setminus F $$
$$ \hspace{0.7cm} x_{g,h} = p_{g,h} \quad \forall h \in H, g \in F$$
$$ x_{\text{coal},h} \leq \delta M \quad \forall h \in H$$
$$ \hspace{0.4cm} x_{\text{coal},h} \geq \delta m_\text{coal} \quad \forall h \in H$$
$$ \hspace{0.6cm} \sum_{h \in H} x_{\text{hydro},h} \leq n \cdot P_\text{hydro} \cdot C $$
$$ \hspace{0.3cm} x_{g,h} \geq 0 \quad \forall h \in H, g \in G$$
$$ \delta \in \{0,1\}.  \hspace{1.9cm}$$

Feel free to run the program different parameters to explore different relationships. The output is a visualization of the following:
1. Schedule: which generators at what levels for each hour of the day. Generators can be selected for their specific schedule.

1. Totals: This shows the hourly load and aggregate generation for the day, as well as the any curtailment that occurs.

1. Source: This shows the percent of the total energy generated (i.e. kWh) that comes from each source.

1. Resource Utilization: On the left is the nameplate capacity for each generator type. On the right is the average power (i.e. total energy (kWh) divided by 24) provided by each generator over the course of the day.

1. CO2: This shows the hourly CO2 emissions by source over the course of the day.
 
$$\text{Conclusion}$$

The solution to this model is highly dependent on the input parameters, so I will discuss the solution to the default problem and some of the behaviors that can be observed by slight perturbations input. In all cases, the model must only decide how to allocate the coal, CC, CT, and hydro resources to meet demand left after nuclear, solar, and wind generation is taken into account.

Under the default parameters, we observe the following:
1. In January, the system is able to avoid using the inefficient CT. Since the coal plant must be on to meet peak, the more efficient CC is underutilized in the early morning to avoid over-generation.

1. In April, demand is so low in the morning that over-generation occurs. Even though the system could meet demand without the coal plant, it is still cheaper to over-generate with coal than use the CT. Interestingly, a carbon price of $7 is sufficient to use the CT and turn off the coal plant for the day. This corresponds to a 44.4% reduction in CO2 emissions on the day.

1. In July, the system is fairly stretched for resources, so there is not over-generation. The CC plant is used as much as possible. The coal plant is on and at 50% in the morning and ramps to 100% for the afternoon and evening. The CT plant is used as little as possible to meet demand (which is consistent with the real behavior of peaker plants like this). The hydro resource, though minimal, is used to meet peak as best it can: at full from 9am to 6pm, and then again from 9pm to 10pm.

1. The October behavior is very similar to the April behavior with a $7 per ton carbon price sufficient to choose the CT over coal. However, a higher gas price or lower coal price does return over-generation with coal to the optimal solution. 

This matches reality fairly well: CCs are usually most cost-efficient, followed by coal, then CTs. One exception is the use of coal to follow load, which occurs here more than is probably realistic. The impact of a carbon price on generator preference can be seen very quickly under some circumstances.


