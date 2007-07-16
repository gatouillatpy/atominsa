Unit UTrigger;

{$mode objfpc}{$H+}



Interface

Uses UItem, UBomberman, UCore, UUtils;

Type

{ CTrigger }

CTrigger = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override;

End;



Implementation

{ CTrigger }

Procedure CTrigger.Bonus( nPlayer : CBomberman ) ;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up trigger bombs.', 0.0, 0.2, 5 );

     nPlayer.ActiveTrigger();
     self.destroy();
End;



End.

