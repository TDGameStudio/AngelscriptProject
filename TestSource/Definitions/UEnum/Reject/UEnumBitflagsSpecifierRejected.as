/**
 * UENUM(Bitflags) is not a supported specifier, so this program is rejected.
 * This file is the illegal program itself; do not rewrite Bitflags as meta,
 * since the unknown specifier is the point.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumBitflagsSpecifierRejected
 * @Harness CompileReject
 * @Tag Definitions.UEnum.UEnumBitflagsSpecifierRejected
 * @Kind CompileReject
 * @Covers UEnum.UEnumBitflagsSpecifierRejected
 * @Inputs UENUM(Bitflags)
 * @Return does not compile; diagnostic "Unknown enum specifier Bitflags"
 * @Provenance Theme: Definitions.UEnum. Isolated compile-fail: UENUM(Bitflags) is not a supported specifier.
 * @Provenance C++: AngelscriptCoverageUEnumTests.cpp::UEnumBitflagsSpecifierRejected
 * @Provenance Expected diagnostic: "Unknown enum specifier Bitflags"
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * Attempt to declare an enum with the unsupported Bitflags specifier.
 *
 * @Covers UEnum.UEnumBitflagsSpecifierRejected
 * @Inputs none
 * @Return does not compile
 */
UENUM(Bitflags)
enum EUnsupportedBitflagsSpecifier
{
	FlagA = 1,
	FlagB = 2
}
