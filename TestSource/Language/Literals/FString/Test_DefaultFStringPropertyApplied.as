// Theme: Language.Literals.FString. Positive UPROPERTY default FString applied.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultFStringPropertyApplied
// sha256=279074aba3d2f99d57183fbe3a6d417a5628c21dfc97899fcd78185f0ba10c75; lines 295-312.
// Oracle: VerifyString returns 42 when MyString is "Hello World".
// Extra: empty string is not the applied default; MyString stays non-empty.
// DefaultSafe. Class owns UPROPERTY MyString.

UCLASS()
class UDefaultStringCarrier : UObject
{
	UPROPERTY()
	FString MyString;

	default MyString = "Hello World";

	UFUNCTION()
	int VerifyString()
	{
		if (MyString != "Hello World")
		{
			return 1;
		}
		return 42;
	}

	UFUNCTION()
	bool Observe_VerifyString_Nominal()
	{
		return VerifyString() == 42;
	}

	UFUNCTION()
	bool Observe_MyString_EmptyBoundary()
	{
		return MyString != "";
	}

	UFUNCTION()
	bool Observe_MyString_CopyIndependence()
	{
		FString Copy = MyString;
		Copy = "Other";
		return MyString == "Hello World" && Copy == "Other";
	}
}
