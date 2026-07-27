# Issue Addendum

| ID | State | Finding | Required closure |
| --- | --- | --- | --- |
| AS-REF-PERSIST-001 | Source and focused regression present; full linked verification pending | GETOBJ uses current-fork `asBCTYPE_W_rW_ARG`, but restore omitted an explicit reader/writer path and stack adjustment for operand 1. P138/P142/P150/P151 repair the contract; P149 documents it. | Complete stream compatibility/malformed-input work and run fresh focused save/load plus aggregate gates. |
| AS-REF-PERSIST-002 | Narrow export present; fresh linked verification pending | The exact precompiled remap regression must call `FAngelscriptPrecompiledFunction::Process` across Runtime/Test DLLs. The pre-export build failed LNK2019; P022 exposes only the existing member. | Re-run the exact fully qualified regression after a coherent build and record report, exit, shutdown, and source/target remap evidence. |

Neither issue belongs to double-to-64-bit numeric conversion.
