%{
+-- Author's Information --------------------------------------------------------+
|                                                                                |
|   Marin Grubišić                                                               |
|   Associate Professor | MEng, PhD, PE                                          |
|   University of Osijek, Faculty of Civil Engineering and Architecture Osijek   |
|   Department of Technical Mechanics                                            |
|   3 Vladimir Prelog Street (University Campus), Office II.26 (2nd floor)       |
|   HR-31000 Osijek, Croatia, Europe                                             |
|                                                                                |
|   E-mail:   marin.grubisic@gfos.hr    | marin.grubisic@gmail.com               |
|   Tel.:     +385 91 224 07 92         | +385 95 823 15 75                      |
|   Web:      www.maringrubisic.com     | github.com/mgrubisic                   |
|   Social:   linkedin.com/in/mgrubisic | twitter.com/mgrubisic                  |
|   Date:     5.6.2014. / 29.4.2017.                                             |
|                                                                                |
+--------------------------------------------------------------------------------+
%}

function outputStructure = momentDistributionMethod(elementsDistributionAndCarryoverFactors, ...
                                                    elementsAndFixedEndMoments, ...
                                                    bendingMomentUnits, ...
                                                    outputFileName, ...
                                                    limitAccuracy, ...
                                                    limitIteration, ...
                                                    tableStyle)
													
%MOMENTDISTRIBUTIONMETHOD  Moment distribution method (Hardy Cross, 1930).
%
%   Hardy Cross developed the moment distribution method for structural
%   analysis of statically indeterminate beams and frames. It was published in
%   an ASCE journal in 1930. The method only takes flexural effects into
%   account and ignores axial and shear effects.
%
%   In every step the node with the largest absolute unbalanced moment is
%   released: its unbalanced moment is distributed to the element ends at that
%   node by the distribution factors and carried over to the opposite ends by
%   the carryover factors.
%
%   outputStructure = momentDistributionMethod(elementsDistributionAndCarryoverFactors, ...
%                                              elementsAndFixedEndMoments)
%   outputStructure = momentDistributionMethod(..., bendingMomentUnits, outputFileName, ...
%                                              limitAccuracy, limitIteration, tableStyle)
%
%   Inputs
%   ------
%   elementsDistributionAndCarryoverFactors : n-by-3 cell array
%       {[i,j], distributionFactor, carryoverFactor; ...}
%       [i,j] is the end at node i of the element i-j. The carryover factor
%       carries a distributed moment from end [i,j] to end [j,i]
%       (1/2 for the Cross procedure, -1 for the Csonka-Werner procedure,
%       0 for a pinned far end).
%   elementsAndFixedEndMoments : m-by-2 cell array
%       {[i,j], fixedEndMoment; ...}   (ends that are not listed have zero FEM)
%   bendingMomentUnits : string, default "kNm"
%       Unit label used in the report.
%   outputFileName : string, default "Moment Distribution Method RESULTS"
%       The report is saved to "<outputFileName>.txt"; use "" to skip the file.
%   limitAccuracy : positive scalar, default 0.1
%       The iteration stops after the step in which the balanced (distributed)
%       moment is not larger than limitAccuracy.
%   limitIteration : positive integer or Inf, default Inf
%       Maximum total number of iterations (steps).
%   tableStyle : "fancy" (default) or "ascii"
%       Line style of the report: box-drawing characters (─ │ ┌ ┐ └ ┘, zero
%       increments shown as —) or plain ASCII characters (- = | +).
%
%   Output (struct)
%   ---------------
%   nodeIterationSequence         - order of iterations (steps) by nodes [row vector]
%   totalNumberofIterations       - total number of iterations (steps)
%   finalBalancedBendingMoments   - {[i,j], moment} final end moments, sorted by end
%   balanceControlofIteratedNodes - [node, initial unbalance, unbalance after each step]
%   allStepsoftheIteration        - {"Element", "Moment", node of step 1, ...;
%                                    [i,j], FEM, increment in step 1, ...}
%   isConverged                   - true if limitAccuracy was reached
%
%   Example: see masterExamples.m

arguments
    elementsDistributionAndCarryoverFactors cell
    elementsAndFixedEndMoments              cell
    bendingMomentUnits  (1,1) string = "kNm"
    outputFileName      (1,1) string = "Moment Distribution Method RESULTS"
    limitAccuracy       (1,1) double {mustBePositive} = 0.1
    limitIteration      (1,1) double {mustBePositive, mustBeIntegerOrInf} = Inf
    tableStyle          (1,1) string {mustBeMember(tableStyle, ["fancy", "ascii"])} = "fancy"
end

model  = buildModel(elementsDistributionAndCarryoverFactors, elementsAndFixedEndMoments);
result = distributeMoments(model, limitAccuracy, limitIteration);

finalMoments = model.fem + sum(result.increments, 2);
endsAsCells  = num2cell(model.ends, 2);

outputStructure = struct( ...
    'nodeIterationSequence',         result.sequence, ...
    'totalNumberofIterations',       numel(result.sequence), ...
    'finalBalancedBendingMoments',   {[endsAsCells, num2cell(finalMoments)]}, ...
    'balanceControlofIteratedNodes', [model.nodes, result.unbalanceHistory], ...
    'allStepsoftheIteration',        {[{"Element", "Moment"}, num2cell(result.sequence)
                                       endsAsCells, num2cell([model.fem, result.increments])]}, ...
    'isConverged',                   result.isConverged);

settings = struct('units', bendingMomentUnits, ...
                  'limitAccuracy', limitAccuracy, 'isDefaultAccuracy', nargin < 5, ...
                  'limitIteration', limitIteration, 'isDefaultIteration', nargin < 6, ...
                  'symbols', tableSymbols(tableStyle));
report = buildReport(model, result, finalMoments, settings);

fprintf('%s\n', report);
if strlength(outputFileName) > 0
    writeReport(outputFileName + ".txt", report);
end

end


%% ======================================================================
%  MODEL
%  ======================================================================

function model = buildModel(factorTable, femTable)
%BUILDMODEL  Validate the inputs and assemble the element-end data.

[dfEnds, factors]    = parseEndTable(factorTable, 3, 'elementsDistributionAndCarryoverFactors');
[femEnds, femValues] = parseEndTable(femTable, 2, 'elementsAndFixedEndMoments');

% All element ends (both ends of every element), sorted by node pairs [i, j]
ends  = unique([dfEnds; fliplr(dfEnds); femEnds; fliplr(femEnds)], 'rows');
nEnds = size(ends, 1);

[~, farEnd]    = ismember(fliplr(ends), ends, 'rows');
[hasDf, dfLoc] = ismember(ends, dfEnds, 'rows');
[~, femLoc]    = ismember(femEnds, ends, 'rows');

model.ends  = ends;
model.far   = farEnd;                        % index of the opposite end [j, i]
model.hasDf = hasDf;
model.df    = zeros(nEnds, 1);
model.co    = zeros(nEnds, 1);
model.fem   = zeros(nEnds, 1);
model.df(hasDf)   = factors(dfLoc(hasDf), 1);
model.co(hasDf)   = factors(dfLoc(hasDf), 2);
model.fem(femLoc) = femValues;

% Iterated (released) nodes are the nodes with distribution factors
model.nodes = unique(dfEnds(:, 1));
[~, model.endNode] = ismember(ends(:, 1), model.nodes);   % 0 = not iterated

checkDistributionFactorSums(model);
end


function [ends, values] = parseEndTable(table, nColumns, name)
%PARSEENDTABLE  Split a {[i,j], value(s)} cell array into numeric arrays.

if isempty(table) || size(table, 2) ~= nColumns
    error('momentDistributionMethod:badInput', ...
          '"%s" must be a non-empty cell array with %d columns.', name, nColumns);
end

isValidEnd = @(e) isnumeric(e) && numel(e) == 2 && all(e == round(e)) && e(1) ~= e(2);
if ~all(cellfun(isValidEnd, table(:, 1)))
    error('momentDistributionMethod:badEnd', ...
          'Element ends in "%s" must be pairs [i, j] of distinct integer node labels.', name);
end
if ~all(cellfun(@(v) isnumeric(v) && isscalar(v) && isfinite(v), table(:, 2:end)), 'all')
    error('momentDistributionMethod:badValue', ...
          'Values in "%s" must be finite numeric scalars.', name);
end

ends   = cell2mat(cellfun(@(e) double(e(:).'), table(:, 1), 'UniformOutput', false));
values = cell2mat(table(:, 2:end));

[~, firstIdx] = unique(ends, 'rows', 'stable');
if numel(firstIdx) < size(ends, 1)
    duplicate = ends(setdiff(1:size(ends, 1), firstIdx), :);
    error('momentDistributionMethod:duplicateEnd', ...
          'Element end [%d, %d] is defined more than once in "%s".', ...
          duplicate(1, 1), duplicate(1, 2), name);
end
end


function checkDistributionFactorSums(model)
%CHECKDISTRIBUTIONFACTORSUMS  Warn if the distribution factors at a node do not sum to 1.

tolerance = 1e-2;
for k = 1:numel(model.nodes)
    dfSum = sum(model.df(model.endNode == k));
    if abs(dfSum - 1) > tolerance
        warning('momentDistributionMethod:distributionFactorSum', ...
                'Distribution factors at node %d sum to %.4f (expected 1).', ...
                model.nodes(k), dfSum);
    end
end
end


%% ======================================================================
%  ITERATION
%  ======================================================================

function result = distributeMoments(model, limitAccuracy, limitIteration)
%DISTRIBUTEMOMENTS  Release the most unbalanced node until convergence.

safetyLimit = 1e6;   % guards against divergence when limitIteration = Inf
maxSteps    = min(limitIteration, safetyLimit);

nEnds     = size(model.ends, 1);
moments   = model.fem;
unbalance = nodeUnbalance(model, moments);

increments       = zeros(nEnds, 0);
sequence         = zeros(1, 0);
unbalanceHistory = unbalance;
balancedMoment   = Inf;

while numel(sequence) < maxSteps && abs(balancedMoment) > limitAccuracy
    [maxUnbalance, k] = max(abs(unbalance));
    if maxUnbalance == 0
        break   % already in perfect balance
    end

    balancedMoment = -unbalance(k);
    atNode = find(model.endNode == k & model.hasDf);

    step = zeros(nEnds, 1);
    step(atNode) = balancedMoment * model.df(atNode);
    step(model.far(atNode)) = step(model.far(atNode)) + step(atNode) .* model.co(atNode);

    moments   = moments + step;
    unbalance = nodeUnbalance(model, moments);

    increments(:, end+1)       = step;              
    sequence(end+1)            = model.nodes(k);    
    unbalanceHistory(:, end+1) = unbalance;         
end

result.increments       = increments;
result.sequence         = sequence;
result.unbalanceHistory = unbalanceHistory;
result.isConverged      = abs(balancedMoment) <= limitAccuracy || max(abs(unbalance)) == 0;

if ~result.isConverged && numel(sequence) >= safetyLimit
    warning('momentDistributionMethod:notConverged', ...
            'No convergence after %d steps; check the distribution and carryover factors.', ...
            safetyLimit);
end
end


function unbalance = nodeUnbalance(model, moments)
%NODEUNBALANCE  Sum of the current end moments at every iterated node.

isIterated = model.endNode > 0;
unbalance  = accumarray(model.endNode(isIterated), moments(isIterated), [numel(model.nodes), 1]);
end


%% ======================================================================
%  REPORT
%  ======================================================================

function report = buildReport(model, result, finalMoments, settings)
%BUILDREPORT  Formatted text report as a string column (one element per line).

units   = settings.units;
symbols = settings.symbols;
nSteps  = numel(result.sequence);
history = result.unbalanceHistory;

% Column widths adapt to the largest printed value
labelWidth = 10;
colWidth   = max(8, 1 + maxTextLength([model.fem; result.increments(:); history(:)]));
tableWidth = labelWidth + (colWidth + 1) + colWidth * nSteps;
stepNodes  = strjoin(pad(string(result.sequence), colWidth, 'left'), "");
valueWidth = max(6, maxTextLength([finalMoments; history(:, end)]));

accuracyText = sprintf("%g %s", settings.limitAccuracy, units);
if settings.isDefaultAccuracy
    accuracyText = accuracyText + " (by default)";
end
if isinf(settings.limitIteration)
    iterationText = "Unlimited";
else
    iterationText = sprintf("%d iterations", settings.limitIteration);
end
if settings.isDefaultIteration
    iterationText = iterationText + " (by default)";
end

analysisDate = string(datetime('now'), 'eeee, MMMM d, yyyy; HH:mm:ss', 'en_US');

report = [
    authorHeader(symbols)
    " The Date of the Analysis: [" + analysisDate + "]"
    ""
    ""
    " MOMENT DISTRIBUTION METHOD (Hardy Cross, 1930)"
    "     Hardy Cross developed the moment distribution method for structural analysis of"
    "     statically indeterminate beams and frames. It was published in an ASCE journal"
    "     in 1930. The method only takes flexural effects into account and ignores axial"
    "     and shear effects."
    ""
    ""
    " Accuracy limit in bending moment balance:     " + accuracyText
    " Limited total number of iterations (steps):  " + iterationText
    ""
    ""
    sectionTitle("1) Order of Iterations (Steps) by Nodes:", symbols)
    " " + strjoin(string(result.sequence), ", ")
    ""
    sectionTitle("2) Total Number of Iterations (Steps):", symbols)
    sprintf(" %d iterations", nSteps)
    ""
    sectionTitle("3) Final Balanced Bending Moments:", symbols)
    sprintf(" Element :  Moment (%s)", units)
    compose(" (%2d, %2d):  ", model.ends) + signedValue(finalMoments, valueWidth) + " " + units
    ""
    sectionTitle("4) Balance Control of Iterated Nodes:", symbols)
    compose(" Node %3d:  ", model.nodes) + signedValue(history(:, end), valueWidth) + " " + units
    ""
    sectionTitle("5) All Steps of the Iteration:", symbols, tableWidth)
    pad(" Element", labelWidth) + pad("Moment", colWidth + 1, 'left') + stepNodes
    rule(symbols.line, tableWidth)
    compose(" (%2d, %2d):", model.ends) + tableRows([model.fem, result.increments], colWidth, symbols.zero)
    rule(symbols.line, tableWidth)
    pad(" Node", labelWidth) + pad("Moment", colWidth + 1, 'left') + stepNodes
    rule(symbols.line, tableWidth)
    pad(compose(" %4d", model.nodes), labelWidth) + tableRows(history, colWidth, "")
    rule(symbols.heavyLine, tableWidth)
    ""
    citationLines()
    ""
    " Structural analysis completed successfully. End of document."
    ];
end


function symbols = tableSymbols(tableStyle)
%TABLESYMBOLS  Line and box characters of the report for the given table style.

switch tableStyle
    case "fancy"
        symbols = struct('line', "─", 'heavyLine', "─", 'vertical', "│", ...
                         'topLeft', "┌", 'topRight', "┐", 'bottomLeft', "└", 'bottomRight', "┘", ...
                         'zero', "—");
    case "ascii"
        symbols = struct('line', "-", 'heavyLine', "=", 'vertical', "|", ...
                         'topLeft', "+", 'topRight', "+", 'bottomLeft', "+", 'bottomRight', "+", ...
                         'zero', "-");
end
end


function lines = authorHeader(symbols)
%AUTHORHEADER  Author's information in a box drawn with the table style symbols.

content = [
    ""
    "   Marin Grubišić"
    "   Associate Professor | MEng, PhD, PE"
    "   University of Osijek, Faculty of Civil Engineering and Architecture Osijek"
    "   Department of Technical Mechanics"
    "   3 Vladimir Prelog Street (University Campus), Office II.26 (2nd floor)"
    "   HR-31000 Osijek, Croatia, Europe"
    ""
    "   E-mail:   marin.grubisic@gfos.hr    " + symbols.vertical + " marin.grubisic@gmail.com"
    "   Tel.:     +385 91 224 07 92         " + symbols.vertical + " +385 95 823 15 75"
    "   Web:      www.maringrubisic.com     " + symbols.vertical + " github.com/mgrubisic"
    ""
    "   Update:   5.6.2014. / 29.4.2017."
    ""
    ];
innerWidth = 80;
title = rule(symbols.heavyLine, 2) + " Author's Information ";

lines = [
    symbols.topLeft + title + rule(symbols.heavyLine, innerWidth - strlength(title)) + symbols.topRight
    symbols.vertical + pad(content, innerWidth) + symbols.vertical
    symbols.bottomLeft + rule(symbols.heavyLine, innerWidth) + symbols.bottomRight
    ];
end


function lines = citationLines()
%CITATIONLINES  How to cite this software (APA style, see CITATION.cff).

version       = "1.0.1";
releaseYear   = "2026";
doi           = "10.5281/zenodo.23042195"
repositoryUrl = "https://zenodo.org/records/23042195";

if strlength(doi) > 0
    link = "Zenodo. https://doi.org/" + doi;
else
    link = repositoryUrl;
end

lines = [
    " If you use this software, please cite it as:"
    "     Grubišić, M. (" + releaseYear + "). Moment Distribution Method (Hardy Cross): MATLAB and Python"
    "     Implementation (Version " + version + ") [Computer software]."
    "     " + link
    ];
end


function lines = sectionTitle(title, symbols, ruleWidth)
if nargin < 3
    ruleWidth = strlength(title) + 2;
end
lines = [" " + title; rule(symbols.heavyLine, ruleWidth)];
end


function line = rule(symbol, width)
line = join(repmat(symbol, 1, width), "");
end


function text = signedValue(values, width)
%SIGNEDVALUE  "+ 12.34" / "- 12.34" / "  0.00" (no sign for values printed as 0.00).

values = withoutNegativeZero(values);
signs  = repmat(" ", size(values));
signs(values > 0) = "+";
signs(values < 0) = "-";
text = signs + compose(sprintf("%%%d.2f", width), abs(values));
end


function rows = tableRows(values, colWidth, zeroSymbol)
%TABLEROWS  First column is one character wider (Moment), then one column per step.
%   Exact zeros are shown as zeroSymbol unless it is empty.

cells = compose(sprintf("%%%d.2f", colWidth), withoutNegativeZero(values));
if strlength(zeroSymbol) > 0
    cells(values == 0) = pad(zeroSymbol, colWidth, 'left');
end
cells(:, 1) = " " + cells(:, 1);
rows = join(cells, "", 2);
end


function n = maxTextLength(values)
n = max(strlength(compose("%.2f", withoutNegativeZero(values(:)))));
end


function values = withoutNegativeZero(values)
%WITHOUTNEGATIVEZERO  Avoid "-0.00" for values that are printed as zero.

values(abs(values) < 0.005) = 0;
end


function writeReport(fileName, report)
fileID = fopen(fileName, 'w', 'n', 'UTF-8');
if fileID == -1
    error('momentDistributionMethod:fileOpen', 'Cannot open "%s" for writing.', fileName);
end
closeFile = onCleanup(@() fclose(fileID));
fprintf(fileID, '%s\n', report);
end


function mustBeIntegerOrInf(value)
if ~(isinf(value) || value == round(value))
    error('momentDistributionMethod:badLimitIteration', ...
          'limitIteration must be a positive integer or Inf.');
end
end
