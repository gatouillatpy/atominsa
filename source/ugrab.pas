Unit UGrab;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman, UCore, UUtils;

Type

{ CKick }

CGrab = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override;

End;



Implementation

{ CGrab }

Procedure CGrab.Bonus( nPlayer : CBomberman ) ;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up the ability to grab bombs.', 0.0, 0.2, 5 );

     nPlayer.ActiveGrab();
     self.destroy();
End;



End.

