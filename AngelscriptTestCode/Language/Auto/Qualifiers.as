/**
 * @version v1
 * @summary const auto locals inferred from a literal or a call.
 * @topic Language
 * @topic Auto
 *
 * const-auto-local        // const auto Value = 3 infers a const int local.
 * const-auto-from-call    // const auto Value = Make() infers a const local from the callee return.
 */
/**
 * @begin const-auto-local
 * @summary const auto Value = 3 infers a const int local.
 * @topic Auto
 */
int ConstLocal()
{
	const auto Value = 3;
	return Value;
}
/** @end */
/**
 * @begin const-auto-from-call
 * @summary const auto Value = Make() infers a const local from the callee return.
 * @topic Auto
 */
int Make()
{
	return 3;
}

int ConstFromCall()
{
	const auto Value = Make();
	return Value;
}
/** @end */
