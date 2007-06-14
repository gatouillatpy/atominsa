Unit UMap;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UForm;

Type

{ CMap}

CMap = Class

          Private
                 sName         : String                                         ;
                 nVersion      : Integer                                        ;

                 sPath         : String                                         ;

                 sSolidMesh    : String                                        	;
                 sBrickMesh    : String                                        	;

          Public
                Constructor Create ( sFile : String ) ;

                Property Path : String Read sPath ;

                Property Name : String Read sName ;
                Property Version : Integer Read nVersion ;

                Property SolidMesh : String Read sSolidMesh ;
                Property BrickMesh : String Read sBrickMesh ;

End;



Implementation

Const STEP_NONE          = 0;
Const STEP_COMMENT       = 1;
Const STEP_NAME          = 2;
Const STEP_VERSION       = 3;
Const STEP_SOLIDMESH	 = 4;
Const STEP_BRICKMESH     = 5;

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
          If (sCommand[i] = '-') And (sCommand[i+1] = 'S') Then nStep := STEP_SOLIDMESH;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'B') Then nStep := STEP_BRICKMESH;

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

{ CMap }

Constructor CMap.Create ( sFile : String ) ;
Var ioLine : TEXT;
    sLine : String;
    i : Integer;
Begin
     Window.Memo.Lines.Add( 'Loading Map ' + sFile );
     
     sName := '*UNKNOWN*';
	 
     sPath := sFile;
     sFile := PATH_MAP + sFile;

     sSolidMesh := '*UNKNOWN*';
     sBrickMesh := '*UNKNOWN*';

     Assign( ioLine, sFile );
     Reset( ioLine );

     While EOF(ioLine) = False Do
     Begin
          ReadLn( ioLine, sLine );
          Case GetStep(sLine) Of
               STEP_NAME          :
               Begin
                    sName := GetString(sLine, 1);
                    AddLineToConsole( 'Name : ' + sName );
               End;
               STEP_VERSION       :
               Begin
                    nVersion := GetInteger(sLine, 1);
                    AddLineToConsole( Format('Version : %d', [nVersion]) );
               End;
               STEP_SOLIDMESH     :
               Begin
                    sSolidMesh := GetString(sLine, 1);
                    AddLineToConsole( 'Solid mesh data : ' + sSolidMesh );
               End;
               STEP_BRICKMESH     :
               Begin
                    sBrickMesh := GetString(sLine, 1);
                    AddLineToConsole( 'Brick mesh data : ' + sBrickMesh );
               End;
          End;
     End;

     Close( ioLine );
End;



End.
