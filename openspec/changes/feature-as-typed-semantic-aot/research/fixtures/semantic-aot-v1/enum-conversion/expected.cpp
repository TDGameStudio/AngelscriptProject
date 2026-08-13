#include "CoreMinimal.h"

enum class ESemanticMode : int32;

static bool AS_Test_Semantic_SemanticEnumEnabled(
	const ESemanticMode as_sem_s0)
{
	return (static_cast<int32>(as_sem_s0) != int32(0));
}
