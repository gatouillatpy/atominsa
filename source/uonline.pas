Unit UOnline;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UMap, UScheme, UCharacter, UForm, UMulti;



Var nServerCount : Integer;
    sServerIP : Array [2..255] Of String;
    sServerName : Array[2..255] Of String;



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
     SetString( STRING_SETUP_MENU(1), 'lan connection', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(2), 'host : ' + sLocalName, 0.2, 1.0, 600 );

     If Not ClientInitOnline( sMasterAddress, nMasterPort ) Then Begin
        nState := PHASE_MULTI;
        Exit;
     End;

     
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
    i : Integer;
    nIndex, nHeader : Integer;
    sData : String;
Begin

     w := GetRenderWidth();
     h := GetRenderHeight();

     DrawString( STRING_SETUP_MENU(0), -w / h * 0.5,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.0;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(1), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(1), IsActive(1), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(2), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(2), IsActive(2), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     t += 0.2;
     For i := 3 To nServerCount + 2 Do Begin
         If fScroll <= t Then DrawString( STRING_SETUP_MENU(i), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(i), IsActive(i), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;

     End;
     
     
     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;


     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );

           nMenu := nMenu - 1;
           If ( nMenu = 0 ) Then Begin
              nMenu := nServerCount + 2;
           End;

           t := 0.0;
           If (nMenu = 1) And (fScroll > t) Then fScroll := t; t += 0.2;
           If (nMenu = 2) And (fScroll > t) Then fScroll := t; t += 0.2;
           t += 0.2;
           For i := 3 To nServerCount - 6 Do Begin
               If (nMenu = i) And (fScroll > t) Then fScroll := t; t += 0.2;
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
           
           nMenu := nMenu + 1;
           If ( nMenu = nServerCount + 3 ) Then Begin
              nMenu := 1;
           End;

           t := 0.0;
           If nMenu = 1 Then fScroll := t;
           t += 0.2;
           For i := 8 To nServerCount + 2 Do Begin
               If (nMenu = i) And (fScroll < t) Then fScroll := t; t += 0.2;
           End;
        End;
        bDown := True;
     End Else Begin
        bDown := False;
     End;



     If GetKey( KEY_ENTER ) Then Begin
        If Not bEnter Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If (nMenu = 1) Then Begin
               nState := PHASE_MULTI;
           End
           Else If (nMenu = 2) Then Begin
                nIndex := nLocalIndex;
                nHeader := HEADER_ONLINE_HOST;
                sData := sLocalName + #31;
                SendOnline( nIndex, nHeader, sData );
                nState := STATE_MULTI;
                // désactivation de la souris
                BindButton( BUTTON_LEFT, NIL );
                // activation du mode multi
                bMulti := True;
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
                    InitMenu();
                End;
           End
           Else Begin
                nState := STATE_MULTI;
                // désactivation de la souris
                BindButton( BUTTON_LEFT, NIL );
                // activation du mode multi
                bMulti := True;
                bGoToPhaseMenu := False;
                // initialisation du compteur de clients
                nClientCount := 0;
                If ClientInit( sServerIP[ nMenu ], nServerPort ) Then Begin
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
                     SetString( STRING_SETUP_MENU(2), 'host : ' + sLocalName, 0.0, 0.02, 600 );
                End;
           End;
           fKey := GetTime + 0.2;
           ClearInput();
        End;
     End Else Begin
        fKey := 0.0;
     End;
End;





Procedure ProcessClientOnline () ;
Var nIndex : DWord;
    nHeader : Integer;
    sData : String;
Var k, l : Integer;
Begin
{
     l := 20;
     For k := 1 To l Do Begin
         sServerName[k+2] := 'Server ' + IntToStr(k);
         SetString( STRING_SETUP_MENU(k+2), sServerName[k+2], 0.2, 1.0, 600 );
     End;
     nServerCount := l;
     nState := STATE_ONLINE;
     fScroll := 0.0;
}
     ClientLoopOnline();

     While GetPacket( nIndex, nHeader, sData ) Do Begin
          Case nHeader Of
               HEADER_SERVER :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), nServerCount ); l += 1;
                    For k := 3 To nServerCount + 2 Do Begin
                        sServerName[k] := GetString( sData, l ); l += 1;
                        sServerIP[k] := GetString( sData, l ); l += 1;
                        SetString( STRING_SETUP_MENU(k), sServerName[k], 0.2, 1.0, 600 );
                    End;
                    nState := STATE_ONLINE;
                    fScroll := 0.0;
               End;
          End;
     End;
End;




End.
