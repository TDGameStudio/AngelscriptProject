/**
 * A UObject carrier declares a default FString UPROPERTY through the `default`
 * initialiser. The member reads back the applied default, stays non-empty, and
 * copies independently of the original. The UPROPERTY name MyString is read by
 * path from C++ and must not be renamed.
 *
 * @Theme Language.Literals
 * @Subject Literals.DefaultFStringPropertyApplied
 * @Harness UClass
 * @Tag Language.Literals.DefaultFStringPropertyApplied
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultFStringPropertyApplied
 * @Provenance sha256=279074aba3d2f99d57183fbe3a6d417a5628c21dfc97899fcd78185f0ba10c75; lines 295-312.
 * @Provenance Oracle: VerifyString returns 42 when MyString is "Hello World".
 * @Provenance Extra: empty string is not the applied default; MyString stays non-empty.
 * @Provenance DefaultSafe. Class owns UPROPERTY MyString.
 */

UCLASS()
class UDefaultStringCarrier : UObject
{
	UPROPERTY()
	FString MyString;

	default MyString = "Hello World";

	/**
	 * Report the verification result: 42 when MyString holds the applied
	 * default, otherwise 1.
	 *
	 * @Covers Literals.FString
	 * @Inputs The carrier's default MyString
	 * @Return 42 on success, 1 on mismatch
	 */
	UFUNCTION()
	int VerifyString()
	{
		if (MyString != "Hello World")
		{
			return 1;
		}
		return 42;
	}

	/**
	 * Confirm the applied default reads back through VerifyString.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs VerifyString over the carrier
	 * @Return true when VerifyString reports 42
	 */
	UFUNCTION()
	bool VerifyStringReturnsSuccess()
	{
		return VerifyString() == 42;
	}

	/**
	 * Confirm MyString is non-empty at the empty boundary.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The carrier's default MyString
	 * @Return true when MyString is not the empty string
	 * @Boundary empty-string sentinel
	 */
	UFUNCTION()
	bool VerifyMyStringNotEmptyAtBoundary()
	{
		return MyString != "";
	}

	/**
	 * Confirm copying MyString and mutating the copy leaves the member
	 * unchanged.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A copy of MyString changed to "Other"
	 * @Return true when MyString stays "Hello World" and the copy is "Other"
	 */
	UFUNCTION()
	bool VerifyMyStringCopyIsIndependent()
	{
		FString Copy = MyString;
		Copy = "Other";
		if (MyString != "Hello World")
		{
			return false;
		}
		return Copy == "Other";
	}
}
