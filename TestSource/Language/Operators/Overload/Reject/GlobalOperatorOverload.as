/**
 * An operator overload declared at global scope is rejected: operators are
 * declared as members of the type they operate on. This file is the illegal
 * program itself; do not move the declaration into a type, since the global
 * scope is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.GlobalOperatorOverload
 * @Harness CompileReject
 * @Tag Language.Operators.GlobalOperatorOverload
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs int opAdd(int A, int B) at module scope
 * @Return does not compile; diagnostic "operator overload at global scope should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOGlobal lines 271-273;
 * @Provenance sha256=e0fac472b0f80e7aeaac47f6b1335e47b0f289cd5d459c7fa41e366c08053e94.
 * @Provenance Expected diagnostic: operator overload at global scope should fail.
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

int opAdd(int A, int B)
{
	return A + B;
}
