# Issue Record

| ID | State | Finding | Required closure |
| --- | --- | --- | --- |
| AS-JIT-TEXT-001 | Source and regression present; fresh linked verification pending | No-operand bytecodes retained the formatter's synthetic separator and produced trailing whitespace in generated AOT comments. P019 normalizes the completed string. | Re-run the documented AOT generation/build/automation workflow, scan the regenerated fixture literally, and record terminal artifacts in `verification.md`. |

Historical evidence remains under `JIT-004` in
`test-as-native-sdk-comprehensive-coverage`. It is supporting evidence only.
