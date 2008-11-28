Unit UMenu;

{$mode objfpc}{$H+}



Interface



Uses Classes, SysUtils, IntfGraphics,
     UCore, UUtils, USetup, UForm;



Procedure InitMenu () ;
Procedure ProcessMenu () ;



Var MaskIntfImg : TLazIntfImage;



Implementation



Const BUTTON_NONE         = 0;
Const BUTTON_EXIT         = 1;
Const BUTTON_PRACTICE     = 2;
Const BUTTON_MULTI        = 3;
Const BUTTON_SOLO         = 4;
Const BUTTON_SETUP        = 5;
Const BUTTON_EDITOR       = 6;

Var nButton : Integer;
    nLastButton : Integer;



Procedure InitMenu () ;
Begin
     // vidage de la texture de rendu
     PutRenderTexture();
     Clear( 1, 1, 1, 1 );
     GetRenderTexture();
     
     PlaySound( SOUND_MENU );

     // mise à jour de la machine d'état
     nState := STATE_MENU;
End;



Procedure CheckButton () ; cdecl;
Begin
     Case nButton Of
          BUTTON_EXIT :
          Begin
               PlaySound( SOUND_MENU_SELECT );
               nState := PHASE_EXIT;
          End;
          BUTTON_PRACTICE :
          Begin
               PlaySound( SOUND_MENU_SELECT );
               nState := PHASE_PRACTICE;
          End;
          BUTTON_MULTI :
          Begin
               PlaySound( SOUND_MENU_SELECT );
               nState := PHASE_ONLINE;
          End;
          BUTTON_SETUP :
          Begin
               PlaySound( SOUND_MENU_SELECT );
               nState := PHASE_SETUP;
          End;
          BUTTON_EDITOR :
          Begin
               PlaySound( SOUND_MENU_SELECT );
               nState := PHASE_EDITOR;
          End;
     End;
End;



Procedure ProcessMenu () ;
Var w, h : Single; // taille de la fenêtre
    x, y : Single; // coordonnées du pointeur
    u, v : Single; // coordonnées de la grille dans le repère OpenGL
    i, j : Integer; // coordonnées du pointeur dans le repère du mask
    k : LongInt;
    r, g, b : Byte;
Begin
     // ajout de la callback pour le bouton gauche de la souris
     BindButton( BUTTON_LEFT, @CheckButton );

     // appel d'une texture de rendu
     PutRenderTexture();

     w := GetRenderWidth;
     h := GetRenderHeight;
     x := GetMouseX / GetWindowWidth * w;
     y := GetMouseY / GetWindowHeight * h;
     u := Round((2 * x / h - w / h) / (w / h / 9)) * (w / h / 9);
     v := Round((1 - 2 * y / h) / (1 / 9)) * (1 / 9);

     // affichage de la croix
     SetTexture( 1, SPRITE_MENU_CROSS );
     DrawImage( u, v, -1, 2 * w / h, 2, 1, 1, 1, 0.1, True );

     // identification du bouton en surbrillance
     i := Round(x / w * Window.Mask.Picture.Width);
     j := Round(y / h * Window.Mask.Picture.Height);
     k := 4 * (j * Window.Mask.Picture.Width + i);
     b := MaskIntfImg.PixelData[k+0];
     g := MaskIntfImg.PixelData[k+1];
     r := MaskIntfImg.PixelData[k+2];
     If (r = 0) And (g = 0) And (b = 0) Then nButton := BUTTON_NONE;
     If (r = 0) And (g = 255) And (b = 255) Then nButton := BUTTON_EXIT;
     If (r = 255) And (g = 0) And (b = 0) Then nButton := BUTTON_PRACTICE;
     If (r = 0) And (g = 255) And (b = 0) Then nButton := BUTTON_MULTI;
     If (r = 0) And (g = 0) And (b = 255) Then nButton := BUTTON_SOLO;
     If (r = 255) And (g = 255) And (b = 0) Then nButton := BUTTON_SETUP;
     If (r = 255) And (g = 0) And (b = 255) Then nButton := BUTTON_EDITOR;

     // affichage du bouton ainsi que du texte correspondant
     If nButton <> BUTTON_NONE Then Begin
        Case nButton Of
             BUTTON_EXIT : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON0 );
             BUTTON_MULTI : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON4 );
             BUTTON_SOLO : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON1 );
             BUTTON_SETUP : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON3 );
             BUTTON_PRACTICE : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON2 );
             BUTTON_EDITOR : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON5 );
        End;
        DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 0.1, True );
        If (nButton <> nLastButton) And (nButton <> BUTTON_NONE) Then Begin
           PlaySound( SOUND_MENU_MOVE );
           Case nButton Of
                BUTTON_EXIT : SetString( STRING_MENU_MAIN, 'exit', 0.5, 0.4, 20 );
                BUTTON_MULTI : SetString( STRING_MENU_MAIN, 'multi', 0.5, 0.5, 20 );
                BUTTON_SOLO : SetString( STRING_MENU_MAIN, 'solo', 0.5, 0.4, 20 );
                BUTTON_SETUP : SetString( STRING_MENU_MAIN, 'setup', 0.5, 0.5, 20 );
                BUTTON_PRACTICE : SetString( STRING_MENU_MAIN, 'practice', 0.5, 0.8, 20 );
                BUTTON_EDITOR : SetString( STRING_MENU_MAIN, 'editor', 0.5, 0.6, 20 );
           End;
        End;
        Case nButton Of
             BUTTON_EXIT : DrawString( STRING_MENU_MAIN, -0.551 * w / h, -0.831, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
             BUTTON_MULTI : DrawString( STRING_MENU_MAIN, 0.425 * w / h, -0.263, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
             BUTTON_SOLO : DrawString( STRING_MENU_MAIN, -0.082 * w / h, -0.319, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
             BUTTON_SETUP : DrawString( STRING_MENU_MAIN, 0.213 * w / h, 0.090, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
             BUTTON_PRACTICE : DrawString( STRING_MENU_MAIN, -0.218 * w / h, 0.194, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
             BUTTON_EDITOR : DrawString( STRING_MENU_MAIN, 0.119 * w / h, 0.702, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
        End;
     End;
     nLastButton := nButton;

     // affichage du rendu précédent en transparence pour l'effet de flou
     SetRenderTexture();
     DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 0.9, True );

     // récupération de la texture de rendu
     GetRenderTexture();

     // remplissage noir de l'écran
     Clear( 0, 0, 0, 0 );

     w := GetRenderWidth();
     h := GetRenderHeight();

     // affichage du fond
     SetTexture( 1, SPRITE_MENU_BACK );
     DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 1, False );

     // affichage final du rendu en transparence
     SetRenderTexture();
     DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 1, True );

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_SELECT );
        nState := PHASE_EXIT;
     End;
End;



End.

