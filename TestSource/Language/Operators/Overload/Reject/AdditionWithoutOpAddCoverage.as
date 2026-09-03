/**
 * Using + on a type that declares no opAdd is rejected. This is the coverage
 * suite's counterpart of ../Reject/AdditionWithoutOpAdd, which comes from the
 * syntax suite; both are kept because their C++ sources differ.
 * This file is the illegal program itself; do not add opAdd or anything else
 * that would make it compile, since the missing operator is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AdditionWithoutOpAddCoverage
 * @Harness CompileReject
 * @Tag Language.Operators.AdditionWithoutOpAddCoverage
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A + B where the struct declares no operator overloads
 * @Return does not compile; diagnostic "using + without opAdd should fail"
 * @Provenance C++: AngelscriptCoverageOperatorOverloadTests.cpp::OperatorNegativeCompile
 * @Provenance sha256=687b496a47b199c21696ea7f4c4ce315a6067f8dfe97d70d7eb86b5b95319708; lines 228-240.
 * @Provenance Expected compile failure: "using + without opAdd should fail".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FNoPlus
{
	int Value = 0;
}

void Test()
{
	FNoPlus A;
	FNoPlus B;
	FNoPlus C = A + B;
}
