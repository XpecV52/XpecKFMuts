class KF2WelderHitEmitter extends WelderHitEmitter;

defaultproperties
{
     ImpactSounds(0)=Sound'KF2Tools_A.Welder.welder_weld_a'
     ImpactSounds(1)=Sound'KF2Tools_A.Welder.welder_weld_b'
     ImpactSounds(2)=Sound'KF2Tools_A.Welder.welder_weld_c'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter41
         UseDirectionAs=PTDU_UpAndNormal
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-210.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=205,G=205,R=131))
         ColorScale(1)=(RelativeTime=0.214286,Color=(B=255,G=255,R=181))
         ColorScale(2)=(RelativeTime=0.439286,Color=(B=155,G=155,R=61))
         ColorScale(3)=(RelativeTime=1.000000,Color=(A=255))
         FadeOutStartTime=0.336000
         FadeInEndTime=0.064000
         MaxParticles=20
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=5000.000000,Max=5000.000000),Z=(Min=5000.000000,Max=5000.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000,Y=0.010000)
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFX.KFSparkHead'
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
     End Object
     Emitters(0)=SpriteEmitter'KF2WelderHitEmitter.SpriteEmitter41'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter42
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=10.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.250000,Max=0.350000),Y=(Min=0.250000,Max=0.300000),Z=(Min=0.200000,Max=0.250000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=2.000000,Max=4.000000))
         InitialParticlesPerSecond=15.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KF2Tools_A.WelderFX.wfx_bigzap'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.050000,Max=0.050000)
     End Object
     Emitters(1)=SpriteEmitter'KF2WelderHitEmitter.SpriteEmitter42'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter43
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         MaxParticles=1
         SpinsPerSecondRange=(X=(Min=-100000.000000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=1.000000,Max=3.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KF2Tools_A.WelderFX.wfx_lightning'
         LifetimeRange=(Min=0.010000,Max=0.100000)
     End Object
     Emitters(2)=SpriteEmitter'KF2WelderHitEmitter.SpriteEmitter43'

}
