# exploring-parameters
Perceptual exploration of generative systems' parameter spaces

This repository contains a SuperCollider implementation of an algorithm for human perceptual (or aesthetic) exploration of generative systems' parameter spaces. It has been possible thanks to the help of Julian Rohrhuber. The current version is a modification and extension of a previous algorithm developed by Castro et al., in 2011.
The process starts with a parametric system in which different sets of parameters are set, and the aural impression of the output is evaluated as being part of one class within a predefined set of classes. For example, we can classify them as being in part A, B, or C, of a piece. You may also not register some sets. The sampling process, i.e which sets of values are chosen, should be taken into account. It can follow standard sampling methods or heuristic considerations. For example, we are probably interested in trying changes in one particular parameter keeping the rest fixed. Once the evaluation process is finished, the sets of parameters plus its classification are processed by the compaction algorithm. The main functionalities and processes are described below.

##Basic strict compaction
This module takes as input the set of evaluated sets or instances. Then, it performs an iterative process searching (in the given order) for each parameter (Pi), sets of instances containing all the possible values of that parameter, and sharing the same values in the rest of the parameters and in the evaluation. In that case, we can consider that Pi do not determine the class of the evaluation, given that, as long as all the other parameters have those values, the output will be the same. Then, the set of instances is compacted into one rule having a "-1" in the place of Pi, indicating that this parameter was compressed. For convention, sets having -1s are referred as rules and sets without -1 as instances. A simple example of this process is shown in the table below. Parameters P1 and P2 can take {2} and {3} discrete values, respectively, and each set can be evaluated in one of two classes {2}. In this case let us suppose that all the instances were evaluated as 1.

|num  | P1 {2} |   P2 {3} |  EVAL {2} |
|:----|:-------|:--------:|----------:|
|1    |    1   |    1     |   1       |
|2    |    2   |    1     |   1       |
|3    |    1   |    2     |   1       |
|4    |    1   |    3     |   1       |

Considering P1, instances 1 and 2 form a set containing all possible values of P1, and share the same values in P2 and in the evaluation. Then, the set is compacted into rule -1 1 1.
The set of rules is now written as:

|num  | P1 {2} |   P2 {3} |  EVAL {2} |
|:----|:-------|:--------:|----------:|
|1-2  |   -1   |    1     |   1       |
|3    |    1   |    2     |   1       |
|4    |    1   |    3     |   1       |

When we consider P2 in the resulting set, we can see that instances 3 and 4 share values in P1 and EVAL. However, rule 1-2 does not share the same value in P1. Then, although all possible values of P2 are present in the set, this cannot be compacted. Note that when the equality of the parameter values is checked the -1s are included.

##All permutations
It should be noted that the resulting set depends on the placing order of the parameters. For example, if we interchange the order of the parameters (P1 and P2) in the original set we have:

|num  | P2 {3} |   P1 {2} |  EVAL {2} |
|:----|:-------|:--------:|----------:| 
|1    |    1   |    1     |   1       |
|2    |    1   |    2     |   1       |
|3    |    2   |    1     |   1       |
|4    |    3   |    1     |   1       |

The resulting set applying the basic strict compaction is:

|num   | P2 {3} |   P1 {2} |  EVAL {2} |
|:-----|:-------|:--------:|----------:|
|1-3-4 |   -1   |    1     |   1       |
|   2  |    1   |    2     |   1       |
The process of interchanging parameters is equivalent to changing the order in which we consider the parameters to perform the search of possible sets for compaction (see next table). To refer to the different sets of rules obtained in each case, we will name the different orders of parameters by its permutation number or explicitly writing the permutation. Formalizing, we can say that with our original data we have two compaction orders (name [0,1] and [1,0]) depending on which parameter we consider first for searching the possible sets for compaction. Then, compacting first in order [0,1] and then in order [1,0], in our example we have the resulting sets:

|num  | P1 {2} |   P2 {3} |  EVAL {2} |
|:----|:-------|:--------:|----------:|
|1-2  |   -1   |    1     |   1       |
|3    |    1   |    2     |   1       |
|4    |    1   |    3     |   1       |

|num   | P1 {2} |   P2 {3} |  EVAL {2} |
|:-----|:-------|:--------:|----------:|
|1-3-4 |    1   |   -1     |   1       |
|   2  |    2   |    1     |   1       |
We are assuming that parameter combinations represent discrete points in the parameter space. Then, what is important for the aesthetic impression, is the value of the parameters and not the order in which they are enumerated. So, P1 = 2, P2 = 1 will be aesthetically perceived equal to P2 = 1, P1 = 2, given that this is only a way to enumerate the values of the parameter setting in the explored system. Then, we are saying that as long as the system have the same values in the parameters, it will produce the same aural impression in the listener. It is important to notice that the order in which the sets of parameters are presented to the listener could change the evaluation of each set, given that our ear and brain use past experience, or references, to "classify" the material. Therefore, the order in which the instances are auditioned should be taken into account during the sampling process.
If we look at the rules of the last two tables, we can see that the rules describe the same data in different ways. For our purposes we wanted to keep all the sets as valid descriptions of the information. There are many reasons to do that. For example, if we classify each instance assigning the part of the piece in which the setting can be used as class, (e.g. part A, part B, part C) we can see the -1 as free parameters, i.e parameters that can be changed to play or add variability to the part without stepping out of the desired part. In other words we want to have the greatest pallet of possibilities first, and later take the desired decisions on these sets. For that reason, the algorithm starts creating all the possible permutations in the input data, and then it applies strict compaction to each set. This algorithm returns all rule sets of the different permutations.

##Playing
After the rule extraction process, the different rules can be used to play with. To access the rules we use: <br/>

<pre>
// get rule (permutation, classifier, which)
~getRule.(0, \A, 0);
</pre>

Then, we remap the values to our system. In this implementation the values of the -1s are randomly selected among all the possible values of the parameter (or free variable).
For example:

<pre>
~rule = ~getRule.(0, \A, 5); //rule for remapping <br/>
~rule.pop; //eliminate the rule classifier for remapping <br/>
// mapping the indexes <br/>
~mapIndices.(~rule, x) <br/>
// set parameter values into Ndef <br/>
Ndef(\x).set(*~mapIndices.(~rule, x));
</pre>

##References
F. Castro, À. Nebot, and F. Mugica, 2011. “On the extraction of decision support rules from fuzzy predictive models”. Applied Soft Computing, 11 (4), 3463-3475.	

