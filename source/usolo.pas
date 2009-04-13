Unit USolo;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, USetup, UCore, UGame, UUtils;

Procedure InitSolo();
Procedure ProcessSolo();
Procedure ProcessMenuSolo();
Procedure InitMenuLevel();
Procedure ProcessMenuLevel();





Implementation

Uses UBomberman;

Const MENU_TITLE_NAME   = 240;
      MENU_SELECT_NAME  = 241;
      MENU_TITLE_LEVEL  = 242;
      MENU_SELECT_LEVEL = 243;
      MENU_FIGHT        = 244;

Var nMenu : Integer;
Var bUp : Boolean;
    bDown : Boolean;
    bLeft : Boolean;
    bRight : Boolean;
    bEnter : Boolean;
Var fScroll : Single;

Function PlayerLevel( n : Integer ) : String;
Begin
     Case nPlayerSkill[n] Of
          SKILL_NOVICE    : PlayerLevel := 'novice';
          SKILL_AVERAGE   : PlayerLevel := 'average';
          SKILL_MASTERFUL : PlayerLevel := 'masterful';
          SKILL_GODLIKE   : PlayerLevel := 'godlike'
          Else PlayerLevel := 'player';
     End;
End;

Procedure InitSolo();
Var k : Integer;
Begin
     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     // désactivation du mode multi
     bMulti := False;
     bSolo := True;

     // initialisation du menu
     ClearInput();

     // chargements pour le fond
     nScheme := 0;
     nMap := 1;
     LoadScheme();
     LoadMap();

     // ajout du titre
     SetString( STRING_GAME_MENU(1), 'solo', 0.2, 0.2, 600 );

     // ajout de la liste des schemes
     For k := 0 To nSchemeCount - 1 Do Begin
         SetString( STRING_GAME_MENU(k+10), aSchemeList[k].Name, 0.2, 1.0, 600 );
     End;

     // Ajout de la couleur
     SetString( STRING_GAME_MENU(250), 'X', 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(251), 'N', 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(252), 'A', 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(253), 'M', 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(254), 'G', 0.2, 1.0, 600 );

     // initialisation du menu
     nGame := GAME_MENU;
     nMenu := 10;

     // remise à zéro des touches
     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     fKey := 0.0;

     // remise à zéro du scrolling
     fScroll := 0.0;

     // mise à jour de la machine d'état
     nState := STATE_SOLO;
End;


Procedure ProcessSolo();
Begin
     Case nGame Of
          GAME_MENU : ProcessMenuSolo();
          GAME_PHASE_LEVEL : InitMenuLevel();
          GAME_STATE_LEVEL : ProcessMenuLevel();
          GAME_INIT : InitGame();
          GAME_ROUND : ProcessGame();
          GAME_WAIT : ProcessWait();
          GAME_SCORE : ProcessScore();
     End;
End;


Procedure ProcessMenuSolo();
          Function IsActive( nConst : Integer ) : Single ;
          Begin
               If nConst = nMenu Then IsActive := 0.0 Else IsActive := 1.0;
          End;
Var w, h : Integer;
    k : Integer;
    t : Single;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // définition de la camera
     SetCamera();

     // rendu du plateau
     DrawPlane( 0.9 );
     DrawBomberman( 0.9, false );
     DrawGrid( 0.9 );
     DrawSkybox( 0.9, 0.9, 0.9, 0.9, TEXTURE_MAP_SKYBOX(0) );

     // affichage du menu
     DrawString( STRING_GAME_MENU(1), -w / h * 0.35,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     t := 0.0;
     For k := 0 To nSchemeCount - 1 Do Begin
         If fScroll <= t Then DrawString( STRING_GAME_MENU(k+10), -w / h * 0.6, 0.7 + fScroll - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(k+10), IsActive(k+10), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
         Case aSchemeList[k].Solo Of
              0:If fScroll <= t Then DrawString( STRING_GAME_MENU(250), -w / h * 0.95, 0.7 + fScroll - t, -1, 0.012 * w / h, 0.024, 1, 1, 1, 1.0, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_NONE );
              1:If fScroll <= t Then DrawString( STRING_GAME_MENU(251), -w / h * 0.90, 0.7 + fScroll - t, -1, 0.012 * w / h, 0.024, 0, 0, 1, 1.0, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_NONE );
              2:If fScroll <= t Then DrawString( STRING_GAME_MENU(252), -w / h * 0.85, 0.7 + fScroll - t, -1, 0.012 * w / h, 0.024, 0.63, 0.33, 0.93, 1.0, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_NONE );
              3:If fScroll <= t Then DrawString( STRING_GAME_MENU(253), -w / h * 0.80, 0.7 + fScroll - t, -1, 0.012 * w / h, 0.024, 0.2, 0.2, 0.2, 1.0, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_NONE );
              4:If fScroll <= t Then DrawString( STRING_GAME_MENU(254), -w / h * 0.75, 0.7 + fScroll - t, -1, 0.012 * w / h, 0.024, 1, 1, 0, 1.0, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_NONE );
        End;
        t += 0.12;
     End;

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;

     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           nMenu := ( ( nMenu - 11 + nSchemeCount ) mod nSchemeCount ) + 10;

           t := 0.0;
           If (nMenu = 10) And (fScroll > t) Then fScroll := t;
           For k := 10 To nSchemeCount - 6 Do Begin
               If (nMenu = k) And (fScroll > t) Then fScroll := t;
               t += 0.12;
           End;
           If (nMenu = nSchemeCount + 9) Then fScroll := t;
        End;
        nScheme := nMenu - 10;
        LoadScheme();
        ClearInput();
        bUp := True;
     End Else Begin
        bUp := False;
     End;

     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           nMenu := ( ( nMenu - 9 + nSchemeCount ) mod nSchemeCount ) + 10;

           t := 0.0;
           If nMenu = 10 Then fScroll := t;
           For k := 24 To nSchemeCount + 9 Do Begin
               If (nMenu = k) And (fScroll < t) Then fScroll := t;
               t += 0.12;
           End;
        End;
        nScheme := nMenu - 10;
        LoadScheme();
        ClearInput();
        bDown := True;
     End Else Begin
        bDown := False;
     End;

     If GetKey( KEY_ENTER ) Then Begin
        If Not bEnter Then Begin
           PlaySound( SOUND_MENU_CLICK );
           // initialisation des parametres de jeu
           nMap := 1;
           nRoundCount := 1;
           nScheme := nMenu - 10;

           // initialisation des joueurs
           nPlayerType[1] := PLAYER_KB1;
           nPlayerType[2] := PLAYER_COM;
           sPlayerName[2] := 'computer';
           For k := 3 To 8 Do Begin
               nPlayerType[k] := PLAYER_NIL;
           End;
           nGame := GAME_PHASE_LEVEL;
       End;
       bEnter := True;
     End Else Begin
        bEnter := False;
     End;
End;


Procedure InitMenuLevel();
Begin
      // Ajout du nom et du level
     SetString( STRING_GAME_MENU(240), 'name:', 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(241), sPlayerName[1], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(242), 'level:', 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(243), PlayerLevel(2), 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(244), 'fight', 0.2, 1.0, 600 );

     // initialisation du menu
     nMenu := MENU_TITLE_NAME;

     // remise à zéro des touches
     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     fKey := 0.0;

     // remise à zéro du scrolling
     fScroll := 0.0;

     nGame := GAME_STATE_LEVEL;
End;

Procedure ProcessMenuLevel();
          Function IsActive( nConst : Integer ) : Single ;
          Begin
               If nConst = nMenu Then IsActive := 0.0 Else IsActive := 1.0;
          End;
Var w, h : Integer;
    t : Single;
    bCursor : Boolean;
    fCTime : Single;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // définition de la camera
     SetCamera();

     // rendu du plateau
     DrawPlane( 0.9 );
     DrawBomberman( 0.9, false );
     DrawGrid( 0.9 );
     DrawSkybox( 0.9, 0.9, 0.9, 0.9, TEXTURE_MAP_SKYBOX(0) );

     DrawString( STRING_GAME_MENU(1), -w / h * 0.35,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     t := 0.2;
     DrawString( STRING_GAME_MENU(MENU_TITLE_NAME), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_TITLE_NAME), IsActive(MENU_TITLE_NAME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     DrawString( STRING_GAME_MENU(MENU_SELECT_NAME), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_SELECT_NAME), IsActive(MENU_SELECT_NAME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_NONE ); t += 0.2;
     DrawString( STRING_GAME_MENU(MENU_TITLE_LEVEL), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_TITLE_LEVEL), IsActive(MENU_TITLE_LEVEL), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     DrawString( STRING_GAME_MENU(MENU_SELECT_LEVEL), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_SELECT_LEVEL), IsActive(MENU_SELECT_LEVEL), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_NONE ); t += 0.2;
     t += 0.2;
     DrawString( STRING_GAME_MENU(MENU_FIGHT), w / h * 0.5, 0.7 + fScroll - t, -1, 0.036 * w / h, 0.048, 1.0, IsActive(MENU_FIGHT), IsActive(MENU_FIGHT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        InitSolo();
        ClearInput();
     End;

     If GetKeyS( KEY_LEFT ) Then Begin
        If Not bLeft Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If ( nMenu = MENU_SELECT_LEVEL ) Then Begin
              Case nPlayerSkill[2] Of
                   SKILL_NOVICE    : nPlayerSkill[2] := SKILL_GODLIKE;
                   SKILL_AVERAGE   : nPlayerSkill[2] := SKILL_NOVICE;
                   SKILL_MASTERFUL : nPlayerSkill[2] := SKILL_AVERAGE;
                   SKILL_GODLIKE   : nPlayerSkill[2] := SKILL_MASTERFUL;
              End;
              SetString( STRING_GAME_MENU(MENU_SELECT_LEVEL), PlayerLevel(2), 0.2, 1.0, 600 );
           End;
        End;
        ClearInput();
        bLeft := True;
     End Else Begin
        bLeft := False;
     End;

     If GetKeyS( KEY_RIGHT ) Then Begin
        If Not bRight Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If ( nMenu = MENU_SELECT_LEVEL ) Then Begin
              Case nPlayerSkill[2] Of
                   SKILL_NOVICE    : nPlayerSkill[2] := SKILL_AVERAGE;
                   SKILL_AVERAGE   : nPlayerSkill[2] := SKILL_MASTERFUL;
                   SKILL_MASTERFUL : nPlayerSkill[2] := SKILL_GODLIKE;
                   SKILL_GODLIKE   : nPlayerSkill[2] := SKILL_NOVICE;
              End;
              SetString( STRING_GAME_MENU(MENU_SELECT_LEVEL), PlayerLevel(2), 0.2, 1.0, 600 );
           End;
        End;
        ClearInput();
        bRight := True;
     End Else Begin
        bRight := False;
     End;

     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_TITLE_NAME   : nMenu := MENU_SELECT_NAME;
                MENU_SELECT_NAME  : nMenu := MENU_TITLE_LEVEL;
                MENU_TITLE_LEVEL  : nMenu := MENU_SELECT_LEVEL;
                MENU_SELECT_LEVEL : nMenu := MENU_FIGHT;
                MENU_FIGHT        : nMenu := MENU_TITLE_NAME;
           End;
        End;
        ClearInput();
        bDown := True;
     End Else Begin
        bDown := False;
     End;

     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_TITLE_NAME   : nMenu := MENU_FIGHT;
                MENU_SELECT_NAME  : nMenu := MENU_TITLE_NAME;
                MENU_TITLE_LEVEL  : nMenu := MENU_SELECT_NAME;
                MENU_SELECT_LEVEL : nMenu := MENU_TITLE_LEVEL;
                MENU_FIGHT        : nMenu := MENU_SELECT_LEVEL;
           End;
        End;
        ClearInput();
        bUp := True;
     End Else Begin
        bUp := False;
     End;

     If GetKey( KEY_ENTER ) Then Begin
       If (nMenu = MENU_FIGHT) Then Begin
          nGame := GAME_INIT;
       End;
       bEnter := True;
     End Else Begin
        bEnter := False;
     End;

     If Ord(CheckKey()) > 0 Then Begin
        If GetTime > fKey Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_SELECT_NAME :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        SetLength(sPlayerName[1], Length(sPlayerName[1]) - 1);
                     End Else Begin
                        sPlayerName[1] := sPlayerName[1] + CheckKey();
                     End;
                     SetString( STRING_GAME_MENU(MENU_SELECT_NAME), sPlayerName[1], 0.0, 0.02, 600 );
                End;
           End;
           fKey := GetTime + 0.1;
           ClearInput();
        End;
     End Else Begin
        fKey := 0.0;
     End;

     fCTime := GetTime();
     If ( Trunc(fCTime*2) - Trunc(fCursorTime*2) = 1 ) Then
        bCursor := True
     Else
         bCursor := False;
     fCursorTime := fCTime;
     Case nMenu Of
                MENU_SELECT_NAME  :
                Begin
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 0 ) Then
                        SetString( STRING_GAME_MENU(MENU_SELECT_NAME), sPlayerName[1], 0.0, 0.02, 600 );
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 1 ) Then
                        SetString( STRING_GAME_MENU(MENU_SELECT_NAME), sPlayerName[1] + '*', 0.0, 0.02, 600 );
                     bCursor := False;
                End;
           End;
End;


End.

