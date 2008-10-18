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
Uses UExtraBomb, UFlameUp, UDisease, USpeedUp, UKick, uGrab, uJelly,
     UPunch, USpoog, UGoldFLame, UTrigger, USuperDisease, UGame;

{ CGrab }

Procedure CRandomBonus.Bonus( nPlayer : CBomberman ) ;
var r : integer;
    aBonus : CItem;
    aDisease : CDisease;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up a random bonus.', 0.0, 0.2, 5 );
     r := random(POWERUPCOUNT);
     case r of
         POWERUP_EXTRABOMB       : aBonus := CExtraBomb.Create(0,0);           // plus de bombes
         POWERUP_FLAMEUP         : aBonus := CFlameUp.Create(0,0);             // flammes plus longues
         POWERUP_DISEASE         : aBonus := CDisease.Create(0,0);             // maladies
         POWERUP_KICK            : aBonus := CKick.Create(0,0);                // pousse avec rebonds
         POWERUP_SPEEDUP         : aBonus := CSpeedUp.Create(0,0);             // plus de vitesse
         POWERUP_PUNCH           : aBonus := CPunch.Create(0,0);               // pousse sans rebonds
         POWERUP_GRAB            : aBonus := CGrab.Create(0,0);                // bombe par dessus les boîtes et portée de bombe.
         POWERUP_SPOOGER         : aBonus := CSpoog.Create(0,0);               // plusieurs bombes avec la deuxième plus loin que la première
         POWERUP_GOLDFLAME       : aBonus := CGoldFlame.Create(0,0);           // flammes infinies
         POWERUP_TRIGGERBOMB     : aBonus := CTrigger.Create(0,0);             // bombes à retardement
         POWERUP_JELLYBOMB       : aBonus := CJelly.Create(0,0);               // bombes spéciales
         POWERUP_SUPERDISEASE    : aBonus := CSuperDisease.Create(0,0);        // 3 maladies
    end;
    aBonus.Bonus(nPlayer);

     Destroy();
End;



End.

