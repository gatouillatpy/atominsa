Unit UCore;

{$mode objfpc}{$H+}
{$ASMMODE INTEL}

Interface

Uses Classes, SysUtils, LazJPEG, Math, Graphics, IntfGraphics,
     gl, glu, glut, glext,
     fmod, fmodtypes, fmoderrors,
     lnet,
     UForm, UUtils, USetup;



Const HEADER_CONNECT           = 1001;
Const HEADER_DISCONNECT        = 1002;

Const HEADER_MESSAGE           = 1101;

Const HEADER_LIST_CLIENT       = 1201;
Const HEADER_LIST_PLAYER       = 1202;

Const HEADER_LOCK              = 1301;
Const HEADER_UNLOCK            = 1302;
Const HEADER_UPDATE            = 1303;
Const HEADER_SETUP             = 1304;
Const HEADER_FIGHT             = 1305;
Const HEADER_ROUND             = 1306;
Const HEADER_PINGREQ           = 1307;
Const HEADER_PINGRES           = 1308;
Const HEADER_PINGARY           = 1309;
Const HEADER_WAIT              = 1310;

Const HEADER_MOVEUP            = 1401;
Const HEADER_MOVEDOWN          = 1402;
Const HEADER_MOVELEFT          = 1403;
Const HEADER_MOVERIGHT         = 1404;
Const HEADER_ACTION0           = 1405;
Const HEADER_ACTION1           = 1406;
Const HEADER_MOVEBOMB          = 1407;
Const HEADER_EXPLOSE           = 1408;

Const HEADER_BOMBERMAN         = 1501;
Const HEADER_BOMB              = 1502;

Const HEADER_DEAD              = 1601;



Type LPPacketItem = ^PacketItem;
     PacketItem = RECORD
                      index : DWord;
                      header : Integer;
                      data : String;
                      next : LPPacketItem;
                  END;



Const KEY_UP = -GLUT_KEY_UP;
      KEY_DOWN = -GLUT_KEY_DOWN;
      KEY_LEFT = -GLUT_KEY_LEFT;
      KEY_RIGHT = -GLUT_KEY_RIGHT;
      KEY_F10 = -GLUT_KEY_F10;
      KEY_F11 = -GLUT_KEY_F11;

Const KEY_TAB = 9;
      KEY_ESC = 27;
      KEY_ENTER = 13;
      KEY_SQUARE = 178;
      KEY_N = 110;
      KEY_Y = 121;



Const EFFECT_NONE     = 0;
Const EFFECT_TERMINAL = 1;



Const FONT_NORMAL    = 1;
Const FONT_BOLD      = 2;
Const FONT_HELVETICA = 3;



Const BUTTON_LEFT    = 1;
Const BUTTON_RIGHT   = 2;
Const BUTTON_MIDDLE  = 3;



Type LPOGLPolygon = ^OGLPolygon;
     LPOGLVertex = ^OGLVertex;
     OGLPolygon = RECORD
                        id0 : LongInt;
                        id1 : LongInt;
                        id2 : LongInt;
                  END;
     OGLVertex = RECORD
                       x : Single;
                       y : Single;
                       z : Single;
                       nx : Single;
                       ny : Single;
                       nz : Single;
                       r : Single;
                       g : Single;
                       b : Single;
                       tu : Single;
                       tv : Single;
                       id : LongInt;
                 END;



Type GLVector = RECORD
                      x : GLFloat;
                      y : GLFloat;
                      z : GLFloat;
                END;

     GLColor = RECORD
                     r : GLFloat;
                     g : GLFloat;
                     b : GLFloat;
               END;

     GLPoint = RECORD
                      u : GLFloat;
                      v : GLFloat;
               END;

     GLIndex = RECORD
                     id0 : GLUInt;
                     id1 : GLUInt;
                     id2 : GLUInt;
               END;
               


Type LPOGLMesh = ^OGLMesh;
     OGLMesh = RECORD
                      PolygonCount : LongInt;
                      PolygonData : Array Of LPOGLPolygon;
                      VertexCount : LongInt;
                      VertexData : Array Of LPOGLVertex;
                      IndexArray : Array Of GLIndex;
                      VectorArray : Array Of GLVector;
                      NormalArray : Array Of GLVector;
                      ColorArray : Array Of GLColor;
                      TextureArray : Array Of GLPoint;
                      VectorID : GLUInt;
                      NormalID : GLUInt;
                      ColorID : GLUInt;
                      TextureID : GLUInt;
                END;

                

Type LPOGLAction = ^OGLAction;
     LPOGLFrame = ^OGLFrame;
     LPOGLAnimation = ^OGLAnimation;
     OGLAction = RECORD
                        framestart : Smallint;
                        framecount : Smallint;
                  END;
     OGLFrame = RECORD
                      Time : LongInt;
                      VectorArray : Array Of GLVector;
                 END;
     OGLAnimation = RECORD
                      Mesh : LPOGLMesh;
                      ActionCount : LongInt;
                      ActionArray : Array Of OGLAction;
                      FrameCount : LongInt;
                      FrameArray : Array Of OGLFrame;
                      VectorArray : Array Of GLVector;
                      VectorID : GLUInt;
                 END;



Type LPOGLTexture = ^OGLTexture;
     OGLTexture = RECORD
			Width : Integer;
			Height : Integer;
			Data : Array Of GLUByte;
                        ID : GLUInt;
                  END;
				

				
Type GameCallback = Procedure () ; cdecl;
     KeyCallbackStd = Procedure () ; cdecl;
     KeyCallbackObj = Procedure ( fTime : Single ) Of Object ; cdecl;
     ButtonCallback = Procedure () ; cdecl;
     TimerCallback = Procedure () Of Object ; cdecl;



Procedure InitDataStack () ;
Procedure FreeDataStack () ;
Procedure ReloadDataStack () ;

Procedure AddItem( nData : Integer ; nIndex : Integer ; pItem : Pointer ; sPath : String ) ;
Function FindItem( nData : Integer ; nIndex : Integer ) : Pointer ;
Function FindItemByPath( nData : Integer ; sPath : String ) : Pointer ;
Procedure DelItem( nData : Integer ; nIndex : Integer ) ;

Function AddTexture ( sFile : String ; nIndex : LongInt ) : LPOGLTexture;
Procedure DelTexture ( nIndex : LongInt ) ;
Procedure SetTexture( nStage : Integer ; nIndex : LongInt ) ;
Procedure FreeTexture ( pTexture : LPOGLTexture ) ;

Function AddMesh ( sFile : String ; nIndex : LongInt ) : LPOGLMesh ;
Procedure DelMesh ( nIndex : LongInt ) ;
Procedure DrawMesh ( nIndex : LongInt ; t : Boolean ) ;
Procedure FreeMesh ( pMesh : LPOGLMesh ) ;

Function AddAnimation ( sFile : String ; nIndex : LongInt ; nMeshIndex : LongInt ) : LPOGLAnimation ;
Procedure DelAnimation ( nIndex : LongInt ) ;
Procedure DrawAnimation ( nIndex : LongInt ; t : Boolean ; nAction : LongInt ) ;
Procedure FreeAnimation ( pAnimation : LPOGLAnimation ) ;

Procedure Clear ( r, g, b, a : Single ) ;

Procedure DrawText ( x, y : Single ; r, g, b : Single ; nFont : Integer ; sText : String ) ;

Procedure DrawImage ( x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;
Procedure DrawSprite ( u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;

Procedure DrawSkybox ( r, g, b, a : Single ; nSkybox : Integer ) ;

Procedure DrawChar ( c : Char ; p : Boolean ; x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ; nCharsetStandard : Integer ; nCharsetExtended : Integer ) ;

Procedure SetProjectionMatrix ( fFOV : Single ; fRatio : Single ; fNearPlane, fFarPlane : Single ) ;
Procedure SetCameraMatrix ( ex, ey, ez, cx, cy, cz, upx, upy, upz : Single ) ;
Procedure PushObjectMatrix ( tx, ty, tz, sx, sy, sz, rx, ry, rz : Single ) ;
Procedure PopObjectMatrix () ;

Procedure SetString ( id : Integer ; s : String ; t1, t2, t3 : Single ) ;
Procedure DrawString ( id : Integer ; x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ; nCharsetStandard : Integer ; nCharsetExtended : Integer ; nEffect : Integer ) ;

Procedure PushBillboardMatrix( camX, camY, camZ, objPosX, objPosY, objPosZ : Single );

Procedure EnableLighting() ;
Procedure DisableLighting() ;
Procedure SetLight( k : Integer ; x, y, z : Single ; r, g, b, a : Single ; a0, a1, a2 : Single ; t : Boolean ) ;
Procedure SetMaterial( r, g, b, a : Single ) ;

Procedure PutRenderTexture() ;
Procedure GetRenderTexture() ;
Procedure SetRenderTexture() ;



Procedure InitBox ( s1, s2 : String ) ;
Procedure DrawBox ( x1, y1, x2, y2 : Single ) ;



Function GetTime () : Single ;
Function GetTimeExt () : Double ;
Function GetFPS () : Single ;
Function GetDelta () : Single;

Procedure AddTimer( fTime : Single ; pCallback : TimerCallback ) ;
Procedure CheckTimer () ;
Procedure FreeTimer();



Procedure BindKeyStd ( nKey : Integer ; bDown : boolean; bInstant : Boolean ; pCallback : KeyCallbackStd ) ;
Procedure BindKeyObj ( nKey : Integer ; bDown : boolean; bInstant : Boolean ; pCallback : KeyCallbackObj ) ;
Procedure ExecKey ( nKey : Integer ; bDown : boolean; bInstant : Boolean ; bSpecial : Boolean ) ;

Procedure BindButton ( nButton : Integer ; pCallback : ButtonCallback ) ;

Function KeyToStr( nKey : Integer ) : String ;

Function GetMouseX() : Integer ;
Function GetMouseY() : Integer ;
Function GetMouseDX() : Single ;
Function GetMouseDY() : Single ;

Procedure ClearInput () ;

Function CheckKey() : Char ;

Function GetKey( nKey : Integer ) : Boolean ;
Function GetKeyS( nKey : Integer ) : Boolean ;



Procedure InitFMod () ;
Procedure ExitFMod () ;

Procedure AddSound ( sFile : String ; nIndex : LongInt ) ;
Procedure DelSound ( nIndex : LongInt ) ;
Procedure AddMusic ( sFile : String ; nIndex : LongInt ) ;
Procedure PlaySound ( nIndex : LongInt ) ;
Procedure PlayMusic ( nIndex : LongInt ) ;
Procedure StopSound ( nIndex : LongInt ) ;
Procedure StopMusic ( nIndex : LongInt ) ;



Function CheckDisplay () : Boolean ;
Procedure SwitchDisplay () ; cdecl;



Procedure InitGlut ( sTitle : String ; pCallback : GameCallback ) ;
Procedure ExecGlut () ;
Procedure ExitGlut () ;



Function GetSquareWidth : Integer;
Function GetSquareHeight : Integer;
Function GetRenderWidth : Integer;
Function GetRenderHeight : Integer;
Function GetWindowWidth : Integer;
Function GetWindowHeight : Integer;



Var BackBuffer : GLUInt;



Var bConnected : Boolean;

Procedure AddPacket ( nIndex : DWord ; nHeader : Integer ; sData : String ) ;
Function GetPacket ( Var nIndex : DWord ; Var nHeader : Integer ; Var sData : String ) : Boolean ;

Procedure Send ( nIndex : DWord ; nHeader : Integer ; sData : String );
Procedure SendEx ( nIndex : DWord ; nHeader : Integer ; sData : String );
Procedure SendTo ( nIndex : DWord ; nHeader : Integer ; sData : String );

Function ServerInit ( Const nPort : Word ) : Boolean ;
Procedure ServerTerminate () ;
Procedure ServerLoop () ;

Function ClientInit ( Const sAddress : String ; Const nPort : Word ) : Boolean ;
Procedure ClientTerminate () ;
Procedure ClientLoop () ;



Var ShaderProgram : GLenum;
Var VertexShader : GLenum;
Var FragmentShader : GLenum;



Implementation

Uses UMulti;



























////////////////////////////////////////////////////////////////////////////////
// FONCTIONS DE GESTION DU RESEAU                                             //
////////////////////////////////////////////////////////////////////////////////



Var aSocket : Array [0..255] Of TLSocket;
    nSocket : Integer;
    
    

Type TLEvents = Class
     Public
           Procedure OnError ( Const sError : String ; tSocket : TLSocket );
           Procedure OnConnect ( tSocket : TLSocket );
           Procedure OnReceive ( tSocket : TLSocket );
           Procedure OnDisconnect( tSocket : TLSocket );
End;

Var pTCP : TLTcp;
Var pEvent: TLEvents;



Var pPacketStack : LPPacketItem = NIL;



Procedure AddPacket ( nIndex : DWord ; nHeader : Integer ; sData : String ) ;
Var pPacketItem : LPPacketItem ;
Begin
     pPacketItem := pPacketStack;
     If pPacketStack = NIL Then Begin
          New( pPacketStack );
          pPacketStack^.index := nIndex;
          pPacketStack^.header := nHeader;
          pPacketStack^.data := sData;
          pPacketStack^.next := NIL;
     End Else Begin
          pPacketItem := pPacketStack;
          While (pPacketItem^.next <> NIL) Do
               pPacketItem := pPacketItem^.next;
          New( pPacketItem^.next );
          pPacketItem := pPacketItem^.next;
          pPacketItem^.index := nIndex;
          pPacketItem^.header := nHeader;
          pPacketItem^.data := sData;
          pPacketItem^.next := NIL;
     End;
End;



Function GetPacket ( Var nIndex : DWord ; Var nHeader : Integer ; Var sData : String ) : Boolean ;
Begin
     If pPacketStack = NIL Then Begin
        GetPacket := False;
     End Else Begin
        nIndex := pPacketStack^.index;
        nHeader := pPacketStack^.header;
        sData := pPacketStack^.data;
        pPacketStack := pPacketStack^.next;
        GetPacket := True;
     End;
End;



Procedure Send ( nIndex : DWord ; nHeader : Integer ; sData : String );
Var k : Integer;
Begin
     If nSocket = -1 Then Begin
        If pTCP.Connected Then pTCP.SendMessage( IntToStr(nIndex) + #30 + IntToStr(nHeader) + #30 + sData + #4 );
     End Else Begin
        For k := 0 To nSocket Do
            If aSocket[k].Connected Then aSocket[k].SendMessage( IntToStr(nIndex) + #30 + IntToStr(nHeader) + #30 + sData + #4 );
     End;
End;

Procedure SendEx ( nIndex : DWord ; nHeader : Integer ; sData : String );
Var k : Integer;
Begin
     If nSocket = -1 Then Begin
        If pTCP.Connected Then pTCP.SendMessage( IntToStr(nIndex) + #30 + IntToStr(nHeader) + #30 + sData + #4 );
     End Else Begin
        For k := 0 To nSocket Do
            If aSocket[k].Connected And (nIndex <> nClientIndex[k+1]) Then
               aSocket[k].SendMessage( IntToStr(nIndex) + #30 + IntToStr(nHeader) + #30 + sData + #4 );
     End;
End;

Procedure SendTo ( nIndex : DWord ; nHeader : Integer ; sData : String );
Var k : Integer;
Begin
     If nSocket = -1 Then Begin
        If pTCP.Connected Then pTCP.SendMessage( IntToStr(nIndex) + #30 + IntToStr(nHeader) + #30 + sData + #4 );
     End Else Begin
        For k := 0 To nSocket Do
            If aSocket[k].Connected And (nIndex = nClientIndex[k+1]) Then
               aSocket[k].SendMessage( IntToStr(nIndex) + #30 + IntToStr(nHeader) + #30 + sData + #4 );
     End;
End;



Function GetMessage ( sData : String ; nMessage : Integer ) : String ;
Var i, j : Integer;
    nCount : Integer;
    sResult : String;
Begin
     nCount := 0;
     sResult := 'NULL';

     j := 1;
     For i := 1 To Length(sData) Do Begin
        If sData[i] = #4 Then Begin
           nCount += 1;
           If nCount = nMessage Then sResult := Copy( sData, j, i - j );
           j := i + 1;
        End;
        If sResult <> 'NULL' Then Break;
     End;

     GetMessage := sResult;
End;



Function GetPart ( sData : String ; nPart : Integer ) : String ;
Var i, j : Integer;
    nCount : Integer;
    sResult : String;
Begin
     nCount := 0;
     sResult := 'NULL';

     j := 1;
     For i := 1 To Length(sData) Do Begin
        If sData[i] = #30 Then Begin
           nCount += 1;
           If nCount = nPart Then sResult := Copy( sData, j, i - j );
           j := i + 1;
        End Else If i = Length(sData) Then Begin
           nCount += 1;
           If nCount = nPart Then sResult := Copy( sData, j, i - j + 1 );
           j := i + 1;
        End;
        If sResult <> 'NULL' Then Break;
     End;

     GetPart := sResult;
End;



Procedure TLEvents.OnConnect ( tSocket : TLSocket ) ;
Begin
     nSocket += 1;
     aSocket[nSocket] := tSocket;

     If bDebug Then AddLineToConsole( tSocket.PeerAddress + ' connected.' );
End;



Procedure TLEvents.OnDisconnect ( tSocket : TLSocket ) ;
Var p, q : Integer;
Begin
     If nSocket > -1 Then Begin
        For p := 0 To nSocket Do
            If aSocket[p] = tSocket Then q := p;
        For p := q To nSocket - 1 Do
            aSocket[p] := aSocket[p+1];
        nSocket -= 1;
     End;
     AddLineToConsole('Connection lost.');
End;



Procedure TLEvents.OnReceive ( tSocket : TLSocket ) ;
Var sBuffer : String;
Var sMessage : String;
    nMessage : Integer;
Var nIndex : DWord;
    nHeader : Integer;
    sData : String;
Begin
     If tSocket.GetMessage( sBuffer ) > 0 Then Begin
        nMessage := 1;
        sMessage := GetMessage( sBuffer, nMessage );
        While sMessage <> 'NULL' Do Begin
           If bDebug Then AddLineToConsole( 'Reception :' );
           nIndex := StrToInt( GetPart( sMessage, 1 ) );
           If bDebug Then AddLineToConsole( '    Index : ' + IntToStr(nIndex) );
           nHeader := StrToInt( GetPart( sMessage, 2 ) );
           If bDebug Then AddLineToConsole( '    Header : ' + IntToStr(nHeader) );
           sData := GetPart( sMessage, 3 );
           If bDebug Then AddLineToConsole( '    Data : ' + sData );
           AddPacket( nIndex, nHeader, sData );
           nMessage += 1;
           sMessage := GetMessage( sBuffer, nMessage );
        End;
     End;
End;



Procedure TLEvents.OnError ( Const sError : String ; tSocket : TLSocket ) ;
Begin
     AddLineToConsole( 'Network error : ' + sError );
End;



Function ClientInit ( Const sAddress : String ; Const nPort : Word ) : Boolean ;
Var t : Single;
Begin
     nSocket := -1;

     bConnected := False;

     pEvent := TLEvents.Create;
     pTCP := TLTcp.Create( NIL );
     pTCP.OnReceive := @pEvent.OnReceive;
     pTCP.OnDisconnect := @pEvent.OnDisconnect;
     pTCP.OnError := @pEvent.OnError;
     If pTCP.Connect( sAddress, nPort ) Then Begin
        AddLineToConsole('Connecting...');
        t := GetTime;
        Repeat
           pTCP.CallAction;
           Sleep(1);
           If GetTime > t + 10.0 Then Break;
        Until pTCP.Connected;
        If pTCP.Connected Then Begin
           AddStringToConsole('success.');
           ClientInit := True;
        End Else Begin
           AddStringToConsole('failed.');
           ClientInit := False;
        End;
     End Else Begin
        AddLineToConsole('Can''t connect to server.');
        ClientInit := False;
     End;
End;



Procedure ClientTerminate () ;
Begin
     pTCP.Disconnect;
     pTCP.Free;
     pEvent.Free;
     AddLineToConsole('Disconnected.');
End;



Procedure ClientLoop () ;
Begin
     pTCP.Callaction;
End;



Function ServerInit ( Const nPort : Word ) : Boolean;
Begin
     nSocket := -1;
     
     pEvent := TLEvents.Create;
     pTCP := TLTcp.Create( NIL );
     pTCP.OnError := @pEvent.OnError;
     pTCP.OnAccept := @pEvent.OnConnect;
     pTCP.OnReceive := @pEvent.OnReceive;
     pTCP.OnDisconnect := @pEvent.OnDisconnect;
     If pTCP.Listen( nPort ) Then Begin
        AddLineToConsole('Server started.');
        ServerInit := True;
     End Else Begin
        AddLineToConsole('Can''t start server.');
        ServerInit := False;
     End;
End;



Procedure ServerTerminate () ;
Begin
     pTCP.Disconnect;
     pTCP.Free;
     pEvent.Free;
     AddLineToConsole('Disconnected.');
End;



Procedure ServerLoop () ;
Begin
     pTCP.Callaction;
End;





























////////////////////////////////////////////////////////////////////////////////
// FONCTIONS DE GESTION DE LA PILE DE DONNEES                                 //
////////////////////////////////////////////////////////////////////////////////



Const DATA_NONE      = 0;
Const DATA_MESH      = 1;
Const DATA_TEXTURE   = 2;
Const DATA_SOUND     = 3;
Const DATA_MUSIC     = 4;
Const DATA_ANIMATION = 5;



Type LPDataItem = ^DataItem;
     DataItem = RECORD
                      count : LongInt;
                      index : LongInt;
                      data : Integer;
                      item : Pointer;
                      path : String;
                      next : LPDataItem;
                END;
Var pDataStack : LPDataItem = NIL;



////////////////////////////////////////////////////////////////////////////////
// InitDataStack : Crée le premier élément de la pile de données.             //
////////////////////////////////////////////////////////////////////////////////
Procedure InitDataStack () ;
Begin
     New( pDataStack );
     pDataStack^.count := 0;
     pDataStack^.index := 0;
     pDataStack^.data := DATA_NONE;
     pDataStack^.item := NIL;
     pDataStack^.path := '';
     pDataStack^.next := NIL;
End;



////////////////////////////////////////////////////////////////////////////////
// FreeDataStack : Vide la pile de données et libère la mémoire.              //
////////////////////////////////////////////////////////////////////////////////
Procedure FreeDataStack () ;
Var pDataItem : LPDataItem;
    pMesh : LPOGLMesh;
    pTexture : LPOGLTexture;
    pSound : PFSoundSample;
    pMusic : PFMusicModule;
Begin
     While pDataStack <> NIL Do
     Begin
          pDataItem := pDataStack^.next;
          Case pDataStack^.data Of
               DATA_MESH :
               Begin
                    pMesh := pDataStack^.item;
                    If pMesh <> NIL Then FreeMesh( pMesh );
               End;
               DATA_TEXTURE :
               Begin
                    pTexture := pDataStack^.item;
                    If pTexture <> NIL Then FreeTexture( pTexture );
               End;
               DATA_SOUND :
               Begin
                    pSound := pDataStack^.item;
                    If pSound <> NIL Then FSOUND_Sample_Free( pSound );
               End;
               DATA_MUSIC :
               Begin
                    pMusic := pDataStack^.item;
                    If pMusic <> NIL Then FMUSIC_FreeSong( pMusic );
               End;
          End;
          Dispose( pDataStack );
          pDataStack := pDataItem;
     End;
End;



////////////////////////////////////////////////////////////////////////////////
// ReloadDataStack : Recharge les éléments de la pile de données.             //
////////////////////////////////////////////////////////////////////////////////
Procedure ReloadDataStack () ;
Var pDataTemp : LPDataItem;
    pDataItem : LPDataItem;
    pMesh : LPOGLMesh;
    pTexture : LPOGLTexture;
    pSound : PFSoundSample;
    pMusic : PFMusicModule;
Begin
     pDataTemp := pDataStack;

     While pDataTemp <> NIL Do
     Begin
          pDataItem := pDataTemp^.next;
          Case pDataTemp^.data Of
               DATA_MESH :
               Begin
                    pMesh := pDataTemp^.item;
                    If pMesh <> NIL Then FreeMesh( pMesh );
               End;
               DATA_TEXTURE :
               Begin
                    pTexture := pDataTemp^.item;
                    If pTexture <> NIL Then FreeTexture( pTexture );
               End;
               DATA_SOUND :
               Begin
                    pSound := pDataTemp^.item;
                    If pSound <> NIL Then FSOUND_Sample_Free( pSound );
               End;
               DATA_MUSIC :
               Begin
                    pMusic := pDataTemp^.item;
                    If pMusic <> NIL Then FMUSIC_FreeSong( pMusic );
               End;
          End;
          pDataTemp := pDataItem;
     End;

     pDataTemp := pDataStack;

     InitDataStack();

     While pDataTemp <> NIL Do
     Begin
          pDataItem := pDataTemp^.next;
          Case pDataTemp^.data Of
               DATA_MESH :
                    AddMesh( pDataTemp^.path, pDataTemp^.index );
               DATA_TEXTURE :
                    AddTexture( pDataTemp^.path, pDataTemp^.index );
               DATA_SOUND :
                    AddSound( pDataTemp^.path, pDataTemp^.index );
               DATA_MUSIC :
                    AddMusic( pDataTemp^.path, pDataTemp^.index );
          End;
          Dispose( pDataTemp );
          pDataTemp := pDataItem;
     End;
End;



Procedure AddItem( nData : Integer ; nIndex : Integer ; pItem : Pointer ; sPath : String ) ;
Var pDataItem : LPDataItem;
Begin
     pDataItem := pDataStack;
     New( pDataStack );
     pDataStack^.count := pDataItem^.count + 1;
     pDataStack^.index := nIndex;
     pDataStack^.data := nData;
     pDataStack^.item := pItem;
     pDataStack^.path := sPath;
     pDataStack^.next := pDataItem;
End;



Function FindItem( nData : Integer ; nIndex : Integer ) : Pointer ;
Var pDataItem : LPDataItem;
    pItem : Pointer;
Begin
     pDataItem := pDataStack;
     pItem := NIL;
     While pDataItem <> NIL Do Begin
          If (pDataItem^.data = nData) And (pDataItem^.index = nIndex) Then pItem := pDataItem^.item;
          If pItem <> NIL Then Break;
          pDataItem := pDataItem^.next;
     End;
     
     FindItem := pItem;
End;



Function FindItemByPath( nData : Integer ; sPath : String ) : Pointer ;
Var pDataItem : LPDataItem;
    pItem : Pointer;
Begin
     pDataItem := pDataStack;
     pItem := NIL;
     While pDataItem <> NIL Do Begin
          If (pDataItem^.data = nData) And (pDataItem^.path = sPath) Then pItem := pDataItem^.item;
          If pItem <> NIL Then Break;
          pDataItem := pDataItem^.next;
     End;

     FindItemByPath := pItem;
End;



Procedure DelItem( nData : Integer ; nIndex : Integer ) ;
Var pDataItem : LPDataItem;
    pTempItem : LPDataItem;
    pItem : Pointer;
Begin
     pDataItem := pDataStack;
     pTempItem := NIL;
     pItem := NIL;
     While pDataItem <> NIL Do Begin
          If (pDataItem^.data = nData) And (pDataItem^.index = nIndex) Then pItem := pDataItem^.item;
          If pItem <> NIL Then Break;
          pTempItem := pDataItem;
          pDataItem := pDataItem^.next;
     End;

     If pTempItem = NIL Then pDataStack := pDataStack^.next;
     If pDataStack = NIL Then InitDataStack();
     If pTempItem <> NIL Then pTempItem^.next := pDataItem^.next;
     
     Dispose(pDataItem);
End;




























////////////////////////////////////////////////////////////////////////////////
// FONCTIONS DE LA MINUTERIE                                                  //
////////////////////////////////////////////////////////////////////////////////



Type LPTimerItem = ^TimerItem;
     TimerItem = RECORD
                      count : LongInt;
                      time : Single;
                      callback : TimerCallback;
                      next : LPTimerItem;
                END;
Var pTimerStack : LPTimerItem = NIL;



Var nFrame : Integer;
    fTime  : Double;
    nFPS   : Integer;
    fDelta : Double;
    fFrame : Double;



////////////////////////////////////////////////////////////////////////////////
// GetTime : Renvoie le temps passé (en secondes) depuis l'exécution du jeu.  //
////////////////////////////////////////////////////////////////////////////////
Function QueryPerformanceCounter( Var lpPerformanceCount : Int64 ) : Integer ; stdcall; external 'kernel32' name 'QueryPerformanceCounter';
Function QueryPerformanceFrequency( Var lpFrequency : Int64 ) : Integer ; stdcall; external 'kernel32' name 'QueryPerformanceFrequency';

Function GetTime () : Single ;
Begin
     GetTime := glutGet(GLUT_ELAPSED_TIME) * 0.001;
End;

Function GetTimeExt () : Double ;
Var lpPerformanceCount : Int64;
Var lpFrequency : Int64;
Begin
     QueryPerformanceCounter( lpPerformanceCount );
     QueryPerformanceFrequency( lpFrequency );
     GetTimeExt := lpPerformanceCount / lpFrequency;
End;



////////////////////////////////////////////////////////////////////////////////
// GetFPS : Renvoie le framerate basé sur la dernière seconde de rendu.       //
////////////////////////////////////////////////////////////////////////////////
Function GetFPS () : Single ;
Begin
     GetFPS := nFPS;
End;



////////////////////////////////////////////////////////////////////////////////
// GetDelta : Renvoie le temps passé (en secondes) entre les deux dernières   //
//            images rendues.                                                 //
////////////////////////////////////////////////////////////////////////////////
Function GetDelta () : Single ;
Begin
     GetDelta := fDelta;
End;



////////////////////////////////////////////////////////////////////////////////
// AddTimer : Ajoute une callback à la pile de la minuterie et définie un     //
//            délai d'exécution.                                              //
////////////////////////////////////////////////////////////////////////////////
Procedure AddTimer ( fTime : Single ; pCallback : TimerCallback ) ;
Var pTimerItem : LPTimerItem ;
Begin
     If pTimerStack = NIL Then Begin
          New( pTimerStack );
          pTimerStack^.count := 0;
          pTimerStack^.time := GetTime() + fTime;
          pTimerStack^.callback := pCallback;
          pTimerStack^.next := NIL;
     End Else Begin
          pTimerItem := pTimerStack;
          New( pTimerStack );
          pTimerStack^.count := pTimerItem^.count + 1;
          pTimerStack^.time := GetTime() + fTime;
          pTimerStack^.callback := pCallback;
          pTimerStack^.next := pTimerItem;
     End;
End;



////////////////////////////////////////////////////////////////////////////////
// CheckTimer : Vérifie en fonction du temps s'il y a une callback à          //
//              éxecuter.                                                     //
////////////////////////////////////////////////////////////////////////////////
Procedure CheckTimer () ;
Var pTimerItem, pLastItem, pTempItem : LPTimerItem ;
Begin
     pLastItem := NIL;
     pTimerItem := pTimerStack;
     While pTimerItem <> NIL Do
     Begin
          If pTimerItem^.time <= GetTime() Then
          Begin
               pTimerItem^.callback();
               If pLastItem <> NIL Then pLastItem^.next := pTimerItem^.next Else pTimerStack := NIL;
               pTempItem := pTimerItem^.next;
               Dispose( pTimerItem );
               pTimerItem := NIL;
          End;
          If pTimerItem <> NIL Then pLastItem := pTimerItem;
          If pTimerItem <> NIL Then pTimerItem := pTimerItem^.next Else pTimerItem := pTempItem;
     End;
End;



////////////////////////////////////////////////////////////////////////////////
// FreeTimer : Libère la minuterie de toutes ses données.   	              //
////////////////////////////////////////////////////////////////////////////////
Procedure FreeTimer ();
     Procedure FreeTimerItem ( pTimerItem : LPTimerItem ) ;
     Begin
          If pTimerItem <> NIL Then Begin
             FreeTimerItem(pTimerItem^.Next);
             Dispose(pTimerItem);
             pTimerItem := NIL;
          End;
     End;
Begin
     If pTimerStack <> NIL Then Begin
          FreeTimerItem(pTimerStack^.Next);
          Dispose(pTimerStack);
          pTimerStack := NIL;
     End;
End;


























////////////////////////////////////////////////////////////////////////////////
// FONCTIONS DE RENDU                                                         //
////////////////////////////////////////////////////////////////////////////////



Procedure PushBillboardMatrix( camX, camY, camZ, objPosX, objPosY, objPosZ : Single );
Var lookAt : Vector;
    objToCamProj : Vector;
    upAux : Vector;
    objToCam : Vector;
    angleCosine : single;
Begin
     glPushMatrix();
     
     glTranslatef( objPosX, objPosY, objPosZ );

     objToCamProj.x := camX - objPosX;
     objToCamProj.y := 0;
     objToCamProj.z := camZ - objPosZ;

     lookAt.x := 0;
     lookAt.y := 0;
     lookAt.z := 1;

     //glRotatef(-90, 1.0, 0.0, 0.0);
     //glRotatef(-0, 0.0, 0.0, 1.0);
     //glRotatef(-0, 0.0, 1.0, 0.0);

     Normalize(objToCamProj);
     upAux := CrossProduct(lookAt,objToCamProj);
     angleCosine := DotProduct(lookAt,objToCamProj);
     if ((angleCosine < 0.99990) and (angleCosine > -0.9999)) then
        glRotatef( arccos(angleCosine) * RAD2DEG, upAux.x, upAux.y, upAux.z);
     objToCam.x := camX - objPosX;
     objToCam.y := camY - objPosY;
     objToCam.z := camZ - objPosZ;
     Normalize(objToCam);
     angleCosine := DotProduct(objToCamProj,objToCam);
     if ((angleCosine < 0.99990) and (angleCosine > -0.9999)) then
         if (objToCam.y < 0) then
            glRotatef(arccos(angleCosine)*RAD2DEG,1,0,0)
	 else
            glRotatef(arccos(angleCosine)*RAD2DEG,-1,0,0);

     glScalef( 1, 1, 1 );
End;


Procedure PushObjectMatrix ( tx, ty, tz, sx, sy, sz, rx, ry, rz : Single ) ;
Begin
     glPushMatrix();
     glTranslatef( tx, ty, tz );
     glRotatef(-rx, 1.0, 0.0, 0.0);
     glRotatef(-rz, 0.0, 0.0, 1.0);
     glRotatef(-ry, 0.0, 1.0, 0.0);
     glScalef( sx, sy, sz );
End;



Procedure PopObjectMatrix () ;
Begin
     glPopMatrix();
End;



Procedure SetCameraMatrix ( ex, ey, ez, cx, cy, cz, upx, upy, upz : Single ) ;
Begin
     glMatrixMode( GL_MODELVIEW );
     glLoadIdentity();
     gluLookAt( ex, ey, ez, cx, cy, cz, upx, upy, upz );
End;



Procedure SetProjectionMatrix ( fFOV : Single ; fRatio : Single ; fNearPlane, fFarPlane : Single ) ;
Begin
     glMatrixMode( GL_PROJECTION );
     glLoadIdentity();
     gluPerspective( fFOV, fRatio, fNearPlane, fFarPlane );
End;



////////////////////////////////////////////////////////////////////////////////
// AddTexture : Charge une OGLTexture depuis un fichier bitmap, l'ajoute à la //
//              pile de données, puis renvoie son pointeur.                   //
////////////////////////////////////////////////////////////////////////////////
Var w, h : Integer;
    u, v : Single;
    i, j : Integer;
    k, l : Integer;
    p, q : Integer;
Function AddTexture ( sFile : String ; nIndex : LongInt ) : LPOGLTexture; register;
Var pTexture : LPOGLTexture;
    pDataItem : LPDataItem;
    TempIntfImg : TLazIntfImage;
    ImageExt : TJPEGImage;
    sExt : String;
    s : String;
    src : ^Byte;
    dst : ^Byte;
    c : Integer;
    r, g, b : Byte;
Procedure inc();
Begin
     k := 3 * ((p - j) * (q + 1) + i);
     l := 4 * (Round(j * v) * (w + 1) + Round(i * u));
End;
Begin
     // appel au manager de ressources pour éviter de charger une texture déjà chargée
     pTexture := FindItemByPath( DATA_TEXTURE, sFile );
     If pTexture <> NIL Then Begin
        AddLineToConsole( 'Reloading texture ' + sFile + '.' );
        AddItem( DATA_TEXTURE, nIndex, pTexture, sFile );
        AddTexture := pTexture;
        Exit;
     End;

     AddLineToConsole( 'Loading texture ' + sFile + '...' );

     // création du pointeur vers la nouvelle texture
     New( pTexture );

     // charge l'image dans un TImage
     sExt := LowerCase(ExtractFileExt(sFile));
     If sExt = '.bmp' Then Window.Image.Picture.Bitmap.LoadFromFile(sFile);
     If (sExt = '.jpg') Or (sExt = '.jpeg') Then Begin
        ImageExt := TJpegImage.Create;
        ImageExt.LoadFromFile(sFile);
        Window.Image.Picture.Bitmap.Assign(ImageExt);
        ImageExt.Free;
     End;
     
     // récupère l'adresse mémoire des pixels
     TempIntfImg := TLazIntfImage.Create(0,0);
     TempIntfImg.LoadFromBitmap( Window.Image.Picture.Bitmap.Handle, Window.Image.Picture.Bitmap.MaskHandle );
     src := TempIntfImg.PixelData;
  
     // attribution de la taille de la texture
     pTexture^.Width := Window.Image.Picture.Width;
     pTexture^.Height := Window.Image.Picture.Height;
     If (Window.Image.Picture.Width < Round(pow(2,nTexturing))) Or (Window.Image.Picture.Height < Round(pow(2,nTexturing))) Then Begin
        p := Round(pow(2,nTexturing)) - 1;
        q := Round(pow(2,nTexturing)) - 1;
     End Else Begin
        p := Window.Image.Picture.Width - 1;
        q := Window.Image.Picture.Height - 1;
     End;
     w := pTexture^.Width - 1;
     h := pTexture^.Height - 1;
     u := pTexture^.Width / (p + 1);
     v := pTexture^.Height / (q + 1);

     // récupère les pixels du TImage et les attribue à la texture
     SetLength( pTexture^.Data, 3 * (p + 1) * (q + 1) );
     {For j := 0 To pTexture^.Height - 1 Do Begin
         For i := 0 To pTexture^.Width - 1 Do Begin
	     k := 3 * ((pTexture^.Height - 1 - j) * pTexture^.Width + i);
             c := ColorToRGB(Window.Image.Canvas.Pixels[i,j]);
	     pTexture^.Data[k+0] := c;
	     pTexture^.Data[k+1] := c shr 8;
	     pTexture^.Data[k+2] := c shr 16;
	 End;
     End;}
     dst := @pTexture^.Data[0];
     Asm
        push eax
        push ebx
        push ecx
        push edx

        mov j, 0
        @yloop:

              mov i, 0
              @xloop:
                    call inc

                    mov ecx, k
                    add ecx, dst
                    mov edx, l
                    add edx, src
                    add edx, 2
                    mov al, byte ptr [edx]
                    mov r, al;
                    mov byte ptr [ecx], al // composante rouge

                    add ecx, 1
                    sub edx, 1
                    mov al, byte ptr [edx]
                    mov byte ptr [ecx], al // composante verte
                    mov g, al;

                    add ecx, 1
                    sub edx, 1
                    mov al, byte ptr [edx]
                    mov byte ptr [ecx], al // composante bleue
                    mov b, al;

                    add i, 1
                    mov eax, i
                    mov ebx, p
                    cmp eax, ebx
                    jle @xloop
                    
              add j, 1
              mov eax, j
              mov ebx, q
              cmp eax, ebx
              jle @yloop
              
        pop edx
        pop ecx
        pop ebx
        pop eax
     End;
     
     TempIntfImg.Destroy();
     
     // envoie la texture dans la mémoire vidéo
     glEnable( GL_TEXTURE_2D );
     glGenTextures( 1, @pTexture^.ID );
     glBindTexture( GL_TEXTURE_2D, pTexture^.ID );
     glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
     glTexImage2D( GL_TEXTURE_2D, 0, 3, (p + 1), (q + 1), 0, GL_RGB, GL_UNSIGNED_BYTE, @pTexture^.Data[0] );

     // ajout de la texture à la pile de données
     AddItem( DATA_TEXTURE, nIndex, pTexture, sFile );

     AddStringToConsole( Format('OK. (%.0f bytes)', [3.0 * (p + 1) * (q + 1)]) );

     AddTexture := pTexture;
End;



Procedure DelTexture ( nIndex : LongInt ) ;
Var pTexture : LPOGLTexture;
Begin
     // recherche de la texture à sélectionner en fonction de son indice
     pTexture := FindItem( DATA_TEXTURE, nIndex );
     If pTexture = NIL Then Exit;

     // destruction de la texture
     FreeTexture( pTexture );

     // destruction de l'objet dans la pile de données
     DelItem( DATA_TEXTURE, nIndex );
End;



Procedure FreeTexture ( pTexture : LPOGLTexture ) ;
Begin
     glDeleteTextures( 1, @pTexture^.ID );
     Finalize( pTexture^.Data );
     Dispose( pTexture );
End;



////////////////////////////////////////////////////////////////////////////////
// SetTexture : Définie la texture active en fonction de son indice.          //
////////////////////////////////////////////////////////////////////////////////
Procedure SetTexture( nStage : Integer ; nIndex : LongInt ) ;
Var pTexture : LPOGLTexture;
Begin
     If nIndex = 0 Then Begin
        glDisable( GL_TEXTURE_2D );
        Exit;
     End;
     
     // recherche de la texture à sélectionner en fonction de son indice
     pTexture := FindItem( DATA_TEXTURE, nIndex );
     If pTexture = NIL Then Exit;

     // active le texturing
     glEnable( GL_TEXTURE_2D );

     // appelle la texture désirée
     glBindTexture( GL_TEXTURE_2D, pTexture^.ID );

     // définie les techniques de rendu
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
     glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
End;



////////////////////////////////////////////////////////////////////////////////
// AddMesh : Charge un OGLMesh depuis un fichier (*.M12), l'ajoute à la pile  //
//           de données, puis renvoie son pointeur.                           //
////////////////////////////////////////////////////////////////////////////////
Function AddMesh ( sFile : String ; nIndex : LongInt ) : LPOGLMesh ;
Var ioLong : File Of LongInt ; ioPolygon : File Of OGLPolygon ; ioVertex : File Of OGLVertex ;
    pMesh : LPOGLMesh ;
    nSize : LongInt ;
    i, j : LongInt ;
Begin
     j := 0;

     // appel au manager de ressources pour éviter de charger un mesh déjà chargé
     pMesh := FindItemByPath( DATA_MESH, sFile );
     If pMesh <> NIL Then Begin
        AddLineToConsole( 'Reloading mesh ' + sFile + '.' );
        AddItem( DATA_MESH, nIndex, pMesh, sFile );
        AddMesh := pMesh;
        Exit;
     End;

     AddLineToConsole( 'Loading mesh ' + sFile + '...' );

     // création du pointeur vers le nouveau mesh
     New( pMesh );

     // lecture du nombre de polygones
     Assign( ioLong, sFile );
     Reset( ioLong, 4 );
     Seek( ioLong, j );
     Read( ioLong, nSize ); j += 1;
     Close( ioLong );
        
     // allocation de la mémoire pour le tableau de polygones
     pMesh^.PolygonCount := nSize;
     SetLength( pMesh^.PolygonData, nSize );
     SetLength( pMesh^.IndexArray, nSize );

     // lecture de chaque polygone
     Assign( ioPolygon, sFile );
     Reset( ioPolygon, 4 );
     For i := 0 To nSize - 1 Do
     Begin
          Seek( ioPolygon, j );
          New( pMesh^.PolygonData[i] );
          Read( ioPolygon, pMesh^.PolygonData[i]^ ); j += 3;
          pMesh^.IndexArray[i].id0 := pMesh^.PolygonData[i]^.id0;
          pMesh^.IndexArray[i].id1 := pMesh^.PolygonData[i]^.id1;
          pMesh^.IndexArray[i].id2 := pMesh^.PolygonData[i]^.id2;
     End;
     Close( ioPolygon );

     // lecture du nombre de vertices
     Assign( ioLong, sFile );
     Reset( ioLong );
     Seek( ioLong, j ); j += 1;
     Read( ioLong, nSize );
     Close( ioLong );

     // allocation de la mémoire pour le tableau de vertices
     pMesh^.VertexCount := nSize;
     SetLength( pMesh^.VertexData, nSize );
     SetLength( pMesh^.VectorArray, nSize );
     SetLength( pMesh^.NormalArray, nSize );
     SetLength( pMesh^.ColorArray, nSize );
     SetLength( pMesh^.TextureArray, nSize );

     // lecture de chaque vertex
     Assign( ioVertex, sFile );
     Reset( ioVertex, 4 );
     For i := 0 To nSize - 1 Do
     Begin
          Seek( ioVertex, j );
          New( pMesh^.VertexData[i] );
          Read( ioVertex, pMesh^.VertexData[i]^ ); j += 12;
          pMesh^.VectorArray[i].x := pMesh^.VertexData[i]^.x;
          pMesh^.VectorArray[i].y := pMesh^.VertexData[i]^.y;
          pMesh^.VectorArray[i].z := pMesh^.VertexData[i]^.z;
          pMesh^.NormalArray[i].x := pMesh^.VertexData[i]^.nx;
          pMesh^.NormalArray[i].y := pMesh^.VertexData[i]^.ny;
          pMesh^.NormalArray[i].z := pMesh^.VertexData[i]^.nz;
          pMesh^.ColorArray[i].r := pMesh^.VertexData[i]^.r;
          pMesh^.ColorArray[i].g := pMesh^.VertexData[i]^.g;
          pMesh^.ColorArray[i].b := pMesh^.VertexData[i]^.b;
          pMesh^.TextureArray[i].u := pMesh^.VertexData[i]^.tu;
          pMesh^.TextureArray[i].v := 1.0-pMesh^.VertexData[i]^.tv;
     End;
     Close( ioVertex );

     // envoie la géométrie dans la mémoire vidéo
     glGenBuffersARB( 1, @pMesh^.VectorID );
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.VectorID );
     glBufferDataARB( GL_ARRAY_BUFFER_ARB, nSize * 12, @pMesh^.VectorArray[0], GL_STATIC_DRAW_ARB );
     glGenBuffersARB( 1, @pMesh^.NormalID );
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.NormalID );
     glBufferDataARB( GL_ARRAY_BUFFER_ARB, nSize * 12, @pMesh^.NormalArray[0], GL_STATIC_DRAW_ARB );
     glGenBuffersARB( 1, @pMesh^.ColorID );
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.ColorID );
     glBufferDataARB( GL_ARRAY_BUFFER_ARB, nSize * 12, @pMesh^.ColorArray[0], GL_STATIC_DRAW_ARB );
     glGenBuffersARB( 1, @pMesh^.TextureID );
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.TextureID );
     glBufferDataARB( GL_ARRAY_BUFFER_ARB, nSize * 8, @pMesh^.TextureArray[0], GL_STATIC_DRAW_ARB );

     // ajout du mesh à la pile de données
     AddItem( DATA_MESH, nIndex, pMesh, sFile );

     AddStringToConsole( Format('OK. (%d bytes)', [j*4]) );

     AddMesh := pMesh;
End;



////////////////////////////////////////////////////////////////////////////////
// DrawMesh : Procède au rendu d'un OGLMesh en fonction de son indice.        //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawMesh ( nIndex : LongInt ; t : Boolean ) ;
Var pMesh : LPOGLMesh ;
Begin
     // recherche du mesh à afficher en fonction de son indice
     pMesh := FindItem( DATA_MESH, nIndex );
     If pMesh = NIL Then Exit;

     If t Then Begin
        glEnable( GL_BLEND );
        glBlendFunc( GL_SRC_ALPHA, GL_ONE );
     End;

     // affiche l'ensemble des polygones du mesh
     {glBegin(GL_TRIANGLES);
     For i := 0 To pMesh^.PolygonCount - 1 Do
     Begin
         p := pMesh^.IndexArray[i];

         v := pMesh^.VectorArray[p.id0];
         glColor3f(1, 1, 1);
         glVertex3f(v.x, v.y, v.z);

         v := pMesh^.VectorArray[p.id1];
         glColor3f(1, 1, 1);
         glVertex3f(v.x, v.y, v.z);

         v := pMesh^.VectorArray[p.id2];
         glColor3f(1, 1, 1);
         glVertex3f(v.x, v.y, v.z);
     End;
     glEnd;}

     glEnableClientState(GL_VERTEX_ARRAY);
     glEnableClientState(GL_NORMAL_ARRAY);
     glEnableClientState(GL_COLOR_ARRAY);
     glEnableClientState(GL_TEXTURE_COORD_ARRAY);

     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.VectorID );
     glVertexPointer(3, GL_FLOAT, 0, NIL);
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.NormalID );
     glNormalPointer(GL_FLOAT, 0, NIL);
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.ColorID );
     glColorPointer(3, GL_FLOAT, 0, NIL);
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.TextureID );
     glTexCoordPointer(2, GL_FLOAT, 0, NIL);

     glDrawElements(GL_TRIANGLES, pMesh^.PolygonCount * 3, GL_UNSIGNED_INT, @pMesh^.IndexArray[0]);

     glDisableClientState(GL_VERTEX_ARRAY);
     glDisableClientState(GL_NORMAL_ARRAY);
     glDisableClientState(GL_COLOR_ARRAY);
     glDisableClientState(GL_TEXTURE_COORD_ARRAY);

     glDisable( GL_BLEND );
End;



Procedure FreeMesh ( pMesh : LPOGLMesh ) ;
Begin
     glDeleteBuffersARB( 1, @pMesh^.VectorID );
     glDeleteBuffersARB( 1, @pMesh^.NormalID );
     glDeleteBuffersARB( 1, @pMesh^.ColorID );
     glDeleteBuffersARB( 1, @pMesh^.TextureID );
     Finalize( pMesh^.VectorArray );
     Finalize( pMesh^.NormalArray );
     Finalize( pMesh^.ColorArray );
     Finalize( pMesh^.TextureArray );
     Finalize( pMesh^.PolygonData );
     Finalize( pMesh^.VertexData );
     Dispose( pMesh );
End;



Procedure DelMesh ( nIndex : LongInt ) ;
Var pMesh : LPOGLMesh;
Begin
     // recherche du mesh à sélectionner en fonction de son indice
     pMesh := FindItem( DATA_MESH, nIndex );
     If pMesh = NIL Then Exit;

     // destruction de la texture
     FreeMesh( pMesh );

     // destruction de l'objet dans la pile de données
     DelItem( DATA_MESH, nIndex );
End;



//////////////////////////////////////////////////////////////////////////////////////////
// AddAnimation : Charge un OGLAnimation depuis un fichier (*.A12), l'ajoute à la pile  //
//                de données, puis renvoie son pointeur.                                //
//////////////////////////////////////////////////////////////////////////////////////////
Function AddAnimation ( sFile : String ; nIndex : LongInt ; nMeshIndex : LongInt ) : LPOGLAnimation ;
Var ioLong : File Of LongInt ; ioAction : File Of OGLAction ; ioVector : File Of GLVector ;
    pAnimation : LPOGLAnimation ;
    tAnimation : LPOGLAnimation ;
    pMesh : LPOGLMesh ;
    nSize : LongInt ;
    tAction : OGLAction ;
    i, j, k : LongInt ;
Begin
     j := 0;

     // appel au manager de ressources pour éviter de charger une animation déjà chargé
     pAnimation := FindItemByPath( DATA_ANIMATION, sFile );
     If pAnimation <> NIL Then Begin
        AddLineToConsole( 'Reloading animation ' + sFile + '.' );
        New( tAnimation );
        tAnimation^.FrameArray := pAnimation^.FrameArray;
        tAnimation^.ActionArray := pAnimation^.ActionArray;
        tAnimation^.FrameCount := pAnimation^.FrameCount;
        tAnimation^.ActionCount := pAnimation^.ActionCount;
        tAnimation^.Mesh := pAnimation^.Mesh;
        SetLength( tAnimation^.VectorArray, pAnimation^.Mesh^.VertexCount );
        AddItem( DATA_ANIMATION, nIndex, tAnimation, sFile );
        AddAnimation := tAnimation;
        Exit;
     End;

     AddLineToConsole( 'Loading animation ' + sFile + '...' );

     // création du pointeur vers la nouvelle animation
     New( pAnimation );

     // appel au manager de ressources pour récupérer le mesh associé
     pMesh := FindItem( DATA_MESH, nMeshIndex );
     pAnimation^.Mesh := pMesh;

     // lecture du nombre d'actions
     Assign( ioLong, sFile );
     Reset( ioLong, 4 );
     Seek( ioLong, j );
     Read( ioLong, nSize ); j += 1;
     Close( ioLong );

     // allocation de la mémoire pour le tableau d'actions
     pAnimation^.ActionCount := nSize;
     SetLength( pAnimation^.ActionArray, nSize );

     // allocation de la mémoire pour le tableau de vecteurs temporaires
     SetLength( pAnimation^.VectorArray, pMesh^.VertexCount );

     // lecture de chaque action
     Assign( ioAction, sFile );
     Reset( ioAction, 4 );
     For i := 0 To nSize - 1 Do
     Begin
          Seek( ioAction, j );
          Read( ioAction, tAction ); j += 1;
          pAnimation^.ActionArray[i].framestart := tAction.framestart;
          pAnimation^.ActionArray[i].framecount := tAction.framecount;
     End;
     Close( ioAction );

     // lecture du nombre de frames
     Assign( ioLong, sFile );
     Reset( ioLong, 4 );
     Seek( ioLong, j ); j += 1;
     Read( ioLong, nSize );
     Close( ioLong );

     // allocation de la mémoire pour le tableau de frames
     pAnimation^.FrameCount := nSize;
     SetLength( pAnimation^.FrameArray, nSize );

     // lecture de chaque frame
     For i := 0 To nSize - 1 Do
     Begin
          // allocation de la mémoire pour le tableau de vecteurs de la frame
          SetLength( pAnimation^.FrameArray[i].VectorArray, pMesh^.VertexCount );

          // lecture de la durée de la frame
          Assign( ioLong, sFile );
          Reset( ioLong, 4 );
          Seek( ioLong, j ); j += 1;
          Read( ioLong, pAnimation^.FrameArray[i].Time );
          Close( ioLong );

          // lecture des vecteurs de la frame
          Assign( ioVector, sFile );
          Reset( ioVector, 4 );
          For k := 0 To pMesh^.VertexCount - 1 Do
          Begin
               Seek( ioVector, j );
               Read( ioVector, pAnimation^.FrameArray[i].VectorArray[k] ); j += 3;
          End;
          Close( ioVector );
     End;

     // envoie la géométrie dans la mémoire vidéo
     glGenBuffersARB( 1, @pAnimation^.VectorID );
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pAnimation^.VectorID );
     glBufferDataARB( GL_ARRAY_BUFFER_ARB, nSize * 12, @pAnimation^.VectorArray[0], GL_STREAM_DRAW_ARB );

     // ajout de l'animation à la pile de données
     AddItem( DATA_ANIMATION, nIndex, pAnimation, sFile );

     AddStringToConsole( Format('OK. (%d bytes)', [j*4]) );

     AddAnimation := pAnimation;
End;



///////////////////////////////////////////////////////////////////////////////////////////
// DrawAnimation : Procède au rendu d'une OGLAnimation en fonction de son indice.        //
///////////////////////////////////////////////////////////////////////////////////////////
Procedure DrawAnimation ( nIndex : LongInt ; t : Boolean ; nAction : LongInt ) ;
Var pAnimation : LPOGLAnimation ;
    pMesh : LPOGLMesh ;
    nTime : LongInt ;
    nFrameStart : LongInt ;
    nFrameCount : LongInt ;
    nDuration : LongInt ;
    nFrame : LongInt ;
    nNextFrame : LongInt ;
    fTime : Single ;
    fTick : Single ;
    fDuration : Single ;
    fFactor : Single ;
    pFrameA : LPOGLFrame ;
    pFrameB : LPOGLFrame ;
    p : QWord ;
Begin
     // recherche de l'animation à afficher en fonction de son indice
     pAnimation := FindItem( DATA_ANIMATION, nIndex );
     If pAnimation = NIL Then Exit;

     pMesh := pAnimation^.Mesh;
     
     If t Then Begin
        glEnable( GL_BLEND );
        glBlendFunc( GL_SRC_ALPHA, GL_ONE );
     End;

     nTime := Round(GetTime() * 1000);

     nFrameStart := pAnimation^.ActionArray[nAction].framestart;
     nFrameCount := pAnimation^.ActionArray[nAction].framecount;
     
     // calcul de la durée de l'animation
     nDuration := 0;
     For i := nFrameStart To nFrameStart + nFrameCount - 1 Do
     Begin
          nDuration += pAnimation^.FrameArray[i].Time;
     End;

     // détermination de la frame en cours et de la suivante
     nTime := (nTime Mod nDuration);
     nDuration := 0;
     For i := nFrameStart To nFrameStart + nFrameCount - 1 Do
     Begin
          nDuration += pAnimation^.FrameArray[i].Time;
          If nDuration >= nTime Then nFrame := i - nFrameStart;
          If nDuration >= nTime Then Break;
     End;
     If nFrame < nFrameCount - 1 Then nNextFrame := nFrame + 1 Else nNextFrame := 0;

     // calcul du facteur d'interpolation
     fTime := nTime;
     fTick := 0;
     fDuration := pAnimation^.FrameArray[nFrameStart+nFrame].Time;
     For i := nFrameStart To nFrameStart + nFrame - 1 Do
     Begin
          fTick += pAnimation^.FrameArray[i].Time;
     End;
     fFactor := (fTime - fTick) / fDuration;
     
     // interpolation linéaire entre deux frames
     pFrameA := @pAnimation^.FrameArray[nFrameStart+nFrame];
     pFrameB := @pAnimation^.FrameArray[nFrameStart+nNextFrame];
     For i := 0 To pAnimation^.Mesh^.VertexCount - 1 Do
     Begin
          pAnimation^.VectorArray[i].x := pFrameA^.VectorArray[i].x + (pFrameB^.VectorArray[i].x - pFrameA^.VectorArray[i].x) * fFactor;
          pAnimation^.VectorArray[i].y := pFrameA^.VectorArray[i].y + (pFrameB^.VectorArray[i].y - pFrameA^.VectorArray[i].y) * fFactor;
          pAnimation^.VectorArray[i].z := pFrameA^.VectorArray[i].z + (pFrameB^.VectorArray[i].z - pFrameA^.VectorArray[i].z) * fFactor;
     End;

     glEnableClientState(GL_VERTEX_ARRAY);
     glEnableClientState(GL_NORMAL_ARRAY);
     glEnableClientState(GL_COLOR_ARRAY);
     glEnableClientState(GL_TEXTURE_COORD_ARRAY);

     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pAnimation^.VectorID );
     glBufferDataARB( GL_ARRAY_BUFFER_ARB, pAnimation^.Mesh^.VertexCount * 12, @pAnimation^.VectorArray[0], GL_STREAM_DRAW_ARB );
     glVertexPointer(3, GL_FLOAT, 0, NIL);
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.NormalID );
     glNormalPointer(GL_FLOAT, 0, NIL);
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.ColorID );
     glColorPointer(3, GL_FLOAT, 0, NIL);
     glBindBufferARB( GL_ARRAY_BUFFER_ARB, pMesh^.TextureID );
     glTexCoordPointer(2, GL_FLOAT, 0, NIL);

     glDrawElements(GL_TRIANGLES, pMesh^.PolygonCount * 3, GL_UNSIGNED_INT, @pMesh^.IndexArray[0]);

     glDisableClientState(GL_VERTEX_ARRAY);
     glDisableClientState(GL_NORMAL_ARRAY);
     glDisableClientState(GL_COLOR_ARRAY);
     glDisableClientState(GL_TEXTURE_COORD_ARRAY);

     glDisable( GL_BLEND );
End;



Procedure FreeAnimation ( pAnimation : LPOGLAnimation ) ;
Var i : Integer;
Begin
     glDeleteBuffersARB( 1, @pAnimation^.VectorID );
     For i := 0 To pAnimation^.FrameCount Do
     Begin
          Finalize( pAnimation^.FrameArray[i].VectorArray );
     End;
     Finalize( pAnimation^.VectorArray );
     Finalize( pAnimation^.FrameArray );
     Finalize( pAnimation^.ActionArray );
     Dispose( pAnimation );
End;



Procedure DelAnimation ( nIndex : LongInt ) ;
Var pAnimation : LPOGLAnimation;
Begin
     // recherche de l'animation à sélectionner en fonction de son indice
     pAnimation := FindItem( DATA_ANIMATION, nIndex );
     If pAnimation = NIL Then Exit;

     // destruction de l'animation
     FreeAnimation( pAnimation );

     // destruction de l'objet dans la pile de données
     DelItem( DATA_ANIMATION, nIndex );
End;



////////////////////////////////////////////////////////////////////////////////
// DrawText : Procède au rendu d'une ligne de texte à l'écran.                //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawText ( x, y : Single ; r, g, b : Single ; nFont : integer ;
sText : String ) ;
Var i : Integer;
    pFont : Pointer;
Begin
     Case nFont of
          FONT_NORMAL    : pFont := GLUT_BITMAP_8_BY_13;
          FONT_BOLD      : pFont := GLUT_BITMAP_9_BY_15;
          FONT_HELVETICA : pFont := GLUT_BITMAP_HELVETICA_18;
     End;
     
     glMatrixMode( GL_PROJECTION );
     glPushMatrix;
     glLoadIdentity;
     gluOrtho2D( 0, GetRenderWidth, 0, GetRenderHeight );

     glMatrixMode( GL_MODELVIEW );
     glPushMatrix;
     glLoadIdentity;

     glDisable( GL_TEXTURE_2D );
     glDisable( GL_DEPTH_TEST );

     glColor3f( r, g, b );
     glRasterPos2f( x, GetRenderHeight - y );
     For i := 1 To Length(sText) Do
         glutBitmapCharacter( pFont, Integer(sText[i]) );

     glMatrixMode( GL_PROJECTION );
     glPopMatrix;
     glMatrixMode( GL_MODELVIEW );
     glPopMatrix;

     glEnable( GL_TEXTURE_2D );
     glEnable( GL_DEPTH_TEST );
End;



////////////////////////////////////////////////////////////////////////////////
// DrawImage : Procède au rendu d'une image à l'écran.                       //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawImage ( x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;
Begin
     glMatrixMode( GL_PROJECTION );
     glLoadIdentity;
     gluPerspective( 90.0, GetRenderWidth / GetRenderHeight, 0.1, 1000.0 );

     glMatrixMode(GL_MODELVIEW);
     glLoadIdentity;

     glDisable( GL_DEPTH_TEST );
     glDisable( GL_LIGHTING );

     If t Then Begin
        glEnable( GL_BLEND );
        glBlendFunc( GL_SRC_ALPHA, GL_ONE );
     End;
     
     glLoadIdentity;
     glTranslatef(x, y, z);

     glBegin( GL_QUADS );
     glTexCoord2f( 0.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -u, -v, 0.0 );
     glTexCoord2f( 0.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -u, v, 0.0 );
     glTexCoord2f( 1.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( u, v, 0.0 );
     glTexCoord2f( 1.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( u, -v, 0.0 );
     glEnd;
    
     glEnable( GL_DEPTH_TEST );
     glEnable( GL_LIGHTING );

     glDisable( GL_BLEND );
End;


////////////////////////////////////////////////////////////////////////////////
// DrawSprite : Procède au rendu d'un sprite à l'écran.                       //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawSprite ( u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;
Begin
     glDisable( GL_DEPTH_TEST );
     glDisable( GL_LIGHTING );

     If t Then Begin
        glEnable( GL_BLEND );
        glBlendFunc( GL_SRC_ALPHA, GL_ONE );
     End;

     glBegin( GL_QUADS );
     glTexCoord2f( 0.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -u, -v, 0.0 );
     glTexCoord2f( 0.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( u, -v, 0.0 );
     glTexCoord2f( 1.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( u, v, 0.0 );
     glTexCoord2f( 1.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -u, v, 0.0 );
     glEnd;

     glEnable( GL_DEPTH_TEST );
     glEnable( GL_LIGHTING );

     glDisable( GL_BLEND );
End;



////////////////////////////////////////////////////////////////////////////////
// DrawSkybox : Procède au rendu d'une skybox à l'écran.                      //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawSkybox ( r, g, b, a : Single ; nSkybox : Integer ) ;
Begin
     glDisable( GL_LIGHTING );

     SetTexture( 1, nSkybox + 1 ); // XZ- : bottom
     glBegin( GL_QUADS );
     glTexCoord2f( 1.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -999.999, -994.999, -999.999 );
     glTexCoord2f( 1.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +999.999, -994.999, -999.999 );
     glTexCoord2f( 0.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +999.999, -994.999, +999.999 );
     glTexCoord2f( 0.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -999.999, -994.999, +999.999 );
     glEnd;
     SetTexture( 1, nSkybox + 2 ); // XZ+ : top
     glBegin( GL_QUADS );
     glTexCoord2f( 1.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -999.999, +994.999, -999.999 );
     glTexCoord2f( 1.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +999.999, +994.999, -999.999 );
     glTexCoord2f( 0.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +999.999, +994.999, +999.999 );
     glTexCoord2f( 0.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -999.999, +994.999, +999.999 );
     glEnd;
     SetTexture( 1, nSkybox + 3 ); // XY- : front
     glBegin( GL_QUADS );
     glTexCoord2f( 1.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -999.999, -999.999, -994.999 );
     glTexCoord2f( 0.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +999.999, -999.999, -994.999 );
     glTexCoord2f( 0.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +999.999, +999.999, -994.999 );
     glTexCoord2f( 1.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -999.999, +999.999, -994.999 );
     glEnd;
     SetTexture( 1, nSkybox + 4 ); // XY+ : back
     glBegin( GL_QUADS );
     glTexCoord2f( 0.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -999.999, -999.999, +994.999 );
     glTexCoord2f( 1.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +999.999, -999.999, +994.999 );
     glTexCoord2f( 1.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +999.999, +999.999, +994.999 );
     glTexCoord2f( 0.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -999.999, +999.999, +994.999 );
     glEnd;
     SetTexture( 1, nSkybox + 5 ); // ZY- : left
     glBegin( GL_QUADS );
     glTexCoord2f( 0.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -994.999, -999.999, -999.999 );
     glTexCoord2f( 1.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -994.999, -999.999, +999.999 );
     glTexCoord2f( 1.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -994.999, +999.999, +999.999 );
     glTexCoord2f( 0.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( -994.999, +999.999, -999.999 );
     glEnd;
     SetTexture( 1, nSkybox + 6 ); // ZY+ : right
     glBegin( GL_QUADS );
     glTexCoord2f( 1.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +994.999, -999.999, -999.999 );
     glTexCoord2f( 0.0, 0.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +994.999, -999.999, +999.999 );
     glTexCoord2f( 0.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +994.999, +999.999, +999.999 );
     glTexCoord2f( 1.0, 1.0 );
     glColor4f( r, g, b, a );
     glVertex3f( +994.999, +999.999, -999.999 );
     glEnd;

     glEnable( GL_LIGHTING );
End;



////////////////////////////////////////////////////////////////////////////////
// DrawChar : Procède au rendu d'un caractère graphique à l'écran.            //
////////////////////////////////////////////////////////////////////////////////
Var cx : Single =  0.0;
    cy : Single =  0.0;
    cz : Single = -1.0;
Procedure DrawChar ( c : Char ; p : Boolean ; x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ; nCharsetStandard : Integer ; nCharsetExtended : Integer ) ;
Var tu, tv : Single;
Begin
     If p = True Then Begin
        x := cx;
        y := cy;
        z := cz;
        cx += u * 2.2;
     End Else Begin
        cx := x;
        cy := y;
        cz := z;
     End;
     
     tu := -1;
     tv := -1;
     
     c := LowerCase(c);
     Case c Of
          'a' : Begin tu := 0.000 ; tv := 0.000 ; End;
          'b' : Begin tu := 0.125 ; tv := 0.000 ; End;
          'c' : Begin tu := 0.250 ; tv := 0.000 ; End;
          'd' : Begin tu := 0.375 ; tv := 0.000 ; End;
          'e' : Begin tu := 0.500 ; tv := 0.000 ; End;
          'f' : Begin tu := 0.625 ; tv := 0.000 ; End;
          'g' : Begin tu := 0.750 ; tv := 0.000 ; End;
          'h' : Begin tu := 0.875 ; tv := 0.000 ; End;
          'i' : Begin tu := 0.000 ; tv := 0.167 ; End;
          'j' : Begin tu := 0.125 ; tv := 0.167 ; End;
          'k' : Begin tu := 0.250 ; tv := 0.167 ; End;
          'l' : Begin tu := 0.375 ; tv := 0.167 ; End;
          'm' : Begin tu := 0.500 ; tv := 0.167 ; End;
          'n' : Begin tu := 0.625 ; tv := 0.167 ; End;
          'o' : Begin tu := 0.750 ; tv := 0.167 ; End;
          'p' : Begin tu := 0.875 ; tv := 0.167 ; End;
          'q' : Begin tu := 0.000 ; tv := 0.333 ; End;
          'r' : Begin tu := 0.125 ; tv := 0.333 ; End;
          's' : Begin tu := 0.250 ; tv := 0.333 ; End;
          't' : Begin tu := 0.375 ; tv := 0.333 ; End;
          'u' : Begin tu := 0.500 ; tv := 0.333 ; End;
          'v' : Begin tu := 0.625 ; tv := 0.333 ; End;
          'w' : Begin tu := 0.750 ; tv := 0.333 ; End;
          'x' : Begin tu := 0.875 ; tv := 0.333 ; End;
          'y' : Begin tu := 0.000 ; tv := 0.500 ; End;
          'z' : Begin tu := 0.125 ; tv := 0.500 ; End;
          '0' : Begin tu := 0.250 ; tv := 0.500 ; End;
          '1' : Begin tu := 0.375 ; tv := 0.500 ; End;
          '2' : Begin tu := 0.500 ; tv := 0.500 ; End;
          '3' : Begin tu := 0.625 ; tv := 0.500 ; End;
          '4' : Begin tu := 0.750 ; tv := 0.500 ; End;
          '5' : Begin tu := 0.875 ; tv := 0.500 ; End;
          '6' : Begin tu := 0.000 ; tv := 0.667 ; End;
          '7' : Begin tu := 0.125 ; tv := 0.667 ; End;
          '8' : Begin tu := 0.250 ; tv := 0.667 ; End;
          '9' : Begin tu := 0.375 ; tv := 0.667 ; End;
          '.' : Begin tu := 0.500 ; tv := 0.667 ; End;
          ',' : Begin tu := 0.625 ; tv := 0.667 ; End;
          #39 : Begin tu := 0.750 ; tv := 0.667 ; End;
          ':' : Begin tu := 0.875 ; tv := 0.667 ; End;
          ';' : Begin tu := 0.000 ; tv := 0.833 ; End;
          '!' : Begin tu := 0.125 ; tv := 0.833 ; End;
          '?' : Begin tu := 0.250 ; tv := 0.833 ; End;
          '(' : Begin tu := 0.375 ; tv := 0.833 ; End;
          ')' : Begin tu := 0.500 ; tv := 0.833 ; End;
          '[' : Begin tu := 0.625 ; tv := 0.833 ; End;
          ']' : Begin tu := 0.750 ; tv := 0.833 ; End;
          '*' : Begin tu := 0.875 ; tv := 0.833 ; End;
     End;
     If (tu = -1) And (tv = -1) Then Begin
        Case c Of
             '-' : Begin tu := 0.000 ; tv := 0.000 ; End;
             Else Exit;
        End;
        SetTexture( 1, nCharsetExtended );
     End Else Begin
        SetTexture( 1, nCharsetStandard );
     End;
     
     glMatrixMode( GL_PROJECTION );
     glLoadIdentity;
     gluPerspective( 90, GetRenderWidth / GetRenderHeight, 0.1, 1000 );

     glMatrixMode(GL_MODELVIEW);
     glLoadIdentity;

     glDisable( GL_DEPTH_TEST );
     glDisable( GL_LIGHTING );

     If t Then Begin
        glEnable( GL_BLEND );
        glBlendFunc( GL_SRC_ALPHA, GL_ONE );
     End;

     glLoadIdentity;
     glTranslatef(x, y, z);

     glBegin( GL_QUADS );
     glTexCoord2f( tu, 1.0 - tv - 0.167 );
     glColor4f( r, g, b, a );
     glVertex3f( -u, -v, 0.0 );
     glTexCoord2f( tu, 1.0 - tv );
     glColor4f( r, g, b, a );
     glVertex3f( -u, v, 0.0 );
     glTexCoord2f( tu + 0.125, 1.0 - tv );
     glColor4f( r, g, b, a );
     glVertex3f( u, v, 0.0 );
     glTexCoord2f( tu + 0.125, 1.0 - tv - 0.167 );
     glColor4f( r, g, b, a );
     glVertex3f( u, -v, 0.0 );
     glEnd;

     glEnable( GL_DEPTH_TEST );
     glEnable( GL_LIGHTING );

     glDisable( GL_BLEND );
End;



Type OGLString = RECORD
		       fTime1 : Single;
		       fTime2 : Single;
		       fTime3 : Single;
		       fTime4 : Single;
                       fRate  : Single;
		       sData  : String;
                  END;
Var aString : Array [0..255] Of OGLString;



////////////////////////////////////////////////////////////////////////////////
// SetString : Initialise une OGLString avant que celle-ci ne soit rendue.    //
////////////////////////////////////////////////////////////////////////////////
Procedure SetString ( id : Integer ; s : String ; t1, t2, t3 : Single ) ;
Begin
     If (id < 0) Or (id > 255) Then Exit;
     
     aString[id].fTime1 := GetTime() + t1;
     aString[id].fTime2 := GetTime() + t1 + t2;
     aString[id].fTime3 := GetTime() + t1 + t2 + t1;
     aString[id].fTime4 := GetTime() + t1 + t2 + t1 + t3;
     aString[id].fRate  := Single(Length(s)) / t2;
     aString[id].sData  := s;
End;



////////////////////////////////////////////////////////////////////////////////
// DrawString : Procède au rendu d'une OGLString en avec un effet.            //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawString ( id : Integer ; x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ; nCharsetStandard : Integer ; nCharsetExtended : Integer ; nEffect : Integer ) ;
Var count : Integer;
    alpha : Single;
    value : Integer;
    k : Integer;
    s : Single;
Begin
     If (id < 0) Or (id > 255) Then Exit;

     If nCharsetStandard = SPRITE_CHARSET_TERMINAL Then s := 2.2;
     If nCharsetStandard = SPRITE_CHARSET_DIGITAL Then s := 1.0;

     If nEffect = EFFECT_NONE Then Begin
        For k := 1 To Length(aString[id].sData) Do
            DrawChar( aString[id].sData[k], False, x + u * s * (k - 1), y, z, u, v, r, g, b, a, t, nCharsetStandard, nCharsetExtended );
     End;

     If nEffect = EFFECT_TERMINAL Then Begin
        count := Round(GetTime() * 1000) Mod 1000;
        If (count >= 0) And (count < 450) Then alpha := a * 1.0;
        If (count >= 450) And (count < 500) Then alpha := a * Single(500 - count) * 0.02;
        If (count >= 500) And (count < 950) Then alpha := a * 0.0;
        If (count >= 950) And (count < 1000) Then alpha := a * Single(count - 950) * 0.02;

        If GetTime() <= aString[id].fTime1 Then Begin
           DrawChar( '*', False, x, y, z, u, v, r, g, b, alpha, t, nCharsetStandard, nCharsetExtended );
        End;
        If (GetTime() > aString[id].fTime1) And (GetTime() <= aString[id].fTime2) Then Begin
           value := Round((GetTime() - aString[id].fTime1) * aString[id].fRate);
           For k := 1 To value Do
               DrawChar( aString[id].sData[k], False, x + u * s * (k - 1), y, z, u, v, r, g, b, a, t, nCharsetStandard, nCharsetExtended );
           DrawChar( '*', False, x + u * s * k, y, z, u, v, r, g, b, alpha, t, nCharsetStandard, nCharsetExtended );
        End;
        If (GetTime() > aString[id].fTime2) And (GetTime() <= aString[id].fTime3) Then Begin
           For k := 1 To Length(aString[id].sData) Do
               DrawChar( aString[id].sData[k], False, x + u * s * (k - 1), y, z, u, v, r, g, b, a, t, nCharsetStandard, nCharsetExtended );
           DrawChar( '*', False, x + u * s * k, y, z, u, v, r, g, b, alpha, t, nCharsetStandard, nCharsetExtended );
        End;
        If (GetTime() > aString[id].fTime3) And (GetTime() <= aString[id].fTime4) Then Begin
           For k := 1 To Length(aString[id].sData) Do
               DrawChar( aString[id].sData[k], False, x + u * s * (k - 1), y, z, u, v, r, g, b, a, t, nCharsetStandard, nCharsetExtended );
        End;
     End;

End;



Procedure Clear ( r, g, b, a : Single ) ;
Begin
     glClearColor( r, g, b, a );
     glClear( GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT );
     glClearDepth( 1.0 );
End;



Function GetSquareWidth : Integer;
Var Rect : Array[0..3] Of Integer;
Begin
     glGetIntegerv(GL_VIEWPORT, @Rect);
     If Rect[2] - Rect[0] >= 0 Then Result := 0;
     If Rect[2] - Rect[0] >= 1 Then Result := 1;
     If Rect[2] - Rect[0] >= 2 Then Result := 2;
     If Rect[2] - Rect[0] >= 4 Then Result := 4;
     If Rect[2] - Rect[0] >= 8 Then Result := 8;
     If Rect[2] - Rect[0] >= 16 Then Result := 16;
     If Rect[2] - Rect[0] >= 32 Then Result := 32;
     If Rect[2] - Rect[0] >= 64 Then Result := 64;
     If Rect[2] - Rect[0] >= 128 Then Result := 128;
     If Rect[2] - Rect[0] >= 256 Then Result := 256;
     If Rect[2] - Rect[0] >= 512 Then Result := 512;
     If Rect[2] - Rect[0] >= 1024 Then Result := 1024;
End;



Function GetSquareHeight : Integer;
Var Rect : Array[0..3] Of Integer;
Begin
     glGetIntegerv(GL_VIEWPORT, @Rect);
     If Rect[3] - Rect[1] >= 0 Then Result := 0;
     If Rect[3] - Rect[1] >= 1 Then Result := 1;
     If Rect[3] - Rect[1] >= 2 Then Result := 2;
     If Rect[3] - Rect[1] >= 4 Then Result := 4;
     If Rect[3] - Rect[1] >= 8 Then Result := 8;
     If Rect[3] - Rect[1] >= 16 Then Result := 16;
     If Rect[3] - Rect[1] >= 32 Then Result := 32;
     If Rect[3] - Rect[1] >= 64 Then Result := 64;
     If Rect[3] - Rect[1] >= 128 Then Result := 128;
     If Rect[3] - Rect[1] >= 256 Then Result := 256;
     If Rect[3] - Rect[1] >= 512 Then Result := 512;
     If Rect[3] - Rect[1] >= 1024 Then Result := 1024;
End;



Function GetRenderWidth : Integer;
Var Rect : Array[0..3] Of Integer;
Begin
     glGetIntegerv(GL_VIEWPORT, @Rect);
     Result := Rect[2] - Rect[0];
End;



Function GetRenderHeight : Integer;
Var Rect : Array[0..3] Of Integer;
Begin
     glGetIntegerv(GL_VIEWPORT, @Rect);
     Result := Rect[3] - Rect[1];
End;


Var WindowWidth : Integer;
Function GetWindowWidth : Integer;
Begin
     Result := WindowWidth;
End;



Var WindowHeight : Integer;
Function GetWindowHeight : Integer;
Begin
     Result := WindowHeight;
End;



Procedure EnableLighting() ;
Begin
     glEnable(GL_LIGHTING);
End;



Procedure DisableLighting() ;
Begin
     glDisable(GL_LIGHTING);
End;



Procedure SetLight( k : Integer ; x, y, z : Single ; r, g, b, a : Single ; a0, a1, a2 : Single ; t : Boolean ) ;
Var LightVector : Array[0..3] Of glFloat;
Var LightColor : Array[0..3] Of glFloat;
Var LightAttn0 : glFloat;
    LightAttn1 : glFloat;
    LightAttn2 : glFloat;
Begin
     LightVector[0] := x;
     LightVector[1] := y;
     LightVector[2] := z;
     LightVector[3] := 1.0;

     LightColor[0] := r;
     LightColor[1] := g;
     LightColor[2] := b;
     LightColor[3] := a;
     
     LightAttn0 := a0;
     LightAttn1 := a1;
     LightAttn2 := a2;

     glLightfv(GL_LIGHT0+k, GL_DIFFUSE, LightColor);
     glLightfv(GL_LIGHT0+k, GL_POSITION, LightVector);
     glLightfv(GL_LIGHT0+k, GL_CONSTANT_ATTENUATION, @LightAttn0);
     glLightfv(GL_LIGHT0+k, GL_LINEAR_ATTENUATION, @LightAttn1);
     glLightfv(GL_LIGHT0+k, GL_QUADRATIC_ATTENUATION, @LightAttn2);
     If t Then glEnable(GL_LIGHT0+k) Else glDisable(GL_LIGHT0+k);
End;



Procedure SetMaterial( r, g, b, a : Single ) ;
Var MaterialColor : Array[0..3] Of glFloat;
Begin
     If Not bLighting Then Begin
        r *= 5.0;
        g *= 5.0;
        b *= 5.0;
        a *= 5.0;
     End;
     
     MaterialColor[0] := r;
     MaterialColor[1] := g;
     MaterialColor[2] := b;
     MaterialColor[3] := a;

     glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, MaterialColor);
End;



Var RenderTexture : GLUInt;
    RenderWidth : Integer;
    RenderHeight : Integer;
    
    

Procedure PutRenderTexture() ;
Begin
     RenderWidth := GetRenderWidth;
     RenderHeight := GetRenderHeight;

     glViewport( 0, 0, GetSquareWidth, GetSquareHeight );

     glEnable( GL_TEXTURE_2D );
     glBindTexture( GL_TEXTURE_2D, RenderTexture );
End;



Procedure GetRenderTexture() ;
Begin
     glEnable( GL_TEXTURE_2D );
     glBindTexture( GL_TEXTURE_2D, RenderTexture );
     glCopyTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, 0, 0, GetSquareWidth, GetSquareHeight, 0 );

     glViewport( 0, 0, RenderWidth, RenderHeight );
End;



Procedure SetRenderTexture() ;
Begin
     glEnable( GL_TEXTURE_2D );
     glBindTexture( GL_TEXTURE_2D, RenderTexture );

     // définit les techniques de rendu
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
     glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
End;



////////////////////////////////////////////////////////////////////////////////
// InitBox : Initialise une boite de dialogue.                                //
////////////////////////////////////////////////////////////////////////////////
Procedure InitBox ( s1, s2 : String ) ;
Var u, v, w : Single;
Begin
     u := GetSquareWidth * 2 / GetRenderWidth;
     v := GetSquareHeight * 2 / GetRenderHeight;
     w := GetSquareWidth / GetSquareHeight;
     
     // appel d'une texture de rendu
     PutRenderTexture();

     glEnable( GL_TEXTURE_2D );
     glBindTexture( GL_TEXTURE_2D, BackBuffer );

     DrawImage( (u - 1.0) * w, v - 1.0, -1.0, u * w, v, 1.0, 1.0, 1.0, 1.0, False );

     // récupération de la texture de rendu
     GetRenderTexture();

     glDisable( GL_TEXTURE_2D );

     SetString( 1, s1, 0.2, 1.0, 60 );
     SetString( 2, s2, 0.4, 1.0, 60 );
End;



////////////////////////////////////////////////////////////////////////////////
// DrawBox : Affiche une boite de dialogue.                                   //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawBox ( x1, y1, x2, y2 : Single ) ;
Var w, h : Single;
Begin
     w := GetRenderWidth;
     h := GetRenderHeight;

     SetRenderTexture();
     DrawImage( 0.0, 0.0, -1.0, 1.0 * w / h, 1.0, 0.5, 0.5, 0.5, 0.5, True );

     DrawString( 1, -w / h * x1, y1, -1, 0.024 * w / h, 0.036, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( 2, -w / h * x2, y2, -1, 0.024 * w / h, 0.036, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
End;






























////////////////////////////////////////////////////////////////////////////////
// FONCTIONS AUDIO                                                            //
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
// InitFMod : Initialise la librairie FMod.                                   //
////////////////////////////////////////////////////////////////////////////////
Procedure InitFMod () ;
Begin
     If FMOD_VERSION > FSOUND_GetVersion Then Begin
          AddLineToConsole( 'ERROR Initializing FMOD : Invalid version.' );
          Exit;
     End;

     If Not FSOUND_Init( 44100, 32, 0 ) Then
     Begin
          AddLineToConsole( 'ERROR Initializing FMOD : ' );
          AddStringToConsole( FMOD_ErrorString(FSOUND_GetError()) );
          FSOUND_Close();
          Exit;
     End;
End;



////////////////////////////////////////////////////////////////////////////////
// ExitFMod : Ferme la librairie FMod.                                        //
////////////////////////////////////////////////////////////////////////////////
Procedure ExitFMod () ;
Begin
     FSOUND_Close();
End;



////////////////////////////////////////////////////////////////////////////////
// AddSound : Charge un son depuis un fichier (*.wav ; *.mp3), et l'ajoute à  //
//            la pile de données.                                             //
////////////////////////////////////////////////////////////////////////////////
Procedure AddSound ( sFile : String ; nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     // appel au manager de ressources pour éviter de charger un son déjà chargé
     pSound := FindItemByPath( DATA_SOUND, sFile );
     If pSound <> NIL Then Begin
        AddLineToConsole( 'Reloading sound ' + sFile + '.' );
        AddItem( DATA_SOUND, nIndex, pSound, sFile );
        Exit;
     End;

     AddLineToConsole( 'Loading sound ' + sFile + '...' );

     // chargement du son
     pSound := FSOUND_Sample_Load( FSOUND_FREE, PChar(sFile), FSOUND_2D, 0, 0 );
     If pSound = NIL Then Begin
        AddStringToConsole( 'FAILED. ' + FMOD_ErrorString(FSOUND_GetError()) );
        Exit;
     End;

     // ajout du son à la pile de données
     AddItem( DATA_SOUND, nIndex, pSound, sFile );
     
     AddStringToConsole( Format('OK. (%d bytes)', [FSOUND_Sample_GetLength(pSound)*2]) );
End;



////////////////////////////////////////////////////////////////////////////////
// DelSound : Supprime un son de la pile de données.                          //
////////////////////////////////////////////////////////////////////////////////
Procedure DelSound ( nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     // recherche du son à sélectionner en fonction de son indice
     pSound := FindItem( DATA_SOUND, nIndex );
     If pSound = NIL Then Exit;

     // destruction de lu son
     FSOUND_Sample_Free( pSound );

     // destruction de l'objet dans la pile de données
     DelItem( DATA_SOUND, nIndex );
End;



////////////////////////////////////////////////////////////////////////////////
// AddMusic : Charge une musique depuis un fichier (*.mod ; *.s3m), et        //
//            l'ajoute à la pile de données.                                  //
////////////////////////////////////////////////////////////////////////////////
Procedure AddMusic ( sFile : String ; nIndex : LongInt ) ;
Var pMusic : PFMusicModule;
Begin
     AddLineToConsole( 'Loading music ' + sFile + '...' );

     // chargement de la musique
     pMusic := FMUSIC_LoadSong( PChar(sFile) );
     If pMusic = NIL Then Begin
        AddStringToConsole( 'FAILED. ' + FMOD_ErrorString(FSOUND_GetError()) );
        Exit;
     End;

     // ajout de la musique à la pile de données
     AddItem( DATA_MUSIC, nIndex, pMusic, sFile );

     AddStringToConsole( Format('OK. (%d bytes)', [FMUSIC_GetNumSamples(pMusic)]) );
End;



////////////////////////////////////////////////////////////////////////////////
// PlaySound : Procède à la lecture d'un son en fonction de son indice.       //
////////////////////////////////////////////////////////////////////////////////
Procedure PlaySound ( nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     // recherche du son à lire en fonction de son indice
     pSound := FindItem( DATA_SOUND, nIndex );
     If pSound = NIL Then Exit;
     
     // lecture du son
     FSOUND_PlaySound( 1, pSound );
End;



////////////////////////////////////////////////////////////////////////////////
// StopSound : Procède à l'arrêt d'un son en fonction de son indice.          //
////////////////////////////////////////////////////////////////////////////////
Procedure StopSound ( nIndex : LongInt ) ;
Begin
     // arrêt du son
     FSOUND_StopSound( 1 );
End;



////////////////////////////////////////////////////////////////////////////////
// PlayMusic : Procède à la lecture d'une musique en fonction de son indice.  //
////////////////////////////////////////////////////////////////////////////////
Procedure PlayMusic ( nIndex : LongInt ) ;
Var pMusic : PFMusicModule;
Begin
     // recherche de la musique à lire en fonction de son indice
     pMusic := FindItem( DATA_MUSIC, nIndex );
     If pMusic = NIL Then Exit;

     // lecture de la musique
     FMUSIC_PlaySong( pMusic );
End;



////////////////////////////////////////////////////////////////////////////////
// StopMusic : Procède à l'arrêt d'une musique en fonction de son indice.     //
////////////////////////////////////////////////////////////////////////////////
Procedure StopMusic ( nIndex : LongInt ) ;
Var pMusic : PFMusicModule;
Begin
     // recherche de la musique à lire en fonction de son indice
     pMusic := FindItem( DATA_MUSIC, nIndex );
     If pMusic = NIL Then Exit;

     // arrêt de la musique
     FMUSIC_StopSong( pMusic );
End;





























////////////////////////////////////////////////////////////////////////////////
// FONCTIONS D'ENTREES CLAVIER/SOURIS                                         //
////////////////////////////////////////////////////////////////////////////////



Type LPKeyItem = ^KeyItem;
     KeyItem = RECORD
                      count : LongInt;
                      key : Integer;
                      instant : Boolean;
                      special : Boolean;
                      callbackstddown : KeyCallbackStd;
                      callbackstdup   : KeyCallbackStd;
                      callbackobjdown : KeyCallbackObj;
                      callbackobjup   : KeyCallbackObj;
                      next : LPKeyItem;
                END;
Var pKeyStack : LPKeyItem = NIL;



Var bKey : Array [0..255] Of Boolean ;
Var bKeyS : Array [0..255] Of Boolean ;



Var nX, nY : Integer; // coordonnées du pointeur de souris
    dX, dY : Single; // dernière petite déviation du pointeur de souris
    


Var pLeftButtonCallback : ButtonCallback = NIL;
Var pRightButtonCallback : ButtonCallback = NIL;
Var pMiddleButtonCallback : ButtonCallback = NIL;



Procedure ClearInput () ;
Var k : Integer;
Begin
     For k := 0 To 255 Do Begin
         bKey[k] := False;
         bKeyS[k] := False;
     End;
End;



Function CheckKey() : Char ;
Var k : Integer;
Begin
     CheckKey := #0;

     If bKey[8] Then CheckKey := #8;

     For k := 97 To 122 Do
         If bKey[k] Then CheckKey := Chr(k);

     For k := 48 To 57 Do
         If bKey[k] Then CheckKey := Chr(k);

     If bKey[32] Then CheckKey := #32;
     If bKey[33] Then CheckKey := #33;
     If bKey[39] Then CheckKey := #39;
     If bKey[40] Then CheckKey := #40;
     If bKey[41] Then CheckKey := #41;
     If bKey[44] Then CheckKey := #44;
     If bKey[45] Then CheckKey := #45;
     If bKey[46] Then CheckKey := #46;
     If bKey[58] Then CheckKey := #58;
     If bKey[59] Then CheckKey := #59;
     If bKey[63] Then CheckKey := #63;
     If bKey[91] Then CheckKey := #91;
     If bKey[93] Then CheckKey := #93;
End;



Function GetKey( nKey : Integer ) : Boolean ;
Begin
     GetKey := bKey[nKey];
End;



Function GetKeyS( nKey : Integer ) : Boolean ;
Begin
     GetKeyS := bKeyS[-nKey];
End;



Function KeyToStr( nKey : Integer ) : String ;
Begin
     KeyToStr := sKeyToString[ abs( nKey ) ];
End;



////////////////////////////////////////////////////////////////////////////////
// BindKey : Ajoute une callback à la pile de touches.                        //
////////////////////////////////////////////////////////////////////////////////
Procedure BindKeyStd ( nKey : Integer; bDown : boolean ; bInstant : Boolean ; pCallback : KeyCallbackStd ) ;
Var pKeyItem : LPKeyItem ;
Begin
     pKeyItem := pKeyStack;
     While pKeyItem <> NIL Do
     Begin
          If (pKeyItem^.key = -nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = True) Then Begin
             If bDown Then Begin
                 pKeyItem^.callbackstddown := pCallback;
             End Else Begin
                 pKeyItem^.callbackstdup := pCallback;
             End;
             Exit;
          End;
          If (pKeyItem^.key = nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = False) Then Begin
             If bDown Then Begin
                 pKeyItem^.callbackstddown := pCallback;
             End Else Begin
                 pKeyItem^.callbackstdup := pCallback;
             End;
             Exit;
          End;
          pKeyItem := pKeyItem^.next;
     End;

     If pKeyStack = NIL Then Begin
          New( pKeyStack );
          pKeyStack^.count := 0;
          pKeyStack^.next := NIL;
     End Else Begin
          pKeyItem := pKeyStack;
          New( pKeyStack );
          pKeyStack^.count := pKeyItem^.count + 1;
          pKeyStack^.next := pKeyItem;
     End;
     If nKey < 0 Then pKeyStack^.key := -nKey Else pKeyStack^.key := nKey;
     pKeyStack^.instant := bInstant;
     If nKey < 0 Then pKeyStack^.special := True Else pKeyStack^.special := False;
     If bDown Then Begin
         pKeyStack^.callbackstddown := pCallback;
         pKeyStack^.callbackstdup := NIL;
     End Else Begin
         pKeyStack^.callbackstddown := NIL;
         pKeyStack^.callbackstdup := pCallback;
     End;
     pKeyStack^.callbackobjdown := NIL;
     pKeyStack^.callbackobjup := NIL;
End;

Procedure BindKeyObj ( nKey : Integer; bDown : boolean ; bInstant : Boolean ; pCallback : KeyCallbackObj ) ;
Var pKeyItem : LPKeyItem ;
Begin
     pKeyItem := pKeyStack;
     While pKeyItem <> NIL Do
     Begin
          If (pKeyItem^.key = -nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = True) Then Begin
             If bDown Then Begin
                 pKeyItem^.callbackobjdown := pCallback;
             End Else Begin
                 pKeyItem^.callbackobjup := pCallback;
             End;
             Exit;
          End;
          If (pKeyItem^.key = nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = False) Then Begin
             If bDown Then Begin
                 pKeyItem^.callbackobjdown := pCallback;
             End Else Begin
                 pKeyItem^.callbackobjup := pCallback;
             End;
             Exit;
          End;
          pKeyItem := pKeyItem^.next;
     End;

     If pKeyStack = NIL Then Begin
          New( pKeyStack );
          pKeyStack^.count := 0;
          pKeyStack^.next := NIL;
     End Else Begin
          pKeyItem := pKeyStack;
          New( pKeyStack );
          pKeyStack^.count := pKeyItem^.count + 1;
          pKeyStack^.next := pKeyItem;
     End;
     If nKey < 0 Then pKeyStack^.key := -nKey Else pKeyStack^.key := nKey;
     pKeyStack^.instant := bInstant;
     If nKey < 0 Then pKeyStack^.special := True Else pKeyStack^.special := False;
     If bDown Then Begin
         pKeyStack^.callbackobjdown := pCallback;
         pKeyStack^.callbackobjup := NIL;
     End Else Begin
         pKeyStack^.callbackobjdown := NIL;
         pKeyStack^.callbackobjup := pCallback;
     End;
     pKeyStack^.callbackstdup := NIL;
     pKeyStack^.callbackstddown := NIL;

End;



////////////////////////////////////////////////////////////////////////////////
// ExecKey : Execute la callback correspondante à la touche enfoncée.         //
////////////////////////////////////////////////////////////////////////////////
Procedure ExecKey ( nKey : Integer ; bDown : boolean ;bInstant : Boolean ; bSpecial : Boolean ) ;
Var pKeyItem : LPKeyItem ;
Begin
   if bDown then
   begin
      // regarde si la touche enfoncée a été définie et appelle la callback correspondante
     pKeyItem := pKeyStack;
     While pKeyItem <> NIL Do
     Begin
          If (pKeyItem^.key = nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = bSpecial) Then Begin
            If (pKeyItem^.callbackstddown = NIL) And (pKeyItem^.callbackobjdown <> NIL) Then pKeyItem^.callbackobjdown( GetDelta() );
            If (pKeyItem^.callbackobjdown = NIL) And (pKeyItem^.callbackstddown <> NIL) Then pKeyItem^.callbackstddown();
          End;
          pKeyItem := pKeyItem^.next;
     End;
   end
   else
   begin
     pKeyItem := pKeyStack;
     While pKeyItem <> Nil do
     begin
       if (pKeyItem^.Key = nKey) AND (pKeyItem^.special = bSpecial) then
       begin
         If (pKeyItem^.callbackstdup = NIL) And (pKeyItem^.callbackobjup <> NIL) Then pKeyItem^.callbackobjup( GetDelta() );
         If (pKeyItem^.callbackobjup = NIL) And (pKeyItem^.callbackstdup <> NIL) Then pKeyItem^.callbackstdup();
       end;
       pKeyItem := pKeyItem^.Next;
     end;
   end;
End;



////////////////////////////////////////////////////////////////////////////////
// BindButton : Attribue une callback à un bouton de souris.                  //
////////////////////////////////////////////////////////////////////////////////
Procedure BindButton ( nButton : Integer ; pCallback : ButtonCallback ) ;
Begin
     Case nButton Of
          BUTTON_LEFT : pLeftButtonCallback := pCallback;
          BUTTON_RIGHT : pRightButtonCallback := pCallback;
          BUTTON_MIDDLE : pMiddleButtonCallback := pCallback;
     End;
End;



Function GetMouseX : Integer ;
Begin
     If nX < 0 Then nX := 0;
     If nX > GetWindowWidth Then nX := GetWindowWidth;
     GetMouseX := nX;
End;



Function GetMouseY : Integer ;
Begin
     If nY < 0 Then nY := 0;
     If nY > GetWindowHeight Then nY := GetWindowHeight;
     GetMouseY := nY;
End;



Function GetMouseDX : Single ;
Begin
     GetMouseDX := dX;
     dX := 0;
End;



Function GetMouseDY : Single ;
Begin
     GetMouseDY := dY;
     dY := 0;
End;





























////////////////////////////////////////////////////////////////////////////////
// CALLBACKS OPENGL                                                           //
////////////////////////////////////////////////////////////////////////////////



Var OGLCallback : GameCallback;



Var sWindowTitle : String;
Var bReshape : Boolean;


Procedure OGLKeyDown( k : Byte ; x, y : LongInt ); cdecl; overload;
Begin
     If bKey[k] = False Then ExecKey( k, True, True, False );
     bKey[k] := True;
End;



Procedure OGLKeyUp( k : Byte ; x, y : LongInt ); cdecl; overload;
Begin
     If bKey[k] then ExecKey( k, False, True, False);
     bKey[k] := False;
End;



Procedure OGLKeyDownS( k : LongInt ; x, y : LongInt ); cdecl; overload;
Begin
     If bKeyS[k] = False Then ExecKey( k, True, True, True );
     bKeyS[k] := True;
End;



Procedure OGLKeyUpS( k : LongInt ; x, y : LongInt ); cdecl; overload;
Begin
     If bKey[k] then ExecKey( k, False, True, True);
     bKeyS[k] := False;
End;



Procedure OGLWindow( w, h : Integer ); cdecl;
Begin
     If h = 0 Then h := 1;
     If w = 0 Then w := 1;

     glViewport( 0, 0, w, h );

     WindowWidth := w;
     WindowHeight := h;

     bReshape := True;
End;



Procedure OGLRender () ; cdecl;
Var k : Integer;
Var Data : Pointer;
Begin
     If bReshape Then Begin
        glDeleteTextures( 1, @RenderTexture );
        GetMem( Data, GetSquareWidth * GetSquareHeight * 3 );
        glGenTextures( 1, @RenderTexture );
        glBindTexture( GL_TEXTURE_2D, RenderTexture );
        glTexImage2D( GL_TEXTURE_2D, 0, 3, GetSquareWidth, GetSquareHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, Data );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
        FreeMem(Data);

        glDeleteTextures( 1, @BackBuffer );
        GetMem( Data, GetSquareWidth * 2 * GetSquareHeight * 2 * 3 );
        glGenTextures( 1, @BackBuffer );
        glBindTexture( GL_TEXTURE_2D, BackBuffer );
        glTexImage2D( GL_TEXTURE_2D, 0, 3, GetSquareWidth * 2, GetSquareHeight * 2, 0, GL_RGB, GL_UNSIGNED_BYTE, Data );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
        FreeMem(Data);
        
        bReshape := False;
     End;

     glClearColor( 0.0, 0.0, 0.0, 0.0 );
     glClear( GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT );
     glClearDepth( 1.0 );

     glDisable( GL_CULL_FACE );
     glEnable( GL_DEPTH_TEST );
     glShadeModel( GL_SMOOTH );
     glDepthFunc( GL_LEQUAL );
     glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
     glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

     OGLCallback();

     glEnable( GL_TEXTURE_2D );
     glBindTexture( GL_TEXTURE_2D, BackBuffer );
     glCopyTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, 0, 0, GetSquareWidth * 2, GetSquareHeight * 2, 0 );

     glDisable(GL_LIGHTING);

     DrawText( 10, 20, 1, 1, 1, FONT_HELVETICA, Format( 'atominsa - %.3f FPS',[GetFPS()] ) );

     glutSwapBuffers;

     For k := 0 To 255 Do Begin
         If bKey[k] = True Then ExecKey( k, True, False, False );
         If bKeyS[k] = True Then ExecKey( k, True, False, True );
     End;
     
     nFrame += 1;
     If GetTime() - fTime > 1 Then
     Begin
          nFPS := nFrame;
          nFrame := -1;
          fTime := GetTime();
     End;
     fDelta := GetTime() - fFrame;
     fFrame := GetTime();
End;



Procedure OGLMouseButton ( button, state, x, y : Integer ) ; cdecl;
Begin
     dX := (nX - x) * 0.001;
     dY := (nY - y) * 0.001;

     nX := x;
     nY := y;
     
     If state = GLUT_UP Then Begin
        Case button Of
             GLUT_LEFT_BUTTON : If pLeftButtonCallback <> NIL Then pLeftButtonCallback();
             GLUT_RIGHT_BUTTON : If pRightButtonCallback <> NIL Then pRightButtonCallback();
             GLUT_MIDDLE_BUTTON : If pMiddleButtonCallback <> NIL Then pMiddleButtonCallback();
        End;
     End;
End;



Procedure OGLMouseMove ( x, y : Integer ) ; cdecl;
Begin
     dX := (nX - x) * 0.001;
     dY := (nY - y) * 0.001;

     nX := x;
     nY := y;
End;



Var fIdleTime : Double;
Procedure OGLTimer () ; cdecl;
Begin
     If GetTimeExt() >= fIdleTime Then Begin
        fIdleTime := GetTimeExt() + 1.0 / nFramerate;
        glutPostRedisplay();
     End;
End;



Function CheckDisplay () : Boolean ;
Begin
     glutGameModeString( PChar( Format( '%dx%d:%d@%d', [nDisplayWidth, nDisplayHeight, nDisplayBPP, nDisplayRefreshrate] ) ) );
     If glutGameModeGet( GLUT_GAME_MODE_POSSIBLE ) = 0 Then CheckDisplay := False Else CheckDisplay := True;
End;



Procedure SwitchDisplay () ; cdecl;
Begin
     If bDisplayFullscreen Then Begin
        bDisplayFullscreen := False;
        glutLeaveGameMode();
        glutInitDisplayMode( GLUT_RGB or GLUT_DOUBLE or GLUT_DEPTH );
        glutInitWindowSize( nWindowWidth, nWindowHeight );
        glutInitWindowPosition( nWindowLeft, nWindowTop );
        glutCreateWindow( PChar(sWindowTitle) );
     End Else Begin
        bDisplayFullscreen := True;
        glutDestroyWindow( glutGetWindow() );
        glutGameModeString( PChar( Format( '%dx%d:%d@%d', [nDisplayWidth, nDisplayHeight, nDisplayBPP, nDisplayRefreshrate] ) ) );
        glutEnterGameMode();
        glutSetCursor( GLUT_CURSOR_NONE );
     End;

     glutReshapeFunc( @OGLWindow );
     glutDisplayFunc( @OGLRender );
     glutIdleFunc( @OGLTimer );
     glutKeyboardFunc( @OGLKeyDown );
     glutKeyboardUpFunc( @OGLKeyUp );
     glutSpecialFunc( @OGLKeyDownS );
     glutSpecialUpFunc( @OGLKeyUpS );
     glutMouseFunc( @OGLMouseButton );
     glutPassiveMotionFunc( @OGLMouseMove );

     ReloadDataStack();
End;



Procedure InitGlut ( sTitle : String ; pCallback : GameCallback ) ;
    Function GetShaderSource( sFile : String ) : PChar;
    Var F : TEXT;
        T, S : String;
    Begin
         S := '';
         Assign( F, sFile );
         Reset( F );
         While Not EOF(F) Do
         Begin
              ReadLn( F, T );
              S := S + T;
         End;
         Close( F );
         GetShaderSource := PChar(S);
    End;
    Function GetShaderError( tHandle : GLenum ) : String;
    Var
       maxLength : Integer;
    Begin
       maxLength := 0;
       glGetObjectParameterivARB( tHandle, GL_OBJECT_INFO_LOG_LENGTH_ARB, @maxLength );
       SetLength(Result, maxLength);
       If maxLength > 0 Then Begin
          glGetInfoLogARB(tHandle, maxLength, @maxLength, @Result[1]);
          SetLength(Result, maxLength);
       End;
    End;
Var p : PChar;
    b : GLint;
Begin
     OGLCallback := pCallback;
  
     sWindowTitle := sTitle;
     
     glutInit( @argc, argv );

     If bDisplayFullscreen Then Begin
        glutInitDisplayMode( GLUT_RGB or GLUT_DOUBLE or GLUT_DEPTH );
        glutGameModeString( PChar( Format( '%dx%d:%d@%d', [nDisplayWidth, nDisplayHeight, nDisplayBPP, nDisplayRefreshrate] ) ) );
        glutEnterGameMode();
        glutSetCursor( GLUT_CURSOR_NONE );
     End Else Begin
        glutInitDisplayMode( GLUT_RGB or GLUT_DOUBLE or GLUT_DEPTH );
        glutInitWindowSize( nWindowWidth, nWindowHeight );
        glutInitWindowPosition( nWindowLeft, nWindowTop );
        glutCreateWindow( PChar(sWindowTitle) );
     End;

     glutReshapeFunc( @OGLWindow );
     glutDisplayFunc( @OGLRender );
     glutIdleFunc( @OGLTimer );
     glutKeyboardFunc( @OGLKeyDown );
     glutKeyboardUpFunc( @OGLKeyUp );
     glutSpecialFunc( @OGLKeyDownS );
     glutSpecialUpFunc( @OGLKeyUpS );
     glutMouseFunc( @OGLMouseButton );
     glutPassiveMotionFunc( @OGLMouseMove );

     If bDebug Then Begin
        AddLineToConsole( 'OpenGL Infos :' );
        AddLineToConsole( '   Vendor : ' + PChar(glGetString(GL_VENDOR)) );
        AddLineToConsole( '   Renderer : ' + PChar(glGetString(GL_RENDERER)) );
        AddLineToConsole( '   Version : ' + PChar(glGetString(GL_VERSION)) );
        AddLineToConsole( '   Extensions : ' + PChar(glGetString(GL_EXTENSIONS)) );
     End;

     If Not Load_GL_ARB_vertex_buffer_object() Then Begin
        AddLineToConsole( 'OpenGL Error : GL_ARB_vertex_buffer_object extension is not supported !' );
     End;
     If Not Load_GL_ARB_shader_objects() Then Begin
        AddLineToConsole( 'OpenGL Error : GL_ARB_shader_objects extension is not supported !' );
     End;
     If Not Load_GL_ARB_shading_language_100() Then Begin
        AddLineToConsole( 'OpenGL Error : GL_ARB_shading_language_100 extension is not supported !' );
     End;
     If Not Load_GL_ARB_vertex_shader() Then Begin
        AddLineToConsole( 'OpenGL Error : GL_ARB_vertex_shader extension is not supported !' );
     End;
     If Not Load_GL_ARB_fragment_shader() Then Begin
        AddLineToConsole( 'OpenGL Error : GL_ARB_fragment_shader extension is not supported !' );
     End;

     ShaderProgram := glCreateProgramObjectARB();
     VertexShader := glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB);
     FragmentShader := glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);

     p := GetShaderSource('./shaders/bomb.vs');
     glShaderSourceARB( VertexShader, 1, @p, NIL );
     p := GetShaderSource('./shaders/bomb.ps');
     glShaderSourceARB( FragmentShader, 1, @p, NIL );

     glCompileShaderARB( VertexShader );
     glGetObjectParameterivARB( VertexShader, GL_COMPILE_STATUS, @b );
     AddLineToConsole( 'Vertex Shader Compilation Status : ' + GetShaderError(VertexShader) );

     glCompileShaderARB( FragmentShader );
     glGetObjectParameterivARB( FragmentShader, GL_COMPILE_STATUS, @b );
     AddLineToConsole( 'Fragment Shader Compilation Status : ' + GetShaderError(FragmentShader) );

     glAttachObjectARB( ShaderProgram, VertexShader );
     glAttachObjectARB( ShaderProgram, FragmentShader );

     glLinkProgramARB( ShaderProgram );
     glGetObjectParameterivARB( ShaderProgram, GL_LINK_STATUS, @b );
     AddLineToConsole( 'Shader Program Link Status : ' + GetShaderError(ShaderProgram) );

     glLinkProgramARB( ShaderProgram );
     glGetObjectParameterivARB( ShaderProgram, GL_VALIDATE_STATUS, @b );
     AddLineToConsole( 'Shader Program Validation Status : ' + GetShaderError(ShaderProgram) );

     glUseProgramObjectARB( 0 );

     fTime := GetTime();
     fDelta := GetTime();
End;



Procedure ExitGlut () ;
Begin
     nWindowLeft := glutGet( GLUT_WINDOW_X );
     nWindowTop := glutGet( GLUT_WINDOW_Y );
     nWindowWidth := glutGet( GLUT_WINDOW_WIDTH );
     nWindowHeight := glutGet( GLUT_WINDOW_HEIGHT );
End;



Procedure ExecGlut () ;
Begin
     glutMainLoop();
End;





























End.

