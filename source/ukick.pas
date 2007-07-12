Unit UKick;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UItem, UBomberman, UCore, UUtils;

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
     SetString( STRING_NOTIFICATION, nPlayer.Name + ' has picked up the ability to kick bombs.', 0.0, 0.2, 5 );
     
     nPlayer.ActiveKick();
     self.destroy();
End;



End.

