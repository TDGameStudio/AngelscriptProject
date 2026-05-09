#include "Components/SkeletalMeshComponent.h"

#include "AngelscriptBinds.h"

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_USkeletalMeshComponent(FAngelscriptBinds::EOrder::Late, []
{
	FAngelscriptBinds USkeletalMeshComponent_ = FAngelscriptBinds::ExistingClass("USkeletalMeshComponent");
	USkeletalMeshComponent_.Method("const TArray<UAnimInstance>& GetLinkedAnimInstances() const", METHODPR_TRIVIAL(const TArray<UAnimInstance*>&, USkeletalMeshComponent, GetLinkedAnimInstances, () const));
	USkeletalMeshComponent_.Method("void SetSkeletalMeshAsset(USkeletalMesh NewMesh)", METHOD_TRIVIAL(USkeletalMeshComponent, SetSkeletalMeshAsset));
	USkeletalMeshComponent_.Method("USkeletalMesh GetSkeletalMeshAsset() const", METHOD_TRIVIAL(USkeletalMeshComponent, GetSkeletalMeshAsset));
});
