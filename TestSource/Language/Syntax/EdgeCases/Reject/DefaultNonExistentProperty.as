/**
 * A `default` statement naming a property that does not exist is rejected. This
 * file is the illegal program itself; do not declare the missing property, since
 * the unknown name is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DefaultNonExistentProperty
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.DefaultNonExistentProperty
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a default statement naming an undeclared property
 * @Return does not compile; diagnostic "non-existent property default"
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultNonExistentPropertyFails
 * @Provenance sha256=e12e6b70bd9da3359f3f2fb857cd6d1278bafbbfb60cf74de68e6d5d831865d5; lines 485-491.
 * @Provenance Expected diagnostic: non-existent property default should fail to compile.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class UDefaultNonExistentCarrier : UObject
{
	default NoSuchProperty = 1;
}
