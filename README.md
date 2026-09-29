# Moment Distribution Method (*Hardy Cross*)   

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.txt)

> If you use this software, please cite it – see [How to cite](#how-to-cite).

<div align='justify'>
Hardy Cross developed and formally presented the moment distribution method for analysing beams and frames in 1930. This method, unlike the slope-deflection method, is approximate and eliminates the need to solve simultaneous equations. The number of successive approximations or iterations performed determines the accuracy of the results obtained using the moment distribution. It focuses on flexural effects while ignoring axial and shear effects. Prior to the widespread use of computers in structural design and analysis, the moment distribution method was the most widely used.

The moment distribution method is an iterative approach for dealing with structures with varying degrees of indeterminacy or freedom. Engineers can manually analyse highly indeterminate structures with many degrees of freedom by using moment distribution.

The method, named after engineering professor Hardy Cross, was published in September 1932 in a concise ten-page paper. This paper, titled *"Analysis of Continuous Frames by Distributing Fixed-End Moments"*, revolutionised structural engineering by allowing for precise structural analysis.

The moment distribution method is an exact technique for calculating bending moments in beams and frames that relies on a series of successive and improved approximations.
</div>

---
**Algorithm:**

In every step, the node with the largest absolute unbalanced moment is released: its unbalanced moment is distributed to the element ends at that node by the **distribution factors** and carried over to the opposite element ends by the **carryover factors**. The iteration stops after the step in which the balanced moment is not larger than `limitAccuracy`, or when `limitIteration` steps have been made.

**Files:**

| File | Description |
|---|---|
| `Matlab/momentDistributionMethod.m` | MATLAB function (R2019b or newer) |
| `Matlab/masterExamples.m` | MATLAB script with 7 examples |
| `Python/moment_distribution_method.py` | Python function (Python 3.9+, NumPy) |
| `Python/masterExamples.py` | Python script with the same 7 examples |
| `CITATION.cff` | Citation metadata (GitHub "Cite this repository", Zenodo) |

Both implementations use the same algorithm and write the same text report.

---
**Input:**

1. **Define Labels of the Elements' Ends, Distribution Factors and Carryover Factors in Cell Array**     
The 1<sup>st</sup> column of the cell array contains the **labels of the elements' ends** `[i, j]` (end at node `i` of the element `i-j`)      
The 2<sup>nd</sup> column of the cell array contains the **distribution factors**      
The 3<sup>rd</sup> column of the cell array contains the **carryover factors** (`1/2` for the Cross procedure, `-1` for the Csonka-Werner procedure, `0` for a pinned far end)      
    - `elementsDistributionAndCarryoverFactors` = {cell array}             
              
2. **Define Labels of the Elements' Ends and Fixed-End Moments (FEM) [e.g. in kNm] in Cell Array**      
The 1<sup>st</sup> column of the cell array contains the **labels of the elements' ends** where there are Fixed-End Moments (FEM)        
The 2<sup>nd</sup> column of the cell array contains the **fixed-end moments (FEM)** (ends that are not listed have zero FEM)           
    - `elementsAndFixedEndMoments` = {cell array}               

**Optional input variables:**

3. Define Bending Moment Unit for Output (`"kNm"` by default)     
    - `bendingMomentUnits = "kNm"; % kNm, Nm, Nmm, kNmm, ...`     
      
4. Define File Name for Output (All results are formatted and saved in `{outputFileName}.txt`; `""` skips writing the file; `"Moment Distribution Method RESULTS"` by default)      
    - `outputFileName = "Structure Example Output";`      
      
5. Accuracy limit in bending moment balance (0.1 "kNm" by default)       
    - `limitAccuracy = 0.1;`     
      
6. Limited total number of iterations, i.e. steps (Unlimited, `Inf`, by default)      
    - `limitIteration = 20;`        

7. Table style of the output (`"fancy"` by default)      
    - `tableStyle = "fancy";` - box-drawing characters `─ │ ┌ ┐ └ ┘`, zero increments shown as `—`      
    - `tableStyle = "ascii";` - plain ASCII characters `- = | +`      

The inputs are validated: element ends must be pairs of distinct integer node labels, each end may be defined only once, and a warning is issued if the distribution factors at a node do not sum to 1.

**Outputs:**

- `outputStructure` - Structured output
  - `nodeIterationSequence` - Order of iterations (steps) by nodes [row vector]     
  - `totalNumberofIterations` - Total number of iterations (steps) [integer]     
  - `finalBalancedBendingMoments` - Final balanced bending moments `{[i,j], moment}` {cell array}    
  - `balanceControlofIteratedNodes` - Balance control of iterated nodes `[node, initial unbalance, unbalance after each step]` [matrix]     
  - `allStepsoftheIteration` - All steps of the iteration, for easy control and insight into the iteration process: header row `{"Element", "Moment", nodes of the steps}`, then `{[i,j], FEM, increment in each step}` {cell array}    
  - `isConverged` - `true` if the accuracy limit was reached [logical]    

- All results are printed to the Command Window and formatted and saved in `{outputFileName}.txt`
---
```matlab
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
                                [2, 3],   9.34
                                [3, 2],   4.39
                                [5, 6],  31.42
                                [6, 5],  14.76
                                [2, 5],  16.62
                                [5, 2],  16.62
                                [3, 6],  -9.58
                                [6, 3],  -9.58 }; 

outputStructure = momentDistributionMethod(elementsDistributionAndCarryoverFactors, ...
                                           elementsAndFixedEndMoments, ...
                                           "kNm", "Structure Example Output", 0.1, 20, "fancy");
```

```
OUTPUT OF EXAMPLE #5

 Accuracy limit in bending moment balance:     0.1 kNm
 Limited total number of iterations (steps):  20 iterations


 1) Order of Iterations (Steps) by Nodes:
──────────────────────────────────────────
 5, 2, 6, 3, 5, 6, 2, 5, 3, 6, 2, 5, 3, 6, 2

 2) Total Number of Iterations (Steps):
────────────────────────────────────────
 15 iterations

 3) Final Balanced Bending Moments:
────────────────────────────────────
 Element :  Moment (kNm)
 ( 1,  2):  - 22.06 kNm
 ( 2,  1):  - 20.60 kNm
 ( 2,  3):  +  7.78 kNm
 ( 2,  5):  + 12.82 kNm
 ( 3,  2):  +  5.99 kNm
 ( 3,  6):  -  6.01 kNm
 ( 4,  5):  - 62.74 kNm
 ( 5,  2):  + 17.10 kNm
 ( 5,  4):  - 51.02 kNm
 ( 5,  6):  + 33.88 kNm
 ( 6,  3):  - 10.58 kNm
 ( 6,  5):  + 10.58 kNm

 4) Balance Control of Iterated Nodes:
───────────────────────────────────────
 Node   2:     0.00 kNm
 Node   3:  -  0.03 kNm
 Node   5:  -  0.05 kNm
 Node   6:     0.00 kNm

 5) All Steps of the Iteration:
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Element     Moment       5       2       6       3       5       6       2       5       3       6       2       5       3       6       2
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
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
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Node        Moment       5       2       6       3       5       6       2       5       3       6       2       5       3       6       2
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    2          8.20    9.10    0.00    0.00    1.41    1.89    1.89    0.00    0.17    0.32    0.32    0.00    0.03    0.06    0.06    0.00
    3         -5.19   -5.19   -6.45   -7.62    0.00    0.00   -0.57   -0.83   -0.83    0.00   -0.10   -0.14   -0.14    0.00   -0.02   -0.03
    5         -8.20    0.00   -2.15   -4.43   -4.43    0.00   -1.10   -1.55    0.00    0.00   -0.19   -0.27    0.00    0.00   -0.03   -0.05
    6          5.18    6.90    6.90    0.00    2.41    3.34    0.00    0.00    0.33    0.59    0.00    0.00    0.06    0.10    0.00    0.00
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

 Structural analysis completed successfully. End of document.
```
---

## Python

The Python version (`moment_distribution_method.py`) is a direct port of the MATLAB function: the same algorithm, the same inputs and the same text report. It requires **Python 3.9+** and **NumPy**.

```
pip install numpy
cd Python
python masterExamples.py
```

In `masterExamples.py`, all 7 examples are defined in the `EXAMPLES` dictionary; select the example to run with `EXAMPLE = 5`.

**Input:** element ends are tuples `(i, j)`, tables are lists of tuples.

```python
import math
from moment_distribution_method import moment_distribution_method

elements_distribution_and_carryover_factors = [((2, 1), 0.250, 1/2),
                                               ((2, 3), 0.277, 1/2),
                                               ((2, 5), 0.473, 1/2),
                                               ((3, 2), 0.369, 1/2),
                                               ((3, 6), 0.631, 1/2),
                                               ((5, 2), 0.219, 1/2),
                                               ((5, 4), 0.361, 1/2),
                                               ((5, 6), 0.420, 1/2),
                                               ((6, 3), 0.340, 1/2),
                                               ((6, 5), 0.660, 1/2)]

elements_and_fixed_end_moments = [((1, 2), -20.64), ((2, 1), -17.76),
                                  ((4, 5), -65.35), ((5, 4), -56.24),
                                  ((2, 3),   9.34), ((3, 2),   4.39),
                                  ((5, 6),  31.42), ((6, 5),  14.76),
                                  ((2, 5),  16.62), ((5, 2),  16.62),
                                  ((3, 6),  -9.58), ((6, 3),  -9.58)]

result = moment_distribution_method(
    elements_distribution_and_carryover_factors,
    elements_and_fixed_end_moments,
    bending_moment_units="kNm",
    output_file_name="Structure Example Output",  # None skips writing the file
    limit_accuracy=0.1,                           # 0.1 by default
    limit_iteration=20,                           # math.inf by default
    table_style="fancy",                          # "fancy" by default, or "ascii"
    verbose=True,                                 # print the report to the console
)

print(result.final_balanced_bending_moments[(1, 2)])   # -22.06...
```

**Output:** `moment_distribution_method` returns a `MomentDistributionResult` (frozen dataclass):

| Python attribute | MATLAB field | Content |
|---|---|---|
| `node_iteration_sequence` | `nodeIterationSequence` | order of iterations (steps) by nodes |
| `total_number_of_iterations` | `totalNumberofIterations` | total number of iterations (steps) |
| `final_balanced_bending_moments` | `finalBalancedBendingMoments` | `{(i, j): moment}` |
| `balance_control_of_iterated_nodes` | `balanceControlofIteratedNodes` | `[node, initial unbalance, unbalance after each step]` |
| `all_steps_of_the_iteration` | `allStepsoftheIteration` | `[FEM, increment in each step]`, rows ordered as `element_ends` |
| `element_ends` | – | all element ends `[i, j]`, sorted |
| `is_converged` | `isConverged` | `True` if the accuracy limit was reached |
| `report` | – | formatted text report |

Invalid inputs raise `ValueError`; distribution factors that do not sum to 1 at a node issue a `UserWarning`.

---

## How to cite

If you use this software in teaching, research or publications, please cite it. The citation is also printed at the end of every report, and GitHub offers it in APA and BibTeX format under **"Cite this repository"** (from [`CITATION.cff`](CITATION.cff)).

**APA**

> Grubišić, M. (2026). *Moment Distribution Method (Hardy Cross): MATLAB and Python Implementation* (Version 1.0) [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.23042195

**BibTeX**

```bibtex
@software{Grubisic_Moment_Distribution_Method_2026,
  author    = {Grubi{\v{s}}i{\'c}, Marin},
  title     = {{Moment Distribution Method (Hardy Cross): MATLAB and Python Implementation}},
  year      = {2026},
  version   = {1.0},
  publisher = {Zenodo},
  doi       = {10.5281/zenodo.23042195},
  url       = {https://github.com/mgrubisic/Moment-Distribution-Method}
}
```

The DOI above is the Zenodo **concept DOI**, which always resolves to the latest version; every release also has its own version DOI, listed on the Zenodo record, for citing the exact version used.

Please also cite the original method:

> Cross, H. (1930). Analysis of continuous frames by distributing fixed-end moments. *Proceedings of the American Society of Civil Engineers*, 56(5), 919–928.

---     

> This Matlab algorithm for iteratively solving the **Moment Distribution Method** is used at the University of Osijek, **Faculty of Civil Engineering and Architecture Osijek**, Department of Technical Mechanics, as part of the **Structural Analysis 2** course.

> **Assoc. Prof. Marin Grubišić**    
> **marin.grubisic@gfos.hr**
