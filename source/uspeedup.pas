unit USpeedUp;

{$mode objfpc}{$H+}

Interface

Uses Classes, SysUtils, UItem, UBomberman, UUtils;

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

       nPlayer.Speed := nPlayer.Speed + SPEEDCHANGE; // augmente la vitesse du joueur
       if nPlayer.Speed > SPEEDLIMIT then nPlayer.Speed := SPEEDLIMIT;    // limitation de la vitesse du bomberman

       self.destroy();     // on peut detruire le bonus
End;




End.
