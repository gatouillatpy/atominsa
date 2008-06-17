Unit UOnline;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UMap, UScheme, UCharacter, UForm;



Var nServerCount : Integer;
    sServerIP : Array [0..255] Of String;
    sServerName : Array[0..255] Of String;



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


     SetString( STRING_SETUP_MENU(-2), 'online', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(-1), 'manual connection', 0.2, 1.0, 600 );
     
     If Not ClientInit( sMasterAddress, nMasterPort ) Then Begin
        nState := PHASE_MULTI;
        Exit;
     End;
{
     SetString( STRING_SETUP_MENU(11), 'show intro : ' + BoolToStr(bIntro), 0.2, 1.0, 600 );

     SetString( STRING_SETUP_MENU(21), 'desired framerate : ' + IntToStr(nFramerate), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(22), 'lighting : ' + BoolToStr(bLighting), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(23), 'shadowing : ' + BoolToStr(bShadowing), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(24), 'reflection : ' + BoolToStr(bReflection), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(25), 'effects : ' + BoolToStr(bEffects), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(26), 'blur : ' + BoolToStr(bBlur), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(27), 'texturing quality : ' + IntToStr(nTexturing), 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(28), 'shader model : ' + IntToStr(nShaderModel), 0.2, 1.0, 600 );

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
}
     nMenu := -1;

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
               If nConst = nMenu Then IsActive := 0.0 Else IsActive := 1.0;
          End;
Var w, h : Single;
    x, y, z : Integer;
    t : Single;
    i : Integer;
Begin

     w := GetRenderWidth();
     h := GetRenderHeight();

     DrawString( STRING_SETUP_MENU(-2), -w / h * 0.5,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.0;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(-1), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(-1), IsActive(-1), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     t += 0.2;
     For i := 0 To nServerCount - 1 Do Begin
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

           nMenu := nMenu + 1;
           If ( nMenu = nServerCount ) Then Begin
              nMenu := - 1;
           End;

           t := 0.0;
           If (nMenu = -1) And (fScroll > t) Then fScroll := t; t += 0.2;
           t += 0.2;
           For i := 0 To nServerCount - 2 Do Begin
               If (nMenu = i) And (fScroll > t) Then fScroll := t; t += 0.2;
           End;
           t -= 0.2;
           If (nMenu = nServerCount - 1) Then fScroll := t;
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;


     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           
           nMenu := nMenu - 1;
           If ( nMenu = -2 ) Then Begin
              nMenu := nServerCount - 1;
           End;

           t := 0.0;
           If nMenu = -1 Then fScroll := 0.0;
           t += 0.2;
           For i := 1 To nServerCount - 1 Do Begin
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
           If (nMenu = -1) Then Begin
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
     While GetPacket( nIndex, nHeader, sData ) Do Begin
          Case nHeader Of
               HEADER_SERVER :
               Begin
                    l := 1;
                    nServerCount := StrToInt( GetString( sData, l ) ); l += 1;
                    For k := 0 To nServerCount - 1 Do Begin
                        sServerName[k] := GetString( sData, l ); l += 1;
                        sServerIP[k] := GetString( sData, l ); l += 1;
                        SetString( STRING_SETUP_MENU(k), sServerName[k], 0.2, 1.0, 600 );
                    End;
                    nState := STATE_ONLINE;
               End;
          End;
     End;
End;




End.
