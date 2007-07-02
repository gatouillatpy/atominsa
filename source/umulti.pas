Unit UMulti;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UGame, UUtils, USetup;



Procedure InitMulti () ;
Procedure ProcessMulti () ;



Implementation



Const MULTI_NONE       = 0;
Const MULTI_BUSY       = 1;
Const MULTI_SERVER     = 2;
Const MULTI_CLIENT     = 3;
Const MULTI_ERROR      = 4;

Var nMulti : Integer;



Const GAME_MENU_MULTI = 12;



Const MENU_MULTI_NAME         = 81;
Const MENU_MULTI_ADDRESS      = 82;

Const MENU_MULTI_JOIN         = 91;
Const MENU_MULTI_HOST         = 92;





























////////////////////////////////////////////////////////////////////////////////
// MENU MULTI                                                                 //
////////////////////////////////////////////////////////////////////////////////



Procedure InitMenuMulti () ;
Var k : Integer;
Begin
     // ajout du titre
     SetString( STRING_GAME_MENU(3), 'multi', 0.2, 0.2, 600 );

     // ajout du menu
     SetString( STRING_GAME_MENU(81), 'name : ' + sLocalName, 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(82), 'address : ' + sServerAddress, 0.2, 1.0, 600 );

     // ajout des boutons join et host
     SetString( STRING_GAME_MENU(91), 'join', 0.2, 0.5, 600 );
     SetString( STRING_GAME_MENU(92), 'host', 0.2, 0.5, 600 );

     // ajout des textes d'état
     SetString( STRING_GAME_MENU(101), 'connecting...', 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(102), 'connection timeout.', 0.2, 1.0, 600 );

     // modification de la machine d'état interne
     nGame := GAME_MENU_MULTI;

     // initialisation du menu
     nMenu := MENU_MULTI_JOIN;

     // initialisation de l'état du réseau
     nMulti := MULTI_NONE;
     
     // remise à zéro des touches
     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     fKey := 0.0;
End;



Procedure ProcessMenuMulti () ;
          Function IsActive( nConst : Integer ) : Single ;
          Begin
               If nConst = nMenu Then IsActive := 0.0 Else IsActive := 1.0;
          End;
Var w, h : Single;
    t : Single;
    k : Integer;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     // affichage du menu
     DrawString( STRING_GAME_MENU(3), -w / h * 0.4,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.3;
     DrawString( STRING_GAME_MENU(81), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_MULTI_NAME), IsActive(MENU_MULTI_NAME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(82), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_MULTI_ADDRESS), IsActive(MENU_MULTI_ADDRESS), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(91), -w / h * 0.6, -0.2, -1, 0.024 * w / h, 0.036, 1.0, IsActive(MENU_MULTI_JOIN), IsActive(MENU_MULTI_JOIN), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( STRING_GAME_MENU(92), -w / h * 0.2, -0.2, -1, 0.024 * w / h, 0.036, 1.0, IsActive(MENU_MULTI_HOST), IsActive(MENU_MULTI_HOST), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     If nMulti = MULTI_BUSY Then
        DrawString( STRING_GAME_MENU(101), -w / h * 0.8, -0.6, -1, 0.018 * w / h, 0.024, 0.0, 0.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     If nMulti = MULTI_ERROR Then
        DrawString( STRING_GAME_MENU(102), -w / h * 0.8, -0.6, -1, 0.018 * w / h, 0.024, 0.0, 0.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;

     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_MULTI_ADDRESS Then nMenu := MENU_MULTI_NAME Else
           If nMenu = MENU_MULTI_JOIN Then nMenu := MENU_MULTI_ADDRESS Else
           If nMenu = MENU_MULTI_HOST Then nMenu := MENU_MULTI_JOIN Else
           If nMenu = MENU_MULTI_NAME Then nMenu := MENU_MULTI_HOST;
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;

     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_MULTI_HOST Then nMenu := MENU_MULTI_NAME Else
           If nMenu = MENU_MULTI_NAME Then nMenu := MENU_MULTI_ADDRESS Else
           If nMenu = MENU_MULTI_ADDRESS Then nMenu := MENU_MULTI_JOIN Else
           If nMenu = MENU_MULTI_JOIN Then nMenu := MENU_MULTI_HOST;
        End;
        bDown := True;
     End Else Begin
        bDown := False;
     End;

     If GetKey( KEY_ENTER ) Then Begin
        If Not bEnter Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_MULTI_JOIN :
                Begin
                     If ClientInit( sServerAddress, nServerPort ) Then Begin
                        nMulti := MULTI_CLIENT;
                        InitMenu();
                     End;
                End;
                MENU_MULTI_HOST :
                Begin
                     If ServerInit( nServerPort ) Then Begin
                        nMulti := MULTI_SERVER;
                        InitMenu();
                     End;
                End;
           End;
        End;
        bEnter := True;
     End Else Begin
        bEnter := False;
     End;

     If Ord(CheckKey()) > 0 Then Begin
        If GetTime > fKey Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_MULTI_NAME :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        SetLength(sLocalName, Length(sLocalName) - 1);
                     End Else Begin
                        sLocalName := sLocalName + CheckKey();
                     End;
                     SetString( STRING_GAME_MENU(81), 'name : ' + sLocalName, 0.0, 0.02, 600 );
                End;
                MENU_MULTI_ADDRESS :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        SetLength(sServerAddress, Length(sServerAddress) - 1);
                     End Else Begin
                        sServerAddress := sServerAddress + CheckKey();
                     End;
                     SetString( STRING_GAME_MENU(82), 'address : ' + sServerAddress, 0.0, 0.02, 600 );
                End;
           End;
           fKey := GetTime + 0.1;
        End;
     End Else Begin
        fKey := 0.0;
     End;

End;





























////////////////////////////////////////////////////////////////////////////////
// PHASE MULTI                                                                //
////////////////////////////////////////////////////////////////////////////////



Procedure InitMulti () ;
Var k : Integer;
Begin
     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     // activation du mode multi
     bMulti := True;

     // suppression de tous les joueurs externes
     For k := 1 To 8 Do
         If nPlayerType[k] = PLAYER_NET Then nPlayerType[k] := PLAYER_NIL;

     // initialisation du menu
     InitMenuMulti();

     // mise à jour de la machine d'état
     nState := STATE_MULTI;
End;



Procedure ProcessMulti () ;
Begin
     Case nGame Of
          GAME_MENU : ProcessMenu();
          GAME_MENU_PLAYER : ProcessMenuPlayer();
          GAME_MENU_MULTI : ProcessMenuMulti();
          GAME_INIT : InitGame();
          GAME_ROUND : ProcessGame();
          GAME_WAIT : ProcessWait();
          GAME_SCORE : ProcessScore();
     End;

     If nMulti = MULTI_SERVER Then Begin
        If nState = PHASE_MENU Then ServerTerminate() Else ServerLoop();
     End Else If nMulti = MULTI_CLIENT Then Begin
        If nState = PHASE_MENU Then ClientTerminate() Else ClientLoop();
     End;
End;





























End.

