// Theme: Definitions.UEnum. Isolated compile-fail: UENUM(Bitflags) is not a supported specifier.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumBitflagsSpecifierRejected
// Expected diagnostic: "Unknown enum specifier Bitflags"
// Isolate the failing program. DiagnosticOnly.

UENUM(Bitflags)
enum EUnsupportedBitflagsSpecifier
{
	FlagA = 1,
	FlagB = 2
}
