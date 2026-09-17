/**
 * @version v1
 * @summary FLinearColor instantiations that must not compile.
 * @topic Unreal
 * @topic FLinearColor
 *
 * desaturate-unsupported
 */
/**
 * @begin desaturate-unsupported
 * @summary FLinearColor.Desaturate is not bound, so this program is rejected.
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
