// Theme: Feature.Inheritance. Positive UUserWidget input-event BlueprintOverride reflection.
// C++: AngelscriptCoverageWidgetTests.cpp::WidgetInputEventOverrideReflection
// Compile + sentinel properties and UFunctions. Oracle counts default 0.
// Extra: empty handle null; all counts stay 0 until events fire. DefaultSafe.
// Keep MouseDownCount/MouseUpCount/MouseMoveCount/MouseEnterCount/MouseLeaveCount/KeyDownCount/KeyUpCount.

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

	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonDown(FGeometry MyGeometry, const FPointerEvent& MouseEvent)
	{
		MouseDownCount++;
		return FEventReply::Handled();
	}

	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonUp(FGeometry MyGeometry, const FPointerEvent& MouseEvent)
	{
		MouseUpCount++;
		return FEventReply::Handled();
	}

	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseMove(FGeometry MyGeometry, const FPointerEvent& MouseEvent)
	{
		MouseMoveCount++;
		return FEventReply::Unhandled();
	}

	UFUNCTION(BlueprintOverride)
	void OnMouseEnter(FGeometry MyGeometry, const FPointerEvent& MouseEvent)
	{
		MouseEnterCount++;
	}

	UFUNCTION(BlueprintOverride)
	void OnMouseLeave(const FPointerEvent& MouseEvent)
	{
		MouseLeaveCount++;
	}

	UFUNCTION(BlueprintOverride)
	FEventReply OnKeyDown(FGeometry MyGeometry, FKeyEvent InKeyEvent)
	{
		KeyDownCount++;
		return FEventReply::Handled();
	}

	UFUNCTION(BlueprintOverride)
	FEventReply OnKeyUp(FGeometry MyGeometry, FKeyEvent InKeyEvent)
	{
		KeyUpCount++;
		return FEventReply::Unhandled();
	}
}

bool Observe_WidgetInput_EmptyHandleIsNull()
{
	UCoverageInputEventWidget Widget;
	return Widget == nullptr;
}

int Observe_WidgetInput_DefaultCounts(UCoverageInputEventWidget Widget)
{
	if (Widget == nullptr)
	{
		throw("TS-FEAT-0158 setup: required UCoverageInputEventWidget is null");
	}
	return Widget.MouseDownCount
		+ Widget.MouseUpCount
		+ Widget.MouseMoveCount
		+ Widget.MouseEnterCount
		+ Widget.MouseLeaveCount
		+ Widget.KeyDownCount
		+ Widget.KeyUpCount;
}

bool Observe_WidgetInput_CopyIndependence(
	UCoverageInputEventWidget First,
	UCoverageInputEventWidget Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0158 setup: required widgets are null");
	}
	First.MouseDownCount = 9;
	return Second.MouseDownCount == 0 && First.MouseDownCount == 9;
}
