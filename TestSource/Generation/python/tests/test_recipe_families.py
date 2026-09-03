from __future__ import annotations

from pathlib import Path

from angelscript_generation.recipes import load_recipe

RECIPES = Path(__file__).resolve().parents[2] / "recipes"


def test_every_registry_family_recipe_loads() -> None:
    files = sorted(RECIPES.glob("*.json"))
    assert len(files) == 22
    ids = {load_recipe(path).recipe_id for path in files}
    assert "authored-source-export" in ids
    assert "function-signature-product" in ids
    assert "authored-host-scenario" in ids
