/**
 * Primitive map key and value structs used by later TMap parameter/return
 * fragments. C++ compiles FMapPrimitiveKey and FMapPrimitiveValue as a complete
 * program.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.MapPrimitiveKeyValueStructs
 * @Harness Function
 * @Tag Definitions.UStruct.MapPrimitiveKeyValueStructs
 * @Namespace UStructTest
 * @Provenance Theme: Definitions.UStruct. Positive block 1: primitive map key/value structs.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapPrimitiveKeyValueParameterAndReturnMatrix lines 13551-13581.
 * @Provenance Isolation=none: complete program of FMapPrimitiveKey/FMapPrimitiveValue. Oracle: default ID 0 Score 0.
 * @Provenance Extra: opEquals false across IDs; Hash of zero key is 0. DefaultSafe.
 */

USTRUCT(BlueprintType)
struct FMapPrimitiveKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.MapPrimitiveKeyValueStructs
	 * @Inputs another FMapPrimitiveKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FMapPrimitiveKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 977 plus Tag.GetHash().
	 *
	 * @Covers UStruct.MapPrimitiveKeyValueStructs
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FMapPrimitiveValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

namespace UStructTest
{
	/**
	 * Observe primitive key/value defaults and the zero-key hash.
	 *
	 * @Kind Observe
	 * @Covers UStruct.MapPrimitiveKeyValueStructs
	 * @Inputs default FMapPrimitiveKey and FMapPrimitiveValue
	 * @Return true when ID/Score are 0, Tag/Label are empty, and Hash is 0
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool MapPrimitiveTypesDefaultEmpty()
	{
		FMapPrimitiveKey Key;
		FMapPrimitiveValue Value;
		if (Key.ID != 0)
		{
			return false;
		}
		if (Key.Tag != n"")
		{
			return false;
		}
		if (Value.Score != 0)
		{
			return false;
		}
		if (Value.Label.Len() != 0)
		{
			return false;
		}
		return Key.Hash() == uint32(0);
	}

	/**
	 * Observe equality across matching and differing IDs.
	 *
	 * @Kind Observe
	 * @Covers UStruct.MapPrimitiveKeyValueStructs
	 * @Inputs A and B with ID 1/Alpha, C with ID 2/Beta
	 * @Return true when A equals B, A does not equal C, and A.Hash equals B.Hash
	 * @Boundary equality
	 */
	UFUNCTION()
	bool MapPrimitiveTypesEqualityBoundary()
	{
		FMapPrimitiveKey A;
		A.ID = 1;
		A.Tag = n"Alpha";
		FMapPrimitiveKey B;
		B.ID = 1;
		B.Tag = n"Alpha";
		FMapPrimitiveKey C;
		C.ID = 2;
		C.Tag = n"Beta";
		bool Same = (A == B);
		if (!Same)
		{
			return false;
		}
		bool Different = (A == C);
		if (Different)
		{
			return false;
		}
		return A.Hash() == B.Hash();
	}

	/**
	 * Observe a zeroed value Score.
	 *
	 * @Kind Observe
	 * @Covers UStruct.MapPrimitiveKeyValueStructs
	 * @Inputs a value whose Score and Label were cleared
	 * @Return 0
	 * @Boundary zero score
	 */
	UFUNCTION()
	int MapPrimitiveTypesValueScoreBoundary()
	{
		FMapPrimitiveValue Value;
		Value.Score = 0;
		Value.Label = "";
		return Value.Score;
	}
}
