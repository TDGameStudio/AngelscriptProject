#pragma once

ANGELSCRIPTRUNTIME_API void AngelscriptReloadGameplayTags();

// Re-registers every cached GameplayTag as a `GameplayTags::<sanitized>` global variable
// on the *currently scoped* asIScriptEngine, regardless of whether the process-level
// AngelscriptGameplayTagsLookup already contains the tag. Use from automation tests that
// acquire a clone/fresh test engine on which startup binds have not registered the
// GameplayTag namespace globals, since Bind_ProcessGameplayTag short-circuits on the
// process-level lookup and would otherwise leave the second engine without the globals.
ANGELSCRIPTRUNTIME_API void AngelscriptRebindGameplayTagsToCurrentEngine();

// Re-registers every cached GameplayTag as a `GameplayTags::<sanitized>` global variable
// on the *currently scoped* asIScriptEngine, regardless of whether the process-level
// AngelscriptGameplayTagsLookup already contains the tag. Use from automation tests that
// acquire a clone/fresh test engine on which startup binds have not registered the
// GameplayTag namespace globals, since Bind_ProcessGameplayTag short-circuits on the
// process-level lookup and would otherwise leave the second engine without the globals.
ANGELSCRIPTRUNTIME_API void AngelscriptRebindGameplayTagsToCurrentEngine();
