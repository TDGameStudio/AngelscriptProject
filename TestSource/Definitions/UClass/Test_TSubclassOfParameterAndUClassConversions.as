// Theme: Definitions.UClass. Positive TSubclassOf parameter / UClass conversions.
// C++: AngelscriptCoverageTypeConversionTests.cpp::TSubclassOfParameterAndUClassConversions
// CSV NegativeDiagnostic is wrong; C++ compiles then InvokeGlobal.
// Oracle: StaticClassToSubclassParameter=1, TSubclassOfToUClassParameter=1,
// NullSubclassParameter=0, DefaultObjectMatchesSubclass=1.
// Extra: empty TSubclassOf is the null vector (already NullSubclassParameter). DefaultSafe.

UCLASS()
class ACoverageSubclassParamBaseActor : AActor
{
}

UCLASS()
class ACoverageSubclassParamDerivedActor : ACoverageSubclassParamBaseActor
{
}

int AcceptSubclass(TSubclassOf<AActor> ActorClass)
{
	return ActorClass.IsValid() && ActorClass.IsChildOf(AActor::StaticClass()) ? 1 : 0;
}

int AcceptExactDerived(TSubclassOf<ACoverageSubclassParamBaseActor> ActorClass)
{
	UClass Class = ActorClass;
	return Class == ACoverageSubclassParamDerivedActor::StaticClass() ? 1 : 0;
}

int StaticClassToSubclassParameter()
{
	return AcceptSubclass(ACoverageSubclassParamDerivedActor::StaticClass());
}

int TSubclassOfToUClassParameter()
{
	TSubclassOf<ACoverageSubclassParamBaseActor> ActorClass = ACoverageSubclassParamDerivedActor::StaticClass();
	return AcceptExactDerived(ActorClass);
}

int NullSubclassParameter()
{
	TSubclassOf<AActor> ActorClass;
	return AcceptSubclass(ActorClass);
}

int DefaultObjectMatchesSubclass()
{
	TSubclassOf<AActor> ActorClass = ACoverageSubclassParamDerivedActor::StaticClass();
	AActor DefaultActor = ActorClass.GetDefaultObject();
	return DefaultActor != nullptr && DefaultActor.IsA(ACoverageSubclassParamDerivedActor::StaticClass()) ? 1 : 0;
}

int Observe_StaticClassToSubclass_Nominal()
{
	return StaticClassToSubclassParameter();
}

int Observe_TSubclassOfToUClass_Nominal()
{
	return TSubclassOfToUClassParameter();
}

int Observe_NullSubclass_EmptyDefault()
{
	return NullSubclassParameter();
}

int Observe_DefaultObjectMatches_Nominal()
{
	return DefaultObjectMatchesSubclass();
}

bool Observe_SubclassParamBase_EmptyDefaultIsNull()
{
	ACoverageSubclassParamBaseActor Actor;
	return Actor == nullptr;
}
