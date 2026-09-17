/**
 * @version v1
 * @summary UUserWidget input-event BlueprintOverride reflection. C++ compiles and looks up the sentinel properties and UFunctions. Counts default to 0 until events fire. Copy independence covers a mutated MouseDownCount.
 * @topic Feature
 */
/**
 * @version root
 * @summary UUserWidget input-event BlueprintOverride reflection. C++ compiles and looks up the sentinel properties and UFunctions. Counts default to 0 until events fire. Copy independence covers a mutated MouseDownCount.
 * @topic Baseline
 */
UCLASS()
class UCoverageInputEventWidget : UUserWidget
{
	UPROPERTY()
	int MouseDownCount = 0;

	UPROPERTY()
	int MouseUpCount = 0;

	UPROPERTY()
	int MouseMoveCount = 0;

	UPROPERTY()
	int MouseEnterCount = 0;

	UPROPERTY()
	int MouseLeaveCount = 0;

	UPROPERTY()
	int KeyDownCount = 0;

	UPROPERTY()
	int KeyUpCount = 0;

	/**
	 * WorldStory: OnMouseButtonDown increments MouseDownCount and returns Handled.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs the widget geometry and pointer event
	 * @Return FEventReply::Handled(); MouseDownCount incremented
	 * @Param MyGeometry the widget geometry
	 * @Param MouseEvent the pointer event
	 */
	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonDown(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		MouseDownCount++;
		return FEventReply::Handled();
	}

	/**
	 * WorldStory: OnMouseButtonUp increments MouseUpCount and returns Handled.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs the widget geometry and pointer event
	 * @Return FEventReply::Handled(); MouseUpCount incremented
	 * @Param MyGeometry the widget geometry
	 * @Param MouseEvent the pointer event
	 */
	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonUp(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		MouseUpCount++;
		return FEventReply::Handled();
	}

	/**
	 * WorldStory: OnMouseMove increments MouseMoveCount and returns Unhandled.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs the widget geometry and pointer event
	 * @Return FEventReply::Unhandled(); MouseMoveCount incremented
	 * @Param MyGeometry the widget geometry
	 * @Param MouseEvent the pointer event
	 */
	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseMove(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		MouseMoveCount++;
		return FEventReply::Unhandled();
	}

	/**
	 * WorldStory: OnMouseEnter increments MouseEnterCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs the widget geometry and pointer event
	 * @Return MouseEnterCount incremented
	 * @Param MyGeometry the widget geometry
	 * @Param MouseEvent the pointer event
	 */
	UFUNCTION(BlueprintOverride)
	void OnMouseEnter(FGeometry MyGeometry, const FPointerEvent&in MouseEvent)
	{
		MouseEnterCount++;
	}

	/**
	 * WorldStory: OnMouseLeave increments MouseLeaveCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs the pointer event
	 * @Return MouseLeaveCount incremented
	 * @Param MouseEvent the pointer event
	 */
	UFUNCTION(BlueprintOverride)
	void OnMouseLeave(const FPointerEvent&in MouseEvent)
	{
		MouseLeaveCount++;
	}

	/**
	 * WorldStory: OnKeyDown increments KeyDownCount and returns Handled.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs the widget geometry and key event
	 * @Return FEventReply::Handled(); KeyDownCount incremented
	 * @Param MyGeometry the widget geometry
	 * @Param InKeyEvent the key event
	 */
	UFUNCTION(BlueprintOverride)
	FEventReply OnKeyDown(FGeometry MyGeometry, FKeyEvent InKeyEvent)
	{
		KeyDownCount++;
		return FEventReply::Handled();
	}

	/**
	 * WorldStory: OnKeyUp increments KeyUpCount and returns Unhandled.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs the widget geometry and key event
	 * @Return FEventReply::Unhandled(); KeyUpCount incremented
	 * @Param MyGeometry the widget geometry
	 * @Param InKeyEvent the key event
	 */
	UFUNCTION(BlueprintOverride)
	FEventReply OnKeyUp(FGeometry MyGeometry, FKeyEvent InKeyEvent)
	{
		KeyUpCount++;
		return FEventReply::Unhandled();
	}

	/**
	 * Observe that a locally constructed widget has all event counts at 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs a widget that has not received input
	 * @Return the sum of all event counts, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultCounts()
	{
		return MouseDownCount
			+ MouseUpCount
			+ MouseMoveCount
			+ MouseEnterCount
			+ MouseLeaveCount
			+ KeyDownCount
			+ KeyUpCount;
	}

	/**
	 * Observe that writing MouseDownCount on this widget leaves another widget untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.WidgetInputEventOverrideReflection
	 * @Inputs this widget plus a second widget
	 * @Return true when this is 9 and the other stays 0
	 * @Param Second the other widget, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UCoverageInputEventWidget Second)
	{
		if (Second == nullptr)
		{
			throw("WidgetInputEventOverrideReflection setup: required Second is null");
		}
		MouseDownCount = 9;
		if (Second.MouseDownCount != 0)
		{
			return false;
		}
		return MouseDownCount == 9;
	}
}
/** @end */
