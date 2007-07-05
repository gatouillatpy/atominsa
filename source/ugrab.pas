Unit UGrab;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman;

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
       nPlayer.ChangeGrab();
       self.destroy();
End;



End.

