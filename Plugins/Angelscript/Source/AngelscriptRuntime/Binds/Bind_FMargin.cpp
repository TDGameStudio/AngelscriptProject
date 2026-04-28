#include "AngelscriptBinds.h"
#include "Layout/Margin.h"

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FMargin(FAngelscriptBinds::EOrder::Normal, []
{
	auto FMargin_= FAngelscriptBinds::ExistingClass("FMargin");

	FMargin_.Constructor("void f(float32 UniformMargin)",
	[](FMargin* Address, float UniformMargin)
	{
		new(Address) FMargin(UniformMargin);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FMargin_, "FMargin");

	FMargin_.Constructor("void f(float32 Horizontal, float32 Vertical)",
	[](FMargin* Address, float Horizontal, float Vertical)
	{
		new(Address) FMargin(Horizontal, Vertical);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FMargin_, "FMargin");

	FMargin_.Constructor("void f(const FVector2D& InVector)",
	[](FMargin* Address, const FVector2D& InVector)
	{
		new(Address) FMargin(InVector);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FMargin_, "FMargin");

	FMargin_.Constructor("void f(float32 InLeft, float32 InTop, float32 InRight, float32 InBottom)",
	[](FMargin* Address, float InLeft, float InTop, float InRight, float InBottom)
	{
		new(Address) FMargin(InLeft, InTop, InRight, InBottom);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FMargin_, "FMargin");

	FMargin_.Constructor("void f(const FVector4& InVector)",
	[](FMargin* Address, const FVector4& InVector)
	{
		new(Address) FMargin(InVector);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FMargin_, "FMargin");

	FMargin_.Method("FMargin opMul(float32 Scale) const", METHODPR_TRIVIAL(FMargin, FMargin, operator*, (float) const));
	FMargin_.Method("FMargin opMul(const FMargin& InScale) const", METHODPR_TRIVIAL(FMargin, FMargin, operator*, (const FMargin&) const));
	FMargin_.Method("FMargin opAdd(const FMargin& Other) const", METHODPR_TRIVIAL(FMargin, FMargin, operator+, (const FMargin&) const));
	FMargin_.Method("FMargin opSub(const FMargin& Other) const", METHODPR_TRIVIAL(FMargin, FMargin, operator-, (const FMargin&) const));
	FMargin_.Method("bool opEquals(const FMargin& Other) const", METHODPR_TRIVIAL(bool, FMargin, operator==, (const FMargin&) const));

	FMargin_.Method("FVector2D GetTopLeft() const", [](const FMargin& Margin) -> FVector2D
	{
		return FVector2D(Margin.GetTopLeft2f());
	});
	FMargin_.Method("FVector2D GetDesiredSize() const", [](const FMargin& Margin) -> FVector2D
	{
		return FVector2D(Margin.GetDesiredSize2f());
	});
	FMargin_.Method("float32 GetTotalSpaceAlongHorizontal() const", [](const FMargin& Margin) -> float
	{
		return Margin.GetTotalSpaceAlong<Orient_Horizontal>();
	});
	FMargin_.Method("float32 GetTotalSpaceAlongVertical() const", [](const FMargin& Margin) -> float
	{
		return Margin.GetTotalSpaceAlong<Orient_Vertical>();
	});
});
