Unit USetup;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UMap, UScheme, UCharacter, UForm;

Const PLAYER_NIL = 0;
Const PLAYER_KB1 = 1;
Const PLAYER_KB2 = 2;
Const PLAYER_COM = 3;
Const PLAYER_NET = 4;

Const SERVER_UNKNOWN = 0;
Const SERVER_STANDARD = 1;
Const SERVER_EXTENDED = 2;

Var sLocalName : String; // a sauvegarder
Var nLocalIndex : DWord;
Var sServerAddress : String; // a sauvegarder
Var nServerPort : Word; // a sauvegarder
Var nServerType : Integer; // a sauvegarder

Var nVersion : Integer;

Var bDebug : Boolean;

Var bColor : Boolean; // a sauvegarder et afficher

Var bIntro : Boolean;

Var nRoundCount : Integer;
Var fRoundDuration : Single; // a sauvegarder et afficher

Var nWindowLeft : Integer;
Var nWindowTop : Integer;
Var nWindowWidth : Integer;
Var nWindowHeight : Integer;
Var nFramerate : Integer;
Var bLighting : Boolean;
Var bShadowing : Boolean;
Var bReflection : Boolean;
Var nTexturing : Integer;
Var bDisplayFullscreen : Boolean;
Var nDisplayWidth : Integer;
Var nDisplayHeight : Integer;
Var nDisplayBPP : Integer;
Var nDisplayRefreshrate : Integer;

Var aSchemeList : Array [0..255] Of CScheme;
Var nSchemeCount : Integer;
Var pScheme : CScheme;
Var nScheme : Integer;

Var aMapList : Array [0..255] Of CMap;
Var nMapCount : Integer;
Var pMap : CMap;
Var nMap : Integer;

Var aCharacterList : Array [0..255] Of CCharacter;
Var nCharacterCount : Integer;

Var pPlayerCharacter : Array [1..8] Of CCharacter;
Var nPlayerCharacter : Array [1..8] Of Integer;
Var sPlayerName : Array [1..8] Of String;
Var nPlayerType : Array [1..8] Of Integer;
Var nPlayerSkill : Array [1..8] Of Integer;
Var nPlayerClient : Array [1..8] Of Integer;

Var nKey1Primary : Integer;
Var nKey1Secondary : Integer;
Var nKey1MoveUp : Integer;
Var nKey1MoveDown : Integer;
Var nKey1MoveLeft : Integer;
Var nKey1MoveRight : Integer;

Var nKey2Primary : Integer;
Var nKey2Secondary : Integer;
Var nKey2MoveUp : Integer;
Var nKey2MoveDown : Integer;
Var nKey2MoveLeft : Integer;
Var nKey2MoveRight : Integer;

Procedure ReadSettings ( sFile : String ) ;
Procedure WriteSettings ( sFile : String ) ;

Procedure InitSetup () ;
Procedure ProcessSetup () ;



Implementation



Uses UCore;



Var fScroll : Single;



Const SETUP_MENU         = 0;
Const SETUP_KEY          = 1;

Var nSetup  : Integer;



Const MENU_INTRO         = 11;

Const MENU_FRAMERATE     = 21;
Const MENU_LIGHTING      = 22;
Const MENU_SHADOWING     = 23;
Const MENU_REFLECTION    = 24;
Const MENU_TEXTURING     = 25;

Const MENU_FULLSCREEN    = 31;
Const MENU_RESOLUTION    = 32;
Const MENU_FORMAT        = 33;
Const MENU_REFRESHRATE   = 34;

Const MENU_P1MOVEUP      = 41;
Const MENU_P1MOVEDOWN    = 42;
Const MENU_P1MOVELEFT    = 43;
Const MENU_P1MOVERIGHT   = 44;
Const MENU_P1PRIMARY     = 45;
Const MENU_P1SECONDARY   = 46;

Const MENU_P2MOVEUP      = 51;
Const MENU_P2MOVEDOWN    = 52;
Const MENU_P2MOVELEFT    = 53;
Const MENU_P2MOVERIGHT   = 54;
Const MENU_P2PRIMARY     = 55;
Const MENU_P2SECONDARY   = 56;

Var nMenu  : Integer;



Var bUp     : Boolean;
Var bDown   : Boolean;
Var bLeft   : Boolean;
Var bRight  : Boolean;
Var bEnter  : Boolean;
Var bEscape : Boolean;



Procedure InitMenu () ;
Begin
     SetString( STRING_SETUP_MENU(1), 'setup', 0.2, 1.0, 600 );

     SetString( STRING_SETUP_MENU(11), 'show intro : ' + BoolToStr(bIntro), 0.2, 1.0, 600 );
     
     SetString( STRING_SETUP_MENU(21), 'desired framerate : ' + IntToStr(nFramerate), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(22), 'lighting : ' + BoolToStr(bLighting), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(23), 'shadowing : ' + BoolToStr(bShadowing), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(24), 'reflection : ' + BoolToStr(bReflection), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(25), 'texturing quality : ' + IntToStr(nTexturing), 0.2, 1.0, 600 );
     
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



Procedure ProcessKey () ;
Var k : Integer ;
Begin
     DrawBox( 0.4, 0.4, 0.3, -0.4 );

     If GetKey( KEY_ESC ) Then Begin
        nSetup := SETUP_MENU;
        PlaySound( SOUND_MENU_BACK );
        ClearInput();
     End Else Begin
        If Not GetKey( KEY_ENTER ) Then Begin
           For k := 0 To 255 Do Begin
               If GetKey( k ) Then Begin
                  Case nMenu Of
                       MENU_P1MOVEUP : nKey1MoveUp := k;
                       MENU_P1MOVEDOWN : nKey1MoveDown := k;
                       MENU_P1MOVELEFT : nKey1MoveLeft := k;
                       MENU_P1MOVERIGHT : nKey1MoveRight := k;
                       MENU_P1PRIMARY : nKey1Primary := k;
                       MENU_P1SECONDARY : nKey1Secondary := k;
                       MENU_P2MOVEUP : nKey2MoveUp := k;
                       MENU_P2MOVEDOWN : nKey2MoveDown := k;
                       MENU_P2MOVELEFT : nKey2MoveLeft := k;
                       MENU_P2MOVERIGHT : nKey2MoveRight := k;
                       MENU_P2PRIMARY : nKey2Primary := k;
                       MENU_P2SECONDARY : nKey2Secondary := k;
                  End;
                  nSetup := SETUP_MENU;
               End;
               If GetKeyS( -k ) Then Begin
                  Case nMenu Of
                       MENU_P1MOVEUP : nKey1MoveUp := -k;
                       MENU_P1MOVEDOWN : nKey1MoveDown := -k;
                       MENU_P1MOVELEFT : nKey1MoveLeft := -k;
                       MENU_P1MOVERIGHT : nKey1MoveRight := -k;
                       MENU_P1PRIMARY : nKey1Primary := -k;
                       MENU_P1SECONDARY : nKey1Secondary := -k;
                       MENU_P2MOVEUP : nKey2MoveUp := -k;
                       MENU_P2MOVEDOWN : nKey2MoveDown := -k;
                       MENU_P2MOVELEFT : nKey2MoveLeft := -k;
                       MENU_P2MOVERIGHT : nKey2MoveRight := -k;
                       MENU_P2PRIMARY : nKey2Primary := -k;
                       MENU_P2SECONDARY : nKey2Secondary := -k;
                  End;
                  nSetup := SETUP_MENU;
               End;
           End;
           If nSetup = SETUP_MENU Then Begin
              PlaySound( SOUND_MENU_CLICK );
              Case nMenu Of
                   MENU_P1MOVEUP    : SetString( STRING_SETUP_MENU(41), 'p1 move up    : ' + KeyToStr(nKey1MoveUp), 0.0, 0.02, 600 );
                   MENU_P1MOVEDOWN  : SetString( STRING_SETUP_MENU(42), 'p1 move down  : ' + KeyToStr(nKey1MoveDown), 0.0, 0.02, 600 );
                   MENU_P1MOVELEFT  : SetString( STRING_SETUP_MENU(43), 'p1 move left  : ' + KeyToStr(nKey1MoveLeft), 0.0, 0.02, 600 );
                   MENU_P1MOVERIGHT : SetString( STRING_SETUP_MENU(44), 'p1 move right : ' + KeyToStr(nKey1MoveRight), 0.0, 0.02, 600 );
                   MENU_P1PRIMARY   : SetString( STRING_SETUP_MENU(45), 'p1 primary    : ' + KeyToStr(nKey1Primary), 0.0, 0.02, 600 );
                   MENU_P1SECONDARY : SetString( STRING_SETUP_MENU(46), 'p1 secondary  : ' + KeyToStr(nKey1Secondary), 0.0, 0.02, 600 );
                   MENU_P2MOVEUP    : SetString( STRING_SETUP_MENU(51), 'p2 move up    : ' + KeyToStr(nKey2MoveUp), 0.0, 0.02, 600 );
                   MENU_P2MOVEDOWN  : SetString( STRING_SETUP_MENU(52), 'p2 move down  : ' + KeyToStr(nKey2MoveDown), 0.0, 0.02, 600 );
                   MENU_P2MOVELEFT  : SetString( STRING_SETUP_MENU(53), 'p2 move left  : ' + KeyToStr(nKey2MoveLeft), 0.0, 0.02, 600 );
                   MENU_P2MOVERIGHT : SetString( STRING_SETUP_MENU(54), 'p2 move right : ' + KeyToStr(nKey2MoveRight), 0.0, 0.02, 600 );
                   MENU_P2PRIMARY   : SetString( STRING_SETUP_MENU(55), 'p2 primary    : ' + KeyToStr(nKey2Primary), 0.0, 0.02, 600 );
                   MENU_P2SECONDARY : SetString( STRING_SETUP_MENU(56), 'p2 secondary  : ' + KeyToStr(nKey2Secondary), 0.0, 0.02, 600 );
              End;
              ClearInput();
              SetString( STRING_SETUP_MENU(1), 'setup', 0.0, 0.02, 600 );
           End;
        End;
     End;
End;



Procedure ProcessMenu () ;
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
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(25), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_TEXTURING), IsActive(MENU_TEXTURING), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

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
           If nMenu = MENU_TEXTURING Then nMenu := MENU_REFLECTION Else
           If nMenu = MENU_FULLSCREEN Then nMenu := MENU_TEXTURING Else
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
           If (nMenu = MENU_TEXTURING) And (fScroll > t) Then fScroll := t; t += 0.2;
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
           If nMenu = MENU_TEXTURING Then nMenu := MENU_FULLSCREEN Else
           If nMenu = MENU_SHADOWING Then nMenu := MENU_REFLECTION Else
           If nMenu = MENU_REFLECTION Then nMenu := MENU_TEXTURING Else
           If nMenu = MENU_LIGHTING Then nMenu := MENU_SHADOWING Else
           If nMenu = MENU_FRAMERATE Then nMenu := MENU_LIGHTING Else
           If nMenu = MENU_INTRO Then nMenu := MENU_FRAMERATE;

           t := 0.0;
           If nMenu = MENU_INTRO Then fScroll := 0.0;
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
                MENU_TEXTURING :
                Begin
                     nTexturing -= 1;
                     If nTexturing < 1 Then nTexturing := 1;
                     SetString( STRING_SETUP_MENU(25), 'texturing quality : ' + IntToStr(nTexturing), 0.0, 0.02, 600 );
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
                MENU_TEXTURING :
                Begin
                     nTexturing += 1;
                     If nTexturing > 11 Then nTexturing := 11;
                     SetString( STRING_SETUP_MENU(25), 'texturing quality : ' + IntToStr(nTexturing), 0.0, 0.02, 600 );
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



Procedure InitSetup () ;
Var tFile : TSearchRec;
    sFile : String;
    k : Integer;
Begin
     // initialisation du menu
     InitMenu();

     // création de la liste des schemes
     sFile := '';
     FindFirst( './schemes/*.sch', faAnyFile, tFile );
     For k := 0 To 255 Do Begin
         If sFile = tFile.Name Then Break;
         sFile := tFile.Name;
         aSchemeList[k] := CScheme.Create( sFile, False );
         FindNext( tFile );
     End;
     nSchemeCount := k;
     
     // création de la liste des maps
     sFile := '';
     FindFirst( './maps/*.map', faAnyFile, tFile );
     For k := 0 To 255 Do Begin
         If sFile = tFile.Name Then Break;
         sFile := tFile.Name;
         aMapList[k] := CMap.Create( sFile, False );
         FindNext( tFile );
     End;
     nMapCount := k;

     // création de la liste des characters
     sFile := '';
     FindFirst( './characters/*.chr', faAnyFile, tFile );
     For k := 0 To 255 Do Begin
         If sFile = tFile.Name Then Break;
         sFile := tFile.Name;
         aCharacterList[k] := CCharacter.Create( sFile, False );
         FindNext( tFile );
     End;
     nCharacterCount := k;

     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     // initialisation de l'éditeur
     nSetup := SETUP_MENU;

     // mise à jour de la machine d'état
     nState := STATE_SETUP;
End;



Procedure ProcessSetup () ;
Begin
     Case nSetup Of
          SETUP_MENU : ProcessMenu();
          SETUP_KEY : ProcessKey();
     End;
End;



Const STEP_NONE            =  0;
Const STEP_COMMENT         =  1;
Const STEP_VERSION         =  2;
Const STEP_PACKAGE         =  3;
Const STEP_MAP             =  4;
Const STEP_SCHEME          =  5;
Const STEP_CHARACTER       =  6;
Const STEP_KEY             =  7;
Const STEP_INTRO           =  8;
Const STEP_DISPLAY         =  9;
Const STEP_QUALITY         = 10;
Const STEP_WINDOW          = 11;
Const STEP_DEBUG           = 12;

Function GetStep ( sCommand : String ) : Integer ;
Var i : Integer;
    nStep : Integer;
Begin
     nStep := STEP_NONE;

     For i := 1 To Length(sCommand) Do
     Begin
          If (sCommand[i] = ';') Then nStep := STEP_COMMENT;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'V') Then nStep := STEP_VERSION;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'P') Then nStep := STEP_PACKAGE;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'S') Then nStep := STEP_SCHEME;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'C') Then nStep := STEP_CHARACTER;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'K') Then nStep := STEP_KEY;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'M') Then nStep := STEP_MAP;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'I') Then nStep := STEP_INTRO;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'D') Then nStep := STEP_DISPLAY;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'Q') Then nStep := STEP_QUALITY;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'W') Then nStep := STEP_WINDOW;
          If (sCommand[i] = '-') And (sCommand[i+1] = 'X') Then nStep := STEP_DEBUG;

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



Procedure ReadSettings ( sFile : String ) ;
Var ioLine : TEXT;
    sLine : String;
    i, k : Integer;
Begin
     Window.Memo.Lines.Add( 'Reading ' + sFile );
     
     For i := 0 To 255 Do Begin
         aSchemeList[i] := NIL;
         aMapList[i] := NIL;
         aCharacterList[i] := NIL;
     End;

     sLocalName := 'atominsa server';
     nLocalIndex := Random(1073741824);
     sServerAddress := '192.168.0.2';
     nServerPort := 1212;
     nServerType := SERVER_STANDARD;
     
     bIntro := True;
     
     bColor := True;

     bDebug := False;

     nWindowLeft := 120;
     nWindowTop := 80;
     nWindowWidth := 640;
     nWindowHeight := 480;
     nFramerate := 20;
     bLighting := False;
     bShadowing := False;
     bReflection := False;
     nTexturing := 8;
     bDisplayFullscreen := False;
     nDisplayWidth := 640;
     nDisplayHeight := 480;
     nDisplayBPP := 32;
     nDisplayRefreshrate := 60;

     nRoundCount := 3;
     fRoundDuration := 180.0*2;
     
     pScheme := NIL;
     nScheme := -1;
     
     pMap := NIL;
     nMap := -1;

     For k := 1 To 8 Do Begin
         pPlayerCharacter[k] := NIL;
         nPlayerCharacter[k] := -1;
         nPlayerType[k] := PLAYER_COM;
         nPlayerSkill[k] := 2;
         nPlayerClient[k] := -1;
     End;
     sPlayerName[1] := 'John Carmack';
     sPlayerName[2] := 'Shigeru Miyamoto';
     sPlayerName[3] := 'Michel Ancel';
     sPlayerName[4] := 'Warren Spector';
     sPlayerName[5] := 'Peter Molyneux';
     sPlayerName[6] := 'Chris Taylor';
     sPlayerName[7] := 'John Romero';
     sPlayerName[8] := 'Frederick Raynal';

     nKey1Primary := 48;
     nKey1Secondary := 46;
     nKey1MoveUp := -101;
     nKey1MoveDown := -103;
     nKey1MoveLeft := -100;
     nKey1MoveRight := -102;

     nKey2Primary := 98;
     nKey2Secondary := 110;
     nKey2MoveUp := 122;
     nKey2MoveDown := 115;
     nKey2MoveLeft := 113;
     nKey2MoveRight := 100;

     Assign( ioLine, sFile );
     Reset( ioLine );

     While EOF(ioLine) = False Do
     Begin
          ReadLn( ioLine, sLine );
          Case GetStep(sLine) Of
               STEP_VERSION :
               Begin
                    nVersion := GetInteger(sLine, 1);
                    AddLineToConsole( Format('Version : %d', [nVersion]) );
               End;
               STEP_CHARACTER :
               Begin
                    k := GetInteger(sLine, 1);
                    nPlayerCharacter[k] := GetInteger(sLine, 2);
                    If nPlayerCharacter[k] > -1 Then Begin
                       If aCharacterList[nPlayerCharacter[k]] <> NIL Then Begin
                          pPlayerCharacter[k] := aCharacterList[nPlayerCharacter[k]];
                          AddLineToConsole( 'Player ' + IntToStr(k) + ' character : ' + pPlayerCharacter[k].Name );
                       End Else Begin
                          AddLineToConsole( 'Player ' + IntToStr(k) + ' character : ' + '*UNKNOWN*' );
                       End;
                       End Else Begin
                          AddLineToConsole( 'Player ' + IntToStr(k) + ' character : ' + '*RANDOM*' );
                    End;
                    sPlayerName[k] := GetString(sLine, 3);
                    AddLineToConsole( 'Player ' + IntToStr(k) + ' name : ' + sPlayerName[k] );
                    nPlayerType[k] := GetInteger(sLine, 4);
                    If nPlayerType[k] = PLAYER_NIL Then AddLineToConsole( 'Player ' + IntToStr(k) + ' type : None' );
                    If nPlayerType[k] = PLAYER_KB1 Then AddLineToConsole( 'Player ' + IntToStr(k) + ' type : Keyboard 1' );
                    If nPlayerType[k] = PLAYER_KB2 Then AddLineToConsole( 'Player ' + IntToStr(k) + ' type : Keyboard 2' );
                    If nPlayerType[k] = PLAYER_COM Then AddLineToConsole( 'Player ' + IntToStr(k) + ' type : Computer' );
                    If nPlayerType[k] = PLAYER_NET Then AddLineToConsole( 'Player ' + IntToStr(k) + ' type : Network' );
                    nPlayerSkill[k] := GetInteger(sLine, 5);
                    If nPlayerSkill[k] = 1 Then AddLineToConsole( 'Player ' + IntToStr(k) + ' skill : Novice' );
                    If nPlayerSkill[k] = 2 Then AddLineToConsole( 'Player ' + IntToStr(k) + ' skill : Average' );
                    If nPlayerSkill[k] = 3 Then AddLineToConsole( 'Player ' + IntToStr(k) + ' skill : Masterful' );
                    If nPlayerSkill[k] = 4 Then AddLineToConsole( 'Player ' + IntToStr(k) + ' skill : Godlike' );
               End;
               STEP_SCHEME :
               Begin
                    k := GetInteger(sLine, 1);
                    nScheme := k;
                    If k = -1 Then Begin
                       AddLineToConsole( 'Scheme : *RANDOM*' );
                    End Else If aSchemeList[k] <> NIL Then Begin
                       pScheme := aSchemeList[k];
                       AddLineToConsole( 'Scheme : ' + pScheme.Name );
                    End Else Begin
                       AddLineToConsole( 'Scheme : *UNKNOWN*' );
                    End;
               End;
               STEP_MAP :
               Begin
                    k := GetInteger(sLine, 1);
                    nMap := k;
                    If k = -1 Then Begin
                       AddLineToConsole( 'Map : *RANDOM*' );
                    End Else If aMapList[k] <> NIL Then Begin
                       pMap := aMapList[k];
                       AddLineToConsole( 'Map : ' + pMap.Name );
                    End Else Begin
                       AddLineToConsole( 'Map : *UNKNOWN*' );
                    End;
               End;
               STEP_KEY :
               Begin
                    If GetInteger(sLine, 1) = 1 Then Begin
                       If LowerCase(GetString(sLine, 2)) = 'primary' Then nKey1Primary := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'secondary' Then nKey1Secondary := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveup' Then nKey1MoveUp := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'movedown' Then nKey1MoveDown := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveleft' Then nKey1MoveLeft := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveright' Then nKey1MoveRight := GetInteger(sLine, 3);
                    End;
                    If GetInteger(sLine, 1) = 2 Then Begin
                       If LowerCase(GetString(sLine, 2)) = 'primary' Then nKey2Primary := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'secondary' Then nKey2Secondary := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveup' Then nKey2MoveUp := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'movedown' Then nKey2MoveDown := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveleft' Then nKey2MoveLeft := GetInteger(sLine, 3);
                       If LowerCase(GetString(sLine, 2)) = 'moveright' Then nKey2MoveRight := GetInteger(sLine, 3);
                    End;
               End;
               STEP_PACKAGE :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'map' Then Begin
                       k := GetInteger(sLine, 2);
                       aMapList[k] := CMap.Create( GetString(sLine, 3), bDebug );
                       nMapCount += 1;
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'scheme' Then Begin
                       k := GetInteger(sLine, 2);
                       aSchemeList[k] := CScheme.Create( GetString(sLine, 3), bDebug );
                       nSchemeCount += 1;
                    End;
                    If LowerCase(GetString(sLine, 1)) = 'character' Then Begin
                       k := GetInteger(sLine, 2);
                       aCharacterList[k] := CCharacter.Create( GetString(sLine, 3), bDebug );
                       nCharacterCount += 1;
                    End;
               End;
               STEP_INTRO :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'true' Then bIntro := True;
                    If LowerCase(GetString(sLine, 1)) = 'false' Then bIntro := False;
                    If bIntro Then AddLineToConsole( 'Intro : Enabled' ) Else AddLineToConsole( 'Intro : Disabled' );
               End;
               STEP_DISPLAY :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'true' Then bDisplayFullscreen := True;
                    If LowerCase(GetString(sLine, 1)) = 'false' Then bDisplayFullscreen := False;
                    If bDisplayFullscreen Then AddLineToConsole( 'Fullscreen : Enabled' ) Else AddLineToConsole( 'Fullscreen : Disabled' );
                    nDisplayWidth := GetInteger(sLine, 2);
                    nDisplayHeight := GetInteger(sLine, 3);
                    nDisplayBPP := GetInteger(sLine, 4);
                    nDisplayRefreshrate := GetInteger(sLine, 5);
                    AddStringToConsole( Format(' ; Width : %d ; Height : %d ; BPP : %d ; @%d', [nDisplayWidth,nDisplayHeight,nDisplayBPP,nDisplayRefreshrate]) );
               End;
               STEP_QUALITY :
               Begin
                    nFramerate := GetInteger(sLine, 1);
                    AddLineToConsole( Format('Desired framerate : %d FPS', [nFramerate]) );
                    If LowerCase(GetString(sLine, 2)) = 'true' Then bLighting := True;
                    If LowerCase(GetString(sLine, 2)) = 'false' Then bLighting := False;
                    If bLighting Then AddLineToConsole( 'Lighting : Enabled' ) Else AddLineToConsole( 'Lighting : Disabled' );
                    If LowerCase(GetString(sLine, 3)) = 'true' Then bShadowing := True;
                    If LowerCase(GetString(sLine, 3)) = 'false' Then bShadowing := False;
                    If bShadowing Then AddLineToConsole( 'Shadowing : Enabled' ) Else AddLineToConsole( 'Shadowing : Disabled' );
                    If LowerCase(GetString(sLine, 4)) = 'true' Then bReflection := True;
                    If LowerCase(GetString(sLine, 4)) = 'false' Then bReflection := False;
                    If bReflection Then AddLineToConsole( 'Reflection : Enabled' ) Else AddLineToConsole( 'Reflection : Disabled' );
                    nTexturing := GetInteger(sLine, 5);
                    AddLineToConsole( Format('Texturing quality : %d', [nTexturing]) );
               End;
               STEP_WINDOW :
               Begin
                    nWindowLeft := GetInteger(sLine, 1);
                    nWindowTop := GetInteger(sLine, 2);
                    AddLineToConsole( Format('Window position : %dx%d', [nWindowLeft,nWindowTop]) );
                    nWindowWidth := GetInteger(sLine, 3);
                    nWindowHeight := GetInteger(sLine, 4);
                    AddLineToConsole( Format('Window size : %dx%d', [nWindowWidth,nWindowHeight]) );
               End;
               STEP_DEBUG :
               Begin
                    If LowerCase(GetString(sLine, 1)) = 'true' Then bDebug := True;
                    If LowerCase(GetString(sLine, 1)) = 'false' Then bDebug := False;
                    If bIntro Then AddLineToConsole( 'Debug : Enabled' ) Else AddLineToConsole( 'Debug : Disabled' );
               End;
          End;
     End;

     Close( ioLine );
End;



Procedure WriteSettings ( sFile : String ) ;
Var ioLine : TEXT;
    i : Integer;
    s : String;
Begin
     Assign( ioLine, sFile );
     Rewrite( ioLine );

     WriteLn( ioLine );
     WriteLn( ioLine , '; NOTE! This is an atominsa Configuration File.' );
     WriteLn( ioLine , '; Modify at your own risk. It is machine-generated and updated.' );
     WriteLn( ioLine );
     WriteLn( ioLine );

     WriteLn( ioLine , '; console debugging enabled ?' );
     If bDebug Then WriteLn( ioLine , '-X,true' ) Else WriteLn( ioLine , '-X,false' );

     WriteLn( ioLine );
     WriteLn( ioLine , '; version control number' );
     WriteLn( ioLine , '-V,2');

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of installed maps (index, file)' );

     For i := 0 To nMapCount - 1 Do
         WriteLn( ioLine , '-P,map,' + IntToStr(i) + ',' + aMapList[i].Path );

     WriteLn( ioLine );
     WriteLn( ioLine , '; index of the current map (-1 for random)' );

     //recuperation du n° correspondant a pMap
     WriteLn( ioLine , '-M,' + IntToStr(nMap) );

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of installed schemes (index, file)' );

     For i := 0 To nSchemeCount - 1 Do
         WriteLn( ioLine , '-P,scheme,' + IntToStr(i) + ',' + aSchemeList[i].Path );

     WriteLn( ioLine );
     WriteLn( ioLine , '; index of the current scheme (-1 for random)' );

     //recuperation du n° correspondant a pScheme
     WriteLn( ioLine , '-S,' + IntToStr(nScheme) );

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of installed characters (index, file)' );

     For i := 0 To nCharacterCount - 1 Do
         WriteLn( ioLine , '-P,character,' + IntToStr(i) + ',' + aCharacterList[i].Path );

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of player settings (player, character, name, type, skill)' );
     WriteLn( ioLine , '; player type : 0 = none ; 1 = key1 ; 2 = key2 ; 3 = computer ; 4 = network' );
     WriteLn( ioLine , '; player skill : 1 = novice ; 2 = average ; 3 = masterful ; 4 = godlike' );

     For i := 1 To 8 Do
         WriteLn( ioLine , Format( '-C,%d,%d,' + sPlayerName[i] + ',%d,%d', [i, nPlayerCharacter[i], nPlayerType[i], nPlayerSkill[i]] ) );

     WriteLn( ioLine );
     WriteLn( ioLine , '; this is the list of binded keys' );
     WriteLn( ioLine , '-K,1,primary,' + IntToStr(nKey1Primary) );
     WriteLn( ioLine , '-K,1,secondary,' + IntToStr(nKey1Secondary) );
     WriteLn( ioLine , '-K,1,moveup,' + IntToStr(nKey1MoveUp) );
     WriteLn( ioLine , '-K,1,movedown,' + IntToStr(nKey1MoveDown) );
     WriteLn( ioLine , '-K,1,moveleft,' + IntToStr(nKey1MoveLeft) );
     WriteLn( ioLine , '-K,1,moveright,' + IntToStr(nKey1MoveRight) );

     WriteLn( ioLine , '-K,2,primary,' + IntToStr(nKey2Primary) );
     WriteLn( ioLine , '-K,2,secondary,' + IntToStr(nKey2Secondary) );
     WriteLn( ioLine , '-K,2,moveup,' + IntToStr(nKey2MoveUp) );
     WriteLn( ioLine , '-K,2,movedown,' + IntToStr(nKey2MoveDown) );
     WriteLn( ioLine , '-K,2,moveleft,' + IntToStr(nKey2MoveLeft) );
     WriteLn( ioLine , '-K,2,moveright,' + IntToStr(nKey2MoveRight) );

     WriteLn( ioLine );
     WriteLn( ioLine , '; is the intro enabled ?' );
     If bIntro Then WriteLn( ioLine , '-I,true' ) Else WriteLn( ioLine , '-I,false' );

     WriteLn( ioLine );
     WriteLn( ioLine , '; display settings (fullscreen, width, height, bpp, refreshrate)' );
     s := '-D,';
     If bDisplayFullscreen Then s := s + 'true,' Else s := s + 'false,';
     s := s + IntToStr(nDisplayWidth) + ',';
     s := s + IntToStr(nDisplayHeight) + ',';
     s := s + IntToStr(nDisplayBPP) + ',';
     s := s + IntToStr(nDisplayRefreshrate);
     WriteLn( ioLine, s );

     WriteLn( ioLine );
     WriteLn( ioLine , '; quality settings (framerate, lighting, shadowing, reflection, texturing)' );
     s := '-Q,';
     s := s + IntToStr(nFramerate) + ',';
     If bLighting Then s := s + 'true,' Else s := s + 'false,';
     If bShadowing Then s := s + 'true,' Else s := s + 'false,';
     If bReflection Then s := s + 'true,' Else s := s + 'false,';
     s := s + IntToStr(nTexturing);
     WriteLn( ioLine, s );

     WriteLn( ioLine );
     WriteLn( ioLine , '; window settings (left, top, width, height)' );
     s := '-W,';
     s := s + IntToStr(nWindowLeft) + ',';
     s := s + IntToStr(nWindowTop) + ',';
     s := s + IntToStr(nWindowWidth) + ',';
     s := s + IntToStr(nWindowHeight);
     WriteLn( ioLine, s );

     Close(ioLine);
End;



End.
