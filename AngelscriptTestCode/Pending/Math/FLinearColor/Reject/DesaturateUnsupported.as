/**
 * @version v1
 * @summary FLinearColor.Desaturate is not bound, so this program is rejected. C++ compiles it as LinearColorUnsupportedMethods and expects a diagnostic naming Desaturate.
 * @topic Math
 */
/**
 * @version root
 * @summary FLinearColor.Desaturate is not bound, so this program is rejected. C++ compiles it as LinearColorUnsupportedMethods and expects a diagnostic naming Desaturate.
 * @topic Negative
 */
/**
 * The isolated failing program: Desaturate has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers FLinearColor.DesaturateUnsupported
 * @Inputs none
 * @Return does not compile; Desaturate is not bound
 */
FLinearColor TryDesaturate()
{
	FLinearColor Color = FLinearColor::Red;
	return Color.Desaturate(0.5);
}
/** @end */
