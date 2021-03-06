class KF2Welder extends KFMeleeGun;

	// dependson(KFVoicePack);

#exec OBJ LOAD FILE=KF2Tools_A.ukx

var() 			float 				AmmoRegenRate, AmmoRegenCount;

var(Screen) 	ScriptedTexture  	ScriptedScreen;
var(Screen)		Shader 				ShadedScreen;
var(Screen) 	Material   			ScriptedScreenBack;
var(Screen)		string				ScriptedScreenRef, ShadedScreenRef, ScriptedScreenBackRef;

//Font/Color/stuff
var(Screen) 	Font 				NameFont, SmallNameFont;
var(Screen)		string				NameFontRef, SmallNameFontRef;
var(Screen) 	Color 				NameColor;
var(Screen) 	Color 				BackColor;

var(Screen) 	float 				ScreenWeldPercent;
var(Screen) 	bool 				bNoTarget;
var(Screen) 	int 				FireModeArray;
var(Screen)		Float				ScreenSizePct;

var(ScreenTex)	Material			ScreenScan, ScreenEmpty, ScreenLine, ScreenGradient, ScreenSolid;
var(ScreenTex)	String				ScreenScanRef, ScreenEmptyRef, ScreenLineRef, ScreenGradientRef, ScreenSolidRef;

var(ScreenTex)	Color				ScreenBlue, ScreenGreen, ScreenRed, ScreenWhite, ScreenBlack;
var(ScreenTex)	Vector				ScreenTop, ScreenBottom;
var(ScreenTex)	Font				ScreenFont;
var(ScreenTex)	String				ScreenFontRef;

// Speech
var(Speech)		bool				bJustStarted;
var(Speech)		float				LastWeldingMessageTime;
var(Speech)		float				WeldingMessageDelay;

// Anims
var(Anims)		name				WeldOnAnim, WeldOffAnim, WeldIdleAnim, WeldSelectAnim, WeldPutDownAnim;
var(Anims)		float				DoorCheckTime, DoorCheckGoal;
var(Anims)		Actor				LastChecked;
var(Anims)		float				WeldTweenTime;
var(Anims)		bool				bToWeld, bTweening;
var(Anims)		name				FireStartAnim, FireLoopAnim, FireEndAnim;
var(Anims)		Sound				ZapLoopSound;
var(Anims)		string				ZapLoopSoundRef;

var(Sound) 		float   			AmbientFireSoundRadius;		// The sound radius for the ambient fire sound
var(Sound)		byte				AmbientFireVolume;          // The ambient fire sound

//-----------------------------------------------------------------------------------------------//

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	default.ScriptedScreen = ScriptedTexture(DynamicLoadObject(default.ScriptedScreenRef, class'ScriptedTexture'));
	default.ShadedScreen = Shader(DynamicLoadObject(default.ShadedScreenRef, class'Shader'));
	default.ScriptedScreenBack = Material(DynamicLoadObject(default.ScriptedScreenBackRef, class'Material'));
	default.NameFont = Font(DynamicLoadObject(default.NameFontRef, class'Font'));
	default.SmallNameFont = Font(DynamicLoadObject(default.SmallNameFontRef, class'Font'));
	default.ScreenFont = Font(DynamicLoadObject(default.SmallNameFontRef, class'Font'));
	default.ScreenScan = Material(DynamicLoadObject(default.ScreenScanRef, class'Material'));
	default.ScreenEmpty = Material(DynamicLoadObject(default.ScreenEmptyRef, class'Material'));
	default.ScreenLine = Material(DynamicLoadObject(default.ScreenLineRef, class'Material'));
	default.ScreenGradient = Material(DynamicLoadObject(default.ScreenGradientRef, class'Material'));
	default.ScreenSolid = Material(DynamicLoadObject(default.ScreenSolidRef, class'Material'));
	default.ZapLoopSound = Sound(DynamicLoadObject(default.ZapLoopSoundRef, class'Sound'));
	
	if (KF2Welder(Inv) != None)
	{
		KF2Welder(Inv).ScriptedScreen = default.ScriptedScreen;
		KF2Welder(Inv).ShadedScreen = default.ShadedScreen;
		KF2Welder(Inv).ScriptedScreenBack = default.ScriptedScreenBack;
		KF2Welder(Inv).NameFont = default.NameFont;
		KF2Welder(Inv).SmallNameFont = default.SmallNameFont;
		KF2Welder(Inv).ScreenFont = default.ScreenFont;
		KF2Welder(Inv).ScreenScan = default.ScreenScan;
		KF2Welder(Inv).ScreenEmpty = default.ScreenEmpty;
		KF2Welder(Inv).ScreenLine = default.ScreenLine;
		KF2Welder(Inv).ScreenGradient = default.ScreenGradient;
		KF2Welder(Inv).ScreenSolid = default.ScreenSolid;
		KF2Welder(Inv).ZapLoopSound = default.ZapLoopSound;
	}
	
	super.PreloadAssets(Inv, bSkipRefCount);
}

static function bool UnloadAssets()
{
	default.ScriptedScreen = None;
	default.ShadedScreen = None;
	default.ScriptedScreenBack = None;
	default.NameFont = None;
	default.SmallNameFont = None;
	default.ScreenFont = None;
	default.ScreenScan = None;
	default.ScreenEmpty = None;
	default.ScreenLine = None;
	default.ScreenGradient = None;
	default.ScreenSolid = None;
	default.ZapLoopSound = None;
	
	return super.UnloadAssets();
}

//-----------------------------------------------------------------------------------------------//

function byte BestMode()
{
	return 1;
}

simulated function bool DoingFire()
{
	return false;
}

simulated function bool InWeldState()
{
	return false;
}

simulated function float RateSelf()
{
	return -100;
}

//----------------------------------------------
// Clean up materails when we're destroyed or level changes
//----------------------------------------------
simulated function Destroyed()
{
	local WeaponAttachment WA;
	
	WA = WeaponAttachment(ThirdPersonActor);
	if (WA != None)
		WA.AmbientSound = None;
	
	Super.Destroyed();
	CleanUpMats();
}

simulated function PreTravelCleanUp()
{
	CleanUpMats();
}

//----------------------------------------------
// Clean up materials
//----------------------------------------------
	
simulated function CleanUpMats()
{
	if( ScriptedScreen!=None )
	{
		ScriptedScreen.SetSize(256,256);
		ScriptedScreen.FallBackMaterial = None;
		ScriptedScreen.Client = None;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = None;
	}

	if( ShadedScreen!=None )
	{
		ShadedScreen.Diffuse = None;
		ShadedScreen.Opacity = None;
		ShadedScreen.SelfIllumination = None;
		ShadedScreen.SelfIlluminationMask = None;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = None;
		skins[3] = None;
	}
}

//----------------------------------------------
// Initialize screen materials
//----------------------------------------------
simulated function InitMaterials()
{
	if( ScriptedScreen==None )
	{
		ScriptedScreen = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
        ScriptedScreen.SetSize(256, 512);
		ScriptedScreen.FallBackMaterial = ScriptedScreenBack;
		ScriptedScreen.Client = Self;
	}

	if( ShadedScreen==None )
	{
		ShadedScreen = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
		ShadedScreen.Diffuse = ScreenSolid;
		ShadedScreen.SelfIllumination = ScriptedScreen;
		skins[1] = ShadedScreen;
	}
}


//----------------------------------------------
// Update our screen
//----------------------------------------------
simulated function Tick(float dt)
{
    local KFDoorMover LastDoorHitActor;
	local WeaponAttachment WA;
	local bool bInFiring;
	
	// Check for doors
	if (Level.NetMode != NM_DedicatedServer && Instigator != None && Instigator.Weapon == Self && ClientState == WS_ReadyToFire && Level.TimeSeconds >= DoorCheckGoal && !bTweening)
	{
		DoorCheckGoal = Level.TimeSeconds + DoorCheckTime;
		LastChecked = Class'KF2WelderFire'.Static.GetWeldTarget(Instigator);
		
		if (LastChecked != None)
		{
			if (!InWeldState())
			{
				bToWeld = true;
				WeldTweenTime = GetAnimDuration(WeldOnAnim);
				PlayAnim(WeldOnAnim, 1.0, 0.1);
				GotoState('WeldTween');
			}
		}
		else if (InWeldState())
		{
			bToWeld = false;
			WeldTweenTime = GetAnimDuration(WeldOffAnim);
			PlayAnim(WeldOffAnim, 1.0, 0.1);
			GotoState('WeldTween');
		}
	}
	
	// -- FIRING ANIM! HANDLED VIA WELDER -- //
	if ((FireMode[0].bIsFiring && KF2WelderFire(FireMode[0]).LastHitActor != None) || (FireMode[1].bIsFiring && KF2WelderFire(FireMode[1]).LastHitActor != None))
	{
		bInFiring = true;
		// Fire anims are handled in our weld ready state
		if (Level.NetMode != NM_DedicatedServer && !DoingFire())
		{
			PlayAnim(FireStartAnim, 1.0, 0.1);
			GotoState('WeldFiring');
		}
	}
	else if (DoingFire() && Level.NetMode != NM_DedicatedServer)
	{
		PlayAnim(FireEndAnim, 1.0, 0.1);
		bTweening = false;
		GotoState('WeldReady');
	}
	
	// SERVER
	if (Role == ROLE_Authority)
	{
		WA = WeaponAttachment(ThirdPersonActor);
		
		if (WA != None)
		{
			if (bInFiring && Instigator != None && Instigator.Weapon == Self)
			{
				WA.AmbientSound = ZapLoopSound;
				WA.SoundVolume = AmbientFireVolume;
				WA.SoundRadius = AmbientFireSoundRadius;
			}
			else
			{
				WA.AmbientSound = None;
				WA.SoundVolume = WA.default.SoundVolume;
				WA.SoundRadius = WA.default.SoundRadius;
			}
		}
	}
	
	// Which fire mode are we checking?
	if (FireMode[0].bIsFiring)
		FireModeArray = 0;
	else if (FireMode[1].bIsFiring)
		FireModeArray = 1;
	else
		bJustStarted = true;

	// Hit actor
	if (KF2WelderFire(FireMode[FireModeArray]).LastHitActor != none && VSize(KF2WelderFire(FireMode[FireModeArray]).LastHitActor.Location - Owner.Location) <= (weaponRange * 1.5) )
	{
		bNoTarget = false;
		LastDoorHitActor = KFDoorMover(KF2WelderFire(FireMode[FireModeArray]).LastHitActor);

        if(LastDoorHitActor != none)
            ScreenWeldPercent = (LastDoorHitActor.WeldStrength / LastDoorHitActor.MaxWeld) * 100;
		
		// This is speech for welding
		if ( Level.Game != none && Level.Game.NumPlayers > 1 && bJustStarted && Level.TimeSeconds - LastWeldingMessageTime > WeldingMessageDelay )
		{
			if ( FireMode[0].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				    PlayerController(Instigator.Controller).Speech('AUTO', 0, "");
			}
			else if ( FireMode[1].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				    PlayerController(Instigator.Controller).Speech('AUTO', 1, "");
			}
		}
	}
	
	// No hit actor
	else if (KF2WelderFire(FireMode[FireModeArray]).LastHitActor == none || KF2WelderFire(FireMode[FireModeArray]).LastHitActor != none && VSize(KF2WelderFire(FireMode[FireModeArray]).LastHitActor.Location - Owner.Location) > (weaponRange * 1.5) && !bNoTarget  )
		bNoTarget = true;
	
	// Consume weld ammo
	if ( AmmoAmount(0) < FireMode[0].AmmoClass.Default.MaxAmmo)
	{
		AmmoRegenCount += (dT * AmmoRegenRate );
		ConsumeAmmo(0, -1*(int(AmmoRegenCount)));
		AmmoRegenCount -= int(AmmoRegenCount);
	}
	
	// ALWAYS UPDATE SCREEN
	if( ScriptedScreen==None )
		InitMaterials();

	ScriptedScreen.Revision++;

	if( ScriptedScreen.Revision > 10 )
		ScriptedScreen.Revision = 1;
}

simulated function float ChargeBar()
{
	return FMin(1, (AmmoAmount(0))/(FireMode[0].AmmoClass.Default.MaxAmmo));
}

//----------------------------------------------
// Render the scripted texture
//----------------------------------------------
simulated event RenderTexture(ScriptedTexture Tex)
{
	local int SizeX, SizeY, BarHeight;
	local float CB;
	local string S;
	
	CB = ChargeBar();
	BarHeight = int(512 * CB * ScreenSizePct);

	// BG
	Tex.DrawTile(0,0,Tex.USize,Tex.VSize,0,0,ScreenSolid.MaterialUSize(),ScreenSolid.MaterialVSize(),ScreenSolid,ScreenBlue);
	
	// THE BAR
	Tex.DrawTile(0,Tex.VSize - BarHeight,Tex.USize,BarHeight,0,0,ScreenSolid.MaterialUSize(),ScreenSolid.MaterialVSize(),ScreenSolid,ScreenGreen);
	
	// Lines
	Tex.DrawTile(0,0,Tex.USize,Tex.VSize,0,0,ScreenLine.MaterialUSize(),ScreenLine.MaterialVSize(),ScreenLine,ScreenWhite);
	
	// NO AMMO LEFT
	if (CB <= 0.01)
		Tex.DrawTile(0,0,Tex.USize,Tex.VSize,0,0,ScreenEmpty.MaterialUSize(),ScreenEmpty.MaterialVSize(),ScreenEmpty,ScreenWhite);
	else
	{
		S = string(int(ChargeBar() * 100)) $ "%";
		Tex.TextSize(S, ScreenFont, SizeX, SizeY);
		Tex.DrawText( (ScreenBottom.X * ScreenSizePct) - (SizeX*0.5), (ScreenBottom.Y * ScreenSizePct) - (SizeY*0.5), S, ScreenFont, ScreenBlack );
	}
	
	// DOOR HEALTH!
	if (!bNoTarget && ScreenWeldPercent > 0)
		S = int(ScreenWeldPercent) $ "%";
	else
		S = "-";

	Tex.TextSize(S, ScreenFont, SizeX, SizeY);
	Tex.DrawText( (ScreenTop.X * ScreenSizePct) - (SizeX*0.5), (ScreenTop.Y * ScreenSizePct) - (SizeY*0.5), S, ScreenFont, ScreenBlack );
	
	// Gradient
	Tex.DrawTile(0,0,Tex.USize,Tex.VSize,0,0,ScreenGradient.MaterialUSize(),ScreenGradient.MaterialVSize(),ScreenGradient,ScreenWhite);
	
	// SCANLINE!
	Tex.DrawTile(0,0,Tex.USize,Tex.VSize,0,0,ScreenScan.MaterialUSize(),ScreenScan.MaterialVSize(),ScreenScan,ScreenWhite);

	/*
	if(!bNoTarget && ScreenWeldPercent > 0 )
	{
		NameColor.R=(255 - (ScreenWeldPercent * 2));
		NameColor.G=(0 + (ScreenWeldPercent * 2.55));
		NameColor.B=(20 + ScreenWeldPercent);
		NameColor.A=255;
		Tex.TextSize(ScreenWeldPercent@"%",NameFont,SizeX,SizeY); // get the size of the players name
		Tex.DrawText( (Tex.USize - SizeX) * 0.5, 85,ScreenWeldPercent@"%", NameFont, NameColor);
		Tex.TextSize("Integrity:",NameFont,SizeX,SizeY);
		Tex.DrawText( (Tex.USize - SizeX) * 0.5, 50,"Integrity:", NameFont, NameColor);
	}
	else
	{
		NameColor.R=255;
		NameColor.G=255;
		NameColor.B=255;
		NameColor.A=255;
		Tex.TextSize("-",NameFont,SizeX,SizeY); // get the size of the players name
		Tex.DrawText( (Tex.USize - SizeX) * 0.5, 85,"-", NameFont, NameColor);
		Tex.TextSize("Integrity:",NameFont,SizeX,SizeY);
		Tex.DrawText( (Tex.USize - SizeX) * 0.5, 50,"Integrity:", NameFont, NameColor);
	}
	*/
}

//----------------------------------------------
// Haven't seen a door yet
//----------------------------------------------
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	bNoTarget =  true;
	
	if( Level.NetMode==NM_DedicatedServer )
		Return;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	bTweening = false;
	
	LastChecked = Class'KF2WelderFire'.Static.GetWeldTarget(Instigator);
	
	if (InWeldState() || LastChecked != None)
	{
		SelectAnim = WeldSelectAnim;
		GotoState('WeldReady');
	}
	else
		SelectAnim = default.SelectAnim;
	
	super.BringUp(PrevWeapon);
}

simulated function bool PutDown()
{
	local WeaponAttachment WA;
	
	WA = WeaponAttachment(ThirdPersonActor);
	
	if (WA != None)
		WA.AmbientSound = None;
	
	if (InWeldState())
		PutDownAnim = WeldPutDownAnim;
	else
		PutDownAnim = default.PutDownAnim;
	return super.PutDown();
}

//----------------------------------------------
// READY TO WELD
// TODO: Add select / putdown anims
//----------------------------------------------
state WeldReady
{
	// Yes, we're in the weld state
	simulated function bool InWeldState()
	{
		return true;
	}
	
	simulated function PlayIdle()
	{
		LoopAnim(WeldIdleAnim, 1.0, 0.1);
	}
}

//----------------------------------------------
// PLAYING A FIRE ANIMATION
//----------------------------------------------
state WeldFiring
{
	ignores PlayIdle;
	
	// Yes, we're in the weld state
	simulated function bool InWeldState()
	{
		return true;
	}
	
	simulated function bool DoingFire()
	{
		return true;
	}
}

//----------------------------------------------
// MOVING IN-BETWEEN WELD STATES
//----------------------------------------------
state WeldTween
{
	ignores PlayIdle;
	
	Begin:
		bTweening = true;
		Sleep(WeldTweenTime);
		bTweening = false;
		if (bToWeld)
			GotoState('WeldReady');
		else
			GotoState('');
}

simulated function AnimEnd(int Channel)
{
	local name anim;
	local float frame, rate;

	if (Channel > 0)
		return;

	GetAnimParams(0, anim, frame, rate);

	if (anim == WeldOnAnim || anim == WeldOffAnim || Anim == FireEndAnim)
	{
		PlayIdle();
		return;
	}
	
	if (anim == FireStartAnim && DoingFire())
	{
		LoopAnim(FireLoopAnim, 1.0, 0.1);
		return;
	}
	
	super.AnimEnd(Channel);
}

defaultproperties
{
     AmmoRegenRate=40.000000
     ScriptedScreenBackRef="KillingFloorWeapons.Welder.WelderWindowFinal"
     NameFontRef="ROFonts.ROBtsrmVr24"
     SmallNameFontRef="ROFonts.ROBtsrmVr12"
     BackColor=(B=128,G=128,R=128,A=255)
     ScreenSizePct=0.500000
     ScreenScanRef="KF2Tools_A.WelderScreen.kf2ws_scan_pan"
     ScreenEmptyRef="KF2Tools_A.WelderScreen.kf2ws_empty"
     ScreenLineRef="KF2Tools_A.WelderScreen.kf2ws_line"
     ScreenGradientRef="KF2Tools_A.WelderScreen.kf2ws_gradient"
     ScreenSolidRef="KF2Tools_A.WelderScreen.kf2ws_solid"
     ScreenBlue=(B=222,G=191,R=151,A=255)
     ScreenGreen=(B=130,G=181,R=134,A=255)
     ScreenRed=(B=64,G=72,R=157,A=255)
     ScreenWhite=(B=255,G=255,R=255,A=255)
     ScreenBlack=(A=255)
     ScreenTop=(X=256.000000,Y=240.000000)
     ScreenBottom=(X=256.000000,Y=690.000000)
     ScreenFontRef="KF2Tools_A.WelderScreenFont"
     WeldingMessageDelay=10.000000
     WeldOnAnim="Weld_On"
     WeldOffAnim="Weld_Off"
     WeldIdleAnim="Idle_Weld"
     WeldSelectAnim="Quick_In"
     WeldPutDownAnim="Quick_Out"
     DoorCheckTime=0.150000
     FireStartAnim="ShootLoop_Start"
     FireLoopAnim="ShootLoop"
     FireEndAnim="ShootLoop_End"
     ZapLoopSoundRef="KF2Tools_A.WEP_SA_Welder_Fire_Loop_M"
     AmbientFireSoundRadius=500.000000
     AmbientFireVolume=255
     weaponRange=120.000000
     Weight=0.000000
     bKFNeverThrow=True
     bAmmoHUDAsBar=True
     bConsumesPhysicalAmmo=False
     StandardDisplayFOV=70.000000
     SleeveNum=2
     MeshRef="KF2Tools_A.kf2_welder"
     SkinRefs(0)="KF2Tools_A.kf2welder_shdr"
    //  SkinRefs(1)="KF2Tools_A.Welder.FlameShader"
     SelectSoundRef="KF2Tools_A.WEP_SUP_Welder_Equip"
     HudImageRef="KF2Tools_A.Welder_T.welder_unselect"
     SelectedHudImageRef="KF2Tools_A.Welder_T.welder_select"
     FireModeClass(0)=Class'KF2WelderFire'
     FireModeClass(1)=Class'KF2WelderAltFire'
     SelectAnim="Equip"
     PutDownAnim="Putaway"
     SelectAnimRate=1.000000
     PutDownAnimRate=1.000000
     PutDownTime=0.500000
     BringUpTime=0.700000
     AIRating=-2.000000
     bMeleeWeapon=False
     bShowChargingBar=True
     DisplayFOV=70.000000
     Priority=5
     InventoryGroup=5
     GroupOffset=1
     PickupClass=Class'KF2WelderPickup'
     PlayerViewOffset=(X=40.000000,Y=27.000000,Z=-20.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KF2WelderAttachment'
     IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
     ItemName="Welder"
     AmbientGlow=2
}
