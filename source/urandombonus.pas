Unit URandomBonus;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman, UCore, UUtils;

Type

{ CRandomBonus }

CRandomBonus = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override;

End;



Implementation
Uses UExtraBomb, UFlameUp, uFlame, UDisease, USpeedUp, UKick, uGrab, uJelly,
     UPunch, USpoog, UGoldFLame, UTrigger, USuperDisease, UGame;

{ CGrab }

Procedure CRandomBonus.Bonus( nPlayer : CBomberman ) ;
var r, numDisease : integer;
    aBonus : CItem;
    aDisease : CDisease;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up a random bonus.', 0.0, 0.2, 5 );
     r := random(POWERUPCOUNT);
     case r of
         POWERUP_EXTRABOMB       : aBonus := CExtraBomb.Create(0,0);           // plus de bombes
         POWERUP_FLAMEUP         : aBonus := CFlameUp.Create(0,0);             // flammes plus longues
         POWERUP_DISEASE         : Begin                                       // maladies
                                        If ( bMulti = false ) Then
                                           aBonus := CDisease.Create(0,0);
                                   End;
         POWERUP_KICK            : aBonus := CKick.Create(0,0);                // pousse avec rebonds
         POWERUP_SPEEDUP         : aBonus := CSpeedUp.Create(0,0);             // plus de vitesse
         POWERUP_PUNCH           : aBonus := CPunch.Create(0,0);               // pousse sans rebonds
         POWERUP_GRAB            : aBonus := CGrab.Create(0,0);                // bombe par dessus les boîtes?
         POWERUP_SPOOGER         : aBonus := CSpoog.Create(0,0);               // porte les bombes?
         POWERUP_GOLDFLAME       : aBonus := CGoldFlame.Create(0,0);           // flammes infinies
         POWERUP_TRIGGERBOMB     : aBonus := CTrigger.Create(0,0);             // bombes à retardement
         POWERUP_JELLYBOMB       : aBonus := CJelly.Create(0,0);               // bombes spéciales
         POWERUP_SUPERDISEASE    : aBonus := CSuperDisease.Create(0,0);        // 3 maladies
    end;
    If ( bMulti = false ) Or ( ( r <> POWERUP_DISEASE ) And ( r <> POWERUP_SUPERDISEASE ) ) Then
       aBonus.Bonus(nPlayer)
    Else Begin
         If ( r = POWERUP_DISEASE ) Then Begin
            If ( nPlayer.DiseaseNumber = 0 )
            Or ( nDisease[Trunc(nPlayer.Position.X + 0.5), Trunc(nPlayer.Position.Y + 0.5)] = DISEASE_SWITCH) Then Begin
               aDisease := CDisease.Create(0,0);
               aDisease.BonusForced(nPlayer,nDisease[Trunc(nPlayer.Position.X + 0.5), Trunc(nPlayer.Position.Y + 0.5)]);
            End
            Else
                aBonus.Destroy();
         End;
         If ( r = POWERUP_SUPERDISEASE ) Then Begin
            aDisease := CDisease.Create(0,0);
            numDisease := nDisease[Trunc(nPlayer.Position.X + 0.5), Trunc(nPlayer.Position.Y + 0.5)] mod 100;
            aDisease.BonusForced(nPlayer,numDisease);
            aDisease := CDisease.Create(0,0);
            numDisease := ( nDisease[Trunc(nPlayer.Position.X + 0.5), Trunc(nPlayer.Position.Y + 0.5)] mod 10000 ) div 100;
            aDisease.BonusForced(nPlayer,numDisease);
            aDisease := CDisease.Create(0,0);
            numDisease := nDisease[Trunc(nPlayer.Position.X + 0.5), Trunc(nPlayer.Position.Y + 0.5)] div 10000;
            aDisease.BonusForced(nPlayer,numDisease);
         End;
    End;

    Destroy();
End;



End.

