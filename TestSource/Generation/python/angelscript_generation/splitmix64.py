"""SplitMix64-v1 portable RNG.

State transition is Steele/Vigna SplitMix64. Bounded draws use rejection
sampling against floor((2^64-1)/n)*n so the remainder never introduces
modulo bias. Permutations use Fisher-Yates with those unbiased draws.
Named substreams mix seed, CaseKey, cell index, and slot independently.
"""

from __future__ import annotations

MASK = (1 << 64) - 1
GAMMA = 0x9E3779B97F4A7C15
M1 = 0xBF58476D1CE4E5B9
M2 = 0x94D049BB133111EB
FNV_OFFSET = 14695981039346656037
FNV_PRIME = 1099511628211


def fnv1a64(data: bytes) -> int:
    h = FNV_OFFSET
    for byte in data:
        h ^= byte
        h = (h * FNV_PRIME) & MASK
    return h


def splitmix64_step(state: int) -> tuple[int, int]:
    if not 0 <= state <= MASK:
        raise ValueError("state must be an unsigned 64-bit integer")
    state = (state + GAMMA) & MASK
    z = state
    z = ((z ^ (z >> 30)) * M1) & MASK
    z = ((z ^ (z >> 27)) * M2) & MASK
    return state, z ^ (z >> 31)


def derive_substream(seed: int, case_key: str, cell_index: int, slot: str) -> int:
    if not 0 <= seed <= MASK:
        raise ValueError("seed must be an unsigned 64-bit integer")
    if not 0 <= cell_index <= MASK:
        raise ValueError("cell_index must be an unsigned 64-bit integer")
    _, mixed_seed = splitmix64_step(seed)
    _, mixed_cell = splitmix64_step(cell_index)
    return mixed_seed ^ fnv1a64(case_key.encode("utf-8")) ^ mixed_cell ^ fnv1a64(slot.encode("utf-8"))


class SplitMix64:
    def __init__(self, state: int) -> None:
        if not 0 <= state <= MASK:
            raise ValueError("state must be an unsigned 64-bit integer")
        self._state = state

    @property
    def state(self) -> int:
        return self._state

    def next_u64(self) -> int:
        self._state, value = splitmix64_step(self._state)
        return value


def bounded_index(rng: SplitMix64, bound: int) -> int:
    """Unbiased index in [0, bound)."""
    if bound <= 0:
        raise ValueError("bound must be positive")
    if bound == 1:
        return 0
    limit = (MASK // bound) * bound
    while True:
        draw = rng.next_u64()
        if draw < limit:
            return draw % bound


def fisher_yates(values: list[int], rng: SplitMix64) -> list[int]:
    items = list(values)
    n = len(items)
    for i in range(n - 1, 0, -1):
        j = bounded_index(rng, i + 1)
        items[i], items[j] = items[j], items[i]
    return items
