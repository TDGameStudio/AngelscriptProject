"""Independent Python generation contract owned by TestSource/Generation.

This package is the Python peer of the portable C++ implementation. It must
not import Unreal types or call C++. Observable algorithms are specified
in goldens under TestSource/Generation/goldens.
"""

from .case_key import CaseKeyError, case_key_from_authored_path, cpp_symbol, fnv1a64_utf8
from .canonical import CanonicalError, canonical_json_bytes, canonical_source_bytes
from .schema import (
    SCHEMA_VERSION_REQUEST,
    GenerationRequest,
    GenerationResult,
    SchemaError,
    load_request,
    load_result,
)
from .splitmix64 import SplitMix64, derive_substream, bounded_index, fisher_yates

__all__ = [
    "CaseKeyError",
    "CanonicalError",
    "GenerationRequest",
    "GenerationResult",
    "SCHEMA_VERSION_REQUEST",
    "SchemaError",
    "SplitMix64",
    "bounded_index",
    "canonical_json_bytes",
    "canonical_source_bytes",
    "case_key_from_authored_path",
    "cpp_symbol",
    "derive_substream",
    "fisher_yates",
    "fnv1a64_utf8",
    "load_request",
    "load_result",
]
