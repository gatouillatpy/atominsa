Unit UOnline;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UMap, UScheme, UCharacter, UForm;



Var nServerCount : Integer;
    sServerIP : Array [2..255] Of String;
    sServerName : Array[2..255] Of String;



Procedure InitMenuOnline () ;
Procedure ProcessMenuOnline () ;
Procedure ProcessClientOnline () ;



Implementation



Uses UCore, USetup, UMulti;



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
     SetString( STRING_SETUP_MENU(1), 'manual connection', 0.2, 1.0, 600 );
     {
     If Not ClientInit( sMasterAddress, nMasterPort ) Then Begin
        nState := PHASE_MULTI;
        Exit;
     End;
     }
     
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
    x, y, z : Integer;
    t : Single;
    i : Integer;
Begin

     w := GetRenderWidth();
     h := GetRenderHeight();

     DrawString( STRING_SETUP_MENU(0), -w / h * 0.5,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.0;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(1), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(1), IsActive(1), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     t += 0.2;
     For i := 2 To nServerCount + 1 Do Begin
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
              nMenu := nServerCount + 1;
           End;

           t := 0.0;
           If (nMenu = 1) And (fScroll > t) Then fScroll := t; t += 0.2;
           t += 0.2;
           For i := 2 To nServerCount - 6 Do Begin
               If (nMenu = i) And (fScroll > t) Then fScroll := t; t += 0.2;
           End;
           t -= 0.2;
           If (nMenu = nServerCount + 1) Then fScroll := t;
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;


     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           
           nMenu := nMenu + 1;
           If ( nMenu = nServerCount + 2 ) Then Begin
              nMenu := 1;
           End;

           t := 0.0;
           If nMenu = 1 Then fScroll := t;
           t += 0.2;
           For i := 8 To nServerCount + 1 Do Begin
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
           Else Begin
                // TODO: Transférer l'IP et le nom.
                nState := STATE_MULTI;
           End;
        End;
        bEnter := True;
     End Else Begin
        bEnter := False;
     End;
End;





Procedure ProcessClientOnline () ;
Var nIndex : DWord;
    nHeader : Integer;
    sData : String;
Var k, l : Integer;
Begin
     l := 20;
     For k := 1 To l Do Begin
         sServerName[k+1] := 'Server ' + IntToStr(k);
         SetString( STRING_SETUP_MENU(k+1), sServerName[k+1], 0.2, 1.0, 600 );
     End;
     nServerCount := l;
     nState := STATE_ONLINE;
     fScroll := 0.0;
     
{
     ClientLoop();

     While GetPacket( nIndex, nHeader, sData ) Do Begin
          Case nHeader Of
               HEADER_SERVER :
               Begin
                    l := 1;
                    TryStrToInt( GetString( sData, l ), nServerCount ); l += 1;
                    For k := 2 To nServerCount + 1 Do Begin
                        sServerName[k] := GetString( sData, l ); l += 1;
                        sServerIP[k] := GetString( sData, l ); l += 1;
                        SetString( STRING_SETUP_MENU(k), sServerName[k], 0.2, 1.0, 600 );
                    End;
                    nState := STATE_ONLINE;
                    fScroll := 0.0;
               End;
          End;
     End;
}
End;




End.
