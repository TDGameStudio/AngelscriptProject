/**
 * A derived class reading an inherited private member is rejected.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.InheritedPrivateAccessFailure
 * @Harness CompileReject
 * @Tag Definitions.UClass.InheritedPrivateAccessFailure
 * @Kind CompileReject
 * @Covers UClass.Access
 * @Inputs return BaseSecret from the derived class
 * @Return does not compile; diagnostic "Illegal access to inherited private property 'BaseSecret'"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: derived class reads inherited private member.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassAccessControlCompileFailures CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: "Illegal access to inherited private property 'BaseSecret'".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class UCoverageUClassPrivateBaseObject : UObject
{
	private int BaseSecret = 17;
}

UCLASS()
class UCoverageUClassPrivateDerivedObject : UCoverageUClassPrivateBaseObject
{
	/**
	 * Illegal read of the base class private member.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.Access
	 * @Inputs BaseSecret inherited as private
	 * @Return does not compile
	 */
	int ReadBaseSecret()
	{
		return BaseSecret;
	}
}
