Unit UCore;

{$mode objfpc}{$H+}
{$ASMMODE INTEL}

Interface

Uses Classes, SysUtils, LazJPEG, Math, Graphics, IntfGraphics,
     GL, GLU, GLUT, GLEXT,
     fmod, fmodtypes, fmoderrors,
     UForm, UUtils;



Const SCREENWIDTH = 640;
      SCREENHEIGHT = 480;

      KEY_UP = GLUT_KEY_UP;
      KEY_DOWN = GLUT_KEY_DOWN;
      KEY_LEFT = GLUT_KEY_LEFT;
      KEY_RIGHT = GLUT_KEY_RIGHT;
      KEY_ESC = 27;
      KEY_SPACE = 32;
      KEY_TAB = GLUT_KEY_F1;
      KEY_ZERO = 48;
      
      KEY_Z = 122;
      KEY_S = 115;
      KEY_Q = 113;
      KEY_D = 100;
      KEY_B = 98;

      FONT_NORMAL  = 1 ;
      FONT_BOLD  = 2 ;
      FONT_HELVETICA_18 = 3 ;

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
     KeyCallback = Procedure ( fTime : Single ) Of Object ; cdecl;
     ButtonCallback = Procedure () ; cdecl;
     TimerCallback = Procedure () Of Object ; cdecl;


Procedure InitDataStack () ;
Procedure FreeDataStack () ;

Function AddTexture ( sFile : String ; nIndex : LongInt ) : LPOGLTexture;
Procedure SetTexture( nStage : Integer ; nIndex : LongInt ) ;

Function AddMesh ( strFile : String ; nIndex : LongInt ) : LPOGLMesh ;
Procedure DrawMesh ( nIndex : LongInt ; r, g, b : Single ; t : Boolean ) ;

Procedure DrawText ( x, y : Single ; r, g, b : Single ; nFont : integer ;sText : String ) ;

Procedure DrawImage ( x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;
Procedure DrawSprite ( u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;

Procedure DrawChar ( c : Char ; p : Boolean ; x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;

Procedure SetProjectionMatrix ( fFOV : Single ; fRatio : Single ; fNearPlane, fFarPlane : Single ) ;
Procedure SetCameraMatrix ( ex, ey, ez, cx, cy, cz, upx, upy, upz : Single ) ;
Procedure PushObjectMatrix ( tx, ty, tz, sx, sy, sz, rx, ry, rz : Single ) ;
Procedure PopObjectMatrix () ;

Procedure SetString ( id : Integer ; s : String ; t1, t2, t3 : Single ) ;
Procedure DrawString ( id : Integer ; x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;

Procedure PushBillboardMatrix( camX, camY, camZ, objPosX, objPosY, objPosZ : Single );

Procedure EnableLighting() ;
Procedure DisableLighting() ;
Procedure SetLight( k : Integer ; x, y, z : Single ; r, g, b, a : Single ; a0, a1, a2 : Single ; t : Boolean ) ;
Procedure SetMaterial( r, g, b : Single ; t : Boolean ) ;



Function GetTime () : Single ;
Function GetFPS () : Single ;
Function GetDelta () : Single;

Procedure AddTimer( fTime : Single ; pCallback : TimerCallback ) ;
Procedure CheckTimer () ;
Procedure FreeTimer();



Procedure BindKey ( nKey : Integer ; bInstant : Boolean ; bSpecial : Boolean ; pCallback : KeyCallback ) ;
Procedure ExecKey ( nKey : Integer ; bInstant : Boolean ; bSpecial : Boolean ) ;

Procedure BindButton ( nButton : Integer ; pCallback : ButtonCallback ) ;

Function GetMouseX() : Integer ;
Function GetMouseY() : Integer ;
Function GetMouseDX() : Single ;
Function GetMouseDY() : Single ;

Function GetKey( nKey : Integer ) : Boolean ;
Function GetKeyS( nKey : Integer ) : Boolean ;



Procedure InitFMod () ;
Procedure ExitFMod () ;

Procedure AddSound ( strFile : String ; nIndex : LongInt ) ;
Procedure AddMusic ( strFile : String ; nIndex : LongInt ) ;
Procedure PlaySound ( nIndex : LongInt ) ;
Procedure PlayMusic ( nIndex : LongInt ) ;
Procedure StopSound ( nIndex : LongInt ) ;
Procedure StopMusic ( nIndex : LongInt ) ;



Procedure InitGlut ( sTitle : String ; pCallback : GameCallback ) ;
Procedure ExecGlut () ;



Function GetWidth : Integer;
Function GetHeight : Integer;



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
     pDataStack^.next := NIL;
End;



////////////////////////////////////////////////////////////////////////////////
// FreeDataStack : Vide la pile de données et libère la mémoire.              //
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
                    If pMesh <> NIL Then Dispose( pMesh );
               End;
               DATA_TEXTURE :
               Begin
                    pTexture := pDataStack^.item;
                    If pTexture <> NIL Then Dispose( pTexture );
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



Procedure AddItem( nData : Integer ; nIndex : Integer ; pItem : Pointer ) ;
Var pDataItem : LPDataItem;
Begin
     pDataItem := pDataStack;
     New( pDataStack );
     pDataStack^.count := pDataItem^.count + 1;
     pDataStack^.index := nIndex;
     pDataStack^.data := nData;
     pDataStack^.item := pItem;
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
    fTime  : Single;
    nFPS   : Integer;
    fDelta : Single;



////////////////////////////////////////////////////////////////////////////////
// GetTime : Renvoie le temps passé (en secondes) depuis l'exécution du jeu.  //
////////////////////////////////////////////////////////////////////////////////
Function GetTime () : Single ;
Begin
     GetTime := glutGet(GLUT_ELAPSED_TIME) * 0.001;
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
     GetDelta := GetTime() - fDelta;
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
    i, j, k : Integer;
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
     k := 3 * ((h - j) * (w + 1) + i);
End;
Begin
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
     
     TempIntfImg := TLazIntfImage.Create(0,0);
     TempIntfImg.LoadFromBitmap( Window.Image.Picture.Bitmap.Handle, Window.Image.Picture.Bitmap.MaskHandle );
     src := TempIntfImg.PixelData;
  
     // attribution de la taille de la texture
     pTexture^.Width := Window.Image.Picture.Width;
     pTexture^.Height := Window.Image.Picture.Height;

     // récupère les pixels du TImage et les attribue à la texture
     SetLength( pTexture^.Data, 3 * pTexture^.Width * pTexture^.Height );
     {For j := 0 To pTexture^.Height - 1 Do Begin
         For i := 0 To pTexture^.Width - 1 Do Begin
	     k := 3 * ((pTexture^.Height - 1 - j) * pTexture^.Width + i);
             c := ColorToRGB(Window.Image.Canvas.Pixels[i,j]);
	     pTexture^.Data[k+0] := c;
	     pTexture^.Data[k+1] := c shr 8;
	     pTexture^.Data[k+2] := c shr 16;
	 End;
     End;}
     // ON PEUT SUREMENT FAIRE CA MIEUX, LA ON PREND TROP DE TEMPS
     w := pTexture^.Width - 1;
     h := pTexture^.Height - 1;
     dst := @pTexture^.Data[0];
     //Window.Caption := Format('addr:%d',[w]);
     Asm
        push eax
        push ebx
        push ecx
        
        mov j, 0
        @yloop:

              mov i, 0
              @xloop:
                    {mov eax, h                           // = h
                    sub eax, 1                           // - 1
                    sub eax, j                           // - j
                    mov eax, ebx
                    mov ebx, w
                    mul ebx                              // * w
                    mov ebx, edx
                    add ebx, i                           // + i
                    mov eax, ebx
                    mov ebx, 3
                    mul ebx                              // * 3
                    mov ecx, edx}
                    
                    call inc

                    mov ecx, k
                    add ecx, dst
                    add src, 2
                    mov edx, src
                    mov al, byte ptr [edx]
                    mov r, al;
                    mov byte ptr [ecx], al // composante rouge

                    add ecx, 1
                    sub src, 1
                    mov edx, src
                    mov al, byte ptr [edx]
                    mov byte ptr [ecx], al // composante verte
                    mov g, al;

                    add ecx, 1
                    sub src, 1
                    mov edx, src
                    mov al, byte ptr [edx]
                    mov byte ptr [ecx], al // composante bleue
                    mov b, al;

                    add src, 4

                    add i, 1
                    mov eax, i
                    mov ebx, w
                    cmp eax, ebx
                    jle @xloop
                    
              add j, 1
              mov eax, j
              mov ebx, h
              cmp eax, ebx
              jle @yloop
              
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
     glTexImage2D( GL_TEXTURE_2D, 0, 3, pTexture^.Width, pTexture^.Height, 0, GL_RGB, GL_UNSIGNED_BYTE, @pTexture^.Data[0] );

     // ajout de la texture à la pile de données
     AddItem( DATA_TEXTURE, nIndex, pTexture );

     AddStringToConsole( Format('OK. (%d bytes)', [3 * pTexture^.Height * pTexture^.Width]) );

     AddTexture := pTexture;
End;



////////////////////////////////////////////////////////////////////////////////
// SetTexture : Définie la texture active en fonction de son indice.          //
////////////////////////////////////////////////////////////////////////////////
Procedure SetTexture( nStage : Integer ; nIndex : LongInt ) ;
Var pTexture : LPOGLTexture;
    nID : GLUInt;
Begin
     If nIndex = 0 Then Begin
        glDisable( GL_TEXTURE_2D );
        Exit;
     End;
     
     // recherche de la texture à sélectionner en fonction de son indice
     pTexture := FindItem( DATA_TEXTURE, nIndex );
     If pTexture = NIL Then Exit;
	 
     // sélectionne l'étage de texture
     //glActiveTextureARB(GL_TEXTURE0_ARB);

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
Function AddMesh ( strFile : String ; nIndex : LongInt ) : LPOGLMesh ;
Var ioLong : File Of LongInt ; ioPolygon : File Of OGLPolygon ; ioVertex : File Of OGLVertex ;
    pMesh : LPOGLMesh ;
    nSize : LongInt ;
    i, j : LongInt ;
    pDataItem : LPDataItem;
    s : String;
Begin
     j := 0;

     AddLineToConsole( 'Loading mesh ' + strFile + '...' );

     // création du pointeur vers le nouveau mesh
     New( pMesh );

     // lecture du nombre de polygones
     Assign( ioLong, strFile );
     Reset( ioLong, 4 );
     Seek( ioLong, j );
     Read( ioLong, nSize ); j += 1;
     Close( ioLong );
        
     // allocation de la mémoire pour le tableau de polygones
     pMesh^.PolygonCount := nSize;
     SetLength( pMesh^.PolygonData, nSize );
     SetLength( pMesh^.IndexArray, nSize );

     // lecture de chaque polygone
     Assign( ioPolygon, strFile );
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
     Assign( ioLong, strFile );
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
     Assign( ioVertex, strFile );
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
          pMesh^.TextureArray[i].v := pMesh^.VertexData[i]^.tv;
     End;
     Close( ioVertex );

     // ajout du mesh à la pile de données
     AddItem( DATA_MESH, nIndex, pMesh );

     AddStringToConsole( Format('OK. (%d bytes)', [j*4]) );

     AddMesh := pMesh;
End;

////////////////////////////////////////////////////////////////////////////////
// DrawMesh : Procède au rendu d'un OGLMesh en fonction de son indice.        //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawMesh ( nIndex : LongInt ; r, g, b : Single ; t : Boolean ) ;
Var i : LongInt ;
    pMesh : LPOGLMesh ;
    pDataItem : LPDataItem;
    p : OGLPolygon;
    v : OGLVertex;
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
         p := pMesh^.PolygonData[i]^;

         v := pMesh^.VertexData[p.id0]^;
         glNormal3f(v.nx, v.ny, v.nz);
         glVertex3f(v.x, v.y, v.z);
         glColor3f(r, g, b);

         v := pMesh^.VertexData[p.id1]^;
         glNormal3f(v.nx, v.ny, v.nz);
         glVertex3f(v.x, v.y, v.z);
         glColor3f(r, g, b);

         v := pMesh^.VertexData[p.id2]^;
         glNormal3f(v.nx, v.ny, v.nz);
         glVertex3f(v.x, v.y, v.z);
         glColor3f(r, g, b);
     End;
     glEnd;}

     //glDisable( GL_TEXTURE_2D );

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



////////////////////////////////////////////////////////////////////////////////
// DrawText : Procède au rendu d'une ligne de texte à l'écran.                //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawText ( x, y : Single ; r, g, b : Single ; nFont : integer ;
sText : String ) ;
Var i : Integer;
    pFont : Pointer;
Begin
 Case nFont of
      FONT_NORMAL : pFont:=GLUT_BITMAP_8_BY_13;
      FONT_BOLD :  pFont:= GLUT_BITMAP_9_BY_15;
      FONT_HELVETICA_18 : pFont:=GLUT_BITMAP_HELVETICA_18;
 end;
     glMatrixMode( GL_PROJECTION );
     glPushMatrix;
     glLoadIdentity;
     gluOrtho2D( 0, GetWidth, 0, GetHeight );

     glMatrixMode( GL_MODELVIEW );
     glPushMatrix;
     glLoadIdentity;

     glDisable( GL_TEXTURE_2D );
     glDisable( GL_DEPTH_TEST );

     glColor3f( r, g, b );
     glRasterPos2f( x, GetHeight - y );
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
Var i : Integer;
Begin
     glMatrixMode( GL_PROJECTION );
     glLoadIdentity;
     gluPerspective( 90, GetWidth() / GetHeight(), 0.1, 1000 );

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
Var i : Integer;
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
// DrawChar : Procède au rendu d'un caractère graphique à l'écran.            //
////////////////////////////////////////////////////////////////////////////////
Var cx : Single =  0.0;
    cy : Single =  0.0;
    cz : Single = -1.0;
Procedure DrawChar ( c : Char ; p : Boolean ; x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;
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
          Else Exit;
     End;
     
     glMatrixMode( GL_PROJECTION );
     glLoadIdentity;
     gluPerspective( 90, GetWidth() / GetHeight(), 0.1, 1000 );

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
     aString[id].fTime3 := GetTime() + t1 + t2 + t3;
     aString[id].fRate  := Single(Length(s)) / t2;
     aString[id].sData  := s;
End;


var tg : integer = 0;

////////////////////////////////////////////////////////////////////////////////
// DrawString : Procède au rendu d'une OGLString en avec un effet.            //
////////////////////////////////////////////////////////////////////////////////
Procedure DrawString ( id : Integer ; x, y, z : Single ; u, v : Single ; r, g, b, a : Single ; t : Boolean ) ;
Var count : Integer;
    alpha : Single;
    value : Integer;
    k : Integer;
Begin
     If (id < 0) Or (id > 255) Then Exit;

     count := Round(GetTime() * 1000) Mod 1000;
     If (count >= 0) And (count < 450) Then alpha := a * 1.0;
     If (count >= 450) And (count < 500) Then alpha := a * Single(500 - count) * 0.02;
     If (count >= 500) And (count < 950) Then alpha := a * 0.0;
     If (count >= 950) And (count < 1000) Then alpha := a * Single(count - 950) * 0.02;

     If GetTime() <= aString[id].fTime1 Then Begin
        DrawChar( '*', False, x, y, z, u, v, r, g, b, alpha, t );
     End;

     If (GetTime() > aString[id].fTime1) And (GetTime() <= aString[id].fTime2) Then Begin
        value := Round((GetTime() - aString[id].fTime1) * aString[id].fRate);
        For k := 1 To value Do
            DrawChar( aString[id].sData[k], False, x + u * 2.2 * (k - 1), y, z, u, v, r, g, b, a, t );
        DrawChar( '*', False, x + u * 2.2 * k, y, z, u, v, r, g, b, alpha, t );
     End;
     
     If (GetTime() > aString[id].fTime2) And (GetTime() <= aString[id].fTime3) Then Begin
        For k := 1 To Length(aString[id].sData) Do
            DrawChar( aString[id].sData[k], False, x + u * 2.2 * (k - 1), y, z, u, v, r, g, b, a, t );
        DrawChar( '*', False, x + u * 2.2 * k, y, z, u, v, r, g, b, alpha, t );
     End;
End;



Function GetWidth : Integer;
Var Rect : Array[0..3] Of Integer;
Begin
     glGetIntegerv(GL_VIEWPORT, @Rect);
     Result := Rect[2] - Rect[0];
End;



Function GetHeight : Integer;
Var Rect : Array[0..3] Of Integer;
Begin
  glGetIntegerv(GL_VIEWPORT, @Rect);
  Result := Rect[3] - Rect[1];
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



Procedure SetMaterial( r, g, b : Single ; t : Boolean ) ;
Var MaterialColor : Array[0..3] Of glFloat;
Begin
     MaterialColor[0] := r;
     MaterialColor[1] := g;
     MaterialColor[2] := b;
     MaterialColor[3] := 1.0;

     glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, MaterialColor);
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
Procedure AddSound ( strFile : String ; nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     AddLineToConsole( 'Loading sound ' + strFile + '...' );

     // chargement du son
     pSound := FSOUND_Sample_Load( FSOUND_FREE, PChar(strFile), FSOUND_2D, 0, 0 );
     If pSound = NIL Then Begin
        AddStringToConsole( 'FAILED. ' + FMOD_ErrorString(FSOUND_GetError()) );
        Exit;
     End;

     // ajout du son à la pile de données
     AddItem( DATA_SOUND, nIndex, pSound );
     
     AddStringToConsole( Format('OK. (%d bytes)', [FSOUND_Sample_GetLength(pSound)*2]) );
End;



////////////////////////////////////////////////////////////////////////////////
// AddMusic : Charge une musique depuis un fichier (*.mod ; *.s3m), et        //
//            l'ajoute à la pile de données.                                  //
////////////////////////////////////////////////////////////////////////////////
Procedure AddMusic ( strFile : String ; nIndex : LongInt ) ;
Var pMusic : PFMusicModule;
Begin
     AddLineToConsole( 'Loading music ' + strFile + '...' );

     // chargement de la musique
     pMusic := FMUSIC_LoadSong( PChar(strFile) );
     If pMusic = NIL Then Begin
        AddStringToConsole( 'FAILED. ' + FMOD_ErrorString(FSOUND_GetError()) );
        Exit;
     End;

     // ajout de la musique à la pile de données
     AddItem( DATA_MUSIC, nIndex, pMusic );

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
     FSOUND_PlaySound( nIndex, pSound );
End;



////////////////////////////////////////////////////////////////////////////////
// StopSound : Procède à l'arrêt d'un son en fonction de son indice.          //
////////////////////////////////////////////////////////////////////////////////
Procedure StopSound ( nIndex : LongInt ) ;
Var pSound : PFSoundSample;
Begin
     // arrêt du son
     FSOUND_StopSound( nIndex );
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
Var i : LongInt;
    pMusic : PFMusicModule;
    pDataItem : LPDataItem;
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
                      callback : KeyCallback;
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



Function GetKey( nKey : Integer ) : Boolean ;
Begin
     GetKey := bKey[nKey];
End;



Function GetKeyS( nKey : Integer ) : Boolean ;
Begin
     GetKeyS := bKeyS[nKey];
End;



////////////////////////////////////////////////////////////////////////////////
// BindKey : Ajoute une callback à la pile de touches.                        //
////////////////////////////////////////////////////////////////////////////////
Procedure BindKey ( nKey : Integer ; bInstant : Boolean ; bSpecial : Boolean ; pCallback : KeyCallback ) ;
Var pKeyItem : LPKeyItem ;
Begin
     If pKeyStack = NIL Then Begin
          New( pKeyStack );
          pKeyStack^.count := 0;
          pKeyStack^.key := nKey;
          pKeyStack^.instant := bInstant;
          pKeyStack^.special := bSpecial;
          pKeyStack^.callback := pCallback;
          pKeyStack^.next := NIL;
     End Else Begin
          pKeyItem := pKeyStack;
          New( pKeyStack );
          pKeyStack^.count := pKeyItem^.count + 1;
          pKeyStack^.key := nKey;
          pKeyStack^.instant := bInstant;
          pKeyStack^.special := bSpecial;
          pKeyStack^.callback := pCallback;
          pKeyStack^.next := pKeyItem;
     End;
End;



////////////////////////////////////////////////////////////////////////////////
// ExecKey : Execute la callback correspondante à la touche enfoncée.         //
////////////////////////////////////////////////////////////////////////////////
Procedure ExecKey ( nKey : Integer ; bInstant : Boolean ; bSpecial : Boolean ) ;
Var pKeyItem : LPKeyItem ;
Begin
     // regarde si la touche enfoncée a été définie et appelle la callback correspondante
     pKeyItem := pKeyStack;
     While pKeyItem <> NIL Do
     Begin
          If (pKeyItem^.key = nKey) And (pKeyItem^.instant = bInstant) And (pKeyItem^.special = bSpecial) Then pKeyItem^.callback( GetDelta() );
          pKeyItem := pKeyItem^.next;
     End;
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



Function GetMouseX() : Integer ;
Begin
     GetMouseX := nX;
End;



Function GetMouseY() : Integer ;
Begin
     GetMouseY := nY;
End;



Function GetMouseDX() : Single ;
Begin
     GetMouseDX := dX;
     dX := 0;
End;



Function GetMouseDY() : Single ;
Begin
     GetMouseDY := dY;
     dY := 0;
End;





























////////////////////////////////////////////////////////////////////////////////
// CALLBACKS OPENGL                                                           //
////////////////////////////////////////////////////////////////////////////////



Var OGLCallback : GameCallback;



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



Procedure OGLRender () ; cdecl;
Var k : Integer;
Begin
     glClearColor( 0.0, 0.0, 0.0, 0.0 );
     glClear( GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT );
     glClearDepth( 1.0 );

     glDisable( GL_CULL_FACE );
     glEnable( GL_DEPTH_TEST );
     glShadeModel( GL_SMOOTH );
     glDepthFunc( GL_LEQUAL );
     glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
     glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
     
     {glEnable(GL_COLOR_MATERIAL);
     glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);

     glEnable(GL_LIGHTING);
     glLightfv(GL_LIGHT0, GL_DIFFUSE, LightColor);
     GlLightfv(GL_LIGHT0, GL_POSITION, LightVector);
     glEnable(GL_LIGHT0);}

     OGLCallback();

     glDisable(GL_LIGHTING);

     DrawText( 10, 20, 0, 0, 1, FONT_HELVETICA_18, Format( 'atominsa - %.3f FPS',[GetFPS()] ) );

     glutSwapBuffers;

     For k := 0 To 255 Do Begin
         If bKey[k] = True Then ExecKey( k, False, False );
         If bKeyS[k] = True Then ExecKey( k, False, True );
     End;
     
     nFrame += 1;
     If GetTime() - fTime > 1 Then
     Begin
          nFPS := nFrame;
          nFrame := 0;
          fTime := GetTime();
     End;
     fDelta := GetTime();
End;



Procedure OGLTimer ( value : Integer ) ; cdecl;
Begin
     glutPostRedisplay;
     glutTimerFunc( 8, @OGLTimer, 0 );
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



Procedure OGLIdle () ; cdecl;
Begin
End;



Procedure InitGlut ( sTitle : String ; pCallback : GameCallback ) ;
Begin
     OGLCallback := pCallback;
  
     glutInit( @argc, argv );

     glutInitDisplayMode( GLUT_RGB or GLUT_DOUBLE or GLUT_DEPTH );
     glutInitWindowSize( SCREENWIDTH, SCREENHEIGHT );
     glutInitWindowPosition( 120, 80 );
     glutCreateWindow( PChar(sTitle) );
     //glutFullscreen();
     glutDisplayFunc( @OGLRender );
     glutIdleFunc( @OGLIdle );
     glutTimerFunc( 8, @OGLTimer, 0 );
     glutKeyboardFunc( @OGLKeyDown );
     glutKeyboardUpFunc( @OGLKeyUp );
     glutSpecialFunc( @OGLKeyDownS );
     glutSpecialUpFunc( @OGLKeyUpS );
     glutMouseFunc( @OGLMouseButton );
     glutPassiveMotionFunc( @OGLMouseMove );

     Window.Memo.Lines.Add( '' );
     Window.Memo.Lines.Add( 'OpenGL Infos :' );
     Window.Memo.Lines.Add( '   Vendor : ' + PChar(glGetString(GL_VENDOR)) );
     Window.Memo.Lines.Add( '   Renderer : ' + PChar(glGetString(GL_RENDERER)) );
     Window.Memo.Lines.Add( '   Version : ' + PChar(glGetString(GL_VERSION)) );
     Window.Memo.Lines.Add( '   Extensions : ' + PChar(glGetString(GL_EXTENSIONS)) );

     fTime := GetTime();
     fDelta := GetTime();
End;

Procedure ExecGlut () ;
Begin
     glutMainLoop();
End;





























End.

