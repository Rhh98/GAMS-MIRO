<h2>Introduction:</h2>

<p>This case study is focused on routing a Cessna 182 aircraft through given thunderstorms information at minimum cost using a minimum cost network flow model.  Many aircraft crash every year due to flying  into thunderstorms, creating a need for pilots to know the best way to navigate thunderstorms hazards. There are different limitations imposed by the limits of the airplane and FAA rules and regulations for flying safety.   </p>
<p>
<img src="https://i.ibb.co/Z6wqBNM/cessnapic.jpg" width="488" height="699" alt=""  />
</p>
<p>Limitations on the aircraft include climbing and descending limits which vary depending on altitude. Velocity when cruising, climbing and descending will vary. The cost of flying at different altitudes also vary as different combustion mixtures take place at different altitudes due to increasing and decreasing air thickness levels.</p>

<p>FAA rules and regulations will be included into the model for a safe flying path to be output of the model. The FAA requires under Instrument Flight Rules (IFR) that a plane fly at 2,000 foot increments for one direction of flight. Planes flying in the opposite direction take an altitude 1,000 feet above or below. The FAA also requires oxygen for an uncompressed aircraft above 12,500 feet. Also enforced is flying at a minimum of 500 feet above the ground.</p>





<h2>   
    Example
</h2>


To be more intuitively, we will first explain the problem by giving an example, which is also shown as an default scenario of this MIRO app. 

<p>
    In this example, we have 3 thunderstorms.The first thunderstorm has its top height of 8 feet and a bottom height of 3 at x=21 nautical miles.  Then thunderstorms two and three has a top height of 12 feet  and a bottom height of 6 at x=71, 72 nautical miles.  The plane will fly for 100 nautical miles without passing through the 3 thunderstorms(clouds) by changing the altitude. The different cost for climbing, descending and crusing are set in the input data. We also confine that the plane will start at 8,000 feet and end at 8,000 feet because this is a height with cheapest cruising cost. And the plane will fly at this altitude before and after. By solving the problem, we will get a best fly path and the cost of this path. As for this setting, we will get the path as: 
    The airplane will climb from 8,000 feet to 10,000 feet to go over cloud 1.  Followed by crusing for about 40 nautical miles. Then the plane will descend to an altitude of 4,000 feet.   finish by climbing up to 8,000 feet in the end from the low of 4,000 feet.  
    <br>The picture and the flow table are shown below:
</p>



<p>
    <img src="https://i.ibb.co/Cn8b9dN/example.jpg" width="756" height="405" alt=""  />
</p>




<h1>
    Input and output of the model
</h1>


Now we explain how exactly we should use this model. To be more explicitly, we will explain what are those input and output data used for.

<h2> Input data illustration</h2>

For the input data part, we could set the information for the thunderstorms, the different cost rates and for what distance in nautical miles will we make one decision for climbing, descending or cruising. 

There are 3 input parameters to declare the information of the 3 Thunderstorms.

<ul>
    <li>xc: the x-coordinate of the 3 thunderstorms.</li>
    <li>low: the altitude of the bottom of the thunderstorms</li>
    <li>high: the altitude of the top of the thunderstorms</li>
</ul>


Note: If one wants to set less than 3 Thunderstorms, one can simply put some of the thunderstorm to have same lower and upper bound. 

The setting for cost rate are as below:

<ul>
    <li>cruise distance: how far to cruise at one decision when deciding to cruise </li>
    <li> cost to cruise : the cost to cruise at a certain altitude per 'cruise distance' miles</li>
    <li>nautical distance to climb 2k feet: how far the plane fly going up 2k feet from a certain altitude  </li>
    <li>cost of going up feet at 'upheight': The total cost of going up 2k from a certain altitude</li>
    <li>nautical distance to descend 2K feet:how far the plane fly going down 2k feet </li>
    <li>cost of going down 2k feet at 'downheight':The total cost of going down 2k feet</li> 
    <li>minheight: the lowest altitude the plane can fly at</li>
</ul>

<h2>
    Output data illustration
</h2>

The Output gives the solution of the model:

<ul>
    <li>Flow: This shows the route for the aircraft through the thunderstorm region.
    <br>If the problem is feasible, then the flying path is presented in 2 ways: a table and a plot. The table shows several nodes the aircraft will stay during the flight. And the actual flight path will just be like a piecewise linear function with breaking point being these nodes. To be more explicitly, the flight path will be displayed in the plot. The 3 vertical lines shown in the figure will be the 3 thunderstorms set. 
    <br>Else if the problem is infeasible, then a message of infeasibility will be displayed.</li>
    <li> cost: This shows the total cost during the flight generated by climbing, descending etc. </li>
    <li> Solve Status: this shows whether the model is solved. Note that with some special setting of thunderstorms, the problem could be infeasible, and the Flow plot may look very strange.</li>
</ul>


<h2> 
    Details about the data and limitation
</h2>


The default data comes from the Pilot's Operation Handbook(POH) for a Cessna 182. More details about the limitation: the various cost and speed when going up and down at different altitude, see this :  <a href="https://srv-file18.gofile.io/download/GQH3IJ/Aircraft%20limitations.md" target="_blank">Aircraft Limitation</a>


<h2>Minimum Cost Network Mathematical Formulation:</h2>

<p>After the nodes and network have been set up. The problem will be solved using a minimum cost network flow model.</p>

<p>For this problem, a start and end node is introduced. This gives a starting point and a finish point of the problem. The end is really important in the model as it is cheaper to descent, and the model will assume that the plane will continue flying at 8,000 feet (only at 8 or 10, 12 too) after finishing the route thru the thunderstorms. The plane will start at 8,000 feet which is the minimum cost of flying given the ascending cost from starting at ground level at the airport. All the arcs in the mathematical formulation below will be called A. B will be zero for all nodes but the start node will be 1 and -1 for the finish node. The cost will be in parameter C<sub>ij</sub> which will be the cost of traveling on node i to node j. X<sub>ij</sub> is a decision variable for which arcs from i to j should be travelled for minimum cost route. To ensure that all only positive distances are travelled, X<sub>ij</sub> must be positive</p>

<p>The goal or objective function is to:</p>
<p>Min ∑<sub>j:(i,j)</sub> <sub>&isin; A </sub>C<sub>ij</sub>X<sub>ij</sub></p>
<p>Subject to:</p>
<p>Model what goes in = what goes out, also referred to as flow balance.</p>
<p>∑<sub>j:(i,j)</sub> <sub>&isin; A </sub>X<sub>ij </sub>- ∑<sub>j:(j,i)</sub> <sub>&isin; A </sub>X<sub>ji</sub> = b</p>

<p>The decision variables must be positive.</p>

X<sub>ij</sub> &gt;= 0 &forall; (I,J) &isin; A



<h2>
     GAMS file link
</h2>
<a href="https://srv-file14.gofile.io/download/2mL5VO/thunder.miroapp" target="_blank">Download the model file</a>



<h2>Future Work</h2>

This problem has multiple extensions that can be added to the model.

<ul>
<li>Adding in winds to increase and decrease the ground speed of the aircraft</li>
<li>Changing the operating altitudes to allow travelling on the odd altitudes for opposite direction of travel </li>
<li>Adding in ground terrain (e.g. mountains) that the aircraft must traverse including safe operating altitude determined by the FAA</li>
<li>Adding in a third dimension (3D) allowing the plane to travel around the thunderstorm </li>
</ul>  

<br>

<h2>References</h2>
<p>Cessna Aircraft Company, Pilot's Operating Handbook and FAA Approved Airplane Flight Manual 1979 Model 182Q. Ed. D1141-13PH - RPC-2,000-8/78. Wichita, KS: n.p., October 1, 1978. Print.
</p>

