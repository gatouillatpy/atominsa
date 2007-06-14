Unit USpawn;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils;

Type

{ CSpawn }

CSpawn = Class

         Private
                nX           : Integer  ;
                nY           : Integer  ;
                
                nColor       : Integer  ;
                nTeam        : Integer  ;
                
                fDelay       : Single   ;
                
         Public
               Constructor Create ( _nX, _nY : Integer ; _nColor, _nTeam : Integer ; _fDelay : Single = 0 ) ; virtual;

               Property X : Integer Read nX ;
               Property Y : Integer Read nY ;
               
               Property Color : Integer Read nColor ;
               Property Team : Integer Read nTeam ;
               
               Property Delay : Single Read fDelay ;

End;



Implementation

{ CSpawn }

Constructor CSpawn.Create ( _nX, _nY : Integer ; _nColor, _nTeam : Integer ; _fDelay : Single = 0 ) ;
Begin

     nX := _nX + 1;
     nY := _nY + 1;

     nColor := _nColor;
     nTeam := _nTeam;
     
     fDelay := _fDelay;
     
End;



End.
