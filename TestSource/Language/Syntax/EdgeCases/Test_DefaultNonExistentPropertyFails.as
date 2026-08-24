// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: default unknown property.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultNonExistentPropertyFails
// sha256=e12e6b70bd9da3359f3f2fb857cd6d1278bafbbfb60cf74de68e6d5d831865d5; lines 485-491.
// Expected diagnostic: non-existent property default should fail to compile.
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class UDefaultNonExistentCarrier : UObject
{
	default NoSuchProperty = 1;
}
