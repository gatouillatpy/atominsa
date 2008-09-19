Unit UBlock;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils;

Type

{ CBlock }

CBlock = Class
         Protected
                nX : integer;
                nY : integer;
                bExplosive : Boolean;                                           // bloc qui peut exploser ou pas

         Public
           Constructor Create (aX, aY : Integer; aExplosive : boolean); virtual;  // constructeur (virtual car la methode va etre utilisee differemment dans les classes filles
           Procedure Explose () ; virtual;                                      // detruit le bloc si c'est possible (appele apres une explosion)
           Procedure ExploseMulti(); virtual;
           Function IsExplosive():boolean;
           
           
           Property XGrid : integer Read nX Write nX;
           Property YGrid : integer Read nY Write nY;
               
End;



Implementation

Uses UGame, UMulti, USetup, UCore;

{ CBlock }

Constructor CBlock.Create ( aX, aY : Integer; aExplosive : boolean) ;
Begin
     nX := aX;                                                                   // definit l'abscisse du bloc
     nY := aY;                                                                   // definit l'ordonnee du bloc
     bExplosive := aExplosive;                                                       // definit si le bloc peut exploser
End;


Procedure CBlock.Explose();
Var sData : String;
Begin
     If (bMulti = False) Or (nLocalIndex = nClientIndex[0]) Then Begin
         Self.Destroy;                                                              // supprime le bloc
         If (bMulti = True) And (nLocalIndex = nClientIndex[0]) Then Begin
            sData := IntToStr( nX ) + #31;
            sData := sData + IntToStr( nY ) + #31;
            Send( nLocalIndex, HEADER_EXPLOSE_BLOCK, sData );
         End;
     End;
End;

Procedure CBlock.ExploseMulti();
Begin
     Self.Destroy;
End;

function CBlock.IsExplosive(): boolean;
begin
  result:=bExplosive;
end;



End.

