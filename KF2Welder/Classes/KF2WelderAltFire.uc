//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KF2WelderAltFire extends UnWeldFire;

function bool AllowFire()
{
	local Actor WeldTarget;

	// WeldTarget = GetWeldTarget(Instigator);
	WeldTarget = GetDoor();
	
	if (WeldTarget == None || KFDoorMover(WeldTarget) == None)
		LastHitActor = None;

	// Can't use welder, if no door.
	if(WeldTarget == none)
		return false;
		
	// Unweld only works on doors
	if (KFDoorMover(WeldTarget) == None)
		return false;

	// Cannot unweld a door that's already unwelded
	if(KFDoorMover(WeldTarget) != None && KFDoorMover(WeldTarget).WeldStrength <= 0)
	{
		LastHitActor = None;
		return false;
	}

	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire ;
}

defaultproperties
{
     MeleeDamage=15
     hitDamageClass=Class'KFMod.DamTypeUnWeld'
     MeleeHitSoundRefs(0)="KF2Tools_A.Welder.welder_weld_a"
     AmmoPerFire=15
}
