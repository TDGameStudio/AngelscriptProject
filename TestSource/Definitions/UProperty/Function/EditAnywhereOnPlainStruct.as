/**
 * EditAnywhere on a plain non-USTRUCT member currently compiles because C++
 * wraps the failure in #if 0 (structural-validation-absent). The observers
 * cover the default 0 and copy independence after mutate.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.EditAnywhereOnPlainStruct
 * @Harness Function
 * @Tag Definitions.UProperty.EditAnywhereOnPlainStruct
 * @Namespace UPropertyTest
 * @Provenance Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
 * @Provenance in #if 0 (#as-engine-behavior: structural-validation-absent) so EditAnywhere on a
 * @Provenance plain non-USTRUCT member currently compiles.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
 * @Provenance UPropSN_EditNonClass; lines 285-291;
 * @Provenance sha256=5122b7bdd56506d88279f1eddd568a145bd5e15ab8ecd869617fdebe7fce3bf1.
 * @Provenance Oracle: FPlain.X default is 0. Extra: 0 empty/default; copy-independence after mutate.
 * @Provenance DefaultSafe. Source owns locals.
 */

struct FPlain
{
	UPROPERTY(EditAnywhere)
	int X = 0;
}

namespace UPropertyTest
{
	/**
	 * Observe the default X of a plain struct.
	 *
	 * @Kind Observe
	 * @Covers UProperty.EditAnywhereOnPlainStruct
	 * @Inputs a default-constructed FPlain
	 * @Return true when X is 0
	 */
	UFUNCTION()
	bool PlainDefault()
	{
		FPlain Value;
		return Value.X == 0;
	}

	/**
	 * Observe that a second default-constructed FPlain is also 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.EditAnywhereOnPlainStruct
	 * @Inputs a default-constructed FPlain
	 * @Return true when X is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool PlainEmptyDefault()
	{
		FPlain Value;
		return Value.X == 0;
	}

	/**
	 * Observe that mutating a copy leaves the original at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.EditAnywhereOnPlainStruct
	 * @Inputs a default-constructed FPlain copied then mutated
	 * @Return true when Original.X is 0 and Copy.X is 7
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PlainCopyIndependence()
	{
		FPlain Original;
		FPlain Copy = Original;
		Copy.X = 7;
		if (Original.X != 0)
		{
			return false;
		}
		return Copy.X == 7;
	}
}
