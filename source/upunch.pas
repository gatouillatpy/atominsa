Unit UPunch;

{$mode objfpc}{$H+}



Interface

Uses UItem, UBomberman, UCore, UUtils;

Type

{ CPunch }

CPunch = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override;

End;



Implementation

{ CPunch }

Procedure CPunch.Bonus( nPlayer : CBomberman ) ;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up the capacity to Punch bombs.', 0.0, 0.2, 5 );

     nPlayer.ActivePunch();
     self.destroy();
End;



End.

