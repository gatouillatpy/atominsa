Unit UScheme;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, USpawn, UPowerUp, UUtils, UForm;

Type

{ CScheme }

CScheme = Class

          Private
                 sName         : String                                         ;
                 nVersion      : Integer                                        ;

                 sPath         : String                                         ;

                 nBrickDensity : Integer                                        ;

                 aBlock        : Array [1..GRIDWIDTH,1..GRIDHEIGHT] Of Integer  ;
                 aSpawn        : Array [1..SPAWNCOUNT] Of CSpawn                ;
                 aPowerUp      : Array [1..POWERUPCOUNT] Of CPowerUp            ;
                 
                 nBlankCount   : Integer                                        ;
                 nBrickCount   : Integer                                        ;
                 nSolidCount   : Integer                                        ;
                 
                 Procedure CheckSpawn( x, y : Integer ) ;

          Public
                Constructor Create ( sFile : String ; bDebug : Boolean ) ;

                Property Name : String Read sName ;
                Property Version : Integer Read nVersion ;

                Property Path : String Read sPath ;

                Property BrickDensity : Integer Read nBrickDensity ;
                
                Function Block ( x, y : Integer ) : Integer ;
                Function Spawn ( id : Integer ) : CSpawn ;
                Function PowerUp ( id : Integer ) : CPowerUp ;

                Property BlankCount : Integer Read nBlankCount ;
                Property BrickCount : Integer Read nBrickCount ;
                Property SolidCount : Integer Read nSolidCount ;

End;



Implementation

Const STEP_NONE          = 0;
Const STEP_COMMENT       = 1;
Const STEP_NAME          = 2;
Const STEP_VERSION       = 3;
Const STEP_BRICKDENSITY  = 4;
Const STEP_BLOCK         = 5;
Const STEP_SPAWN         = 6;
Const STEP_POWERUP       = 7;

Function GetStep ( sCommand : String ) : Integer ;
Var i : Integer;
    nStep : Integer;
Begin
     nStep := STEP_NONE;

     For i := 1 To Length(sCommand) Do
     Begin
          If (sCommand[i] = ';') Then nStep := STEP_COMMENT;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'N') Then nStep := STEP_NAME;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'V') Then nStep := STEP_VERSION;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'B') Then nStep := STEP_BRICKDENSITY;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'R') Then nStep := STEP_BLOCK;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'S') Then nStep := STEP_SPAWN;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'P') Then nStep := STEP_POWERUP;

          If nStep > STEP_NONE Then Break;
     End;
     
     GetStep := nStep;
End;

Function GetString ( sCommand : String; nArg : Integer ) : String ;
Var i, j : Integer;
    nCount : Integer;
    sResult : String;
Begin
     nCount := 0;
     sResult := 'NULL';

     j := 0;
     For i := 1 To Length(sCommand) Do
     Begin
          If sCommand[i] = ',' Then
          Begin
               nCount += 1;
               If nCount = nArg Then j := i + 1;
               If nCount = nArg + 1 Then sResult := Copy( sCommand, j, i - j );
          End Else Begin If i = Length(sCommand) Then
          Begin
               nCount += 1;
               If nCount = nArg Then j := i + 1;
               If nCount = nArg + 1 Then sResult := Copy( sCommand, j, i - j + 1 );
          End; End;
          If sResult <> 'NULL' Then Break;
     End;

     GetString := sResult;
End;

Function GetInteger ( sCommand : String; nArg : Integer ) : Integer ;
Var sResult : String;
Begin
     sResult := GetString( sCommand, nArg );
     
     If sResult <> 'NULL' Then GetInteger := StrToInt( sResult ) Else GetInteger := 0;
End;

Function GetSingle ( sCommand : String; nArg : Integer ) : Single ;
Var sResult : String;
Begin
     sResult := GetString( sCommand, nArg );

     If sResult <> 'NULL' Then GetSingle := StrToFloat( sResult ) Else GetSingle := 0.0;
End;

Function GetBoolean ( sCommand : String; nArg : Integer ) : Boolean ;
Var sResult : String;
Begin
     sResult := GetString( sCommand, nArg );

     If sResult <> 'NULL' Then GetBoolean := StrToBool( sResult ) Else GetBoolean := False;
End;

{ CScheme }

Procedure CScheme.CheckSpawn( x, y : Integer ) ;
Begin
     aBlock[x,y] := BLOCK_BLANK;
     x -= 1;
     If CheckCoordinates( x, y ) Then aBlock[x,y] := BLOCK_BLANK;
     x += 2;
     If CheckCoordinates( x, y ) Then aBlock[x,y] := BLOCK_BLANK;
     x -= 1;
     y -= 1;
     If CheckCoordinates( x, y ) Then aBlock[x,y] := BLOCK_BLANK;
     y += 2;
     If CheckCoordinates( x, y ) Then aBlock[x,y] := BLOCK_BLANK;
End;

Constructor CScheme.Create ( sFile : String ; bDebug : Boolean ) ;
Var ioLine : TEXT;
    sLine : String;
    nX, nY : Integer;
    sData : String;
    nSpawn : Integer;
    nPowerUp : Integer;
    i : Integer;
Begin
     AddLineToConsole( 'Loading scheme ' + sFile );
     
     sPath := sFile;
     sFile := PATH_SCHEME + sFile;

     nSpawn := 0;
     For i := 1 To SPAWNCOUNT Do
         aSpawn[i] := NIL;

     nPowerUp := 0;
     For i := 1 To POWERUPCOUNT Do
         aPowerUp[i] := NIL;

     For nY := 1 To GRIDHEIGHT Do Begin
         For nX := 1 To GRIDWIDTH Do Begin
             aBlock[nX,nY] := BLOCK_SOLID;
         End;
     End;

     Assign( ioLine, sFile );
     Reset( ioLine );

     While EOF(ioLine) = False Do
     Begin
          ReadLn( ioLine, sLine );
          Case GetStep(sLine) Of
               STEP_NAME          :
               Begin
                    sName := GetString(sLine, 1);
                    If bDebug Then AddLineToConsole( 'Name : ' + sName );
               End;
               STEP_VERSION       :
               Begin
                    nVersion := GetInteger(sLine, 1);
                    If bDebug Then AddLineToConsole( Format('Version : %d', [nVersion]) );
               End;
               STEP_BRICKDENSITY  :
               Begin
                    nBrickDensity := GetInteger(sLine, 1);
                    If bDebug Then AddLineToConsole( Format('Brick density :  %d', [nBrickDensity]) );
               End;
               STEP_BLOCK         :
               Begin
                    nY := 1 + GetInteger(sLine, 1);
                    sData := GetString(sLine, 2);
                    For nX := 1 To Length(sData) Do Begin
                        Case sData[nX] Of
                             '#'         : aBlock[nX,nY] := BLOCK_SOLID;
                             ':'         : aBlock[nX,nY] := BLOCK_BRICK;
                             '.'         : aBlock[nX,nY] := BLOCK_BLANK;
                             Else          aBlock[nX,nY] := BLOCK_SOLID;
                        End;
                    End;
               End;
               STEP_SPAWN         :
               Begin
                    nSpawn += 1;
                    aSpawn[nSpawn] := CSpawn.Create( GetInteger(sLine, 2),
                                                     GetInteger(sLine, 3),
                                                     GetInteger(sLine, 1),
                                                     GetInteger(sLine, 4),
                                                     GetSingle(sLine, 5) );
                    CheckSpawn( aSpawn[nSpawn].X, aSpawn[nSpawn].Y );
                    If bDebug Then AddLineToConsole( Format( 'Spawn point : Player %d ; Team %d ; X %d ; Y %d ; Delay %f',
                                                   [aSpawn[nSpawn].Color, aSpawn[nSpawn].Team, aSpawn[nSpawn].X, aSpawn[nSpawn].Y, aSpawn[nSpawn].Delay] ) );
               End;
               STEP_POWERUP       :
               Begin
                    nPowerUp += 1;
                    aPowerUp[nPowerUp] := CPowerUp.Create( GetInteger(sLine, 1),
                                                           GetInteger(sLine, 2),
                                                           GetBoolean(sLine, 3),
                                                           GetInteger(sLine, 4),
                                                           GetBoolean(sLine, 5) );
                    If bDebug Then AddLineToConsole( Format( 'PowerUp : Code %d ; InitQuantity %d ; GameQuantity %d ; Forbidden %b',
                                                   [aPowerUp[nPowerUp].Code, aPowerUp[nPowerUp].InitQuantity, aPowerUp[nPowerUp].GameQuantity, aPowerUp[nPowerUp].Forbidden] ) );
               End;
          End;
     End;

     Close( ioLine );

     nBlankCount := 0;
     nBrickCount := 0;
     nSolidCount := 0;
     For nY := 1 To GRIDHEIGHT Do Begin
         sLine := '';
         For nX := 1 To GRIDWIDTH Do Begin
             Case aBlock[nX,nY] Of
                  BLOCK_SOLID :
                  Begin
                       nSolidCount += 1;
                       sLine += 'S';
                  End;
                  BLOCK_BRICK :
                  Begin
                       nBrickCount += 1;
                       sLine += 'B';
                  End;
                  BLOCK_BLANK :
                  Begin
                       nBlankCount += 1;
                       sLine += ' ';
                  End;
             End;
         End;
         If bDebug Then AddLineToConsole( sLine );
     End;
End;

Function CScheme.Block ( x, y : Integer ) : Integer ;
Begin
     Block := aBlock[x,y];
End;

Function CScheme.Spawn ( id : Integer ) : CSpawn ;
Var i : Integer;
Begin
     For i := 1 To SPAWNCOUNT Do
     Begin
          If aSpawn[i] <> NIL Then
             If aSpawn[i].Color = id Then Spawn := aSpawn[i];
     End;
End;

Function CScheme.PowerUp ( id : Integer ) : CPowerUp ;
Var i : Integer;
Begin
     For i := 1 To POWERUPCOUNT Do
     Begin
          If aPowerUp[i] <> NIL Then
             If aPowerUp[i].Code = id Then PowerUp := aPowerUp[i];
     End;
     PowerUp := aPowerUp[id];
End;


End.
