from __future__ import annotations

import hashlib
import random


class DeterministicRandom:
    """Case-local random source that never depends on process-global RNG state."""

    def __init__(self, seed: int, ordinal: int) -> None:
        if not 0 <= seed < 2**64:
            raise ValueError("seed must be an unsigned 64-bit integer")
        if not 0 <= ordinal < 2**64:
            raise ValueError("ordinal must be an unsigned 64-bit integer")
        material = seed.to_bytes(8, "big") + ordinal.to_bytes(8, "big")
        derived_seed = int.from_bytes(hashlib.blake2b(material, digest_size=16).digest(), "big")
        self._random = random.Random(derived_seed)

    def choice(self, values: tuple[str, ...] | tuple[int, ...]) -> str | int:
        return self._random.choice(values)

    def integer(self, minimum: int, maximum: int) -> int:
        return self._random.randint(minimum, maximum)

    def chance(self, numerator: int, denominator: int) -> bool:
        if denominator <= 0 or numerator < 0 or numerator > denominator:
            raise ValueError("probability must satisfy 0 <= numerator <= denominator and denominator > 0")
        return self._random.randrange(denominator) < numerator
