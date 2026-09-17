/**
 * @version v1
 * @summary UENUM(Bitflags) is not a supported specifier, so this program is rejected. This file is the illegal program itself; do not rewrite Bitflags as meta, since the unknown specifier is the point.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UENUM(Bitflags) is not a supported specifier, so this program is rejected. This file is the illegal program itself; do not rewrite Bitflags as meta, since the unknown specifier is the point.
 * @topic Negative
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
/** @end */
