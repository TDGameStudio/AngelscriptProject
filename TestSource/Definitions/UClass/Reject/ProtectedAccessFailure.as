/**
 * Reading a protected UCLASS member from a free function is rejected.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ProtectedAccessFailure
 * @Harness CompileReject
 * @Tag Definitions.UClass.ProtectedAccessFailure
 * @Kind CompileReject
 * @Covers UClass.Access
 * @Inputs Object.ProtectedValue from outside the class
 * @Return does not compile; diagnostic "Illegal access to protected property 'ProtectedValue'"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: illegal protected member access from a free function.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassAccessControlCompileFailures CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: "Illegal access to protected property 'ProtectedValue'".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class UCoverageUClassProtectedAccessObject : UObject
{
	protected int ProtectedValue = 23;
}

/**
 * Illegal read of a protected member from a free function.
 *
 * @Kind CompileReject
 * @Covers UClass.Access
 * @Param Object Host whose ProtectedValue is protected
 * @Inputs Object.ProtectedValue
 * @Return does not compile
 */
int ReadProtectedAccess(UCoverageUClassProtectedAccessObject Object)
{
	return Object.ProtectedValue;
}
