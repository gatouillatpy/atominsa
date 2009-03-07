Program atominsa;

{$mode objfpc}{$H+}

Uses Classes, Forms, Interfaces, Graphics, SysUtils, IntfGraphics, Glut,
     UCore, UUtils, UBlock, UItem, UScheme, USpawn, UBomberman, UDisease,
     USpeedUp, UExtraBomb, UFlameUp, UGrid, UFlame, UBomb, USetup, UForm,
     UPractice, UMenu, UIntro, UEditor, UMulti, UGrab, uJelly, UJellyBomb,
     UListBomb, UPunch, USpoog, UGoldFlame, UTriggerBomb, UTrigger,
     USuperDisease, URandomBonus, UExplosion, UOnline, UNetwork;




Procedure Exit () ;
Begin
     DrawBox( 0.7, 0.4, 0.2, -0.4 );

     If GetKey(KEY_Y_LOWER) Or GetKey(KEY_Y_UPPER) Or DEDICATED_SERVER Then Begin
        If Not DEDICATED_SERVER Then Begin
            StopSound( SOUND_MENU_SELECT );

            FreeBomberman();
            FreeBomb();
            FreeFlame();
            FreeDataStack();
            FreeTimer();

            ExitFMod();
            ExitGlut();
        End;
        
        DO_NOT_RENDER := True;

        WriteSettings( 'atominsa.cfg' );

        Window.Memo.Destroy();

        Application.Terminate;

        Halt(0);
     End Else If GetKey(KEY_N_LOWER) Or GetKey(KEY_N_UPPER) Then Begin
         SetString( STRING_MENU_MAIN, ' ', 0.5, 0.1, 20 );

         PlaySound( SOUND_MENU_BACK );

         nState := PHASE_MENU;
     End;
End;



Procedure AskExit () ;
Begin
     InitBox( 'do you really want to quit ?', 'yes - no' );

     StopSound( SOUND_MENU );

     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     nState := STATE_EXIT;
End;



Procedure MainLoop () ; cdecl; // TODO : COUPER LE RENDU A PARTIR D'ICI
Begin
     Case nState Of
          PHASE_EXIT      : AskExit();
          STATE_EXIT      : Exit();
        //  PHASE_INTRO     : InitIntro();
        //  STATE_INTRO     : ProcessIntro();
          PHASE_MENU      : InitMenu();
          STATE_MENU      : ProcessMenu();
          PHASE_PRACTICE  : InitPractice();
          STATE_PRACTICE  : ProcessPractice();
          PHASE_EDITOR    : InitEditor();
          STATE_EDITOR    : ProcessEditor();
          PHASE_SETUP     : InitSetup();
          STATE_SETUP     : ProcessSetup();
          PHASE_MULTI     : InitMulti();
          STATE_MULTI     : ProcessMulti();
          PHASE_ONLINE    : InitMenuOnline();
          STATE_ONLINE    : ProcessMenuOnline();
          REFRESH_ONLINE  : ProcessClientOnline();
          PHASE_NETWORK   : InitMenuNetwork();
          STATE_NETWORK   : ProcessMenuNetwork();
     End;
     Application.ProcessMessages;
End;



Procedure ExecNormal () ;
Var k : Integer;
Begin
     DO_NOT_RENDER := False;

     // création de la pile de données
     InitDataStack();

     // initialisation de FMod
     InitFMod();

     InitGlut( 'atominsa - Game', @MainLoop );

     // chargement du masque des zones du menu principal
     Window.Mask.Picture.Bitmap.LoadFromFile( './textures/mask.bmp' );
     MaskIntfImg := TLazIntfImage.Create(0,0);
     MaskIntfImg.LoadFromBitmap( Window.Mask.Picture.Bitmap.Handle, Window.Mask.Picture.Bitmap.MaskHandle );

     // chargement des meshes relatifs aux blocs et bonus
     AddMesh( './meshes/disease.m12', MESH_DISEASE, False );
     AddMesh( './meshes/extrabomb.m12', MESH_EXTRABOMB, False );
     AddMesh( './meshes/flameup.m12', MESH_FLAMEUP, False );
     AddMesh( './meshes/speedup.m12', MESH_SPEEDUP, False );

     // chargement des sprites relatifs au menu
     AddTexture( './textures/back.jpg', SPRITE_MENU_BACK );
     AddTexture( './textures/mainbt0.jpg', SPRITE_MENU_MAIN_BUTTON0 );
     AddTexture( './textures/mainbt1.jpg', SPRITE_MENU_MAIN_BUTTON1 );
     AddTexture( './textures/mainbt2.jpg', SPRITE_MENU_MAIN_BUTTON2 );
     AddTexture( './textures/mainbt3.jpg', SPRITE_MENU_MAIN_BUTTON3 );
     AddTexture( './textures/mainbt4.jpg', SPRITE_MENU_MAIN_BUTTON4 );
     AddTexture( './textures/mainbt5.jpg', SPRITE_MENU_MAIN_BUTTON5 );
     AddTexture( './textures/cross.jpg', SPRITE_MENU_CROSS );
     AddTexture( './maps/night/sb-front.jpg', SPRITE_BACK );

     // chargement des polices de caractères
     AddTexture( './textures/charset0.jpg', SPRITE_CHARSET_TERMINAL );
     AddTexture( './textures/charset0x.jpg', SPRITE_CHARSET_TERMINALX );
     AddTexture( './textures/charset1.jpg', SPRITE_CHARSET_DIGITAL );

     // chargement des images de l'intro
    { If bIntro Then Begin
        For k := 0 To 21 Do
            AddTexture( Format('./textures/layer%d.jpg', [k]), SPRITE_INTRO_LAYER(k) );
     End; }

     // chargement des sons du menu
     AddSound( './sounds/move.wav', SOUND_MENU_MOVE, False );
     AddSound( './sounds/select.wav', SOUND_MENU_SELECT, False );
     AddSound( './sounds/back.wav', SOUND_MENU_BACK, False );
     AddSound( './sounds/click.wav', SOUND_MENU_CLICK, False );

     // chargement du son de l'invite de messages
     AddSound( './sounds/message.wav', SOUND_MESSAGE, False );

     // chargement de la musique du menu
     AddSound( './musics/menu.mp3', SOUND_MENU, False );

     // chargement des bombermen
     For k := 1 To 8 Do Begin
         If nPlayerCharacter[k] = -1 Then Begin
            pPlayerCharacter[k] := aCharacterList[Trunc(Random(nCharacterCount))];
         End Else Begin
             pPlayerCharacter[k] := aCharacterList[nPlayerCharacter[k]];
         End;
         AddMesh( './characters/' + pPlayerCharacter[k].PlayerMesh, MESH_BOMBERMAN(k), False );
         AddMesh( './characters/' + pPlayerCharacter[k].BombMesh, MESH_BOMB(k), False );
         AddTexture( './characters/' + pPlayerCharacter[k].PlayerSkin[k], TEXTURE_BOMBERMAN(k) );
         AddTexture( './characters/' + pPlayerCharacter[k].BombSkin, TEXTURE_BOMB(k) );
         AddTexture( './characters/' + pPlayerCharacter[k].FlameTexture, TEXTURE_FLAME(k) );
         AddSound( './characters/' + pPlayerCharacter[k].BombSound[1], SOUND_BOMB(10+k), False );
         AddSound( './characters/' + pPlayerCharacter[k].BombSound[2], SOUND_BOMB(20+k), False );
         AddSound( './characters/' + pPlayerCharacter[k].BombSound[3], SOUND_BOMB(30+k), False );
         AddAnimation( './characters/' + pPlayerCharacter[k].PlayerAnim, ANIMATION_BOMBERMAN(k), MESH_BOMBERMAN(k), False );
     End;

     InitShaderProgram();

     // initialisation de la machine d'état
    // If bIntro Then Begin
    //    nState := PHASE_INTRO;
    // End Else Begin
        nState := PHASE_MENU;
    // End;

     // définition de la touche pour le passage en plein écran
     BindKeyStd( nKeyScreen, True, True, @SwitchDisplay );

     ExecGlut();
End;

Procedure ExecServer () ;
Var nIndex, nHeader : Integer;
    sData : String;
    nDelay : Integer;
Begin
     AddLineToConsole( 'Mode dedicated server.' );

     nState := PHASE_MENU;

     nDelay := 1000 Div nFramerate;
     
     // attente des infos du master server
     While True Do Begin
           MainLoop();
           Delay( nDelay );
     End;
End;



Begin
     // initialisation de l'application
     Application.Initialize;
     Application.CreateForm( TWindow, Window );

     // affichage de la console
     Window.Show();

     // initialisation du générateur de nombres aléatoires
     Randomize();
     
     // lecture du fichier atominsa.cfg
     ReadSettings( 'atominsa.cfg' );

     DEDICATED_SERVER := False;
     If ParamCount() = 1 Then Begin
        If CompareStr( ParamStr(1), '/server' ) = 0 Then Begin
           DEDICATED_SERVER := True;
        End;
     End;
     
     If DEDICATED_SERVER Then Begin
        ExecServer();
     End Else Begin
        ExecNormal();
     End;
End.

