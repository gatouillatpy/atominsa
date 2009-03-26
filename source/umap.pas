Unit UMap;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UForm;

{ CMap}

Type

CMap = Class

          Private
                 sName         : String                                         ;
                 nVersion      : Integer                                        ;

                 sPath         : String                                         ;

                 sSolidMesh    : String                                        	;
                 sBrickMesh    : String                                        	;
                 sPlaneMesh    : String                                        	;

                 sSolidTexture    : String                                      ;
                 sBrickTexture    : String                                      ;
                 sPlaneTexture    : String                                      ;

                 sSkyboxBottom    : String                                      ;
                 sSkyboxTop       : String                                      ;
                 sSkyboxFront     : String                                      ;
                 sSkyboxBack      : String                                      ;
                 sSkyboxLeft      : String                                      ;
                 sSkyboxRight     : String                                      ;

          Public
                Constructor Create ( sFile : String ; bDebug : Boolean ) ;

                Property Path : String Read sPath ;

                Property Name : String Read sName ;
                Property Version : Integer Read nVersion ;

                Property SolidMesh : String Read sSolidMesh ;
                Property BrickMesh : String Read sBrickMesh ;
                Property PlaneMesh : String Read sPlaneMesh ;

                Property SolidTexture : String Read sSolidTexture ;
                Property BrickTexture : String Read sBrickTexture ;
                Property PlaneTexture : String Read sPlaneTexture ;

                Property SkyboxBottom : String Read sSkyboxBottom ;
                Property SkyboxTop    : String Read sSkyboxTop ;
                Property SkyboxFront  : String Read sSkyboxFront ;
                Property SkyboxBack   : String Read sSkyboxBack ;
                Property SkyboxLeft   : String Read sSkyboxLeft ;
                Property SkyboxRight  : String Read sSkyboxRight ;

                
End;



Implementation

Const STEP_NONE          = 0;
Const STEP_COMMENT       = 1;
Const STEP_NAME          = 2;
Const STEP_VERSION       = 3;
Const STEP_MESH	         = 4;
Const STEP_TEXTURE       = 5;
Const STEP_SKYBOX        = 6;

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
          If (sCommand[i] = '-') And (sCommand[i+1] = 'T') Then nStep := STEP_TEXTURE;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'S') Then nStep := STEP_SKYBOX;

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

Constructor CMap.Create ( sFile : String ; bDebug : Boolean ) ;
Var ioLine : TEXT;
    sLine : String;
Begin
     Window.Memo.Lines.Add( 'Loading map ' + sFile );
     
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
               STEP_NAME :
               Begin
                    sName := GetString(sLine, 1);
                    If bDebug Then AddLineToConsole( 'Name : ' + sName );
               End;
               STEP_VERSION :
               Begin
                    nVersion := GetInteger(sLine, 1);
                    If bDebug Then AddLineToConsole( Format('Version : %d', [nVersion]) );
               End;
               STEP_MESH :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'solid' Then Begin
                       sSolidMesh := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Solid mesh : ' + sSolidMesh );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'brick' Then Begin
                       sBrickMesh := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Brick mesh : ' + sBrickMesh );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'plane' Then Begin
                       sPlaneMesh := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Plane mesh : ' + sPlaneMesh );
                    End;
               End;
               STEP_TEXTURE :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'solid' Then Begin
                       sSolidTexture := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Solid texture : ' + sSolidTexture );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'brick' Then Begin
                       sBrickTexture := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Brick texture : ' + sBrickTexture );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'plane' Then Begin
                       sPlaneTexture := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Plane texture : ' + sPlaneTexture );
                    End;
               End;
               STEP_SKYBOX :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'bottom' Then Begin
                       sSkyboxBottom := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Skybox bottom : ' + sSkyboxBottom );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'top' Then Begin
                       sSkyboxTop := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Skybox top : ' + sSkyboxTop );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'front' Then Begin
                       sSkyboxFront := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Skybox front : ' + sSkyboxFront );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'back' Then Begin
                       sSkyboxBack := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Skybox back : ' + sSkyboxBack );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'left' Then Begin
                       sSkyboxLeft := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Skybox left : ' + sSkyboxLeft );
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'right' Then Begin
                       sSkyboxRight := GetString(sLine, 2);
                       If bDebug Then AddLineToConsole( 'Skybox right : ' + sSkyboxRight );
                    End;
               End;
          End;
     End;

     Close( ioLine );
End;



End.
