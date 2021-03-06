class KF2WelderFire extends KFMeleeFire;

var 			Actor 		LastHitActor;
var localized 	string 		NoWeldTargetMessage;
var localized 	string 		CantWeldTargetMessage;
var 			float 		FailTime;

var				array<string>			Weldables;

var				float					ArmorDamp;

var int maxAdditionalDamage;

// Weapon handles this
function PlayFiring();

static function bool CanWeldThis(Actor A)
{
	local int l;
	
	if (A == None)
		return false;
	
	for (l=0; l<default.Weldables.Length; l++)
	{
		if (string(A.Class) ~= default.Weldables[l])
			return true;
	}
	
	return false;
}

// ACTUALLY DO DAMAGE TO THE ENEMY!
simulated Function Timer()
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal,AdjustedLocation;
	local rotator PointRot;
	local int MyDamage;

	If( !KFWeapon(Weapon).bNoHit )
	{
		MyDamage = MeleeDamage + Rand(MaxAdditionalDamage);

		// Weld speed modifier
		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
			MyDamage = float(MyDamage) * KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetWeldSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));

		PointRot = Instigator.GetViewRotation();
		StartTrace = Instigator.Location + Instigator.EyePosition();
		EndTrace = StartTrace + vector(PointRot)*weaponRange;
		Weapon.bBlockHitPointTraces = false;
		HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
		Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;

		LastHitActor = HitActor;

		// We have a hit actor! - Serversided?
		if( LastHitActor!=none && Level.NetMode!=NM_Client )
		{
			AdjustedLocation = Hitlocation;
			AdjustedLocation.Z = (Hitlocation.Z - 0.15 * Instigator.collisionheight);
			Spawn(class'KF2WelderHitEffect',,, AdjustedLocation, rotator(HitLocation - StartTrace));
			
			// Actually do something to the object!
			if (KFDoorMover(HitActor) != None)
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation , vector(PointRot),hitDamageClass);
			
			if (KFBulletWhipAttachment(HitActor) != None)
				HitActor = HitActor.Owner;
			
			// Must be something else
			if (KFHumanPawn(HitActor) != None)
				KFHumanPawn(HitActor).ShieldStrength = Min(KFHumanPawn(HitActor).ShieldStrength + (MyDamage * ArmorDamp), 100);
			else if (Pawn(HitActor) != None)
				Pawn(HitActor).Health = Clamp(Pawn(HitActor).Health + MyDamage, 0, Pawn(HitActor).HealthMax);
		}
	}
}

//----------------------------------------------------------
// FIND SOMETHING TO WELD
// This is a trace, do this sparingly
//----------------------------------------------------------
static function Actor GetWeldTarget(Pawn CheckFrom)
{
	local Actor A;
	local vector Dummy, End, Start;

	Start = CheckFrom.Location + CheckFrom.EyePosition();
	End = Start+vector(CheckFrom.GetViewRotation())*default.weaponRange;
    CheckFrom.bBlockHitPointTraces = false;
	A = CheckFrom.Trace(Dummy,Dummy,End,Start,True);
    CheckFrom.bBlockHitPointTraces = CheckFrom.default.bBlockHitPointTraces;
	
	// Doors, sentries, panzers, and humans
	if (KFDoorMover(A) != None || KFBulletWhipAttachment(A) != None || KFHumanPawn(A) != None || Class'KF2WelderFire'.Static.CanWeldThis(A))
		return A;
	
	return none;
}

//----------------------------------------------------------
// CAN WE WELD?
//----------------------------------------------------------
function bool AllowFire()
{
	local Actor WeldTarget;

	WeldTarget = GetWeldTarget(Instigator);

	// Can't use welder, if no door.
	if ( WeldTarget == none )
	{
		LastHitActor = None;
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).CheckForHint(54);

			if ( FailTime + 0.5 < Level.TimeSeconds )
			{
				PlayerController(Instigator.Controller).ClientMessage(NoWeldTargetMessage, 'CriticalEvent');
				FailTime = Level.TimeSeconds;
			}

		}

		return false;
	}

	// Door can't be welded
	if(KFDoorMover(WeldTarget) != None && KFDoorMover(WeldTarget).bDisallowWeld)
	{
		if( PlayerController(Instigator.controller)!=None )
			PlayerController(Instigator.controller).ClientMessage(CantWeldTargetMessage, 'CriticalEvent');

		return false;
	}

    return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire ;
}

defaultproperties
{
     NoWeldTargetMessage="You must go near a weldable door to weld it."
     CantWeldTargetMessage="You can't weld this door."
    //  Weldables(0)="FunhouseExtras.PanzerPet"
    //  Weldables(1)="FunhouseExtras.PanzerPetGold"
    //  Weldables(2)="FunhouseExtras.SentryDeath"
    //  Weldables(3)="FunhouseExtras.SentryDemo"
    //  Weldables(4)="FunhouseExtras.SentryPlasma"
    //  Weldables(5)="FunhouseExtras.SentryPyro"
    //  Weldables(6)="FunhouseExtras.SentrySupport"
    //  Weldables(7)="FunhouseExtras.SentryZerker"
     ArmorDamp=0.450000
     MeleeDamage=4
     DamagedelayMin=0.100000
     DamagedelayMax=0.100000
     hitDamageClass=Class'KFMod.DamTypeWelder'
     MeleeHitSoundRefs(0)="KF2Tools_A.welder_weld_a"
     TransientSoundVolume=1.800000
     FireRate=0.200000
     AmmoClass=Class'KF2WelderAmmo'
     AmmoPerFire=20
}
