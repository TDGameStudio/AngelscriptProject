// Framework contract: SpawnObject creates a tracked UObject outered to the
// suite without creating a World. Terminal cleanup releases the object.
// GetTestWorld remains null for a pure leaf.
// Payload: one transient UObject with an integer mutation is enough.
// Expected observations: object is non-null, GetOuter() is this, Value
// mutates to 1, GetTestWorld is null throughout.
// C++ oracle required: automatic release after the leaf, no World context
// created, and ownership lifetime.

UCLASS()
class UTestSourcePlainObject : UObject
{
	int Value = 0;

	void Increment()
	{
		Value += 1;
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourcePureObjectFixtureSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyPureObjectFixture()
	{
		AssertNull(FAngelscriptTest::GetTestWorld(), "TS-FW-WORLD-001 World existed before spawn");
		UTestSourcePlainObject Object =
			Cast<UTestSourcePlainObject>(
				FAngelscriptTest::SpawnObject(
					UTestSourcePlainObject::StaticClass()));
		AssertNotNull(Object, "TS-FW-WORLD-001 SpawnObject returned null");
		AssertSame(this, Object.GetOuter(), "TS-FW-WORLD-001 outer is not the suite");
		Object.Increment();
		AssertEquals(1, Object.Value, "TS-FW-WORLD-001 mutation payload");
		AssertNull(FAngelscriptTest::GetTestWorld(), "TS-FW-WORLD-001 SpawnObject created a World");
	}
}
