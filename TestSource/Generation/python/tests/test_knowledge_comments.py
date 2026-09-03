from __future__ import annotations

import pytest

from angelscript_generation.comments import render_comment_block, validate_comment_facts
from angelscript_generation.schema import SchemaError


def test_required_facts_are_present() -> None:
    facts = validate_comment_facts(
        {
            "feature": "IsActorInitialized",
            "inputs": "spawned actor and CDO",
            "expectations": "true after initialization",
            "boundary": "CDO is not initialized",
        }
    )
    text = render_comment_block(facts)
    assert "IsActorInitialized" in text
    assert "spawned actor" in text
    assert "true after initialization" in text


def test_missing_expectation_fails() -> None:
    with pytest.raises(SchemaError) as caught:
        validate_comment_facts({"feature": "x", "inputs": "y"})
    assert caught.value.code == "missing_comment_fact"
