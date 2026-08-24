// Framework contract: assertion, exception, timeout, and cancellation
// terminals each release owned World, actors, components, objects, and
// pending commands exactly once. The next fresh leaf must see no World.
// Payload: shared CreateOwnedResources plus four isolated failing leaves
// with unique messages. Cancellation uses a long WaitDelay so the oracle
// can cancel it.
// Expected observations: each leaf fails with its unique marker; after
// each terminal path GetTestWorld is null for a later leaf.
// C++ oracle required: resource release once per path, no World leak, and
// cancellation vs timeout distinction.

UCLASS()
class UTestSourceWorldFailureObject : UObject
{
}

UCLASS()
class ATestSourceWorldFailureActor : AActor
{
}

UCLASS()
class UTestSourceWorldFailureComponent : UActorComponent
{
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceWorldFailureCleanupSuite : UAngelscriptTestSuite
{
	void CreateOwnedResources()
	{
		FAngelscriptTest::CreateTestWorld(true);
		FAngelscriptTest::SpawnObject(
			UTestSourceWorldFailureObject::StaticClass());
		ATestSourceWorldFailureActor Actor =
			Cast<ATestSourceWorldFailureActor>(
				FAngelscriptTest::SpawnActor(
					ATestSourceWorldFailureActor::StaticClass()));
		FAngelscriptTest::SpawnComponent(
			UTestSourceWorldFailureComponent::StaticClass(),
			Actor,
			true);
	}

	bool NeverReady()
	{
		return false;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyWorldFailureCleanup()
	{
		CreateOwnedResources();
		Fail("TS-FW-WORLD-005 assertion cleanup");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailWorldCleanupByException()
	{
		CreateOwnedResources();
		throw("TS-FW-WORLD-005 exception cleanup");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailWorldCleanupByTimeout()
	{
		CreateOwnedResources();
		FAngelscriptTest::Commands()
			.Until(n"NeverReady", 0.01, "TS-FW-WORLD-005 timeout cleanup");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FailWorldCleanupByCancellation()
	{
		CreateOwnedResources();
		FAngelscriptTest::Commands()
			.WaitDelay(5.0, "TS-FW-WORLD-005 cancellation hold");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyNextLeafHasNoWorld()
	{
		AssertNull(
			FAngelscriptTest::GetTestWorld(),
			"TS-FW-WORLD-005 World leaked into later leaf");
	}
}
