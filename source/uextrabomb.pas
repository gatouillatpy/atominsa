Unit UExtraBomb;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman, UUtils, UCore;

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
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up an extra bomb.', 0.0, 0.2, 5 );

     If nPlayer.BombCount < MAXBOMBCOUNT Then
        nPlayer.BombCount := nPlayer.BombCount + 1; // augmente le nombre de bombes du joueur d'une unité

     Self.Destroy(); // on peut detruire le bonus
End;





End.
