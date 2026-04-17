#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Components/BoxComponent.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPrimitiveComponentBoundsCompatBindingsTest,
	"Angelscript.TestModule.Bindings.PrimitiveComponentBoundsCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptPrimitiveComponentBindingsTests_Private
{
	static constexpr ANSICHAR PrimitiveComponentBindingsModuleName[] = "ASPrimitiveComponentBoundsCompat";
	static constexpr TCHAR PrimitiveComponentHostActorName[] = TEXT("PrimitiveComponentBindingsHostActor");
	static constexpr TCHAR PrimitiveComponentName[] = TEXT("PrimitiveComponentBindingsBox");
	static const FVector ExpectedBoxExtent(10.0f, 20.0f, 30.0f);
	static const FVector ExpectedRelativeLocation(100.0f, 50.0f, 25.0f);
	static constexpr double BoundsTolerance = 0.01;

	struct FPrimitiveComponentBindingBaseline
	{
		FString ComponentPath;
		FVector BoundingBoxExtents = FVector::ZeroVector;
		FVector BoundsOrigin = FVector::ZeroVector;
		FVector BoundsExtent = FVector::ZeroVector;
		double BoundsRadius = 0.0;
		bool bSelectable = false;
		ELightmapType InitialLightmapType = ELightmapType::Default;
	};

	void ReplaceToken(FString& Source, const TCHAR* Token, const FString& Replacement)
	{
		Source.ReplaceInline(Token, *Replacement, ESearchCase::CaseSensitive);
	}

	FString FormatDoubleLiteral(const double Value)
	{
		return LexToString(Value);
	}

	FString FormatVectorLiteral(const FVector& Value)
	{
		return FString::Printf(
			TEXT("FVector(%s, %s, %s)"),
			*LexToString(Value.X),
			*LexToString(Value.Y),
			*LexToString(Value.Z));
	}

	UBoxComponent* CreatePrimitiveComponentFixture(FAutomationTestBase& Test, AActor*& OutHostActor)
	{
		OutHostActor = NewObject<AActor>(
			GetTransientPackage(),
			AActor::StaticClass(),
			PrimitiveComponentHostActorName,
			RF_Transient);
		if (!Test.TestNotNull(TEXT("PrimitiveComponentBoundsCompat should create the transient host actor"), OutHostActor))
		{
			return nullptr;
		}

		UBoxComponent* BoxComponent = NewObject<UBoxComponent>(
			OutHostActor,
			UBoxComponent::StaticClass(),
			PrimitiveComponentName,
			RF_Transient);
		if (!Test.TestNotNull(TEXT("PrimitiveComponentBoundsCompat should create the transient box component"), BoxComponent))
		{
			return nullptr;
		}

		OutHostActor->AddInstanceComponent(BoxComponent);
		OutHostActor->SetRootComponent(BoxComponent);

		BoxComponent->SetBoxExtent(ExpectedBoxExtent);
		BoxComponent->SetRelativeLocation(ExpectedRelativeLocation);
		BoxComponent->bSelectable = false;
		BoxComponent->SetLightmapType(ELightmapType::Default);
		BoxComponent->UpdateComponentToWorld();
		BoxComponent->UpdateBounds();
		return BoxComponent;
	}

	FPrimitiveComponentBindingBaseline CapturePrimitiveComponentBaseline(const UBoxComponent& BoxComponent)
	{
		FPrimitiveComponentBindingBaseline Baseline;
		Baseline.ComponentPath = BoxComponent.GetPathName();
		Baseline.BoundingBoxExtents = BoxComponent.GetCollisionShape().GetExtent();
		Baseline.BoundsOrigin = BoxComponent.Bounds.Origin;
		Baseline.BoundsExtent = BoxComponent.Bounds.BoxExtent;
		Baseline.BoundsRadius = BoxComponent.Bounds.SphereRadius;
		Baseline.bSelectable = BoxComponent.bSelectable;
		Baseline.InitialLightmapType = BoxComponent.GetLightmapType();
		return Baseline;
	}

	bool VerifyNativeBaseline(
		FAutomationTestBase& Test,
		const FPrimitiveComponentBindingBaseline& Baseline)
	{
		bool bPassed = true;
		bPassed &= Test.TestTrue(
			TEXT("PrimitiveComponentBoundsCompat native collision extents should match the configured box extent"),
			Baseline.BoundingBoxExtents.Equals(ExpectedBoxExtent, 0.0f));
		bPassed &= Test.TestTrue(
			TEXT("PrimitiveComponentBoundsCompat native bounds origin should reflect the configured relative location"),
			Baseline.BoundsOrigin.Equals(ExpectedRelativeLocation, BoundsTolerance));
		bPassed &= Test.TestTrue(
			TEXT("PrimitiveComponentBoundsCompat native bounds extent should match the configured box extent"),
			Baseline.BoundsExtent.Equals(ExpectedBoxExtent, BoundsTolerance));
		bPassed &= Test.TestTrue(
			TEXT("PrimitiveComponentBoundsCompat native bounds radius should match the box extent radius"),
			FMath::IsNearlyEqual(Baseline.BoundsRadius, ExpectedBoxExtent.Size(), BoundsTolerance));
		bPassed &= Test.TestFalse(
			TEXT("PrimitiveComponentBoundsCompat native selectable flag should start disabled"),
			Baseline.bSelectable);
		bPassed &= Test.TestEqual(
			TEXT("PrimitiveComponentBoundsCompat native lightmap type should start at the default"),
			Baseline.InitialLightmapType,
			ELightmapType::Default);
		return bPassed;
	}

	FString BuildPrimitiveComponentScript(const FPrimitiveComponentBindingBaseline& Baseline)
	{
		FString Script = TEXT(R"AS(
int Entry()
{
	UObject FoundObject = FindObject("__COMPONENT_PATH__");
	UPrimitiveComponent Component = Cast<UPrimitiveComponent>(FoundObject);
	if (Component == null)
		return 1;

	int Failures = 0;
	if (!Component.GetBoundingBoxExtents().Equals(__EXPECTED_BOX_EXTENT__, 0.0f))
		Failures |= 2;
	if (!Component.GetBoundsOrigin().Equals(__EXPECTED_BOUNDS_ORIGIN__, __BOUNDS_TOLERANCE__))
		Failures |= 4;
	if (!Component.GetBoundsExtent().Equals(__EXPECTED_BOUNDS_EXTENT__, __BOUNDS_TOLERANCE__))
		Failures |= 8;
	if (!Math::IsNearlyEqual(Component.GetBoundsRadius(), __EXPECTED_BOUNDS_RADIUS__, __BOUNDS_TOLERANCE__))
		Failures |= 16;
	if (Component.GetbSelectable())
		Failures |= 32;

	Component.SetbSelectable(true);
	if (!Component.GetbSelectable())
		Failures |= 64;

	Component.SetLightmapType(ELightmapType::ForceSurface);
	return Failures;
}
)AS");

		ReplaceToken(Script, TEXT("__COMPONENT_PATH__"), Baseline.ComponentPath.ReplaceCharWithEscapedChar());
		ReplaceToken(Script, TEXT("__EXPECTED_BOX_EXTENT__"), FormatVectorLiteral(Baseline.BoundingBoxExtents));
		ReplaceToken(Script, TEXT("__EXPECTED_BOUNDS_ORIGIN__"), FormatVectorLiteral(Baseline.BoundsOrigin));
		ReplaceToken(Script, TEXT("__EXPECTED_BOUNDS_EXTENT__"), FormatVectorLiteral(Baseline.BoundsExtent));
		ReplaceToken(Script, TEXT("__EXPECTED_BOUNDS_RADIUS__"), FormatDoubleLiteral(Baseline.BoundsRadius));
		ReplaceToken(Script, TEXT("__BOUNDS_TOLERANCE__"), FormatDoubleLiteral(BoundsTolerance));
		return Script;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptPrimitiveComponentBindingsTests_Private;

bool FAngelscriptPrimitiveComponentBoundsCompatBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	AActor* HostActor = nullptr;
	UBoxComponent* BoxComponent = nullptr;
	bool bModuleCompiled = false;

	ON_SCOPE_EXIT
	{
		if (bModuleCompiled)
		{
			Engine.DiscardModule(TEXT("ASPrimitiveComponentBoundsCompat"));
		}

		if (BoxComponent != nullptr)
		{
			BoxComponent->MarkAsGarbage();
		}

		if (HostActor != nullptr)
		{
			HostActor->MarkAsGarbage();
		}
	};

	BoxComponent = CreatePrimitiveComponentFixture(*this, HostActor);
	if (BoxComponent == nullptr)
	{
		return false;
	}

	const FPrimitiveComponentBindingBaseline Baseline = CapturePrimitiveComponentBaseline(*BoxComponent);
	if (!VerifyNativeBaseline(*this, Baseline))
	{
		return false;
	}

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		PrimitiveComponentBindingsModuleName,
		BuildPrimitiveComponentScript(Baseline));
	if (Module == nullptr)
	{
		return false;
	}
	bModuleCompiled = true;

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = INDEX_NONE;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	bPassed = TestEqual(
		TEXT("PrimitiveComponent bounds/selectable/lightmap bindings should preserve the scripted parity matrix"),
		Result,
		0);
	bPassed &= TestTrue(
		TEXT("PrimitiveComponent SetbSelectable(true) should update the native component immediately"),
		BoxComponent->bSelectable);
	bPassed &= TestEqual(
		TEXT("PrimitiveComponent SetLightmapType(ForceSurface) should update the native lightmap type"),
		BoxComponent->GetLightmapType(),
		ELightmapType::ForceSurface);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
