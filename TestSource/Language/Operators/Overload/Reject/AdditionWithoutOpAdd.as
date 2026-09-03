/**
 * Using + on a type that declares no opAdd is rejected: there is no operator
 * to dispatch to. This file is the illegal program itself; do not add opAdd or
 * anything else that would make it compile, since the missing operator is the
 * point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AdditionWithoutOpAdd
 * @Harness CompileReject
 * @Tag Language.Operators.AdditionWithoutOpAdd
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A + B where the struct declares no operator overloads
 * @Return does not compile; diagnostic "using + without opAdd overload should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative AssertFailsToCompile ASSyntaxOONoOp; lines 278-290;
 * @Provenance sha256=d4f5a63e96fec4aeb1ba329b0ebb15c5e5e444ef94f3bfdc045c112914943ad8.
 * @Provenance Expected diagnostic: using + without opAdd overload should fail.
 * @Provenance Do not add opAdd or other declarations that would make this compile.
 * @Provenance DiagnosticOnly.
 */

struct FMyType
{
	int X = 0;
}

/** */
void Test()
{
	FMyType A;
	FMyType B;
	FMyType C = A + B;
}
