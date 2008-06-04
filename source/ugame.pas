Unit UGame;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils, GLext, GL,
     UCore, UUtils, UBlock, UItem, UBomberman, UDisease, UExplosion,
     USpeedUp, UExtraBomb, UFlameUp, UKick, UGrab, UJelly, UGrid, UFlame, UListBomb, UBomb, USetup, UForm,
     UJellyBomb, UPunch, USpoog, UGoldFLame, UTrigger, UTriggerBomb, USuperDisease, URandomBonus, UComputer;



Var bMulti : Boolean;



Const GAME_MENU         = 1;
Const GAME_INIT         = 2;
Const GAME_ROUND        = 3;
Const GAME_WAIT         = 4;
Const GAME_SCORE        = 5;
Const GAME_MENU_PLAYER  = 11;

Var nGame  : Integer;



Const MENU_PLAYER1       = 11;
Const MENU_PLAYER2       = 12;
Const MENU_PLAYER3       = 13;
Const MENU_PLAYER4       = 14;
Const MENU_PLAYER5       = 15;
Const MENU_PLAYER6       = 16;
Const MENU_PLAYER7       = 17;
Const MENU_PLAYER8       = 18;

Const MENU_SCHEME        = 21;

Const MENU_MAP           = 31;

Const MENU_ROUNDCOUNT    = 41;

Const MENU_FIGHT         = 51;

Const MENU_PLAYER_NAME        = 61;
Const MENU_PLAYER_CHARACTER   = 62;
Const MENU_PLAYER_TYPE        = 63;
Const MENU_PLAYER_SKILL       = 64;

Const MENU_PLAYER_BACK        = 71;

Var nMenu  : Integer;
Var nPlayer  : Integer;



Var bMessage : Boolean;
    sMessage : String;



Var bUp     : Boolean;
Var bDown   : Boolean;
Var bLeft   : Boolean;
Var bRight  : Boolean;
Var bEnter  : Boolean;

Var fKey    : Single;



Var bScoreTable : Boolean;



Var pGrid : CGrid;



Const CAMERA_FLY          = -1;
Const CAMERA_OVERALL      =  0;

Var nCamera  : Integer;
    vCamera  : Vector;
    vCenter  : Vector;
    vAngle   : Vector;
    vPointer : Vector;



Var nRound : Integer;
    fRoundTime : Single;
    fGameTime : Single;
    fWaitTime : Single;



Var pPlayer1 : CBomberman;
    pPlayer2 : CBomberman;
    
    
Var numDisease : Array [1..GRIDWIDTH, 1..GRIDHEIGHT] Of Integer;



Procedure LoadCharacter ( tPlayer : Integer ) ;
Procedure LoadScheme () ;
Procedure LoadMap () ;

Procedure SetCamera () ;
Procedure SetLighting ( w : Single ; h : Single ; a0, a1, a2 : Single ) ;

Procedure DrawBomberman ( w : Single; bUpdate : boolean ) ;
Procedure DrawGrid ( w : Single ) ;
Procedure DrawBomb ( w : Single; bUpdate : boolean ) ;
Procedure DrawFlame ( w : Single; bUpdate : boolean ) ;
Procedure DrawPlane ( w : Single ) ;
Procedure DrawTimer ( p : Single ) ;
Procedure DrawScore ( p : Single ) ;
Procedure DrawScreen ( p : Single ) ;

Procedure InitScreen () ;
Procedure AddBlankToScreen () ;
Procedure AddStringToScreen ( sMessage : String ) ;

Procedure InitScore () ;
Procedure ProcessScore () ;

Procedure InitWait () ;
Procedure ProcessWait () ;

Procedure InitRound () ;
Procedure InitGame () ;
Procedure ProcessGame () ;

Procedure InitMenu () ;
Procedure UpdateMenu () ;
Procedure ProcessMenu () ;

Procedure InitMenuPlayer ( n : Integer ) ;
Procedure ProcessMenuPlayer () ;



Implementation

Uses UMulti;



























////////////////////////////////////////////////////////////////////////////////
// CHARGEMENT                                                                 //
////////////////////////////////////////////////////////////////////////////////



Procedure LoadCharacter ( tPlayer : Integer ) ;
Begin
     If nPlayerCharacter[tPlayer] = -1 Then Begin
        pPlayerCharacter[tPlayer] := aCharacterList[Trunc(Random(nCharacterCount))];
     End Else Begin
        pPlayerCharacter[tPlayer] := aCharacterList[nPlayerCharacter[tPlayer]];
     End;
     AddAnimation( './characters/' + pPlayerCharacter[tPlayer].PlayerAnim, ANIMATION_BOMBERMAN(tPlayer), MESH_BOMBERMAN(tPlayer) );
     AddMesh( './characters/' + pPlayerCharacter[tPlayer].PlayerMesh, MESH_BOMBERMAN(tPlayer) );
     AddMesh( './characters/' + pPlayerCharacter[tPlayer].BombMesh, MESH_BOMB(tPlayer) );
     AddTexture( './characters/' + pPlayerCharacter[tPlayer].PlayerSkin[tPlayer], TEXTURE_BOMBERMAN(tPlayer) );
     AddTexture( './characters/' + pPlayerCharacter[tPlayer].BombSkin, TEXTURE_BOMB(tPlayer) );
     AddTexture( './characters/' + pPlayerCharacter[tPlayer].FlameTexture, TEXTURE_FLAME(tPlayer) );
     AddSound( './characters/' + pPlayerCharacter[tPlayer].BombSound[1], SOUND_BOMB(10+tPlayer) );
     AddSound( './characters/' + pPlayerCharacter[tPlayer].BombSound[2], SOUND_BOMB(20+tPlayer) );
     AddSound( './characters/' + pPlayerCharacter[tPlayer].BombSound[3], SOUND_BOMB(30+tPlayer) );
End;



Procedure LoadScheme () ;
Var k : Integer;
Begin
     If nScheme = -1 Then Begin
        If (bMulti = True) Then
           pScheme := aSchemeList[nSchemeMulti]
        Else
            pScheme := aSchemeList[Trunc(Random(nSchemeCount))];
     End Else Begin
        pScheme := aSchemeList[nScheme];
     End;
     pGrid := CGrid.Create( pScheme );
     FreeBomberman();
     For k := 1 To 8 Do
         AddBomberman( 'temp', pScheme.Spawn(k).Team, pScheme.Spawn(k).Color, SKILL_PLAYER, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
End;



Procedure LoadMap () ;
Begin
     If nMap = -1 Then Begin
        pMap := aMapList[Trunc(Random(nMapCount))];
     End Else Begin
        pMap := aMapList[nMap];
     End;
     //DelMesh( MESH_BLOCK_SOLID );
     AddMesh( './maps/' + pMap.SolidMesh, MESH_BLOCK_SOLID );
     //DelMesh( MESH_BLOCK_BRICK );
     AddMesh( './maps/' + pMap.BrickMesh, MESH_BLOCK_BRICK );
     //DelMesh( MESH_PLANE );
     AddMesh( './maps/' + pMap.PlaneMesh, MESH_PLANE );
     //DelTexture( TEXTURE_MAP_SOLID );
     AddTexture( './maps/' + pMap.SolidTexture, TEXTURE_MAP_SOLID );
     //DelTexture( TEXTURE_MAP_BRICK );
     AddTexture( './maps/' + pMap.BrickTexture, TEXTURE_MAP_BRICK );
     //DelTexture( TEXTURE_MAP_PLANE );
     AddTexture( './maps/' + pMap.PlaneTexture, TEXTURE_MAP_PLANE );
     //DelTexture( TEXTURE_MAP_SKYBOX(1) );
     AddTexture( './maps/' + pMap.SkyboxBottom, TEXTURE_MAP_SKYBOX(1) );
     //DelTexture( TEXTURE_MAP_SKYBOX(2) );
     AddTexture( './maps/' + pMap.SkyboxTop, TEXTURE_MAP_SKYBOX(2) );
     //DelTexture( TEXTURE_MAP_SKYBOX(3) );
     AddTexture( './maps/' + pMap.SkyboxFront, TEXTURE_MAP_SKYBOX(3) );
     //DelTexture( TEXTURE_MAP_SKYBOX(4) );
     AddTexture( './maps/' + pMap.SkyboxBack, TEXTURE_MAP_SKYBOX(4) );
     //DelTexture( TEXTURE_MAP_SKYBOX(5) );
     AddTexture( './maps/' + pMap.SkyboxLeft, TEXTURE_MAP_SKYBOX(5) );
     //DelTexture( TEXTURE_MAP_SKYBOX(6) );
     AddTexture( './maps/' + pMap.SkyboxRight, TEXTURE_MAP_SKYBOX(6) );
End;





























////////////////////////////////////////////////////////////////////////////////
// AFFICHAGE                                                                  //
////////////////////////////////////////////////////////////////////////////////



Procedure SetCamera () ;
Begin
     If GetTime - fGameTime < 3.0 Then Begin
     // on fait le tour du plateau durant les trois premières secondes de jeu
        vPointer.x := 8.0 + (fGameTime - GetTime + 3.0) * 24.0 * cos((GetTime - fGameTime) / 3.0 * PI + PI * 3 / 2);
        vPointer.y := 8.5 + (fGameTime - GetTime + 3.0) * 8.0;
        vPointer.z := 6.0 + (fGameTime - GetTime + 3.0) * 24.0 * sin((GetTime - fGameTime) / 3.0 * PI + PI * 3 / 2);
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If GetTime - fWaitTime < 1.0 Then Begin
     // on s'éloigne du plateau la dernière seconde d'un round
        vPointer.x := 8.0;
        vPointer.y := 8.5 + (GetTime - fWaitTime) * 3.0;
        vPointer.z := 6.0 + (GetTime - fWaitTime) * 16.0;
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If GetTime - fRoundTime < 1.0 Then Begin
     // on se rapproche du plateau la première seconde d'un round
        vPointer.x := 8.0;
        vPointer.y := 8.5 + (fRoundTime - GetTime + 1.0) * 3.0;
        vPointer.z := 6.0 + (fRoundTime - GetTime + 1.0) * 16.0;
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If nGame = GAME_WAIT Then Begin
     // position de la caméra reculée
        vPointer.x := 8.0;
        vPointer.y := 11.5;
        vPointer.z := 22.0;
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If nCamera = CAMERA_OVERALL Then Begin
     // position de la caméra au dessus du plateau
        vPointer.x := 8.0;
        vPointer.y := 8.5;
        vPointer.z := 6.0;
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If nCamera = CAMERA_FLY Then Begin
     // gestion de la souris et du clavier pour le mode caméra libre
        vAngle.x -= GetMouseDX() * 2000.0 * GetDelta();
        vAngle.y += GetMouseDY() * 2000.0 * GetDelta();
        If vAngle.x < 0.0 Then vAngle.x += PI2;
        If vAngle.x > PI2 Then vAngle.x -= PI2;
        If vAngle.y < -PI*0.5 Then vAngle.y := -PI*0.5;
        If vAngle.y > +PI*0.5 Then vAngle.y := +PI*0.5;
        If GetKeyS(KEY_UP) Then Begin
           vPointer.x += GetDelta() * 1.0 * cos(vAngle.x);
           vPointer.y += GetDelta() * 1.0 * sin(vAngle.y);
           vPointer.z += GetDelta() * 1.0 * sin(vAngle.x);
        End Else If GetKeyS(KEY_DOWN) Then Begin
           vPointer.x -= GetDelta() * 1.0 * cos(vAngle.x);
           vPointer.y -= GetDelta() * 1.0 * sin(vAngle.y);
           vPointer.z -= GetDelta() * 1.0 * sin(vAngle.x);
        End Else If GetKeyS(KEY_RIGHT) Then Begin
           vPointer.x += GetDelta() * 1.0 * cos(vAngle.x + PI*0.5);
           vPointer.z += GetDelta() * 1.0 * sin(vAngle.x + PI*0.5);
        End Else If GetKeyS(KEY_LEFT) Then Begin
           vPointer.x -= GetDelta() * 1.0 * cos(vAngle.x + PI*0.5);
           vPointer.z -= GetDelta() * 1.0 * sin(vAngle.x + PI*0.5);
        End;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
        vCenter.x := vCamera.x + cos(vAngle.x);
        vCenter.y := vCamera.y + sin(vAngle.y);
        vCenter.z := vCamera.z + sin(vAngle.x);
     End Else Begin
     // caméra en mode suivi de bomberman
        vCenter.x := GetBombermanByCount(nCamera).Position.X;
        vCenter.y := 0.0;
        vCenter.z := GetBombermanByCount(nCamera).Position.Y;
        If GetBombermanByCount(nCamera).Direction = 0 Then Begin
           vPointer.x := vCenter.x;
           vPointer.y := 3.0;
           vPointer.z := vCenter.z - 3.0;
        End Else If GetBombermanByCount(nCamera).Direction = 90 Then Begin
           vPointer.x := vCenter.x + 3.0;
           vPointer.y := 3.0;
           vPointer.z := vCenter.z;
        End Else If GetBombermanByCount(nCamera).Direction = 180 Then Begin
           vPointer.x := vCenter.x;
           vPointer.y := 3.0;
           vPointer.z := vCenter.z + 3.0;
        End Else If GetBombermanByCount(nCamera).Direction = -90 Then Begin
           vPointer.x := vCenter.x - 3.0;
           vPointer.y := 3.0;
           vPointer.z := vCenter.z;
        End;
     End;
     
     // déplacement progressif de la camera vers son pointeur pour rendre plus fluide le mouvement
     If vCamera.x > vPointer.x Then vCamera.x -= vPointer.x * GetDelta() * 1.0;
     If vCamera.x < vPointer.x Then vCamera.x += vPointer.x * GetDelta() * 1.0;
     If vCamera.y > vPointer.y Then vCamera.y -= vPointer.y * GetDelta() * 1.0;
     If vCamera.y < vPointer.y Then vCamera.y += vPointer.y * GetDelta() * 1.0;
     If vCamera.z > vPointer.z Then vCamera.z -= vPointer.z * GetDelta() * 1.0;
     If vCamera.z < vPointer.z Then vCamera.z += vPointer.z * GetDelta() * 1.0;

     // envoi des données au moteur graphique
     SetProjectionMatrix ( 90.0, 1.0, 0.1, 2048.0 ) ;
     SetCameraMatrix ( vCamera.x, vCamera.y, vCamera.z, vCenter.x, vCenter.y, vCenter.z, 0, 1, 0 ) ;
End;



Procedure SetLighting ( w : Single ; h : Single ; a0, a1, a2 : Single ) ;
Var k : Integer;
    aBomberman : CBomberman;
Begin
     For k := 1 To 8 Do Begin
         SetLight( k - 1, 4999.999, 4999.999, 4999.999, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, False );
     End;

     If bLighting Then Begin
        If nPlayerType[1] > 0 Then
        begin
           aBomberman:=GetBombermanByIndex(1);
           if aBomberman.Alive then
           SetLight( 0, aBomberman.Position.X, h, aBomberman.Position.Y - 2, w, 0, 0, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        end;
        If nPlayerType[2] > 0 Then
        begin
           aBomberman:=GetBombermanByIndex(2);
           if aBomberman.Alive then
           SetLight( 1, aBomberman.Position.X, h, aBomberman.Position.Y - 2, 0, 0, w, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        end;
        If nPlayerType[3] > 0 Then
        begin
           aBomberman:=GetBombermanByIndex(3);
           if aBomberman.Alive then
           SetLight( 2, aBomberman.Position.X, h, aBomberman.Position.Y - 2, 0, w, 0, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        end;
        If nPlayerType[4] > 0 Then
        begin
           aBomberman:=GetBombermanByIndex(4);
           if aBomberman.Alive then
           SetLight( 3, aBomberman.Position.X, h, aBomberman.Position.Y - 2, w, w, 0, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        end;
        If nPlayerType[5] > 0 Then
        begin
           aBomberman:=GetBombermanByIndex(5);
           if aBomberman.Alive then
           SetLight( 4, aBomberman.Position.X, h, aBomberman.Position.Y - 2, 0, w, w, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        end;
        If nPlayerType[6] > 0 Then
        begin
           aBomberman:=GetBombermanByIndex(6);
           if aBomberman.Alive then
           SetLight( 5, aBomberman.Position.X, h, aBomberman.Position.Y - 2, w, 0, w, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        end;
        If nPlayerType[7] > 0 Then
        begin
           aBomberman:=GetBombermanByIndex(7);
           if aBomberman.Alive then
           SetLight( 6, aBomberman.Position.X, h, aBomberman.Position.Y - 2, w, w, w, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        end;
        If nPlayerType[8] > 0 Then
        begin
           aBomberman:=GetBombermanByIndex(8);
           if aBomberman.Alive then
           SetLight( 7, aBomberman.Position.X, h, aBomberman.Position.Y - 2, 0.2 * w, 0.2 * w, 0.2 * w, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        end;
     End;
End;



Procedure DrawBomberman ( w : Single ; bUpdate : Boolean ) ;
Var i : Integer;
    aBomberman : CBomberman;
Begin
     EnableLighting();
     SetLighting( w, 2.0, 1.0, 0.3, 0.6 );

     SetMaterial( w, w, w, 1.0 );

     For i := 1 To GetBombermanCount() Do
     Begin
          aBomberman:=GetBombermanByCount(i);
          If aBomberman.Alive then
          Begin
               SetTexture( 1, TEXTURE_BOMBERMAN(aBomberman.BIndex) );
               PushObjectMatrix( aBomberman.Position.X-0.15, aBomberman.Position.Z, aBomberman.Position.Y-0.15, 0.05, 0.05, 0.05, 0, aBomberman.Direction, 0 );
               If aBomberman.IsMoving() Then Begin
                  DrawAnimation( ANIMATION_BOMBERMAN(aBomberman.BIndex), False, 1 );
               End Else Begin
                  //DrawMesh( MESH_BOMBERMAN(aBomberman.BIndex), False );
                  DrawAnimation( ANIMATION_BOMBERMAN(aBomberman.BIndex), False, 0 );
               End;
               PopObjectMatrix();
               If bUpdate Then aBomberman.Update(GetDelta());
          End;
     End;
End;



Procedure DrawGrid ( w : Single ) ;
Var i, j : Integer;
    pBlock : CBlock;
Begin
     EnableLighting();
     SetLighting( w, 5.0, 1.0, 1.8, 2.4 );

     For j := 1 To GRIDHEIGHT Do Begin
          For i := 1 To GRIDWIDTH Do Begin
              pBlock := pGrid.GetBlock(i,j);
              If Not(pBlock Is CBomb) Then Begin
                 If (pBlock Is CDisease) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, 0, 0, 1.0 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.026, 0.026, 0.026, 0, 0, 0 );
                    DrawMesh( MESH_DISEASE, True );
                    PopObjectMatrix();
                 End Else If (pBlock Is CExtraBomb) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( 0, w, 0, 1.0 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.012, 0.012, 0.012, 0, 0, 0 );
                    DrawMesh( MESH_EXTRABOMB, True );
                    PopObjectMatrix();
                 End Else If (pBlock Is CSpeedUp) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( 0, 0, w, 1.0 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.026, 0.026, 0.026, 0, 0, 0 );
                    DrawMesh( MESH_SPEEDUP, True );
                    PopObjectMatrix();
                 End Else If (pBlock Is CFlameUp) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, w, 0, 1.0 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );
                    PopObjectMatrix();
                 End Else If (pBlock Is CKick) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, w, 1.0, 1.0 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du Kick
                    PopObjectMatrix();
                 End Else If (pBlock Is CGrab) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, w, 1.0, 0.5 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du GRAB
                    PopObjectMatrix();
                 End Else If (pBlock Is CJelly) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, w, 0.8, 0.4 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du JELLY
                    PopObjectMatrix();
                 End Else If (pBlock Is CPunch) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, w, 0.2, 0.6 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du PUNCH
                    PopObjectMatrix();
                 End Else If (pBlock Is CSpoog) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, w, 0.5, 0.5 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du SPOOG
                    PopObjectMatrix();
                 End Else If (pBlock Is CGoldFlame) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, 0.4, 0.5, 0.6 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du GOLDFLAME
                    PopObjectMatrix();
                 End Else If (pBlock Is CTrigger) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, 0.2, 0.5, 0.9 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du TRIGGER
                    PopObjectMatrix();
                 End Else If (pBlock Is CSuperDisease) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( 0.8, 0.2, 0.2, 0.9 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du SUPERDISEASE
                    PopObjectMatrix();
                 End Else If (pBlock Is CRandomBonus) And (pBlock As CItem).IsExplosed() Then Begin
                    SetMaterial( w, 1, 1, 0.8 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////////////////////////////Mettre le mesh du RANDOM
                    PopObjectMatrix();
                 End Else If (pBlock Is CItem) Then Begin
                    SetMaterial( w, w, w, 1.0 );                                        //////////////////// sert a rien lui si ???????
                    SetTexture( 1, TEXTURE_MAP_BRICK );                                 //////////////////
                    PushObjectMatrix( i, 0, j, 0.012, 0.012, 0.012, 0, 0, 0 );
                    DrawMesh( MESH_BLOCK_BRICK, False );
                    PopObjectMatrix();
                 End Else If (pBlock Is CBlock) Then Begin
                    SetMaterial( w, w, w, 1.0 );
                    If (pBlock As CBlock).IsExplosive() Then Begin
                       SetTexture( 1, TEXTURE_MAP_BRICK );
                       PushObjectMatrix( i, 0, j, 0.012, 0.012, 0.012, 0, 0, 0 );
                       DrawMesh( MESH_BLOCK_BRICK, False );
                       PopObjectMatrix();
                    End Else Begin
                        SetTexture( 1, TEXTURE_MAP_SOLID );
                        PushObjectMatrix( i, 0, j, 0.016, 0.016, 0.016, 0, 0, 0 );
                        DrawMesh( MESH_BLOCK_SOLID, False );
                        PopObjectMatrix();
                    End;
                 End;
              End;
          End;
     End;
End;



Procedure DrawBomb ( w : Single ; bUpdate : Boolean ) ;
Var i : Integer;
    r, g, b : Single;
    aBomb : CBomb;
Begin
     EnableLighting();
     SetLighting( w, 5.0, 1.0, 1.8, 2.4 );

     i := 1;
     While ( i <= GetBombCount() ) Do Begin
          aBomb := GetBombByCount(i);
          If bColor Then Begin
             Case aBomb.BIndex Of
                  1 : Begin r := 3.0; g := 0.0; b := 0.0; End;
                  2 : Begin r := 0.0; g := 0.0; b := 3.0; End;
                  3 : Begin r := 0.0; g := 3.0; b := 0.0; End;
                  4 : Begin r := 3.0; g := 3.0; b := 0.0; End;
                  5 : Begin r := 0.0; g := 3.0; b := 3.0; End;
                  6 : Begin r := 3.0; g := 0.0; b := 3.0; End;
                  7 : Begin r := 3.0; g := 3.0; b := 3.0; End;
                  8 : Begin r := 1.0; g := 1.0; b := 1.0; End;
             End;
          End Else Begin
             r := 1.0; g := 1.0; b := 1.0;
          End;
          SetMaterial( w * r, w * g, w * b, 1.0 );
          SetTexture( 1, TEXTURE_BOMB(aBomb.BIndex) );

          if (aBomb is CJellyBomb) then
          PushObjectMatrix( aBomb.Position.X, aBomb.Position.Z, aBomb.Position.Y,
                            1/30*(0.7+Cos(7*aBomb.Time)*Cos(7*aBomb.Time)*0.5),
                            1/30*(0.7+Cos(7*aBomb.Time)*Cos(7*aBomb.Time)*0.5),
                            1/30*(0.7+Cos(7*aBomb.Time)*Cos(7*aBomb.Time)*0.5),
                            0,0,0)
          else if (aBomb is CTriggerBomb) then
          PushObjectMatrix( aBomb.Position.X, aBomb.Position.Z, aBomb.Position.Y,
                            0.04, 0.04, 0.04,
                            0,0,0)
          else
          PushObjectMatrix( aBomb.Position.X, aBomb.Position.Z, aBomb.Position.Y,
                            1/30*(0.7+Cos(4*aBomb.Time)*Cos(4*aBomb.Time)*0.5),
                            1/30*(0.7+Cos(4*aBomb.Time)*Cos(4*aBomb.Time)*0.5),
                            1/30*(0.7+Cos(4*aBomb.Time)*Cos(4*aBomb.Time)*0.5),
                            0, 0, 0 );
                            
          DrawMesh( MESH_BOMB(aBomb.BIndex), False );
          PopObjectMatrix();
          If bUpdate Then Begin
              If Not aBomb.UpdateBomb() Then i += 1;
          End Else Begin
              i += 1;
          End;
    End;
End;



Procedure DrawFlame ( w : Single ; bUpdate : Boolean ) ;
Var i : Integer;
    r, g, b : Single;
    aFlame : CFlame;
Begin
     DisableLighting();

     i := 1;
     While ( i <= GetFlameCount() ) Do Begin
          aFlame := GetFlameByCount(i);
          SetTexture( 1, TEXTURE_FLAME(aFlame.Owner.BIndex) );
          // flamme intérieure
          If bColor Then Begin
             Case aFlame.Owner.BIndex Of
                  1 : Begin r := 1.0; g := 0.6; b := 0.6; End;
                  2 : Begin r := 0.6; g := 0.6; b := 1.0; End;
                  3 : Begin r := 0.6; g := 1.0; b := 0.6; End;
                  4 : Begin r := 1.0; g := 1.0; b := 0.6; End;
                  5 : Begin r := 0.6; g := 1.0; b := 1.0; End;
                  6 : Begin r := 1.0; g := 0.6; b := 1.0; End;
                  7 : Begin r := 1.0; g := 1.0; b := 1.0; End;
                  8 : Begin r := 0.6; g := 0.6; b := 0.6; End;
             End;
          End Else Begin
             r := 1.0; g := 1.0; b := 1.0;
          End;
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X - 0.001, 0, aFlame.Y - 0.001 ); // on évite les cas particuliers (les angles à 90° bug)
          DrawSprite( 1.0 + 2.0 * aFlame.Itensity, 1.0 + 2.0 * aFlame.Itensity, r, g, b, aFlame.Itensity, True );
          PopObjectMatrix();
          // flammes centrales
          If bColor Then Begin
             Case aFlame.Owner.BIndex Of
                  1 : Begin r := 0.8; g := 0.2; b := 0.2; End;
                  2 : Begin r := 0.2; g := 0.2; b := 0.8; End;
                  3 : Begin r := 0.2; g := 0.8; b := 0.2; End;
                  4 : Begin r := 0.8; g := 0.8; b := 0.2; End;
                  5 : Begin r := 0.2; g := 0.8; b := 0.8; End;
                  6 : Begin r := 0.8; g := 0.2; b := 0.8; End;
                  7 : Begin r := 0.8; g := 0.8; b := 0.8; End;
                  8 : Begin r := 0.2; g := 0.2; b := 0.2; End;
             End;
          End Else Begin
             r := 1.0; g := 0.5; b := 0.0;
          End;
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X - 0.301, 0, aFlame.Y );
          DrawSprite( 0.6 + 1.7 * aFlame.Itensity, 0.6 + 1.7 * aFlame.Itensity, r, g, b, aFlame.Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X + 0.299, 0, aFlame.Y );
          DrawSprite( 0.6 + 1.7 *aFlame.Itensity, 0.6 + 1.7 * aFlame.Itensity, r, g, b, aFlame.Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X, 0, aFlame.Y - 0.301 );
          DrawSprite( 0.6 + 1.7 * aFlame.Itensity, 0.6 + 1.7 * aFlame.Itensity, r, g, b, aFlame.Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X, 0, aFlame.Y + 0.299 );
          DrawSprite( 0.6 + 1.7 * aFlame.Itensity, 0.6 + 1.7 * aFlame.Itensity, r, g, b, aFlame.Itensity * 0.8, True );
          PopObjectMatrix();
          // flammes extérieures
          If bColor Then Begin
             Case aFlame.Owner.BIndex Of
                  1 : Begin r := 0.4; g := 0.0; b := 0.0; End;
                  2 : Begin r := 0.0; g := 0.0; b := 0.4; End;
                  3 : Begin r := 0.0; g := 0.4; b := 0.0; End;
                  4 : Begin r := 0.4; g := 0.4; b := 0.0; End;
                  5 : Begin r := 0.0; g := 0.4; b := 0.4; End;
                  6 : Begin r := 0.4; g := 0.0; b := 0.4; End;
                  7 : Begin r := 0.4; g := 0.4; b := 0.4; End;
                  8 : Begin r := 0.1; g := 0.1; b := 0.1; End;
             End;
          End Else Begin
             r := 1.0; g := 0.0; b := 0.0;
          End;
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X - 0.301, 0, aFlame.Y - 0.301 );
          DrawSprite( 0.2 + 1.4 * aFlame.Itensity, 0.2 + 1.4 * aFlame.Itensity, r, g, b, aFlame.Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X - 0.301, 0, aFlame.Y + 0.299 );
          DrawSprite( 0.2 + 1.4 * aFlame.Itensity, 0.2 + 1.4 * aFlame.Itensity, r, g, b, aFlame.Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X + 0.299, 0, aFlame.Y - 0.301 );
          DrawSprite( 0.2 + 1.4 * aFlame.Itensity, 0.2 + 1.4 * aFlame.Itensity, r, g, b, aFlame.Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, aFlame.X + 0.299, 0, aFlame.Y + 0.299 );
          DrawSprite( 0.2 + 1.4 * aFlame.Itensity, 0.2 + 1.4 * aFlame.Itensity, r, g, b, aFlame.Itensity * 0.4, True );
          PopObjectMatrix();
          // mise à jour
          If bUpdate Then Begin
              If Not aFlame.Update() Then i += 1;
          End Else Begin
              i += 1;
          End;
     End;
End;



Procedure DrawPlane ( w : Single ) ;
Begin
     EnableLighting();
     SetLighting( w, 2.0, 1.0, 0.3, 0.6 );

     SetMaterial( w, w, w, 1.0 );

     SetTexture( 1, TEXTURE_MAP_PLANE );
     PushObjectMatrix( 8.0, -0.5, 6.0, 0.11, 0.11, 0.11, 0, 0, 0 );
     DrawMesh( MESH_PLANE, True );
     PopObjectMatrix();
End;



Var fBlinkTime : Single;
    bBlinkState : Boolean;

Procedure DrawTimer ( p : Single ) ;
Var w, h : Single;
Var nMin, nSec : Integer;
    fTime : Single;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     fTime := fRoundDuration + fRoundTime - GetTime + 3.0;
     nMin := Trunc(fTime / 60.0);
     nSec := Trunc(fTime) - nMin * 60;
     
     DisableLighting();

     SetString( STRING_TIMER, Format('****', [nMin, nSec]), 0.0, 0.0, 0.0 );
     DrawString( STRING_TIMER, w / h * 0.7, 0.8, -1, 0.064 * w / h, 0.096, p, p, p, p * 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );

     If nSec < 10 Then Begin
        SetString( STRING_TIMER, Format('%d:0%d', [nMin, nSec]), 0.0, 0.0, 0.0 );
     End Else Begin
        SetString( STRING_TIMER, Format('%d:%d', [nMin, nSec]), 0.0, 0.0, 0.0 );
     End;

     If GetTime > fRoundTime + fRoundDuration Then Begin
        bBlinkState := True;
     End Else If GetTime > fRoundTime + fRoundDuration - 3.0 Then Begin
        If GetTime > fBlinkTime + 0.1 Then Begin
           fBlinkTime := GetTime;
           bBlinkState := Not bBlinkState;
        End;
     End Else If GetTime > fRoundTime + fRoundDuration - 8.0 Then Begin
        If GetTime > fBlinkTime + 0.5 Then Begin
           fBlinkTime := GetTime;
           bBlinkState := Not bBlinkState;
        End;
     End Else Begin
        bBlinkState := False;
     End;
     
     If bBlinkState Then Begin
        DrawString( STRING_TIMER, w / h * 0.7, 0.8, -1, 0.064 * w / h, 0.096, p, p, p, p * 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );
     End Else Begin
        DrawString( STRING_TIMER, w / h * 0.7, 0.8, -1, 0.064 * w / h, 0.096, p, p, p, p * 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );
     End;
End;



Var fScreenTime : Single;
    sScreenMessage : String;

Procedure InitScreen () ;
Begin
     fScreenTime := 0.0;
     sScreenMessage := '                        ';
End;

Procedure AddBlankToScreen () ;
Begin
     sScreenMessage := sScreenMessage + '************************';
End;

Procedure AddStringToScreen ( sMessage : String ) ;
Begin
     sScreenMessage := sScreenMessage + '************************' + sMessage + '************************';
End;

Procedure DrawScreen ( p : Single ) ;
Var w, h : Single;
    k : Integer;
    s : String;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     If Length(sScreenMessage) <= 24 Then Begin
        sScreenMessage := '************************';
     End Else If GetTime > fScreenTime + 0.1 Then Begin
        fScreenTime := GetTime;
        For k := 1 To Length(sScreenMessage) - 1 Do
            sScreenMessage[k] := sScreenMessage[k+1];
        SetLength(sScreenMessage, Length(sScreenMessage) - 1);
     End;

     DisableLighting();

     SetString( STRING_SCREEN, '************************', 0.0, 0.0, 0.0 );
     DrawString( STRING_SCREEN, w / h * -0.9, 0.8, -1, 0.064 * w / h, 0.096, p, p, p, p * 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );

     SetLength( s, 24 );
     For k := 1 To 24 Do
         s[k] := sScreenMessage[k];

     SetString( STRING_SCREEN, s, 0.0, 0.0, 0.0 );
     DrawString( STRING_SCREEN, w / h * -0.9, 0.8, -1, 0.064 * w / h, 0.096, p, p, p, p * 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );
End;



Procedure DrawScore ( p : Single ) ;
Var w, h : Single;
    i : Integer;
    aBomberman : CBomberman;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     If GetKey(KEY_TAB) Then Begin
        If Not bScoreTable Then Begin
           If GetBombermanCount() <> 0 Then
              For i := 1 To GetBombermanCount() Do
              Begin
                  aBomberman := GetBombermanByCount(i);
                  SetString( STRING_SCORE_TABLE(i), aBomberman.Name + Format(' : %2d ; %d kill(s), %d death(s). (%.2f ms)', [aBomberman.Score, aBomberman.Kills, aBomberman.Deaths, fPlayerPing[i]]), Single(i) * 0.1 + 0.1, 1.0, 20 );
              End;
        End;
        If GetBombermanCount() <> 0 Then
           For i := 1 To GetBombermanCount() Do
               DrawString( STRING_SCORE_TABLE(i), -w / h * 0.9, 0.6 - 0.15 * Single(i), -1, 0.018 * w / h, 0.024, p, p, p, p * 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
        bScoreTable := True;
     End Else Begin
        bScoreTable := False;
     End;
End;



Procedure DrawMessage ( p : Single ) ;
Var w, h : Single;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     If GetKey(KEY_SQUARE) Then Begin
        If GetTime > fKey Then Begin
           SetString( STRING_MESSAGE, 'say : ' + sMessage, 0.0, 0.02, 600 );
           bMessage := Not bMessage;
           fKey := GetTime + 0.5;
           ClearInput();
        End;
     End;

     If bMessage Then Begin
         DrawString( STRING_MESSAGE, -w / h * 0.9, -0.75, -1, 0.018 * w / h, 0.024, p, p, p, p * 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

         If GetKey( KEY_ENTER ) Then Begin
            If Not bEnter Then Begin
               PlaySound( SOUND_MESSAGE );
               Send( nLocalIndex, HEADER_MESSAGE, sMessage );
               bMessage := False;
               sMessage := '';
            End;
            bEnter := True;
         End Else Begin
            bEnter := False;
         End;

         If Ord(CheckKey()) > 0 Then Begin
            If GetTime > fKey Then Begin
               If Ord(CheckKey()) = 8 Then Begin
                   SetLength(sMessage, Length(sMessage) - 1);
               End Else Begin
                   sMessage := sMessage + CheckKey();
               End;
               SetString( STRING_MESSAGE, 'say : ' + sMessage, 0.0, 0.02, 600 );
            End;
            fKey := GetTime + 0.2;
            ClearInput();
         End Else Begin
            fKey := 0.0;
         End;
     End;
End;



Procedure DrawNotification ( p : Single ) ;
Var w, h : Single;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     DrawString( STRING_NOTIFICATION, -w / h * 0.9, -0.9, -1, 0.018 * w / h, 0.024, p, p, p, p * 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
End;





























////////////////////////////////////////////////////////////////////////////////
// PHASE D'ATTENTE EN FIN DE MATCH                                            //
////////////////////////////////////////////////////////////////////////////////



Procedure InitScore () ;
Var i : Integer;
    aBomberman : CBomberman;
Begin
     // suppression des touches des joueurs
     BindKeyObj( nKey1MoveUp, True, False, NIL );
     BindKeyObj( nKey1MoveDown, True, False, NIL );
     BindKeyObj( nKey1MoveLeft, True, False, NIL );
     BindKeyObj( nKey1MoveRight, True, False, NIL );
     BindKeyObj( nKey1Primary, True, False, NIL );
     BindKeyObj( nKey1Secondary, True, False, NIL );
     BindKeyObj( nKey1Primary, False, False, NIL );
     BindKeyObj( nKey1Secondary, False, False, NIL );
     
     BindKeyObj( nKey2MoveUp, True, False, NIL );
     BindKeyObj( nKey2MoveDown, True, False, NIL );
     BindKeyObj( nKey2MoveLeft, True, False, NIL );
     BindKeyObj( nKey2MoveRight, True, False, NIL );
     BindKeyObj( nKey2Primary, True, False, NIL );
     BindKeyObj( nKey2Secondary, True, False, NIL );
     BindKeyObj( nKey2Primary, False, False, NIL );
     BindKeyObj( nKey2Secondary, False, False, NIL );

     // identification du vainqueur
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            If GetBombermanByCount(i).Score = nRoundCount Then
               nPlayer := GetBombermanByCount(i).BIndex;

     // affichage du vainqueur
     SetString( STRING_SCORE_TABLE(0), sPlayerName[nPlayer] + ' wins the match !', 1.0, 0.5, 300.0 );

     // affichage des scores
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
        begin
            aBomberman := GetBombermanByCount(i);
            SetString( STRING_SCORE_TABLE(i), aBomberman.Name + Format(' : %2d ; %d kill(s), %d death(s).', [aBomberman.Score, aBomberman.Kills, aBomberman.Deaths]), Single(i) * 0.1 + 0.5, 1.0, 300.0 );
        end;

     // mise à jour de la machine d'état interne
     nGame := GAME_SCORE;
End;



Procedure ProcessScore () ;
Var w, h : Single;
    i : Integer;
    k : Integer;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // définition de la camera
     SetCamera();

     // ajout de la lumière
     EnableLighting();
     PushObjectMatrix( 8.0, 0.0, 5.5, 0.5, 0.5, 0.5, 80.0, 0.0, 0.0 );
     SetLight( 0, 0.0, 0.0, 5.0, 0.8, 0.8, 0.8, 0.8, 0.0, 0.0, 0.0, True );
     PopObjectMatrix();
     For k := 1 To 7 Do Begin
         SetLight( k, 4999.999, 4999.999, 4999.999, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, False );
     End;
     SetMaterial( 0.4, 0.4, 0.4, 0.4 );

     // affichage du personnage
     SetTexture( 1, TEXTURE_BOMBERMAN(nPlayer) );
     PushObjectMatrix( 8.0, 0.0, 5.5, 0.5, 0.5, 0.5, 80.0, GetTime * 60.0, 0.0 );
     DrawMesh( MESH_BOMBERMAN(nPlayer), False );
     PopObjectMatrix();

     // affichage du vainqueur
     DrawString( STRING_SCORE_TABLE(0), -w / h * 0.9, 0.9, -1, 0.036 * w / h, 0.048, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     // affichage des scores
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            DrawString( STRING_SCORE_TABLE(i), -w / h * 0.9, 0.7 - 0.2 * Single(i), -1, 0.018 * w / h, 0.024, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     If GetKey(KEY_ENTER) Then InitMenu();
End;





























////////////////////////////////////////////////////////////////////////////////
// PHASE D'ATTENTE ENTRE DEUX ROUNDS                                          //
////////////////////////////////////////////////////////////////////////////////



Procedure InitWait () ;
Var i : Integer;
Begin
     // initialisation de la minuterie d'attente
     fWaitTime := GetTime;

     // suppression des touches des joueurs
     BindKeyObj( nKey1MoveUp, True, False, NIL );
     BindKeyObj( nKey1MoveDown, True, False, NIL );
     BindKeyObj( nKey1MoveLeft, True, False, NIL );
     BindKeyObj( nKey1MoveRight, True, False, NIL );
     BindKeyObj( nKey1Primary, True, False, NIL );
     BindKeyObj( nKey1Secondary, True, False, NIL );
     BindKeyObj( nKey1Primary, False, False, NIL );
     BindKeyObj( nKey1Secondary, False, False, NIL );
     
     BindKeyObj( nKey2MoveUp, True, False, NIL );
     BindKeyObj( nKey2MoveDown, True, False, NIL );
     BindKeyObj( nKey2MoveLeft, True, False, NIL );
     BindKeyObj( nKey2MoveRight, True, False, NIL );
     BindKeyObj( nKey2Primary, True, False, NIL );
     BindKeyObj( nKey2Secondary, True, False, NIL );
     BindKeyObj( nKey2Primary, False, False, NIL );
     BindKeyObj( nKey2Secondary, False, False, NIL );

     // affichage du vainqueur
     If CheckEndGame() <= 0 Then Begin
        SetString( STRING_SCORE_TABLE(0), 'draw game!', 1.0, 0.5, 300.0 );
     End Else Begin
        SetString( STRING_SCORE_TABLE(0), GetBombermanByIndex(CheckEndGame()).Name + ' wins the round.', 1.0, 0.5, 300.0 );
        If ( bMulti = false ) Or ( nLocalIndex = nClientIndex[0] ) Then
           GetBombermanByIndex(CheckEndGame()).UpScore();
     End;

     // affichage des scores
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            SetString( STRING_SCORE_TABLE(i), GetBombermanByCount(i).Name + Format(' : %2d ; %d kill(s), %d death(s).', [GetBombermanByCount(i).Score, GetBombermanByCount(i).Kills, GetBombermanByCount(i).Deaths]), Single(i) * 0.1 + 0.5, 1.0, 300.0 );

     // mise à jour de la machine d'état interne
     nGame := GAME_WAIT;
End;



Procedure ProcessWait () ;
Var w, h : Single;
    i : Integer;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     // définition de la camera
     SetCamera();

     // rendu des reflets
     If bReflection Then Begin
        PushObjectMatrix( 0, -1, 0, 1, -1, 1, 0, 0, 0 );
        DrawBomberman( 0.4, False );
        DrawGrid( 0.4 );
        DrawBomb( 0.4, False );
        DrawFlame( 0.4, False );
        PopObjectMatrix();
        PushObjectMatrix( 0, -1, 0, 1.2, -1.2, 1.2, 0, 0, 0 );
        DrawSkybox( 0.4, 0.4, 0.4, 0.4, TEXTURE_MAP_SKYBOX(0) );
        PopObjectMatrix();
     End;

     // rendu global
     DrawPlane( 1.0 );
     DrawBomberman( 1.0, False );
     DrawGrid( 1.0 );
     DrawBomb( 1.0, False );
     DrawFlame( 1.0, True );
     DrawSkybox( 1.0, 1.0, 1.0, 1.0, TEXTURE_MAP_SKYBOX(0) );

     // affichage du vainqueur
     DrawString( STRING_SCORE_TABLE(0), -w / h * 0.9, 0.9, -1, 0.036 * w / h, 0.048, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     // affichage des scores
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            DrawString( STRING_SCORE_TABLE(i), -w / h * 0.9, 0.7 - 0.2 * Single(i), -1, 0.018 * w / h, 0.024, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     If GetKey(KEY_ENTER) Then Begin
       If (bMulti = False) Or ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Then Begin
          InitRound();
       End;
     End;
End;





























////////////////////////////////////////////////////////////////////////////////
// PHASE DE JEU                                                               //
////////////////////////////////////////////////////////////////////////////////



Procedure InitRound () ;
Var i, j, l, k, m : Integer;
    sData : String;
Begin
     // supression des différents éléments du jeu
     FreeFlame();
     FreeBomb();
     FreeTimer();

     // initialisation des informations
     SetString( STRING_NOTIFICATION, 'fight!', 0.0, 0.2, 10 );

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // rechargement de la grille
     If (bMulti = True) And (nLocalIndex = nClientIndex[0]) And (nScheme = -1) Then Begin
        nSchemeMulti := Random(nSchemeCount);
        LoadScheme();
        sData := IntToStr(nScheme) + #31;
        sData := sData + IntToStr(nSchemeMulti) + #31;
        sData := sData + IntToStr(nMap) + #31;
        sData := sData + IntToStr(nRoundCount) + #31;
        Send( nLocalIndex, HEADER_SETUP, sData );
     End;
     pGrid.LoadScheme( pScheme );

     // restauration des bomberman
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            GetBombermanByCount(i).Restore();

     // chargement de la map
     LoadMap();

     // lancement du jeu
     nGame := GAME_ROUND;

     // ajout d'un round
     nRound += 1;

     fPingTime := GetTime();
     
     // affectation des touches au joueur 1
     If pPlayer1 <> NIL Then Begin
        BindKeyObj( nKey1MoveUp, True, False, @pPlayer1.MoveUp );
        BindKeyObj( nKey1MoveDown, True, False, @pPlayer1.MoveDown );
        BindKeyObj( nKey1MoveLeft, True, False, @pPlayer1.MoveLeft );
        BindKeyObj( nKey1MoveRight, True, False, @pPlayer1.MoveRight );
        BindKeyObj( nKey1Primary, True, False, @pPlayer1.PrimaryKeyDown );
        BindKeyObj( nKey1Secondary, True, False, @pPlayer1.SecondaryKeyDown );
        BindKeyObj( nKey1Primary, False, False, @pPlayer1.PrimaryKeyUp );
        BindKeyObj( nKey1Secondary, False, False, @pPlayer1.SecondaryKeyUp );
     End;

     // affectation des touches au joueur 2
     If pPlayer2 <> NIL Then Begin
        BindKeyObj( nKey2MoveUp, True, False, @pPlayer2.MoveUp );
        BindKeyObj( nKey2MoveDown, True, False, @pPlayer2.MoveDown );
        BindKeyObj( nKey2MoveLeft, True, False, @pPlayer2.MoveLeft );
        BindKeyObj( nKey2MoveRight, True, False, @pPlayer2.MoveRight );
        BindKeyObj( nKey2Primary, True, False, @pPlayer2.PrimaryKeyDown );
        BindKeyObj( nKey2Secondary, True, False, @pPlayer2.SecondaryKeyDown );
        BindKeyObj( nKey2Primary, False, False, @pPlayer2.PrimaryKeyUp );
        BindKeyObj( nKey2Secondary, False, False, @pPlayer2.SecondaryKeyUp );
     End;

     // fin de partie si un joueur a gagné un certain nombre de rounds
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            If GetBombermanByCount(i).Score = nRoundCount Then
               InitScore();

     If bMulti = True Then Begin
        If nLocalIndex = nClientIndex[0] Then Begin
          For i := 1 To GRIDWIDTH Do Begin
               For j := 1 To GRIDHEIGHT Do Begin
                   numDisease[i, j] := -1;
               End;
           End;
           sData := '';
           For i := 1 To GRIDWIDTH Do Begin
               For j := 1 To GRIDHEIGHT Do Begin
                   If ( pGrid.GetBlock(i, j) Is CItem ) Then Begin
                      If ( pGrid.GetBlock(i, j) Is CExtraBomb ) Then Begin
                         sData := sData + IntToStr( POWERUP_EXTRABOMB );
                         sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CFlameUp ) Then Begin
                           sData := sData + IntToStr( POWERUP_FLAMEUP );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CDisease ) Then Begin // Attention : Plusieurs types de maladies.
                           sData := sData + IntToStr( POWERUP_DISEASE );
                           sData := sData + #31;
                           numDisease[i, j] := Random(DISEASECOUNT) + 1;
                           sData := sData + IntToStr( numDisease[i, j] );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CKick ) Then Begin
                           sData := sData + IntToStr( POWERUP_KICK );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CSpeedUp ) Then Begin
                           sData := sData + IntToStr( POWERUP_SPEEDUP );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CPunch ) Then Begin
                           sData := sData + IntToStr( POWERUP_PUNCH );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CGrab ) Then Begin
                           sData := sData + IntToStr( POWERUP_GRAB );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CSpoog ) Then Begin
                           sData := sData + IntToStr( POWERUP_SPOOGER );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CGoldFlame ) Then Begin
                           sData := sData + IntToStr( POWERUP_GOLDFLAME );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CTrigger ) Then Begin
                           sData := sData + IntToStr( POWERUP_TRIGGERBOMB );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CJelly ) Then Begin
                           sData := sData + IntToStr( POWERUP_JELLYBOMB );
                           sData := sData + #31;
                      End
                      Else If ( pGrid.GetBlock(i, j) Is CSuperDisease ) Then Begin  // Plusieurs types de maladies.
                           sData := sData + IntToStr( POWERUP_SUPERDISEASE );
                           sData := sData + #31;
                           Repeat
                                 k := Random(DISEASECOUNT)+1;
                           Until ( k <> DISEASE_SWITCH );
                           Repeat
                                 l := Random(DISEASECOUNT)+1;
                           Until ( l <> k ) And ( l <> DISEASE_SWITCH );
                           Repeat
                                 m := Random(DISEASECOUNT)+1;
                           Until ( m <> k ) And ( m <> l ) And ( m <> DISEASE_SWITCH );
                           numDisease[i, j] := k + 100 * l + 10000 * i;
                           sData := sData + IntToStr( k + 100 * l + 10000 * i );
                           sData := sData + #31;
                      End
                      Else Begin                  // Cela ne devrait jamais arriver... et poutant : POWERUP_RANDOM
                           sData := sData + IntToStr( POWERUP_FLAMEUP );
                           sData := sData + #31;
                           pGrid.aBlock[i, j].Destroy();
                           pGrid.aBlock[i, j] := CFlameUp.Create(i,j);
                      End;
                   End;
               End;
           End;
           If ( sData = '' ) Then sData := #31;
           Send( nLocalIndex, HEADER_ROUND, sData );
        End;
     End;

     // initialisation de la minuterie du round
     If ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Or (bMulti = False) Then fRoundTime := GetTime();
End;



Procedure InitGame () ;
Var  k: Integer;
Begin
     // enregistrement des paramètres
     WriteSettings( 'atominsa.cfg' );

     // initialisation de l'invite de messages
     bMessage := False;
     sMessage := '';
     
     // suppression de tous les bomberman
     FreeBomberman();
     
     // supression des différents éléments du jeu
     FreeFlame();
     FreeBomb();
     FreeTimer();

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // chargement du scheme
     If nScheme = -1 Then Begin
        pScheme := aSchemeList[Trunc(Random(nSchemeCount))];
     End Else Begin
        pScheme := aSchemeList[nScheme];
     End;
     
     // création de la grille en fonction du scheme
     pGrid := CGrid.Create( pScheme );

     // création des bombermen
     pPlayer1 := NIL;
     pPlayer2 := NIL;
     For k := 1 To 8 Do Begin // pour des random spawn on crééra une liste 1..8 de chiffres random parmi 1..8 sans remise
       If ((bMulti = True) And (nLocalIndex = nPlayerClient[k])) Or (bMulti = False) Then Begin
           Case nPlayerType[k] Of
                PLAYER_KB1 :
                     pPlayer1 := AddBomberman( sPlayerName[k], k, k, SKILL_PLAYER, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
                PLAYER_KB2 :
                     pPlayer2 := AddBomberman( sPlayerName[k], k, k, SKILL_PLAYER, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
                PLAYER_COM :
                     AddBomberman( sPlayerName[k], k, k, nPlayerSkill[k], pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
           End;
       End Else Begin
           Case nPlayerType[k] Of
                PLAYER_KB1 :
                     AddBomberman( sPlayerName[k], k, k, SKILL_PLAYER, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
                PLAYER_KB2 :
                     AddBomberman( sPlayerName[k], k, k, SKILL_PLAYER, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
                PLAYER_COM :
                     AddBomberman( sPlayerName[k], k, k, SKILL_PLAYER, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
           End;
       End;
     End;

     // mise à zéro de la minuterie du jeu
     fGameTime := GetTime();

     // initialisation du premier round
     nRound := 0;
     If ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Or (bMulti = False) Then InitRound();
     
     // initialisation du panneau d'affichage
     InitScreen();
     AddStringToScreen( 'Welcome to Bomberman Returns!' ); // IL VA FALLOIR QU'ON TROUVE UN VRAI TITRE
     AddStringToScreen( 'Good luck!   Have fun!' );
End;



Procedure ProcessGame () ;
    Procedure Render( p : Single ) ;
    Begin
        // définition de la camera
        SetCamera();

        // rendu des reflets
        If bReflection Then Begin
          PushObjectMatrix( 0, -1, 0, 1, -1, 1, 0, 0, 0 );
          DrawBomberman( p * 0.4, False );
          DrawGrid( p * 0.4 );
          DrawBomb( p * 0.4, False );
          DrawFlame( p * 0.4, False );
          PopObjectMatrix();
          PushObjectMatrix( 0, -1, 0, 1.2, -1.2, 1.2, 0, 0, 0 );
          DrawSkybox( p * 0.4, p * 0.4, p * 0.4, p * 0.4, TEXTURE_MAP_SKYBOX(0) );
          PopObjectMatrix();
        End;

        // rendu global
        DrawPlane( p * 1.0 );
        DrawBomberman( p * 1.0, True );
        DrawGrid( p * 1.0 );
        DrawBomb( p * 1.0, True );
        DrawFlame( p * 1.0, True );
        DrawSkybox( p * 1.0, p * 1.0, p * 1.0, p * 1.0, TEXTURE_MAP_SKYBOX(0) );

        // affichage de l'invite de messages
        If bMulti Then DrawMessage( p * 1.0 );

        // affichage des informations
        DrawNotification( p * 1.0 );

        // affichage des scores
        DrawScore( p * 1.0 );

        // affichage de la minuterie
        DrawTimer( p * 1.0 );

        // affichage du panneau d'affichage
        DrawScreen( p * 1.0 );
    End;
    Procedure SetupEffect() ;
    Var k, n : Integer;
        p : GLint;
        tExplosion : LPExplosion;
        x, y, t, s : Single;
    Begin
         UpdateExplosion();

         p := glGetUniformLocationARB( ShaderProgram, PChar('color') );
         glUniform4fARB( p, 1.0, 1.0, 1.0, 0.8 );

         If nShaderModel = 2 Then Begin
            n := GetExplosionCount();
            If n > 4 Then n := 4;
         End Else Begin
            n := GetExplosionCount();
            If n > 8 Then n := 8;

            p := glGetUniformLocationARB( ShaderProgram, PChar('count') );
            glUniform1iARB( p, n );
         End;

         For k := 1 To n Do Begin
             tExplosion := GetExplosion(k);
             If tExplosion <> NIL Then Begin
                x := tExplosion^.X * 0.063;
                y := 0.83 - tExplosion^.Y * 0.063;
                t := (GetTime() - tExplosion^.T) / EXPLOSION_DURATION;
                s := 0.2 * (0.6 - t) * (0.6 - t);

                If nShaderModel = 4 Then Begin
                   p := glGetUniformLocationARB( ShaderProgram, PChar('center') ) + 2 * (k - 1);
                   glUniform2fARB( p, x, y );
                   p := glGetUniformLocationARB( ShaderProgram, PChar('inbound') ) + (k - 1);;
                   glUniform1fARB( p, t );
                   p := glGetUniformLocationARB( ShaderProgram, PChar('exbound') ) + (k - 1);;
                   glUniform1fARB( p, t + 0.2 - s );
                   p := glGetUniformLocationARB( ShaderProgram, PChar('strength') ) + (k - 1);;
                   glUniform1fARB( p, s );
                End Else Begin
                   p := glGetUniformLocationARB( ShaderProgram, PChar('center' + IntToStr(k)) );
                   glUniform2fARB( p, x, y );
                   p := glGetUniformLocationARB( ShaderProgram, PChar('inbound' + IntToStr(k)) );
                   glUniform1fARB( p, t );
                   p := glGetUniformLocationARB( ShaderProgram, PChar('exbound' + IntToStr(k)) );
                   glUniform1fARB( p, t + 0.2 - s );
                   p := glGetUniformLocationARB( ShaderProgram, PChar('strength' + IntToStr(k)) );
                   glUniform1fARB( p, s );
                End;
             End;
         End;
    End;
Var k : Integer;
    sData : String;
    w, h : Single; // taille de la fenêtre
Begin
     // récupération de la taille de la fenêtre
     w := GetRenderWidth();
     h := GetRenderHeight();

     // gestion de l'effet de motion blur
     If bBlur Then Begin
        If bEffects Then Begin
           // appel d'une texture de rendu
           PutRenderTexture();

           // rendu plus sombre
           Render( 0.4 );
            
           glUseProgramObjectARB( ShaderProgram );

           SetupEffect();
           
           // affichage du rendu précédent en transparence pour l'effet de flou
           SetRenderTexture();
           DrawImage( 0, 0, -1, 1, 1, 1.0, 1.0, 1.0, 0.8, True );

           glUseProgramObjectARB( 0 );

           // récupération de la texture de rendu
           GetRenderTexture();

           // remplissage noir de l'écran
           Clear( 0.0, 0.0, 0.0, 0.0 );

           // affichage final du rendu
           SetRenderTexture();
           DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 1, False );
        End Else Begin
           // appel d'une texture de rendu
           PutRenderTexture();

           // rendu plus sombre
           Render( 0.4 );

           // affichage du rendu précédent en transparence pour l'effet de flou
           SetRenderTexture();
           DrawImage( 0, 0, -1, 1, 1, 1.0, 1.0, 1.0, 0.8, True );

           // récupération de la texture de rendu
           GetRenderTexture();

           // remplissage noir de l'écran
           Clear( 0.0, 0.0, 0.0, 0.0 );

           // affichage final du rendu
           SetRenderTexture();
           DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 1, False );
        End;
     End Else Begin
        If bEffects Then Begin
           // appel d'une texture de rendu
           PutRenderTexture();

           // rendu normal
           Render( 1.0 );

           // récupération de la texture de rendu
           GetRenderTexture();

           // remplissage noir de l'écran
           Clear( 0.0, 0.0, 0.0, 0.0 );

           glUseProgramObjectARB( ShaderProgram );

           SetupEffect();

           // affichage final du rendu
           SetRenderTexture();
           DrawImage( 0, 0, -1, w / h, 1, 1, 1, 1, 1, False );

           glUseProgramObjectARB( 0 );
        End Else Begin
           // rendu normal
           Render( 1.0 );
        End;
     End;

     // gestion de l'intelligence artificielle
     For k := 1 To GetBombermanCount() Do Begin
         If ( GetBombermanByCount(k) Is CBomberman ) And ( GetBombermanByCount(k).Alive = true )
         And ( ( bMulti = false ) Or ( nPlayerClient[GetBombermanByCount(k).nIndex] = nLocalIndex ) )  Then Begin
            If nPlayerType[GetBombermanByCount(k).BIndex] = PLAYER_COM Then
               ProcessComputer( GetBombermanByCount(k), nPlayerSkill[GetBombermanByCount(k).BIndex] );
         End;
     End;
     
     // mise à jour de la minuterie
     CheckTimer();

     // force l'arrêt du round par la minuterie
     If GetKeyS( KEY_F10 ) Then Begin
        If (bMulti = False) Or ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Then Begin
           fRoundTime := fRoundTime - fRoundDuration - 3.0;
        End;
     End;
        
     // vérifie s'il reste des bomberman en jeu ou si la minuterie est à zéro
     If (CheckEndGame() <> 0) Or (GetTime >= fRoundTime + fRoundDuration + 3.0) Then Begin
        If (bMulti = False) Then Begin
           InitWait();
        End Else If ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Then Begin
           InitWait();
           sData := IntToStr(CheckEndGame()) + #31;
           If GetBombermanCount() <> 0 Then Begin
              For k := 1 To GetBombermanCount() Do Begin
                  sData := sData + IntToStr(GetBombermanByCount(k).Score) + #31;
                  sData := sData + IntToStr(GetBombermanByCount(k).Kills) + #31;
                  sData := sData + IntToStr(GetBombermanByCount(k).Deaths) + #31;
              End;
           End;
           Send( nLocalIndex, HEADER_WAIT, sData );
        End;
     End;

     // force l'abandon du jeu
     If GetKey( KEY_ESC ) Then Begin
        If (bMulti = False) Then Begin
           InitMenu();
           ClearInput();
        End Else If ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Then Begin
            // TODO
            // retour au menu multi et envoi d'un paquet serveur -> client signalant la fin forcée du jeu
        End Else Begin
            // TODO
            // retour au menu principal et envoi d'un paquet client -> serveur signalant la déconnexion du joueur
        End;
     End;
 End;





























////////////////////////////////////////////////////////////////////////////////
// MENU JOUEUR                                                                //
////////////////////////////////////////////////////////////////////////////////



Function PlayerInfo( nConst : Integer ) : String ;
Begin
     If (bMulti = True) And (nPlayerClient[nConst] <> nLocalIndex) Then Begin
       Case nPlayerType[nConst] Of
            PLAYER_NIL :
            Begin
                 PlayerInfo := 'none';
            End;
            PLAYER_KB1 :
            Begin
                 PlayerInfo := 'network              : ' + sPlayerName[nConst];
            End;
            PLAYER_KB2 :
            Begin
                 PlayerInfo := 'network              : ' + sPlayerName[nConst];
            End;
            PLAYER_COM :
            Begin
                 PlayerInfo := 'network              : ' + sPlayerName[nConst];
            End;
       End;
     End Else Begin
       Case nPlayerType[nConst] Of
            PLAYER_NIL :
            Begin
                 PlayerInfo := 'none';
            End;
            PLAYER_KB1 :
            Begin
                 PlayerInfo := 'keyboard 1           : ' + sPlayerName[nConst];
            End;
            PLAYER_KB2 :
            Begin
                 PlayerInfo := 'keyboard 2           : ' + sPlayerName[nConst];
            End;
            PLAYER_COM :
            Begin
                 If nPlayerSkill[nConst] = 1 Then PlayerInfo := 'computer (novice)    : ' + sPlayerName[nConst];
                 If nPlayerSkill[nConst] = 2 Then PlayerInfo := 'computer (average)   : ' + sPlayerName[nConst];
                 If nPlayerSkill[nConst] = 3 Then PlayerInfo := 'computer (masterful) : ' + sPlayerName[nConst];
                 If nPlayerSkill[nConst] = 4 Then PlayerInfo := 'computer (godlike)   : ' + sPlayerName[nConst];
            End;
       End;
     End;
End;

Function PlayerType() : String ;
Begin
     If (bMulti = True) And (nPlayerClient[nPlayer] <> nLocalIndex) Then Begin
       Case nPlayerType[nPlayer] Of
            PLAYER_NIL : PlayerType := 'none';
            PLAYER_KB1 : PlayerType := 'network';
            PLAYER_KB2 : PlayerType := 'network';
            PLAYER_COM : PlayerType := 'network';
       End;
     End Else Begin
       Case nPlayerType[nPlayer] Of
            PLAYER_NIL : PlayerType := 'none';
            PLAYER_KB1 : PlayerType := 'keyboard 1';
            PLAYER_KB2 : PlayerType := 'keyboard 2';
            PLAYER_COM : PlayerType := 'computer';
       End;
     End;
End;

Function PlayerSkill() : String ;
Begin
     Case nPlayerSkill[nPlayer] Of
        //  SKILL_PLAYER    : PlayerSkill := 'player';
          SKILL_NOVICE    : PlayerSkill := 'novice';
          SKILL_AVERAGE   : PlayerSkill := 'average';
          SKILL_MASTERFUL : PlayerSkill := 'masterful';
          SKILL_GODLIKE   : PlayerSkill := 'godlike'
          else PlayerSkill := 'player';
     End;
End;



Procedure InitMenuPlayer ( n : Integer ) ;
Var k : Integer; sData : String;
Begin
     If bMulti = True Then Begin
        If (nPlayerClient[n] <> -1) And (nPlayerClient[n] <> nLocalIndex) Then Exit;
        nPlayerClient[n] := nLocalIndex;
        
        sData := IntToStr(n) + #31;
        Send( nLocalIndex, HEADER_LOCK, sData );
     End;
     
     // identification du joueur modifié
     nPlayer := n;
     
     // ajout du titre
     SetString( STRING_GAME_MENU(2), 'player ' + IntToStr(nPlayer), 0.2, 0.2, 600 );

     // ajout du menu
     SetString( STRING_GAME_MENU(61), 'name : ' + sPlayerName[nPlayer], 0.2, 1.0, 600 );
     If nPlayerCharacter[nPlayer] = -1 Then Begin
        pPlayerCharacter[nPlayer] := aCharacterList[Trunc(Random(nCharacterCount))];
        SetString( STRING_GAME_MENU(62), 'character : ' + 'random', 0.2, 1.0, 600 );
     End Else Begin
        pPlayerCharacter[nPlayer] := aCharacterList[nPlayerCharacter[nPlayer]];
        SetString( STRING_GAME_MENU(62), 'character : ' + pPlayerCharacter[nPlayer].Name, 0.2, 1.0, 600 );
     End;
     SetString( STRING_GAME_MENU(63), 'type : ' + PlayerType, 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(64), 'skill : ' + PlayerSkill, 0.2, 1.0, 600 );

     // ajout du bouton back
     SetString( STRING_GAME_MENU(71), 'back', 0.2, 0.5, 600 );

     // modification de la machine d'état interne
     nGame := GAME_MENU_PLAYER;

     // initialisation du menu
     nMenu := MENU_PLAYER_BACK;

     // remise à zéro des touches
     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     fKey := 0.0;
End;



Procedure ProcessMenuPlayer () ;
          Function IsActive( nConst : Integer ) : Single ;
          Begin
               If nConst = nMenu Then IsActive := 0.0 Else IsActive := 1.0;
          End;
Var w, h : Single;
    t : Single;
    k : Integer;
    sData : String;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // définition de la camera
     SetCamera();

     // ajout de la lumière
     EnableLighting();
     PushObjectMatrix( 8.0, 0.0, 5.5, 0.5, 0.5, 0.5, 80.0, 0.0, 0.0 );
     SetLight( 0, 0.0, 0.0, 5.0, 0.8, 0.8, 0.8, 0.8, 0.0, 0.0, 0.0, True );
     PopObjectMatrix();
     For k := 1 To 7 Do Begin
         SetLight( k, 4999.999, 4999.999, 4999.999, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, False );
     End;
     SetMaterial( 0.4, 0.4, 0.4, 0.4 );

     // affichage du personnage
     SetTexture( 1, TEXTURE_BOMBERMAN(nPlayer) );
     PushObjectMatrix( 8.0, 0.0, 5.5, 0.5, 0.5, 0.5, 80.0, GetTime * 60.0, 0.0 );
     DrawMesh( MESH_BOMBERMAN(nPlayer), False );
     PopObjectMatrix();

     // affichage du menu
     DrawString( STRING_GAME_MENU(2), -w / h * 0.4,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.3;
     DrawString( STRING_GAME_MENU(61), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER_NAME), IsActive(MENU_PLAYER_NAME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(62), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER_CHARACTER), IsActive(MENU_PLAYER_CHARACTER), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(63), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER_TYPE), IsActive(MENU_PLAYER_TYPE), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     If nPlayerType[nPlayer] = PLAYER_COM Then
        DrawString( STRING_GAME_MENU(64), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER_SKILL), IsActive(MENU_PLAYER_SKILL), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(71), -w / h * -0.6, -0.8, -1, 0.024 * w / h, 0.036, 1.0, IsActive(MENU_PLAYER_BACK), IsActive(MENU_PLAYER_BACK), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nGame := GAME_MENU;
        SetString( STRING_GAME_MENU(10 + nPlayer), PlayerInfo(nPlayer), 0.0, 0.02, 600 );
        nMenu := MENU_PLAYER1 + nPlayer - 1;
        ClearInput();
     End;

     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_PLAYER_CHARACTER Then nMenu := MENU_PLAYER_NAME Else
           If nMenu = MENU_PLAYER_TYPE Then nMenu := MENU_PLAYER_CHARACTER Else
           If nMenu = MENU_PLAYER_SKILL Then nMenu := MENU_PLAYER_TYPE Else
           If nMenu = MENU_PLAYER_BACK Then nMenu := MENU_PLAYER_SKILL Else
           If nMenu = MENU_PLAYER_NAME Then nMenu := MENU_PLAYER_BACK;
           If (nPlayerType[nPlayer] <> PLAYER_COM) And (nMenu = MENU_PLAYER_SKILL) Then nMenu := MENU_PLAYER_TYPE;
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;

     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_PLAYER_BACK Then nMenu := MENU_PLAYER_NAME Else
           If nMenu = MENU_PLAYER_NAME Then nMenu := MENU_PLAYER_CHARACTER Else
           If nMenu = MENU_PLAYER_CHARACTER Then nMenu := MENU_PLAYER_TYPE Else
           If nMenu = MENU_PLAYER_TYPE Then nMenu := MENU_PLAYER_SKILL Else
           If nMenu = MENU_PLAYER_SKILL Then nMenu := MENU_PLAYER_BACK;
           If (nPlayerType[nPlayer] <> PLAYER_COM) And (nMenu = MENU_PLAYER_SKILL) Then nMenu := MENU_PLAYER_BACK;
        End;
        bDown := True;
     End Else Begin
        bDown := False;
     End;

     If GetKeyS( KEY_LEFT ) Then Begin
        If Not bLeft Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_PLAYER_SKILL :
                Begin
                     nPlayerSkill[nPlayer] -= 1;
                     If nPlayerSkill[nPlayer] < 1 Then nPlayerSkill[nPlayer] := 1;
                     SetString( STRING_GAME_MENU(64), 'skill : ' + PlayerSkill, 0.0, 0.02, 600 );
                End;
                MENU_PLAYER_TYPE :
                Begin
                     If nPlayerType[nPlayer] = PLAYER_KB1 Then nPlayerType[nPlayer] := PLAYER_NIL;
                     If nPlayerType[nPlayer] = PLAYER_KB2 Then nPlayerType[nPlayer] := PLAYER_KB1;
                     If nPlayerType[nPlayer] = PLAYER_COM Then nPlayerType[nPlayer] := PLAYER_KB2;
                     SetString( STRING_GAME_MENU(63), 'type : ' + PlayerType, 0.0, 0.02, 600 );
                End;
                MENU_PLAYER_CHARACTER :
                Begin
                     nPlayerCharacter[nPlayer] -= 1;
                     If nPlayerCharacter[nPlayer] < -1 Then nPlayerCharacter[nPlayer] := nCharacterCount - 1;
                     LoadCharacter( nPlayer );
                     If nPlayerCharacter[nPlayer] = -1 Then Begin
                        SetString( STRING_GAME_MENU(62), 'character : ' + 'random', 0.0, 0.02, 600 );
                     End Else Begin
                        SetString( STRING_GAME_MENU(62), 'character : ' + pPlayerCharacter[nPlayer].Name, 0.0, 0.02, 600 );
                     End;
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
                MENU_PLAYER_SKILL :
                Begin
                     nPlayerSkill[nPlayer] += 1;
                     If nPlayerSkill[nPlayer] > 4 Then nPlayerSkill[nPlayer] := 4;
                     SetString( STRING_GAME_MENU(64), 'skill : ' + PlayerSkill, 0.0, 0.02, 600 );
                End;
                MENU_PLAYER_TYPE :
                Begin
                     If nPlayerType[nPlayer] = PLAYER_KB2 Then nPlayerType[nPlayer] := PLAYER_COM;
                     If nPlayerType[nPlayer] = PLAYER_KB1 Then nPlayerType[nPlayer] := PLAYER_KB2;
                     If nPlayerType[nPlayer] = PLAYER_NIL Then nPlayerType[nPlayer] := PLAYER_KB1;
                     SetString( STRING_GAME_MENU(63), 'type : ' + PlayerType, 0.0, 0.02, 600 );
                End;
                MENU_PLAYER_CHARACTER :
                Begin
                     nPlayerCharacter[nPlayer] += 1;
                     If nPlayerCharacter[nPlayer] = nCharacterCount Then nPlayerCharacter[nPlayer] := -1;
                     LoadCharacter( nPlayer );
                     If nPlayerCharacter[nPlayer] = -1 Then Begin
                        SetString( STRING_GAME_MENU(62), 'character : ' + 'random', 0.0, 0.02, 600 );
                     End Else Begin
                        SetString( STRING_GAME_MENU(62), 'character : ' + pPlayerCharacter[nPlayer].Name, 0.0, 0.02, 600 );
                     End;
                End;
           End;
        End;
        bRight := True;
     End Else Begin
        bRight := False;
     End;

     If GetKey( KEY_ENTER ) Then Begin
        If Not bEnter Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_PLAYER_BACK :
                Begin
                     nGame := GAME_MENU;
                     SetString( STRING_GAME_MENU(10 + nPlayer), PlayerInfo(nPlayer), 0.0, 0.02, 600 );
                     nMenu := MENU_PLAYER1 + nPlayer - 1;
                     If bMulti = True Then Begin
                        If nPlayerType[nPlayer] = PLAYER_NIL Then Begin
                           nPlayerClient[nPlayer] := -1;

                           sData := IntToStr(nPlayer) + #31;
                           Send( nLocalIndex, HEADER_UNLOCK, sData );
                        End Else Begin
                            sData := IntToStr(nPlayer) + #31;
                            sData := sData + IntToStr(nPlayerType[nPlayer]) + #31;
                            sData := sData + IntToStr(nPlayerSkill[nPlayer]) + #31;
                            sData := sData + IntToStr(nPlayerCharacter[nPlayer]) + #31;
                            sData := sData + sPlayerName[nPlayer] + #31;
                            Send( nLocalIndex, HEADER_UPDATE, sData );
                        End;
                     End;
                End;
           End;
        End;
        bEnter := True;
     End Else Begin
        bEnter := False;
     End;

     If Ord(CheckKey()) > 0 Then Begin
        If GetTime > fKey Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_PLAYER_NAME :
                Begin
                     If Ord(CheckKey()) = 8 Then Begin
                        SetLength(sPlayerName[nPlayer], Length(sPlayerName[nPlayer]) - 1);
                     End Else Begin
                        sPlayerName[nPlayer] := sPlayerName[nPlayer] + CheckKey();
                     End;
                     SetString( STRING_GAME_MENU(61), 'name : ' + sPlayerName[nPlayer], 0.0, 0.02, 600 );
                End;
           End;
        End;
        fKey := GetTime + 0.2;
        ClearInput();
     End Else Begin
        fKey := 0.0;
     End;

End;





























////////////////////////////////////////////////////////////////////////////////
// MENU PRINCIPAL                                                             //
////////////////////////////////////////////////////////////////////////////////



Procedure UpdateMenu () ;
Begin
     // ajout du titre
     If (bMulti = True) Then Begin
          SetString( STRING_GAME_MENU(1), '  multi', 0.0, 0.02, 600 );
     End Else Begin
          SetString( STRING_GAME_MENU(1), 'practice', 0.0, 0.02, 600 );
     End;

     // ajout de la liste de joueurs
     SetString( STRING_GAME_MENU(11), PlayerInfo(1), 0.0, 0.02, 600 );
     SetString( STRING_GAME_MENU(12), PlayerInfo(2), 0.0, 0.02, 600 );
     SetString( STRING_GAME_MENU(13), PlayerInfo(3), 0.0, 0.02, 600 );
     SetString( STRING_GAME_MENU(14), PlayerInfo(4), 0.0, 0.02, 600 );
     SetString( STRING_GAME_MENU(15), PlayerInfo(5), 0.0, 0.02, 600 );
     SetString( STRING_GAME_MENU(16), PlayerInfo(6), 0.0, 0.02, 600 );
     SetString( STRING_GAME_MENU(17), PlayerInfo(7), 0.0, 0.02, 600 );
     SetString( STRING_GAME_MENU(18), PlayerInfo(8), 0.0, 0.02, 600 );

     // chargement et ajout du scheme
     LoadScheme();
     If nScheme = -1 Then Begin
        SetString( STRING_GAME_MENU(21), 'scheme : ' + 'random', 0.0, 0.02, 600 );
     End Else Begin
        SetString( STRING_GAME_MENU(21), 'scheme : ' + pScheme.Name, 0.0, 0.02, 600 );
     End;

     // chargement et ajout de la map
     LoadMap();
     If nMap = -1 Then Begin
        SetString( STRING_GAME_MENU(31), 'map : ' + 'random', 0.0, 0.02, 600 );
     End Else Begin
        SetString( STRING_GAME_MENU(31), 'map : ' + pMap.Name, 0.0, 0.02, 600 );
     End;

     // ajout du compteur de rounds
     SetString( STRING_GAME_MENU(41), 'round count : ' + IntToStr(nRoundCount), 0.0, 0.02, 600 );

     // ajout du bouton fight
     SetString( STRING_GAME_MENU(51), 'fight!', 0.0, 0.02, 600 );
End;



Procedure InitMenu () ;
Begin
     // ajout du titre
     If (bMulti = True) Then Begin
          SetString( STRING_GAME_MENU(1), '   multi', 0.2, 0.2, 600 );
     End Else Begin
          SetString( STRING_GAME_MENU(1), 'practice', 0.2, 0.2, 600 );
     End;

     // ajout de la liste de joueurs
     SetString( STRING_GAME_MENU(11), PlayerInfo(1), 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(12), PlayerInfo(2), 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(13), PlayerInfo(3), 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(14), PlayerInfo(4), 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(15), PlayerInfo(5), 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(16), PlayerInfo(6), 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(17), PlayerInfo(7), 0.2, 1.0, 600 );
     SetString( STRING_GAME_MENU(18), PlayerInfo(8), 0.2, 1.0, 600 );

     // chargement et ajout du scheme
     LoadScheme();
     If nScheme = -1 Then Begin
        SetString( STRING_GAME_MENU(21), 'scheme : ' + 'random', 0.2, 1.0, 600 );
     End Else Begin
        SetString( STRING_GAME_MENU(21), 'scheme : ' + pScheme.Name, 0.2, 1.0, 600 );
     End;

     // chargement et ajout de la map
     LoadMap();
     If nMap = -1 Then Begin
        SetString( STRING_GAME_MENU(31), 'map : ' + 'random', 0.2, 1.0, 600 );
     End Else Begin
        SetString( STRING_GAME_MENU(31), 'map : ' + pMap.Name, 0.2, 1.0, 600 );
     End;

     // ajout du compteur de rounds
     SetString( STRING_GAME_MENU(41), 'round count : ' + IntToStr(nRoundCount), 0.2, 1.0, 600 );

     // ajout du bouton fight
     SetString( STRING_GAME_MENU(51), 'fight!', 0.2, 0.5, 600 );

     // définition de la machine d'état interne
     nGame := GAME_MENU;

     // initialisation du menu
     nMenu := MENU_PLAYER1;

     // remise à zéro des touches
     bUp := False;
     bDown := False;
     bLeft := False;
     bRight := False;
     bEnter := False;
     fKey := 0.0;
End;



Procedure ProcessMenu () ;
          Function IsActive( nConst : Integer ) : Single ;
          Begin
               If nConst = nMenu Then IsActive := 0.0 Else IsActive := 1.0;
          End;
Var w, h : Single;
    t : Single;
    k : Integer;
    bSend : Boolean;
    sData : String;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // définition de la camera
     SetCamera();

     // rendu du plateau
     DrawPlane( 0.9 );
     DrawBomberman( 0.9, false );
     DrawGrid( 0.9 );
     DrawSkybox( 0.9, 0.9, 0.9, 0.9, TEXTURE_MAP_SKYBOX(0) );

     // affichage du menu
     DrawString( STRING_GAME_MENU(1), -w / h * 0.4,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.0;
     DrawString( STRING_GAME_MENU(11), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER1), IsActive(MENU_PLAYER1), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(12), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER2), IsActive(MENU_PLAYER2), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(13), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER3), IsActive(MENU_PLAYER3), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(14), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER4), IsActive(MENU_PLAYER4), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(15), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER5), IsActive(MENU_PLAYER5), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(16), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER6), IsActive(MENU_PLAYER6), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(17), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER7), IsActive(MENU_PLAYER7), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(18), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER8), IsActive(MENU_PLAYER8), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(21), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_SCHEME), IsActive(MENU_SCHEME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(31), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_MAP), IsActive(MENU_MAP), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_GAME_MENU(41), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_ROUNDCOUNT), IsActive(MENU_ROUNDCOUNT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_GAME_MENU(51), -w / h * -0.6, -0.8, -1, 0.024 * w / h, 0.036, 1.0, IsActive(MENU_FIGHT), IsActive(MENU_FIGHT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nState := PHASE_MENU;
        ClearInput();
     End;

     If GetKeyS( KEY_UP ) Then Begin
        If Not bUp Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_PLAYER2 Then nMenu := MENU_PLAYER1 Else
           If nMenu = MENU_PLAYER3 Then nMenu := MENU_PLAYER2 Else
           If nMenu = MENU_PLAYER4 Then nMenu := MENU_PLAYER3 Else
           If nMenu = MENU_PLAYER5 Then nMenu := MENU_PLAYER4 Else
           If nMenu = MENU_PLAYER6 Then nMenu := MENU_PLAYER5 Else
           If nMenu = MENU_PLAYER7 Then nMenu := MENU_PLAYER6 Else
           If nMenu = MENU_PLAYER8 Then nMenu := MENU_PLAYER7 Else
           If nMenu = MENU_SCHEME Then nMenu := MENU_PLAYER8 Else
           If nMenu = MENU_MAP Then nMenu := MENU_SCHEME Else
           If nMenu = MENU_ROUNDCOUNT Then nMenu := MENU_MAP Else
           If nMenu = MENU_FIGHT Then nMenu := MENU_ROUNDCOUNT Else
           If nMenu = MENU_PLAYER1 Then nMenu := MENU_FIGHT;
        End;
        bUp := True;
     End Else Begin
        bUp := False;
     End;

     If GetKeyS( KEY_DOWN ) Then Begin
        If Not bDown Then Begin
           PlaySound( SOUND_MENU_CLICK );
           If nMenu = MENU_FIGHT Then nMenu := MENU_PLAYER1 Else
           If nMenu = MENU_ROUNDCOUNT Then nMenu := MENU_FIGHT Else
           If nMenu = MENU_MAP Then nMenu := MENU_ROUNDCOUNT Else
           If nMenu = MENU_SCHEME Then nMenu := MENU_MAP Else
           If nMenu = MENU_PLAYER8 Then nMenu := MENU_SCHEME Else
           If nMenu = MENU_PLAYER7 Then nMenu := MENU_PLAYER8 Else
           If nMenu = MENU_PLAYER6 Then nMenu := MENU_PLAYER7 Else
           If nMenu = MENU_PLAYER5 Then nMenu := MENU_PLAYER6 Else
           If nMenu = MENU_PLAYER4 Then nMenu := MENU_PLAYER5 Else
           If nMenu = MENU_PLAYER3 Then nMenu := MENU_PLAYER4 Else
           If nMenu = MENU_PLAYER2 Then nMenu := MENU_PLAYER3 Else
           If nMenu = MENU_PLAYER1 Then nMenu := MENU_PLAYER2;
        End;
        bDown := True;
     End Else Begin
        bDown := False;
     End;

     If ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Or (bMulti = False) Then Begin
       If GetKeyS( KEY_LEFT ) Then Begin
          If Not bLeft Then Begin
             PlaySound( SOUND_MENU_CLICK );
             Case nMenu Of
                  MENU_SCHEME :
                  Begin
                       nScheme -= 1;
                       If nScheme < -1 Then nScheme := nSchemeCount - 1;
                       If ( nScheme = - 1 ) Then
                          nSchemeMulti := Random(nSchemeCount)
                       Else
                           nSchemeMulti := -1;
                       LoadScheme();
                       If nScheme = -1 Then Begin
                          SetString( STRING_GAME_MENU(21), 'scheme : ' + 'random', 0.0, 0.02, 600 );
                       End Else Begin
                          SetString( STRING_GAME_MENU(21), 'scheme : ' + pScheme.Name, 0.0, 0.02, 600 );
                       End;
                  End;
                  MENU_MAP :
                  Begin
                       nMap -= 1;
                       If nMap < -1 Then nMap := nMapCount - 1;
                       LoadMap();
                       If nMap = -1 Then Begin
                          SetString( STRING_GAME_MENU(31), 'map : ' + 'random', 0.0, 0.02, 600 );
                       End Else Begin
                          SetString( STRING_GAME_MENU(31), 'map : ' + pMap.Name, 0.0, 0.02, 600 );
                       End;
                  End;
                  MENU_ROUNDCOUNT :
                  Begin
                       nRoundCount -= 1;
                       If nRoundCount < 1 Then nRoundCount := 1;
                       SetString( STRING_GAME_MENU(41), 'round count : ' + IntToStr(nRoundCount), 0.0, 0.02, 600 );
                  End;
             End;
             If ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Then Begin
                sData := IntToStr(nScheme) + #31;
                sData := sData + IntToStr(nSchemeMulti) + #31;
                sData := sData + IntToStr(nMap) + #31;
                sData := sData + IntToStr(nRoundCount) + #31;
                Send( nLocalIndex, HEADER_SETUP, sData );
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
                  MENU_SCHEME :
                  Begin
                       nScheme += 1;
                       If nScheme = nSchemeCount Then nScheme := -1;
                       If ( nScheme = - 1 ) Then
                          nSchemeMulti := Random(nSchemeCount)
                       Else
                           nSchemeMulti := -1;
                       LoadScheme();
                       If nScheme = -1 Then Begin
                          SetString( STRING_GAME_MENU(21), 'scheme : ' + 'random', 0.0, 0.02, 600 );
                       End Else Begin
                          SetString( STRING_GAME_MENU(21), 'scheme : ' + pScheme.Name, 0.0, 0.02, 600 );
                       End;
                  End;
                  MENU_MAP :
                  Begin
                       nMap += 1;
                       If nMap = nMapCount Then nMap := -1;
                       LoadMap();
                       If nMap = -1 Then Begin
                          SetString( STRING_GAME_MENU(31), 'map : ' + 'random', 0.0, 0.02, 600 );
                       End Else Begin
                          SetString( STRING_GAME_MENU(31), 'map : ' + pMap.Name, 0.0, 0.02, 600 );
                       End;
                  End;
                  MENU_ROUNDCOUNT :
                  Begin
                       nRoundCount += 1;
                       If nRoundCount > 99 Then nRoundCount := 1;
                       SetString( STRING_GAME_MENU(41), 'round count : ' + IntToStr(nRoundCount), 0.0, 0.02, 600 );
                  End;
             End;
             If ((bMulti = True) And (nLocalIndex = nClientIndex[0])) Then Begin
                sData := IntToStr(nScheme) + #31;
                sData := sData + IntToStr(nSchemeMulti) + #31;
                sData := sData + IntToStr(nMap) + #31;
                sData := sData + IntToStr(nRoundCount) + #31;
                Send( nLocalIndex, HEADER_SETUP, sData );
             End;
          End;
          bRight := True;
       End Else Begin
          bRight := False;
       End;
     End;
     
     If GetKey( KEY_ENTER ) Then Begin
        If Not bEnter Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_PLAYER1 :
                     InitMenuPlayer(1);
                MENU_PLAYER2 :
                     InitMenuPlayer(2);
                MENU_PLAYER3 :
                     InitMenuPlayer(3);
                MENU_PLAYER4 :
                     InitMenuPlayer(4);
                MENU_PLAYER5 :
                     InitMenuPlayer(5);
                MENU_PLAYER6 :
                     InitMenuPlayer(6);
                MENU_PLAYER7 :
                     InitMenuPlayer(7);
                MENU_PLAYER8 :
                     InitMenuPlayer(8);
                MENU_FIGHT :
                If (bMulti = True) And (nLocalIndex = nClientIndex[0]) Then Begin
                    // Si un client est en train de choisir un personnage,
                    // le serveur n'a pas le droit de lancer la partie.
                    bSend := True;
                    For k := 1 To 8 Do Begin
                        If ( nPlayerClient[k] <> -1 ) And ( nPlayerType[k] = PLAYER_NIL ) Then
                           bSend := False;
                    End;
                    If ( bSend = True ) Then Begin
                       nGame := GAME_INIT;
                       Send( nLocalIndex, HEADER_FIGHT, sData );
                    End;
                End Else If (bMulti = False) Then Begin
                    nGame := GAME_INIT;
                End;
           End;
       End;
       bEnter := True;
     End Else Begin
        bEnter := False;
     End;

End;





























End.

