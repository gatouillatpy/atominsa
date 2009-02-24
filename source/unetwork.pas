Unit UNetwork;

{$mode objfpc}{$H+}



Interface

Uses Classes, SysUtils, UUtils, UCore, UGame, USetup;



Procedure InitMenuNetwork() ;
Procedure ProcessMenuNetwork () ;



Implementation

Uses UForm;


Var fScroll : Single;

Var nMenu  : Integer;

Var bUp     : Boolean;
Var bDown   : Boolean;
Var bLeft   : Boolean;
Var bRight  : Boolean;
Var bEnter  : Boolean;
Var bEscape : Boolean;



Procedure InitMenuNetwork () ;
Var i : Integer;
Begin
     sHiddenPassword := '';
     For i := 1 To Length( sUserPassword ) Do
         sHiddenPassword := sHiddenPassword + '*';
     SetString( STRING_SETUP_MENU(0), 'network', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(1), 'lan mode', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(2), 'online mode', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(3), 'name: ', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(4), sUserName, 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(5), 'password: ', 0.2, 1.0, 600 );
     SetString( STRING_SETUP_MENU(6), sHiddenPassword, 0.2, 1.0, 600 );

     nMenu := 1;

     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     bEscape := False;

     nState := STATE_NETWORK;
End;



Procedure ProcessMenuNetwork () ;
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
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(3), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(3), IsActive(3), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(4), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(4), IsActive(4), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(5), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(5), IsActive(5), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;
     If fScroll <= t Then DrawString( STRING_SETUP_MENU(6), -w / h * 0.5, 0.6 + fScroll - t, -1, 0.024 * w / h, 0.032, 1.0, IsActive(6), IsActive(6), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.2;


     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;


     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           
           If (nMenu = 4) Then SetString( STRING_SETUP_MENU(4), sUserName, 0.0, 0.02, 600 );

           nMenu := nMenu - 1;
           If ( nMenu = 0 ) Then Begin
              nMenu := 6;
           End;

           t := 0.0;
           If (nMenu = 1) And (fScroll > t) Then fScroll := t; t += 0.2;
           
           If (nMenu = 6) Then
              SetString( STRING_SETUP_MENU(6), sUserPassword, 0.0, 0.02, 600 )
           Else
               SetString( STRING_SETUP_MENU(6), sHiddenPassword, 0.0, 0.02, 600 );
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;


     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           
           If (nMenu = 4) Then SetString( STRING_SETUP_MENU(4), sUserName, 0.0, 0.02, 600 );

           nMenu := nMenu + 1;
           If ( nMenu = 7 ) Then Begin
              nMenu := 1;
           End;

           t := 0;
           If (nMenu = 1) Then fScroll := 0.0;
           
           If (nMenu = 6) Then
              SetString( STRING_SETUP_MENU(6), sUserPassword, 0.0, 0.02, 600 )
           Else
               SetString( STRING_SETUP_MENU(6), sHiddenPassword, 0.0, 0.02, 600 );
        End;
        bDown := True;
     End Else Begin
        bDown := False;
     End;



     If GetKey( KEY_ENTER ) Then Begin
        If Not bEnter Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                1 : nState := PHASE_MULTI;
                2 : nState := PHASE_ONLINE;
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
                4 :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        SetLength(sUserName, Length(sUserName) - 1);
                     End Else Begin
                        sUserName := sUserName + CheckKey();
                     End;
                     SetString( STRING_SETUP_MENU(4), sUserName, 0.0, 0.02, 600 );
                End;
                6 :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        SetLength(sUserPassword, Length(sUserPassword) - 1);
                        SetLength(sHiddenPassword, Length(sHiddenPassword) - 1);
                     End Else Begin
                        sUserPassword := sUserPassword + CheckKey();
                        sHiddenPassword := sHiddenPassword + '*';
                     End;
                     SetString( STRING_SETUP_MENU(6), sUserPassword, 0.0, 0.02, 600 );
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
                4 :
                Begin
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 0 ) Then
                        SetString( STRING_SETUP_MENU(4), sUserName, 0.0, 0.02, 600 );
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 1 ) Then
                        SetString( STRING_SETUP_MENU(4), sUserName + '*', 0.0, 0.02, 600 );
                     bCursor := False;
                End;
                6 :
                Begin
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 0 ) Then
                        SetString( STRING_SETUP_MENU(6), sUserPassword, 0.0, 0.02, 600 );
                     If ( bCursor ) And ( Trunc(fCTime*2) mod 2 = 1 ) Then
                        SetString( STRING_SETUP_MENU(6), sUserPassword + '*', 0.0, 0.02, 600 );
                     bCursor := False;
                End;
           End;
End;




end.

