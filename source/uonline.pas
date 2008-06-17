Unit UOnline;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UMap, UScheme, UCharacter, UForm;



Var sServerIP : Array [0..255] Of String;
Var sServerName : Array[0..255] Of String;



Procedure InitMenuOnline () ;
Procedure ProcessMenuOnline () ;



Implementation



Uses UCore;



Var fScroll : Single;



Var nMenu  : Integer;



Var bUp     : Boolean;
Var bDown   : Boolean;
Var bLeft   : Boolean;
Var bRight  : Boolean;
Var bEnter  : Boolean;
Var bEscape : Boolean;



Procedure InitMenuOnline () ;
Begin
     SetString( STRING_SETUP_MENU(1), 'setup', 0.2, 1.0, 600 );

     SetString( STRING_SETUP_MENU(11), 'show intro : ' + BoolToStr(bIntro), 0.2, 1.0, 600 );

     SetString( STRING_SETUP_MENU(21), 'desired framerate : ' + IntToStr(nFramerate), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(22), 'lighting : ' + BoolToStr(bLighting), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(23), 'shadowing : ' + BoolToStr(bShadowing), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(24), 'reflection : ' + BoolToStr(bReflection), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(25), 'effects : ' + BoolToStr(bEffects), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(26), 'blur : ' + BoolToStr(bBlur), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(27), 'texturing quality : ' + IntToStr(nTexturing), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(28), 'shader model : ' + IntToStr(nShaderModel), 0.2, 1.0, 600 );

     SetString( STRING_SETUP_MENU(31), 'fullscreen : ' + BoolToStr(bDisplayFullscreen), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(32), 'resolution : ' + Format('%d x %d', [nDisplayWidth,nDisplayHeight]), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(33), 'format : ' + IntToStr(nDisplayBPP) + ' bits', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(34), 'refresh rate : ' + IntToStr(nDisplayRefreshrate) + ' Hz', 0.2, 1.0, 600 );

     SetString( STRING_SETUP_MENU(41), 'p1 move up    : ' + KeyToStr(nKey1MoveUp), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(42), 'p1 move down  : ' + KeyToStr(nKey1MoveDown), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(43), 'p1 move left  : ' + KeyToStr(nKey1MoveLeft), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(44), 'p1 move right : ' + KeyToStr(nKey1MoveRight), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(45), 'p1 primary    : ' + KeyToStr(nKey1Primary), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(46), 'p1 secondary  : ' + KeyToStr(nKey1Secondary), 0.2, 1.0, 600 );

     SetString( STRING_SETUP_MENU(51), 'p2 move up    : ' + KeyToStr(nKey2MoveUp), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(52), 'p2 move down  : ' + KeyToStr(nKey2MoveDown), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(53), 'p2 move left  : ' + KeyToStr(nKey2MoveLeft), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(54), 'p2 move right : ' + KeyToStr(nKey2MoveRight), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(55), 'p2 primary    : ' + KeyToStr(nKey2Primary), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(56), 'p2 secondary  : ' + KeyToStr(nKey2Secondary), 0.2, 1.0, 600 );

     fScroll := 0.0;

     nMenu := MENU_INTRO;

     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     bEscape := False;
End;



Procedure ProcessMenuOnline () ;
          Function IsActive( nConst : Integer ) : Single ;
          Begin
               If nConst = nMenu Then IsActive := 0.0 Else IsActive := 1.0;
          End;
Var w, h : Single;
    x, y, z : Integer;
    t : Single;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     DrawString( STRING_SCORE_TABLE(1), -w / h * 0.5,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     t := 0.0;

     If fScroll <= t Then DrawString( STRING_SETUP_MENU(11), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_INTRO), IsActive(MENU_INTRO), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

     t += 0.2;

     If fScroll <= t Then DrawString( STRING_SETUP_MENU(21), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_FRAMERATE), IsActive(MENU_FRAMERATE), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(22), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_LIGHTING), IsActive(MENU_LIGHTING), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(23), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_SHADOWING), IsActive(MENU_SHADOWING), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(24), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_REFLECTION), IsActive(MENU_REFLECTION), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(25), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_EFFECTS), IsActive(MENU_EFFECTS), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(26), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_BLUR), IsActive(MENU_BLUR), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(27), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_TEXTURING), IsActive(MENU_TEXTURING), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(28), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_SHADERMODEL), IsActive(MENU_SHADERMODEL), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

     t += 0.2;

     If fScroll <= t Then DrawString( STRING_SETUP_MENU(31), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_FULLSCREEN), IsActive(MENU_FULLSCREEN), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(32), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_RESOLUTION), IsActive(MENU_RESOLUTION), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(33), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_FORMAT), IsActive(MENU_FORMAT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(34), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_REFRESHRATE), IsActive(MENU_REFRESHRATE), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

     t += 0.2;

     If fScroll <= t Then DrawString( STRING_SETUP_MENU(41), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P1MOVEUP), IsActive(MENU_P1MOVEUP), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(42), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P1MOVEDOWN), IsActive(MENU_P1MOVEDOWN), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(43), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P1MOVELEFT), IsActive(MENU_P1MOVELEFT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(44), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P1MOVERIGHT), IsActive(MENU_P1MOVERIGHT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(45), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P1PRIMARY), IsActive(MENU_P1PRIMARY), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(46), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P1SECONDARY), IsActive(MENU_P1SECONDARY), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

     t += 0.2;

     If fScroll <= t Then DrawString( STRING_SETUP_MENU(51), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P2MOVEUP), IsActive(MENU_P2MOVEUP), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(52), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P2MOVEDOWN), IsActive(MENU_P2MOVEDOWN), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(53), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P2MOVELEFT), IsActive(MENU_P2MOVELEFT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(54), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P2MOVERIGHT), IsActive(MENU_P2MOVERIGHT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(55), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P2PRIMARY), IsActive(MENU_P2PRIMARY), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(56), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_P2SECONDARY), IsActive(MENU_P2SECONDARY), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;

     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_FRAMERATE Then nMenu := MENU_INTRO Else
           If nMenu = MENU_LIGHTING Then nMenu := MENU_FRAMERATE Else
           If nMenu = MENU_SHADOWING Then nMenu := MENU_LIGHTING Else
           If nMenu = MENU_REFLECTION Then nMenu := MENU_SHADOWING Else
           If nMenu = MENU_EFFECTS Then nMenu := MENU_REFLECTION Else
           If nMenu = MENU_BLUR Then nMenu := MENU_EFFECTS Else
           If nMenu = MENU_TEXTURING Then nMenu := MENU_BLUR Else
           If nMenu = MENU_SHADERMODEL Then nMenu := MENU_TEXTURING Else
           If nMenu = MENU_FULLSCREEN Then nMenu := MENU_SHADERMODEL Else
           If nMenu = MENU_RESOLUTION Then nMenu := MENU_FULLSCREEN Else
           If nMenu = MENU_FORMAT Then nMenu := MENU_RESOLUTION Else
           If nMenu = MENU_REFRESHRATE Then nMenu := MENU_FORMAT Else
           If nMenu = MENU_P1MOVEUP Then nMenu := MENU_REFRESHRATE Else
           If nMenu = MENU_P1MOVEDOWN Then nMenu := MENU_P1MOVEUP Else
           If nMenu = MENU_P1MOVELEFT Then nMenu := MENU_P1MOVEDOWN Else
           If nMenu = MENU_P1MOVERIGHT Then nMenu := MENU_P1MOVELEFT Else
           If nMenu = MENU_P1PRIMARY Then nMenu := MENU_P1MOVERIGHT Else
           If nMenu = MENU_P1SECONDARY Then nMenu := MENU_P1PRIMARY Else
           If nMenu = MENU_P2MOVEUP Then nMenu := MENU_P1SECONDARY Else
           If nMenu = MENU_P2MOVEDOWN Then nMenu := MENU_P2MOVEUP Else
           If nMenu = MENU_P2MOVELEFT Then nMenu := MENU_P2MOVEDOWN Else
           If nMenu = MENU_P2MOVERIGHT Then nMenu := MENU_P2MOVELEFT Else
           If nMenu = MENU_P2PRIMARY Then nMenu := MENU_P2MOVERIGHT Else
           If nMenu = MENU_P2SECONDARY Then nMenu := MENU_P2PRIMARY Else
           If nMenu = MENU_INTRO Then nMenu := MENU_P2SECONDARY;

           t := 0.0;
           If (nMenu = MENU_INTRO) And (fScroll > t) Then fScroll := t; t += 0.2;
           t += 0.2;
           If (nMenu = MENU_FRAMERATE) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_LIGHTING) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_SHADOWING) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_REFLECTION) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_EFFECTS) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_BLUR) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_TEXTURING) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_SHADERMODEL) And (fScroll > t) Then fScroll := t; t += 0.2;
           t += 0.2;
           If (nMenu = MENU_FULLSCREEN) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_RESOLUTION) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_FORMAT) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_REFRESHRATE) And (fScroll > t) Then fScroll := t; t += 0.2;
           t += 0.2;
           If (nMenu = MENU_P1MOVEUP) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1MOVEDOWN) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1MOVELEFT) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1MOVERIGHT) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1PRIMARY) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1SECONDARY) And (fScroll > t) Then fScroll := t; t += 0.2;
           t -= 0.2;
           If nMenu = MENU_P2SECONDARY Then fScroll := t;
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;

     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_P2SECONDARY Then nMenu := MENU_INTRO Else
           If nMenu = MENU_P2PRIMARY Then nMenu := MENU_P2SECONDARY Else
           If nMenu = MENU_P2MOVERIGHT Then nMenu := MENU_P2PRIMARY Else
           If nMenu = MENU_P2MOVELEFT Then nMenu := MENU_P2MOVERIGHT Else
           If nMenu = MENU_P2MOVEDOWN Then nMenu := MENU_P2MOVELEFT Else
           If nMenu = MENU_P2MOVEUP Then nMenu := MENU_P2MOVEDOWN Else
           If nMenu = MENU_P1SECONDARY Then nMenu := MENU_P2MOVEUP Else
           If nMenu = MENU_P1PRIMARY Then nMenu := MENU_P1SECONDARY Else
           If nMenu = MENU_P1MOVERIGHT Then nMenu := MENU_P1PRIMARY Else
           If nMenu = MENU_P1MOVELEFT Then nMenu := MENU_P1MOVERIGHT Else
           If nMenu = MENU_P1MOVEDOWN Then nMenu := MENU_P1MOVELEFT Else
           If nMenu = MENU_P1MOVEUP Then nMenu := MENU_P1MOVEDOWN Else
           If nMenu = MENU_REFRESHRATE Then nMenu := MENU_P1MOVEUP Else
           If nMenu = MENU_FORMAT Then nMenu := MENU_REFRESHRATE Else
           If nMenu = MENU_RESOLUTION Then nMenu := MENU_FORMAT Else
           If nMenu = MENU_FULLSCREEN Then nMenu := MENU_RESOLUTION Else
           If nMenu = MENU_SHADERMODEL Then nMenu := MENU_FULLSCREEN Else
           If nMenu = MENU_TEXTURING Then nMenu := MENU_SHADERMODEL Else
           If nMenu = MENU_BLUR Then nMenu := MENU_TEXTURING Else
           If nMenu = MENU_EFFECTS Then nMenu := MENU_BLUR Else
           If nMenu = MENU_REFLECTION Then nMenu := MENU_EFFECTS Else
           If nMenu = MENU_SHADOWING Then nMenu := MENU_REFLECTION Else
           If nMenu = MENU_LIGHTING Then nMenu := MENU_SHADOWING Else
           If nMenu = MENU_FRAMERATE Then nMenu := MENU_LIGHTING Else
           If nMenu = MENU_INTRO Then nMenu := MENU_FRAMERATE;

           t := 0.0;
           If nMenu = MENU_INTRO Then fScroll := 0.0;
           t += 0.2;
           If (nMenu = MENU_TEXTURING) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_SHADERMODEL) And (fScroll < t) Then fScroll := t; t += 0.2;
           t += 0.2;
           If (nMenu = MENU_FULLSCREEN) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_RESOLUTION) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_FORMAT) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_REFRESHRATE) And (fScroll < t) Then fScroll := t; t += 0.2;
           t += 0.2;
           If (nMenu = MENU_P1MOVEUP) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1MOVEDOWN) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1MOVELEFT) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1MOVERIGHT) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1PRIMARY) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P1SECONDARY) And (fScroll < t) Then fScroll := t; t += 0.2;
           t += 0.2;
           If (nMenu = MENU_P2MOVEUP) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P2MOVEDOWN) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P2MOVELEFT) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P2MOVERIGHT) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P2PRIMARY) And (fScroll < t) Then fScroll := t; t += 0.2;
           If (nMenu = MENU_P2SECONDARY) And (fScroll < t) Then fScroll := t; t += 0.2;
        End;
        bDown := True;
     End Else Begin
        bDown := False;
     End;

     If GetKeyS( KEY_LEFT ) Then Begin
        If Not bLeft Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_INTRO :
                Begin
                     bIntro := Not bIntro;
                     SetString( STRING_SETUP_MENU(11), 'show intro : ' + BoolToStr(bIntro), 0.0, 0.02, 600 );
                End;
                MENU_FRAMERATE :
                Begin
                     nFramerate -= 5;
                     If nFramerate < 5 Then nFramerate := 5;
                     SetString( STRING_SETUP_MENU(21), 'desired framerate : ' + IntToStr(nFramerate), 0.0, 0.02, 600 );
                End;
                MENU_LIGHTING :
                Begin
                     bLighting := Not bLighting;
                     SetString( STRING_SETUP_MENU(22), 'lighting : ' + BoolToStr(bLighting), 0.0, 0.02, 600 );
                End;
                MENU_SHADOWING :
                Begin
                     bShadowing := Not bShadowing;
                     SetString( STRING_SETUP_MENU(23), 'shadowing : ' + BoolToStr(bShadowing), 0.0, 0.02, 600 );
                End;
                MENU_REFLECTION :
                Begin
                     bReflection := Not bReflection;
                     SetString( STRING_SETUP_MENU(24), 'reflection : ' + BoolToStr(bReflection), 0.0, 0.02, 600 );
                End;
                MENU_EFFECTS :
                Begin
                     bEffects := Not bEffects;
                     SetString( STRING_SETUP_MENU(25), 'effects : ' + BoolToStr(bEffects), 0.0, 0.02, 600 );
                End;
                MENU_BLUR :
                Begin
                     bBlur := Not bBlur;
                     SetString( STRING_SETUP_MENU(26), 'blur : ' + BoolToStr(bBlur), 0.0, 0.02, 600 );
                End;
                MENU_TEXTURING :
                Begin
                     nTexturing -= 1;
                     If nTexturing < 1 Then nTexturing := 1;
                     SetString( STRING_SETUP_MENU(27), 'texturing quality : ' + IntToStr(nTexturing), 0.0, 0.02, 600 );
                End;
                MENU_SHADERMODEL :
                Begin
                     nShaderModel -= 1;
                     If nShaderModel < 2 Then nShaderModel := 2;
                     SetString( STRING_SETUP_MENU(28), 'shader model : ' + IntToStr(nShaderModel), 0.0, 0.02, 600 );
                     InitShaderProgram();
                End;
                MENU_FULLSCREEN :
                Begin
                     bDisplayFullscreen := Not bDisplayFullscreen;
                     SetString( STRING_SETUP_MENU(31), 'fullscreen : ' + BoolToStr(bDisplayFullscreen), 0.0, 0.02, 600 );
                End;
                MENU_RESOLUTION :
                Begin
                     x := nDisplayWidth;
                     If nDisplayWidth = 800 Then nDisplayWidth := 640;
                     If nDisplayWidth = 1024 Then nDisplayWidth := 800;
                     If nDisplayWidth = 1280 Then nDisplayWidth := 1024;
                     If nDisplayWidth = 1600 Then nDisplayWidth := 1280;
                     y := nDisplayHeight;
                     If nDisplayHeight = 600 Then nDisplayHeight := 480;
                     If nDisplayHeight = 768 Then nDisplayHeight := 600;
                     If nDisplayHeight = 960 Then nDisplayHeight := 768;
                     If nDisplayHeight = 1200 Then nDisplayHeight := 960;
                     If Not CheckDisplay() Then Begin
                        nDisplayWidth := x;
                        nDisplayHeight := y;
                     End;
                     SetString( STRING_SETUP_MENU(32), 'resolution : ' + Format('%d x %d', [nDisplayWidth,nDisplayHeight]), 0.0, 0.02, 600 );
                End;
                MENU_FORMAT :
                Begin
                     nDisplayBPP := 16;
                     If Not CheckDisplay() Then
                        nDisplayBPP := 32;
                     SetString( STRING_SETUP_MENU(33), 'format : ' + IntToStr(nDisplayBPP) + ' bits', 0.0, 0.02, 600 );
                End;
                MENU_REFRESHRATE :
                Begin
                     z := nDisplayRefreshrate;
                     If nDisplayRefreshrate = 70 Then nDisplayRefreshrate := 60;
                     If nDisplayRefreshrate = 75 Then nDisplayRefreshrate := 70;
                     If nDisplayRefreshrate = 85 Then nDisplayRefreshrate := 75;
                     If nDisplayRefreshrate = 100 Then nDisplayRefreshrate := 85;
                     If nDisplayRefreshrate = 120 Then nDisplayRefreshrate := 100;
                     If Not CheckDisplay() Then
                        nDisplayRefreshrate := z;
                     SetString( STRING_SETUP_MENU(34), 'refresh rate : ' + IntToStr(nDisplayRefreshrate) + ' Hz', 0.0, 0.02, 600 );
                End;
           End;
        End;
        bLeft := True;
     End Else Begin
        bLeft := False;
     End;

     If GetKeyS( KEY_RIGHT ) Then Begin
        If Not bRight Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_INTRO :
                Begin
                     bIntro := Not bIntro;
                     SetString( STRING_SETUP_MENU(11), 'show intro : ' + BoolToStr(bIntro), 0.0, 0.02, 600 );
                End;
                MENU_FRAMERATE :
                Begin
                     nFramerate += 5;
                     If nFramerate > 2000 Then nFramerate := 2000;
                     SetString( STRING_SETUP_MENU(21), 'desired framerate : ' + IntToStr(nFramerate), 0.0, 0.02, 600 );
                End;
                MENU_LIGHTING :
                Begin
                     bLighting := Not bLighting;
                     SetString( STRING_SETUP_MENU(22), 'lighting : ' + BoolToStr(bLighting), 0.0, 0.02, 600 );
                End;
                MENU_SHADOWING :
                Begin
                     bShadowing := Not bShadowing;
                     SetString( STRING_SETUP_MENU(23), 'shadowing : ' + BoolToStr(bShadowing), 0.0, 0.02, 600 );
                End;
                MENU_REFLECTION :
                Begin
                     bReflection := Not bReflection;
                     SetString( STRING_SETUP_MENU(24), 'reflection : ' + BoolToStr(bReflection), 0.0, 0.02, 600 );
                End;
                MENU_EFFECTS :
                Begin
                     bEffects := Not bEffects;
                     SetString( STRING_SETUP_MENU(25), 'effects : ' + BoolToStr(bEffects), 0.0, 0.02, 600 );
                End;
                MENU_BLUR :
                Begin
                     bBlur := Not bBlur;
                     SetString( STRING_SETUP_MENU(26), 'blur : ' + BoolToStr(bBlur), 0.0, 0.02, 600 );
                End;
                MENU_TEXTURING :
                Begin
                     nTexturing += 1;
                     If nTexturing > 11 Then nTexturing := 11;
                     SetString( STRING_SETUP_MENU(27), 'texturing quality : ' + IntToStr(nTexturing), 0.0, 0.02, 600 );
                End;
                MENU_SHADERMODEL :
                Begin
                     nShaderModel += 1;
                     If nShaderModel > 4 Then nShaderModel := 4;
                     SetString( STRING_SETUP_MENU(28), 'shader model : ' + IntToStr(nShaderModel), 0.0, 0.02, 600 );
                     InitShaderProgram();
                End;
                MENU_FULLSCREEN :
                Begin
                     bDisplayFullscreen := Not bDisplayFullscreen;
                     SetString( STRING_SETUP_MENU(31), 'fullscreen : ' + BoolToStr(bDisplayFullscreen), 0.0, 0.02, 600 );
                End;
                MENU_RESOLUTION :
                Begin
                     x := nDisplayWidth;
                     If nDisplayWidth = 1280 Then nDisplayWidth := 1600;
                     If nDisplayWidth = 1024 Then nDisplayWidth := 1280;
                     If nDisplayWidth = 800 Then nDisplayWidth := 1024;
                     If nDisplayWidth = 640 Then nDisplayWidth := 800;
                     y := nDisplayHeight;
                     If nDisplayHeight = 960 Then nDisplayHeight := 1200;
                     If nDisplayHeight = 768 Then nDisplayHeight := 960;
                     If nDisplayHeight = 600 Then nDisplayHeight := 768;
                     If nDisplayHeight = 480 Then nDisplayHeight := 600;
                     If Not CheckDisplay() Then Begin
                        nDisplayWidth := x;
                        nDisplayHeight := y;
                     End;
                     SetString( STRING_SETUP_MENU(32), 'resolution : ' + Format('%d x %d', [nDisplayWidth,nDisplayHeight]), 0.0, 0.02, 600 );
                End;
                MENU_FORMAT :
                Begin
                     nDisplayBPP := 32;
                     If Not CheckDisplay() Then
                        nDisplayBPP := 16;
                     SetString( STRING_SETUP_MENU(33), 'format : ' + IntToStr(nDisplayBPP) + ' bits', 0.0, 0.02, 600 );
                End;
                MENU_REFRESHRATE :
                Begin
                     z := nDisplayRefreshrate;
                     If nDisplayRefreshrate = 100 Then nDisplayRefreshrate := 120;
                     If nDisplayRefreshrate = 85 Then nDisplayRefreshrate := 100;
                     If nDisplayRefreshrate = 75 Then nDisplayRefreshrate := 85;
                     If nDisplayRefreshrate = 70 Then nDisplayRefreshrate := 75;
                     If nDisplayRefreshrate = 60 Then nDisplayRefreshrate := 70;
                     If Not CheckDisplay() Then
                        nDisplayRefreshrate := z;
                     SetString( STRING_SETUP_MENU(34), 'refresh rate : ' + IntToStr(nDisplayRefreshrate) + ' Hz', 0.0, 0.02, 600 );
                End;
           End;
        End;
        bRight := True;
     End Else Begin
        bRight := False;
     End;

     If GetKey( KEY_ENTER ) Then Begin
        If Not bEnter Then Begin
           PlaySound( SOUND_MENU_CLICK );
           nSetup := SETUP_KEY;
           Case nMenu Of
                MENU_P1MOVEUP : InitBox( 'player 1 move up', 'press any key' );
                MENU_P1MOVEDOWN : InitBox( 'player 1 move down', 'press any key' );
                MENU_P1MOVELEFT : InitBox( 'player 1 move left', 'press any key' );
                MENU_P1MOVERIGHT : InitBox( 'player 1 move right', 'press any key' );
                MENU_P1PRIMARY : InitBox( 'player 1 primary', 'press any key' );
                MENU_P1SECONDARY : InitBox( 'player 1 secondary', 'press any key' );
                MENU_P2MOVEUP : InitBox( 'player 2 move up', 'press any key' );
                MENU_P2MOVEDOWN : InitBox( 'player 2 move down', 'press any key' );
                MENU_P2MOVELEFT : InitBox( 'player 2 move left', 'press any key' );
                MENU_P2MOVERIGHT : InitBox( 'player 2 move right', 'press any key' );
                MENU_P2PRIMARY : InitBox( 'player 2 primary', 'press any key' );
                MENU_P2SECONDARY : InitBox( 'player 2 secondary', 'press any key' );
           Else
                nSetup := SETUP_MENU;
           End;
        End;
        bEnter := True;
     End Else Begin
        bEnter := False;
     End;

End;



End.
