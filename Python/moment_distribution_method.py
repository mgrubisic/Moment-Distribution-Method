"""
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

MOMENT DISTRIBUTION METHOD (Hardy Cross, 1930)
    Hardy Cross developed the moment distribution method for structural analysis of
    statically indeterminate beams and frames. It was published in an ASCE journal
    in 1930. The method only takes flexural effects into account and ignores axial
    and shear effects.
"""

from __future__ import annotations

import math
import sys
import warnings
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Sequence

import numpy as np

__all__ = ["MomentDistributionResult", "moment_distribution_method"]

DEFAULT_OUTPUT_FILE_NAME = "Moment Distribution Method RESULTS"
DEFAULT_LIMIT_ACCURACY = 0.1
SAFETY_LIMIT = 1_000_000  # guards against divergence when limit_iteration = inf
DISTRIBUTION_FACTOR_TOLERANCE = 1e-2

# How to cite this software (APA style, see CITATION.cff)
SOFTWARE_VERSION = "2.0.0"
RELEASE_YEAR = "2026"
CITATION_DOI = ""  # Zenodo concept DOI, e.g. "10.5281/zenodo.XXXXXXX"
REPOSITORY_URL = "https://github.com/mgrubisic/Moment-Distribution-Method"

ElementEnd = tuple[int, int]


@dataclass(frozen=True)
class MomentDistributionResult:
    """Results of the moment distribution method.

    Attributes
    ----------
    node_iteration_sequence : ndarray (n_steps,)
        Order of iterations (steps) by nodes.
    total_number_of_iterations : int
        Total number of iterations (steps).
    element_ends : ndarray (n_ends, 2)
        All element ends [i, j], sorted; row order of the arrays below.
    final_balanced_bending_moments : dict[(i, j), float]
        Final end moments, sorted by element end.
    balance_control_of_iterated_nodes : ndarray (n_nodes, 2 + n_steps)
        [node, initial unbalance, unbalance after each step].
    all_steps_of_the_iteration : ndarray (n_ends, 1 + n_steps)
        [FEM, increment in step 1, increment in step 2, ...] per element end.
    is_converged : bool
        True if limit_accuracy was reached.
    report : str
        Formatted text report (as printed and written to the output file).
    """

    node_iteration_sequence: np.ndarray
    total_number_of_iterations: int
    element_ends: np.ndarray
    final_balanced_bending_moments: dict[ElementEnd, float]
    balance_control_of_iterated_nodes: np.ndarray
    all_steps_of_the_iteration: np.ndarray
    is_converged: bool
    report: str


@dataclass(frozen=True)
class _Model:
    ends: np.ndarray       # (n_ends, 2) sorted element ends [i, j]
    far: np.ndarray        # index of the opposite end [j, i]
    has_df: np.ndarray     # end has a distribution factor
    df: np.ndarray
    co: np.ndarray
    fem: np.ndarray
    nodes: np.ndarray      # iterated (released) nodes
    end_node: np.ndarray   # index into nodes, -1 = not iterated


@dataclass(frozen=True)
class _Iteration:
    increments: np.ndarray         # (n_ends, n_steps)
    sequence: np.ndarray           # (n_steps,)
    unbalance_history: np.ndarray  # (n_nodes, 1 + n_steps)
    is_converged: bool


def moment_distribution_method(
    elements_distribution_and_carryover_factors: Sequence[tuple[Sequence[int], float, float]],
    elements_and_fixed_end_moments: Sequence[tuple[Sequence[int], float]],
    bending_moment_units: str = "kNm",
    output_file_name: str | None = DEFAULT_OUTPUT_FILE_NAME,
    limit_accuracy: float | None = None,
    limit_iteration: float | None = None,
    table_style: str = "fancy",
    verbose: bool = True,
) -> MomentDistributionResult:
    """Moment distribution method (Hardy Cross, 1930).

    In every step the node with the largest absolute unbalanced moment is
    released: its unbalanced moment is distributed to the element ends at that
    node by the distribution factors and carried over to the opposite ends by
    the carryover factors.

    Parameters
    ----------
    elements_distribution_and_carryover_factors
        [((i, j), distribution_factor, carryover_factor), ...]
        (i, j) is the end at node i of the element i-j. The carryover factor
        carries a distributed moment from end (i, j) to end (j, i)
        (1/2 for the Cross procedure, -1 for the Csonka-Werner procedure,
        0 for a pinned far end).
    elements_and_fixed_end_moments
        [((i, j), fixed_end_moment), ...]  (ends that are not listed have zero FEM)
    bending_moment_units
        Unit label used in the report.
    output_file_name
        The report is saved to "<output_file_name>.txt"; None or "" skips the file.
    limit_accuracy
        The iteration stops after the step in which the balanced (distributed)
        moment is not larger than limit_accuracy (default 0.1).
    limit_iteration
        Maximum total number of iterations (steps), a positive integer or
        math.inf (default).
    table_style
        "fancy" (default) or "ascii": line style of the report, box-drawing
        characters (─ │ ┌ ┐ └ ┘, zero increments shown as —) or plain ASCII
        characters (- = | +).
    verbose
        Print the report to the console.
    """
    if table_style not in TABLE_STYLES:
        raise ValueError(f"table_style must be one of {sorted(TABLE_STYLES)}, not {table_style!r}.")
    is_default_accuracy = limit_accuracy is None
    is_default_iteration = limit_iteration is None
    limit_accuracy = DEFAULT_LIMIT_ACCURACY if is_default_accuracy else float(limit_accuracy)
    limit_iteration = math.inf if is_default_iteration else limit_iteration
    _validate_limits(limit_accuracy, limit_iteration)

    model = _build_model(elements_distribution_and_carryover_factors, elements_and_fixed_end_moments)
    iteration = _distribute_moments(model, limit_accuracy, limit_iteration)
    final_moments = model.fem + iteration.increments.sum(axis=1)

    report = _build_report(
        model, iteration, final_moments, bending_moment_units,
        limit_accuracy, is_default_accuracy, limit_iteration, is_default_iteration,
        TABLE_STYLES[table_style],
    )
    if verbose:
        _print_text(report)
    if output_file_name:
        Path(f"{output_file_name}.txt").write_text(report, encoding="utf-8", newline="\n")

    return MomentDistributionResult(
        node_iteration_sequence=iteration.sequence,
        total_number_of_iterations=iteration.sequence.size,
        element_ends=model.ends,
        final_balanced_bending_moments={
            (int(i), int(j)): float(m) for (i, j), m in zip(model.ends, final_moments)
        },
        balance_control_of_iterated_nodes=np.column_stack([model.nodes, iteration.unbalance_history]),
        all_steps_of_the_iteration=np.column_stack([model.fem, iteration.increments]),
        is_converged=iteration.is_converged,
        report=report,
    )


# ======================================================================
#  MODEL
# ======================================================================

def _build_model(factor_table, fem_table) -> _Model:
    """Validate the inputs and assemble the element-end data."""
    df_ends, factors = _parse_end_table(factor_table, 2, "elements_distribution_and_carryover_factors")
    fem_ends, fem_values = _parse_end_table(fem_table, 1, "elements_and_fixed_end_moments")

    # All element ends (both ends of every element), sorted by node pairs [i, j]
    ends = np.unique(np.vstack([df_ends, df_ends[:, ::-1], fem_ends, fem_ends[:, ::-1]]), axis=0)
    index = {(int(i), int(j)): k for k, (i, j) in enumerate(ends)}

    far = np.array([index[(int(j), int(i))] for i, j in ends])
    df_rows = np.array([index[(int(i), int(j))] for i, j in df_ends])
    fem_rows = np.array([index[(int(i), int(j))] for i, j in fem_ends])

    n_ends = len(ends)
    has_df = np.zeros(n_ends, dtype=bool)
    df, co, fem = np.zeros(n_ends), np.zeros(n_ends), np.zeros(n_ends)
    has_df[df_rows] = True
    df[df_rows] = factors[:, 0]
    co[df_rows] = factors[:, 1]
    fem[fem_rows] = fem_values[:, 0]

    # Iterated (released) nodes are the nodes with distribution factors
    nodes = np.unique(df_ends[:, 0])
    node_index = {int(node): k for k, node in enumerate(nodes)}
    end_node = np.array([node_index.get(int(i), -1) for i in ends[:, 0]])

    model = _Model(ends, far, has_df, df, co, fem, nodes, end_node)
    _check_distribution_factor_sums(model)
    return model


def _parse_end_table(table, n_values: int, name: str) -> tuple[np.ndarray, np.ndarray]:
    """Split a [((i, j), value(s)), ...] table into numeric arrays."""
    if len(table) == 0 or any(len(row) != 1 + n_values for row in table):
        raise ValueError(f'"{name}" must be a non-empty table with {1 + n_values} columns.')

    ends, values = [], []
    for row in table:
        end = tuple(row[0])
        if not (len(end) == 2 and all(float(n).is_integer() for n in end) and end[0] != end[1]):
            raise ValueError(
                f'Element ends in "{name}" must be pairs (i, j) of distinct integer node labels.')
        row_values = [float(v) for v in row[1:]]
        if not all(math.isfinite(v) for v in row_values):
            raise ValueError(f'Values in "{name}" must be finite numbers.')
        ends.append([int(n) for n in end])
        values.append(row_values)

    seen = set()
    for i, j in ends:
        if (i, j) in seen:
            raise ValueError(f'Element end [{i}, {j}] is defined more than once in "{name}".')
        seen.add((i, j))

    return np.array(ends, dtype=int), np.array(values, dtype=float)


def _check_distribution_factor_sums(model: _Model) -> None:
    """Warn if the distribution factors at a node do not sum to 1."""
    for k, node in enumerate(model.nodes):
        df_sum = model.df[model.end_node == k].sum()
        if abs(df_sum - 1) > DISTRIBUTION_FACTOR_TOLERANCE:
            warnings.warn(f"Distribution factors at node {node} sum to {df_sum:.4f} (expected 1).",
                          stacklevel=4)


def _validate_limits(limit_accuracy: float, limit_iteration: float) -> None:
    if not limit_accuracy > 0:
        raise ValueError("limit_accuracy must be positive.")
    if not (limit_iteration == math.inf or
            (limit_iteration > 0 and float(limit_iteration).is_integer())):
        raise ValueError("limit_iteration must be a positive integer or math.inf.")


# ======================================================================
#  ITERATION
# ======================================================================

def _distribute_moments(model: _Model, limit_accuracy: float, limit_iteration: float) -> _Iteration:
    """Release the most unbalanced node until convergence."""
    max_steps = min(limit_iteration, SAFETY_LIMIT)

    moments = model.fem.copy()
    unbalance = _node_unbalance(model, moments)

    increments: list[np.ndarray] = []
    sequence: list[int] = []
    history: list[np.ndarray] = [unbalance]
    balanced_moment = math.inf

    while len(sequence) < max_steps and abs(balanced_moment) > limit_accuracy:
        k = int(np.argmax(np.abs(unbalance)))
        if unbalance[k] == 0:
            break  # already in perfect balance

        balanced_moment = -unbalance[k]
        at_node = np.flatnonzero((model.end_node == k) & model.has_df)

        step = np.zeros_like(moments)
        step[at_node] = balanced_moment * model.df[at_node]
        step[model.far[at_node]] += step[at_node] * model.co[at_node]

        moments = moments + step
        unbalance = _node_unbalance(model, moments)

        increments.append(step)
        sequence.append(int(model.nodes[k]))
        history.append(unbalance)

    is_converged = abs(balanced_moment) <= limit_accuracy or not np.any(unbalance)
    if not is_converged and len(sequence) >= SAFETY_LIMIT:
        warnings.warn(f"No convergence after {SAFETY_LIMIT} steps; "
                      "check the distribution and carryover factors.", stacklevel=4)

    return _Iteration(
        increments=np.column_stack(increments) if increments else np.zeros((len(moments), 0)),
        sequence=np.array(sequence, dtype=int),
        unbalance_history=np.column_stack(history),
        is_converged=bool(is_converged),
    )


def _node_unbalance(model: _Model, moments: np.ndarray) -> np.ndarray:
    """Sum of the current end moments at every iterated node."""
    iterated = model.end_node >= 0
    return np.bincount(model.end_node[iterated], weights=moments[iterated],
                       minlength=len(model.nodes))


# ======================================================================
#  REPORT
# ======================================================================

@dataclass(frozen=True)
class _TableSymbols:
    line: str
    heavy_line: str
    vertical: str
    top_left: str
    top_right: str
    bottom_left: str
    bottom_right: str
    zero: str


TABLE_STYLES = {
    "fancy": _TableSymbols(line="─", heavy_line="─", vertical="│",
                           top_left="┌", top_right="┐", bottom_left="└", bottom_right="┘",
                           zero="—"),
    "ascii": _TableSymbols(line="-", heavy_line="=", vertical="|",
                           top_left="+", top_right="+", bottom_left="+", bottom_right="+",
                           zero="-"),
}


def _author_header(symbols: _TableSymbols) -> list[str]:
    """Author's information in a box drawn with the table style symbols."""
    v = symbols.vertical
    content = [
        "",
        "   Marin Grubišić",
        "   Associate Professor | MEng, PhD, PE",
        "   University of Osijek, Faculty of Civil Engineering and Architecture Osijek",
        "   Department of Technical Mechanics",
        "   3 Vladimir Prelog Street (University Campus), Office II.26 (2nd floor)",
        "   HR-31000 Osijek, Croatia, Europe",
        "",
        f"   E-mail:   marin.grubisic@gfos.hr    {v} marin.grubisic@gmail.com",
        f"   Tel.:     +385 91 224 07 92         {v} +385 95 823 15 75",
        f"   Web:      www.maringrubisic.com     {v} github.com/mgrubisic",
        "",
        "   Update:   5.6.2014. / 29.4.2017.",
        "",
    ]
    inner_width = 80
    title = symbols.heavy_line * 2 + " Author's Information "
    return [
        symbols.top_left + title + symbols.heavy_line * (inner_width - len(title)) + symbols.top_right,
        *(v + line.ljust(inner_width) + v for line in content),
        symbols.bottom_left + symbols.heavy_line * inner_width + symbols.bottom_right,
    ]


def _build_report(model: _Model, iteration: _Iteration, final_moments: np.ndarray, units: str,
                  limit_accuracy: float, is_default_accuracy: bool,
                  limit_iteration: float, is_default_iteration: bool,
                  symbols: _TableSymbols) -> str:
    """Formatted text report, one line per list element."""
    sequence = iteration.sequence
    history = iteration.unbalance_history
    steps_table = np.column_stack([model.fem, iteration.increments])

    # Column widths adapt to the largest printed value
    label_width = 10
    col_width = max(8, 1 + _max_text_length(np.concatenate([steps_table.ravel(), history.ravel()])))
    table_width = label_width + (col_width + 1) + col_width * sequence.size
    step_nodes = "".join(f"{node:>{col_width}d}" for node in sequence)
    value_width = max(6, _max_text_length(np.concatenate([final_moments, history[:, -1]])))

    accuracy_text = f"{limit_accuracy:g} {units}" + (" (by default)" if is_default_accuracy else "")
    iteration_text = ("Unlimited" if limit_iteration == math.inf
                      else f"{int(limit_iteration)} iterations")
    iteration_text += " (by default)" if is_default_iteration else ""

    now = datetime.now()
    analysis_date = f"{now:%A}, {now:%B} {now.day}, {now:%Y}; {now:%H:%M:%S}"

    lines = [
        *_author_header(symbols),
        f" The Date of the Analysis: [{analysis_date}]",
        "",
        "",
        " MOMENT DISTRIBUTION METHOD (Hardy Cross, 1930)",
        "     Hardy Cross developed the moment distribution method for structural analysis of",
        "     statically indeterminate beams and frames. It was published in an ASCE journal",
        "     in 1930. The method only takes flexural effects into account and ignores axial",
        "     and shear effects.",
        "",
        "",
        " Accuracy limit in bending moment balance:     " + accuracy_text,
        " Limited total number of iterations (steps):  " + iteration_text,
        "",
        "",
        *_section_title("1) Order of Iterations (Steps) by Nodes:", symbols),
        " " + ", ".join(str(node) for node in sequence),
        "",
        *_section_title("2) Total Number of Iterations (Steps):", symbols),
        f" {sequence.size} iterations",
        "",
        *_section_title("3) Final Balanced Bending Moments:", symbols),
        f" Element :  Moment ({units})",
        *(f" ({i:2d}, {j:2d}):  {_signed_value(m, value_width)} {units}"
          for (i, j), m in zip(model.ends, final_moments)),
        "",
        *_section_title("4) Balance Control of Iterated Nodes:", symbols),
        *(f" Node {node:3d}:  {_signed_value(m, value_width)} {units}"
          for node, m in zip(model.nodes, history[:, -1])),
        "",
        *_section_title("5) All Steps of the Iteration:", symbols, table_width),
        " Element".ljust(label_width) + "Moment".rjust(col_width + 1) + step_nodes,
        symbols.line * table_width,
        *(f" ({i:2d}, {j:2d}):" + _table_row(row, col_width, zero_symbol=symbols.zero)
          for (i, j), row in zip(model.ends, steps_table)),
        symbols.line * table_width,
        " Node".ljust(label_width) + "Moment".rjust(col_width + 1) + step_nodes,
        symbols.line * table_width,
        *(f" {node:4d}".ljust(label_width) + _table_row(row, col_width, zero_symbol="")
          for node, row in zip(model.nodes, history)),
        symbols.heavy_line * table_width,
        "",
        *_citation_lines(),
        "",
        " Structural analysis completed successfully. End of document.",
    ]
    return "\n".join(lines) + "\n"


def _citation_lines() -> list[str]:
    """How to cite this software (APA style, see CITATION.cff)."""
    link = f"Zenodo. https://doi.org/{CITATION_DOI}" if CITATION_DOI else REPOSITORY_URL
    return [
        " If you use this software, please cite it as:",
        f"     Grubišić, M. ({RELEASE_YEAR}). Moment Distribution Method (Hardy Cross, 1930): MATLAB and Python",
        f"     Implementation (Version {SOFTWARE_VERSION}) [Computer software].",
        f"     {link}",
    ]


def _section_title(title: str, symbols: _TableSymbols, rule_width: int | None = None) -> list[str]:
    return [" " + title,
            symbols.heavy_line * (rule_width if rule_width is not None else len(title) + 2)]


def _signed_value(value: float, width: int) -> str:
    """'+ 12.34' / '- 12.34' / '  0.00' (no sign for values printed as 0.00)."""
    value = _without_negative_zero(value)
    sign = "+" if value > 0 else "-" if value < 0 else " "
    return f"{sign}{abs(value):{width}.2f}"


def _table_row(values: np.ndarray, col_width: int, zero_symbol: str) -> str:
    """First column is one character wider (Moment), then one column per step.

    Exact zeros are shown as zero_symbol unless it is empty.
    """
    cells = [zero_symbol.rjust(col_width) if zero_symbol and v == 0
             else f"{_without_negative_zero(v):{col_width}.2f}" for v in values]
    return " " + "".join(cells)


def _max_text_length(values: np.ndarray) -> int:
    return max(len(f"{_without_negative_zero(v):.2f}") for v in values)


def _without_negative_zero(value: float) -> float:
    """Avoid '-0.00' for values that are printed as zero."""
    return 0.0 if abs(value) < 0.005 else float(value)


def _print_text(text: str) -> None:
    """Print UTF-8 text even when the console encoding cannot represent it."""
    try:
        sys.stdout.write(text)
    except UnicodeEncodeError:
        sys.stdout.flush()
        sys.stdout.buffer.write(text.encode("utf-8"))
        sys.stdout.buffer.flush()
