The following description is adapted from New York Times. The circuit board game is designed by Kousha Nejad.


<h2>Problem Statement</h2>
Given an initial circuit board like the following, you want to connect the points on the circuit board so that every point is connected to either one or three (never two) other points, and so that no areas are enclosed. When you're done, all the points must be interconnected (i.e. There is a connected graph formed by all edges without cycle).
<img src="" alt="Test Image"  align='right' style="width:300px;display:inline">
<h2> 
    Input and Output Data Illustration
</h2>

The model requires several inputs,

<h3>
    Input Data
</h3>

<ol>
    <li> initial line segments : the existing line segments given by the problem. Users need to specify a line by specifying the end points of it (See Table 1). 
    <li> blocked grid : some grids are black in the initial solution, meaning it is block and no line can be drawn to connect it with any of its adjacent point. (See Table 2).
    <li> board size : the board is always in square shape, but users can change its side length.
</ol>
Table 1:
|              | row 1 | col 1 | row 2 | col 2 |
| ---------- | -------| ------ | --------- | ----------------|
| Line #1 | 1       | 1      | 1          | 2                |
| Line #2 | 3       | 4      | 4          | 4                |
| Line #3 | 3       | 3      | 3          | 4                |

Table 2:
|              | row 1 | col 1 |
| ---------- | -------| ------ | 
| Blocked #1 | 5       | 6      | 
| Blocked #2 | 6      | 6      |


<h3>
    Output Data
</h3>
<ul>
    <li>the lines that will be added to the graph to make it satisfy connectivity, odd-edge, and  cycle-free constraints.
</ul>

<h2>Mathematical Formulation</h2>
Here, we mathematically formulate this problem as a network flow problem. We want to use the nature of network balance constraint to preserve the connectivity of the graph.

We first introduce the variable and parameter we use in our model. (We use the most simple way to represent our model in the following introduction. The detailed implementation may need more sets in the GAMS syntax)

<h3>Set</h3>
$N$: the set of all the nodes inside the board

$A$: the set of arcs inside the circuit board. $(i,j)$ is consider an arc if
 $i$ and $j$ are adjacent and neither $i$ nor $j$ is blocked.  $\forall i , j \in N$.

$I$: the set of initial lines $(i,j)$ given by the user input.  $\forall i , j \in N$ such that  $i$ and $j$ are adjacent and neither $i$ nor $j$ is blocked.,

<h3>parameter</h3>
$S_i$ : the supply of node $i$. If $i$ is blocked, $S_i =0$. Only one unblock node will have  $S_i = |N| - $ (# of blocked grids) $-1$. All the other unblocked nodes will have $S_i = -1$. $\forall i \in N$.

<h3>Variable</h3>
$x_{ij}$ : flow from node $i$ to node $j$.  $\forall i , j \in N$. If either $i$ or $j$ is blocked, then $f_{ij}$ is fixed to $0$.

$z_{ij}$: binary variable. 1 if either flow from node $i$ to node $j$ or flow from node $j$ to node $i$ is greater than $0$; otherwise 0. $\forall i , j \in N$ 

$t_i$ : integer variable to force the odd-edge constraint. $\forall i  \in N$ 


<h3>Constraints</h3>

<h4>1. Network Flow Constraint</h4>

$\sum_{(i,j) \in A} x_{ij} - \sum_{(j,i) \in A_{ji}} x_{ji} = S_i, $ $\forall i \in N$.

<h4>2. Construct the binary logic of $z_{ij}$</h4>

$x_{ij} + x_{ji} \leq z_{ij}M $, $\forall i , j \in N$ . ($M$ is the big-$M$ value.)

$x_{ij} + x_{ji} + (1-z_{ij}) \geq 0$, $\forall i , j \in N$ .

<h4>3. Odd-edge constraint</h4>

$\sum_{(i,j) \in A} z_{ij} = 1+2t_i$, $\forall i \in N.$ 


<h4>4. Initial line constraint (make sure initial lines exist.) </h4>

$x_{ij} + x_{ji} \geq 1$,$\forall (i , j) \in I$ .


<h4>5. Objective Function (Minimize # of arcs that have positive flow on them.)</h4>

$\min \sum_{(i,j) \in A} z_(ij)$

<h3>Additional Notes</h3>

We can extract the lines we need to draw from $z_{ij}$. If $z_{ij} =1$, that means there should be a line between $i$ and $j$ in our connected graph.

<h2>Creator</h2>
The MIRO application and the GAMS model are created by Cheng-Wei Lu.










