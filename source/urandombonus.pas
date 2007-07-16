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
     UPunch, USpoog, UGoldFLame, UTrigger, USuperDisease;

{ CGrab }

Procedure CRandomBonus.Bonus( nPlayer : CBomberman ) ;
var r : integer;
    aBonus : CItem;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up a random bonus.', 0.0, 0.2, 5 );
     r := random(POWERUPCOUNT);
     case r of
         POWERUP_EXTRABOMB       : aBonus := CExtraBomb.Create(0,0);
         POWERUP_FLAMEUP         : aBonus := CFlameUp.Create(0,0);
         POWERUP_DISEASE         : aBonus := CDisease.Create(0,0);
         POWERUP_KICK            : aBonus := CKick.Create(0,0);
         POWERUP_SPEEDUP         : aBonus := CSpeedUp.Create(0,0);
         POWERUP_PUNCH           : aBonus := CPunch.Create(0,0);
         POWERUP_GRAB            : aBonus := CGrab.Create(0,0);
         POWERUP_SPOOGER         : aBonus := CSpoog.Create(0,0);
         POWERUP_GOLDFLAME       : aBonus := CGoldFlame.Create(0,0);
         POWERUP_TRIGGERBOMB     : aBonus := CTrigger.Create(0,0);
         POWERUP_JELLYBOMB       : aBonus := CJelly.Create(0,0);
         POWERUP_SUPERDISEASE    : aBonus := CSuperDisease.Create(0,0);
    end;
    aBonus.Bonus(nPlayer);
    Destroy();
End;



End.

