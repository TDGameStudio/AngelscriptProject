/**
 * Global functions declared with the 'mixin' keyword can only be called as methods.
 * The first parameter will be the type of object the method can be used on.
 *
 * The module must still be imported for the mixin method to be usable.
 *
 * This behaves similar to the ScriptMixin meta tag for C++ function libraries.
 */
mixin void ExampleMixinActorMethod(AActor Self, FVector Location)
{
	Print("Mixin invoked on: " + Self.GetClass().GetName());
}

void Example_MixinMethod()
{
	AActor ActorReference;
	ActorReference.ExampleMixinActorMethod(FVector(0.0, 0.0, 100.0));
}
