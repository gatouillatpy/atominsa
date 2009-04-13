Program atominsa;

{$mode objfpc}{$H+}

{$R atominsa.res}


Uses Classes, Forms, Interfaces, Graphics, SysUtils, IntfGraphics, Glut,
     UCore, UUtils, UBlock, UItem, UScheme, USpawn, UBomberman, UDisease,
     USpeedUp, UExtraBomb, UFlameUp, UGrid, UFlame, UBomb, USetup, UForm,
     UPractice, UMenu, UIntro, UEditor, UMulti, UGrab, uJelly, UJellyBomb,
     UListBomb, UPunch, USpoog, UGoldFlame, UTriggerBomb, UTrigger,
     USuperDisease, URandomBonus, UExplosion, UOnline, UNetwork, USolo;




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
          PHASE_SOLO      : InitSolo();
          STATE_SOLO      : ProcessSolo();
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
     AddSound( './sounds/move.mp3', SOUND_MENU_MOVE, False );
     AddSound( './sounds/select.mp3', SOUND_MENU_SELECT, False );
     AddSound( './sounds/back.mp3', SOUND_MENU_BACK, False );
     AddSound( './sounds/click.mp3', SOUND_MENU_CLICK, False );

     // chargement du son de l'invite de messages
     AddSound( './sounds/message.mp3', SOUND_MESSAGE, False );
     
     // chargement du son des bombes
     AddSound( './sounds/bomb0.mp3', SOUND_BOMB(1), False );
     AddSound( './sounds/bomb1.mp3', SOUND_BOMB(2), False );
     AddSound( './sounds/bomb2.mp3', SOUND_BOMB(3), False );
     AddSound( './sounds/bomb3.mp3', SOUND_BOMB(4), False );
     AddSound( './sounds/bomb4.mp3', SOUND_BOMB(5), False );
     AddSound( './sounds/bomb5.mp3', SOUND_BOMB(6), False );
     AddSound( './sounds/bomb6.mp3', SOUND_BOMB(7), False );
     AddSound( './sounds/bomb7.mp3', SOUND_BOMB(8), False );
     AddSound( './sounds/bomb8.mp3', SOUND_BOMB(9), False );
     AddSound( './sounds/bomb9.mp3', SOUND_BOMB(10), False );
     AddSound( './sounds/bomb10.mp3', SOUND_BOMB(11), False );
     AddSound( './sounds/bomb11.mp3', SOUND_BOMB(12), False );
     AddSound( './sounds/bomb12.mp3', SOUND_BOMB(13), False );
     AddSound( './sounds/bomb13.mp3', SOUND_BOMB(14), False );
     AddSound( './sounds/bomb14.mp3', SOUND_BOMB(15), False );
     AddSound( './sounds/bomb15.mp3', SOUND_BOMB(16), False );
     AddSound( './sounds/bomb16.mp3', SOUND_BOMB(17), False );
     AddSound( './sounds/bomb17.mp3', SOUND_BOMB(18), False );
     AddSound( './sounds/bomb18.mp3', SOUND_BOMB(19), False );
     AddSound( './sounds/bomb19.mp3', SOUND_BOMB(20), False );
     AddSound( './sounds/bomb20.mp3', SOUND_BOMB(21), False );
     AddSound( './sounds/bomb21.mp3', SOUND_BOMB(22), False );
     AddSound( './sounds/bomb22.mp3', SOUND_BOMB(23), False );
     AddSound( './sounds/bomb23.mp3', SOUND_BOMB(24), False );
     AddSound( './sounds/bomb24.mp3', SOUND_BOMB(25), False );
     AddSound( './sounds/bomb25.mp3', SOUND_BOMB(26), False );
     AddSound( './sounds/bomb26.mp3', SOUND_BOMB(27), False );
     AddSound( './sounds/bomb27.mp3', SOUND_BOMB(28), False );
     AddSound( './sounds/bomb28.mp3', SOUND_BOMB(29), False );
     AddSound( './sounds/bomb29.mp3', SOUND_BOMB(30), False );
     
     // chargement des sons des posages du bombe
     AddSound( './sounds/drop0.mp3', SOUND_DROP(1), False );
     AddSound( './sounds/drop1.mp3', SOUND_DROP(2), False );
     AddSound( './sounds/drop2.mp3', SOUND_DROP(3), False );
     
     // chargement des sons pour les morts
     AddSound( './sounds/die0.mp3', SOUND_DIE(1), False );
     AddSound( './sounds/die1.mp3', SOUND_DIE(2), False );
     
     // chargement des sons pour les maladies
     AddSound( './sounds/disease0.mp3', SOUND_DISEASE(1), False );
     AddSound( './sounds/disease1.mp3', SOUND_DISEASE(2), False );
     AddSound( './sounds/disease2.mp3', SOUND_DISEASE(3), False );
     AddSound( './sounds/disease3.mp3', SOUND_DISEASE(4), False );
     AddSound( './sounds/disease4.mp3', SOUND_DISEASE(5), False );
     AddSound( './sounds/disease5.mp3', SOUND_DISEASE(6), False );
     AddSound( './sounds/disease6.mp3', SOUND_DISEASE(7), False );
     AddSound( './sounds/disease7.mp3', SOUND_DISEASE(8), False );
     
     // chargement des sons pour les grab
     AddSound( './sounds/grab0.mp3', SOUND_GRAB(1), False );
     AddSound( './sounds/grab1.mp3', SOUND_GRAB(2), False );

     // chargement des sons pour les kick
     AddSound( './sounds/kick0.mp3', SOUND_KICK(1), False );
     AddSound( './sounds/kick1.mp3', SOUND_KICK(2), False );
     AddSound( './sounds/kick2.mp3', SOUND_KICK(3), False );
     AddSound( './sounds/kick3.mp3', SOUND_KICK(4), False );
     
     // chargement des sons pour les dropages
     AddSound( './sounds/throw0.mp3', SOUND_THROW(1), False );
     AddSound( './sounds/throw1.mp3', SOUND_THROW(2), False );
     AddSound( './sounds/throw2.mp3', SOUND_THROW(3), False );
     AddSound( './sounds/throw3.mp3', SOUND_THROW(4), False );
     
     // chargement des sons de rebondissement
     AddSound( './sounds/bounce0.mp3', SOUND_BOUNCE(1), False );
     AddSound( './sounds/bounce1.mp3', SOUND_BOUNCE(2), False );
     
     // chargement des sons des bonus
     AddSound( './sounds/bonus0.mp3', SOUND_BONUS(1), False );
     AddSound( './sounds/bonus1.mp3', SOUND_BONUS(2), False );
     AddSound( './sounds/bonus2.mp3', SOUND_BONUS(3), False );
     AddSound( './sounds/bonus3.mp3', SOUND_BONUS(4), False );
     
     // chargement des sons des stops
     AddSound( './sounds/stop0.mp3', SOUND_STOP(1), False );
     AddSound( './sounds/stop1.mp3', SOUND_STOP(2), False );

     // chargement des voix
     For k := 0 To 86 Do
         AddSound( Format('./sounds/speech%d.mp3', [k]), SOUND_SPEECH(k+1), False );

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
     
     // On arrête d'afficher la console
     If Not bConsole Then Window.Hide();

     ExecGlut();
End;

Procedure ExecServer () ;
Var nIndex, nHeader : Integer;
    sData : String;
    nDelay : Integer;
Begin
     AddLineToConsole( 'Mode dedicated server.' );

     // initialisation de FMod
     InitFMod();

     nState := PHASE_MENU;

     nDelay := 1000 Div nFramerate;
     
     // attente des infos du master server
     While Not FORCE_QUIT Do Begin
           MainLoop();
           Delay( nDelay );
     End;

     ExitFMod();
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

