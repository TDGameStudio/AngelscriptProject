/**
 * OverrideComponent of a name that does not exist is rejected. The override
 * target must be a parent default component; this file is the illegal program.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Override_Mixed_NegativeOverrideNonExistent
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Override_Mixed_NegativeOverrideNonExistent
 * @Kind CompileReject
 * @Covers DefaultComponent.Override_Mixed_NegativeOverrideNonExistent
 * @Inputs UPROPERTY(OverrideComponent = NonExistent) UStaticMeshComponent Mesh
 * @Return does not compile; Override non-existent component should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Override_Mixed_NegativeOverrideNonExistent
 * @Provenance AssertFailsToCompile module DefCompOverrideBad.
 * @Provenance Expected diagnostic: Override non-existent component should fail.
 * @Provenance DiagnosticOnly. Isolation=none. Do not declare NonExistent on the parent.
 */

class ADefCompBaseBadActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

class ADefCompChildBadActor : ADefCompBaseBadActor
{
	UPROPERTY(OverrideComponent = NonExistent)
	UStaticMeshComponent Mesh;
}
