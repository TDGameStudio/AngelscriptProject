// Theme: Language.Syntax.EdgeCases. Positive class-like signature echo.
// C++: AngelscriptCompilerEndToEndTests.cpp::ClassLikeReflectionShape
// sha256=a66cdc38f95ed2e6b7e7d5f9002484cf08e3b8feca1e199daa71a9adb6e5941f; lines 373-395.
// Oracle: EchoPlainClass / EchoActorClass / EchoSoftActorClass round-trip the
// given value. Extra: nullptr/empty pass-through; AActor class identity.
// DefaultSafe.

UCLASS()
class UCompilerClassLikeShapeCarrier : UObject
{
	UFUNCTION()
	UClass EchoPlainClass(UClass Value)
	{
		return Value;
	}

	UFUNCTION()
	TSubclassOf<AActor> EchoActorClass(TSubclassOf<AActor> Value)
	{
		return Value;
	}

	UFUNCTION()
	TSoftClassPtr<AActor> EchoSoftActorClass(TSoftClassPtr<AActor> Value)
	{
		return Value;
	}
}

bool Observe_ClassLike_PlainNullEmpty(UCompilerClassLikeShapeCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_ClassLikeReflectionShape setup: required Carrier is null");
	}
	return Carrier.EchoPlainClass(nullptr) == nullptr;
}

bool Observe_ClassLike_ActorIdentity(UCompilerClassLikeShapeCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_ClassLikeReflectionShape setup: required Carrier is null");
	}
	TSubclassOf<AActor> ActorClass = AActor::StaticClass();
	TSubclassOf<AActor> Echoed = Carrier.EchoActorClass(ActorClass);
	return Echoed == ActorClass;
}

bool Observe_ClassLike_SoftEmptyDefault(UCompilerClassLikeShapeCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_ClassLikeReflectionShape setup: required Carrier is null");
	}
	TSoftClassPtr<AActor> Empty;
	TSoftClassPtr<AActor> Echoed = Carrier.EchoSoftActorClass(Empty);
	return Echoed.IsNull();
}
