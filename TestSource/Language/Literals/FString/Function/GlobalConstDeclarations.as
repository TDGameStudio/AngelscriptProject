/**
 * Module-level const declarations for the string family. These globals are
 * initialized once at module load, so the oracle proves their values are
 * visible to every function in the module.
 *
 * @Theme Language.Literals
 * @Subject Literals.GlobalConstDeclarations
 * @Harness Function
 * @Tag Language.Literals.GlobalConstDeclarations
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::GlobalConstDeclarations
 * @Provenance sha256 from TS-LANG-0126; lines 196-215.
 * @Provenance Oracle: GetGlobalString "Global"; GetGlobalName n"GlobalName"; GetGlobalText empty.
 * @Provenance Extra: default const FText ToString is empty; name is not a default FName.
 * @Provenance DefaultSafe. Module owns const globals.
 */

const FString GConstString = "Global";
const FName GConstName = n"GlobalName";
const FText GConstText;

namespace LiteralsTest
{
	/**
	 * Reads the module-level const string.
	 *
	 * @Covers Literals.FString
	 * @Inputs the module-level const FString
	 * @Return "Global"
	 */
	FString GetGlobalString()
	{
		return GConstString;
	}

	/**
	 * Reads the module-level const name.
	 *
	 * @Covers Literals.FString
	 * @Inputs the module-level const FName
	 * @Return n"GlobalName"
	 */
	FName GetGlobalName()
	{
		return GConstName;
	}

	/**
	 * Reads the module-level const text.
	 *
	 * @Covers Literals.FString
	 * @Inputs the module-level const FText
	 * @Return the underlying string, expected to be empty
	 */
	FString GetGlobalText()
	{
		return GConstText.ToString();
	}

	/**
	 * Observe that the const string and name hold their initialized values.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs the module-level const globals
	 * @Return true when both values match
	 */
	UFUNCTION()
	bool GlobalConstDeclarationProduceExpectedValues()
	{
		if (GetGlobalString() != "Global")
		{
			return false;
		}

		return GetGlobalName() == n"GlobalName";
	}

	/**
	 * Observe that a default-constructed const FText stringifies as empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs the module-level const FText
	 * @Return true when the string is empty
	 * @Boundary default-constructed FText
	 */
	UFUNCTION()
	bool GlobalConstEmptyTextBoundary()
	{
		return GetGlobalText() == "";
	}

	/**
	 * Observe that the const name is not NAME_None.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs GetGlobalName() against a default FName
	 * @Return true when the const name differs from NAME_None
	 * @Boundary NAME_None
	 */
	UFUNCTION()
	bool GlobalNameNotNoneBoundary()
	{
		FName Empty;
		return GetGlobalName() != Empty;
	}
}
