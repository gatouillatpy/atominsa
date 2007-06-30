Unit UExtraBomb;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman, UUtils;

Type

{ CExtraBomb }

CExtraBomb = Class ( CItem )

          Public
                Procedure Bonus ( nPlayer : CBomberman ) ; override; // procedure qui va augmenter le nombre de bombes du joueur

End;



Implementation

{ CExtraBomb }

Procedure CExtraBomb.Bonus( nPlayer : CBomberman );
Begin
     if nPlayer.BombCount<>MAXBOMBCOUNT then
       nPlayer.BombCount := nPlayer.BombCount + 1; // augmente le nombre de bombes du joueur de 1
       self.destroy();        // on peut detruire le bonus

End;





End.
