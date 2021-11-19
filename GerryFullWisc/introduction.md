<h2>Introduction</h2>

Gerrymandering refers to a strategy where politicians try to maximize the votes they get by redistricting and manipulating district boundaries. The term gerrymandering got its first appearance in 1810s with Elbridge Gerry, the Governer of Massachusetts at that time, signing a bill that created a partisan distict in the Boston area that was compared to the shape of a mythological salamander.

<img src="https://i.ibb.co/9chzKHh/gerrymander-pic.jpg" width="300" height="350" alt=""/>

Fair Gerrymandering strategy has been discussed recently to ensure some sort of fairness is maintain while constructing a new district assignment strategy. Such fairness includes population bounds (i.e. all districts should have roughly the same population), contiguity constraints (i.e. all unit assigned to a district should be connected), and the pursuit of compactness (i.e. we prefer a compact district rather than a long thin district. ) 

For our application, we have designed an algorithm to generate strategies effectively and stored it in our database. The GAMS MIRO application can pick the GerryMandering strategy that best fits a user's objective that can be adjusted by the user input.

<h2>User Input</h2>
We use the[ Wisconsin ward-level election and shape data](https://data-ltsb.opendata.arcgis.com/datasets/f67c2e7f43bb432687b4a42bee50a16c_0/explore?location=44.774376%2C-89.815220%2C7.69) from 2020 US election.

1. Objective : Users can choose to do GerryMandering in favor of Republicans or Democrats.

2. Population Bounds : Users can choose the bounds for the population for districts. Small bounds mean the variance across district population should be small, while large bounds mean the difference among district populations can be large.

3. Compactness : Users can choose the importance of compactness with 0 meaning no compactness is considered, and 1 meaning only compactness is considered. 

4. Specific Scenario Choice : Users are able to fetch a specific scenario in the database.

<h2>Output</h2>
1. A strategy map that details the assignment of every ward in Wisconsin.

2. The population distribution for each district.

3. The interactive graph that allows users to see the distribution of strategies given a population bound.