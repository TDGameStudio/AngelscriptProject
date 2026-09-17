/**
 * @version v1
 * @summary Observe FEnhancedActionKeyMapping equality, including identity, copy, and mismatched key/action operands.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FEnhancedActionKeyMapping equality, including identity, copy, and mismatched key/action operands.
 * @topic Baseline
 */
// a third mapping with EKeys::S, a mapping with a second action, and a
// default-constructed mapping as the empty operand.
// Expected observations: Same action/key mappings compare equal. Different
// keys or actions compare unequal. Two default mappings compare equal.
// Boundary/ownership: Equality compares mapping identity fields. It does not
// take ownership of the action. Null NewObject results are setup failure.

namespace TS_UInputMappingContext_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.EqualityAction", true));
		UInputAction OtherAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.EqualityOtherAction", true));
		if (Action is null || OtherAction is null)
		{
			throw("TS_UInputMappingContext_Operators_01 setup: required Action is null");
		}
		FEnhancedActionKeyMapping Left(Action, EKeys::W);
		FEnhancedActionKeyMapping Right(Action, EKeys::W);
		FEnhancedActionKeyMapping DifferentKey(Action, EKeys::S);
		FEnhancedActionKeyMapping DifferentAction(OtherAction, EKeys::W);
		FEnhancedActionKeyMapping EmptyLeft;
		FEnhancedActionKeyMapping EmptyRight;
		return Left == Right &&
			!(Left == DifferentKey) &&
			!(Left == DifferentAction) &&
			!(Left == EmptyLeft) &&
			EmptyLeft == EmptyRight;
	}
}
/** @end */
