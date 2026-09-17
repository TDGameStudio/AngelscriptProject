# Topic is an open label, not an enum

Source: exploration finding `topics-open.md` (Chinese).

Parser and Builder only reject an empty `@topic`. There is no whitelist. Queries AND the given labels. An unknown label is an empty result, not a format error.

`Negative` and `SourceOnly` in the language-fixtures spec are conventional words used in scenarios, not a closed enum. Authors may add `Compile`, `Runtime`, or any new word without a schema change. Compile versus runtime polarity is carried by the two Fail files, not by an official topic table.
