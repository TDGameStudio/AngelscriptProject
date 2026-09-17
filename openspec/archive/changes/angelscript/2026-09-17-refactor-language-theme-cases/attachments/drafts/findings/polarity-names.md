# Negative file names

Source: exploration finding `polarity-names.md` (Chinese).

External corpora: Test262 keeps polarity in YAML `negative.phase`; libcxx uses `compile.fail` suffixes; this repo's old tree used `Reject/`; Pending used `*Rejected`. Welding `Negative` onto the FileTag is not the common pattern.

Q9 chose `Fail`. Q10 split compile-fail and runtime-fail into two files. R20 accepted the suffixes `CompileFail` and `RuntimeFail`. `@topic Negative` may still appear as an open label. VersionTags stay `invalid-<kebab>`.
