/**
 * The consumer half of a declared-function import round-trip: the module imports
 * SharedValue by signature from the provider and returns it unchanged.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ImportConsumerModule
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ImportConsumerModule
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerImportTests.cpp::DeclaredFunctionImportRoundTrip block 2
 * @Provenance sha256=ee7033f0ccd7227ff6498719ac24f9a0139862c8a48bb3254ec1a514d92af07e; lines 133-140.
 * @Provenance Oracle: Entry() returns the imported SharedValue (77 from the provider).
 * @Provenance Extra: repeating Entry is stable. DefaultSafe.
 */

/**
 * Brings in the provider's exported function by signature.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the module Tests.Compiler.ImportSource
 * @Return the imported SharedValue declaration
 */
import int SharedValue() from "Tests.Compiler.ImportSource";

namespace SyntaxTest
{
	/**
	 * Returns the value obtained through the import.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the imported SharedValue
	 * @Return 77
	 */
	int Entry()
	{
		return SharedValue();
	}

	/**
	 * Observe that the imported value came through.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 77
	 */
	UFUNCTION()
	bool ImportConsumerReturnsImportedValue()
	{
		return Entry() == 77;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 77
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ImportConsumerRepeatsConsistently()
	{
		if (Entry() != 77)
		{
			return false;
		}

		return Entry() == 77;
	}
}
