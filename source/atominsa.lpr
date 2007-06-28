Program atominsa;

{$mode objfpc}{$H+}

Uses Classes, Forms, Interfaces, Graphics, SysUtils,
     UCore, UUtils, UBlock, UItem, UScheme, USpawn, UBomberman, UDisease,
     USpeedUp, UExtraBomb, UFlameUp, UGrid, UFlame, UBomb, USetup, UForm,
     UGame, UMenu, UIntro, UEditor;



Procedure Exit () ;
Begin
     DrawBox( 0.7, 0.4, 0.2, -0.4 );

     If GetKey(KEY_Y) Then Begin
        FreeBomberman();
        FreeBomb();
        FreeFlame();
        FreeDataStack();
        FreeTimer();
     
        ExitFMod();
        ExitGlut();
     
        WriteSettings( 'atominsa.cfg' );

        Application.Terminate;
     
        Halt(0);
     End Else If GetKey(KEY_N) Then Begin
         SetString( STRING_MENU_MAIN, ' ', 0.5, 0.1, 20 );

         PlaySound( SOUND_MENU_BACK );

         nState := PHASE_MENU;
     End;
End;



Procedure AskExit () ;
Begin
     InitBox( 'do you really want to quit ?', 'yes - no' );

     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     nState := STATE_EXIT;
End;



Procedure MainLoop () ; cdecl;
Begin
     Case nState Of
          PHASE_EXIT      : AskExit();
          STATE_EXIT      : Exit();
          PHASE_INTRO     : InitIntro();
          STATE_INTRO     : ProcessIntro();
          PHASE_MENU      : InitMenu();
          STATE_MENU      : ProcessMenu();
          PHASE_PRACTICE  : InitPractice();
          STATE_PRACTICE  : ProcessGame();
          PHASE_EDITOR    : InitEditor();
          STATE_EDITOR    : ProcessEditor();
          PHASE_SETUP     : InitSetup();
          STATE_SETUP     : ProcessSetup();
     End;
End;




Var k : Integer;
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

     // création de la pile de données
     InitDataStack();
     
     // initialisation de FMod
     InitFMod();

     InitGlut( 'atominsa - Game', @MainLoop );

     //----------------------------BEGIN::TEMP----------------------------//
     AddMesh( './characters/bomberman/bomberman.m12', MESH_BOMBERMAN );
     AddMesh( './maps/test/solid.m12', MESH_BLOCK_SOLID );
     AddMesh( './maps/test/brick.m12', MESH_BLOCK_BRICK );
     AddMesh( './meshes/bomb.m12', MESH_BOMB );
     AddMesh( './maps/test/plane.m12', MESH_PLANE );
     AddSound( './characters/bomberman/bomb0.wav', SOUND_BOMB(0) );
     AddSound( './characters/bomberman/bomb1.wav', SOUND_BOMB(1) );

     For k := 0 To 7 Do
         AddTexture( Format('./characters/bomberman/bomberman%d.jpg', [k]), TEXTURE_BOMBERMAN(k+1) );

     AddTexture( './maps/test/brick.jpg', TEXTURE_MAP_BRICK );
     AddTexture( './maps/test/solid.jpg', TEXTURE_MAP_SOLID );
     AddTexture( './maps/test/plane.jpg', TEXTURE_MAP_PLANE );
     AddTexture( './characters/bomberman/flame.jpg', TEXTURE_BOMBERMAN_FLAME );
     //-----------------------------END::TEMP-----------------------------//

     // chargement des meshes relatifs aux blocs et bonus
     AddMesh( './meshes/disease.m12', MESH_DISEASE );
     AddMesh( './meshes/extrabomb.m12', MESH_EXTRABOMB );
     AddMesh( './meshes/flameup.m12', MESH_FLAMEUP );
     AddMesh( './meshes/speedup.m12', MESH_SPEEDUP );

     // chargement des sprites relatifs au menu
     AddTexture( './textures/back.jpg', SPRITE_MENU_BACK );
     AddTexture( './textures/mainbt0.jpg', SPRITE_MENU_MAIN_BUTTON0 );
     AddTexture( './textures/mainbt1.jpg', SPRITE_MENU_MAIN_BUTTON1 );
     AddTexture( './textures/mainbt2.jpg', SPRITE_MENU_MAIN_BUTTON2 );
     AddTexture( './textures/mainbt3.jpg', SPRITE_MENU_MAIN_BUTTON3 );
     AddTexture( './textures/mainbt4.jpg', SPRITE_MENU_MAIN_BUTTON4 );
     AddTexture( './textures/mainbt5.jpg', SPRITE_MENU_MAIN_BUTTON5 );
     AddTexture( './textures/cross.jpg', SPRITE_MENU_CROSS );

     // chargement des polices de caractères
     AddTexture( './textures/charset0.jpg', SPRITE_CHARSET_TERMINAL );
     AddTexture( './textures/charset0x.jpg', SPRITE_CHARSET_TERMINALX );
     AddTexture( './textures/charset1.jpg', SPRITE_CHARSET_DIGITAL );

     // chargement des images de l'intro
     If bIntro Then Begin
        For k := 0 To 21 Do
            AddTexture( Format('./textures/layer%d.jpg', [k]), SPRITE_INTRO_LAYER(k) );
     End;

     // chargement des sons du menu
     AddSound( './sounds/move.wav', SOUND_MENU_MOVE );
     AddSound( './sounds/select.wav', SOUND_MENU_SELECT );
     AddSound( './sounds/back.wav', SOUND_MENU_BACK );

     // initialisation de la machine d'état
     If bIntro Then Begin
        nState := PHASE_INTRO;
     End Else Begin
        nState := PHASE_MENU;
     End;

     // définition de la touche pour le passage en plein écran
     BindKeyStd( KEY_F11, True, True, @SwitchDisplay );

     ExecGlut();
End.

