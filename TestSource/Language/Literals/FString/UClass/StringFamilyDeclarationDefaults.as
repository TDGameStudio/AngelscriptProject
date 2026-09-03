/**
 * String-family members on a script actor keep the defaults declared in the
 * UPROPERTY initialisers. The actor exposes FString, FName, and FText members
 * with and without explicit defaults, and the observers confirm the values
 * survive declaration, the empty fields stay empty, and copying a member does
 * not alias it. The UPROPERTY names are read by path from C++ and must not be
 * renamed: StringValue, EmptyString, NoDefaultString, NameValue, EmptyName,
 * TextValue.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringFamilyDeclarationDefaults
 * @Harness UClass
 * @Tag Language.Literals.StringFamilyDeclarationDefaults
 * @Provenance C++: AngelscriptCoverageFStringPropertyTests.cpp::StringFamilyDeclarationDefaults
 * @Provenance sha256=0d0ea2f9dcbc88c4a32203c2d733e462ae615818801915ab3b85ebdd56d3105c; lines 202-224.
 * @Provenance Oracle VerifyByPath: StringValue Hello; EmptyString ""; NoDefaultString ""; NameValue MyName;
 * @Provenance EmptyName NAME_None; TextValue empty.
 * @Provenance Extra: Observe helpers keep those UPROPERTY names; empty FText IsEmpty.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageFStringDefaultsActor : AActor
{
	UPROPERTY()
	FString StringValue = "Hello";

	UPROPERTY()
	FString EmptyString = "";

	UPROPERTY()
	FString NoDefaultString;

	UPROPERTY()
	FName NameValue = n"MyName";

	UPROPERTY()
	FName EmptyName = n"";

	UPROPERTY()
	FText TextValue;

	/**
	 * Confirm every declared string-family default matches its initialiser.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The actor's declared defaults
	 * @Return true when all six members read back their declared values
	 */
	UFUNCTION()
	bool VerifyDefaultsMatchDeclaration()
	{
		if (StringValue != "Hello")
		{
			return false;
		}
		if (EmptyString != "")
		{
			return false;
		}
		if (NoDefaultString != "")
		{
			return false;
		}
		if (NameValue != n"MyName")
		{
			return false;
		}
		if (EmptyName != n"")
		{
			return false;
		}
		return TextValue.IsEmpty();
	}

	/**
	 * Confirm the empty-boundary members stay empty at declaration time.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The actor's empty FString and FName members
	 * @Return true when the empty fields have zero length or NAME_None
	 * @Boundary empty defaults
	 */
	UFUNCTION()
	bool VerifyEmptyFieldsStayEmpty()
	{
		if (EmptyString.Len() != 0)
		{
			return false;
		}
		if (NoDefaultString != "")
		{
			return false;
		}
		return EmptyName == n"";
	}

	/**
	 * Confirm copying StringValue and mutating the copy leaves the member
	 * unchanged.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A copy of StringValue changed to "Other"
	 * @Return true when StringValue is still "Hello" and the copy is "Other"
	 */
	UFUNCTION()
	bool VerifyStringValueCopyIsIndependent()
	{
		FString Copy = StringValue;
		Copy = "Other";
		if (StringValue != "Hello")
		{
			return false;
		}
		return Copy == "Other";
	}
}
