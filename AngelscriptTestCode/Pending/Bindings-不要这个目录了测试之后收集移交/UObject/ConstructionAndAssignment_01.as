/**
 * @version v1
 * @summary Observe generic Cast<TargetType> of UObject handles and in-place string append of a UObject text representation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe generic Cast<TargetType> of UObject handles and in-place string append of a UObject text representation.
 * @topic Baseline
 */
// Runner owns the live UObject fixture.
// AS-facing API: TargetType CastObject = Cast<TargetType>(Object);
// Text += Object;
// Inputs: Runner-supplied UObject that is a UTexture2D, a null handle, and
// prefix text "obj:".
// Expected observations: Cast<UTexture2D> of the live object returns the same
// identity. Cast<UClass> of that object is null. Cast of nullptr is null.
// Text += Object grows the string; repeating += grows it again.
// Boundary/ownership: Cast does not copy the UObject. += copies the text
// representation into the existing FString. SetupOwner=Runner.

namespace TS_UObject_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_ConstructionAndAssignment_01 setup: required Object is null");
		}
		UTexture2D Texture = Cast<UTexture2D>(Object);
		UClass AsClass = Cast<UClass>(Object);
		UTexture2D FromNull = Cast<UTexture2D>(nullptr);
		UObject NullObject = nullptr;
		UTexture2D FromNullObject = Cast<UTexture2D>(NullObject);
		return Texture != nullptr && Texture == Object && AsClass is null && FromNull is null && FromNullObject is null;
	}

	bool Observe_AddAssign_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_ConstructionAndAssignment_01 setup: required Object is null");
		}
		FString Text = "obj:";
		int32 Before = Text.Len();
		Text += Object;
		int32 AfterFirst = Text.Len();
		Text += Object;
		int32 AfterRepeat = Text.Len();
		FString NullText = "null:";
		UObject NullObject = nullptr;
		NullText += NullObject;
		return AfterFirst > Before && AfterRepeat > AfterFirst && NullText.Len() > 5;
	}
}
/** @end */
