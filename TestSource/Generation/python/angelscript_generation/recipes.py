"""Recipe loading and exhaustive explicit-axis enumeration."""

from __future__ import annotations

import json
from dataclasses import dataclass
from itertools import product
from pathlib import Path
from typing import Any, Iterator

from .schema import SchemaError

RECIPE_VERSION = "recipe-v1"


@dataclass(frozen=True)
class Recipe:
    recipe_id: str
    recipe_version: str
    owner: str
    explicit_axes: tuple[tuple[str, tuple[Any, ...]], ...]
    constraints: tuple[dict[str, Any], ...]
    random_slots: tuple[str, ...]
    oracle_kinds: tuple[str, ...]
    negative_policy: str
    comment_policy: str
    mandatory_cell_count: int | None


def load_recipe(payload: dict[str, Any] | str | Path) -> Recipe:
    if isinstance(payload, Path):
        payload = json.loads(payload.read_text(encoding="utf-8"))
    elif isinstance(payload, str):
        payload = json.loads(payload)
    if not isinstance(payload, dict):
        raise SchemaError("invalid_object", "recipe must be a JSON object")
    if payload.get("schemaVersion") != RECIPE_VERSION:
        raise SchemaError(
            "unsupported_schema_version",
            f"unsupported recipe schema {payload.get('schemaVersion')}",
        )
    axes = []
    for axis in payload.get("explicitAxes") or []:
        name = axis["name"]
        values = tuple(axis["values"])
        axes.append((name, values))
    slots = tuple(slot["name"] for slot in (payload.get("randomSlots") or []))
    count = payload.get("mandatoryCellCount")
    return Recipe(
        recipe_id=str(payload["recipeId"]),
        recipe_version=str(payload["recipeVersion"]),
        owner=str(payload["owner"]),
        explicit_axes=tuple(axes),
        constraints=tuple(payload.get("constraints") or ()),
        random_slots=slots,
        oracle_kinds=tuple(payload.get("oracleKinds") or ()),
        negative_policy=str(payload.get("negativePolicy") or ""),
        comment_policy=str(payload.get("commentPolicy") or ""),
        mandatory_cell_count=None if count is None else int(count),
    )


def _allowed(cell: dict[str, Any], constraints: tuple[dict[str, Any], ...]) -> bool:
    for constraint in constraints:
        forbidden = constraint.get("forbid")
        if isinstance(forbidden, dict) and all(cell.get(k) == v for k, v in forbidden.items()):
            return False
    return True


def enumerate_cells(recipe: Recipe) -> list[dict[str, Any]]:
    if not recipe.explicit_axes:
        cells = [{}]
    else:
        names = [name for name, _ in recipe.explicit_axes]
        value_lists = [values for _, values in recipe.explicit_axes]
        cells = []
        for combo in product(*value_lists):
            cell = {names[i]: combo[i] for i in range(len(names))}
            if _allowed(cell, recipe.constraints):
                cells.append(cell)
    if recipe.mandatory_cell_count is not None and recipe.mandatory_cell_count != len(cells):
        raise SchemaError(
            "matrix_cardinality",
            f"{recipe.recipe_id} expected {recipe.mandatory_cell_count} cells, got {len(cells)}",
        )
    return cells


def cells_for_seeds(recipe: Recipe, seeds: Iterator[int]) -> dict[int, list[dict[str, Any]]]:
    canonical = enumerate_cells(recipe)
    return {seed: list(canonical) for seed in seeds}
