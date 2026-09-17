# Names

Source draft: `openspec/drafts/angelscript/remaining-container-type-direction/designs/tmap-tset-optional/glossary.md` (approval R3).

| Term | Chosen | Rejected | Reason |
|---|---|---|---|
| Change | `angelscript/feature-tmap-tset-optional-type-direction` | `feature-container-type-and-direction-coverage`; `feature-remaining-param-container-type-direction` | R3. Neighbor is `feature-tarray-type-and-direction-coverage`; `container` is too wide |
| TMap `&in` leaves | keep existing `*In` | rename to `Read*` | R3. `ContainsKeyIn` and siblings are already admitted FileTags |
| New directions | `Read` / `FillBy` / `Mutate` | prefer a more precise old verb when present | Matches the archived TArray contract; do not rename existing TMap `*In` |
| TMap types | FString (key), FName (key), Bool (value), FVector (value), UObject (value) | float keys | Old TMap Coverage |
| TSet types | FString, FName, Bool, FVector, UObject | float elements | Old TSet Coverage |
| TOptional types | FString, FName, Bool, FVector, UObject | float | Old TOptional Coverage |
| Corpus method | `CorpusHasTMapTSetOptionalTypeAndDirection` | split per-tree methods | Follows `CorpusHasTArrayTypeAndDirection` |
