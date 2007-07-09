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
           Function IsExplosive():boolean;
           
           Property XGrid : integer Read nX Write nX;
           Property YGrid : integer Read nY Write nY;
               
End;



Implementation

{ CBlock }

Constructor CBlock.Create ( aX, aY : Integer; aExplosive : boolean) ;
Begin
     nX := aX;                                                                   // definit l'abscisse du bloc
     nY := aY;                                                                   // definit l'ordonnee du bloc
     bExplosive := aExplosive;                                                       // definit si le bloc peut exploser
End;


Procedure CBlock.Explose();
Begin
     Self.Destroy;                                                              // supprime le bloc
End;

function CBlock.IsExplosive(): boolean;
begin
  result:=bExplosive;
end;



End.

