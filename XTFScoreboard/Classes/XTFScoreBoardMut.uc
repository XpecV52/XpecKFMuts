class XTFScoreBoardMut extends Mutator;

var XTFScoreBoardGameRules sbGameRules;

function PostBeginPlay()
{
	Level.Game.ScoreBoardType = "XTFScoreBoard.XTFScoreBoard";
	sbGameRules=Spawn(Class'XTFScoreBoardGameRules');
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(Controller(Other)!=None)
		Controller(Other).PlayerReplicationInfoClass = Class'XTFPlayerReplicationInfo';
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-XTFScoreboard"
     FriendlyName="XTFScoreboard"
     Description="XTFScoreboard show Players' HPBar and FP/SC/HU killCount."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
