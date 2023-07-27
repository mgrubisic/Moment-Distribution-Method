%{
┌── Author's Information ────────────────────────────────────────────────────────┐
│                                                                                │
│   Marin Grubišić                                                               │
│   Assistant Professor | MEng, PhD                                              │
│   University of Osijek, Faculty of Civil Engineering and Architecture Osijek   │
│   Department of Technical Mechanics                                            │
│   3 Vladimir Prelog Street (University Campus), Office II.26 (2nd floor)       │
│   HR-31000 Osijek, Croatia, Europe                                             │
│                                                                                │
│   E-mail:   marin.grubisic@gfos.hr    | marin.grubisic@gmail.com               │
│   Tel.:     +385 95 823 15 75         | +385 91 224 07 92                      │
│   Web:      www.maringrubisic.com     | github.com/mgrubisic                   │
│   Social:   linkedin.com/in/mgrubisic | twitter.com/mgrubisic                  │
│   Update:   5.6.2014. / 29.4.2017.                                             │
│                                                                                │
└────────────────────────────────────────────────────────────────────────────────┘
%}

%{
MOMENT DISTRIBUTION METHOD (Hardy Cross, 1930)
    Hardy Cross developed the moment distribution method for structural analysis of
    statically indeterminate beams and frames. It was published in an ASCE journal
    in 1930. The method only takes flexural effects into account and ignores axial
    and shear effects.
%}

clc; clear all; close all; format compact

%% Optional input variables

% Define Bending Moment Unit for Output
bendingMomentUnits  = "kNm"; % kNm, Nm, Nmm, kNmm

% Define File Name for Output (all results are formatted and saved in "{outputFileName}.txt")
outputFileName      = "Structure Example Output";

% Accuracy limit in bending moment balance (0.1 "kNm" by default)
limitAccuracy       = 0.1;

% Limited total number of iterations, i.e. steps (Infinite by default)
limitIteration      = 20;


%% EXAMPLE #1
%  Simple Fixed Portal Frame Structure (1 storey, 1 bay)

% a) Define Labels of the Elements' Ends, Distribution and Carryover Factors
%    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
%    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
%    The 3rd column of the cell array contains the CARRYOVER FACTORS

elementsDistributionAndCarryoverFactors = { [2,1], 0.290, 1/2
                                            [2,4], 0.710, 1/2
                                            [4,2], 0.765, 1/2
                                            [4,3], 0.235, 1/2 };
% Carryover Factor of  1/2 for Cross procedure
% Carryover Factor of -1   for Csonka-Werner procedure

% b) Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm]
%    The 1st column of the cell array contains the labels of the elements' ends where there are Fixed-End Moments (FEM)
%    The 2nd column of the cell array contains the Fixed-End Moments (FEM)

elementsAndFixedEndMoments  = { [2,1],  63.91
                                [2,4], -55.98
                                [4,2], -55.98
                                [4,3],  48.05
                                [1,2],  71.49
                                [3,4],  53.75 };


%% EXAMPLE #2
%  Simple Beam (3 bays)

% % a) Define Labels of the Elements' Ends, Distribution and Carryover Factors
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
% %    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
% %    The 3rd column of the cell array contains the CARRYOVER FACTORS
% 
% elementsDistributionAndCarryoverFactors = { [2, 1], 3/11, 0
%                                             [2, 3], 8/11, 1/2
%                                             [3, 2], 8/12, 1/2
%                                             [3, 4], 4/12, 1/2 };
% % Carryover Factor of  1/2 for Cross procedure
% % Carryover Factor of -1   for Csonka-Werner procedure
% % 
% % b) Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm]
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS where there are Fixed-End Moments (FEM)
% %    The 2nd column of the cell array contains the Fixed-End Moments (FEM)
% 
% elementsAndFixedEndMoments  = { [2, 1], -13.65
%                                 [2, 3],  8.333
%                                 [3, 2], -8.333
%                                 [3, 4],  25
%                                 [4, 3], -25 };


%% EXAMPLE #3
%  Simple Regular Bridge Structure (4 columns, 5 bays)

% % a) Define Labels of the Elements' Ends, Distribution and Carryover Factors
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
% %    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
% %    The 3rd column of the cell array contains the CARRYOVER FACTORS
% 
% elementsDistributionAndCarryoverFactors = { [6,1],  4/15, 1/2
%                                             [6,5],  1/5,  0
%                                             [6,7],  8/15, 1/2
%                                             [7,2],  1/4,  1/2
%                                             [7,6],  1/4,  1/2
%                                             [7,8],  2/4,  1/2
%                                             [8,3],  1/8,  1/2
%                                             [8,7],  4/8,  1/2
%                                             [8,9],  3/8,  1/2
%                                             [9,4],  4/13, 1/2
%                                             [9,8],  4/13, 1/2
%                                             [9,10], 5/13, 0 };
% % Carryover Factor of  1/2 for Cross procedure
% % Carryover Factor of -1   for Csonka-Werner procedure
% 
% % b) Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm]
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS where there are Fixed-End Moments (FEM)
% %    The 2nd column of the cell array contains the Fixed-End Moments (FEM)
% 
% elementsAndFixedEndMoments  = { [1,6], -28
%                                 [6,1], -14
%                                 [7,8],  25
%                                 [8,7], -25 };


%% EXAMPLE #4
%  Complex Irregular Frame (3 storeys, 3 bays)

% % a) Define Labels of the Elements' Ends, Distribution and Carryover Factors
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
% %    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
% %    The 3rd column of the cell array contains the CARRYOVER FACTORS
% 
% elementsDistributionAndCarryoverFactors = { [4,  3], 9/28,  0
%                                             [4,  1], 1/7,   1/2
%                                             [4,  5], 3/28,  1/2
%                                             [4,  8], 3/7,   1/2
%                                             [5,  4], 6/55,  1/2
%                                             [5,  2], 16/55, 1/2
%                                             [5,  6], 9/55,  0
%                                             [5,  9], 24/55, 1/2
%                                             [8,  7], 1/5,   0
%                                             [8,  4], 2/5,   1/2
%                                             [8,  9], 1/5,   1/2
%                                             [8, 10], 1/5,   1/2
%                                             [9,  8], 2/7,   1/2
%                                             [9,  5], 4/7,   1/2
%                                             [9, 11], 1/7,   1/2
%                                             [10, 8], 2/3,   1/2
%                                             [10,11], 1/3,   1/2
%                                             [11,10], 1/2,   1/2
%                                             [11, 9], 1/2,   1/2 }; 
% % Carryover Factor of  1/2 for Cross procedure
% % Carryover Factor of -1   for Csonka-Werner procedure
% 
% % b) Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm]
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS where there are Fixed-End Moments (FEM)
% %    The 2nd column of the cell array contains the Fixed-End Moments (FEM)
% 
% elementsAndFixedEndMoments  = { [1, 4],  -38.33 
%                                 [4, 1],  -18.67 
%                                 [4, 5],   30
%                                 [5, 4],  -30 
%                                 [4, 8],   20 
%                                 [8, 4],  -20 
%                                 [5, 9],  -52.5
%                                 [9, 5],   52.5 
%                                 [8, 9],   13.33 
%                                 [9, 8],  -13.33 
%                                 [10, 11], 13.33  
%                                 [11, 10], 36.67 };


%% EXAMPLE #5
%  Regular Fixed Frame (2 storeys, 1 bay)

% % a) Define Labels of the Elements' Ends, Distribution and Carryover Factors
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
% %    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
% %    The 3rd column of the cell array contains the CARRYOVER FACTORS
% 
% elementsDistributionAndCarryoverFactors = { [2,1], 0.250, 1/2
%                                             [2,3], 0.277, 1/2
%                                             [2,5], 0.473, 1/2
%                                             [3,2], 0.369, 1/2
%                                             [3,6], 0.631, 1/2
%                                             [5,2], 0.219, 1/2
%                                             [5,4], 0.361, 1/2
%                                             [5,6], 0.420, 1/2
%                                             [6,3], 0.340, 1/2
%                                             [6,5], 0.660, 1/2 };
% % Carryover Factor of  1/2 for Cross procedure
% 
% % b) Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm]
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS where there are Fixed-End Moments (FEM)
% %    The 2nd column of the cell array contains the Fixed-End Moments (FEM)
% 
% elementsAndFixedEndMoments  = { [1,2], -20.64
%                                 [2,1], -17.76
%                                 [4,5], -65.35
%                                 [5,4], -56.24
%                                 [2,3],  9.34
%                                 [3,2],  4.39
%                                 [5,6],  31.42
%                                 [6,5],  14.76
%                                 [2,5],  16.62
%                                 [5,2],  16.62
%                                 [3,6], -9.58
%                                 [6,3], -9.58 }; 


%% EXAMPLE #6
%  Two Storey Half-Frame Structure for Csonka-Werner Iteration Procedure (2 storey half-frame)

% % a) Define Labels of the Elements' Ends, Distribution and Carryover Factors
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
% %    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
% %    The 3rd column of the cell array contains the CARRYOVER FACTORS
% 
% elementsDistributionAndCarryoverFactors = { [2, 1], 0.136, -1
%                                             [2, 3], 0.150, -1
%                                             [2, 4], 0.713,  0
%                                             [3, 2], 0.174, -1
%                                             [3, 5], 0.826,  0 };
% % Carryover Factor of  1/2 for Cross procedure
% % Carryover Factor of -1   for Csonka-Werner procedure
% 
% % b) Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm]
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS where there are Fixed-End Moments (FEM)
% %    The 2nd column of the cell array contains the Fixed-End Moments (FEM)
% 
% elementsAndFixedEndMoments  = { [1, 2], -80
%                                 [2, 1], -80
%                                 [2, 3],  30
%                                 [3, 2],  30 };


%% EXAMPLE #7
%  Two Storey Frame, 2 bays in 1st (ground) storey, 1 bay in 2nd storey

% % a) Define Labels of the Elements' Ends, Distribution and Carryover Factors
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS
% %    The 2nd column of the cell array contains the DISTRIBUTION FACTORS
% %    The 3rd column of the cell array contains the CARRYOVER FACTORS
% 
% elementsDistributionAndCarryoverFactors = { [4, 1], 0.1845, 1/2
%                                             [4, 5], 0.5695, 1/2
%                                             [4, 7], 0.2460, 1/2
%                                             [5, 2], 0.2801, 1/2
%                                             [5, 4], 0.2735, 1/2
%                                             [5, 6], 0.3282, 1/2
%                                             [5, 8], 0.1182, 1/2
%                                             [6, 3], 0.1684, 0
%                                             [6, 5], 0.8316, 1/2
%                                             [7, 4], 0.3017, 1/2
%                                             [7, 8], 0.6983, 1/2
%                                             [8, 5], 0.3017, 1/2
%                                             [8, 7], 0.6983, 1/2 };
% % Carryover Factor of  1/2 for Cross procedure
% % Carryover Factor of -1   for Csonka-Werner procedure
% 
% % b) Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm]
% %    The 1st column of the cell array contains the LABELS OF THE ELEMENTS' ENDS where there are Fixed-End Moments (FEM)
% %    The 2nd column of the cell array contains the Fixed-End Moments (FEM)
% 
% elementsAndFixedEndMoments  = { [7, 8],  18
%                                 [8, 7], -18
%                                 [8, 5],  18.75
%                                 [5, 8], -18.75
%                                 [4, 5],  18
%                                 [5, 4], -18
%                                 [5, 6],  12.5
%                                 [6, 5], -12.5 };


%% Run custom 'momentDistributionMethod.p' function and save outputs

%  All results are formatted and saved in "{outputFileName}.txt"

%{
'outputStructure' contains:
    - 'nodeIterationSequence'           - Order of iterations (steps) by nodes
    - 'totalNumberofIterations'         - Total number of iterations (steps)
    - 'finalBalancedBendingMoments'     - Final balanced bending moments
    - 'balanceControlofIteratedNodes'   - Balance control of iterated nodes
    - 'allStepsoftheIteration'          - All steps of the iteration, for easy control and insight into the iteration process
%}

outputStructure = momentDistributionMethod ( elementsDistributionAndCarryoverFactors, ...
                                             elementsAndFixedEndMoments, ...
                                             bendingMomentUnits, ...
                                             outputFileName, ...
                                             limitAccuracy, ...
                                             limitIteration ...
                                             );
