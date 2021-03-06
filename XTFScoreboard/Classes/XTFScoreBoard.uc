class XTFScoreBoard extends KFScoreBoardNew;
#exec TEXTURE IMPORT COMPRESS NAME="Box" FILE="Textures\Box.dds" FORMAT=DXT5
// #exec TEXTURE IMPORT FILE="Textures\Box.dds"
// #exec OBJ LOAD FILE=XTSB.utx

var localized string FPText,SCText,HuskText,PlayerTimeText;
var localized string NotShownInfo,PlayerCountText,SpectatorCountText,AliveCountText,BotText,KillAssistsSeparator;
var Color GrayColor;
var Color Blue;
var Color DarkGrayColor;//Ast
var Color YellowColor;//Time
var Color GoldColor;//Dosh
var Color ChocolateColor;//HU
var Color OrangeColor;//SC
var Color CrimsonColor;//FP
var Color OrangeRedColor;//Title
var Color PurpleColor;//Kill

function string GetDateString()
{
    local string DateString;

    DateString = "Current Date:";
    switch(Level.DayOfWeek)
    {
        case 0:
            DateString @= "Sunday";
            break;
        case 1:
            DateString @= "Monday";
            break;
        case 2:
            DateString @= "Tuesday";
            break;
        case 3:
            DateString @= "Wednesday";
            break;
        case 4:
            DateString @= "Thursday";
            break;
        case 5:
            DateString @= "Friday";
            break;
        case 6:
            DateString @= "Saturday";
            break;
        default:
            break;
    }//sat | 09M-10D-2020Y | 15:
    //Year
    DateString @= ("|" $ string(Level.Year));
    //Mon
    if(Level.Month < 10)
    {
        DateString $= (("/" $ "0") $ string(Level.Month));
    }
    else
    {
        DateString $= ("/" $ string(Level.Month));
    }
    //Day
    if(Level.Day < 10)
    {
        DateString $= (("/" $ "0") $ string(Level.Day));
    }
    else
    {
        DateString $= ("/" $ string(Level.Day));
    }
    //Time
    if(Level.Hour < 10)
    {
        DateString @= (("|" @ "0") $ string(Level.Hour));
    }
    else
    {
        DateString @= ("|" @ string(Level.Hour));
    }
    if(Level.Minute < 10)
    {
        DateString $= ((":" $ "0") $ string(Level.Minute));
    }
    else
    {
        DateString $= (":" $ string(Level.Minute));
    }
    if(Level.Second < 10)
    {
        DateString $= ((":" $ "0") $ string(Level.Second));
    }
    else
    {
        DateString $= (":" $ string(Level.Second));
    }
    return DateString;
}

function DrawTitle(Canvas Canvas, float HeaderOffsetY, float PlayerAreaY, float PlayerBoxSizeY)
{
    local string CurrentGameString, CurrentDateString, scoreinfostring, RestartString;
    local float CurrentGameXL, CurrentGameYL, CurrentDateXL, CurrentDateYL, ScoreInfoXL, ScoreInfoYL,
	    TitleYPos, DrawYPos;

    CurrentDateString = GetDateString();
    CurrentGameString = ((((("Current Game:" @ SkillLevel[Clamp(InvasionGameReplicationInfo(GRI).BaseDifficulty, 0, 7)]) @ "|") @ WaveString) @ string(InvasionGameReplicationInfo(GRI).WaveNumber + 1)) @ "|") @ Level.Title;
    Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);
    if(GRI.TimeLimit != 0)
    {
        scoreinfostring = TimeLimit $ (FormatTime(GRI.RemainingTime));
    }
    else
    {
        scoreinfostring = FooterText @ (FormatTime(GRI.ElapsedTime));
    }
    if(UnrealPlayer(Owner).bDisplayLoser)
    {
        scoreinfostring = class'HudBase'.default.YouveLostTheMatch;
    }
    else
    {
        if(UnrealPlayer(Owner).bDisplayWinner)
        {
            scoreinfostring = class'HudBase'.default.YouveWonTheMatch;
        }
        else
        {
            if(PlayerController(Owner).IsDead())
            {
                RestartString = Restart;
                if(PlayerController(Owner).PlayerReplicationInfo.bOutOfLives)
                {
                    RestartString = OutFireText;
                }
                scoreinfostring = RestartString;
            }
        }
    }
    TitleYPos = Canvas.ClipY * 0.130;
    DrawYPos = TitleYPos;
    // Canvas.DrawColor = HudClass.default.WhiteColor;
    // Canvas.DrawColor = default.OrangeRedColor;
    Canvas.DrawColor = default.Blue;
    Canvas.StrLen(CurrentGameString, CurrentGameXL, CurrentGameYL);
    Canvas.SetPos(0.50 * (Canvas.ClipX - CurrentGameXL), DrawYPos);
    Canvas.DrawText(CurrentGameString);
    DrawYPos += CurrentGameYL;
    Canvas.StrLen(CurrentDateString, CurrentDateXL, CurrentDateYL);
    Canvas.SetPos(0.50 * (Canvas.ClipX - CurrentDateXL), DrawYPos);
    Canvas.DrawText(CurrentDateString);
    DrawYPos += CurrentDateYL;
    Canvas.StrLen(scoreinfostring, ScoreInfoXL, ScoreInfoYL);
    Canvas.SetPos(0.50 * (Canvas.ClipX - ScoreInfoXL), DrawYPos);
    Canvas.DrawText(scoreinfostring);
}

simulated event UpdateScoreBoard(Canvas Canvas)
{
    local PlayerReplicationInfo PRI, OwnerPRI;
    local int i, j,  FontReduction, NetXPos,PlayerCount, HeaderOffsetY, HeadFoot, MessageFoot, PlayerBoxSizeY,BoxSpaceY, NameXPos, BoxTextOffsetY, BoxXPos, KillsXPos,	TitleYPos, BoxWidth, VetXPos, TempVetXPos, VetYPos;

    local float XL, YL, MaxScaling,AssistsXL, KillsXL, netXL, MaxNamePos,	KillWidthX, ScoreXPos, scoreXL;
    local float SCXL, FPXL, HuskXL,PlayerXL;
	local float AssistsXPos,AssistsWidthX;
    local bool bNameFontReduction;
    local Material VeterancyBox, StarMaterial;
    local int TempLevel;
    local KFPlayerReplicationInfo KFPRI;
    local float FPXPos, FPWidthX, SCXPos, SCWidthX, HuskXPos, HuskWidthX,PlayerTimeXPos, PlayerTimeXL, PlayerTimeWidthX, CashX;

    local string CashString, PlayerTime;
    local array<PlayerReplicationInfo> TeamPRIArray;
    local int OwnerOffset;

    OwnerPRI = KFPlayerController(Owner).PlayerReplicationInfo;
    OwnerOffset = -1;
    
    for(i=0;i < GRI.PRIArray.Length;i++)
    {
        PRI = GRI.PRIArray[i];
        if(!PRI.bOnlySpectator)
        {
            if(PRI == OwnerPRI)
            {
                OwnerOffset = i;
            }
            PlayerCount++;
            TeamPRIArray[TeamPRIArray.Length] = PRI;
        }
        
    }
    PlayerCount = Min(PlayerCount, MAXPLAYERS);//32
    Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);
    Canvas.StrLen("Test", XL, YL);
    BoxSpaceY = int(0.250 * YL);
    PlayerBoxSizeY = int(1.20 * YL);
    HeadFoot = int(float(7) * YL);
    MessageFoot = int(1.50 * float(HeadFoot));
    if(float(PlayerCount) > ((Canvas.ClipY - (1.50 * float(HeadFoot))) / float(PlayerBoxSizeY + BoxSpaceY)))
    {
        BoxSpaceY = int(0.1250 * YL);
        PlayerBoxSizeY = int(1.250 * YL);
        if(float(PlayerCount) > ((Canvas.ClipY - (1.50 * float(HeadFoot))) / float(PlayerBoxSizeY + BoxSpaceY)))
        {
            if(float(PlayerCount) > ((Canvas.ClipY - (1.50 * float(HeadFoot))) / float(PlayerBoxSizeY + BoxSpaceY)))
            {
                PlayerBoxSizeY = int(1.1250 * YL);
            }
        }
    }
    if(Canvas.ClipX < float(512))
    {
        PlayerCount = Min(PlayerCount, int(float(1) + ((Canvas.ClipY - float(HeadFoot)) / float(PlayerBoxSizeY + BoxSpaceY))));
    }
    else
    {
        PlayerCount = Min(PlayerCount, int(Canvas.ClipY - float(HeadFoot)) / (PlayerBoxSizeY + BoxSpaceY));
    }
    if(FontReduction > 1)//2
    {
        MaxScaling = 1.75;//3.0
    }
    else
    {
        MaxScaling = 1.75;//2.1250
    }
    PlayerBoxSizeY = int(FClamp(((1.250 + (Canvas.ClipY - (0.670 * float(MessageFoot)))) / float(PlayerCount)) - float(BoxSpaceY), float(PlayerBoxSizeY), MaxScaling * YL));
    bDisplayMessages = float(PlayerCount) <= ((Canvas.ClipY - float(MessageFoot)) / float(PlayerBoxSizeY + BoxSpaceY));
    
    HeaderOffsetY = int(float(9) * YL);//10
    BoxWidth = int(0.70 * Canvas.ClipX);
    BoxXPos = int(0.10 * (Canvas.ClipX - float(BoxWidth)));//0.2
    BoxWidth = int(Canvas.ClipX - float(2 * BoxXPos));
    VetXPos = int(float(BoxXPos) + (0.000050 * float(BoxWidth)));
    NameXPos = int(float(BoxXPos) + (0.0525 * float(BoxWidth)));//0.665
    KillsXPos = int(float(BoxXPos) + (0.385 * float(BoxWidth)));//0.45
	AssistsXPos = BoxXPos + 0.42 * BoxWidth; //0.525
    HuskXPos = float(BoxXPos) + (0.51 * float(BoxWidth));//0.60
    SCXPos = float(BoxXPos) + (0.60 * float(BoxWidth));//0.675
    FPXPos = float(BoxXPos) + (0.69 * float(BoxWidth));//0.75
    PlayerTimeXPos = float(BoxXPos) + (0.78 * float(BoxWidth));//0.825
    ScoreXPos = float(BoxXPos) + (0.87 * float(BoxWidth));//0.90
    NetXPos = int(float(BoxXPos) + (0.96 * float(BoxWidth)));//0.975
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = HudClass.default.WhiteColor;
    
    for(i=0;i < PlayerCount;i++)
    {
        if(i == OwnerOffset)
        {
            Canvas.DrawColor.A = 64;
        }
        else
        {
            Canvas.DrawColor.A = 32;
        }
        Canvas.SetPos(float(BoxXPos), float(HeaderOffsetY + ((PlayerBoxSizeY + BoxSpaceY) * i)));
        Canvas.DrawTileStretched(BoxMaterial, float(BoxWidth), float(PlayerBoxSizeY));
        
    }

    Canvas.Style = ERenderStyle.STY_Normal;
    DrawTitle(Canvas, float(HeaderOffsetY), float(PlayerCount + 1) * float(PlayerBoxSizeY + BoxSpaceY), float(PlayerBoxSizeY));
    TitleYPos = int(float(HeaderOffsetY) - (1.10 * YL));
    Canvas.StrLen(PlayerText, PlayerXL, YL);
    Canvas.StrLen(KillsText, KillsXL, YL);
	Canvas.StrLen(AssistsHeaderText, AssistsXL, YL);
    Canvas.StrLen(PointsText, scoreXL, YL);
    Canvas.StrLen(HuskText,HuskXL,YL);
	Canvas.StrLen(SCText, SCXL, YL);
	Canvas.StrLen(FPText, FPXL, YL);
    Canvas.StrLen(PlayerTimeText, PlayerTimeXL, YL);
    // Canvas.DrawColor = HudClass.default.GreenColor;
    Canvas.DrawColor = HudClass.default.WhiteColor;
    Canvas.SetPos(float(NameXPos ), float(TitleYPos));
    Canvas.DrawText(PlayerText, true);
    // Canvas.DrawColor = default.PurpleColor;
    Canvas.DrawColor = HudClass.default.WhiteColor;
    Canvas.SetPos(float(KillsXPos) - (0.50 * KillsXL), float(TitleYPos));
    Canvas.DrawText(KillsText, true);
    //Ast
	Canvas.DrawColor = default.DarkGrayColor;
	Canvas.SetPos(AssistsXPos - 0.5 * AssistsXL, TitleYPos);
	Canvas.DrawText(KillAssistsSeparator $ AssistsHeaderText,true);
    //
    Canvas.DrawColor = default.CrimsonColor;
	Canvas.SetPos(FPXPos - (0.5 * FPXL), TitleYPos);
	Canvas.DrawText(FPText,true);
    Canvas.DrawColor = default.OrangeColor;
	Canvas.SetPos(SCXPos - (0.5 * SCXL), TitleYPos);
	Canvas.DrawText(SCText,true);
    // Canvas.DrawColor = default.ChocolateColor;
    Canvas.DrawColor = default.OrangeRedColor;
    Canvas.SetPos(HuskXPos- (0.5 * HuskXL),TitleYPos);
    Canvas.DrawText(HuskText,true);
    // Canvas.DrawColor = default.YellowColor;
    Canvas.DrawColor = HudClass.default.WhiteColor;
    Canvas.SetPos(PlayerTimeXPos - (0.50 * PlayerTimeXL), float(TitleYPos));
    Canvas.DrawText(PlayerTimeText, true);
    // Canvas.DrawColor = default.GoldColor;
    Canvas.DrawColor = HudClass.default.WhiteColor;
    Canvas.SetPos(ScoreXPos - (0.50 * scoreXL), float(TitleYPos));
    Canvas.DrawText(PointsText, true);
    MaxNamePos = 0.90 * float(KillsXPos - NameXPos);
    
    for(i=0;i < PlayerCount;i++)
    {
        Canvas.StrLen(TeamPRIArray[i].PlayerName, XL, YL);
        if(XL > MaxNamePos)
        {
            bNameFontReduction = true;
        }
        
    }
    if(bNameFontReduction)
    {
        Canvas.Font = GetSmallerFontFor(Canvas, FontReduction - 1);
    }
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.SetPos(0.50 * Canvas.ClipX, float(HeaderOffsetY + 4));
    BoxTextOffsetY = int(float(HeaderOffsetY) + (0.50 * (float(PlayerBoxSizeY) - YL)));
    MaxNamePos = Canvas.ClipX;
    Canvas.ClipX = float(KillsXPos) - 4.0;
    
    for(i=0;i < PlayerCount;i++)
    {
        Canvas.DrawColor = HudClass.default.WhiteColor;
        KFPRI = KFPlayerReplicationInfo(TeamPRIArray[i]);
        Canvas.DrawColor.B = 0;
        if(i == OwnerOffset)
        {
            Canvas.DrawColor.A = 140;
        }
        else
        {
            Canvas.DrawColor.A = 70;//64
        }
        if(KFPRI.PlayerHealth >100)
        {
            // Canvas.DrawColor.R = 32;//0
            // Canvas.DrawColor.G = byte(128);//255
            // Canvas.DrawColor.B = byte((0.63750 * float(KFPRI.PlayerHealth)) - 63.750);
            
            Canvas.DrawColor.R = 0;//0
            Canvas.DrawColor.G = byte(255);//255
            Canvas.DrawColor.B = 127;
            // Canvas.DrawColor.A = 140;
        }
        else
        {
            if(KFPRI.PlayerHealth >= 65)
            {
                // Canvas.DrawColor.R = byte(float(510) - (5.10 * float(KFPRI.PlayerHealth)));
                // Canvas.DrawColor.G = byte(255);
                
            Canvas.DrawColor.R = 0;//11;//12;//byte(float(510) - (5.10 * float(KFPRI.PlayerHealth)))
            Canvas.DrawColor.G = 134;//86;////29;//byte(103);//128
            Canvas.DrawColor.B = 139;//193;////127;//136;//128
            // Canvas.DrawColor.A = 140;
            }
            else
            {
                if(KFPRI.PlayerHealth >= 25)
                {
                    Canvas.DrawColor.R = byte(255);
                    Canvas.DrawColor.G = byte((10.20 * float(KFPRI.PlayerHealth)) - float(255));
                    // Canvas.DrawColor.A = 140;
                }
                else
                {
                    Canvas.DrawColor.R = byte(255);
                    Canvas.DrawColor.G = 0;
                    // Canvas.DrawColor.A = 140;
                }
            }
        }
        Canvas.SetPos(float(BoxXPos), float(HeaderOffsetY + ((PlayerBoxSizeY + BoxSpaceY) * i)));
        Canvas.DrawTileStretched(BoxMaterial, float((BoxWidth * Clamp(KFPRI.PlayerHealth, 0, 100)) / 100), float(PlayerBoxSizeY));
        
    }
    Canvas.ClipX = MaxNamePos;
    if(bNameFontReduction)
    {
        Canvas.Font = GetSmallerFontFor(Canvas, FontReduction);
    }
    Canvas.Style = ERenderStyle.STY_Alpha;
    MaxScaling = FMax(float(PlayerBoxSizeY), 30.0);
    
    for(i=0;i < PlayerCount;i++)
    {
        KFPRI = KFPlayerReplicationInfo(TeamPRIArray[i]);
        Canvas.DrawColor = HudClass.default.WhiteColor;
        if(i == OwnerOffset)
        {
            Canvas.DrawColor.A = byte(255);
        }
        else
        {
            Canvas.DrawColor.A = 192;
        }
        if((KFPRI != none) && KFPRI.ClientVeteranSkill != none)
        {
            if(KFPRI.ClientVeteranSkillLevel == 6)
            {
                VeterancyBox = KFPRI.ClientVeteranSkill.default.OnHUDGoldIcon;
                StarMaterial = class'HUDKillingFloor'.default.VetStarGoldMaterial;
                TempLevel = KFPRI.ClientVeteranSkillLevel - 5;
            }
            else
            {
                VeterancyBox = KFPRI.ClientVeteranSkill.default.OnHUDIcon;
                StarMaterial = class'HUDKillingFloor'.default.VetStarMaterial;
                TempLevel = KFPRI.ClientVeteranSkillLevel;
            }
            if(VeterancyBox != none)
            {
                TempVetXPos = VetXPos;
                VetYPos = int(float(((PlayerBoxSizeY + BoxSpaceY) * i) + BoxTextOffsetY) - (float(PlayerBoxSizeY) * 0.195));//0.22
                Canvas.SetPos(float(TempVetXPos), float(VetYPos));
                Canvas.DrawTile(VeterancyBox, float(PlayerBoxSizeY), float(PlayerBoxSizeY), 0.0, 0.0, float(VeterancyBox.MaterialUSize()), float(VeterancyBox.MaterialVSize()));
                if(StarMaterial != none)
                {
                    TempVetXPos += int(float(PlayerBoxSizeY) - (float(PlayerBoxSizeY / 5) * 0.750));
                    VetYPos += int(float(PlayerBoxSizeY) - (float(PlayerBoxSizeY / 5) * 1.50));
                    
                    for(j=0;j < TempLevel;j++)
                    {
                        Canvas.SetPos(float(TempVetXPos), float(VetYPos));
                        Canvas.DrawTile(StarMaterial, float(PlayerBoxSizeY / 5) * 0.70, float(PlayerBoxSizeY / 5) * 0.70, 0.0, 0.0, float(StarMaterial.MaterialUSize()), float(StarMaterial.MaterialVSize()));
                        VetYPos -= int(float(PlayerBoxSizeY / 5) * 0.70);
                        
                    }
                }
            }
        }
        Canvas.SetPos(float(NameXPos), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
        Canvas.DrawTextClipped(KFPRI.PlayerName);
        if(bDisplayWithKills)
        {
            Canvas.DrawColor = default.CrimsonColor;
            Canvas.StrLen(string(XTFPlayerReplicationInfo(KFPRI).FPKilled), FPWidthX, YL);
            Canvas.SetPos(FPXPos - (0.50 * FPWidthX), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
            Canvas.DrawText(string(XTFPlayerReplicationInfo(KFPRI).FPKilled), true);
            Canvas.DrawColor = default.OrangeColor;
            Canvas.StrLen(string(XTFPlayerReplicationInfo(KFPRI).SCKilled), SCWidthX, YL);
            Canvas.SetPos(SCXPos - (0.50 * SCWidthX), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
            Canvas.DrawText(string(XTFPlayerReplicationInfo(KFPRI).SCKilled), true);
            Canvas.DrawColor = default.OrangeRedColor;
            Canvas.StrLen(string(XTFPlayerReplicationInfo(KFPRI).HuskKilled), HuskWidthX, YL);
            Canvas.SetPos(HuskXPos - (0.50 * HuskWidthX), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
            Canvas.DrawText(string(XTFPlayerReplicationInfo(KFPRI).HuskKilled), true);
            // Canvas.DrawColor = default.PurpleColor;
            Canvas.DrawColor = HudClass.default.WhiteColor;
            Canvas.StrLen(string(KFPRI.Kills), KillWidthX, YL);
            Canvas.SetPos(float(KillsXPos) - (0.50 * KillWidthX), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
            Canvas.DrawText(string(KFPRI.Kills), true);
            // Draw Kill Assists
			Canvas.DrawColor = default.DarkGrayColor;
			Canvas.StrLen(KFPRI.KillAssists, AssistsWidthX, YL);
			Canvas.SetPos(AssistsXPos - 0.5 * AssistsWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
			Canvas.DrawText(KillAssistsSeparator $ KFPRI.KillAssists, true);            
        }
        PlayerTime = FormatTime(GRI.ElapsedTime - KFPRI.StartTime);
        // Canvas.DrawColor = default.YellowColor;
        Canvas.DrawColor = HudClass.default.WhiteColor;
        Canvas.StrLen(PlayerTime, PlayerTimeWidthX, YL);
        Canvas.SetPos(PlayerTimeXPos - (0.50 * PlayerTimeWidthX), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
        Canvas.DrawText(PlayerTime, true);
        CashString = "£" $ string(int(TeamPRIArray[i].Score));
        if(TeamPRIArray[i].Score >= float(1000))
        {
            CashString = ( "£" $ string(TeamPRIArray[i].Score / 1000.0)) $ "K";
        }
        // Canvas.DrawColor = default.GoldColor;
        Canvas.DrawColor = HudClass.default.WhiteColor;
        Canvas.StrLen(CashString, CashX, YL);
        Canvas.SetPos(ScoreXPos - (CashX / float(2)), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
        Canvas.DrawText(CashString);
        
    }
    if(Level.NetMode == NM_Standalone)
    {
        return;
    }
    Canvas.DrawColor = HudClass.default.WhiteColor;
    Canvas.StrLen(NetText, netXL, YL);
    Canvas.SetPos(float(NetXPos) - (0.50 * netXL), float(TitleYPos));
    Canvas.DrawText(NetText, true);

    for(i=0;i < GRI.PRIArray.Length;i++)
    {
        PRIArray[i] = GRI.PRIArray[i];
    }
    DrawNetInfo(Canvas, FontReduction, HeaderOffsetY, PlayerBoxSizeY, BoxSpaceY, BoxTextOffsetY, OwnerOffset, PlayerCount, NetXPos);
    DrawMatchID(Canvas, FontReduction);
}

function DrawNetInfo(Canvas Canvas, int FontReduction, int HeaderOffsetY, int PlayerBoxSizeY, int BoxSpaceY, int BoxTextOffsetY, int OwnerOffset, int PlayerCount, int NetXPos)
{
    local int i, PlayerPing;
    local float AdminXL, AdminYL, ReadyXL, ReadyYL, NotReadyXL, NotReadyYL,
	    PlayerPingXL, PlayerPingYL;

    if(Canvas.ClipX < float(512))
    {
        PingText = "";
    }
    else
    {
        PingText = default.PingText;
    }
    if(GRI.bMatchHasBegun)
    {
        Canvas.DrawColor = HudClass.default.WhiteColor;
        
        for(i=0;i < PlayerCount;i++)
        {
            if(i == OwnerOffset)
            {
                Canvas.DrawColor.A = byte(255);
            }
            else
            {
                Canvas.DrawColor.A = 192;
            }
            if(PRIArray[i].bAdmin)
            {
                Canvas.StrLen(AdminText, AdminXL, AdminYL);
                Canvas.SetPos(float(NetXPos) - (0.50 * AdminXL), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
                Canvas.DrawText(AdminText);
            }

        }
    }
    else
    {
        
        for(i=0;i < PlayerCount;i++)
        {
            Canvas.DrawColor = HudClass.default.WhiteColor;
            PlayerPing = Min(999, 4 * PRIArray[i].Ping);
            if(i == OwnerOffset)
            {
                Canvas.DrawColor.A = byte(255);
            }
            else
            {
                Canvas.DrawColor.A = 192;
            }
            if(PRIArray[i].bReadyToPlay)
            {
                Canvas.StrLen(ReadyText, ReadyXL, ReadyYL);
                Canvas.SetPos(float(NetXPos) - (0.50 * ReadyXL), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
                Canvas.DrawText(ReadyText, true);
                
            }
            Canvas.StrLen(NotReadyText, NotReadyXL, NotReadyYL);
            Canvas.SetPos(float(NetXPos) - (0.50 * NotReadyXL), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
            Canvas.DrawText(NotReadyText, true);
            
        }
        return;
    }
    if(Canvas.ClipX < float(512))
    {
        PingText = "";
    }
    else
    {
        PingText = default.PingText;
    }
    
    for(i=0;i < PlayerCount;i++)
    {
        Canvas.DrawColor = HudClass.default.WhiteColor;
        if(i == OwnerOffset)
        {
            Canvas.DrawColor.A = byte(255);
        }
        else
        {
            Canvas.DrawColor.A = 192;
        }
        if(!PRIArray[i].bAdmin && !PRIArray[i].bOutOfLives)
        {
            PlayerPing = Min(999, 4 * PRIArray[i].Ping);
            Canvas.StrLen(string(PlayerPing), PlayerPingXL, PlayerPingYL);
            Canvas.SetPos(float(NetXPos) - (0.50 * PlayerPingXL), (float(PlayerBoxSizeY + BoxSpaceY) * float(i)) + float(BoxTextOffsetY));
            Canvas.DrawText(string(PlayerPing), true);
        }
        
    }
}


simulated function bool InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
	local KFPlayerReplicationInfo P11,P22;

	P11 = KFPlayerReplicationInfo(P1);
	P22 = KFPlayerReplicationInfo(P2);

	if( P11==None || P22==None )
		return true;
	if( P1.bOnlySpectator )
	{
		if( P2.bOnlySpectator )
			return true;
		else return false;
	}
	else if ( P2.bOnlySpectator )
		return true;

	if( P11.Kills < P22.Kills )
		return false;
	else if( P11.Kills==P22.Kills )
	{
		// Kills is equal, go for assists.
		if( P11.KillAssists < P22.KillAssists )
		{
			return false;
		}
        else if( P11.KillAssists==P22.KillAssists )
		{
			if( P11.Score < P22.Score )
			{
                return false;
            }
            else if( P11.Score == P22.Score)
            {
               return (P1.PlayerName<P2.PlayerName); // Go for name.
            }
        }
	}
	return true;
}

defaultproperties
{
     FPText="FleshPound"
     SCText="Scrake"
     HuskText="Husk"
     KillsText="Kill"
     AssistsHeaderText="Assist"
     KillAssistsSeparator=" +"
     PlayerText="Player"
	 PlayerTimeText="Time"
     AdminText="Ab0min"
     PointsText="D0$h"
     NetText="Ping"
     ReadyText="Ready"
     NotReadyText="Pending"
     NotShownInfo="player names not shown"
     PlayerCountText="Players:"
     SpectatorCountText="| Spectators:"
     AliveCountText="| Alive players:"
     BotText="BOT"
     Blue=(R=32,G=178,B=170,A=255)
     GrayColor=(B=192,G=192,R=192,A=255)
     DarkGrayColor=(B=128,G=128,R=128,A=255)
     YellowColor=(R=218,G=165,B=32,A=255)
	 ChocolateColor=(R=139,G=69,B=19,A=255)
     OrangeRedColor=(R=235,G=222,B=30,A=255)
	 OrangeColor=(R=223,G=89,B=17,A=255)//210,105,30
	//  OrangeRedColor=(R=255,G=69,B=0,A=255)
     CrimsonColor=(R=255,G=0,B=0,A=255)
     GoldColor=(R=220,G=20,B=60,A=255)
     PurpleColor=(B=128,G=0,R=128,A=255)
     BoxMaterial=Texture'Box'
}
