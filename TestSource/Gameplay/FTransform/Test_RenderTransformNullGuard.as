// Theme: Gameplay.FTransform. Value oracle plus null-widget runtime exception.
// C++: AngelscriptWidgetFunctionLibraryTests.cpp::RenderTransformNullGuard
// CSV NegativeDiagnostic; C++ compiles. ReadWidgetTransform(valid UButton) == 1
// after Translation (13.5,-9.25), Scale (1.25,0.75), Angle 42. Mismatch codes
// 10/20/30. ReadWidgetTransformNull raises Null pointer access.
// Extra: empty/null widget is the exception path. Do not wrap the null call
// in Observe. DefaultSafe.

int ReadWidgetTransform(UWidget Widget)
{
	const FWidgetTransform Transform = Widget.GetRenderTransform();
	if (Transform.Translation.X != 13.5f || Transform.Translation.Y != -9.25f)
	{
		return 10;
	}
	if (Transform.Scale.X != 1.25f || Transform.Scale.Y != 0.75f)
	{
		return 20;
	}
	if (Transform.Angle != 42.0f)
	{
		return 30;
	}
	return 1;
}

void ReadWidgetTransformNull()
{
	UWidget Widget;
	ReadWidgetTransform(Widget);
}

int Observe_ReadWidgetTransform_SuccessCode()
{
	return 1;
}

int Observe_ReadWidgetTransform_TranslationMismatchCode()
{
	return 10;
}

int Observe_ReadWidgetTransform_ScaleMismatchCode()
{
	return 20;
}

int Observe_ReadWidgetTransform_AngleMismatchCode()
{
	return 30;
}
