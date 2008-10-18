Unit UMulti;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils, UJellyBomb, UPunch, USpoog, UGoldFLame, UTrigger, UTriggerBomb, USuperDisease,
     UCore, UGame, UUtils, USetup, UForm, UExtraBomb, UFlameUp, UKick, UGrab, UJelly, UDisease, USpeedUp;



Var nClientCount : Integer;
Var nClientIndex : Array [0..255] Of Integer;
Var sClientName : Array [0..255] Of String;
Var bClientReady : Array [0..255] Of Boolean;
Var fPingTime, fPing : Single;



Procedure InitMulti () ;
Procedure ProcessMulti () ;

Function ClientIndex( nIndex : DWord ) : Integer ;
Function GetString ( sData : String ; nString : Integer ) : String ;



Implementation

Uses UBomberman, UListBomb, UBomb, UBlock, UItem, UGrid;



Const MULTI_NONE       = 0;
Const MULTI_SERVER     = 1;
Const MULTI_CLIENT     = 2;
Const MULTI_ERROR      = 3;

Var nMulti : Integer;



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
    pBomberman, pSecondBomberman : CBomberman;
    pBomb : CBomb;
    fX, fY : Single;
    dt : Single;
    nBombSize, nDirection : Integer;
    fBombTime : Single;
    _nNetID : Integer;
    aX, aY, dX, dY : Integer;
Var k, l : Integer;
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
                    sData := sData + IntToStr(nSchemeMulti) + #31;
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
                    If ( nCame = GAME_MENU ) Or ( nGame = GAME_MENU_PLAYER ) Or ( nGame = GAME_MENU_MULTI ) Then UpdateMenu();
               End;
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
                    UpdateMenu();
               End;
               HEADER_UNLOCK :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
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
                    UpdateMenu();
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
                    If Not ( GetBombByNetID( _nNetId ) Is CBomb ) Then Begin
                        pBomberman.CreateBombMulti( fX, fY, nBombSize, fBombTime, _nNetID );
                    End;
               End;
               HEADER_ACTION1 :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    pBomberman.DoIgnition();
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
                    TryStrToInt( GetString( sData, l ), nClientCount ); l += 1;
                    For k := 0 To nClientCount - 1 Do Begin
                        TryStrToInt( GetString( sData, l ), nClientIndex[k] ); l += 1;
                        sClientName[k] := GetString( sData, l ); l += 1;
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
                        LoadCharacter( k ); l += 1;
                        TryStrToInt( GetString( sData, l ), nPlayerType[k] ); l += 1;
                    End;
               End;
               HEADER_LOCK :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    nPlayerClient[k] := nIndex;
                    UpdateMenu();
               End;
               HEADER_UNLOCK :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    nPlayerClient[k] := -1;
                    nPlayerType[k] := PLAYER_NIL;
                    UpdateMenu();
               End;
               HEADER_UPDATE :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    TryStrToInt( GetString( sData, 2 ), nPlayerType[k] );
                    TryStrToInt( GetString( sData, 3 ), nPlayerSkill[k] );
                    TryStrToInt( GetString( sData, 4 ), nPlayerCharacter[k] );
                    sPlayerName[k] := GetString( sData, 5 );
                    UpdateMenu();
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
                        bClientReady[ClientIndex(nIndex)] := False;
                    End;
                    nGame := GAME_INIT;
               End;
               HEADER_READY :
               Begin
                    bClientReady[ClientIndex(nIndex)] := True;
                    AddLineToConsole( sClientName[ClientIndex(nIndex)] + ' is ready.' );
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
                    End;
               End;
               HEADER_ACTION1 :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    pBomberman.DoIgnition();
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
                       pBlock.ExploseMulti();
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
                       (pBlock As CItem).bIsExplosedMulti := True;
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
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    If ( pBomberman.uGrabbedBomb <> Nil ) Then Begin
                        pBomberman.uGrabbedBomb.Position.X := pBomberman.Position.X;
                        pBomberman.uGrabbedBomb.Position.Y := pBomberman.Position.Y;
                        pBomberman.uGrabbedBomb.StartTime();
                        pBomberman.uGrabbedBomb.Position.Z := 0;
                        pBomberman.uGrabbedBomb.JumpMovement := True;
                        pBomberman.uGrabbedBomb := Nil;
                    End;
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
                    While ( GetString( sData, l ) <> 'NULL' ) Do Begin
                        TryStrToInt( GetString( sData, l ), _nNetID ); l += 1;
                        pBomb := GetBombByNetID( _nNetID );
                        If pBomb <> Nil Then Begin
                           fX := StrToFloat( GetString( sData, l ) ); l += 1;
                           fY := StrToFloat( GetString( sData, l ) ); l += 1;
                           fZ := StrToFloat( GetString( sData, l ) ); l += 1;
                           pBomb.Position.x := fX;
                           pBomb.Position.y := fY;
                           pBomb.Position.z := fZ;
                           pBomb.xGrid := Trunc( fX );
                           pBomb.yGrid := Trunc( fY );
                        End Else Begin
                            l += 3;
                        End;
                    End;
               End;
               HEADER_DEAD :
               Begin
                    TryStrToInt( GetString( sData, 1 ), k );
                    pBomberman := GetBombermanByIndex( k );
                    If ( pBomberman Is CBomberman ) Then
                       pBomberman.Alive := false;
               End;
               HEADER_QUIT_GAME :
               Begin
                    InitMenu();
                    ClearInput();
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
          GAME_SYNCHRO : SynchroGame();
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

