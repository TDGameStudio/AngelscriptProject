/**
 * @version v1
 * @summary Observe FSoftObjectPath equality for identical, empty, and distinct object identities. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FSoftObjectPath equality for identical, empty, and distinct object identities. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// the zero operand, and a path built from UObject::StaticClass() as a
// distinct identity.
// Expected observations: Same CDO paths compare true. Empty == empty is
// true. Live CDO path vs empty is false. CDO vs a different UObject path
// is false.
// Boundary/ownership: Equality is exact path identity and does not load or
// mutate either operand.

namespace TS_SoftObjectPath_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Operators_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath Left(LiveCdo);
		FSoftObjectPath RightSame(LiveCdo);
		FSoftObjectPath Empty;
		FSoftObjectPath EmptyOther;
		UObject ObjectCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
		if (ObjectCdo is null)
		{
			throw("TS_SoftObjectPath_Operators_01 setup: required UObject CDO is null");
		}
		FSoftObjectPath RightDifferent(ObjectCdo);
		return Left == RightSame && Empty == EmptyOther && !(Left == Empty) && !(Left == RightDifferent);
	}
}
/** @end */
