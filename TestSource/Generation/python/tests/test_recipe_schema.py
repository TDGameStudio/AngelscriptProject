from __future__ import annotations

from pathlib import Path

from angelscript_generation.recipes import enumerate_cells, load_recipe

RECIPES = Path(__file__).resolve().parents[2] / "recipes"


def test_authored_recipe_has_one_cell_for_every_seed() -> None:
    recipe = load_recipe(RECIPES / "authored-source-export.json")
    first = enumerate_cells(recipe)
    second = enumerate_cells(recipe)
    assert first == second
    assert len(first) == 1


def test_function_signature_product_cardinality_is_seed_independent() -> None:
    recipe = load_recipe(RECIPES / "function-signature-product.json")
    cells = enumerate_cells(recipe)
    assert len(cells) == recipe.mandatory_cell_count
    assert len({tuple(sorted(cell.items())) for cell in cells}) == len(cells)
