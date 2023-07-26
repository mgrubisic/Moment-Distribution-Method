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
│   E-mail:   marin.grubisic@gfos.hr | marin.grubisic@gmail.com                  │
│   Tel.:     +385 95 823 15 75 | +385 91 224 07 92                              │
│   Web:      www.maringrubisic.com | www.gfos.unios.hr | github.com/mgrubisic   │
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

% Define File Name for Output
outputFileName      = "Structure Example Output";

% Accuracy limit in bending moment balance (0.1 "kNm" by default)
limitAccuracy       = 0.1;

% Limited total number of iterations, i.e. steps (Infinite by default)
limitIteration      = 20;


%% Example #1
%  Simple fixed portal frame structure (1 storey, 1 bay)

% % a) Define Distribution Factors
% distributionFactorsElements = {[2,1], [2,4], [4,2], [4,3]}';
% distributionFactors         = [0.290, 0.709, 0.765, 0.235]';
% 
% % b) Define Carryover Factors (for the same Distribution Factors Elements)
% carryoverFactors            = [1/2, 1/2, 1/2, 1/2]';
% 
% % c) Define Fixed-End Moments [e.g. in kNm]
% fixedEndMomentsElements     = {[2,1], [2,4], [4,2], [4,3], [1,2], [3,4]}';
% fixedEndMoments             = [63.91, -55.98, -55.98, 48.05, 71.49, 53.75]';


%% Example #2
%  Simple beam (3 bays)

% % a) Define Distribution Factors
% distributionFactorsElements = {[2, 1], [2, 3], [3, 2], [3, 4]}';
% distributionFactors         = [3/11, 8/11, 8/12, 4/12]';
% 
% % b) Define Carryover Factors (for the same Distribution Factors Elements)
% carryoverFactors            = [0, 1/2, 1/2, 1/2]';
% 
% % c) Define Fixed-End Moments [e.g. in kNm]
% fixedEndMomentsElements     = {[2, 1], [2, 3], [3, 2], [3, 4], [4, 3]}';
% fixedEndMoments             = [-13.65, 8.333, -8.333, 25, -25]';


%% Example #3
%  Simple regular bridge structure (4 columns, 5 bays)

% % a) Define Distribution Factors
% distributionFactorsElements = {[6,1], [6,5], [6,7], [7,2], [7,6], [7,8], [8,3], [8,7], [8,9], [9,4], [9,8], [9,10]}';
% distributionFactors         = [4/15, 1/5, 8/15, 1/4, 1/4, 2/4, 1/8, 4/8, 3/8, 4/13, 4/13, 5/13]';
% 
% % b) Define Carryover Factors (for the same Distribution Factors Elements)
% carryoverFactors            = [1/2, 0, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 0]';
% 
% % c) Define Fixed-End Moments [e.g. in kNm]
% fixedEndMomentsElements     = {[1,6], [6,1], [7,8], [8,7]}';
% fixedEndMoments             = [-28, -14, 25, -25]';


%% Example #4
%  Complex irregular frame (3 storeys, 3 bays)

% a) Define Distribution Factors
distributionFactorsElements = {[4, 3], [4, 1], [4, 5], [4, 8], [5, 4], [5, 2], [5, 6], [5, 9], [8, 7], [8, 4], [8, 9], [8, 10], [9, 8], [9, 5], [9, 11], [10, 8], [10, 11], [11, 10], [11,9]}';
distributionFactors         = [9/28, 1/7, 3/28, 3/7, 6/55, 16/55, 9/55, 24/55, 1/5, 2/5, 1/5, 1/5, 2/7, 4/7, 1/7, 2/3, 1/3, 1/2, 1/2]';

% b) Define Carryover Factors (for the same Distribution Factors Elements)
carryoverFactors            = [0, 1/2, 1/2, 1/2, 1/2, 1/2, 0, 1/2, 0, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2]';

% c) Define Fixed-End Moments [e.g. in kNm]
fixedEndMomentsElements     = {[1, 4], [4, 1], [4, 5], [5, 4], [4, 8], [8, 4], [5, 9], [9, 5], [8, 9], [9, 8], [10, 11], [11, 10]}';
fixedEndMoments             = [-38.33, -18.67, 30, -30, 20, -20, -52.5, 52.5, 13.33, -13.33, 13.33, 36.67]';


%% Example #5
%  Regular fixed frame (2 storeys, 1 bay)

% % a) Define Distribution Factors
% distributionFactorsElements = {[2,1], [2,3], [2,5], [3,2], [3,6], [5,2], [5,4], [5,6], [6,3], [6,5]}';
% distributionFactors         = [0.250, 0.277, 0.473, 0.369, 0.631, 0.217, 0.361, 0.420, 0.340, 0.660]';
% 
% % b) Define Carryover Factors (for the same Distribution Factors Elements)
% carryoverFactors            = [1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2]';
% 
% % c) Define Fixed-End Moments [e.g. in kNm]
% fixedEndMomentsElements     = {[1,2], [2,1], [4,5], [5,4], [2,3], [3,2], [5,6], [6,5], [2,5], [5,2], [3,6], [6,3]}';
% fixedEndMoments             = [-20.64, -17.76, -65.35, -56.24, 9.34, 4.39, 31.42, 14.76, 16.62, 16.62, -9.58, -9.58]';


%% Run custom 'momentDistributionMethod.p' function as save outputs

%  All results are formated and saved in "{outputFileName}.txt"

%{
'outputStructure' contains:
    - 'nodeIterationSequence'           - Order of iterations (steps) by nodes
    - 'totalNumberofIterations'         - Total number of iterations (steps)
    - 'finalBalancedBendingMoments'     - Final balanced bending moments
    - 'balanceControlofIteratedNodes'   - Balance control of iterated nodes
    - 'allStepsoftheIteration'          - All steps of the iteration, for easy control and insight into the iteration process
%}
outputStructure = momentDistributionMethod ( distributionFactorsElements, ...
                                             distributionFactors, ...
                                             carryoverFactors, ...
                                             fixedEndMomentsElements, ...
                                             fixedEndMoments, ...
                                             bendingMomentUnits, ...
                                             outputFileName, ...
                                             limitAccuracy, ...
                                             limitIteration ...
                                             );
