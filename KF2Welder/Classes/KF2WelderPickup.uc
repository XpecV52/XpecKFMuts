class KF2WelderPickup extends WelderPickup;

// #exec obj load file="..\StaticMeshes\NewPatchSM.usx"

defaultproperties
{
     Weight=0.000000
     ItemName="Welder"
     CorrespondingPerkIndex=1
     InventoryType=Class'KF2Welder'
     PickupMessage="You picked up KF2Welder!"
     PickupSound=Sound'Inf_Weapons_Foley.Misc.AmmoPickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF2Tools_A.WelderKF2LLI_st'
     CollisionHeight=5.000000
}
