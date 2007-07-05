unit USpeedUp;

{$mode objfpc}{$H+}

Interface

Uses Classes, SysUtils, UItem, UBomberman, UUtils, UCore;

Type

{ CSpeedUp }

CSpeedUp = Class ( CItem )

          Public
                Procedure Bonus ( nPlayer : CBomberman ) ; override; // procedure qui va augmenter la vitesse du joueur de 1

End;



Implementation

{ CSpeedUp }

Procedure CSpeedUp.Bonus( nPlayer : CBomberman );
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up a speed upgrade.', 0.0, 0.2, 5 );

     nPlayer.Speed := nPlayer.Speed + SPEEDCHANGE; // augmente la vitesse du joueur
     if nPlayer.Speed > SPEEDLIMIT then nPlayer.Speed := SPEEDLIMIT;    // limitation de la vitesse du bomberman

     self.destroy();     // on peut detruire le bonus
End;




End.
