Unit UFlameUp;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman, UUtils, UCore;

Type

{ CFlameUp }

CFlameUp = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override; // procedure qui va augmenter la portee de l'explosion du joueur
                 
End;



Implementation

{ CFlameUp }

Procedure CFlameUp.Bonus( nPlayer : CBomberman ) ;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up a flame upgrade.', 0.0, 0.2, 5 );

     nPlayer.FlameSize := nPlayer.FlameSize + FLAMECHANGE; // augmente la portee de l'explosion des bombes du joueur de 1
     if nPlayer.FlameSize > FLAMELIMIT then nPlayer.FlameSize := FLAMELIMIT; // les flammes ne doivent pas depasser la valeur limite
     self.destroy();      // on change la valeur de la variable pour qu'a la prochaine utilissation de la methode, on annule son effet
End;



End.

