Program atominsa;

{$mode objfpc}{$H+}

Uses
  Classes, Forms, Interfaces, Graphics, SysUtils, IntfGraphics,
  UCore, UUtils, UBlock, UItem, UScheme, USpawn, UBomberman, UDisease,
  USpeedUp, UExtraBomb, UFlameUp, UGrid, UFlame, UBomb, USetup, UForm;

Const VERSION = 'v.1.0.b';

Var MaskIntfImg : TLazIntfImage;

Const STATE_EXIT          = 0;
Const STATE_INTRO         = 1;
Const STATE_MENU          = 2;
Const STATE_QUICKGAME     = 3;
Var nState : Integer;

Const MENU_MAIN           = 0;
Var nMenu : Integer;

Const BUTTON_NONE         = 0;
Const BUTTON_EXIT         = 1;
Const BUTTON_QUICKGAME    = 2;
Const BUTTON_MULTIGAME    = 3;
Const BUTTON_SOLOGAME     = 4;
Const BUTTON_SETUP        = 5;

Var nButton : Integer;
    nLastButton : Integer;
    
Const CAMERA_FLY          = -1;
Const CAMERA_OVERALL      = 0;
Var nCamera  : Integer;
    vCamera  : Vector;
    vCenter  : Vector;
    vAngle   : Vector;
    vPointer : Vector;

Var tPlayer : CBomberman;
    tGrid   : CGrid;
    tScheme : CScheme;
    tBlock  : CBlock;

Var nIntroLayer : Integer;
    fIntroTime : Single;

Var nRound : Integer;
    fRoundTime : Single;
    fGameTime : Single;

       
Procedure NextRound () ;
Var i : Integer;
Begin
     // attention restore sera pour l'inter-round, ce ne sera plus nécessaire dans initgame
     //de meme que FreeTimer et FreeBomb et FreeFlame et LoadScheme ... en fait toute cette fonction quoi ...
     //donc en fait t'as ecrit de la merde c'est juste que cette fonction elle devra etre appeler ou il faut =)
     //c boooooooooooooooon on rigoooooooooooole
     FreeFlame();
     FreeBomb();
     FreeTimer();
     tGrid.LoadScheme(tScheme);
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            GetBombermanByCount(i).Restore();

     nRound += 1;
     fRoundTime := GetTime();
End;



Procedure InitGame () ;
Var i : Integer;
Begin
     tScheme := pScheme;
     tGrid := CGrid.Create( tScheme );

     tPlayer := AddBomberman( sName1, 1, 1, tGrid, tScheme.Spawn(1).X, tScheme.Spawn(1).Y ); // le spawn du bomberman est variable : à voir
     BindKey( nKey1MoveUp, False, True, @tPlayer.MoveUp );
     BindKey( nKey1MoveDown, False, True, @tPlayer.MoveDown );
     BindKey( nKey1MoveLeft, False, True, @tPlayer.MoveLeft );
     BindKey( nKey1MoveRight, False, True, @tPlayer.MoveRight );
     BindKey( nKey1Primary, True, False, @tPlayer.CreateBomb );
     //BindKey( nKey1Secondary, True, False, @tPlayer.??? );

     tPlayer := AddBomberman( sName2, 2, 2, tGrid, tScheme.Spawn(2).X, tScheme.Spawn(2).Y );
     BindKey( nKey2MoveUp, False, False, @tPlayer.MoveUp );
     BindKey( nKey2MoveDown, False, False, @tPlayer.MoveDown );
     BindKey( nKey2MoveLeft, False, False, @tPlayer.MoveLeft );
     BindKey( nKey2MoveRight, False, False, @tPlayer.MoveRight );
     BindKey( nKey2Primary, True, False, @tPlayer.CreateBomb );
     //BindKey( nKey2Secondary, True, False, @tPlayer.??? );

     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     fGameTime := GetTime();

     nRound := 0;
     NextRound();
End;



Procedure ProcessIntro () ;
Var t : Single;
Begin
     If GetTime() > fIntroTime Then Begin
        nIntroLayer += 1;
        fIntroTime := GetTime() + 1.0;
        If nIntroLayer = 21 Then nState := STATE_MENU;
     End;

     // permet d'ajuster la vitesse de zoom en fonction par rapport à la projection
     t := pow((1.0 + GetTime() - fIntroTime), 0.707);
     
     SetTexture( 1, SPRITE_INTRO_LAYER(nIntroLayer) );
     // zoom sur la Terre
     If nIntroLayer = 0 Then DrawImage( -0.007 * t, -0.012 * t, 0.537 * t - 1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
     If nIntroLayer = 1 Then DrawImage( 0, 0, 0.669 * t - 1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
     If nIntroLayer = 2 Then DrawImage( -0.022 * t, -0.034 * t, 0.490 * t - 1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
     If nIntroLayer = 3 Then DrawImage( -0.175 * t, -0.016 * t, 0.469 * t - 1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
     If (nIntroLayer > 3) And (nIntroLayer < 18) Then DrawImage( 0.055 * t, -0.045 * t, 0.500 * t - 1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
     If nIntroLayer = 18 Then DrawImage( 0, 0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
     // fondu et affichage de la grille
     If nIntroLayer = 19 Then Begin
        SetTexture( 1, SPRITE_INTRO_LAYER(18) );
        DrawImage( 0, 0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 0.5 + (fIntroTime - GetTime()) * 0.5, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(19) );
        DrawImage( 0, 0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, (1.0 + GetTime() - fIntroTime) * 0.5, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(20) );
        DrawImage( -2.0 + (1.0 + GetTime() - fIntroTime) * 2.0, 0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(21) );
        DrawImage( 0, 2.0 - (1.0 + GetTime() - fIntroTime) * 2.0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
     End;
     If nIntroLayer = 20 Then Begin
        SetTexture( 1, SPRITE_INTRO_LAYER(18) );
        DrawImage( 0, 0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, (fIntroTime - GetTime()) * 0.5, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(19) );
        DrawImage( 0, 0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 0.5 + (1.0 + GetTime() - fIntroTime) * 0.5, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(20) );
        DrawImage( (1.0 + GetTime() - fIntroTime) * 2.0, 0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(21) );
        DrawImage( 0, 0.0 - (1.0 + GetTime() - fIntroTime) * 2.0, -1.0, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, True );
     End;

End;



Procedure CheckMainButton () ; cdecl;
Begin
     Case nButton Of
          BUTTON_QUICKGAME :
          Begin
               PlaySound( SOUND_MENU_SELECT );
               InitGame();
               nState := STATE_QUICKGAME;
          End;
          BUTTON_EXIT :
          Begin
               PlaySound( SOUND_MENU_SELECT );
               FreeBomberman();
               FreeBomb();
               FreeFlame();
               FreeDataStack();
               FreeTimer();
               ExitFMod();
               Application.Terminate;
               Halt(0);
          End;
     End;
End;



Procedure ProcessMenu () ;
Var w, h : Single; // taille de la fenêtre
    x, y : Single; // coordonnées du pointeur
    u, v : Single; // coordonnées de la grille dans le repère OpenGL
    c : Integer;
    i, j : Integer; // coordonnées du pointeur dans le repère du mask
    k : LongInt;
    r, g, b : Byte;
Begin
     w := GetWidth();
     h := GetHeight();
     x := GetMouseX();
     y := GetMouseY();
     u := Round((2 * x / h - w / h) / (w / h / 9)) * (w / h / 9);
     v := Round((1 - 2 * y / h) / (1 / 9)) * (1 / 9);

     Case nMenu Of
          MENU_MAIN :
          Begin
               BindButton( BUTTON_LEFT, @CheckMainButton );

               // affichage du fond et de la croix
               SetTexture( 1, SPRITE_MENU_BACK );
               DrawImage( 0, 0, -1, GetWidth() / GetHeight(), 1, 1, 1, 1, 1, False );
               SetTexture( 1, SPRITE_MENU_CROSS );
               DrawImage( u, v, -1, 2 * w / h, 2, 1, 1, 1, 0.5, True );
               DrawText( w - 170, h - 20, 1, 1, 1, FONT_NORMAL, 'atominsa ' + VERSION );
               
               i := Round(x / w * Window.Mask.Picture.Width);
               j := Round(y / h * Window.Mask.Picture.Height);
               k := 4 * (j * Window.Mask.Picture.Width + i);
               b := MaskIntfImg.PixelData[k+0];
               g := MaskIntfImg.PixelData[k+1];
               r := MaskIntfImg.PixelData[k+2];
               If (r = 0) And (g = 0) And (b = 0) Then nButton := BUTTON_NONE;
               If (r = 0) And (g = 255) And (b = 255) Then nButton := BUTTON_EXIT;
               If (r = 255) And (g = 0) And (b = 0) Then nButton := BUTTON_QUICKGAME;
               If (r = 0) And (g = 255) And (b = 0) Then nButton := BUTTON_MULTIGAME;
               If (r = 0) And (g = 0) And (b = 255) Then nButton := BUTTON_SOLOGAME;
               If (r = 255) And (g = 255) And (b = 0) Then nButton := BUTTON_SETUP;

               If nButton <> BUTTON_NONE Then Begin
                  Case nButton Of
                       BUTTON_EXIT : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON0 );
                       BUTTON_MULTIGAME : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON4 );
                       BUTTON_SOLOGAME : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON1 );
                       BUTTON_SETUP : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON3 );
                       BUTTON_QUICKGAME : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON2 );
                  End;
                  DrawImage( 0, 0, -1, GetWidth() / GetHeight(), 1, 1, 1, 1, 0.5, True );
                  If (nButton <> nLastButton) And (nButton <> BUTTON_NONE) Then Begin
                     PlaySound( SOUND_MENU_MOVE );
                     Case nButton Of
                          BUTTON_EXIT : SetString( STRING_MENU_MAIN, 'exit', 0.5, 0.4, 20 );
                          BUTTON_MULTIGAME : SetString( STRING_MENU_MAIN, 'multiplayer', 0.5, 1.1, 20 );
                          BUTTON_SOLOGAME : SetString( STRING_MENU_MAIN, 'solo', 0.5, 0.4, 20 );
                          BUTTON_SETUP : SetString( STRING_MENU_MAIN, 'setup', 0.5, 0.5, 20 );
                          BUTTON_QUICKGAME : SetString( STRING_MENU_MAIN, 'practice', 0.5, 0.8, 20 );
                     End;
                  End;
                  SetTexture( 1, SPRITE_CHARSET_TERMINAL );
                  Case nButton Of
                       BUTTON_EXIT : DrawString( STRING_MENU_MAIN, -0.734, -0.831, -1, 0.03, 0.03, 1, 1, 1, 0.8, True );
                       BUTTON_MULTIGAME : DrawString( STRING_MENU_MAIN, 0.566, -0.263, -1, 0.03, 0.03, 1, 1, 1, 0.8, True );
                       BUTTON_SOLOGAME : DrawString( STRING_MENU_MAIN, -0.109, -0.319, -1, 0.03, 0.03, 1, 1, 1, 0.8, True );
                       BUTTON_SETUP : DrawString( STRING_MENU_MAIN, 0.284, 0.090, -1, 0.03, 0.03, 1, 1, 1, 0.8, True );
                       BUTTON_QUICKGAME : DrawString( STRING_MENU_MAIN, -0.291, 0.194, -1, 0.03, 0.03, 1, 1, 1, 0.8, True );
                  End;
               End;
               nLastButton := nButton;
          End;
     End;
End;

// vrai si on est en train d'afficher les scores
Var bScoreTable : Boolean;

Procedure ProcessGame () ;
Var i, j : Integer;
    r,g,b : single;
    t : Boolean;
Begin
     If GetTime() - fGameTime < 3.0 Then Begin
        vPointer.x := 8.0 + (fGameTime - GetTime() + 3.0) * 8.0 * cos((GetTime() - fGameTime) / 3.0 * PI + PI);
        vPointer.y := 8.5 + (fGameTime - GetTime() + 3.0) * 8.0;
        vPointer.z := 6.0 + (fGameTime - GetTime() + 3.0) * 8.0 * sin((GetTime() - fGameTime) / 3.0 * PI + PI);
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If GetTime() - fRoundTime < 1.0 Then Begin
        vPointer.x := 8.0;
        vPointer.y := 8.5 - (GetTime() - fRoundTime) * 3.0;
        vPointer.z := 6.0 + (fRoundTime - GetTime() + 1.0) * 16.0;
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If nCamera = CAMERA_OVERALL Then Begin
        vPointer.x := 8.0;
        vPointer.y := 8.5;
        vPointer.z := 6.0;
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If nCamera = CAMERA_FLY Then Begin
        vAngle.x -= GetMouseDX() * 2000.0 * GetDelta();
        vAngle.y += GetMouseDY() * 2000.0 * GetDelta();
        If vAngle.x < 0.0 Then vAngle.x += PI2;
        If vAngle.x > PI2 Then vAngle.x -= PI2;
        If vAngle.y < -PI*0.5 Then vAngle.y := -PI*0.5;
        If vAngle.y > +PI*0.5 Then vAngle.y := +PI*0.5;
        If GetKeyS(KEY_UP) Then Begin
           vPointer.x += GetDelta() * 1.0 * cos(vAngle.x);
           vPointer.y += GetDelta() * 1.0 * sin(vAngle.y);
           vPointer.z += GetDelta() * 1.0 * sin(vAngle.x);
        End Else If GetKeyS(KEY_DOWN) Then Begin
           vPointer.x -= GetDelta() * 1.0 * cos(vAngle.x);
           vPointer.y -= GetDelta() * 1.0 * sin(vAngle.y);
           vPointer.z -= GetDelta() * 1.0 * sin(vAngle.x);
        End Else If GetKeyS(KEY_RIGHT) Then Begin
           vPointer.x += GetDelta() * 1.0 * cos(vAngle.x + PI*0.5);
           vPointer.z += GetDelta() * 1.0 * sin(vAngle.x + PI*0.5);
        End Else If GetKeyS(KEY_LEFT) Then Begin
           vPointer.x -= GetDelta() * 1.0 * cos(vAngle.x + PI*0.5);
           vPointer.z -= GetDelta() * 1.0 * sin(vAngle.x + PI*0.5);
        End;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
        vCenter.x := vCamera.x + cos(vAngle.x);
        vCenter.y := vCamera.y + sin(vAngle.y);
        vCenter.z := vCamera.z + sin(vAngle.x);
     End Else Begin
        vCenter.x := GetBombermanByCount(nCamera).X;
        vCenter.y := 0.0;
        vCenter.z := GetBombermanByCount(nCamera).Y;
        If GetBombermanByCount(nCamera).Direction = 0 Then Begin
           vPointer.x := vCenter.x;
           vPointer.y := 3.0;
           vPointer.z := vCenter.z - 3.0;
        End Else If GetBombermanByCount(nCamera).Direction = 90 Then Begin
           vPointer.x := vCenter.x + 3.0;
           vPointer.y := 3.0;
           vPointer.z := vCenter.z;
        End Else If GetBombermanByCount(nCamera).Direction = 180 Then Begin
           vPointer.x := vCenter.x;
           vPointer.y := 3.0;
           vPointer.z := vCenter.z + 3.0;
        End Else If GetBombermanByCount(nCamera).Direction = -90 Then Begin
           vPointer.x := vCenter.x - 3.0;
           vPointer.y := 3.0;
           vPointer.z := vCenter.z;
        End;
     End;
     If vCamera.x > vPointer.x Then vCamera.x -= vPointer.x * GetDelta() * 1.0;
     If vCamera.x < vPointer.x Then vCamera.x += vPointer.x * GetDelta() * 1.0;
     If vCamera.y > vPointer.y Then vCamera.y -= vPointer.y * GetDelta() * 1.0;
     If vCamera.y < vPointer.y Then vCamera.y += vPointer.y * GetDelta() * 1.0;
     If vCamera.z > vPointer.z Then vCamera.z -= vPointer.z * GetDelta() * 1.0;
     If vCamera.z < vPointer.z Then vCamera.z += vPointer.z * GetDelta() * 1.0;

     SetProjectionMatrix ( 90.0, 1.0, 0.1, 2048.0 ) ;
     SetCameraMatrix ( vCamera.x, vCamera.y, vCamera.z, vCenter.x, vCenter.y, vCenter.z, 0, 1, 0 ) ;

     EnableLighting();
     SetLight( 0,             0, 2,             -1, 1, 1, 1, 1, 1, 0.3, 0.6, True );
     SetLight( 1, GRIDWIDTH - 1, 2,             -1, 1, 1, 1, 1, 1, 0.3, 0.6, True );
     SetLight( 2,             0, 2, GRIDHEIGHT - 2, 1, 1, 1, 1, 1, 0.3, 0.6, True );
     SetLight( 3, GRIDWIDTH - 1, 2, GRIDHEIGHT - 2, 1, 1, 1, 1, 1, 0.3, 0.6, True );
     SetLight( 4, GRIDWIDTH / 2 + 1, 2, GRIDHEIGHT / 2 - 2, 1, 1, 1, 1, 1, 0.3, 0.6, True );

     SetMaterial( 1, 1, 1, True );

     // affichage du plan en arrière plan
     SetTexture( 1, TEXTURE_MAP_PLANE );
     PushObjectMatrix( 8.0, -0.5, 6.0, 0.11, 0.11, 0.11, 0, 0, 0 );
     DrawMesh( MESH_PLANE, 1, 1, 1, False );
     PopObjectMatrix();
     
     // affichage de chaque bomberman
     For i := 1 To GetBombermanCount() Do
     Begin
          If GetBombermanByCount(i).Alive then
          Begin
               SetTexture( 1, TEXTURE_BOMBERMAN(i) );
               PushObjectMatrix( GetBombermanByCount(i).X, 0, GetBombermanByCount(i).Y, 0.05, 0.05, 0.05, 0, GetBombermanByCount(i).Direction, 0 );
               DrawMesh( MESH_BOMBERMAN, r, g, b, False );
               PopObjectMatrix();
          End;
     End;

     SetMaterial( 1, 1, 1, False );

     EnableLighting();
     SetLight( 0,             0, 5,             -1, 1, 1, 1, 1, 1, 1.8, 2.4, True );
     SetLight( 1, GRIDWIDTH - 1, 5,             -1, 1, 1, 1, 1, 1, 1.8, 2.4, True );
     SetLight( 2,             0, 5, GRIDHEIGHT - 2, 1, 1, 1, 1, 1, 1.8, 2.4, True );
     SetLight( 3, GRIDWIDTH - 1, 5, GRIDHEIGHT - 2, 1, 1, 1, 1, 1, 1.8, 2.4, True );
     SetLight( 4, GRIDWIDTH / 2 + 1, 5, GRIDHEIGHT / 2 - 2, 1, 1, 1, 1, 1, 1.8, 2.4, True );

     // affichage de la grille
     For j := 1 To GRIDHEIGHT Do Begin
          For i := 1 To GRIDWIDTH Do Begin
              tBlock := tGrid.GetBlock(i,j);
              if Not(tBlock is CBomb) then
              begin
              If (tBlock Is CDisease) And (tBlock As CItem).IsExplosed() Then Begin
                 SetMaterial( 1, 0, 0, True );
                 SetTexture( 1, TEXTURE_NONE );
                 PushObjectMatrix( i, 0, j, 0.026, 0.026, 0.026, 0, 0, 0 );
                 DrawMesh( MESH_DISEASE, 1, 0, 0, True );
                 PopObjectMatrix();
              End Else
              If (tBlock Is CExtraBomb) And (tBlock As CItem).IsExplosed() Then Begin
                 SetMaterial( 0, 1, 0, True );
                 SetTexture( 1, TEXTURE_NONE );
                 PushObjectMatrix( i, 0, j, 0.012, 0.012, 0.012, 0, 0, 0 );
                 DrawMesh( MESH_EXTRABOMB, 0, 1, 0, True );
                 PopObjectMatrix();
              End Else
              If (tBlock Is CSpeedUp) And (tBlock As CItem).IsExplosed() Then Begin
                 SetMaterial( 0, 0, 1, True );
                 SetTexture( 1, TEXTURE_NONE );
                 PushObjectMatrix( i, 0, j, 0.026, 0.026, 0.026, 0, 0, 0 );
                 DrawMesh( MESH_SPEEDUP, 0, 0, 1, True );
                 PopObjectMatrix();
              End Else
              If (tBlock Is CFlameUp) And (tBlock As CItem).IsExplosed() Then Begin
                 SetMaterial( 1, 1, 0, True );
                 SetTexture( 1, TEXTURE_NONE );
                 PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                 DrawMesh( MESH_FLAMEUP, 1, 1, 0, True );
                 PopObjectMatrix();
              End Else
              If (tBlock Is CItem) Then Begin
                 SetMaterial( 1, 1, 1, True );
                 SetTexture( 1, TEXTURE_MAP_BRICK );
                 PushObjectMatrix( i, 0, j, 0.012, 0.012, 0.012, 0, 0, 0 );
                 DrawMesh( MESH_BLOCK_BRICK, 1, 1, 1, False );
                 PopObjectMatrix();
              End {Else
              If (tBlock Is CBomb) Then Begin
                 SetMaterial( 1, 1, 1, True );
                 SetTexture( 1, TEXTURE_NONE );
                 PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                 DrawMesh( MESH_BOMB, 0.6, 0, 0, False );
                 PopObjectMatrix();
              End} Else
              If (tBlock Is CBlock) Then Begin
                 SetMaterial( 1, 1, 1, True );
                 If (tBlock As CBlock).IsExplosive() Then Begin
                    SetTexture( 1, TEXTURE_MAP_BRICK );
                    PushObjectMatrix( i, 0, j, 0.012, 0.012, 0.012, 0, 0, 0 );
                    DrawMesh( MESH_BLOCK_BRICK, 1, 1, 1, False );
                    PopObjectMatrix();
                 End Else Begin
                    SetTexture( 1, TEXTURE_MAP_SOLID );
                    PushObjectMatrix( i, 0, j, 0.016, 0.016, 0.016, 0, 0, 0 );
                    DrawMesh( MESH_BLOCK_SOLID, 1, 1, 1, False );
                    PopObjectMatrix();
                End;
              End;
              end;
          End;
     End;
     
     // Affichage + mise à jour des bombes
     i := 1;
     While ( i <= GetBombCount() ) Do
     begin
      SetMaterial( 1, 1, 1, True );
      SetTexture( 1, TEXTURE_NONE );
      PushObjectMatrix( GetBombByCount(i).X, 0, GetBombByCount(i).Y,
                         1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)),
                         1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)),
                         1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)),
                        0, 0, 0 );
      DrawMesh( MESH_BOMB, 0.6, 0, 0, False );
      PopObjectMatrix();
      If Not GetBombByCount(i).UpdateBomb(GetDelta()) Then i += 1;
    end;

     DisableLighting();

     // mise à jour et affichage des flames
     i := 1;
     While ( i <= GetFlameCount() ) Do
     Begin
          SetTexture( 1, TEXTURE_BOMBERMAN_FLAME );
          // flamme intérieure
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.001, 0, GetFlameByCount(i).Y - 0.001 ); // on évite les cas particuliers (les angles à 90° bug)
          DrawSprite( 1.0 + 2.0 * GetFlameByCount(i).Itensity, 1.0 + 2.0 * GetFlameByCount(i).Itensity, 1, 1, 1, GetFlameByCount(i).Itensity, True );
          PopObjectMatrix();
          // flammes centrales
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.301, 0, GetFlameByCount(i).Y );
          DrawSprite( 0.6 + 1.7 * GetFlameByCount(i).Itensity, 0.6 + 1.7 * GetFlameByCount(i).Itensity, 1, 0.5, 0, GetFlameByCount(i).Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X + 0.299, 0, GetFlameByCount(i).Y );
          DrawSprite( 0.6 + 1.7 * GetFlameByCount(i).Itensity, 0.6 + 1.7 * GetFlameByCount(i).Itensity, 1, 0.5, 0, GetFlameByCount(i).Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X, 0, GetFlameByCount(i).Y - 0.301 );
          DrawSprite( 0.6 + 1.7 * GetFlameByCount(i).Itensity, 0.6 + 1.7 * GetFlameByCount(i).Itensity, 1, 0.5, 0, GetFlameByCount(i).Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X, 0, GetFlameByCount(i).Y + 0.299 );
          DrawSprite( 0.6 + 1.7 * GetFlameByCount(i).Itensity, 0.6 + 1.7 * GetFlameByCount(i).Itensity, 1, 0.5, 0, GetFlameByCount(i).Itensity * 0.8, True );
          PopObjectMatrix();
          // flammes extérieures
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.301, 0, GetFlameByCount(i).Y - 0.301 );
          DrawSprite( 0.2 + 1.4 * GetFlameByCount(i).Itensity, 0.2 + 1.4 * GetFlameByCount(i).Itensity, 1, 0.0, 0, GetFlameByCount(i).Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.301, 0, GetFlameByCount(i).Y + 0.299 );
          DrawSprite( 0.2 + 1.4 * GetFlameByCount(i).Itensity, 0.2 + 1.4 * GetFlameByCount(i).Itensity, 1, 0.0, 0, GetFlameByCount(i).Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X + 0.299, 0, GetFlameByCount(i).Y - 0.301 );
          DrawSprite( 0.2 + 1.4 * GetFlameByCount(i).Itensity, 0.2 + 1.4 * GetFlameByCount(i).Itensity, 1, 0.0, 0, GetFlameByCount(i).Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X + 0.299, 0, GetFlameByCount(i).Y + 0.299 );
          DrawSprite( 0.2 + 1.4 * GetFlameByCount(i).Itensity, 0.2 + 1.4 * GetFlameByCount(i).Itensity, 1, 0.0, 0, GetFlameByCount(i).Itensity * 0.4, True );
          PopObjectMatrix();
          //PushObjectMatrix( GetFlameByCount(i).X, 0, GetFlameByCount(i).Y, 0.07, 0.07, 0.07, 0, 0, 0 );
          //DrawMesh( MESH_FLAME, 1, 1, 1, False );
          //PopObjectMatrix();
          If Not GetFlameByCount(i).Update() Then i += 1;
     End;



     // affichage des scores
     If GetKeyS(KEY_TAB) Then Begin
        SetTexture( 1, SPRITE_CHARSET_TERMINAL );
        If Not bScoreTable Then Begin
           If GetBombermanCount() <> 0 Then
              For i := 1 To GetBombermanCount() Do
                  SetString( STRING_SCORE_TABLE(i), GetBombermanByCount(i).Name + Format(' : %d kills.', [GetBombermanByCount(i).Kills]), Single(i) * 0.1 + 0.1, 1.0, 20 );
        End;
        If GetBombermanCount() <> 0 Then
           For i := 1 To GetBombermanCount() Do
               DrawString( STRING_SCORE_TABLE(i), -0.5, 0.8 - 0.2 * Single(i), -1, 0.03, 0.03, 1, 1, 1, 0.8, True );
        bScoreTable := True;
     End Else Begin
        bScoreTable := False;
     End;

     // mise à jour de la minuterie
     CheckTimer();

     // vérifie s'il reste des bomberman en jeu
     If CheckEndGame() Then NextRound();
End;

Procedure GameLoop () ; cdecl;
Begin
     Case nState Of
          STATE_INTRO : ProcessIntro();
          STATE_MENU  : ProcessMenu();
          STATE_QUICKGAME  : ProcessGame();
     End;
End;

Var k : Integer;
Begin
     // initialisation de l'application
     Application.Initialize;
     Application.CreateForm(TWindow, Window);

     // affichage de la console
     Window.Show();
     
     // chargement du masque des zones du menu principal
     Window.Mask.Picture.Bitmap.LoadFromFile( './textures/mask.bmp' );
     MaskIntfImg := TLazIntfImage.Create(0,0);
     MaskIntfImg.LoadFromBitmap( Window.Mask.Picture.Bitmap.Handle, Window.Mask.Picture.Bitmap.MaskHandle );

     // initialisation du générateur de nombres aléatoires
     Randomize();
     
     // lecture du fichier atominsa.cfg
     ReadSettings( 'atominsa.cfg' );
     WriteSettings( 'tg.txt' );
     
     InitDataStack();
     
     // initialisation de FMod
     InitFMod();

     // CHECKER UNE OPTION POUR LE PASSAGE EN FULLSCREEN ET POUR LA RESOLUTION
     // LE PASSAGE EN FULLSCREEN DOIT SE FAIRE DANS OGLExec APRES LE CHARGEMENT
     InitGlut( 'atominsa - Game', @gameloop );

     //----------------------------BEGIN::TEMP----------------------------//
     AddMesh( './characters/bomberman/bomberman.m12', MESH_BOMBERMAN );
     AddMesh( './maps/test/solid.m12', MESH_BLOCK_SOLID );
     AddMesh( './maps/test/brick.m12', MESH_BLOCK_BRICK );
     AddMesh( './meshes/bomb.m12', MESH_BOMB );
     AddMesh( './maps/test/plane.m12', MESH_PLANE );
     AddSound( './characters/bomberman/bomb0.wav', SOUND_BOMB(0) );
     AddSound( './characters/bomberman/bomb1.wav', SOUND_BOMB(1) );

     For k := 0 To 7 Do
         AddTexture( Format('./characters/bomberman/bomberman%d.jpg', [k]), TEXTURE_BOMBERMAN(k+1) );

     AddTexture( './maps/test/brick.jpg', TEXTURE_MAP_BRICK );
     AddTexture( './maps/test/solid.jpg', TEXTURE_MAP_SOLID );
     AddTexture( './maps/test/plane.jpg', TEXTURE_MAP_PLANE );
     AddTexture( './characters/bomberman/flame.jpg', TEXTURE_BOMBERMAN_FLAME );
     //-----------------------------END::TEMP-----------------------------//

     // chargement des meshes relatifs aux blocs et bonus
     AddMesh( './meshes/disease.m12', MESH_DISEASE );
     AddMesh( './meshes/extrabomb.m12', MESH_EXTRABOMB );
     AddMesh( './meshes/flameup.m12', MESH_FLAMEUP );
     AddMesh( './meshes/speedup.m12', MESH_SPEEDUP );

     // chargement des sprites relatifs au menu
     AddTexture( './textures/back.jpg', SPRITE_MENU_BACK );
     AddTexture( './textures/mainbt0.jpg', SPRITE_MENU_MAIN_BUTTON0 );
     AddTexture( './textures/mainbt1.jpg', SPRITE_MENU_MAIN_BUTTON1 );
     AddTexture( './textures/mainbt2.jpg', SPRITE_MENU_MAIN_BUTTON2 );
     AddTexture( './textures/mainbt3.jpg', SPRITE_MENU_MAIN_BUTTON3 );
     AddTexture( './textures/mainbt4.jpg', SPRITE_MENU_MAIN_BUTTON4 );
     AddTexture( './textures/cross.jpg', SPRITE_MENU_CROSS );

     // chargement des polices de caractères
     AddTexture( './textures/charset0.jpg', SPRITE_CHARSET_TERMINAL );
     AddTexture( './textures/charset1.jpg', SPRITE_CHARSET_DIGITAL );

     // chargement des images de l'intro
     bIntro:=False;
     If bIntro Then Begin
        For k := 0 To 21 Do
            AddTexture( Format('./textures/layer%d.jpg', [k]), SPRITE_INTRO_LAYER(k) );
     End;

     // chargement des sons du menu
     AddSound( './sounds/move.wav', SOUND_MENU_MOVE );
     AddSound( './sounds/select.wav', SOUND_MENU_SELECT );
     AddSound( './sounds/back.wav', SOUND_MENU_BACK );

     // initialisation de la machine d'état
     If bIntro Then Begin
        nState := STATE_MENU;
        nIntroLayer := -1;
        fIntroTime := 0.0;
     End Else Begin
        nState := STATE_MENU;
     End;

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     ExecGlut();
End.

