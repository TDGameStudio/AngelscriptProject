from __future__ import annotations

import json
from pathlib import Path

from angelscript_generation.splitmix64 import (
    SplitMix64,
    bounded_index,
    derive_substream,
    fisher_yates,
    splitmix64_step,
)

GOLDEN = Path(__file__).resolve().parents[2] / "goldens" / "splitmix64-v1.json"


def test_state_transitions_match_golden() -> None:
    payload = json.loads(GOLDEN.read_text(encoding="utf-8"))
    state = int(payload["initialState"])
    for expected in payload["nextValues"]:
        state, value = splitmix64_step(state)
        assert value == int(expected)


def test_bounded_draws_and_shuffle_match_golden() -> None:
    payload = json.loads(GOLDEN.read_text(encoding="utf-8"))
    rng = SplitMix64(int(payload["boundedState"]))
    draws = [bounded_index(rng, payload["bound"]) for _ in range(payload["boundedCount"])]
    assert draws == payload["boundedDraws"]
    shuffled = fisher_yates(list(payload["shuffleInput"]), SplitMix64(int(payload["shuffleState"])))
    assert shuffled == payload["shuffleOutput"]


def test_named_substreams_are_independent() -> None:
    payload = json.loads(GOLDEN.read_text(encoding="utf-8"))
    left = derive_substream(1, "TestSource/Bindings/AActor/Test_Queries_01", 0, "literal")
    right = derive_substream(1, "TestSource/Bindings/AActor/Test_Queries_01", 0, "identifier")
    assert left == int(payload["substreamLiteral"])
    assert right == int(payload["substreamIdentifier"])
    assert left != right


def test_empty_and_single_shuffle() -> None:
    assert fisher_yates([], SplitMix64(0)) == []
    assert fisher_yates([7], SplitMix64(0)) == [7]
