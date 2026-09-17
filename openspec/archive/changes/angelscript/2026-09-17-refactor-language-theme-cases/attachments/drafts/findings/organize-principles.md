# Container organize principles (Casting sample)

Source: exploration finding `organize-principles.md` (Chinese). Q2=B. Q3 later replaced the mashup/slice vote with "one VersionTag, one case".

## Facts

- FileTag and VersionTag are two identities. Parent does not splice source.
- The Builder forced every non-root onto a parent, so a star tree is not an author edit.
- Roles: Mashup / Slice / Sibling / Bleed / Family. Casting Family count is 0.

## Principles (as accepted in the design)

**P1** Classify each VersionTag before moving, renaming, or deleting.

**P2** Parent reports lineage only. Do not describe `@parent root` as "an edit of root".

**P3** One claim, one body. Split mashup roots. Do not keep a mashup body beside its slices.

**P4** Bleed must leave the current FileTag. Known Casting bleed: nameless class, missing braces, self-inheritance, duplicate class name, super outside class; NumericImplicit unary-index operators.

**P5** Positive siblings may stay in the pocket. Negatives move to Fail files.

**P6** Only a Family is an edit tree: same program, child delta is pointable. Do not promote a Slice to Family.

**P7** This Change still does not add compile/diagnostic oracles or touch generator products. It does change the Builder so several parentless versions are legal.
