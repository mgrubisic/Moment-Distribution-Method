# Moment Distribution Method (*Hardy Cross*, 1930)   

<div align='justify'>
Hardy Cross developed and formally presented the moment distribution method for analysing beams and frames in 1930. This method, unlike the slope-deflection method, is approximate and eliminates the need to solve simultaneous equations. The number of successive approximations or iterations performed determines the accuracy of the results obtained using the moment distribution. It focuses on flexural effects while ignoring axial and shear effects. Prior to the widespread use of computers in structural design and analysis, the moment distribution method was the most widely used.

The moment distribution method is an iterative approach for dealing with structures with varying degrees of indeterminacy or freedom. Engineers can manually analyse highly indeterminate structures with many degrees of freedom by using moment distribution.

The method, named after engineering professor Hardy Cross, was published in September 1932 in a concise ten-page paper. This paper, titled *"Analysis of Continuous Frames by Distributing Fixed-End Moments"*, revolutionised structural engineering by allowing for precise structural analysis.

The moment distribution method is an exact technique for calculating bending moments in beams and frames that relies on a series of successive and improved approximations.
</div>

---

**Input:**

- Define Distribution Factors                
`distributionFactorsElements` = {cell array}          
`distributionFactors`         = [array (columm vector)]           
              
- Define Carryover Factors (respectively, for the same `distributionFactorsElements`)            
`carryoverFactors`            = [array (columm vector)]                      
               
- Define Fixed-End Moments [e.g. in kNm]            
`fixedEndMomentsElements`     = {cell array}               
`fixedEndMoments`             = [array (columm vector)]

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

% a) Define Distribution Factors
distributionFactorsElements = {[2,1], [2,4], [4,2], [4,3]}'; % Value pairs of element end labels
distributionFactors         = [0.290, 0.709, 0.765, 0.235]';

% b) Define Carryover Factors (for the same Distribution Factors Elements)
carryoverFactors            = [1/2, 1/2, 1/2, 1/2]';

% c) Define Fixed-End Moments [e.g. in kNm]
fixedEndMomentsElements     = {[2,1], [2,4], [4,2], [4,3], [1,2], [3,4]}'; % Value pairs of element end labels
fixedEndMoments             = [63.91, -55.98, -55.98, 48.05, 71.49, 53.75]'; % [kNm]
```

```
%% Optional input variables

% Define Bending Moment Unit for Output
bendingMomentUnits  = "kNm"; % kNm, Nm, Nmm, kNmm, ...

% Define File Name for Output (All results are formated and saved in {outputFileName}.txt)
outputFileName      = "Structure Example Output";

% Accuracy limit in bending moment balance (0.1 "kNm" by default)
limitAccuracy       = 0.1;

% Limited total number of iterations, i.e. steps (Infinite by default)
limitIteration      = 20;
```
---     

> This Matlab algorithm for iteratively solving the **Moment Distribution Method** is used at the University of Osijek, **Faculty of Civil Engineering and Architecture Osijek**, Department of Technical Mechanics, as part of the **Structural Analysis 2** course.

> **Assist. Prof. Marin Grubišić**    
> **marin.grubisic@gfos.hr**
