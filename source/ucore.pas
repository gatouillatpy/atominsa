Unit UCore;

{$mode objfpc}{$H+}
{$ASMMODE INTEL}

Interface

Uses Classes, SysUtils, LazJPEG, Math, Graphics, IntfGraphics,
     GL, GLU, GLUT, GLEXT,
     fmod, fmodtypes, fmoderrors,
     UForm, UUtils, USetup;



Const KEY_UP = -GLUT_KEY_UP;
      KEY_DOWN = -GLUT_KEY_DOWN;
      KEY_LEFT = -GLUT_KEY_LEFT;
      KEY_RIGHT = -GLUT_KEY_RIGHT;
      KEY_F11 = -GLUT_KEY_F11;

Const KEY_TAB = 9;
      KEY_ESC = 27;
      KEY_ENTER = 13;
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

Function AddTexture ( sFile : String ; nIndex : LongInt ) : LPOGLTexture;
Procedure DelTexture ( nIndex : LongInt ) ;
Procedure SetTexture( nStage : Integer ; nIndex : LongInt ) ;
Procedure FreeTexture ( pTexture : LPOGLTexture ) ;

Function AddMesh ( sFile : String ; nIndex : LongInt ) : LPOGLMesh ;
Procedure DelMesh ( nIndex : LongInt ) ;
Procedure DrawMesh ( nIndex : LongInt ; t : Boolean ) ;
Procedure FreeMesh ( pMesh : LPOGLMesh ) ;

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



Procedure BindKeyStd ( nKey : Integer ; bInstant : Boolean ; pCallback : KeyCallbackStd ) ;
Procedure BindKeyObj ( nKey : Integer ; bInstant : Boolean ; pCallback : KeyCallbackObj ) ;
Procedure ExecKey ( nKey : Integer ; bInstant : Boolean ; bSpecial : Boolean ) ;

Procedure BindButton ( nButton : Integer ; pCallback : ButtonCallback ) ;

Function KeyToStr( nKey : Integer ) : String ;

Function GetMouseX() : Integer ;
Function GetMouseY() : Integer ;
Function GetMouseDX() : Single ;
Function GetMouseDY() : Single ;

Procedure ClearInput () ;

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



Implementation





























////////////////////////////////////////////////////////////////////////////////
// FONCTIONS DE GESTION DE LA PILE DE DONNEES                                 //
////////////////////////////////////////////////////////////////////////////////



Const DATA_NONE    = 0;
Const DATA_MESH    = 1;
Const DATA_TEXTURE = 2;
Const DATA_SOUND   = 3;
Const DATA_MUSIC   = 4;



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
// InitDataStack : Cr�e le premier �l�ment de la pile de donn�es.             //
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
// FreeDataStack : Vide la pile de donn�es et lib�re la m�moire.              //
////////////////////////////////////////////////////////////////////////////////
Procedure FreeDataStack () ;
Var i : LongInt;
    pDataItem : LPDataItem;
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
// ReloadDataStack : Recharge les �l�ments de la pile de donn�es.             //
////////////////////////////////////////////////////////////////////////////////
Procedure ReloadDataStack () ;
Var i : LongInt;
    pDataTemp : LPDataItem;
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
// GetTime : Renvoie le temps pass� (en secondes) depuis l'ex�cution du jeu.  //
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
// GetFPS : Renvoie le framerate bas� sur la derni�re seconde de rendu.       //
////////////////////////////////////////////////////////////////////////////////
Function GetFPS () : Single ;
Begin
     GetFPS := nFPS;
End;



////////////////////////////////////////////////////////////////////////////////
// GetDelta : Renvoie le temps pass� (en secondes) entre les deux derni�res   //
//            images rendues.                                                 //
////////////////////////////////////////////////////////////////////////////////
Function GetDelta () : Single ;
Begin
     GetDelta := fDelta;
End;



////////////////////////////////////////////////////////////////////////////////
// AddTimer : Ajoute une callback � la pile de la minuterie et d�finie un     //
//            d�lai d'ex�cution.                                              //
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
// CheckTimer : V�rifie en fonction du temps s'il y a une callback �          //
//              �xecuter.                                                     //
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
// FreeTimer : Lib�re la minuterie de toutes ses donn�es.   	              //
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
// AddTexture : Charge une OGLTexture depuis un fichier bitmap, l'ajoute � la //
//              pile de donn�es, puis renvoie son pointeur.                   //
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
     AddLineToConsole( 'Loading texture ' + sFile + '...' );

     // cr�ation du pointeur vers la nouvelle texture
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
     
     // r�cup�re l'adresse m�moire des pixels
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

     // r�cup�re les pixels du TImage et les attribue � la texture
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
     
     // envoie la texture dans la m�moire vid�o
     glEnable( GL_TEXTURE_2D );
     glGenTextures( 1, @pTexture^.ID );
     glBindTexture( GL_TEXTURE_2D, pTexture^.ID );
     glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
     glTexImage2D( GL_TEXTURE_2D, 0, 3, (p + 1), (q + 1), 0, GL_RGB, GL_UNSIGNED_BYTE, @pTexture^.Data[0] );

     // ajout de la texture � la pile de donn�es
     AddItem( DATA_TEXTURE, nIndex, pTexture, sFile );

     AddStringToConsole( Format('OK. (%.0f bytes)', [3.0 * (p + 1) * (q + 1)]) );

     AddTexture := pTexture;
End;



Procedure DelTexture ( nIndex : LongInt ) ;
Var pTexture : LPOGLTexture;
Begin
     // recherche de la texture � s�lectionner en fonction de son indice
     pTexture := FindItem( DATA_TEXTURE, nIndex );
     If pTexture = NIL Then Exit;

     // destruction de la texture
     FreeTexture( pTexture );

     // destruction de l'objet dans la pile de donn�es
     DelItem( DATA_TEXTURE, nIndex );
End;



Procedure FreeTexture ( pTexture : LPOGLTexture ) ;
Begin
     glDeleteTextures( 1, @pTexture^.ID );
     Finalize( pTexture^.Data );
     Dispose( pTexture );
End;



////////////////////////////////////////////////////////////////////////////////
// SetTexture : D�finie la texture active en fonction de son indice.          //
////////////////////////////////////////////////////////////////////////////////
Procedure SetTexture( nStage : Integer ; nIndex : LongInt ) ;
Var pTexture : LPOGLTexture;
    nID : GLUInt;
Begin
     If nIndex = 0 Then Begin
        glDisable( GL_TEXTURE_2D );
        Exit;
     End;
     
     // recherche de la texture � s�lectionner en fonction de son indice
     pTexture := FindItem( DATA_TEXTURE, nIndex );
     If pTexture = NIL Then Exit;

     // active le texturing
     glEnable( GL_TEXTURE_2D );

     // appelle la texture d�sir�e
     glBindTexture( GL_TEXTURE_2D, pTexture^.ID );

     // d�finie les techniques de rendu
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
     glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
End;



////////////////////////////////////////////////////////////////////////////////
// AddMesh : Charge un OGLMesh depuis un fichier (*.M12), l'ajoute � la pile  //
//           de donn�es, puis renvoie son pointeur.                           //
////////////////////////////////////////////////////////////////////////////////
Function AddMesh ( sFile : String ; nIndex : LongInt ) : LPOGLMesh ;
Var ioLong : File Of LongInt ; ioPolygon : File Of OGLPolygon ; ioVertex : File Of OGLVertex ;
    pMesh : LPOGLMesh ;
    nSize : LongInt ;
    i, j : LongInt ;
    pDataItem : LPDataItem;
    s : String;
Begin
     j := 0;

     AddLineToConsole( 'Loading mesh ' + sFile + '...' );

     // cr�ation du pointeur vers le nouveau mesh
     New( pMesh );

     // lecture du nombre de polygones
     Assign( ioLong, sFile );
     Reset( ioLong, 4 );
     Seek( ioLong, j );
     Read( ioLong, nSize ); j += 1;
     Close( ioLong );
        
     // allocation de la m�moire pour le tableau de polygones
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

     // allocation de la m�moire pour le tableau de vertices
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

     // ajout du mesh � la pile de donn�es
     AddItem( DATA_MESH, nIndex, pMesh, sFile );

     AddStringToConsole( Format('OK. (%d bytes)', [j*4]) );

     AddMesh := pMesh;
End;



////////////////////////////////////////////////////////////////////////////////
// DrawMesh : Proc�de au rendu d'un OGLMesh en fonction de son indice.        //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawMesh ( nIndex : LongInt ; t : Boolean ) ;
Var i : LongInt ;
    pMesh : LPOGLMesh ;
    pDataItem : LPDataItem;
    p : GLIndex;
    v : GLVector;
Begin
     // recherche du mesh � afficher en fonction de son indice
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
     
     glVertexPointer(3, GL_FLOAT, 0, @pMesh^.VectorArray[0]);
     glNormalPointer(GL_FLOAT, 0, @pMesh^.NormalArray[0]);
     glColorPointer(3, GL_FLOAT, 0, @pMesh^.ColorArray[0]);
     glTexCoordPointer(2, GL_FLOAT, 0, @pMesh^.TextureArray[0]);

     glDrawElements(GL_TRIANGLES, pMesh^.PolygonCount * 3, GL_UNSIGNED_INT, @pMesh^.IndexArray[0]);

     glDisableClientState(GL_VERTEX_ARRAY);
     glDisableClientState(GL_NORMAL_ARRAY);
     glDisableClientState(GL_COLOR_ARRAY);
     glDisableClientState(GL_TEXTURE_COORD_ARRAY);

     glDisable( GL_BLEND );
End;



Procedure FreeMesh ( pMesh : LPOGLMesh ) ;
Begin
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
     // recherche du mesh � s�lectionner en fonction de son indice
     pMesh := FindItem( DATA_MESH, nIndex );
     If pMesh = NIL Then Exit;

     // destruction de la texture
     FreeMesh( pMesh );

     // destruction de l'objet dans la pile de donn�es
     DelItem( DATA_MESH, nIndex );
End;



////////////////////////////////////////////////////////////////////////////////
// DrawText : Proc�de au rendu d'une ligne de texte � l'�cran.                //
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
// DrawImage : Proc�de au rendu d'une image � l'�cran.                       //
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
// DrawSprite : Proc�de au rendu d'un sprite � l'�cran.                       //
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
// DrawSkybox : Proc�de au rendu d'une skybox � l'�cran.                      //
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
// DrawChar : Proc�de au rendu d'un caract�re graphique � l'�cran.            //
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


var tg : integer = 0;

////////////////////////////////////////////////////////////////////////////////
// DrawString : Proc�de au rendu d'une OGLString en avec un effet.            //
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

     // d�finie les techniques de rendu
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
     glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
End;



////////////////////////////////////////////////////////////////////////////////
// InitBox : Initialise une boite de dialogue.                                //
////////////////////////////////////////////////////////////////////////////////
Procedure InitBox ( s1, s2 : String ) ;
Var u, v, w : Single;
Var Data : Pointer;
Begin
     u := GetSquareWidth * 2 / GetRenderWidth;
     v := GetSquareHeight * 2 / GetRenderHeight;
     w := GetSquareWidth / GetSquareHeight;
     
     // appel d'une texture de rendu
     PutRenderTexture();

     glEnable( GL_TEXTURE_2D );
     glBindTexture( GL_TEXTURE_2D, BackBuffer );

     DrawImage( (u - 1.0) * w, v - 1.0, -1.0, u * w, v, 1.0, 1.0, 1.0, 1.0, False );

     // r�cup�ration de la texture de rendu
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
// AddSound : Charge un son depuis un fichier (*.wav ; *.mp3), et l'ajoute �  //
//            la pile de donn�es.                                             //
////////////////////////////////////////////////////////////////////////////////
Procedure AddSound ( sFile : String ; nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     AddLineToConsole( 'Loading sound ' + sFile + '...' );

     // chargement du son
     pSound := FSOUND_Sample_Load( FSOUND_FREE, PChar(sFile), FSOUND_2D, 0, 0 );
     If pSound = NIL Then Begin
        AddStringToConsole( 'FAILED. ' + FMOD_ErrorString(FSOUND_GetError()) );
        Exit;
     End;

     // ajout du son � la pile de donn�es
     AddItem( DATA_SOUND, nIndex, pSound, sFile );
     
     AddStringToConsole( Format('OK. (%d bytes)', [FSOUND_Sample_GetLength(pSound)*2]) );
End;



////////////////////////////////////////////////////////////////////////////////
// DelSound : Supprime un son de la pile de donn�es.                          //
////////////////////////////////////////////////////////////////////////////////
Procedure DelSound ( nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     // recherche du son � s�lectionner en fonction de son indice
     pSound := FindItem( DATA_SOUND, nIndex );
     If pSound = NIL Then Exit;

     // destruction de lu son
     FSOUND_Sample_Free( pSound );

     // destruction de l'objet dans la pile de donn�es
     DelItem( DATA_SOUND, nIndex );
End;



////////////////////////////////////////////////////////////////////////////////
// AddMusic : Charge une musique depuis un fichier (*.mod ; *.s3m), et        //
//            l'ajoute � la pile de donn�es.                                  //
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

     // ajout de la musique � la pile de donn�es
     AddItem( DATA_MUSIC, nIndex, pMusic, sFile );

     AddStringToConsole( Format('OK. (%d bytes)', [FMUSIC_GetNumSamples(pMusic)]) );
End;



////////////////////////////////////////////////////////////////////////////////
// PlaySound : Proc�de � la lecture d'un son en fonction de son indice.       //
////////////////////////////////////////////////////////////////////////////////
Procedure PlaySound ( nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     // recherche du son � lire en fonction de son indice
     pSound := FindItem( DATA_SOUND, nIndex );
     If pSound = NIL Then Exit;
     
     // lecture du son
     FSOUND_PlaySound( 1, pSound );
End;



////////////////////////////////////////////////////////////////////////////////
// StopSound : Proc�de � l'arr�t d'un son en fonction de son indice.          //
////////////////////////////////////////////////////////////////////////////////
Procedure StopSound ( nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     // arr�t du son
     FSOUND_StopSound( 1 );
End;



////////////////////////////////////////////////////////////////////////////////
// PlayMusic : Proc�de � la lecture d'une musique en fonction de son indice.  //
////////////////////////////////////////////////////////////////////////////////
Procedure PlayMusic ( nIndex : LongInt ) ;
Var pMusic : PFMusicModule;
Begin
     // recherche de la musique � lire en fonction de son indice
     pMusic := FindItem( DATA_MUSIC, nIndex );
     If pMusic = NIL Then Exit;

     // lecture de la musique
     FMUSIC_PlaySong( pMusic );
End;



////////////////////////////////////////////////////////////////////////////////
// StopMusic : Proc�de � l'arr�t d'une musique en fonction de son indice.     //
////////////////////////////////////////////////////////////////////////////////
Procedure StopMusic ( nIndex : LongInt ) ;
Var i : LongInt;
    pMusic : PFMusicModule;
    pDataItem : LPDataItem;
Begin
     // recherche de la musique � lire en fonction de son indice
     pMusic := FindItem( DATA_MUSIC, nIndex );
     If pMusic = NIL Then Exit;

     // arr�t de la musique
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
                      callbackstd : KeyCallbackStd;
                      callbackobj : KeyCallbackObj;
                      next : LPKeyItem;
                END;
Var pKeyStack : LPKeyItem = NIL;



Var bKey : Array [0..255] Of Boolean ;
Var bKeyS : Array [0..255] Of Boolean ;



Var nX, nY : Integer; // coordonn�es du pointeur de souris
    dX, dY : Single; // derni�re petite d�viation du pointeur de souris
    


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
     KeyToStr := IntToStr( nKey );
End;



////////////////////////////////////////////////////////////////////////////////
// BindKey : Ajoute une callback � la pile de touches.                        //
////////////////////////////////////////////////////////////////////////////////
Procedure BindKeyStd ( nKey : Integer ; bInstant : Boolean ; pCallback : KeyCallbackStd ) ;
Var pKeyItem : LPKeyItem ;
Begin
     pKeyItem := pKeyStack;
     While pKeyItem <> NIL Do
     Begin
          If (pKeyItem^.key = -nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = True) Then Begin
             pKeyItem^.callbackstd := pCallback;
             Exit;
          End;
          If (pKeyItem^.key = nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = False) Then Begin
             pKeyItem^.callbackstd := pCallback;
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
     pKeyStack^.callbackstd := pCallback;
     pKeyStack^.callbackobj := NIL;
End;

Procedure BindKeyObj ( nKey : Integer ; bInstant : Boolean ; pCallback : KeyCallbackObj ) ;
Var pKeyItem : LPKeyItem ;
Begin
     pKeyItem := pKeyStack;
     While pKeyItem <> NIL Do
     Begin
          If (pKeyItem^.key = -nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = True) Then Begin
             pKeyItem^.callbackobj := pCallback;
             Exit;
          End;
          If (pKeyItem^.key = nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = False) Then Begin
             pKeyItem^.callbackobj := pCallback;
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
     pKeyStack^.callbackstd := NIL;
     pKeyStack^.callbackobj := pCallback;
End;



////////////////////////////////////////////////////////////////////////////////
// ExecKey : Execute la callback correspondante � la touche enfonc�e.         //
////////////////////////////////////////////////////////////////////////////////
Procedure ExecKey ( nKey : Integer ; bInstant : Boolean ; bSpecial : Boolean ) ;
Var pKeyItem : LPKeyItem ;
Begin
     // regarde si la touche enfonc�e a �t� d�finie et appelle la callback correspondante
     pKeyItem := pKeyStack;
     While pKeyItem <> NIL Do
     Begin
          If (pKeyItem^.key = nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = bSpecial) Then Begin
             If (pKeyItem^.callbackstd = NIL) And (pKeyItem^.callbackobj <> NIL) Then pKeyItem^.callbackobj( GetDelta() );
             If (pKeyItem^.callbackobj = NIL) And (pKeyItem^.callbackstd <> NIL) Then pKeyItem^.callbackstd();
          End;
          pKeyItem := pKeyItem^.next;
     End;
End;



////////////////////////////////////////////////////////////////////////////////
// BindButton : Attribue une callback � un bouton de souris.                  //
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
     If bKey[k] = False Then ExecKey( k, True, False );
     bKey[k] := True;
End;



Procedure OGLKeyUp( k : Byte ; x, y : LongInt ); cdecl; overload;
Begin
     bKey[k] := False;
End;



Procedure OGLKeyDownS( k : LongInt ; x, y : LongInt ); cdecl; overload;
Begin
     If bKeyS[k] = False Then ExecKey( k, True, True );
     bKeyS[k] := True;
End;



Procedure OGLKeyUpS( k : LongInt ; x, y : LongInt ); cdecl; overload;
Begin
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
         If bKey[k] = True Then ExecKey( k, False, False );
         If bKeyS[k] = True Then ExecKey( k, False, True );
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
        Window.Memo.Lines.Add( 'OpenGL Infos :' );
        Window.Memo.Lines.Add( '   Vendor : ' + PChar(glGetString(GL_VENDOR)) );
        Window.Memo.Lines.Add( '   Renderer : ' + PChar(glGetString(GL_RENDERER)) );
        Window.Memo.Lines.Add( '   Version : ' + PChar(glGetString(GL_VERSION)) );
        Window.Memo.Lines.Add( '   Extensions : ' + PChar(glGetString(GL_EXTENSIONS)) );
     End;

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

