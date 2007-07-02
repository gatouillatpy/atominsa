Unit UIntro;

{$mode objfpc}{$H+}

Interface



Uses Classes, SysUtils,
     UCore, UUtils, USetup, UForm;



Procedure InitIntro () ;
Procedure ProcessIntro () ;



Implementation



Var nIntroLayer : Integer;
    fIntroTime : Single;



Procedure InitIntro () ;
Begin
     // définition de la première couche à afficher
     nIntroLayer := -1;

     // mise à zero de la minuterie de l'intro
     fIntroTime := 0.0;

     // mise à jour de la machine d'état
     nState := STATE_INTRO;
End;



Procedure ProcessIntro () ;
Var t : Single;
    w, h : Single;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     If GetTime() > fIntroTime Then Begin
        nIntroLayer += 1;
        fIntroTime := GetTime() + 1.0;
        If nIntroLayer = 21 Then nState := PHASE_MENU;
     End;

     // permet d'ajuster la vitesse de zoom en fonction par rapport à la projection
     t := pow((1.0 + GetTime() - fIntroTime), 0.707);

     SetTexture( 1, SPRITE_INTRO_LAYER(nIntroLayer) );
     // zoom sur la Terre
     If nIntroLayer = 0 Then DrawImage( -0.007 * t, -0.012 * t, 0.537 * t - 1.0, w / h, 1, 1, 1, 1, 1, True );
     If nIntroLayer = 1 Then DrawImage( 0, 0, 0.669 * t - 1.0, w / h, 1, 1, 1, 1, 1, True );
     If nIntroLayer = 2 Then DrawImage( -0.022 * t, -0.034 * t, 0.490 * t - 1.0, w / h, 1, 1, 1, 1, 1, True );
     If nIntroLayer = 3 Then DrawImage( -0.175 * t, -0.016 * t, 0.469 * t - 1.0, w / h, 1, 1, 1, 1, 1, True );
     If (nIntroLayer > 3) And (nIntroLayer < 18) Then DrawImage( 0.055 * t, -0.045 * t, 0.500 * t - 1.0, w / h, 1, 1, 1, 1, 1, True );
     If nIntroLayer = 18 Then DrawImage( 0, 0, -1.0, w / h, 1, 1, 1, 1, 1, True );
     // fondu et affichage de la grille
     If nIntroLayer = 19 Then Begin
        SetTexture( 1, SPRITE_INTRO_LAYER(18) );
        DrawImage( 0, 0, -1.0, w / h, 1, 1, 1, 1, 0.5 + (fIntroTime - GetTime()) * 0.5, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(19) );
        DrawImage( 0, 0, -1.0, w / h, 1, 1, 1, 1, (1.0 + GetTime() - fIntroTime) * 0.5, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(20) );
        DrawImage( -2.0 + (1.0 + GetTime() - fIntroTime) * 2.0, 0, -1.0, w / h, 1, 1, 1, 1, 1, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(21) );
        DrawImage( 0, 2.0 - (1.0 + GetTime() - fIntroTime) * 2.0, -1.0, w / h, 1, 1, 1, 1, 1, True );
     End;
     If nIntroLayer = 20 Then Begin
        SetTexture( 1, SPRITE_INTRO_LAYER(18) );
        DrawImage( 0, 0, -1.0, w / h, 1, 1, 1, 1, (fIntroTime - GetTime()) * 0.5, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(19) );
        DrawImage( 0, 0, -1.0, w / h, 1, 1, 1, 1, 0.5 + (1.0 + GetTime() - fIntroTime) * 0.5, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(20) );
        DrawImage( (1.0 + GetTime() - fIntroTime) * 2.0, 0, -1.0, w / h, 1, 1, 1, 1, 1, True );
        SetTexture( 1, SPRITE_INTRO_LAYER(21) );
        DrawImage( 0, 0.0 - (1.0 + GetTime() - fIntroTime) * 2.0, -1.0, w / h, 1, 1, 1, 1, 1, True );
     End;

End;



End.

