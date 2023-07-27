# Moment Distribution Method (*Hardy Cross*, 1930)   

<div align='justify'>
Hardy Cross developed and formally presented the moment distribution method for analysing beams and frames in 1930. This method, unlike the slope-deflection method, is approximate and eliminates the need to solve simultaneous equations. The number of successive approximations or iterations performed determines the accuracy of the results obtained using the moment distribution. It focuses on flexural effects while ignoring axial and shear effects. Prior to the widespread use of computers in structural design and analysis, the moment distribution method was the most widely used.

The moment distribution method is an iterative approach for dealing with structures with varying degrees of indeterminacy or freedom. Engineers can manually analyse highly indeterminate structures with many degrees of freedom by using moment distribution.

The method, named after engineering professor Hardy Cross, was published in September 1932 in a concise ten-page paper. This paper, titled *"Analysis of Continuous Frames by Distributing Fixed-End Moments"*, revolutionised structural engineering by allowing for precise structural analysis.

The moment distribution method is an exact technique for calculating bending moments in beams and frames that relies on a series of successive and improved approximations.
</div>

---
**Input:**

1. **Define Labels of the Elements' Ends, Distribution Factors and Carryover Factors in Cell Array**     
The 1<sup>st</sup> column of the cell array contains the **labels of the elements' ends**      
The 2<sup>nd</sup> column of the cell array contains the **distribution factors**      
The 3<sup>rd</sup> column of the cell array contains the **carryover factors**      
    - `elementsDistributionAndCarryoverFactors` = {cell array}             
              
2. **Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm] in Cell Array**      
The 1<sup>st</sup> column of the cell array contains the **labels of the elements' ends** where there are Fixed-End Moments (FEM)        
The 2<sup>nd</sup> column of the cell array contains the **fixed-end moments (FEM)**           
    - `elementsAndFixedEndMoments` = {cell array}               

**Optional input variables:**

3. Define Bending Moment Unit for Output     
    - `bendingMomentUnits = "kNm"; % kNm, Nm, Nmm, kNmm, ...`     
      
4. Define File Name for Output (All results are formated and saved in `{outputFileName}.txt`)      
    - `outputFileName = "Structure Example Output";`      
      
5. Accuracy limit in bending moment balance (0.1 "kNm" by default)       
    - `limitAccuracy = 0.1;`     
      
6. Limited total number of iterations, i.e. steps (Infinite by default)      
    - `limitIteration = 20;`        


**Outputs:**

- `outputStructure` - Structured output
  - `nodeIterationSequence` - Order of iterations (steps) by nodes [array (row vector)]     
  - `totalNumberofIterations` - Total number of iterations (steps) [integer]     
  - `finalBalancedBendingMoments` - Final balanced bending moments {cell array}    
  - `balanceControlofIteratedNodes` - Balance control of iterated nodes [matrix]     
  - `allStepsoftheIteration` - All steps of the iteration, for easy control and insight into the iteration process {cell array}    

- All results are formated and saved in `{outputFileName}.txt`
---
```   
%% EXAMPLE #1
%  Simple fixed portal frame structure (1 storey, 1 bay)

% a) Define Labels of the Elements' Ends, Distribution & Carryover Factors
%    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
%    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
%    The 3rd column of the cell array contains the CARRYOVER FACTORS

elementsDistributionAndCarryoverFactors = { [2, 1], 0.290, 1/2
                                            [2, 4], 0.710, 1/2
                                            [4, 2], 0.765, 1/2
                                            [4, 3], 0.235, 1/2 };
% Carryover Factor of  1/2 for Hardy Cross procedure
% Carryover Factor of -1   for Csonka-Werner procedure

% b) Define Labels of the Elements' Ends, Distribution & Fixed-End Moments (FEM) [e.g. in kNm]
%    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS where there are fixed-end moments (FEM)
%    The 2nd column of the cell array contains the FIXED-END MOMENTS (FEM)

elementsAndFixedEndMoments  = { [2, 1],  63.91
                                [2, 4], -55.98
                                [4, 2], -55.98
                                [4, 3],  48.05
                                [1, 2],  71.49
                                [3, 4],  53.75 };
```

```
OUTPUT OF EXAMPLE #1

Accuracy limit in bending moment balance:    0.1 kNm
Limited total number of iterations (steps):  20 iterations

 1) Order of Iterations (Steps) by Nodes:
──────────────────────────────────────────
 2, 4, 2, 4, 2, 4, 2

 2) Total Number of Iterations (Steps):
────────────────────────────────────────
 7

 3) Final Balanced Bending Moments:
────────────────────────────────────
 Element :  Moment (kNm)
 ( 1,  2):  + 69.65 kNm
 ( 2,  1):  + 60.23 kNm
 ( 2,  4):  — 60.23 kNm
 ( 3,  4):  + 55.21 kNm
 ( 4,  2):  — 50.99 kNm
 ( 4,  3):  + 50.96 kNm

 4) Balance Control of Iterated Nodes:
───────────────────────────────────────
 Node   2:     0.00 kNm
 Node   4:  —  0.03 kNm

 5) All Steps of the Iteration:
─────────────────────────────────────────────────────────────────────────────
 Element    Moment        2       4       2       4       2       4       2
─────────────────────────────────────────────────────────────────────────────    
 ( 1, 2):    71.49    -1.15       —   -0.60       —   -0.08       —   -0.01
 ( 2, 1):    63.91    -2.30       —   -1.19       —   -0.16       —   -0.02
 ( 2, 4):   -55.98    -5.63    4.11   -2.92    0.56   -0.40    0.08   -0.05
 ( 3, 4):    53.75        —    1.26       —    0.17       —    0.02       —
 ( 4, 2):   -55.98    -2.82    8.22   -1.46    1.12   -0.20    0.15   -0.03
 ( 4, 3):    48.05        —    2.53       —    0.34       —    0.05       —
─────────────────────────────────────────────────────────────────────────────
 Node       Moment        2       4       2       4       2       4       2
─────────────────────────────────────────────────────────────────────────────
    2         7.93     0.00    4.11    0.00    0.56    0.00    0.08    0.00 
    4        -7.93   -10.75    0.00   -1.46    0.00   -0.20    0.00   -0.03 
─────────────────────────────────────────────────────────────────────────────
```
---     

> This Matlab algorithm for iteratively solving the **Moment Distribution Method** is used at the University of Osijek, **Faculty of Civil Engineering and Architecture Osijek**, Department of Technical Mechanics, as part of the **Structural Analysis 2** course.

> **Assist. Prof. Marin Grubišić**    
> **marin.grubisic@gfos.hr**
