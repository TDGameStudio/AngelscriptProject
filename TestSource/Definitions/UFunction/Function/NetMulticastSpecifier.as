/**
 * NetMulticast on an actor method. MulticastEffect is a valid NetMulticast
 * UFUNCTION, a default handle is null, and assigning one handle to another
 * aliases the same object.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.NetMulticastSpecifier
 * @Harness Function
 * @Tag Definitions.UFunction.NetMulticastSpecifier
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: NetMulticast specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 7 AssertCompiles.
 * @Provenance sha256=02c324644f2569f3ea55df4634afe9a553fb9d3bc172acf6bc192711a8cae6aa; lines 119-125.
 * @Provenance Oracle: AUFuncNetMCActor.MulticastEffect() is a valid NetMulticast UFUNCTION.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AUFuncNetMCActor : AActor
{
	/**
	 * NetMulticast UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(NetMulticast)
	void MulticastEffect()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that MulticastEffect can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose MulticastEffect is invoked, runner-owned when non-null
	 * @Inputs Actor.MulticastEffect()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int MulticastEffectCallCompletes(AUFuncNetMCActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.MulticastEffect();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncNetMCActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncNetMCActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases the same object.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two default handles; First = Second
	 * @Return true when First is Second
	 */
	UFUNCTION()
	bool AssignAliasesHandle()
	{
		AUFuncNetMCActor First;
		AUFuncNetMCActor Second;
		First = Second;
		return First is Second;
	}
}
