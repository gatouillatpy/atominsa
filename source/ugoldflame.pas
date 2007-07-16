Unit UGoldFlame;

{$mode objfpc}{$H+}



Interface

Uses UItem, UBomberman, UCore, UUtils;

Type

{ CGoldFlame }

CGoldFlame = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override;

End;



Implementation

{ CSpoil }

Procedure CGoldFlame.Bonus( nPlayer : CBomberman ) ;
Begin
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up a GoldFLame.', 0.0, 0.2, 5 );

     nPlayer.FlameSize:=FLAMELIMIT;
     self.destroy();
End;



End.

