/**
 * Reading a private UCLASS member from a free function is rejected.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.PrivateAccessFailure
 * @Harness CompileReject
 * @Tag Definitions.UClass.PrivateAccessFailure
 * @Kind CompileReject
 * @Covers UClass.Access
 * @Inputs Object.SecretValue from outside the class
 * @Return does not compile; diagnostic "Illegal access to private property 'SecretValue'"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: illegal private member access from a free function.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassAccessControlCompileFailures CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: "Illegal access to private property 'SecretValue'".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class UCoverageUClassPrivateAccessObject : UObject
{
	private int SecretValue = 42;
}

/**
 * Illegal read of a private member from a free function.
 *
 * @Kind CompileReject
 * @Covers UClass.Access
 * @Param Object Host whose SecretValue is private
 * @Inputs Object.SecretValue
 * @Return does not compile
 */
int ReadPrivateAccess(UCoverageUClassPrivateAccessObject Object)
{
	return Object.SecretValue;
}
