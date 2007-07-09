Unit UJelly;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman, UCore, UUtils;

Type

{ CJelly }

CJelly = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override;

End;



Implementation

{ CJelly }

Procedure CJelly.Bonus( nPlayer : CBomberman ) ;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up jelly bombs.', 0.0, 0.2, 5 );

     nPlayer.ChangeJelly();
     self.destroy();
End;



End.

