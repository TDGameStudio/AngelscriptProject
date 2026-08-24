// Theme: Feature.PropertyAccess. Positive raw-field access on the carrier actor.
// C++: AngelscriptPropertyAccessorRemovalTests.cpp::RawFieldAccessCompilesAndRuns
// Invokes CheckRawFieldAccess; oracle Result==1 (Field 17 then 23, bEnabled true).
// Extra: default Field==17; bEnabled false returns 20.
// DefaultSafe. Keep #if EDITOR. Source owns the script class.

#if EDITOR
UCLASS()
class AAutoAccessorRawFieldScriptActor : AAngelscriptPropertyAccessorCarrier
{
	UFUNCTION()
	int32 CheckRawFieldAccess()
	{
		if (Field != 17)
		{
			return 10;
		}
		if (!bEnabled)
		{
			return 20;
		}

		Field = 23;
		if (Field != 23)
		{
			return 30;
		}

		return 1;
	}
}

int Observe_RawFieldAccess_Nominal(AAutoAccessorRawFieldScriptActor Actor)
{
	if (Actor is null)
	{
		throw("Test_RawFieldAccessCompilesAndRuns setup: required Actor is null");
	}
	return Actor.CheckRawFieldAccess();
}

int Observe_RawFieldAccess_DefaultField(AAutoAccessorRawFieldScriptActor Actor)
{
	if (Actor is null)
	{
		throw("Test_RawFieldAccessCompilesAndRuns setup: required Actor is null");
	}
	return Actor.Field;
}

int Observe_RawFieldAccess_DisabledBoundary(AAutoAccessorRawFieldScriptActor Actor)
{
	if (Actor is null)
	{
		throw("Test_RawFieldAccessCompilesAndRuns setup: required Actor is null");
	}
	Actor.bEnabled = false;
	return Actor.CheckRawFieldAccess();
}
#endif
