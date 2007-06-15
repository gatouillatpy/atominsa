Unit USetup;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UMap, UScheme, UCharacter, UForm;

Var nVersion : Integer;

Var bIntro : Boolean;

Var nRoundCount : Integer;

Var bDisplayFullscreen : Boolean;
Var nDisplayWidth : Integer;
Var nDisplayHeight : Integer;
Var nDisplayFramerate : Integer;
Var nDisplayRefreshrate : Integer;

Var aSchemeList : Array [0..255] Of CScheme;
Var nSchemeCount : Integer;
Var bSchemeRandom : Boolean;
Var pScheme : CScheme;

Var aMapList : Array [0..255] Of CMap;
Var nMapCount : Integer;
Var bMapRandom : Boolean;
Var pMap : CMap;

Var aCharacterList : Array [0..255] Of CCharacter;
Var nCharacterCount : Integer;
Var pCharacter1 : CCharacter;
Var pCharacter2 : CCharacter;

Var sName1 : String;
Var sName2 : String;

Var nKey1Primary : Integer;
Var nKey1Secondary : Integer;
Var nKey1MoveUp : Integer;
Var nKey1MoveDown : Integer;
Var nKey1MoveLeft : Integer;
Var nKey1MoveRight : Integer;

Var nKey2Primary : Integer;
Var nKey2Secondary : Integer;
Var nKey2MoveUp : Integer;
Var nKey2MoveDown : Integer;
Var nKey2MoveLeft : Integer;
Var nKey2MoveRight : Integer;

Procedure ReadSettings ( sFile : String ) ;
Procedure WriteSettings ( sFile : String ) ;



Implementation

Const STEP_NONE            = 0;
Const STEP_COMMENT         = 1;
Const STEP_VERSION         = 2;
Const STEP_PACKAGE         = 3;
Const STEP_MAP             = 4;
Const STEP_SCHEME          = 5;
Const STEP_PLAYERCHARACTER = 6;
Const STEP_PLAYERNAME      = 7;
Const STEP_KEY             = 8;
Const STEP_INTRO           = 9;

Function GetStep ( sCommand : String ) : Integer ;
Var i : Integer;
    nStep : Integer;
Begin
     nStep := STEP_NONE;

     For i := 1 To Length(sCommand) Do
     Begin
          If (sCommand[i] = ';') Then nStep := STEP_COMMENT;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'N') Then nStep := STEP_PLAYERNAME;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'V') Then nStep := STEP_VERSION;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'P') Then nStep := STEP_PACKAGE;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'S') Then nStep := STEP_SCHEME;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'C') Then nStep := STEP_PLAYERCHARACTER;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'K') Then nStep := STEP_KEY;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'M') Then nStep := STEP_MAP;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'I') Then nStep := STEP_INTRO;

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



Procedure ReadSettings ( sFile : String ) ;
Var ioLine : TEXT;
    sLine : String;
    sData : String;
    i, k : Integer;
Begin
     Window.Memo.Lines.Add( 'Reading ' + sFile );
     
     For i := 0 To 255 Do Begin
         aSchemeList[i] := NIL;
         aMapList[i] := NIL;
         aCharacterList[i] := NIL;
     End;

     bIntro := True;
     
     bDisplayFullscreen := False;
     nDisplayWidth := 640;
     nDisplayHeight := 480;
     nDisplayFramerate := 60;
     nDisplayRefreshrate := 85;

     nRoundCount := 3;

     bSchemeRandom := False;
     pScheme := NIL;
     
     bMapRandom := False;
     pMap := NIL;
     
     pCharacter1 := NIL;
     pCharacter2 := NIL;

     sName1 := 'Player1';
     sName2 := 'Player2';

     nKey1Primary := 108;
     nKey1Secondary := 1212; // DELETE KEY ?
     nKey1MoveUp := 101;
     nKey1MoveDown := 103;
     nKey1MoveLeft := 100;
     nKey1MoveRight := 102;

     nKey2Primary := 1212; // B KEY ?
     nKey2Secondary := 1212; // N KEY ?
     nKey2MoveUp := 90;
     nKey2MoveDown := 83;
     nKey2MoveLeft := 81;
     nKey2MoveRight := 68;

     Assign( ioLine, sFile );
     Reset( ioLine );

     While EOF(ioLine) = False Do
     Begin
          ReadLn( ioLine, sLine );
          Case GetStep(sLine) Of
               STEP_PLAYERNAME :
               Begin
                    If GetInteger(sLine, 1) = 1 Then Begin
                       sName1 := GetString(sLine, 2);
                       AddLineToConsole( 'Player 1 Name : ' + sName1 );
                    End;
                    If GetInteger(sLine, 1) = 2 Then Begin
                       sName2 := GetString(sLine, 2);
                       AddLineToConsole( 'Player 2 Name : ' + sName2 );
                    End;
               End;
               STEP_VERSION :
               Begin
                    nVersion := GetInteger(sLine, 1);
                    AddLineToConsole( Format('Version : %d', [nVersion]) );
               End;
               STEP_PLAYERCHARACTER :
               Begin
                    If GetInteger(sLine, 1) = 1 Then Begin
                       k := GetInteger(sLine, 2);
                       If aCharacterList[k] <> NIL Then Begin
                          pCharacter1 := aCharacterList[k];
                          AddLineToConsole( 'Player 1 Character : ' + pCharacter1.Name );
                       End Else
                          AddLineToConsole( 'Player 1 Character : *UNKNOWN*' );
                    End;
                    If GetInteger(sLine, 1) = 2 Then Begin
                       k := GetInteger(sLine, 2);
                       If aCharacterList[k] <> NIL Then Begin
                          pCharacter2 := aCharacterList[k];
                          AddLineToConsole( 'Player 2 Character : ' + pCharacter2.Name );
                       End Else
                          AddLineToConsole( 'Player 2 Character : *UNKNOWN*' );
                    End;
               End;
               STEP_SCHEME :
               Begin
                    k := GetInteger(sLine, 2);
                    If k = -1 Then
                       bSchemeRandom := True
                    Else If aSchemeList[k] <> NIL Then Begin
                       pScheme := aSchemeList[k];
                       AddLineToConsole( 'Scheme : ' + pScheme.Name );
                    End Else
                       AddLineToConsole( 'Scheme : *UNKNOWN*' );
               End;
               STEP_MAP :
               Begin
                    k := GetInteger(sLine, 2);
                    If k = -1 Then
                       bMapRandom := True
                    Else If aMapList[k] <> NIL Then Begin
                       pMap := aMapList[k];
                       AddLineToConsole( 'Map : ' + pMap.Name );
                    End Else
                       AddLineToConsole( 'Map : *UNKNOWN*' );
               End;
               STEP_KEY :
               Begin
                    If GetInteger(sLine, 1) = 1 Then Begin
                       If LowerCase(GetString(sLine, 2)) = 'primary' Then nKey1Primary := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'secondary' Then nKey1Secondary := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveup' Then nKey1MoveUp := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'movedown' Then nKey1MoveDown := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveleft' Then nKey1MoveLeft := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveright' Then nKey1MoveRight := GetInteger(sLine, 3);
                    End;
                    If GetInteger(sLine, 1) = 2 Then Begin
                       If LowerCase(GetString(sLine, 2)) = 'primary' Then nKey2Primary := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'secondary' Then nKey2Secondary := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveup' Then nKey2MoveUp := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'movedown' Then nKey2MoveDown := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveleft' Then nKey2MoveLeft := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveright' Then nKey2MoveRight := GetInteger(sLine, 3);
                    End;
               End;
               STEP_PACKAGE :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'map' Then Begin
                       k := GetInteger(sLine, 2);
                       aMapList[k] := CMap.Create(GetString(sLine, 3));
                       nMapCount += 1;
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'scheme' Then Begin
                       k := GetInteger(sLine, 2);
                       aSchemeList[k] := CScheme.Create(GetString(sLine, 3));
                       nSchemeCount += 1;
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'character' Then Begin
                       k := GetInteger(sLine, 2);
                       aCharacterList[k] := CCharacter.Create(GetString(sLine, 3));
                       nCharacterCount += 1;
                    End;
               End;
               STEP_INTRO :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'true' Then bIntro := True;
                    If LowerCase(GetString(sLine, 1)) = 'false' Then bIntro := False;
               End;
          End;
     End;

     Close( ioLine );
End;



Procedure WriteSettings ( sFile : String ) ;
Var ioLine : TEXT;
    i : Integer;
    s : String;
Begin
     Assign( ioLine, sFile );
     Rewrite( ioLine );

     WriteLn( ioLine );
     WriteLn( ioLine , '; NOTE! This is an Atominsa Configuration File.' );
     WriteLn( ioLine , '; Modify at your own risk. It is machine-generated and updated.' );
     WriteLn( ioLine );
     WriteLn( ioLine );

     WriteLn( ioLine , '; version control number' );
     WriteLn( ioLine , '-V,2');

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of installed maps (index, file)' );

     For i := 0 To nMapCount - 1 Do
         WriteLn( ioLine , '-P,map,' + IntToStr(i) + ',' + aMapList[i].Path );

     WriteLn( ioLine );
     WriteLn( ioLine , '; index of the current map (-1 for random)' );

     //recuperation du n° correspondant a pMap
     i := -1;
     Repeat
           i += 1;
     Until ( pMap = aMapList[i] ) Or ( i > 255 );
     If ( i > 255 ) Or bMapRandom Then s := '-1' Else s := IntToStr(i);

     WriteLn( ioLine , '-M,' + s );

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of installed schemes (index, file)' );

     For i := 0 To nSchemeCount - 1 Do
         WriteLn( ioLine , '-P,scheme,' + IntToStr(i) + ',' + aSchemeList[i].Path );

     WriteLn( ioLine );
     WriteLn( ioLine , '; index of the current scheme (-1 for random)' );

     //recuperation du n° correspondant a pScheme
     i:=-1;
     Repeat
           i += 1;
     Until ( pScheme = aSchemeList[i] ) Or ( i > 255 );
     If ( i > 255 ) Or bSchemeRandom Then s := '-1' Else s := IntToStr(i);

     WriteLn( ioLine , '-S,' + s );

     WriteLn( ioLine );
     WriteLn( ioLine , '; name of the first and second players (player, name)' );
     WriteLn( ioLine , '-N,1,' + sName1 );
     WriteLn( ioLine , '-N,2,' + sName2 );

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of installed characters (index, file, name)' );

     For i := 0 To nSchemeCount - 1 Do
         WriteLn( ioLine , '-P,character,' + IntToStr(i) + ',' + aCharacterList[i].Path );

     WriteLn( ioLine );
     WriteLn( ioLine , '; character index of the first and second players (player, index)' );

     //recuperation du n° correspondant a pCharacter1
     i := -1;
     Repeat
           i += 1;
     Until ( pCharacter1 = aCharacterList[i] ) Or ( i > 255 );
     If ( i > 255 ) Then s := '-1' Else s := IntToStr(i);

     WriteLn( ioLine , '-C,1,' + s );

     //recuperation du n° correspondant a pCharacter2
     i := -1;
     Repeat
           i += 1;
     Until ( pCharacter2 = aCharacterList[i] ) Or ( i > 255 );
     If ( i > 255 ) Then s := '-1' Else s := IntToStr(i);

     WriteLn( ioLine , '-C,2,' + s );

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of binded keys' );
     WriteLn( ioLine , '-K,1,primary,' + IntToStr(nKey1Primary) );
     WriteLn( ioLine , '-K,1,secondary,' + IntToStr(nKey1Secondary) );
     WriteLn( ioLine , '-K,1,moveup,' + IntToStr(nKey1MoveUp) );
     WriteLn( ioLine , '-K,1,movedown,' + IntToStr(nKey1MoveDown) );
     WriteLn( ioLine , '-K,1,moveleft,' + IntToStr(nKey1MoveLeft) );
     WriteLn( ioLine , '-K,1,moveright,' + IntToStr(nKey1MoveRight) );

     WriteLn( ioLine , '-K,2,primary,' + IntToStr(nKey2Primary) );
     WriteLn( ioLine , '-K,2,secondary,' + IntToStr(nKey2Secondary) );
     WriteLn( ioLine , '-K,2,moveup,' + IntToStr(nKey2MoveUp) );
     WriteLn( ioLine , '-K,2,movedown,' + IntToStr(nKey2MoveDown) );
     WriteLn( ioLine , '-K,2,moveleft,' + IntToStr(nKey2MoveLeft) );
     WriteLn( ioLine , '-K,2,moveright,' + IntToStr(nKey2MoveRight) );

     WriteLn( ioLine );
     WriteLn( ioLine , '; is the intro enabled ?' );
     If bIntro Then WriteLn( ioLine , '-I,true' ) Else WriteLn( ioLine , '-I,false' );

     Close(ioLine);
End;



End.
