Unit UKick;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman, UUtils;

Type

{ CKick }

CKick = Class ( CItem )

           Public
                 Procedure Bonus ( nPlayer : CBomberman ) ; override;
                 
End;



Implementation

{ CKick }

Procedure CKick.Bonus( nPlayer : CBomberman ) ;
Begin
       nPlayer.Kick:=True;
       self.destroy();
End;



End.

