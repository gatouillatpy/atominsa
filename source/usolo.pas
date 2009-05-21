Unit USolo;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, USetup, UCore, UGame, UUtils;

Procedure InitSolo();
Procedure ProcessSolo();
Procedure ProcessMenuSolo();
Procedure InitMenuName();
Procedure ProcessMenuName();





Implementation

Uses UBomberman;

Const MENU_NAME         = 240;
      MENU_PLAYER2      = 242;
      MENU_PLAYER3      = 243;
      MENU_PLAYER4      = 244;
      MENU_PLAYER5      = 245;
      MENU_PLAYER6      = 246;
      MENU_PLAYER7      = 247;
      MENU_PLAYER8      = 248;
      MENU_FIGHT        = 249;
      MENU_DONE         = 250;

Var nMenu : Integer;
    nNbPlayers : Integer;
Var bUp : Boolean;
    bDown : Boolean;
    bLeft : Boolean;
    bRight : Boolean;
    bEnter : Boolean;
Var fScroll : Single;

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
     SetString( STRING_GAME_MENU(MENU_DONE), 'done', 0.2, 1.0, 600 );

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
          GAME_PHASE_NAME : InitMenuName();
          GAME_STATE_NAME : ProcessMenuName();
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
    nLevel : Integer;
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
         If ( aSchemeList[k].Solo = 1 ) And ( fScroll <= t ) Then
            DrawString( STRING_GAME_MENU(MENU_DONE), -w / h * 0.90, 0.7 + fScroll - t, -1, 0.012 * w / h, 0.024, 1, 1, 0, 1.0, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_NONE );
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
           If ( nScheme <= 62 ) Then Begin
              nNbPlayers := 1 + ( nScheme mod 7 );
              nLevel := 1 + nScheme div 7;
           End
           Else Begin
                nNbPlayers := 7;
                nLevel := 9;
           End;

           // initialisation des joueurs
           nPlayerType[1] := PLAYER_KB1;
           For k := 2 To nNbPlayers + 1 Do Begin
               nPlayerType[k] := PLAYER_COM;
               Case nLevel Of
                    1:Begin
                           sPlayerName[k] := 'novice ' + IntToStr( k );
                           nPlayerSkill[k] := SKILL_NOVICE;
                    End;
                    2:Begin
                           If ( k mod 2 = 0 ) Then Begin
                              sPlayerName[k] := 'average ' + IntToStr( k );
                              nPlayerSkill[k] := SKILL_AVERAGE;
                           End
                           Else Begin
                               sPlayerName[k] := 'novice ' + IntToStr( k );
                               nPlayerSkill[k] := SKILL_NOVICE;
                           End;
                    End;
                    3:Begin
                           sPlayerName[k] := 'average ' + IntToStr( k );
                           nPlayerSkill[k] := SKILL_AVERAGE;
                    End;
                    4:Begin
                           If ( k mod 3 = 0 ) Then Begin
                              sPlayerName[k] := 'masterful ' + IntToStr( k );
                              nPlayerSkill[k] := SKILL_MASTERFUL;
                           End
                           Else If ( k mod 3 = 1 ) Then Begin
                               sPlayerName[k] := 'average ' + IntToStr( k );
                               nPlayerSkill[k] := SKILL_AVERAGE;
                           End
                           Else Begin
                               sPlayerName[k] := 'novice ' + IntToStr( k );
                               nPlayerSkill[k] := SKILL_NOVICE;
                           End;
                    End;
                    5:Begin
                           If ( k mod 2 = 0 ) Then Begin
                              sPlayerName[k] := 'masterful ' + IntToStr( k );
                              nPlayerSkill[k] := SKILL_MASTERFUL;
                           End
                           Else Begin
                               sPlayerName[k] := 'average ' + IntToStr( k );
                               nPlayerSkill[k] := SKILL_AVERAGE;
                           End;
                    End;
                    6:Begin
                           sPlayerName[k] := 'masterful ' + IntToStr( k );
                           nPlayerSkill[k] := SKILL_MASTERFUL;
                    End;
                    7:Begin
                           If ( k mod 3 = 0 ) Then Begin
                              sPlayerName[k] := 'godlike ' + IntToStr( k );
                              nPlayerSkill[k] := SKILL_GODLIKE;
                           End
                           Else If ( k mod 3 = 1 ) Then Begin
                               sPlayerName[k] := 'masterful ' + IntToStr( k );
                               nPlayerSkill[k] := SKILL_MASTERFUL;
                           End
                           Else Begin
                               sPlayerName[k] := 'average ' + IntToStr( k );
                               nPlayerSkill[k] := SKILL_AVERAGE;
                           End;
                    End;
                    8:Begin
                           If ( k mod 2 = 0 ) Then Begin
                              sPlayerName[k] := 'godlike ' + IntToStr( k );
                              nPlayerSkill[k] := SKILL_GODLIKE;
                           End
                           Else Begin
                               sPlayerName[k] := 'masterful ' + IntToStr( k );
                               nPlayerSkill[k] := SKILL_MASTERFUL;
                           End;
                    End;
                    9:Begin
                           sPlayerName[k] := 'godlike ' + IntToStr( k );
                           nPlayerSkill[k] := SKILL_GODLIKE;
                    End;
               End;
           End;
           For k := nNbPlayers + 2 To 8 Do Begin
               nPlayerType[k] := PLAYER_NIL;
           End;
           nGame := GAME_PHASE_NAME;
       End;
       bEnter := True;
     End Else Begin
        bEnter := False;
     End;
End;


Procedure InitMenuName();
Begin
      // Ajout du nom et du level
     SetString( STRING_GAME_MENU(MENU_NAME), 'name: ' + sPlayerName[1], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(MENU_PLAYER2), 'player2: ' + sPlayerName[2], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(MENU_PLAYER3), 'player3: ' + sPlayerName[3], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(MENU_PLAYER4), 'player4: ' + sPlayerName[4], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(MENU_PLAYER5), 'player5: ' + sPlayerName[5], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(MENU_PLAYER6), 'player6: ' + sPlayerName[6], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(MENU_PLAYER7), 'player7: ' + sPlayerName[7], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(MENU_PLAYER8), 'player8: ' + sPlayerName[8], 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(MENU_FIGHT), 'fight', 0.2, 1.0, 600 );

     // initialisation du menu
     nMenu := MENU_NAME;

     // remise à zéro des touches
     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     fKey := 0.0;

     // remise à zéro du scrolling
     fScroll := 0.0;

     nGame := GAME_STATE_NAME;
End;

Procedure ProcessMenuName();
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

     t := 0.0;
     DrawString( STRING_GAME_MENU(MENU_NAME), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(MENU_NAME), IsActive(MENU_NAME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     DrawString( STRING_GAME_MENU(MENU_PLAYER2), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER2), IsActive(MENU_PLAYER2), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     If nNbPlayers >= 2 Then DrawString( STRING_GAME_MENU(MENU_PLAYER3), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER3), IsActive(MENU_PLAYER3), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     If nNbPlayers >= 3 Then DrawString( STRING_GAME_MENU(MENU_PLAYER4), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER4), IsActive(MENU_PLAYER4), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     If nNbPlayers >= 4 Then DrawString( STRING_GAME_MENU(MENU_PLAYER5), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER5), IsActive(MENU_PLAYER5), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     If nNbPlayers >= 5 Then DrawString( STRING_GAME_MENU(MENU_PLAYER6), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER6), IsActive(MENU_PLAYER6), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     If nNbPlayers >= 6 Then DrawString( STRING_GAME_MENU(MENU_PLAYER7), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER7), IsActive(MENU_PLAYER7), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     If nNbPlayers >= 7 Then DrawString( STRING_GAME_MENU(MENU_PLAYER8), -w / h * 0.8, 0.7 + fScroll - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER8), IsActive(MENU_PLAYER8), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     DrawString( STRING_GAME_MENU(MENU_FIGHT), w / h * 0.5, 0.7 + fScroll - t, -1, 0.036 * w / h, 0.048, 1.0, IsActive(MENU_FIGHT), IsActive(MENU_FIGHT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        InitSolo();
        ClearInput();
     End;

     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_NAME         : nMenu := MENU_FIGHT;
                MENU_FIGHT        : nMenu := MENU_NAME;
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
                MENU_NAME         : nMenu := MENU_FIGHT;
                MENU_FIGHT        : nMenu := MENU_NAME;
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
                MENU_NAME :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        SetLength(sPlayerName[1], Length(sPlayerName[1]) - 1);
                     End Else Begin
                        sPlayerName[1] := sPlayerName[1] + CheckKey();
                     End;
                     SetString( STRING_GAME_MENU(MENU_NAME), 'name: ' + sPlayerName[1], 0.0, 0.02, 600 );
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
                MENU_NAME  :
                Begin
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 0 ) Then
                        SetString( STRING_GAME_MENU(MENU_NAME), 'name: ' + sPlayerName[1], 0.0, 0.02, 600 );
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 1 ) Then
                        SetString( STRING_GAME_MENU(MENU_NAME), 'name: ' + sPlayerName[1] + '*', 0.0, 0.02, 600 );
                     bCursor := False;
                End;
           End;
End;


End.

