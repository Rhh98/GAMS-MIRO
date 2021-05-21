## Introduction

Gerrymandering refers to a strategy where politicians try to maximize the votes they get by redistricting and manipulating district boundaries. The term gerrymandering got its first appearance in 1810s with Elbridge Gerry, the Governer of Massachusetts at that time, signing a bill that created a partisan distict in the Boston area that was compared to the shape of a mythological salamander.

<img src="https://i.ibb.co/9chzKHh/gerrymander-pic.jpg" width="250" height="350" alt=""/>



The challenge of such problem comes from two sources. First, if we formulate such problem with upper and lower bound on the total population of a distict, then this problem is acutally a knapsack problem. Second, in the real world scenario, usually all the units in a district should be **connected**, which means that given a pair of units assigned to the same district, there must be a path between them. My main focus and the main contribution on this project is to solve the latter problem, where I formulated connectivity constraints that allow redistricting with connectivity. Different gerrymandering strategy can be combined with the connectivity constraints.

In this application, there are 2 kinds of objective functions users can choose basen on their goals. The first objective is to optimize for fairness, which means the number of winning districts for a party best represents the ratio of total votes it gets within a given state. The second objective is to optimize for a given party so that the chosen party gain as many electoral votes as it can. We use the original votes for each party in a county (unit) and the adjancey matrix among all the counties(units) to achieve such goal and at the same time maintaining the connectivity within every district that is assigned to.

This document would be presented in the following order. In section 2 and 3, I will illustrate the input and  output format for this application respectively. In section 4, I will introduce the output visualizations and the information such visualizations could provide us. Lastly, I will provide the mathematical formulation (for the Optimize for Fairness case) for this model.

## Input Format

I use the Wisconsin state data from [2016 US election](https://public.opendatasoft.com/) (The original dataset is removed from this given link by the creator) and the [county adjacency data](https://www.census.gov/geographies/reference-files/2010/geo/county-adjacency.html) as the default data for my model. The detailed inputs for this model are as follows:

1. Adjacency csv file: the adjacecny matrix of counties in a specific state in America. The first two columns are the fips code of a pair of counties. If two counties are adjacent, then the corresponding value will be 1. If not, then it will be -1. Ex.
| Fips     | Fips     |  1 or -1 |
| -------- | -------- | -------- |
| 55001    | 55003    | -1       |
| 55001    | 55005    | -1       |

2. County vote csv file: the file should contain the votes that Demoncrats and Republicans get in a given state. The first column will be the fips code of a county and the second column will be the party. The last column will be the votes corresponding party and county in that row.<br>Ex.
| Fips     | Party       |  Votes   |
| -------- | ----------- | -------- |
| 55001    | Republicans | 5983     |
| 55001    | Democrats   | 3780    |

3. Number of districts to be assigned : an integer value that allows users to determined the number of districts tha will exist after the reassignment (Changing this will lead to a failure to use initial point).
4. Population upper and lower bound (ratio compared with average population for a district): two fraction values to impose bound on population in each district to maintain fairness
5. Lambda : a parameter to add weight to the penalty to make the population difference between max district and min district smaller.
6. Choice of Objective : Users can choose to optimize for fairness (assign units to districts fairly) or optimize for a given party.
7. Choice of Party to Optimize for : This input parameter will matter only if the Choice of Objective is to optimize for a given party.
## Output Format
The output will be suggested redistricted maps with fips code and the winning party of each district. We also provide population visualization of each district via bar chart. <br>


## Mathematical Formulation
We formulate this problem as a mixed integer programming problem.

Ensuring connectivity in a district is essentially a network flow problem. For example, given a graph $G = (V,E)$, to see if $G$ is a connected graph, we can randomly pick a vertice $v \in V$ and give it an inital supply with value of $|V|-1$. For each point in $V - \{v\}$, we can give it a demand value of 1(equivalent to supply value of -1). After we do that, we can ensure the total demand is equal to the total supply in $G$.<br><br>
$1 \times (|V|-1) + |V - \{v\}| \times (-1) = 0$ <br><br>
Then the search for connectivity in graph $G$ is equivalent to the search for feasible solutions for the network flow problem, where a single supply node needs to pass its supply to the all other nodes in the same graph with demand 1. That is, the connectivity exists in $G$ if and only if there is a feasible solution for the corresponding network flow problem. <br><br>
Therefore, to ensure connectivity exists in every district, we have to formulate **network flow constraints** for each of them. In the following mathematical formulation, I will divide my model into two parts - the gerrymandering related equations and connectivity constraints.

Another very important implicit constraint in gerrymandering problem is that we have to maintain the fairness for each district, which means the number of total votes in each district should not vary too much. For example, if the total votes in  𝑑1  is 2000 and the total votes in  𝑑2  is 100, it is more reasonable for  𝑑1  to have more "congressional votes."  I therefore assume that there will be 100 congressional votes in total, and the votes gained by a party in a district is proportional to the total votes in that district. Also, the congressional votes for a district can be floats. Since the votes for a district is proportional to the total votes in that district, **fairness** is conserved. 

Considering the details stated above, the problem is formulated as follows:

$
D : \text{the set of all districts}
$

$
I : \text{the set of all units to be assigned}
$

$
P : \text{the set of 2 parties - Republicans and Democrats}
$

$
N_{ip} : \text{number of votes for party $p$ in $i$ }, \forall i \in I, p \in P
$

$
A_{ij} : \text{the set of edge that exist between i and j}. i,j \in I, 
$

$
M : \text{big M for logical constraints}
$

$
R : \text{the ratio given by } \frac{\text{total Democrats vots}}{\text{total Republicans vots}}
$

$
\lambda : \text{Penalty weight in the objective function} 
$

$
a_{id} : \text{1 if unit i is assigned to district d; otherwise 0. } \forall i \in I, d \in D
$

$
r_{di} : \text{1 if unit i is the root of district d; otherwise 0.(root unit is equivalent to the supply node described in the start of section 2) } \forall i \in I, d \in D 
$

$
b_{id} : \text{1 if unit i is assigned to district d and is not a root in district d; otherwise 0. } \forall i \in I, d \in D
$

$
x_{dij} : \text{The flow from i to j in district d. } \forall i,j \in I, d \in D
$

$
z_{d} : \text{1 if Republicans win in district d; otherwise 0. } \forall d \in D
$

$
p_{d} : \text{total votes in district $d$, }  d \in D
$




$$\min_{a_id : \forall i\in I, d \in D} |(|D|-\sum_{d} z_{d}) - R\times\sum_{d} \ z_{d} \tag{obj}| + \lambda(\max_{d\in D}{p_d} - \min_{d\in D}{p_d})$$ 

$$\text{s.t.} p_{d} = \sum_{i \in I}( a_{id} \times \sum_{p \in P} N_{ip}) \tag{1}$$


$$ \sum_{i \in I} a_{id} \geq 1, \forall d \in D \tag{2}$$

$$\sum_{i\in I}(a_{id}\times (N_{i,Republicans} - N_{i,Democrats})) - M \times z_d \leq 0, \forall d \in D \tag{3(a)}$$

$$\sum_{i\in I}(a_{id}\times (N_{i,Republicans} - N_{i,Democrats})) + (-M-1) \times z_d \geq -M, \forall d \in D \tag{3(b)}$$

$$\sum_{d\in D}a_{id} = 1, \forall i \in I \tag{4}$$


$$\sum_{i\in I}r_{di} = 1, \forall d \in D \tag{5}$$

$$r_{di} \leq a_{id}, \forall i \in I, \forall d \in D \tag{6}$$

$$x_{dij} \leq M \times a_{id}, \forall i,j \in I, \forall d \in D \tag{7(a)}$$

$$x_{dij} \leq M \times a_{jd}, \forall i,j \in I, \forall d \in D \tag{7(b)}$$

$$a_{id}  + (1-r_{di}) - b_{id} \leq 1 , \forall i \in I, \forall d \in D \tag{8(a)}$$

$$a_{id}  + (1-r_{di}) - 2*b_{id} \geq 0 , \forall i \in I, \forall d \in D \tag{8(b)}$$

$$\sum_{j:(i,j)\in A} x_{dij} - \sum_{j:(j,i)\in A} x_{dji} - (\sum_{j \in D} a_{jd} - 1) + r_{d,i}\times M \leq M, \forall i \in I, \forall d \in D \tag{9(a)}$$

$$\sum_{j:(i,j)\in A} x_{dij} - \sum_{j:(j,i)\in A} x_{dji} - (\sum_{j \in D} a_{jd} - 1) + r_{d,i}\times (-M) \geq (-M), \forall i \in I, \forall d \in D \tag{9(b)}$$

$$\sum_{j:(i,j)\in A} x_{dij} - \sum_{j:(j,i)\in A} x_{dji} +1 + b_{id}\times M \leq M, \forall i \in I, \forall d \in D \tag{10(a)}$$

$$\sum_{j:(i,j)\in A} x_{dij} - \sum_{j:(j,i)\in A} x_{dji} +1 \geq 0, \forall i \in I, \forall d \in D \tag{10(b)}$$

$$a_{id} \in \{0,1\}, r_{di} \in \{0,1\}, b_{id} \in \{0,1\}, \forall i \in I, \forall d \in D  $$

$$𝑧_𝑑 \in \{0,1\}, \forall d \in D$$

$$x_{dij} \geq 0 , \forall d \in D, \forall i,j \in I$$

(obj) is our objective function. Our task is to minimize the difference between the proportion of total votes between two parties and the number of proportion of winning districts in our assignment.

From equation (1) to equation (3(b)), those are the gerrymandering equations. Equation (1) calculates the sum of all original votes in a district.  Equation (2) represents constraint that each district should contain at least one node. Equation (3(a)) and (3(b)) is how we construct the binary logic of variable $z_d$.

Equation (4) to equation (10(b)) are connectivity constraints. Equation (4) ensures that a unit is assigned to exactly one district. Equation (5) esures that each district only has one root. Equation (6) means that only if a unit is assigned to a given district can it be the root of it. Equation (7(a)) and (7(b)) limit the flow between unit $i$ and unit $j$ in district $d$ to be $0$ if at least one of $i$ or $j$ is not assigned to $d$. Equation (8(a)) adn (8(b)) is how we construct the binary logic of $b_{id}$. Equation (9(a)) and (9(b)) are used to construct the network flow equations for root node. Therefore, if a unit $i$ is the root for district $d$, $r_{id}$ will be 1 and (9(a)) and (9(b)) will be binding under the effect of each other. Similarly,  Equation (10(a)) and (10(b)) are used to construct the network flow equations for non-root nodes that are assigned to district $d$.


## References
1. Wikipedia contributors. "Gerrymandering." Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, 10 Feb. 2021. Web. 10 Feb. 2021.
2. Gerrymander drawing. Digital image. Smithsonian Magazine. https://www.smithsonianmag.com/history/where-did-term-gerrymander-come-180964118/

