from __future__ import annotations

import sys
from pathlib import Path

import pytest


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.generation.random_source import DeterministicRandom


def test_case_local_random_source_is_stable_and_ordinal_scoped() -> None:
    first = DeterministicRandom(42, 3)
    repeated = DeterministicRandom(42, 3)
    next_case = DeterministicRandom(42, 4)

    first_values = tuple(first.integer(-100, 100) for _ in range(4))

    assert first_values == tuple(repeated.integer(-100, 100) for _ in range(4))
    assert first_values != tuple(next_case.integer(-100, 100) for _ in range(4))


@pytest.mark.parametrize("seed, ordinal", [(-1, 0), (2**64, 0), (0, -1), (0, 2**64)])
def test_random_source_rejects_values_outside_the_uint64_identity_range(seed: int, ordinal: int) -> None:
    with pytest.raises(ValueError, match="unsigned 64-bit"):
        DeterministicRandom(seed, ordinal)


def test_random_source_rejects_invalid_probability_bounds() -> None:
    random_source = DeterministicRandom(0, 0)

    with pytest.raises(ValueError, match="probability"):
        random_source.chance(2, 1)
