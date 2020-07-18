# Allocate model for group testing in Wisconsin

<center>Michael C. Ferris and Yuhao Wang </center> 

<center> May 21, 2020 </center>

## Problem Introduction

Now there are serious situation caused by the covid-19. Since several sources
are not sufficient for testing each individual, group testing is necessary.
Group testing is a much more economic way for testing. Multiple people
can be tested using source usually for a single person. However, the accuracy
will decrease using group test. The test procedure could be split into 3 main
steps: collection of the samples, allocation from centers to labs and analysis
at labs. Once samples are collected at centers, this model will help to determine
what group testing strategy should each labs use and how should we
allocate these samples(kits) from centers to labs, obtaining as much correct
result as possible.

## Input Data Specification

To use this model, several input parameters are required:

• prevalence: A current prevalence rate of covid-19 is needed. Note multiple
prevalence rate is also allowed. People in different environment
may have different potential to be infected.

• efficiency for different prevalence: Setting a tolerance of efficiency with
respect to the prevalence rate. Only group sizing has efficiency higher
than the setting value will be adopted. The efficiency here is defined
as the ratio of the expected number of known testing result and the
total testing number.

• Maximal distance for transportation: a maximal distance should be
set. A kit will not be transported from a center to a lab if the distance
between the 2 places is bigger than the maximal distance.

• Importance of different prevalence t test: For different prevalence, the
priority for testing may vary. This parameter set a relative favor for
each prevalence by giving certain numbers.
(Maybe ordering is a better choice instead of giving specific number)

• centers/labs : Give an index to each center or lab. The index could be
any text. e.g. c1,...,cn stands for n centers.

• locations of centers and labs: Giving the information of the labs and
centers by giving 2 coordinates for each place.
(Linking to a map such as google map for user to search for the position
may be better).

• center collection: The information of collection for each center, signed
with setting prevalence.

• runsize of labs: The running size for each lab. The running size is the
number of testing a lab could do for a single round.
(Here we are assuming each round takes up 5 hours in every lab, which is true for all prevalence .)

## Output Data Specification

The result shows:

• allocate strategy: How should we allocate the kits from centers to labs.  One can click on markers to filter flow, leaving those only relevant to the clicked lab/center. An "all" check box on the right top can be selected to show all flows.

• kits to test in labs l: This shows the number of kits of different prevalence
in each lab. The kits are separated into 2 classes： the normal class and the extra class. The kits in normal classes are going to be tested with a certain batch size. The kits in the extra classes will only be tested individually.

• operation in lab l: This shows for each lab, what operation should
they do. The result include for what batch size should be used, how
many rounds for this batch size. An extra round means that test all
the unknown result in previous testing in batch size equal to 1. The
number of batches should be no more than the runsize of the lab.

• Kits left in centers: A bar charts showing the kits that are not allocated to labs in each
center of each prevalence.

• alltest/leftover/pcplus scalar: "alltest" denotes he total number of kits tested. "leftover" denotes the
number of kits left over with unknow results, "pcplus" denotes the percentage of how many unknow kits left over is contained on the total kits tested.

### Details about operation in lab:

In each lab, there are 4 rounds of operation in total in each lab. Each operation could take up either 1, 2, 3 or 4 rounds. In the output data "operation in lab l". There will be 7 indices for each operation as the following picture shows. 

![pic](https://i.ibb.co/BKXMDZ2/image-20200525162421042.png)

As the pictures shows, in lab l2, there are 2 operations. The first operation is to test kits of batch size 8. This test will cost 2 rounds out of 4. And we will repeat this operation once. The prevalence of the kits included in this operation is 0.04. There will be 62.5 batches in this operation. Note that the batch size is 8, so we have 62.5*8 =500 kits. The lab can test with 62 batches of size 8 and 1 of size 4. Moreover, since the run size of this lab is larger than the number of batches, there are still 33 extra position left. So we can actually do some test for some single kits in these positions. The number of extra kits transported to lab is listed in the output "kitsinl". The second operation is to do some extra round for single kits. These kits could have any prevalence. And they could be either the kits  not tested yet or the kits tested with unknown result. We repeat this operation for 2 times. Each time we will just test as many single kits as possible.



<h2>
    GAMS Model
</h2>

The GAMS model can be downloaded <a href="static_allocate_miro3/allocate_miro3.gms" target="_blank">here</a>.



## Limitation

•In this model we have a fixed common running time for each round in each lab, which is 5 hours. In reality the running time for each round may vary for different prevalence and labs. If the total number of round changes, then the embedding GAMS model should be modified. Generalization for different round time could be realized，but this will lead to worse relaxation, which may make the model harder to solve.

•Accuracy: The model aims to maximize the number of total kits tested as positive or negative. There are 2 approximation about the expected kits with known results during computation. However, both of the 2 approximation are pessimistic. So actually the real result might be better than the output. 
