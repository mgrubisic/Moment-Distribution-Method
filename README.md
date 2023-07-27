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
%% EXAMPLE #5
%  Regular Fixed Frame (2 storeys, 1 bay)

% a) Define Labels of the Elements' Ends, Distribution and Carryover Factors
%    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
%    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
%    The 3rd column of the cell array contains the CARRYOVER FACTORS

elementsDistributionAndCarryoverFactors = { [2, 1], 0.250, 1/2
                                            [2, 3], 0.277, 1/2
                                            [2, 5], 0.473, 1/2
                                            [3, 2], 0.369, 1/2
                                            [3, 6], 0.631, 1/2
                                            [5, 2], 0.219, 1/2
                                            [5, 4], 0.361, 1/2
                                            [5, 6], 0.420, 1/2
                                            [6, 3], 0.340, 1/2
                                            [6, 5], 0.660, 1/2 };
% Carryover Factor of 1/2 for Cross procedure

% b) Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm]
%    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS where there are Fixed-End Moments (FEM)
%    The 2nd column of the cell array contains the FIXED-END MOMENTS (FEM)

elementsAndFixedEndMoments  = { [1, 2], -20.64
                                [2, 1], -17.76
                                [4, 5], -65.35
                                [5, 4], -56.24
                                [2, 3],  9.34
                                [3, 2],  4.39
                                [5, 6],  31.42
                                [6, 5],  14.76
                                [2, 5],  16.62
                                [5, 2],  16.62
                                [3, 6], -9.58
                                [6, 3], -9.58 }; 
```

```
OUTPUT OF EXAMPLE #5

Accuracy limit in bending moment balance:    0.1 kNm
Limited total number of iterations (steps):  20 iterations


 1) Order of Iterations (Steps) by Nodes:
──────────────────────────────────────────
 5, 2, 6, 3, 5, 6, 2, 5, 3, 6, 2, 5, 3, 6, 2

 2) Total Number of Iterations (Steps):
────────────────────────────────────────
 15

 3) Final Balanced Bending Moments:
────────────────────────────────────
 Element :  Moment (kNm)
 ( 1,  2):  — 22.06 kNm
 ( 2,  1):  — 20.60 kNm
 ( 2,  3):  +  7.78 kNm
 ( 2,  5):  + 12.82 kNm
 ( 3,  2):  +  5.99 kNm
 ( 3,  6):  —  6.01 kNm
 ( 4,  5):  — 62.74 kNm
 ( 5,  2):  + 17.10 kNm
 ( 5,  4):  — 51.02 kNm
 ( 5,  6):  + 33.88 kNm
 ( 6,  3):  — 10.58 kNm
 ( 6,  5):  + 10.58 kNm

 4) Balance Control of Iterated Nodes:
───────────────────────────────────────
 Node   2:     0.00 kNm
 Node   3:  —  0.03 kNm
 Node   5:  —  0.05 kNm
 Node   6:     0.00 kNm

 5) All Steps of the Iteration:
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Element     Moment       5       2       6       3       5       6       2       5       3       6       2       5       3       6       2
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 ( 1,  2):   -20.64       —   -1.14       —       —       —       —   -0.24       —       —       —   -0.04       —       —       —   -0.01
 ( 2,  1):   -17.76       —   -2.27       —       —       —       —   -0.47       —       —       —   -0.08       —       —       —   -0.01
 ( 2,  3):     9.34       —   -2.52       —    1.41       —       —   -0.52       —    0.15       —   -0.09       —    0.03       —   -0.02
 ( 2,  5):    16.62    0.90   -4.30       —       —    0.49       —   -0.89    0.17       —       —   -0.15    0.03       —       —   -0.03
 ( 3,  2):     4.39       —   -1.26       —    2.81       —       —   -0.26       —    0.31       —   -0.04       —    0.05       —   -0.01
 ( 3,  6):    -9.58       —       —   -1.17    4.81       —   -0.57       —       —    0.52   -0.10       —       —    0.09   -0.02       —
 ( 4,  5):   -65.35    1.48       —       —       —    0.80       —       —    0.28       —       —       —    0.05       —       —       —
 ( 5,  2):    16.62    1.80   -2.15       —       —    0.97       —   -0.45    0.34       —       —   -0.08    0.06       —       —   -0.01
 ( 5,  4):   -56.24    2.96       —       —       —    1.60       —       —    0.56       —       —       —    0.10       —       —       —
 ( 5,  6):    31.42    3.44       —   -2.28       —    1.86   -1.10       —    0.65       —   -0.19       —    0.11       —   -0.03       —
 ( 6,  3):    -9.58       —       —   -2.35    2.41       —   -1.13       —       —    0.26   -0.20       —       —    0.05   -0.03       —
 ( 6,  5):    14.76    1.72       —   -4.56       —    0.93   -2.20       —    0.33       —   -0.39       —    0.06       —   -0.07       —
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Node        Moment       5       2       6       3       5       6       2       5       3       6       2       5       3       6       2
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    2          8.20    9.10    0.00    0.00    1.41    1.89    1.89    0.00    0.17    0.32    0.32    0.00    0.03    0.06    0.06    0.00 
    3         -5.19   -5.19   -6.45   -7.62    0.00    0.00   -0.57   -0.83   -0.83    0.00   -0.10   -0.14   -0.14    0.00   -0.02   -0.03 
    5         -8.20    0.00   -2.15   -4.43   -4.43    0.00   -1.10   -1.55    0.00    0.00   -0.19   -0.27    0.00    0.00   -0.03   -0.05 
    6          5.18    6.90    6.90    0.00    2.41    3.34    0.00    0.00    0.33    0.59    0.00    0.00    0.06    0.10    0.00    0.00 
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```
---     

> This Matlab algorithm for iteratively solving the **Moment Distribution Method** is used at the University of Osijek, **Faculty of Civil Engineering and Architecture Osijek**, Department of Technical Mechanics, as part of the **Structural Analysis 2** course.

> **Assist. Prof. Marin Grubišić**    
> **marin.grubisic@gfos.hr**
