<h1> 
    Air Ambulance Reassignment Problem
</h1>

<h2>
    Problem Statement
</h2>
<img src="https://neos-guide.org/sites/default/files/u2/zepper.jpg" alt="Test Image"  align='right' style="width:300px;display:inline">An air ambulance (helicopter) service provider has a set of locations with a number of helicopters assigned to each site. Within each site's defined service area, requests are satisfied by the helicopters assigned to that site. At the end of each time period, the service provider updates the projected demand for each site and determines whether any of the helicopters need to be reassigned. There is a transportation cost associated with reassigning a helicopter to a different site. Therefore, the service provider wants to determine a minimum cost assignment of helicopters to sites to satisfy the next period's projected demand at each site.

As an example, consider an air ambulance service provider with 5 locations in the Midwest. The company evaluates the need to relocate helicopters based on the monthly projected demand for each location. The cost of reassigning a helicopter from site ii to site jj is $100 per kilometer of distance from site \(i\) to site \(j\). For each of the company's locations, the table below lists the \(x\) and \(y\) coordinates of the site, the number of helicopters currently assigned, and the projected demand for the next period.

|             | X - Coord | Y-Coord | # Assigned | Projected Demand |
| ----------- | --------- | ------- | ---------- | ---------------- |
| Location #1 | 36        | 20      | 6          | 7                |
| Location #2 | 23        | 30      | 2          | 3                |
| Location #3 | 23        | 56      | 3          | 2                |
| Location #4 | 10        | 15      | 3          | 4                |
| Location #5 | 5         | 5       | 4          | 2                |

<h2> 
    Input and Output Data Illustration
</h2>

To understand how to use this model to solve the problem, several inputs are required and several outputs are displayed.

<h3>
    Input Data
</h3>

<ul>
    <li> location: this will requires the information of the x and y coordinates of the sites that will be assigned helicopters. User should enter the x and y coordinates as real number along with the unique id of each site. Note the number of x coordinates should coinside with the y coordinate.</li>
    <li>projected demand: the demand for helicopters in each site</li>
    <li>units currently assigned: the current number of helicopter in each site </li>
</ul>

<h3>
    Output Data
</h3>
<ul>
    <li>helicopter reassignment: A digraph shows the reassignment of helicopters among all the sites. The helicopters will be reassigned from the head of arcs to the tail of the arcs. The number of reassigned helicopter in this arc is the weight shown on the arc. One can also see the data table by clicking the "switch view" button on the top right corner. </li>
    <li> number of helicopters in L: A datatable and a barplot is displayed to show the distribution of the helicopters among all the sites. There are three numbers for each site, the first one is for the previous number of helicopters before the reassignment, the second one is for the demand of helicopters in that site, the third one is for the current number of the helicopters after the reassignment.</li>
</ul>






<h2>
    Mathematical Formulation
</h2>

Given the set of locations, the pairwise distances between locations, the number of helicopters currently assigned to each location, the projected demand for each location, and the cost per kilometer, the objective of the Air Ambulance Reassignment Problem is to determine a minimum cost set of reassignments to satisfy projected demand. The problem can be formulated as a linear programming problem because the objective function and the constraints are all linear functions. The pairwise distances are computed as the Euclidean distance.



**Set**

L​= the set of locations

**Parameters**

x<sub>i</sub> = the x-coordinate for location i, ∀i∈L∀i∈L

y<sub>i</sub> = the y-coordinate for the location i, ∀i∈L

d<sub>i</sub> = projected demand for the next period for location i, ∀i∈L

s<sub>i</sub> = number of helicopters currently assigned to location i, ∀i∈L

c​ = transportation cost per kilometer

dist<sub>ij</sub> = Euclidean distance between location i and location j, ∀i∈L, ∀j∈L

dist<sub>ij</sub> = √((x<sub>j</sub>−x<sub>i</sub>)^2 +(y<sub>j</sub>−y<sub>i</sub>)^2)

**Variables**

z<sub>ij</sub> = number of helicopters to be moved from location i to j, ∀i∈L, ∀j∈L

**Objective Function**

Minimize ∑<sub>(i,j)∈L×L</sub>dist<sub>ij</sub>∗c∗z<sub>ij</sub>

**Constraints**

There are two cases when building the model:

<ul> 
    <li>Case 1: the total demand number of helicopters is larger than the total number of current assigned helicopters:
    <br>When this is the case, the flow balance constraint will be:
    <br>∑<sub>j∈L</sub> z<sub>ji</sub>+s<sub>i</sub>>=d<sub>i</sub>+∑<sub>j∈L</sub>z<sub>ij</sub>,∀i∈L </li>
    <li>Case 2: the total demand number of helicopters is smaller than or equal to the total number of current assigned helicopters.
    <br>When this is the case, the flow balance constraint will be:
    <br>∑<sub>j∈L</sub> z<sub>ji</sub>+s<sub>i</sub><=d<sub>i</sub>+∑<sub>j∈L</sub>z<sub>ij</sub>,∀i∈L </li></li>
    </ul>







<h2>
    GAMS Model
</h2>

The GAMS model can be downloaded <a href="static_airambulance/AirAmbulance.gms" target="_blank">here</a>.
