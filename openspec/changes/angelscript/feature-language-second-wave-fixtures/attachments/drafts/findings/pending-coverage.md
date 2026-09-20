# Real gap between Language and Pending/Language

Date: 2026-09-17. Source draft finding (Chinese original; approval R27).

Workspace: `git_3b46972bbc7ef05a4244fd2890d18183` / `D:\Workspace\AngelscriptProject`. `theme-case-containers` is already handed off. This note does not reopen that format contract.

## File counts mislead

```
Language/                         95 .as files / 475 @begin cases
├─ Casting 43
├─ ControlFlow 99
├─ Namespace 29
├─ Operators 118
├─ Preprocessor 16
└─ Syntax 170                     // theme pockets: several cases per file

Pending/Language/                 558 .as files
├─ same first-wave themes 423
│  ├─ Reject/ 249 (whole tree)
│  ├─ UClass/ 124
│  └─ bodies with UCLASS/UFUNCTION/UPROPERTY 258
├─ missing theme roots 66         // Auto Class Const Destructors Inheritance Mixin Properties Typedef
└─ Literals/FString 69            // host strings, not core language
```

The first wave `feature-testcode-language-fixtures` admitted 47 FileTags across six themes. Census of 624 old sources: adapted 147, excluded 477. Exclusions: no UClass, no FString/UE APIs, no UFUNCTION/@Kind Observe. Pending is that old tree (now 558).

The format refactor already absorbed many former "theme Reject outside the FileTag" cases into `*CompileFail`. Language case count is already close to the Pending file count. The remaining gap is **whole missing themes**, plus **host files that must not enter Language**.

## Second wave already drafted in Pending

`Pending/Language/Migration.md` names Class / Inheritance / Destructors / Typedef / Properties / Mixin / Auto / Const. Those files are mostly host-free (umacro=0 in the 66) but still use `@version root` and forced parent stars.

`Pending/Language/Casting/UClass/ObjectCastAndTypeChecks.as` is the counter-example: `UCLASS` / `UFUNCTION` / `SpawnActor` / `@Kind WorldStory`. First-wave exclusion. Bindings/World/Unreal, not Language.

## Language-surface filter

`openspec/specs/angelscript/language/surface`: virtual properties are removed. Pending `Properties/` cannot enter as positives.

Mixin / typedef / auto / destructors / inheritance are not on the removal list.

## How to promote

Do not copy 558 to 558. Promotion uses the accepted pocket contract. After merge, expect about one positive pocket plus CompileFail per theme.
