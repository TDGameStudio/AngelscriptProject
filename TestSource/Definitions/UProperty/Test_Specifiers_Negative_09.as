// Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
// in #if 0 (#as-engine-behavior: structural-validation-absent) so EditAnywhere on a
// plain non-USTRUCT member currently compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
// UPropSN_EditNonClass; lines 285-291;
// sha256=5122b7bdd56506d88279f1eddd568a145bd5e15ab8ecd869617fdebe7fce3bf1.
// Oracle: FPlain.X default is 0. Extra: 0 empty/default; copy-independence after mutate.
// DefaultSafe. Source owns locals.

struct FPlain
{
	UPROPERTY(EditAnywhere)
	int X = 0;
}

bool Observe_Plain_Nominal()
{
	FPlain Value;
	return Value.X == 0;
}

bool Observe_Plain_EmptyDefault()
{
	FPlain Value;
	return Value.X == 0;
}

bool Observe_Plain_CopyIndependence()
{
	FPlain Original;
	FPlain Copy = Original;
	Copy.X = 7;
	return Original.X == 0 && Copy.X == 7;
}
