Unit UMulti;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils, UJellyBomb, UPunch, USpoog, UGoldFLame, UTrigger, UTriggerBomb, USuperDisease,
     UCore, UGame, UUtils, USetup, UForm, UExtraBomb, UFlameUp, UKick, UGrab, UJelly, UDisease, USpeedUp;



Var nClientCount : Integer;
Var nClientIndex : Array [0..255] Of Integer;
Var sClientName : Array [0..255] Of String;
Var fPingTime, fPing : Single;



Procedure InitMulti () ;
Procedure ProcessMulti () ;



Implementation

Uses UBomberman, UListBomb, UBomb, UBlock, UItem, UGrid;



Const MULTI_NONE       = 0;
Const MULTI_SERVER     = 1;
Const MULTI_CLIENT     = 2;
Const MULTI_ERROR      = 3;

Var nMulti : Integer;



Const GAME_MENU_MULTI = 12;



Const MENU_MULTI_NAME         = 81;
Const MENU_MULTI_ADDRESS      = 82;
Const MENU_MULTI_TYPE         = 83;

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
     Case nServerType Of
          SERVER_UNKNOWN : SetString( STRING_GAME_MENU(83), 'type : unknown', 0.2, 1.0, 600 );
          SERVER_STANDARD : SetString( STRING_GAME_MENU(83), 'type : standard', 0.2, 1.0, 600 );
          SERVER_EXTENDED : SetString( STRING_GAME_MENU(83), 'type : extended', 0.2, 1.0, 600 );
     End;
     
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
     DrawString( STRING_GAME_MENU(83), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_MULTI_TYPE), IsActive(MENU_MULTI_TYPE), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
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
           If nMenu = MENU_MULTI_ADDRESS Then nMenu := MENU_MULTI_NAME Else
           If nMenu = MENU_MULTI_TYPE Then nMenu := MENU_MULTI_ADDRESS Else
           If nMenu = MENU_MULTI_JOIN Then nMenu := MENU_MULTI_TYPE Else
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
           If nMenu = MENU_MULTI_ADDRESS Then nMenu := MENU_MULTI_TYPE Else
           If nMenu = MENU_MULTI_TYPE Then nMenu := MENU_MULTI_JOIN Else
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
                        For k := 1 To 8 Do Begin
                            nPlayerType[k] := PLAYER_NIL;
                            nPlayerClient[k] := -1;
                        End;
                        InitMenu();
                        Send( nLocalIndex, HEADER_CONNECT, sLocalName );
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
                MENU_MULTI_TYPE :
                Begin
                     If nServerType = SERVER_EXTENDED Then nServerType := SERVER_STANDARD;
                     Case nServerType Of
                          SERVER_STANDARD : SetString( STRING_GAME_MENU(83), 'type : standard', 0.0, 0.02, 600 );
                          SERVER_EXTENDED : SetString( STRING_GAME_MENU(83), 'type : extended', 0.0, 0.02, 600 );
                     End;
                End;
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
                MENU_MULTI_TYPE :
                Begin
                     If nServerType = SERVER_STANDARD Then nServerType := SERVER_EXTENDED;
                     Case nServerType Of
                          SERVER_STANDARD : SetString( STRING_GAME_MENU(83), 'type : standard', 0.0, 0.02, 600 );
                          SERVER_EXTENDED : SetString( STRING_GAME_MENU(83), 'type : extended', 0.0, 0.02, 600 );
                     End;
                End;
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
           End;
           fKey := GetTime + 0.2;
           ClearInput();
        End;
     End Else Begin
        fKey := 0.0;
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
    pBomberman : CBomberman;
    pBomb : CBomb;
    fX, fY : Single;
    _nNetID : Integer;
Var k : Integer;
Begin
     While GetPacket( nIndex, nHeader, sData ) Do Begin
          Case nHeader Of
               HEADER_CONNECT :
               Begin
                    // ajout du client à la liste
                    If ClientIndex(nIndex) = -1 Then Begin
                       nClientIndex[nClientCount] := nIndex;
                       sClientName[nClientCount] := sData;
                       nClientCount += 1;
                       AddLineToConsole( sData + ' entered the game.' );
                    End;
                    // renvoi de la liste des clients
                    nIndex := nLocalIndex;
                    nHeader := HEADER_LIST_CLIENT;
                    sData := IntToStr(nClientCount);
                    For k := 0 To nClientCount - 1 Do
                        sData := sData + #31 + IntToStr(nClientIndex[k]) + #31 + sClientName[k];
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
                    sData := sData + IntToStr(nMap) + #31;
                    sData := sData + IntToStr(nRoundCount) + #31;
                    Send( nIndex, HEADER_SETUP, sData );
                    UpdateMenu();
               End;
               HEADER_DISCONNECT :
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
                           sPlayerName[k] := '';
                        End;
                    End;
                    // renvoi de la liste des clients
                    nIndex := nLocalIndex;
                    nHeader := HEADER_LIST_CLIENT;
                    sData := IntToStr(nClientCount);
                    For k := 0 To nClientCount - 1 Do
                        sData := sData + #31 + IntToStr(nClientIndex[k]) + #31 + sClientName[k];
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
                    UpdateMenu();
               End;
               HEADER_MESSAGE :
               Begin
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' says : ' + sData );
                    AddStringToScreen( sClientName[ClientIndex(nIndex)] + ' says : ' + sData );
                    Send( nIndex, nHeader, sData );
               End;
               HEADER_LOCK :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    nPlayerClient[k] := nIndex;
                    Send( nIndex, nHeader, sData );
                    UpdateMenu();
               End;
               HEADER_UNLOCK :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    nPlayerClient[k] := -1;
                    nPlayerType[k] := PLAYER_NIL;
                    Send( nIndex, nHeader, sData );
                    UpdateMenu();
               End;
               HEADER_PINGREQ :
               Begin
                    sData := '';
                    SendTo( nIndex, HEADER_PINGRES, sData );
               End;
               HEADER_PINGRES :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    fPlayerPing[k] := StrToFloat( GetString( sData, 2 ) );
                    sData := '';
                    For k := 1 To 8 Do Begin
                        sData := sData + FloatToStr(fPlayerPing[k]) + #31;
                    End;
                    Send( nIndex, HEADER_PINGARY, sData );
               End;
               HEADER_UPDATE :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    nPlayerType[k] := StrToInt( GetString( sData, 2 ) );
                    nPlayerSkill[k] := StrToInt( GetString( sData, 3 ) );
                    nPlayerCharacter[k] := StrToInt( GetString( sData, 4 ) );
                    sPlayerName[k] := GetString( sData, 5 );
                    Send( nIndex, nHeader, sData );
                    UpdateMenu();
               End;
               HEADER_MOVEUP :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, 2 ) );
                    fY := StrToFloat( GetString( sData, 3 ) );
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    pBomberman.Direction := 180;
                    pBomberman.LastDirN.x := 0;
                    pBomberman.LastDirN.y := -1;
               End;
               HEADER_MOVEDOWN :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, 2 ) );
                    fY := StrToFloat( GetString( sData, 3 ) );
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    pBomberman.Direction := 0;
                    pBomberman.LastDirN.x := 0;
                    pBomberman.LastDirN.y := 1;
               End;
               HEADER_MOVELEFT :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, 2 ) );
                    fY := StrToFloat( GetString( sData, 3 ) );
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    pBomberman.Direction := 90;
                    pBomberman.LastDirN.x := -1;
                    pBomberman.LastDirN.y := 0;
               End;
               HEADER_MOVERIGHT :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByIndex( k );
                    fX := StrToFloat( GetString( sData, 2 ) );
                    fY := StrToFloat( GetString( sData, 3 ) );
                    pBomberman.Position.x := fX;
                    pBomberman.Position.y := fY;
                    pBomberman.Direction := -90;
                    pBomberman.LastDirN.x := 1;
                    pBomberman.LastDirN.y := 0;
               End;
               HEADER_ACTION0 :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByIndex( k );
                    _nNetID := StrToInt( GetString( sData, 2 ) );
                    If Not ( pGrid.GetBlock( Trunc(pBomberman.Position.X + 0.5), Trunc(pBomberman.Position.Y + 0.5) ) Is CBomb ) Then Begin
                       pBomberman.CreateBomb(GetDelta, _nNetID);
                    End;
               End;
               HEADER_ACTION1 :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByIndex( k );
                    pBomberman.DoIgnition();
               End;
          End;
     End;
     
     If nGame = GAME_ROUND Then Begin
        sData := '';
        For k := 1 To 8 Do Begin
            pBomberman := GetBombermanByIndex( k );
            If pBomberman <> Nil Then Begin
               sData := sData + FloatToStr(pBomberman.Position.x) + #31;
               sData := sData + FloatToStr(pBomberman.Position.y) + #31;
               sData := sData + IntToStr(pBomberman.LastDirN.x) + #31;
               sData := sData + IntToStr(pBomberman.LastDirN.y) + #31;
            End;
        End;
        Send( nLocalIndex, HEADER_BOMBERMAN, sData );

        If GetBombCount() > 0 Then Begin
           sData := '';
           For k := 1 To GetBombCount() Do Begin
               pBomb := GetBombByCount( k );
               sData := sData + IntToStr(pBomb.nNetID) + #31;
               sData := sData + FloatToStr(pBomb.Position.x) + #31;
               sData := sData + FloatToStr(pBomb.Position.y) + #31;
           End;
           Send( nLocalIndex, HEADER_BOMB, sData );
        End;
    End;
End;



Procedure ProcessClient () ;
Var nIndex : DWord;
    nHeader : Integer;
    sData : String;
    sBuffer : String;
    pBomberman : CBomberman;
    pBomb : CBomb;
    fX, fY : Single;
    nX, nY : Integer;
    isBomb : Boolean;
    nBonus : Integer;
    _nNetID : Integer;
    sTemp : String;
Var k, l, m, i : Integer;
Begin
     While GetPacket( nIndex, nHeader, sData ) Do Begin
          Case nHeader Of
               HEADER_MESSAGE :
               Begin
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' says : ' + sData );
                    AddStringToScreen( sClientName[ClientIndex(nIndex)] + ' says : ' + sData );
               End;
               HEADER_LIST_CLIENT :
               Begin
                    l := 1;
                    nClientCount := StrToInt( GetString( sData, l ) ); l += 1;
                    For k := 0 To nClientCount - 1 Do Begin
                        nClientIndex[k] := StrToInt( GetString( sData, l ) ); l += 1;
                        sClientName[k] := GetString( sData, l ); l += 1;
                    End;
               End;
               HEADER_LIST_PLAYER :
               Begin
                    l := 1;
                    For k := 1 To 8 Do Begin
                        nPlayerClient[k] := StrToInt( GetString( sData, l ) ); l += 1;
                        sPlayerName[k] := GetString( sData, l ); l += 1;
                        nPlayerCharacter[k] := -1;
                        For m := 0 To nCharacterCount - 1 Do
                            If aCharacterList[m].Name = GetString( sData, l ) Then nPlayerCharacter[k] := m;
                        LoadCharacter( k ); l += 1;
                        nPlayerType[k] := StrToInt( GetString( sData, l ) ); l += 1;
                    End;
               End;
               HEADER_LOCK :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    nPlayerClient[k] := nIndex;
                    UpdateMenu();
               End;
               HEADER_UNLOCK :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    nPlayerClient[k] := -1;
                    nPlayerType[k] := PLAYER_NIL;
                    UpdateMenu();
               End;
               HEADER_UPDATE :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    nPlayerType[k] := StrToInt( GetString( sData, 2 ) );
                    nPlayerSkill[k] := StrToInt( GetString( sData, 3 ) );
                    nPlayerCharacter[k] := StrToInt( GetString( sData, 4 ) );
                    sPlayerName[k] := GetString( sData, 5 );
                    UpdateMenu();
               End;
               HEADER_SETUP :
               Begin
                    nScheme := StrToInt( GetString( sData, 1 ) );
                    nMap := StrToInt( GetString( sData, 2 ) );
                    nRoundCount := StrToInt( GetString( sData, 3 ) );
                    UpdateMenu();
               End;
               HEADER_FIGHT :
               Begin
                    nGame := GAME_INIT;
               End;
               HEADER_PINGRES :
               Begin
                    fPing := (GetTime - fPingTime) * 500;
                    sData := IntToStr(nPlayer) + #31;
                    sData := sData + FloatToStr(fPing) + #31;
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
                            If ( pGrid.GetBlock(k, l) Is CItem ) Then Begin
                               nBonus := StrToInt( GetString( sData, m ) );
                               m := m + 1;
                               Case nBonus Of
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
                                                                   numDisease[k,l] := StrToInt( GetString( sData, m ) );
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
                                                                   numDisease[k,l] := StrToInt( GetString( sData, m ) );
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
                              nX := StrToInt( GetString( sData, l ) ); l += 1;
                              nY := StrToInt( GetString( sData, l ) ); l += 1;
                              If nX = 1 Then pBomberman.Direction := -90
                              Else If nX = -1 Then pBomberman.Direction := 90
                              Else If nY = 1 Then pBomberman.Direction := 0
                              Else If nY = -1 Then pBomberman.Direction := 180;
                              pBomberman.LastDirN.x := nX;
                              pBomberman.LastDirN.y := nY;
                           End
                           Else Begin
                                l += 4;
                           End;
                        End;
                    End;
               End;
               HEADER_ACTION0 :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByIndex( k );
                    _nNetID := StrToInt( GetString( sData, 2 ) );
                    If ( Trunc(pBomberman.Position.X + 0.5) in [1..GRIDWIDTH] )
                    And ( Trunc(pBomberman.Position.X + 0.5) in [1..GRIDHEIGHT] )
                    And Not ( pGrid.GetBlock( Trunc(pBomberman.Position.X + 0.5), Trunc(pBomberman.Position.Y + 0.5) ) Is CBomb ) Then Begin
                       pBomberman.CreateBomb(GetDelta, _nNetID);
                    End;
               End;
               HEADER_ACTION1 :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByIndex( k );
                    pBomberman.DoIgnition();
               End;
               HEADER_WAIT :
               Begin
                    l := 1;
                    k := StrToInt( GetString( sData, l ) ); l += 1;
                    If k = -1 Then Begin
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
                           GetBombermanByCount(i).Score := StrToInt( GetString( sData, l ) ); l += 1;
                           GetBombermanByCount(i).Kills := StrToInt( GetString( sData, l ) ); l += 1;
                           GetBombermanByCount(i).Deaths := StrToInt( GetString( sData, l ) ); l += 1;
                       End;
                    End;
                    InitWait();
               End;
               HEADER_BOMB :
               Begin
                    l := 1;
                    While ( GetString( sData, l ) <> 'NULL' ) Do Begin
                        _nNetID := StrToInt( GetString( sData, l ) ); l += 1;
                        pBomb := GetBombByNetID( _nNetID );
                        If pBomb <> Nil Then Begin
                           fX := StrToFloat( GetString( sData, l ) ); l += 1;
                           fY := StrToFloat( GetString( sData, l ) ); l += 1;
                           pBomb.Position.x := fX;
                           pBomb.Position.y := fY;
                        End Else Begin
                            l += 2;
                        End;
                    End;
               End;
               HEADER_DEAD :
               Begin
                    k := StrToInt( GetString( sData, 1 ) );
                    pBomberman := GetBombermanByCount( k );
                    If ( pBomberman Is CBomberman ) Then
                       pBomberman.Alive := false;
               End;
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
          GAME_ROUND : ProcessGame();
          GAME_WAIT : ProcessWait();
          GAME_SCORE : ProcessScore();
     End;

     If nMulti = MULTI_SERVER Then Begin
        ProcessServer();
        If nState = PHASE_MENU Then ServerTerminate() Else ServerLoop();
     End Else If nMulti = MULTI_CLIENT Then Begin
        If nState = PHASE_MENU Then Send( nLocalIndex, HEADER_DISCONNECT, sLocalName );
        ProcessClient();
        If nState = PHASE_MENU Then ClientTerminate() Else ClientLoop();
     End;
End;





























End.

