/**
 * A USTRUCT may not use inheritance syntax. This file is the illegal program
 * itself; dropping ": FBaseStruct" would make it compile.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.InheritanceRejected
 * @Harness CompileReject
 * @Tag Feature.Inheritance.InheritanceRejected
 * @Kind CompileReject
 * @Covers Inheritance.InheritanceRejected
 * @Inputs USTRUCT FDerivedStruct : FBaseStruct
 * @Return does not compile; "Error parsing script struct FDerivedStruct. Structs may not inherit from anything."
 * @Provenance Theme: Feature.Inheritance. Isolated compile-fail: USTRUCT may not use inheritance syntax.
 * @Provenance C++: AngelscriptPreprocessorStructTests.cpp::InheritanceRejected
 * @Provenance Expected diagnostic: "Error parsing script struct FDerivedStruct. Structs may not inherit from anything."
 * @Provenance DiagnosticOnly. Do not drop ": FBaseStruct"; that would make the program compile.
 */

USTRUCT()
struct FDerivedStruct : FBaseStruct
{
	UPROPERTY()
	int Value;
}
