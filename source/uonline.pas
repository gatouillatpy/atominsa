Unit UOnline;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UMap, UScheme, UCharacter, UForm, UMulti;



Var nServerCount : Integer;
    nPlayableCount : Integer;
    sServerIP : Array [2..255] Of String;
    sServerPort : Array [2..255] Of Integer;
    sServerName : Array[2..255] Of String;
    nNbrPlayers : Array[2..255] Of Integer;



Procedure InitMenuOnline () ;
Procedure ProcessMenuOnline () ;
Procedure ProcessClientOnline () ;



Implementation



Uses UCore, USetup, UGame;



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


     SetString( STRING_SETUP_MENU(0), 'online', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(1), 'host (name):', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(2), sLocalName, 0.2, 1.0, 600 );

     If Not ClientInitOnline( sMasterAddress, nMasterPort ) Then Begin
        nState := PHASE_MULTI;
        Exit;
     End;

     bOnline := True;
     nMenu := 1;

     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     bEscape := False;

     nState := REFRESH_ONLINE;
End;



Procedure ProcessMenuOnline () ;
          Function IsActive( nConst : Integer ) : Single ;
          Begin
               If nConst = nMenu Then IsActive:= 0.0 Else IsActive := 1.0;
          End;
Var w, h : Single;
    k, x, y, z : Integer;
    t : Single;
    i, j, l, m : Integer;
    nIndex, nHeader : Integer;
    b1, b2 : Boolean;
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

     DrawString( STRING_SETUP_MENU(0), -w / h * 0.5,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.0;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(1), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(1), IsActive(1), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(2), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(2), IsActive(2), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     t += 0.2;
     For i := 3 To nPlayableCount + 2 Do Begin
         If fScroll <= t Then DrawString( STRING_SETUP_MENU(i), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(i), IsActive(i), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     End;
     If ( nPlayableCount < nServerCount ) And ( nPlayableCount <> 0 ) Then t += 0.2;
     For i := nPlayableCount + 3 To nServerCount + 2 Do Begin
         If fScroll <= t Then DrawString( STRING_SETUP_MENU(i), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 0.5, IsActive(i), IsActive(i), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     End;

     
     
     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;


     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           
           If ( nMenu = 2 ) Then SetString( STRING_SETUP_MENU(2), sLocalName, 0.0, 0.02, 600 );

           nMenu := nMenu - 1;
           If ( nMenu = 0 ) Then Begin
              nMenu := nServerCount + 2;
           End;

           b1 := nServerCount > 0;
           b2 := (nServerCount - nPlayableCount > 0) And (nPlayableCount > 0);
           t := 0.0;
           If (nMenu = 1) And (fScroll > t) Then fScroll := t;
           j := nServerCount - 6;
           If b1 Then j += 1;
           If b2 Then j += 1;
           l := 1;
           For i := 1 To j Do Begin
               If (b1 And (i = 3)) Or (b2 And (i = nPlayableCount + 4)) Then t += 0.2
               Else Begin
                    If (nMenu = l) And (fScroll > t) Then fScroll := t; t += 0.2;
                    l += 1;
               End;
           End;
           If (nMenu = nServerCount + 2) Then fScroll := t;
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;


     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           
           If ( nMenu = 2 ) Then SetString( STRING_SETUP_MENU(2), sLocalName, 0.0, 0.02, 600 );
           
           nMenu := nMenu + 1;
           If ( nMenu = nServerCount + 3 ) Then Begin
              nMenu := 1;
           End;

           t := 0.0;
           b1 := nServerCount > 0;
           b2 := (nServerCount - nPlayableCount > 0) And (nPlayableCount > 0);

           If nMenu = 1 Then fScroll := t;
           t += 0.2;
           j := 9;
           m := nServerCount + 2;
           If b1 Then j -= 1;
           If b2 And (nPlayableCount + 4 < j) Then j -= 1;
           If b2 And (nPlayableCount + 4 >= j) Then m += 1;
           l := j;
           For i := j To m Do Begin
               If b2 And (i = nPlayableCount + 3) Then t += 0.2
               Else Begin
                    If (nMenu = l) And (fScroll < t) Then fScroll := t; t += 0.2;
                    l += 1;
               End;
           End;
        End;
        bDown := True;
     End Else Begin
        bDown := False;
     End;



     If GetKey( KEY_ENTER ) Or DEDICATED_SERVER Then Begin
        If Not bEnter Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If (nMenu = 1) Or (nMenu = 2) Or DEDICATED_SERVER Then Begin
                nIndex := nLocalIndex;
                nHeader := HEADER_ONLINE_HOST;
                sData := sServerAddress + #31;
                sData += IntToStr( nServerPort ) + #31;
                sData += sLocalName + #31;
                If bOnline Then
                   SendOnline( nIndex, nHeader, sData );
                nState := STATE_MULTI;
                // désactivation de la souris
                BindButton( BUTTON_LEFT, NIL );
                // activation du mode multi
                bMulti := True;
                bOnline := True;
                bGoToPhaseMenu := False;
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
                    // bClientBtnReady[0] := True;
                    bLocalReady := False;
                    InitMenu();
                End;
           End
           Else Begin
                nState := STATE_MULTI;
                // désactivation de la souris
                BindButton( BUTTON_LEFT, NIL );
                // activation du mode multi
                bMulti := True;
                bOnline := True;
                bGoToPhaseMenu := False;
                // initialisation du compteur de clients
                nClientCount := 0;
                If ClientInit( sServerIP[nMenu], sServerPort[nMenu] ) Then Begin
                  nMulti := MULTI_CLIENT;
                  For k := 1 To 8 Do Begin
                      nPlayerType[k] := PLAYER_NIL;
                      nPlayerClient[k] := -2;
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
           ClearInput();
        End;
        bEnter := True;
     End Else Begin
        bEnter := False;
     End;
     
     If Ord(CheckKey()) > 0 Then Begin
        If GetTime > fKey Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                2 :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        SetLength(sLocalName, Length(sLocalName) - 1);
                     End Else Begin
                        sLocalName := sLocalName + CheckKey();
                     End;
                     SetString( STRING_SETUP_MENU(2), sLocalName, 0.0, 0.02, 600 );
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
                2 :
                Begin
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 0 ) Then
                        SetString( STRING_SETUP_MENU(2), sLocalName, 0.0, 0.02, 600 );
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 1 ) Then
                        SetString( STRING_SETUP_MENU(2), sLocalName + '*', 0.0, 0.02, 600 );
                     bCursor := False;
                End;
           End;
End;





Procedure ProcessClientOnline () ;
Var nIndex : DWord;
    nHeader : Integer;
    sData : String;
Var k, l : Integer;
Begin
   {
     l := Random(19);
     For k := 1 To l Do Begin
         sServerName[k+2] := 'Server ' + IntToStr(k);
         SetString( STRING_SETUP_MENU(k+2), sServerName[k+2], 0.2, 1.0, 600 );
     End;
     nServerCount := l;
     Repeat
           nPlayableCount := Random(19);
     Until ( nPlayableCount <= nServerCount );
     nState := STATE_ONLINE;
     fScroll := 0.0;
   }
     ClientLoopOnline();
     While GetPacket( nIndex, nHeader, sData ) Do Begin
          Case nHeader Of
               HEADER_SERVER :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), nPlayableCount ); l += 1;
                    For k := 3 To nPlayableCount + 2 Do Begin
                        sServerName[k] := GetString( sData, l ); l += 1;
                        sServerIP[k] := GetString( sData, l ); l += 1;
                        TryStrToInt( GetString( sData, l ), sServerPort[k] ); l += 1;
                        TryStrToInt( GetString( sData, l ), nNbrPlayers[k] ); l += 1;
                        SetString( STRING_SETUP_MENU(k), sServerName[k] + ' [' + IntToStr( nNbrPlayers[k] ) + ']', 0.2, 1.0, 600 );
                    End;
                    TryStrToInt( GetString( sData, l ), k ); l += 1;
                    nServerCount := k + nPlayableCount;
                    For k := nPlayableCount + 3 To nServerCount + 2 Do Begin
                        sServerName[k] := GetString( sData, l ); l += 1;
                        sServerIP[k] := GetString( sData, l ); l += 1;
                        TryStrToInt( GetString( sData, l ), sServerPort[k] ); l += 1;
                        TryStrToInt( GetString( sData, l ), nNbrPlayers[k] ); l += 1;
                        SetString( STRING_SETUP_MENU(k), sServerName[k] + ' [' + IntToStr( nNbrPlayers[k] ) + ']', 0.2, 1.0, 600 );
                    End;
                    nState := STATE_ONLINE;
                    fScroll := 0.0;
               End;
          End;
     End;
End;




End.
