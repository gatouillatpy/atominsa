Unit UMulti;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils, UJellyBomb, UPunch, USpoog, UGoldFLame, UTrigger, UTriggerBomb, USuperDisease,
     UCore, UGame, UUtils, USetup, UForm, UExtraBomb, UFlameUp, UKick, UGrab, UJelly, UDisease, USpeedUp;



Const MULTI_NONE       = 0;
Const MULTI_SERVER     = 1;
Const MULTI_CLIENT     = 2;
Const MULTI_ERROR      = 3;

Var bLocalReady : Boolean;
Var nClientCount : Integer;
Var nClientIndex : Array [0..255] Of Integer;
Var sClientName : Array [0..255] Of String;
Var sClientUserName : Array [0..255] Of String;
Var sClientUserPassword : Array [0..255] Of String;
Var bClientReady : Array [0..255] Of Boolean;
Var bClientBtnReady : Array [0..255] Of Boolean;
Var fPingTime, fPing, fCheckTime : Single;



Var nMulti : Integer;



Procedure InitMulti () ;
Procedure ProcessMulti () ;

Function ClientIndex( nIndex : DWord ) : Integer ;
Function GetString ( sData : String ; nString : Integer ) : String ;



Implementation

Uses UBomberman, UListBomb, UBomb, UBlock, UItem, UGrid;





Const MENU_MULTI_NAME         = 81;
Const MENU_MULTI_ADDRESS      = 82;
Const MENU_MULTI_PORT         = 83;

Const MENU_MULTI_JOIN         = 91;
Const MENU_MULTI_HOST         = 92;

















// Fonction puissance
Function IntPower( n, p : Integer ) : Integer;
Var i : Integer;
Begin
     IntPower := 1;
     For i := 1 To p Do Begin
         IntPower *= n;
     End;
End;










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
     SetString( STRING_GAME_MENU(83), 'port : ' + IntToStr(nServerPort), 0.2, 1.0, 600 );
     
     // ajout des boutons join et host
     SetString( STRING_GAME_MENU(91), 'join', 0.2, 0.5, 600 );
     SetString( STRING_GAME_MENU(92), 'host', 0.2, 0.5, 600 );

     // ajout des textes d'état
     SetString( STRING_GAME_MENU(101), 'connection error.', 0.2, 1.0, 600 );

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
    sData : String;
    bCursor : Boolean;
    fCTime : Single;
Begin
     // appel d'une texture de rendu
     PutRenderTexture();

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
     SetTexture( 1, SPRITE_BACK );
     DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 1, False );

     // affichage final du rendu en transparence
     SetRenderTexture();
     DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 1, True );

     // affichage du menu
     DrawString( STRING_GAME_MENU(3), -w / h * 0.2,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.3;
     DrawString( STRING_GAME_MENU(81), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_MULTI_NAME), IsActive(MENU_MULTI_NAME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(82), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_MULTI_ADDRESS), IsActive(MENU_MULTI_ADDRESS), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(83), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_MULTI_PORT), IsActive(MENU_MULTI_PORT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(91), -w / h * 0.6, -0.7, -1, 0.024 * w / h, 0.036, 1.0, IsActive(MENU_MULTI_JOIN), IsActive(MENU_MULTI_JOIN), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     DrawString( STRING_GAME_MENU(92), -w / h * 0.2, -0.7, -1, 0.024 * w / h, 0.036, 1.0, IsActive(MENU_MULTI_HOST), IsActive(MENU_MULTI_HOST), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     If nMulti = MULTI_ERROR Then
        DrawString( STRING_GAME_MENU(101), -w / h * 0.8, -0.9, -1, 0.018 * w / h, 0.024, 0.0, 0.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;

     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_MULTI_ADDRESS Then Begin
              nMenu := MENU_MULTI_NAME;
              SetString( STRING_GAME_MENU(82), 'address : ' + sServerAddress, 0.0, 0.02, 600 );
           End Else
           If nMenu = MENU_MULTI_PORT Then Begin
              nMenu := MENU_MULTI_ADDRESS;
              SetString( STRING_GAME_MENU(83), 'port : ' + IntToStr(nServerPort), 0.0, 0.02, 600 );
           End Else
           If nMenu = MENU_MULTI_JOIN Then nMenu := MENU_MULTI_PORT Else
           If nMenu = MENU_MULTI_HOST Then nMenu := MENU_MULTI_JOIN Else
           If nMenu = MENU_MULTI_NAME Then Begin
              nMenu := MENU_MULTI_HOST;
              SetString( STRING_GAME_MENU(81), 'name : ' + sLocalName, 0.0, 0.02, 600 );
           End;
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;

     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_MULTI_HOST Then nMenu := MENU_MULTI_NAME Else
           If nMenu = MENU_MULTI_NAME Then Begin
              nMenu := MENU_MULTI_ADDRESS;
              SetString( STRING_GAME_MENU(81), 'name : ' + sLocalName, 0.0, 0.02, 600 );
           End Else
           If nMenu = MENU_MULTI_ADDRESS Then Begin
              nMenu := MENU_MULTI_PORT;
              SetString( STRING_GAME_MENU(82), 'address : ' + sServerAddress, 0.0, 0.02, 600 );
           End Else
           If nMenu = MENU_MULTI_PORT Then Begin
              nMenu := MENU_MULTI_JOIN;
              SetString( STRING_GAME_MENU(83), 'port : ' + IntToStr(nServerPort), 0.0, 0.02, 600 );
           End Else
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
                        bSendDisconnect := False;
                        nMulti := MULTI_CLIENT;
                        For k := 1 To 8 Do Begin
                            nPlayerType[k] := PLAYER_NIL;
                            nPlayerClient[k] := -2;      // Pour empêcher le choix de personnage avant d'avoir reçu la liste.
                        End;
                        InitMenu();
                        sData := IntToStr( nNetworkVersion ) + #31;
                        sData := sData + sLocalName + #31;
                        sData := sData + sUserName + #31;
                        sData := sData + sUserPassword + #31;
                        Send( nLocalIndex, HEADER_CONNECT, sData );
                     End Else Begin
                        nMulti := MULTI_ERROR;
                     End;
                End;
                MENU_MULTI_HOST :
                Begin
                     If ServerInit( nServerPort ) Then Begin
                        nMulti := MULTI_SERVER;
                        nClientCount := 1;
                        nClientIndex[0] := nLocalIndex;
                        sClientName[0] := sLocalName;
                        For k := 1 To 8 Do Begin
                            nPlayerType[k] := PLAYER_NIL;
                            nPlayerClient[k] := -1;
                        End;
                        For k := 0 To 255 Do Begin
                            bClientBtnReady[k] := False;
                        End;
                        bLocalReady := False;
                        InitMenu();
                     End;
                End;
           End;
        End;
        bEnter := True;
     End Else Begin
        bEnter := False;
     End;

     If GetKeyS( KEY_LEFT ) Then Begin
        If Not bLeft Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_MULTI_JOIN :
                Begin
                     nMenu := MENU_MULTI_HOST;
                End;
                MENU_MULTI_HOST :
                Begin
                     nMenu := MENU_MULTI_JOIN;
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
                MENU_MULTI_JOIN :
                Begin
                     nMenu := MENU_MULTI_HOST;
                End;
                MENU_MULTI_HOST :
                Begin
                     nMenu := MENU_MULTI_JOIN;
                End;
           End;
        End;
        bRight := True;
     End Else Begin
        bRight := False;
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
                MENU_MULTI_PORT :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        nServerPort := nServerPort div 10;
                     End Else If ( Ord(CheckKey()) >= 48 ) And ( Ord(CheckKey()) <= 57 ) And ( nServerPort <= 999 ) Then Begin
                        nServerPort := nServerPort * 10 + StrToInt( CheckKey() );
                     End;
                     SetString( STRING_GAME_MENU(83), 'port : ' + IntToStr(nServerPort), 0.0, 0.02, 600 );
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
                MENU_MULTI_NAME :
                Begin
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 0 ) Then
                        SetString( STRING_GAME_MENU(81), 'name : ' + sLocalName, 0.0, 0.02, 600 );
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 1 ) Then
                        SetString( STRING_GAME_MENU(81), 'name : ' + sLocalName + '*', 0.0, 0.02, 600 );
                     bCursor := False;
                End;
                MENU_MULTI_ADDRESS :
                Begin
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 0 ) Then
                        SetString( STRING_GAME_MENU(82), 'address : ' + sServerAddress, 0.0, 0.02, 600 );
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 1 ) Then
                        SetString( STRING_GAME_MENU(82), 'address : ' + sServerAddress + '*', 0.0, 0.02, 600 );
                     bCursor := False;
                End;
                MENU_MULTI_PORT :
                Begin
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 0 ) Then
                        SetString( STRING_GAME_MENU(83), 'port : ' + IntToStr(nServerPort), 0.0, 0.02, 600 );
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 1 ) Then
                        SetString( STRING_GAME_MENU(83), 'port : ' + IntToStr(nServerPort) + '*', 0.0, 0.02, 600 );
                     bCursor := False;
                End;
           End;
End;





























////////////////////////////////////////////////////////////////////////////////
// RESEAU                                                                     //
////////////////////////////////////////////////////////////////////////////////



Function GetString ( sData : String ; nString : Integer ) : String ;
Var i, j, k : Integer;
    nCount : Integer;
    sResult : String;
Begin
     nCount := 0;
     sResult := 'NULL';

     j := 1;
     For i := 1 To Length(sData) Do Begin
        If sData[i] = #31 Then Begin
           nCount += 1;
           If nCount = nString Then sResult := Copy( sData, j, i - j );
           j := i + 1;
        End Else If i = Length(sData) Then Begin
           nCount += 1;
           If nCount = nString Then sResult := Copy( sData, j, i - j + 1 );
           j := i + 1;
        End;
        If sResult <> 'NULL' Then Break;
     End;

     For k := 1 To Length(sResult) Do Begin
        If sResult[k] = ',' Then sResult[k] := '.';
     End;
     
     GetString := sResult;
End;



Function PlayerIndex( nIndex : DWord ) : Integer ;
Var k : Integer;
Begin
     PlayerIndex := -1;
     For k := 1 To 8 Do
         If nPlayerClient[k] = nIndex Then PlayerIndex := k;
End;

Function ClientIndex( nIndex : DWord ) : Integer ;
Var k : Integer;
Begin
     ClientIndex := -1;
     For k := 0 To nClientCount - 1 Do
         If nClientIndex[k] = nIndex Then ClientIndex := k;
End;



Procedure ProcessServer () ;
Var nIndex : DWord;
    nHeader : Integer;
    sData : String;
    pBomberman, pSecondBomberman : CBomberman;
    pBomb : CBomb;
    fX, fY : Single;
    dt : Single;
    nBombSize, nDirection : Integer;
    fBombTime : Single;
    _nNetID, nSum, nNbr : Integer;
    aX, aY, dX, dY : Integer;
    bNoPlayers : Boolean;
Var k, l : Integer;
Begin
     While GetPacket( nIndex, nHeader, sData ) Do Begin
          Case nHeader Of
               HEADER_CONNECT :
               Begin
                    TryStrToInt( GetString( sData, 1 ), nNbr );
                    If ( nNbr = nNetworkVersion ) Then Begin
                        // ajout du client à la liste
                        If ClientIndex(nIndex) = -1 Then Begin
                           nClientIndex[nClientCount] := nIndex;
                           sClientName[nClientCount] := GetString( sData, 2 );
                           sClientUserName[nClientCount] := GetString( sData, 3 );
                           sClientUserPassword[nClientCount] := GetString( sData, 4 );
                           AddLineToConsole( sClientName[nClientCount] + ' entered the game.' );
                           nClientCount += 1;
                        End;
                        // renvoi de la liste des clients
                        nIndex := nLocalIndex;
                        nHeader := HEADER_LIST_CLIENT;
                        sData := IntToStr(nClientCount);
                        For k := 0 To nClientCount - 1 Do Begin
                            sData += #31 + IntToStr(nClientIndex[k]);
                            sData += #31 + sClientName[k];
                            If ( bClientBtnReady[k] ) Then Begin
                               sData += #31 + IntToStr(1);
                            End Else Begin
                               sData += #31 + IntToStr(0);
                            End;
                        End;
                        Send( nIndex, nHeader, sData );
                        // renvoi de la liste des joueurs
                        nIndex := nLocalIndex;
                        nHeader := HEADER_LIST_PLAYER;
                        sData := '';
                        For k := 1 To 8 Do Begin
                            sData := sData + IntToStr(nPlayerClient[k]) + #31;
                            sData := sData + sPlayerName[k] + #31;
                            sData := sData + pPlayerCharacter[k].Name + #31;
                            sData := sData + IntToStr(nPlayerType[k]) + #31;
                        End;
                        Send( nIndex, nHeader, sData );
                        // renvoi du scheme, de la map et du nombre de rounds.
                        sData := IntToStr(nScheme) + #31;
                        sData := sData + IntToStr(nSchemeMulti) + #31;
                        sData := sData + IntToStr(nMap) + #31;
                        sData := sData + IntToStr(nRoundCount) + #31;
                        Send( nIndex, HEADER_SETUP, sData );
                        UpdateMenu();
                    End
                    Else Begin
                         sData := 'Versions not compatible!' + #31;
                         Send( nLocalIndex, HEADER_SHOW, sData );
                    End;
               End;
            {   HEADER_DISCONNECT :
               Begin
                    // suppression du client de la liste
                    For k := ClientIndex(nIndex) To nClientCount - 2 Do
                        nClientIndex[k] := nClientIndex[k+1];
                    nClientCount -= 1;
                    AddLineToConsole( sData + ' leaved the game.' );
                    // supression des joueurs attribués s'il y en avait
                    For k := 1 To 8 Do Begin
                        If nPlayerClient[k] = nIndex Then Begin
                           nPlayerClient[k] := -1;
                           nPlayerType[k] := PLAYER_NIL;
                        End;
                    End;
                    // renvoi de la liste des clients
                    nHeader := HEADER_LIST_CLIENT;
                    sData := IntToStr(nClientCount);
                    For k := 0 To nClientCount - 1 Do
                        sData := sData + #31 + IntToStr(nClientIndex[k]) + #31 + sClientName[k];
                    Send( nLocalIndex, nHeader, sData );
                    // renvoi de la liste des joueurs
                    nHeader := HEADER_LIST_PLAYER;
                    sData := '';
                    For k := 1 To 8 Do Begin
                        sData := sData + IntToStr(nPlayerClient[k]) + #31;
                        sData := sData + sPlayerName[k] + #31;
                        sData := sData + pPlayerCharacter[k].Name + #31;
                        sData := sData + IntToStr(nPlayerType[k]) + #31;
                    End;
                    Send( nIndex, nHeader, sData );
                    If ( nGame = GAME_MENU ) Or ( nGame = GAME_MENU_PLAYER ) Or ( nGame = GAME_MENU_MULTI ) Then
                       UpdateMenu();
                    // Vérification qu'il y a encore des joueurs.
                    bNoPlayers := True;
                    For k := 1 To 8 Do Begin
                        If nPlayerType[k] <> PLAYER_NIL Then bNoPlayers := False;
                    End;
                    If bNoPlayers Then Begin
                        For k := 0 To 255 Do Begin
                            bClientBtnReady[k] := False;
                        End;
                        bLocalReady := False;
                        InitMenu();
                        If bOnline Then
                           SendOnline( nLocalIndex, HEADER_END_MATCH, '' );
                        Send( nLocalIndex, HEADER_END_GAME, '' );
                    End;
                    sData := '';
                    SendTo( nIndex, HEADER_QUIT_MENU, sData );
               End;      }
               HEADER_MESSAGE :
               Begin
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' says : ' + sData );
                    AddStringToScreen( sClientName[ClientIndex(nIndex)] + ' says : ' + sData );
                    Send( nIndex, nHeader, sData );
               End;
               HEADER_READY :
               Begin
                    bClientReady[ClientIndex(nIndex)] := True;
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' is ready.' );
                    Send( nIndex, nHeader, sData );
               End;
               HEADER_LOCK :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    nPlayerClient[k] := nIndex;
                    Send( nIndex, nHeader, sData );
                    //UpdateMenu();
               End;
               HEADER_UNLOCK :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    nPlayerClient[k] := -1;
                    nPlayerType[k] := PLAYER_NIL;
                    Send( nIndex, nHeader, sData );
                    SetString( STRING_GAME_MENU(10 + k), PlayerInfo(k), 0.0, 0.02, 600 );
                    If ( bOnline ) Then Begin
                       sData := IntToStr( k ) + #31;
                       sData := sData + IntToStr( nPlayerType[k] ) + #31;
                       sData := sData + sPlayerName[k] + #31;
                       sData := sData + sClientUserName[ClientIndex(nIndex)] + #31;
                       sData := sData + sClientUserPassword[ClientIndex(nIndex)] + #31;
                       SendOnline( nLocalIndex, HEADER_ONLINE_PLAYER, sData );
                    End;
               End;
               HEADER_BTN_READY :
               Begin
                    bClientBtnReady[ClientIndex(nIndex)] := True;
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' is ready.' );
                    Send( nIndex, nHeader, sData );
                    UpdatePlayerInfo();
                    If ( nGame <> GAME_MENU ) And ( nGame <> GAME_MENU_PLAYER ) And ( nGame <> GAME_MENU_MULTI ) Then
                       UpdatePlayerScore();
               End;
               HEADER_BTN_NOTREADY :
               Begin
                    bClientBtnReady[ClientIndex(nIndex)] := False;
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' is not ready.' );
                    Send( nIndex, nHeader, sData );
                    UpdatePlayerInfo();
                    If ( nGame <> GAME_MENU ) And ( nGame <> GAME_MENU_PLAYER ) And ( nGame <> GAME_MENU_MULTI ) Then
                       UpdatePlayerScore();
               End;
               HEADER_PINGREQ :
               Begin
                    sData := '';
                    SendTo( nIndex, HEADER_PINGRES, sData );
               End;
               HEADER_PINGRES :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    fPlayerPing[k] := StrToFloat( GetString( sData, 2 ) );
                    sData := '';
                    For k := 1 To 8 Do Begin
                        sData := sData + FormatFloat('0.000',fPlayerPing[k]) + #31;
                    End;
                    Send( nIndex, HEADER_PINGARY, sData );
               End;
               HEADER_UPDATE :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    TryStrToInt( GetString( sData, 2 ), nPlayerType[k] );
                    TryStrToInt( GetString( sData, 3 ), nPlayerSkill[k] );
                    TryStrToInt( GetString( sData, 4 ), nPlayerCharacter[k] );
                    sPlayerName[k] := GetString( sData, 5 );
                    Send( nIndex, nHeader, sData );
                    If ( bOnline ) Then Begin
                       sData := IntToStr( k ) + #31;
                       sData := sData + IntToStr( nPlayerType[k] ) + #31;
                       sData := sData + sPlayerName[k] + #31;
                       sData := sData + sClientUserName[ClientIndex(nIndex)] + #31;
                       sData := sData + sClientUserPassword[ClientIndex(nIndex)] + #31;
                       SendOnline( nLocalIndex, HEADER_ONLINE_PLAYER, sData );
                    End;
                    SetString( STRING_GAME_MENU(10 + k), PlayerInfo(k), 0.0, 0.02, 600 );
               End;
               HEADER_MOVEUP :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, 2 ) );
                    fY := StrToFloat( GetString( sData, 3 ) );
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    pBomberman.Direction := 180;
                    pBomberman.LastDirN.x := 0;
                    pBomberman.LastDirN.y := -1;
                    pBomberman.fMoveTime := GetTime();
               End;
               HEADER_MOVEDOWN :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, 2 ) );
                    fY := StrToFloat( GetString( sData, 3 ) );
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    pBomberman.Direction := 0;
                    pBomberman.LastDirN.x := 0;
                    pBomberman.LastDirN.y := 1;
                    pBomberman.fMoveTime := GetTime();
               End;
               HEADER_MOVELEFT :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, 2 ) );
                    fY := StrToFloat( GetString( sData, 3 ) );
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    pBomberman.Direction := 90;
                    pBomberman.LastDirN.x := -1;
                    pBomberman.LastDirN.y := 0;
                    pBomberman.fMoveTime := GetTime();
               End;
               HEADER_MOVERIGHT :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, 2 ) );
                    fY := StrToFloat( GetString( sData, 3 ) );
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    pBomberman.Direction := -90;
                    pBomberman.LastDirN.x := 1;
                    pBomberman.LastDirN.y := 0;
                    pBomberman.fMoveTime := GetTime();
               End;
               HEADER_ACTION0 :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), k ); l += 1;
                    pBomberman := GetBombermanByIndex( k );
                    TryStrToInt( GetString( sData, l ), _nNetID ); l += 1;
                    fX := StrToFloat( GetString( sData, l ) ); l += 1;
                    fY := StrToFloat( GetString( sData, l ) ); l += 1;
                    TryStrToInt( GetString( sData, l ), nBombSize ); l += 1;
                    fBombTime := StrToFloat( GetString( sData, l ) ); l += 1;
                    If Not ( GetBombByNetID( _nNetId ) Is CBomb ) And pBomberman.Alive Then Begin
                        pBomberman.CreateBombMulti( fX, fY, nBombSize, fBombTime, _nNetID );
                        Send( nLocalIndex, HEADER_ACTION0, sData );
                    End;
               End;
               HEADER_ACTION1 :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    sData := GetString( sData, 1 ) + #31;
                    Send( nLocalIndex, HEADER_ACTION1, sData );
                    pBomberman.DoIgnition();
               End;
               HEADER_PUNCH :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    TryStrToInt( GetString( sData, 2 ), nDirection );
                    TryStrToInt( GetString( sData, 3 ), dX );
                    TryStrToInt( GetString( sData, 4 ), dY );
                    dt := StrToFloat( GetString( sData, 5 ) );
                    If (pGrid.GetBlock(dX,dY) is CBomb) Then
                    Case nDirection of
                              0    :  CBomb(pGrid.GetBlock(dX,dY)).Punch(DOWN,dt);
                              90   :  CBomb(pGrid.GetBlock(dX,dY)).Punch(LEFT,dt);
                              180  :  CBomb(pGrid.GetBlock(dX,dY)).Punch(UP,dt);
                              -90  :  CBomb(pGrid.GetBlock(dX,dY)).Punch(RIGHT,dt);
                            End;
                    PlaySound( SOUND_KICK( Random(4) + 1 ) );
                    Send( nLocalIndex, HEADER_PUNCH, '' );
               End;
               HEADER_MOVEBOMB :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    TryStrToInt( GetString( sData, 2 ), aX );
                    TryStrToInt( GetString( sData, 3 ), aY );
                    TryStrToInt( GetString( sData, 4 ), dX );
                    TryStrToInt( GetString( sData, 5 ), dY );
                    dt := StrToFloat( GetString( sData, 6 ) );
                    pBomberman.MoveBomb(aX,aY,aX,aY,dX,dY,dt);
                    PlaySound( SOUND_KICK( Random(4) + 1 ) );

               End;
               HEADER_CHECK_BONUS :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), k ); l += 1;
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, l ) ); l += 1;
                    fY := StrToFloat( GetString( sData, l ) ); l += 1;
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    TryStrToInt( GetString( sData, l ), dX ); l += 1;
                    TryStrToInt( GetString( sData, l ), dY ); l += 1;
                    pBomberman.LastDirN.x := dX;
                    pBomberman.LastDirN.y := dY;
                    TryStrToInt( GetString( sData, l ), nDirection ); l += 1;
                    If ( nDirection = 0 ) Then pBomberman.Direction := 0
                    Else If ( nDirection = 1 ) Then pBomberman.Direction := 90
                    Else If ( nDirection = 2 ) Then pBomberman.Direction := 180
                    Else If ( nDirection = 3 ) Then pBomberman.Direction := -90;
                    pBomberman.CheckBonus();
               End;
               HEADER_SWITCH :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    pBomberman.DiseaseNumber := DISEASE_NONE;
                    pBomberman.Position.X := StrToFloat( GetString( sData, 2 ) );
                    pBomberman.Position.Y := StrToFloat( GetString( sData, 3 ) );
                    TryStrToInt( GetString( sData, 4 ), l );
                    pSecondBomberman := GetBombermanByIndex( l );
                    fX := StrToFloat( GetString( sData, 5 ) );
                    fY := StrToFloat( GetString( sData, 6 ) );
                    If ( pGrid.GetBlock( Trunc( fX + 0.5 ), Trunc( fY + 0.5 ) ) <> Nil ) Then
                       pGrid.GetBlock( Trunc( fX + 0.5 ), Trunc( fY + 0.5 ) ).Destroy();
                    pGrid.aBlock[ Trunc( fX + 0.5 ), Trunc( fY + 0.5 ) ] := Nil;
                    pSecondBomberman.Position.X := fX;
                    pSecondBomberman.Position.Y := fY;
               End;
               HEADER_GRAB_SERVER :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    TryStrToInt( GetString( sData, 2 ), dX );
                    TryStrToInt( GetString( sData, 3 ), dY );
                    If ( ( pGrid.GetBlock( dX, dY ) <> Nil ) And ( pGrid.GetBlock( dX, dY ) Is CBomb ) ) Then Begin
                        pBomberman.GrabBombMulti( dX, dY );
                        sData := IntToStr( k ) + #31;
                        sData := sData + IntToStr( dX ) + #31;
                        sData := sData + IntToStr( dY ) + #31;
                        Send( nLocalIndex, HEADER_GRAB_CLIENT, sData );
                    End;
               End;
               HEADER_DROP_SERVER :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    dt := StrToFloat( GetString( sData, 2 ) );
                    pBomberman.DropBombMulti( dt );
                    sData := IntToStr( k ) + #31;
                    sData := sData + FormatFloat('0.000',pBomberman.Position.x) + #31;
                    sData := sData + FormatFloat('0.000',pBomberman.Position.y) + #31;
                    Send( nLocalIndex, HEADER_DROP_CLIENT, sData );
               End;
          End;
     End;
     
     If nGame = GAME_ROUND Then Begin
        sData := '';
        For k := 1 To 8 Do Begin
            pBomberman := GetBombermanByIndex( k );
            If pBomberman <> Nil Then Begin
               sData := sData + FormatFloat('0.000',pBomberman.Position.x) + #31;
               sData := sData + FormatFloat('0.000',pBomberman.Position.y) + #31;
               sData := sData + IntToStr(pBomberman.LastDirN.x) + #31;
               sData := sData + IntToStr(pBomberman.LastDirN.y) + #31;
               If (pBomberman.Direction = 0) Then nDirection := 0
               Else If (pBomberman.Direction = 90) Then nDirection := 1
               Else If (pBomberman.Direction = 180) Then nDirection := 2
               Else If (pBomberman.Direction = -90) Then nDirection := 3
               Else nDirection := -1;
               sData := sData + IntToStr(nDirection) + #31;
               If pBomberman.IsMoving() Then
                  sData := sData + 'M' + #31
               Else
                  sData := sData + 'I' + #31;
            End;
        End;
        Send( nLocalIndex, HEADER_BOMBERMAN, sData );

        If GetBombCount() > 0 Then Begin
           sData := '';
           For k := 1 To GetBombCount() Do Begin
               pBomb := GetBombByCount( k );
               sData := sData + IntToStr(pBomb.nNetID) + #31;
               sData := sData + FormatFloat('0.000',pBomb.Position.x) + #31;
               sData := sData + FormatFloat('0.000',pBomb.Position.y) + #31;
               sData := sData + FormatFloat('0.000',pBomb.Position.z) + #31;
               If bDebug And ( pBomb.Position.x < 1 ) Or ( pBomb.Position.y < 1 ) Then
                  AddLineToConsole( 'Paquet Bug!' );  // C'est normal si la bombe est porté avec un grab!
           End;
           Send( nLocalIndex, HEADER_BOMB, sData );
        End;
    End;
    
    If (nGame = GAME_ROUND) And (GetTime > fCheckTime + 5.0) Then Begin
        // Vérifier les blocks.
        sData := '';
        For k := 1 To GRIDHEIGHT Do Begin
            nSum := 0;
            For l := 1 To GRIDWIDTH Do Begin  // 0 pour vide, 1 pour bonus, 2 pour block explosable.
                If ( pGrid.GetBlock(l,k) <> Nil )
                And ( pGrid.GetBlock(l,k).IsExplosive() ) And Not ( pGrid.GetBlock(l,k) Is CBomb ) Then Begin
                    If ( pGrid.GetBlock(l,k) Is CItem ) And ( (pGrid.GetBlock(l,k) As CItem).IsExplosed() ) Then
                       nNbr := 1
                    Else
                        nNbr := 2;
                End
                Else
                    nNbr := 0;
                nSum := nSum + nNbr * IntPower( 3, l );
            End;
            sData := sData + IntToStr( nSum ) + #31;
        End;

        Send( nLocalIndex, HEADER_CHECK_BLOCK, sData );
        
        // Vérifier les bombermans.
        sData := '';
        nSum := 0;
        For k := 1 To 8 Do Begin  // 0 pour mort, 1 pour vivant.
            pBomberman := GetBombermanByIndex( k );
            If ( pBomberman <> Nil ) And ( pBomberman.Alive = True ) Then
                nSum := nSum + IntPower( 2, k );
        End;
        sData := IntToStr( nSum ) + #31;
        
        Send( nLocalIndex, HEADER_CHECK_BOMBERMAN, sData );
            

        

        fCheckTime := GetTime;
    End;
End;



Procedure ProcessClient () ;
Var nIndex : DWord;
    nHeader : Integer;
    sData : String;
    sBuffer : String;
    pBomberman, pSecondBomberman : CBomberman;
    pBomb : CBomb;
    pBlock : CBlock;
    pDisease : CDisease;
    fX, fY, fZ : Single;
    nX, nY : Integer;
    nBombSize, nDirection : Integer;
    fBombTime : Single;
    isBomb : Boolean;
    sState : String;
    nBonus : Integer;
    _nNetID, nSum, nNbr : Integer;
   // tNetID : Array [1..64] Of Integer;
    nNbrNetId : Integer;
    sTemp : String;
Var k, l, m, i : Integer;
Begin
     While GetPacket( nIndex, nHeader, sData ) Do Begin
          Case nHeader Of
               HEADER_SHOW :
               Begin
                    AddLineToConsole( sData );
                    nState := PHASE_MENU;
               End;
               HEADER_MESSAGE :
               Begin
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' says : ' + sData );
                    AddStringToScreen( sClientName[ClientIndex(nIndex)] + ' says : ' + sData );
               End;
               HEADER_LIST_CLIENT :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), nClientCount ); l += 1;
                    For k := 0 To nClientCount - 1 Do Begin
                        TryStrToInt( GetString( sData, l ), nClientIndex[k] ); l += 1;
                        sClientName[k] := GetString( sData, l ); l += 1;
                        TryStrToInt( GetString( sData, l ), i ); l += 1;
                        If i = 1 Then Begin
                           bClientBtnReady[k] := True;
                        End Else Begin
                           bClientBtnReady[k] := False;
                        End;
                    End;
               End;
               HEADER_LIST_PLAYER :
               Begin
                    l := 1;
                    For k := 1 To 8 Do Begin
                        TryStrToInt( GetString( sData, l ), nPlayerClient[k] ); l += 1;
                        sPlayerName[k] := GetString( sData, l ); l += 1;
                        nPlayerCharacter[k] := -1;
                        For m := 0 To nCharacterCount - 1 Do
                            If aCharacterList[m].Name = GetString( sData, l ) Then nPlayerCharacter[k] := m;
                      //  LoadCharacter( k );
                        l += 1;
                        TryStrToInt( GetString( sData, l ), nPlayerType[k] ); l += 1;
                    End;
                    If ( nGame = GAME_MENU ) Or ( nGame = GAME_MENU_PLAYER ) Or ( nGame = GAME_MENU_MULTI ) Then
                       UpdatePlayerInfo();
               End;
               HEADER_LOCK :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    nPlayerClient[k] := nIndex;
                   // UpdateMenu();
               End;
               HEADER_UNLOCK :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    nPlayerClient[k] := -1;
                    nPlayerType[k] := PLAYER_NIL;
                    SetString( STRING_GAME_MENU(10 + k), PlayerInfo(k), 0.0, 0.02, 600 );
               End;
               HEADER_UPDATE :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    TryStrToInt( GetString( sData, 2 ), nPlayerType[k] );
                    TryStrToInt( GetString( sData, 3 ), nPlayerSkill[k] );
                    TryStrToInt( GetString( sData, 4 ), nPlayerCharacter[k] );
                    sPlayerName[k] := GetString( sData, 5 );
                    SetString( STRING_GAME_MENU(10 + k), PlayerInfo(k), 0.0, 0.02, 600 );
               End;
               HEADER_SETUP :
               Begin
                    TryStrToInt( GetString( sData, 1 ), nScheme );
                    TryStrToInt( GetString( sData, 2 ), nSchemeMulti );
                    TryStrToInt( GetString( sData, 3 ), nMap );
                    TryStrToInt( GetString( sData, 4 ), nRoundCount );
                    UpdateMenu();
               End;
               HEADER_FIGHT :
               Begin
                    For k := 0 To 255 Do Begin
                        bClientReady[k] := False;
                    End;
                    nGame := GAME_INIT;
               End;
               HEADER_READY :
               Begin
                    bClientReady[ClientIndex(nIndex)] := True;
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' is ready.' );
               End;
               HEADER_BTN_READY :
               Begin
                    bClientBtnReady[ClientIndex(nIndex)] := True;
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' is ready.' );
                    UpdatePlayerInfo();
                    If ( nGame <> GAME_MENU ) And ( nGame <> GAME_MENU_PLAYER ) And ( nGame <> GAME_MENU_MULTI ) Then
                       UpdatePlayerScore();
               End;
               HEADER_BTN_NOTREADY :
               Begin
                    bClientBtnReady[ClientIndex(nIndex)] := False;
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' is not ready.' );
                    UpdatePlayerInfo();
                    If ( nGame <> GAME_MENU ) And ( nGame <> GAME_MENU_PLAYER ) And ( nGame <> GAME_MENU_MULTI ) Then
                       UpdatePlayerScore();
               End;
               HEADER_END_GAME :
               Begin
                    For k := 0 To 255 Do Begin
                        bClientBtnReady[k] := False;
                    End;
                    bLocalReady := False;
                    InitMenu();
               End;
               HEADER_PINGRES :
               Begin
                    fPing := (GetTime - fPingTime) * 500;
                    sData := IntToStr(nPlayer) + #31;
                    sData := sData + FormatFloat('0.000',fPing) + #31;
                    Send( nLocalIndex, HEADER_PINGRES, sData );
               End;
               HEADER_PINGARY :
               Begin
                    l := 1;
                    For k := 1 To 8 Do Begin
                        fPlayerPing[k] := StrToFloat( GetString( sData, l ) ); l += 1;
                    End;
               End;
               HEADER_ROUND :
               Begin
                    fRoundTime := GetTime;
                    InitRound();
                    For k := 1 To GRIDWIDTH Do Begin
                        For l := 1 To GRIDHEIGHT Do Begin
                            numDisease[k, l] := -1;
                        End;
                    End;
                    m := 1;
                    For k := 1 To GRIDWIDTH Do Begin
                        For l := 1 To GRIDHEIGHT Do Begin
                            If ( pGrid.GetBlock(k, l) Is CBlock ) And ( pGrid.GetBlock(k, l).IsExplosive() = True ) Then Begin
                               TryStrToInt( GetString( sData, m ), nBonus );
                               m := m + 1;
                               Case nBonus Of
                                    POWERUP_NONE            : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CBlock.Create(k,l,True);
                                                              End;
                                    POWERUP_EXTRABOMB       : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CExtraBomb.Create(k,l);
                                                              End;
                                    POWERUP_FLAMEUP         : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CFlameUp.Create(k,l);
                                                              End;
                                    POWERUP_DISEASE         : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CDisease.Create(k,l);
                                                                   TryStrToInt( GetString( sData, m ), numDisease[k,l] );
                                                                   m += 1;
                                                              End;
                                    POWERUP_KICK            : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CKick.Create(k,l);
                                                              End;
                                    POWERUP_SPEEDUP         : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CSpeedUp.Create(k,l);
                                                              End;
                                    POWERUP_PUNCH           : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CPunch.Create(k,l);
                                                              End;
                                    POWERUP_GRAB            : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CGrab.Create(k,l);
                                                              End;
                                    POWERUP_SPOOGER         : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CSpoog.Create(k,l);
                                                              End;
                                    POWERUP_GOLDFLAME       : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CGoldFlame.Create(k,l);
                                                              End;
                                    POWERUP_TRIGGERBOMB     : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CTrigger.Create(k,l);
                                                              End;
                                    POWERUP_JELLYBOMB       : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CJelly.Create(k,l);
                                                              End;
                                    POWERUP_SUPERDISEASE    : Begin
                                                                   pGrid.GetBlock(k, l).Destroy();
                                                                   pGrid.aBlock[k,l] := CSuperDisease.Create(k,l);
                                                                   TryStrToInt( GetString( sData, m ), numDisease[k,l] );
                                                                   m += 1;
                                                              End;
                               End;
                            End;
                        End;
                    End;
               End;
               HEADER_BOMBERMAN :
               Begin
                    l := 1;
                    For k := 1 To 8 Do Begin
                        pBomberman := GetBombermanByIndex( k );
                        If (pBomberman <> Nil) Then Begin
                           If (nPlayerClient[k] <> nLocalIndex) Then Begin
                              fX := StrToFloat( GetString( sData, l ) ); l += 1;
                              fY := StrToFloat( GetString( sData, l ) ); l += 1;
                              pBomberman.Position.x := fX;
                              pBomberman.Position.y := fY;
                              TryStrToInt( GetString( sData, l ), nX ); l += 1;
                              TryStrToInt( GetString( sData, l ), nY ); l += 1;
                              pBomberman.LastDirN.x := nX;
                              pBomberman.LastDirN.y := nY;
                              TryStrToInt( GetString( sData, l ), nDirection ); l += 1;
                              If ( nDirection = 0 ) Then pBomberman.Direction := 0
                              Else If ( nDirection = 1 ) Then pBomberman.Direction := 90
                              Else If ( nDirection = 2 ) Then pBomberman.Direction := 180
                              Else If ( nDirection = 3 ) Then pBomberman.Direction := -90;
                              sState := GetString( sData, l ); l += 1;
                              If ( sState = 'M' ) Then pBomberman.fMoveTime := GetTime();
                           End
                           Else Begin
                                l += 6;
                           End;
                           pBomberman.CheckBonus();
                        End;
                    End;
               End;
               HEADER_ACTION0 :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), k ); l += 1;
                    pBomberman := GetBombermanByIndex( k );
                    TryStrToInt( GetString( sData, l ), _nNetID ); l += 1;
                    fX := StrToFloat( GetString( sData, l ) ); l += 1;
                    fY := StrToFloat( GetString( sData, l ) ); l += 1;
                    TryStrToInt( GetString( sData, l ), nBombSize ); l += 1;
                    fBombTime := StrToFloat( GetString( sData, l ) ); l += 1;
                    If Not ( GetBombByNetID( _nNetId ) Is CBomb ) Then Begin
                        pBomberman.CreateBombMulti( fX, fY, nBombSize, fBombTime, _nNetID );
                    End
                    Else Begin
                        GetBombByNetID( _nNetId).IsChecked := True;
                    End;
               End;
               HEADER_ACTION1 :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    If pBomberman.GetTargetTriggerBomb <> Nil Then Begin
                        pBomberman.GetTargetTriggerBomb.Ignition();
                        pBomberman.DelTriggerBomb();
                    End;
               End;
               HEADER_EXPLOSE_BOMB :
               Begin
                    TryStrToInt( GetString( sData, 1 ), _nNetID );
                    pBomb := GetBombByNetID( _nNetID );
                    If ( pBomb <> Nil ) Then
                       pBomb.Explose();
               End;
               HEADER_EXPLOSE_BLOCK :
               Begin
                    TryStrToInt( GetString( sData, 1 ), nX );
                    TryStrToInt( GetString( sData, 2 ), nY );
                    pBlock := pGrid.GetBlock( nX, nY );
                    If ( pBlock <> Nil ) Then Begin
                       If ( pBlock Is CItem ) Then
                          (pBlock As CItem).ExploseMulti()
                       Else
                           (pBlock As CBlock).ExploseMulti();
                       pGrid.DelBlock( nX, nY );
                    End;
               End;
               HEADER_ISEXPLOSED_ITEM :
               Begin
                    TryStrToInt( GetString( sData, 1 ), nX );
                    TryStrToInt( GetString( sData, 2 ), nY );
                    pBlock := pGrid.GetBlock( nX, nY );
                    If ( pBlock <> Nil ) And ( pBlock Is CItem ) And ( (pBlock As CItem).IsExplosed() = False) Then Begin
                       (pBlock As CItem).bIsExplosed := True;
                    End;
               End;
               HEADER_SWITCH :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    pBomberman.DiseaseNumber := DISEASE_NONE;
                    pBomberman.Position.X := StrToFloat( GetString( sData, 2 ) );
                    pBomberman.Position.Y := StrToFloat( GetString( sData, 3 ) );
                    TryStrToInt( GetString( sData, 4 ), l );
                    pSecondBomberman := GetBombermanByIndex( l );
                    fX := StrToFloat( GetString( sData, 5 ) );
                    fY := StrToFloat( GetString( sData, 6 ) );
                    If ( pGrid.GetBlock( Trunc( fX + 0.5 ), Trunc( fY + 0.5 ) ) <> Nil ) Then
                       pGrid.GetBlock( Trunc( fX + 0.5 ), Trunc( fY + 0.5 ) ).ExploseMulti();
                    pGrid.DelBlock( Trunc( fX + 0.5 ), Trunc( fY + 0.5 ) );
                    pSecondBomberman.Position.X := fX;
                    pSecondBomberman.Position.Y := fY;
                    Send( nLocalIndex, HEADER_SWITCH, sData );
               End;
               HEADER_GRAB_CLIENT :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    TryStrToInt( GetString( sData, 2 ), nX );
                    TryStrToInt( GetString( sData, 3 ), nY );
                    If ( ( pGrid.GetBlock( nX, nY ) <> Nil ) And ( pGrid.GetBlock( nX, nY ) Is CBomb ) ) Then Begin
                        pBomberman.GrabBombMulti( nX, nY );
                    End;
               End;
               HEADER_DROP_CLIENT :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), k ); l += 1;
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, l ) ); l += 1;
                    fY := StrToFloat( GetString( sData, l ) ); l += 1;
                    If ( pBomberman.uGrabbedBomb <> Nil ) Then Begin
                        pBomberman.uGrabbedBomb.Position.X := fX;
                        pBomberman.uGrabbedBomb.Position.Y := fY;
                        pBomberman.uGrabbedBomb.StartTime();
                        pBomberman.uGrabbedBomb.Position.Z := 0;
                        pBomberman.uGrabbedBomb.JumpMovement := True;
                        pBomberman.uGrabbedBomb := Nil;
                        PlaySound( SOUND_THROW( Random(4) + 1 ) );
                    End;
               End;
               HEADER_END_OF_JUMP :
               Begin
                    TryStrToInt( GetString( sData, 1 ), _nNetID );
                    pBomb := GetBombByNetID( _nNetID );
                    TryStrToInt( GetString( sData, 2 ), nX );
                    TryStrToInt( GetString( sData, 3 ), nY );
                    pGrid.DelBlock(nX,nY);
                    If ( pBomb <> Nil ) Then Begin
                        pBomb.Position.z   := 0.0;
                        pBomb.xGrid        := nX;
                        pBomb.yGrid        := nY;
                        pBomb.nOriginX     := nX;
                        pBomb.nOriginY     := nY;
                        pBomb.Position.x   := nX;
                        pBomb.Position.y   := nY;
                        pGrid.AddBlock(nX,nY,pBomb);
                        pBomb.bJumping     := false;
                        pBomb.bMoveJump    := false;
                        pBomb.bMoving      := false;
                    End
                    Else If bDebug Then
                        AddLineToConsole( 'Bug : Header_end_of_jump' );
               End;
               HEADER_BJUMPING :
               Begin
                    TryStrToInt( GetString( sData, 1 ), _nNetID );
                    pBomb := GetBombByNetID( _nNetID );
                    If ( pBomb <> Nil ) Then
                       pBomb.bJumping := False
                    Else If bDebug Then
                        AddLineToConsole( 'Bug : Header_bjumping' );
               End;
               HEADER_CONTAMINATE :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    TryStrToInt( GetString( sData, 2 ), l );
                    pSecondBomberman := GetBombermanByIndex( l );
                    If ( pSecondBomberman <> Nil ) And ( pBomberman <> Nil )
                    And ( pSecondBomberman.DiseaseNumber = 0 ) Then Begin
                       SetString( STRING_NOTIFICATION, pSecondBomberman.Name + ' has been stephaned by ' + pBomberman.sName, 0.0, 0.2, 5 );
                       pDisease := CDisease.Create(1,1);
                       pDisease.BonusForced( pSecondBomberman, pBomberman.nDisease );
                    End;
               End;
               HEADER_PUNCH :
               Begin
                    PlaySound( SOUND_KICK( Random(4) + 1 ) );
               End;
               HEADER_WAIT :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), k ); l += 1;
                    If k <= 0 Then Begin
                       If GetBombermanCount() <> 0 Then Begin
                          For i := 1 To GetBombermanCount() Do Begin
                              GetBombermanByCount(i).Alive := False;
                          End;
                       End;
                    End Else Begin
                       If GetBombermanCount() <> 0 Then Begin
                          For i := 1 To GetBombermanCount() Do Begin
                              GetBombermanByCount(i).Alive := False;
                          End;
                       End;
                       GetBombermanByIndex(k).Alive := True;
                    End;
                    If GetBombermanCount() <> 0 Then Begin
                       For i := 1 To GetBombermanCount() Do Begin
                           TryStrToInt( GetString( sData, l ), GetBombermanByCount(i).Score ); l += 1;
                           TryStrToInt( GetString( sData, l ), GetBombermanByCount(i).Kills ); l += 1;
                           TryStrToInt( GetString( sData, l ), GetBombermanByCount(i).Deaths ); l += 1;
                       End;
                    End;
                    InitWait();
               End;
               HEADER_BOMB :
               Begin
                    l := 1;
                    nNbrNetId := 0;
                    While ( GetString( sData, l ) <> 'NULL' ) Do Begin
                        TryStrToInt( GetString( sData, l ), _nNetID ); l += 1;
                     {   nNbrNetId += 1;
                        If ( nNbrNetId <= 64 ) Then
                           tNetId[ nNbrNetId ] := _nNetId; }
                        pBomb := GetBombByNetID( _nNetID );
                        If pBomb <> Nil Then Begin
                           fX := StrToFloat( GetString( sData, l ) ); l += 1;
                           fY := StrToFloat( GetString( sData, l ) ); l += 1;
                           fZ := StrToFloat( GetString( sData, l ) ); l += 1;
                           If ( abs( pBomb.Position.x - fX ) > 0.001 ) Or ( abs( pBomb.Position.y - fY ) > 0.001 ) Then Begin
                             { If ( pBomb.JumpMovement = False ) Then Begin
                            //  Or ( pGrid.GetBlock( pBomb.xGrid, pBomb.yGrid ) = Nil ) ) Then Begin
                            //  And ( IsBombermanAtCoo( pBomb.xGrid, pBomb.yGrid ) = False ) Then
                                 pGrid.DelBlock( pBomb.xGrid, pBomb.yGrid );
                                 AddLineToConsole( 'Bug : delblock for dropped bomb' );
                              End; }
                              pBomb.Position.x := fX;
                              pBomb.Position.y := fY;
                              pBomb.xGrid := Trunc( fX );
                              pBomb.yGrid := Trunc( fY );
                            //  If ( pBomb.JumpMovement = False )
                            //  And ( IsBombermanAtCoo( pBomb.xGrid, pBomb.yGrid ) = False ) Then
                             { If ( pBomb.JumpMovement = False ) Then
                             // Or ( pGrid.GetBlock( pBomb.xGrid, pBomb.yGrid ) = Nil ) ) Then
                                 pGrid.AddBlock( pBomb.xGrid, pBomb.yGrid, pBomb ); }
                           End;
                           pBomb.xGrid := Trunc( fX );
                           pBomb.yGrid := Trunc( fY );
                           pBomb.Position.z := fZ;
                        End Else Begin
                            l += 3;
                        End;
                    End;
                  {  If ( nNbrNetId >= 0 ) And ( nNbrNetId <= 64 ) Then Begin
                        For k := 1 To GetBombCount() Do Begin
                            pBomb := GetBombByCount( k );
                            If ( pBomb <> Nil ) Then
                               isBomb := False;
                               l := 1;
                               While ( l <= nNbrNetId ) And ( isBomb = False ) Do Begin
                                    If ( tNetId[ l ] = pBomb.nNetId ) Then
                                       isBomb := True;
                                    l += 1;
                               End;
                               If ( isBomb = False ) Then Begin
                                  If ( pBomb Is CTriggerBomb ) Then Begin
                                     (pBomb AS CTriggerBomb).Ignition();
                                     pBomberman := GetBombermanByIndex( pBomb.nIndex );
                                     If ( pBomberman <> Nil ) Then pBomberman.DelTriggerBomb();
                                  End
                                  Else
                                      pBomb.Explose();
                               End;
                        End;
                    End;  }
               End;
               HEADER_BOMB_DOMOVE :
               Begin
                    {
                      uGrid.DelBlock(nX,nY);
                     if nPunch>0 then
                       if ((aX<>nX) or (aY<>nY)) then
                         if (abs(afX-aX)<0.1) and (abs(afY-aY)<0.1) then nPunch -= 1;
                     nX:=aX;
                     nY:=aY;
                     fPosition.x:=afX;
                     fPosition.y:=afY;
                     uGrid.AddBlock(nX,nY,Self);
                    }
                    l := 1;
                    TryStrToInt( GetString( sData, l ), _nNetID ); l += 1;
                    pBomb := GetBombByNetID( _nNetID );
                    fX := StrToFloat( GetString( sData, l ) ); l += 1;
                    fY := StrToFloat( GetString( sData, l ) ); l += 1;
                    If ( pBomb <> Nil ) Then Begin
                       pGrid.DelBlock( pBomb.XGrid, pBomb.YGrid );
                       pBomb.xGrid := Trunc( fX );
                       pBomb.yGrid := Trunc( fY );
                       pBomb.Position.X := fX;
                       pBomb.Position.Y := fY;
                       pGrid.AddBlock( pBomb.XGrid, pBomb.YGrid, pBomb );
                    End;
               End;
               HEADER_CHECK_BLOCK :
               Begin
                    l := 1;
                    For k := 1 To GRIDHEIGHT Do Begin
                        TryStrToInt( GetString( sData, l ), nSum ); l += 1;
                        nSum := nSum div 3;
                        For m := 1 To GRIDWIDTH Do Begin
                            nNbr := nSum mod 3;
                            nSum := nSum div 3;
                            pBlock := pGrid.GetBlock(m,k);
                            If ( nNbr = 0 ) And ( pBlock <> Nil )
                            And ( pBlock.IsExplosive() ) And Not ( pBlock Is CBomb ) Then Begin
                                If ( pBlock Is CItem ) Then
                                   (pBlock As CItem).ExploseMulti()
                                Else
                                    (pBlock As CBlock).ExploseMulti();
                                pGrid.DelBlock(m,k);
                            End;
                            If ( nNbr = 1 ) And ( pBlock <> Nil )
                            And ( pBlock.IsExplosive() ) And Not ( pBlock Is CBomb )
                            And ( pBlock Is CItem ) And ( (pBlock As CItem).IsExplosed() = False ) Then Begin
                                (pBlock As CItem).bIsExplosed := True;
                            End;
                        End;
                    End;
               End;
               HEADER_CHECK_BOMBERMAN :
               Begin
                    TryStrToInt( GetString( sData, 1 ), nSum );
                    nSum := nSum div 2;
                    For k := 1 To 8 Do Begin
                        nNbr := nSum mod 2;
                        nSum := nSum div 2;
                        pBomberman := GetBombermanByIndex( k );
                        If ( pBomberman <> Nil ) And ( pBomberman.Alive = True ) And ( nNbr = 0 ) Then
                           pBomberman.Alive := False;
                    End;
               End;
               HEADER_DEAD :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    If ( pBomberman <> Nil ) Then Begin
                       If ( pBomberman.Alive = True ) Then PlaySound( SOUND_DIE( Random( 2 ) + 1 ) );
                       pBomberman.Alive := false;
                    End;
               End;
               HEADER_QUIT_GAME :
               Begin
                    PlaySound( SOUND_MENU_BACK );
                    For k := 0 To 255 Do Begin
                        bClientBtnReady[k] := False;
                    End;
                    bLocalReady := False;
                    InitMenu();
                    ClearInput();
               End;
            {   HEADER_QUIT_MENU :
               Begin
                    nState := PHASE_MENU;
               End; }
          End;
     End;
     
     If (nGame = GAME_ROUND) And (GetTime > fPingTime + 1.0) Then Begin
        sData := '';
        Send( nLocalIndex, HEADER_PINGREQ, sData );
        fPingTime := GetTime;
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
     bGoToPhaseMenu := False;

     // initialisation du compteur de clients
     nClientCount := 0;
     
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
          GAME_SYNCHRO : SynchroGame();
          GAME_ROUND : ProcessGame();
          GAME_WAIT : ProcessWait();
          GAME_SCORE : ProcessScore();
     End;

     If nMulti = MULTI_SERVER Then Begin
        ProcessServer();
        If (nState = PHASE_MENU) Or (bGoToPhaseMenu) Then Begin
           ServerTerminate();
           nState := PHASE_MENU;
        End
        Else ServerLoop();
     End Else If nMulti = MULTI_CLIENT Then Begin
        If (nState = PHASE_MENU) Or (bGoToPhaseMenu) Then Begin
         {  If Not bSendDisconnect Then Begin
              Send( nLocalIndex, HEADER_DISCONNECT, sLocalName );
              bSendDisconnect := True;
           End;
           If GetTime() > ( fKey + 8.0 ) Then nState := PHASE_MENU; }
           nState := PHASE_MENU;
        End;
        ProcessClient();
        If (nState = PHASE_MENU) Then Begin
           ClientTerminate();
        End
        Else ClientLoop();
     End;
End;





























End.

