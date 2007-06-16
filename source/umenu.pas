Unit UMenu;

{$mode objfpc}{$H+}



Interface



Uses Classes, SysUtils, IntfGraphics,
     UCore, UUtils, UBlock, UItem, UScheme, USpawn, UBomberman, UDisease,
     USpeedUp, UExtraBomb, UFlameUp, UGrid, UFlame, UBomb, USetup, UForm;



Procedure InitMenu () ;
Procedure ProcessMenu () ;



Implementation



Var MaskIntfImg : TLazIntfImage;



Const MENU_MAIN           = 0;

Var nMenu : Integer;



Const BUTTON_NONE         = 0;
Const BUTTON_EXIT         = 1;
Const BUTTON_PRACTICE     = 2;
Const BUTTON_NETWORK      = 3;
Const BUTTON_SOLO         = 4;
Const BUTTON_SETUP        = 5;

Var nButton : Integer;
    nLastButton : Integer;



Procedure InitMenu () ;
Begin
     // chargement du masque des zones du menu principal
     Window.Mask.Picture.Bitmap.LoadFromFile( './textures/mask.bmp' );
     MaskIntfImg := TLazIntfImage.Create(0,0);
     MaskIntfImg.LoadFromBitmap( Window.Mask.Picture.Bitmap.Handle, Window.Mask.Picture.Bitmap.MaskHandle );

     // création de la texture de rendu
     CreateRenderTexture();
     PutRenderTexture();
     Clear( 1, 1, 1, 1 );
     GetRenderTexture();

     // mise à jour de la machine d'état
     nState := STATE_MENU;
End;



Procedure CheckMainButton () ; cdecl;
Begin
     Case nButton Of
          BUTTON_PRACTICE :
          Begin
               PlaySound( SOUND_MENU_SELECT );
               nState := PHASE_PRACTICE;
          End;
          BUTTON_EXIT :
          Begin
               nState := PHASE_EXIT;
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
     Case nMenu Of
          MENU_MAIN :
          Begin
               // ajout de la callback pour le bouton gauche de la souris
               BindButton( BUTTON_LEFT, @CheckMainButton );

               // appel d'une texture de rendu
               PutRenderTexture();

               w := GetRenderWidth();
               h := GetRenderHeight();
               x := GetMouseX() / GetWindowWidth() * w;
               y := GetMouseY() / GetWindowHeight() * h;
               u := Round((2 * x / h - w / h) / (w / h / 9)) * (w / h / 9);
               v := Round((1 - 2 * y / h) / (1 / 9)) * (1 / 9);

               // affichage de la croix
               SetTexture( 1, SPRITE_MENU_CROSS );
               DrawImage( u, v, -1, 2 * w / h, 2, 1, 1, 1, 0.1, True );
               DrawText( w - 170, h - 20, 1, 1, 1, FONT_NORMAL, 'atominsa ' + VERSION );

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
               If (r = 0) And (g = 255) And (b = 0) Then nButton := BUTTON_NETWORK;
               If (r = 0) And (g = 0) And (b = 255) Then nButton := BUTTON_SOLO;
               If (r = 255) And (g = 255) And (b = 0) Then nButton := BUTTON_SETUP;

               // affichage du bouton ainsi que du texte correspondant
               If nButton <> BUTTON_NONE Then Begin
                  Case nButton Of
                       BUTTON_EXIT : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON0 );
                       BUTTON_NETWORK : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON4 );
                       BUTTON_SOLO : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON1 );
                       BUTTON_SETUP : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON3 );
                       BUTTON_PRACTICE : SetTexture( 1, SPRITE_MENU_MAIN_BUTTON2 );
                  End;
                  DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 0.1, True );
                  If (nButton <> nLastButton) And (nButton <> BUTTON_NONE) Then Begin
                     PlaySound( SOUND_MENU_MOVE );
                     Case nButton Of
                          BUTTON_EXIT : SetString( STRING_MENU_MAIN, 'exit', 0.5, 0.4, 20 );
                          BUTTON_NETWORK : SetString( STRING_MENU_MAIN, 'multiplayer', 0.5, 1.1, 20 );
                          BUTTON_SOLO : SetString( STRING_MENU_MAIN, 'solo', 0.5, 0.4, 20 );
                          BUTTON_SETUP : SetString( STRING_MENU_MAIN, 'setup', 0.5, 0.5, 20 );
                          BUTTON_PRACTICE : SetString( STRING_MENU_MAIN, 'practice', 0.5, 0.8, 20 );
                     End;
                  End;
                  Case nButton Of
                       BUTTON_EXIT : DrawString( STRING_MENU_MAIN, -0.551 * w / h, -0.831, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); //-0.734
                       BUTTON_NETWORK : DrawString( STRING_MENU_MAIN, 0.425 * w / h, -0.263, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); //0.566
                       BUTTON_SOLO : DrawString( STRING_MENU_MAIN, -0.082 * w / h, -0.319, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); //-0.109
                       BUTTON_SETUP : DrawString( STRING_MENU_MAIN, 0.213 * w / h, 0.090, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); //0.284
                       BUTTON_PRACTICE : DrawString( STRING_MENU_MAIN, -0.218 * w / h, 0.194, -1, 0.023 * w / h, 0.03, 1, 1, 1, 0.1, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); //-0.291
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
          End;
     End;
End;



End.

