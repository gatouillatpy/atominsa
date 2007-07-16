Unit USpoog;

{$mode objfpc}{$H+}



Interface

Uses UItem, UBomberman, UCore, UUtils;

Type

{ CSpoog }

CSpoog = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override;

End;



Implementation

{ CSpoil }

Procedure CSpoog.Bonus( nPlayer : CBomberman ) ;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up the capacity to Spoog bombs.', 0.0, 0.2, 5 );

     nPlayer.ActiveSpoog();
     self.destroy();
End;



End.

