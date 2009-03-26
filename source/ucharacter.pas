Unit UCharacter;

{$mode objfpc}{$H+}



Interface



Uses Classes, SysUtils, UUtils, UForm;

Type

{ CCharacter}

StringArray8 = Array [1..8] Of String;

CCharacter = Class

          Private
                 sName         : String                                         ;
                 nVersion      : Integer                                        ;
                 
                 sPath         : String                                         ;

                 sPlayerMesh   : String                                        	;
                 sPlayerAnim   : String                                        	;
                 aPlayerSkin   : StringArray8                            	;

                 sBombMesh     : String                                        	;
                 sBombSkin     : String                       	                ;

                 sFlameTexture : String                       	                ;
                 
          Public
                Constructor Create ( sFile : String ; bDebug : Boolean ) ;

                Property Name : String Read sName ;
                Property Version : Integer Read nVersion ;
                
                Property Path : String Read sPath ;

                Property PlayerMesh : String Read sPlayerMesh ;
                Property PlayerAnim : String Read sPlayerAnim ;
                Property PlayerSkin : StringArray8 Read aPlayerSkin ;

                Property BombMesh : String Read sBombMesh ;
                Property BombSkin : String Read sBombSkin ;
                
                Property FlameTexture : String Read sFlameTexture ;

End;



Implementation



Const STEP_NONE          = 0;
Const STEP_COMMENT       = 1;
Const STEP_NAME          = 2;
Const STEP_VERSION       = 3;
Const STEP_MESH          = 4;
Const STEP_ANIM          = 5;
Const STEP_TEXTURE       = 6;
Const STEP_SOUND         = 7;

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
          If (sCommand[i] = '-') And (sCommand[i+1] = 'M') Then nStep := STEP_MESH;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'A') Then nStep := STEP_ANIM;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'T') Then nStep := STEP_TEXTURE;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'S') Then nStep := STEP_SOUND;

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

{ CCharacter }

Constructor CCharacter.Create ( sFile : String ; bDebug : Boolean ) ;
Var ioLine : TEXT;
    sLine : String;
    i : Integer;
Begin
     Window.Memo.Lines.Add( 'Loading character ' + sFile );
     
     sName := '*UNKNOWN*';
     
     sPath := sFile;
     sFile := PATH_CHARACTER + sFile;

     sPlayerMesh := '*UNKNOWN*';
     sPlayerAnim := '*UNKNOWN*';
     For i := 1 To 8 Do
         aPlayerSkin[i] := '*UNKNOWN*';

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
               STEP_MESH          :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'player' Then Begin
                       sPlayerMesh := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player mesh : ' + sPlayerMesh );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'bomb' Then Begin
                       sBombMesh := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Bomb mesh : ' + sBombMesh );
                    End;
               End;
               STEP_ANIM          :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'player' Then Begin
                       sPlayerAnim := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player animation : ' + sPlayerAnim );
                    End;
               End;
               STEP_TEXTURE       :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'player1' Then Begin
                       aPlayerSkin[1] := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player 1 skin : ' + aPlayerSkin[1] );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'player2' Then Begin
                       aPlayerSkin[2] := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player 2 skin : ' + aPlayerSkin[1] );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'player3' Then Begin
                       aPlayerSkin[3] := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player 3 skin : ' + aPlayerSkin[1] );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'player4' Then Begin
                       aPlayerSkin[4] := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player 4 skin : ' + aPlayerSkin[1] );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'player5' Then Begin
                       aPlayerSkin[5] := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player 5 skin : ' + aPlayerSkin[1] );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'player6' Then Begin
                       aPlayerSkin[6] := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player 6 skin : ' + aPlayerSkin[1] );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'player7' Then Begin
                       aPlayerSkin[7] := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player 7 skin : ' + aPlayerSkin[1] );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'player8' Then Begin
                       aPlayerSkin[8] := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Player 8 skin : ' + aPlayerSkin[1] );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'bomb' Then Begin
                       sBombSkin := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Bomb skin : ' + sBombSkin );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'flame' Then Begin
                       sFlameTexture := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Flame texture : ' + sFlameTexture );
                    End;
               End;
	  End;
     End;

     Close( ioLine );
End;



End.
