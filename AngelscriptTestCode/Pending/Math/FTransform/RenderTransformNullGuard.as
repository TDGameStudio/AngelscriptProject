/**
 * @version v1
 * @summary Reading a UWidget render transform: a success code when Translation, Scale and Angle match, mismatch codes 10/20/30, and a null-widget runtime exception that observers never call. C++ compiles the module and drives the.
 * @topic Math
 */
/**
 * @version root
 * @summary Reading a UWidget render transform: a success code when Translation, Scale and Angle match, mismatch codes 10/20/30, and a null-widget runtime exception that observers never call. C++ compiles the module and drives the.
 * @topic Baseline
 */
namespace FTransformTest
{
	/**
	 * Read a widget render transform and return a code for the matching fields.
	 *
	 * @Kind Observe
	 * @Covers FTransform.RenderTransformNullGuard
	 * @Inputs a widget
	 * @Return 1 on match, 10 on translation mismatch, 20 on scale mismatch, 30 on angle mismatch
	 * @Param Widget the widget whose render transform is read
	 */
	UFUNCTION()
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

	/**
	 * Trigger the null-widget path. Observers never call this; C++ expects the exception.
	 *
	 * @Kind Action
	 * @Covers FTransform.RenderTransformNullGuard
	 * @Inputs a null widget
	 * @Return raises Null pointer access
	 * @Boundary null widget
	 */
	UFUNCTION()
	void ReadWidgetTransformNull()
	{
		UWidget Widget;
		ReadWidgetTransform(Widget);
	}

	/**
	 * The success code C++ compares against when every field matches.
	 *
	 * @Kind Observe
	 * @Covers FTransform.RenderTransformNullGuard
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int ReadWidgetTransformSuccessCode()
	{
		return 1;
	}

	/**
	 * The mismatch code C++ compares against when translation differs.
	 *
	 * @Kind Observe
	 * @Covers FTransform.RenderTransformNullGuard
	 * @Inputs none
	 * @Return 10
	 */
	UFUNCTION()
	int ReadWidgetTransformTranslationMismatchCode()
	{
		return 10;
	}

	/**
	 * The mismatch code C++ compares against when scale differs.
	 *
	 * @Kind Observe
	 * @Covers FTransform.RenderTransformNullGuard
	 * @Inputs none
	 * @Return 20
	 */
	UFUNCTION()
	int ReadWidgetTransformScaleMismatchCode()
	{
		return 20;
	}

	/**
	 * The mismatch code C++ compares against when angle differs.
	 *
	 * @Kind Observe
	 * @Covers FTransform.RenderTransformNullGuard
	 * @Inputs none
	 * @Return 30
	 */
	UFUNCTION()
	int ReadWidgetTransformAngleMismatchCode()
	{
		return 30;
	}
}
/** @end */
