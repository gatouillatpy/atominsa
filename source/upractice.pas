Unit UPractice;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UUtils, UBlock, UItem, UScheme, USpawn, UBomberman, UDisease,
     USpeedUp, UExtraBomb, UFlameUp, UKick, UGrid, UFlame, UBomb, USetup, UForm,
     UCharacter, UComputer;



Procedure InitPractice () ;
Procedure ProcessPractice () ;



Implementation



Var bScoreTable : Boolean;



Var pGrid : CGrid;



Const CAMERA_FLY          = -1;
Const CAMERA_OVERALL      =  0;

Var nCamera  : Integer;
    vCamera  : Vector;
    vCenter  : Vector;
    vAngle   : Vector;
    vPointer : Vector;



Const PRACTICE_MENU         = 0;
Const PRACTICE_MENU_PLAYER  = 1;
Const PRACTICE_INIT         = 2;
Const PRACTICE_GAME         = 3;
Const PRACTICE_WAIT         = 4;
Const PRACTICE_SCORE        = 5;

Var nPractice  : Integer;



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



Var bUp     : Boolean;
Var bDown   : Boolean;
Var bLeft   : Boolean;
Var bRight  : Boolean;
Var bEnter  : Boolean;

Var fKey    : Single;



Procedure InitMenu () ; Forward;
Procedure InitScore () ; Forward;





























////////////////////////////////////////////////////////////////////////////////
// ENTRAINEMENT                                                               //
////////////////////////////////////////////////////////////////////////////////



Var nRound : Integer;
    fRoundTime : Single;
    fGameTime : Single;
    fWaitTime : Single;



Var pPlayer1 : CBomberman;
    pPlayer2 : CBomberman;



Procedure LoadScheme () ;
Var k : Integer;
Begin
     If nScheme = -1 Then Begin
        pScheme := aSchemeList[Trunc(Random(nSchemeCount))];
     End Else Begin
        pScheme := aSchemeList[nScheme];
     End;
     pGrid := CGrid.Create( pScheme );
     FreeBomberman();
     For k := 1 To 8 Do
         AddBomberman( 'temp', pScheme.Spawn(k).Team, pScheme.Spawn(k).Color, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
End;



Procedure LoadMap () ;
Begin
     If nMap = -1 Then Begin
        pMap := aMapList[Trunc(Random(nMapCount))];
     End Else Begin
        pMap := aMapList[nMap];
     End;
     DelMesh( MESH_BLOCK_SOLID );
     AddMesh( './maps/' + pMap.SolidMesh, MESH_BLOCK_SOLID );
     DelMesh( MESH_BLOCK_BRICK );
     AddMesh( './maps/' + pMap.BrickMesh, MESH_BLOCK_BRICK );
     DelMesh( MESH_PLANE );
     AddMesh( './maps/' + pMap.PlaneMesh, MESH_PLANE );
     DelTexture( TEXTURE_MAP_SOLID );
     AddTexture( './maps/' + pMap.SolidTexture, TEXTURE_MAP_SOLID );
     DelTexture( TEXTURE_MAP_BRICK );
     AddTexture( './maps/' + pMap.BrickTexture, TEXTURE_MAP_BRICK );
     DelTexture( TEXTURE_MAP_PLANE );
     AddTexture( './maps/' + pMap.PlaneTexture, TEXTURE_MAP_PLANE );
     DelTexture( TEXTURE_MAP_SKYBOX(1) );
     AddTexture( './maps/' + pMap.SkyboxBottom, TEXTURE_MAP_SKYBOX(1) );
     DelTexture( TEXTURE_MAP_SKYBOX(2) );
     AddTexture( './maps/' + pMap.SkyboxTop, TEXTURE_MAP_SKYBOX(2) );
     DelTexture( TEXTURE_MAP_SKYBOX(3) );
     AddTexture( './maps/' + pMap.SkyboxFront, TEXTURE_MAP_SKYBOX(3) );
     DelTexture( TEXTURE_MAP_SKYBOX(4) );
     AddTexture( './maps/' + pMap.SkyboxBack, TEXTURE_MAP_SKYBOX(4) );
     DelTexture( TEXTURE_MAP_SKYBOX(5) );
     AddTexture( './maps/' + pMap.SkyboxLeft, TEXTURE_MAP_SKYBOX(5) );
     DelTexture( TEXTURE_MAP_SKYBOX(6) );
     AddTexture( './maps/' + pMap.SkyboxRight, TEXTURE_MAP_SKYBOX(6) );
End;



Procedure InitRound () ;
Var i : Integer;
Begin
     // supression des différents éléments du jeu
     FreeFlame();
     FreeBomb();
     FreeTimer();
     
     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // rechargement de la grille
     pGrid.LoadScheme( pScheme );
     
     // restauration des bomberman
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            GetBombermanByCount(i).Restore();

     // chargement de la map
     LoadMap();

     // lancement du jeu
     nPractice := PRACTICE_GAME;

     // ajout d'un round
     nRound += 1;

     // affectation des touches au joueur 1
     If pPlayer1 <> NIL Then Begin
        BindKeyObj( nKey1MoveUp, False, @pPlayer1.MoveUp );
        BindKeyObj( nKey1MoveDown, False, @pPlayer1.MoveDown );
        BindKeyObj( nKey1MoveLeft, False, @pPlayer1.MoveLeft );
        BindKeyObj( nKey1MoveRight, False, @pPlayer1.MoveRight );
        BindKeyObj( nKey1Primary, True, @pPlayer1.CreateBomb );
        //BindKeyObj( nKey1Secondary, True, @pPlayer1.??? );
     End;
     
     // affectation des touches au joueur 2
     If pPlayer1 <> NIL Then Begin
        BindKeyObj( nKey2MoveUp, False, @pPlayer2.MoveUp );
        BindKeyObj( nKey2MoveDown, False, @pPlayer2.MoveDown );
        BindKeyObj( nKey2MoveLeft, False, @pPlayer2.MoveLeft );
        BindKeyObj( nKey2MoveRight, False, @pPlayer2.MoveRight );
        BindKeyObj( nKey2Primary, True, @pPlayer2.CreateBomb );
        //BindKeyObj( nKey2Secondary, True, @pPlayer2.??? );
     End;

     // fin de partie si un joueur a gagné un certain nombre de rounds
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            If GetBombermanByCount(i).Score = nRoundCount Then
               InitScore();
     
     // initialisation de la minuterie du round
     fRoundTime := GetTime;
End;



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
     End Else If nPractice = PRACTICE_WAIT Then Begin
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
        vCenter.x := GetBombermanByCount(nCamera).X;
        vCenter.y := 0.0;
        vCenter.z := GetBombermanByCount(nCamera).Y;
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



Procedure SetLighting ( h : Single ; a0, a1, a2 : Single ) ;
Var k : Integer;
Begin
     {SetLight( 0,                 0, h,                - 1, 1, 1, 1, 1, a0, a1, a2, True );
     SetLight( 1, GRIDWIDTH     - 1, h,                - 1, 1, 1, 1, 1, a0, a1, a2, True );
     SetLight( 2,                 0, h, GRIDHEIGHT     - 2, 1, 1, 1, 1, a0, a1, a2, True );
     SetLight( 3, GRIDWIDTH     - 1, h, GRIDHEIGHT     - 2, 1, 1, 1, 1, a0, a1, a2, True );
     SetLight( 4, GRIDWIDTH / 2 + 1, h, GRIDHEIGHT / 2 - 2, 1, 1, 1, 1, a0, a1, a2, True );}

     For k := 1 To 8 Do Begin
         SetLight( k - 1, 4999.999, 4999.999, 4999.999, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, False );
     End;

     If bLighting Then Begin
        If nPlayerType[1] > 0 Then If GetBombermanByIndex(1).Alive Then
           SetLight( 0, GetBombermanByIndex(1).X, h, GetBombermanByIndex(1).Y - 2, 1, 0, 0, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        If nPlayerType[2] > 0 Then If GetBombermanByIndex(2).Alive Then
           SetLight( 1, GetBombermanByIndex(2).X, h, GetBombermanByIndex(2).Y - 2, 0, 0, 1, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        If nPlayerType[3] > 0 Then If GetBombermanByIndex(3).Alive Then
           SetLight( 2, GetBombermanByIndex(3).X, h, GetBombermanByIndex(3).Y - 2, 0, 1, 0, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        If nPlayerType[4] > 0 Then If GetBombermanByIndex(4).Alive Then
           SetLight( 3, GetBombermanByIndex(4).X, h, GetBombermanByIndex(4).Y - 2, 1, 1, 0, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        If nPlayerType[5] > 0 Then If GetBombermanByIndex(5).Alive Then
           SetLight( 4, GetBombermanByIndex(5).X, h, GetBombermanByIndex(5).Y - 2, 0, 1, 1, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        If nPlayerType[6] > 0 Then If GetBombermanByIndex(6).Alive Then
           SetLight( 5, GetBombermanByIndex(6).X, h, GetBombermanByIndex(6).Y - 2, 1, 0, 1, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        If nPlayerType[7] > 0 Then If GetBombermanByIndex(7).Alive Then
           SetLight( 6, GetBombermanByIndex(7).X, h, GetBombermanByIndex(7).Y - 2, 1, 1, 1, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
        If nPlayerType[8] > 0 Then If GetBombermanByIndex(8).Alive Then
           SetLight( 7, GetBombermanByIndex(8).X, h, GetBombermanByIndex(8).Y - 2, 0, 0, 0, 1, a0 * 0.1, a1 * 0.5, a2 * 1.0, True );
     End;
End;



Procedure DrawBomberman ( w : Single ) ;
Var i : Integer;
Begin
     EnableLighting();
     SetLighting( 2.0, 1.0, 0.3, 0.6 );

     SetMaterial( w, w, w, 1.0 );

     For i := 1 To GetBombermanCount() Do
     Begin
          If GetBombermanByCount(i).Alive then
          Begin
               SetTexture( 1, TEXTURE_BOMBERMAN(i) );
               PushObjectMatrix( GetBombermanByCount(i).X-0.15, 0, GetBombermanByCount(i).Y-0.15, 0.05, 0.05, 0.05, 0, GetBombermanByCount(i).Direction, 0 );
               DrawMesh( MESH_BOMBERMAN(GetBombermanByCount(i).BIndex), False );
               PopObjectMatrix();
               GetBombermanByCount(i).Update(GetDelta());
          End;
     End;
End;



Procedure DrawGrid ( w : Single ) ;
Var i, j : Integer;
    pBlock : CBlock;
Begin
     EnableLighting();
     SetLighting( 5.0, 1.0, 1.8, 2.4 );

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
                    SetMaterial( w, w, 0, 1.0 );
                    SetTexture( 1, TEXTURE_NONE );
                    PushObjectMatrix( i, 0, j, 0.05, 0.05, 0.05, 0, 0, 0 );
                    DrawMesh( MESH_FLAMEUP, True );                /////////////////////Mette le mesh du Kick
                    PopObjectMatrix();
                 End Else If (pBlock Is CItem) Then Begin
                    SetMaterial( w, w, w, 1.0 );
                    SetTexture( 1, TEXTURE_MAP_BRICK );
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



Procedure DrawBomb ( w : Single ) ;
Var i : Integer;
Var r, g, b : Single;
Begin
     EnableLighting();
     SetLighting( 5.0, 1.0, 1.8, 2.4 );

     i := 1;
     While ( i <= GetBombCount() ) Do Begin
          If bColor Then Begin
             Case GetBombByCount(i).BIndex Of
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
          SetTexture( 1, TEXTURE_BOMB(GetBombByCount(i).BIndex) );
          PushObjectMatrix( GetBombByCount(i).Position.X, 0, GetBombByCount(i).Position.Y,
                            1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)*0.5),
                            1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)*0.5),
                            1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)*0.5),
                            0, 0, 0 );
          DrawMesh( MESH_BOMB(GetBombByCount(i).BIndex), False );
          PopObjectMatrix();
          If Not GetBombByCount(i).UpdateBomb() Then i += 1;
    End;
End;



Procedure DrawFlame ( w : Single ) ;
Var i : Integer;
Var r, g, b : Single;
Begin
     DisableLighting();

     i := 1;
     While ( i <= GetFlameCount() ) Do Begin
          SetTexture( 1, TEXTURE_FLAME(GetFlameByCount(i).Owner.BIndex) );
          // flamme intérieure
          If bColor Then Begin
             Case GetFlameByCount(i).Owner.BIndex Of
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
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.001, 0, GetFlameByCount(i).Y - 0.001 ); // on évite les cas particuliers (les angles à 90° bug)
          DrawSprite( 1.0 + 2.0 * GetFlameByCount(i).Itensity, 1.0 + 2.0 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity, True );
          PopObjectMatrix();
          // flammes centrales
          If bColor Then Begin
             Case GetFlameByCount(i).Owner.BIndex Of
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
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.301, 0, GetFlameByCount(i).Y );
          DrawSprite( 0.6 + 1.7 * GetFlameByCount(i).Itensity, 0.6 + 1.7 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X + 0.299, 0, GetFlameByCount(i).Y );
          DrawSprite( 0.6 + 1.7 * GetFlameByCount(i).Itensity, 0.6 + 1.7 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X, 0, GetFlameByCount(i).Y - 0.301 );
          DrawSprite( 0.6 + 1.7 * GetFlameByCount(i).Itensity, 0.6 + 1.7 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity * 0.8, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X, 0, GetFlameByCount(i).Y + 0.299 );
          DrawSprite( 0.6 + 1.7 * GetFlameByCount(i).Itensity, 0.6 + 1.7 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity * 0.8, True );
          PopObjectMatrix();
          // flammes extérieures
          If bColor Then Begin
             Case GetFlameByCount(i).Owner.BIndex Of
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
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.301, 0, GetFlameByCount(i).Y - 0.301 );
          DrawSprite( 0.2 + 1.4 * GetFlameByCount(i).Itensity, 0.2 + 1.4 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.301, 0, GetFlameByCount(i).Y + 0.299 );
          DrawSprite( 0.2 + 1.4 * GetFlameByCount(i).Itensity, 0.2 + 1.4 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X + 0.299, 0, GetFlameByCount(i).Y - 0.301 );
          DrawSprite( 0.2 + 1.4 * GetFlameByCount(i).Itensity, 0.2 + 1.4 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity * 0.4, True );
          PopObjectMatrix();
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X + 0.299, 0, GetFlameByCount(i).Y + 0.299 );
          DrawSprite( 0.2 + 1.4 * GetFlameByCount(i).Itensity, 0.2 + 1.4 * GetFlameByCount(i).Itensity, r, g, b, GetFlameByCount(i).Itensity * 0.4, True );
          PopObjectMatrix();
          // mise à jour
          If Not GetFlameByCount(i).Update() Then i += 1;
     End;
End;



Procedure DrawPlane ( w : Single ) ;
Begin
     EnableLighting();
     SetLighting( 2.0, 1.0, 0.3, 0.6 );

     SetMaterial( w, w, w, 1.0 );

     SetTexture( 1, TEXTURE_MAP_PLANE );
     PushObjectMatrix( 8.0, -0.5, 6.0, 0.11, 0.11, 0.11, 0, 0, 0 );
     DrawMesh( MESH_PLANE, True );
     PopObjectMatrix();
End;



Var fBlinkTime : Single;
    bBlinkState : Boolean;

Procedure DrawTimer () ;
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
     DrawString( STRING_TIMER, w / h * 0.7, 0.8, -1, 0.064 * w / h, 0.096, 1, 1, 1, 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );

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
        DrawString( STRING_TIMER, w / h * 0.7, 0.8, -1, 0.064 * w / h, 0.096, 1.0, 0.0, 0.0, 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );
     End Else Begin
        DrawString( STRING_TIMER, w / h * 0.7, 0.8, -1, 0.064 * w / h, 0.096, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );
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
     sScreenMessage := sScreenMessage + '                        ';
End;

Procedure AddStringToScreen ( sMessage : String ) ;
Begin
     sScreenMessage := sScreenMessage + '   ' + sMessage + ' ';
End;

Procedure DrawScreen () ;
Var w, h : Single;
    k : Integer;
    s : String;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     If GetTime > fScreenTime + 0.1 Then Begin
        fScreenTime := GetTime;
        For k := 1 To Length(sScreenMessage) - 1 Do
            sScreenMessage[k] := sScreenMessage[k+1];
     End;
     
     DisableLighting();

     SetString( STRING_SCREEN, '************************', 0.0, 0.0, 0.0 );
     DrawString( STRING_SCREEN, w / h * -0.9, 0.8, -1, 0.064 * w / h, 0.096, 1, 1, 1, 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );

     SetLength( s, 24 );
     For k := 1 To 24 Do
         s[k] := sScreenMessage[k];

     SetString( STRING_SCREEN, s, 0.0, 0.0, 0.0 );
     DrawString( STRING_SCREEN, w / h * -0.9, 0.8, -1, 0.064 * w / h, 0.096, 1, 1, 1, 0.8, True, SPRITE_CHARSET_DIGITAL, SPRITE_CHARSET_DIGITALX, EFFECT_NONE );
End;



Procedure DrawScore () ;
Var w, h : Single;
    i : Integer;
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     If GetKey(KEY_TAB) Then Begin
        If Not bScoreTable Then Begin
           If GetBombermanCount() <> 0 Then
              For i := 1 To GetBombermanCount() Do
                  SetString( STRING_SCORE_TABLE(i), GetBombermanByCount(i).Name + Format(' : %2d ; %d kill(s), %d death(s).', [GetBombermanByCount(i).Score, GetBombermanByCount(i).Kills, GetBombermanByCount(i).Deaths]), Single(i) * 0.1 + 0.1, 1.0, 20 );
        End;
        If GetBombermanCount() <> 0 Then
           For i := 1 To GetBombermanCount() Do
               DrawString( STRING_SCORE_TABLE(i), -w / h * 0.9, 0.6 - 0.15 * Single(i), -1, 0.018 * w / h, 0.024, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
        bScoreTable := True;
     End Else Begin
        bScoreTable := False;
     End;
End;



Procedure InitScore () ;
Var i : Integer;
Begin
     // suppression des touches des joueurs
     BindKeyObj( nKey1MoveUp, False, NIL );
     BindKeyObj( nKey1MoveDown, False, NIL );
     BindKeyObj( nKey1MoveLeft, False, NIL );
     BindKeyObj( nKey1MoveRight, False, NIL );
     BindKeyObj( nKey1Primary, True, NIL );
     BindKeyObj( nKey1Secondary, True, NIL );
     BindKeyObj( nKey2MoveUp, False, NIL );
     BindKeyObj( nKey2MoveDown, False, NIL );
     BindKeyObj( nKey2MoveLeft, False, NIL );
     BindKeyObj( nKey2MoveRight, False, NIL );
     BindKeyObj( nKey2Primary, True, NIL );
     BindKeyObj( nKey2Secondary, True, NIL );

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
            SetString( STRING_SCORE_TABLE(i), GetBombermanByCount(i).Name + Format(' : %2d ; %d kill(s), %d death(s).', [GetBombermanByCount(i).Score, GetBombermanByCount(i).Kills, GetBombermanByCount(i).Deaths]), Single(i) * 0.1 + 0.5, 1.0, 300.0 );

     // mise à jour de la machine d'état interne
     nPractice := PRACTICE_SCORE;
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



Procedure InitWait () ;
Var i : Integer;
Begin
     // initialisation de la minuterie d'attente
     fWaitTime := GetTime;

     // suppression des touches des joueurs
     BindKeyObj( nKey1MoveUp, False, NIL );
     BindKeyObj( nKey1MoveDown, False, NIL );
     BindKeyObj( nKey1MoveLeft, False, NIL );
     BindKeyObj( nKey1MoveRight, False, NIL );
     BindKeyObj( nKey1Primary, True, NIL );
     BindKeyObj( nKey1Secondary, True, NIL );
     BindKeyObj( nKey2MoveUp, False, NIL );
     BindKeyObj( nKey2MoveDown, False, NIL );
     BindKeyObj( nKey2MoveLeft, False, NIL );
     BindKeyObj( nKey2MoveRight, False, NIL );
     BindKeyObj( nKey2Primary, True, NIL );
     BindKeyObj( nKey2Secondary, True, NIL );

     // affichage du vainqueur
     If CheckEndGame() <= 0 Then Begin
        SetString( STRING_SCORE_TABLE(0), 'draw game!', 1.0, 0.5, 300.0 );
     End Else Begin
        SetString( STRING_SCORE_TABLE(0), GetBombermanByCount(CheckEndGame()).Name + ' wins the round.', 1.0, 0.5, 300.0 );
     End;

     // affichage des scores
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            SetString( STRING_SCORE_TABLE(i), GetBombermanByCount(i).Name + Format(' : %2d ; %d kill(s), %d death(s).', [GetBombermanByCount(i).Score, GetBombermanByCount(i).Kills, GetBombermanByCount(i).Deaths]), Single(i) * 0.1 + 0.5, 1.0, 300.0 );

     // mise à jour de la machine d'état interne
     nPractice := PRACTICE_WAIT;
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
        DrawBomberman( 0.4 );
        DrawGrid( 0.4 );
        DrawBomb( 0.4 );
        DrawFlame( 0.4 );
        PopObjectMatrix();
        PushObjectMatrix( 0, -1, 0, 1.2, -1.2, 1.2, 0, 0, 0 );
        DrawSkybox( 0.4, 0.4, 0.4, 0.4, TEXTURE_MAP_SKYBOX(0) );
        PopObjectMatrix();
     End;

     // rendu global
     DrawPlane( 1.0 );
     DrawBomberman( 1.0 );
     DrawGrid( 1.0 );
     DrawBomb( 1.0 );
     DrawFlame( 1.0 );
     DrawSkybox( 1.0, 1.0, 1.0, 1.0, TEXTURE_MAP_SKYBOX(0) );

     // affichage du vainqueur
     DrawString( STRING_SCORE_TABLE(0), -w / h * 0.9, 0.9, -1, 0.036 * w / h, 0.048, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     // affichage des scores
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            DrawString( STRING_SCORE_TABLE(i), -w / h * 0.9, 0.7 - 0.2 * Single(i), -1, 0.018 * w / h, 0.024, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );

     If GetKey(KEY_ENTER) Then InitRound(); // player ready en multiplayer
End;



Procedure InitGame () ;
Var k : Integer;
Begin
     // enregistrement des paramètres
     WriteSettings( 'atominsa.cfg' );

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
     pGrid := CGrid.Create( pScheme );

     // création des bombermen
     pPlayer1 := NIL;
     pPlayer2 := NIL;
     For k := 1 To 8 Do Begin // pour des random spawn on crééra une liste 1..8 de chiffres random parmi 1..8 sans remise
         Case nPlayerType[k] Of
              PLAYER_KB1 :
                   pPlayer1 := AddBomberman( sPlayerName[k], k, k, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
              PLAYER_KB2 :
                   pPlayer2 := AddBomberman( sPlayerName[k], k, k, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
              PLAYER_COM : // AddComputer() ?
                   AddBomberman( sPlayerName[k], k, k, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
              PLAYER_NET : // AddNetwork() ?
                   AddBomberman( sPlayerName[k], k, k, pGrid, pScheme.Spawn(k).X, pScheme.Spawn(k).Y );
         End;
     End;

     // mise à zéro de la minuterie du jeu
     fGameTime := GetTime();

     // initialisation du premier round
     nRound := 0;
     InitRound();
     
     // initialisation du panneau d'affichage
     InitScreen();
     AddBlankToScreen();
     AddStringToScreen( 'Welcome to Bomberman Returns!' ); // IL VA FALLOIR QU'ON TROUVE UN VRAI TITRE
     AddBlankToScreen();
     AddStringToScreen( 'Good luck!   Have fun!' );
     AddBlankToScreen();
End;



Procedure ProcessGame () ;
Var k : Integer;
Begin
     // définition de la camera
     SetCamera();

     // rendu des reflets
     If bReflection Then Begin
        PushObjectMatrix( 0, -1, 0, 1, -1, 1, 0, 0, 0 );
        DrawBomberman( 0.4 );
        DrawGrid( 0.4 );
        DrawBomb( 0.4 );
        DrawFlame( 0.4 );
        PopObjectMatrix();
        PushObjectMatrix( 0, -1, 0, 1.2, -1.2, 1.2, 0, 0, 0 );
        DrawSkybox( 0.4, 0.4, 0.4, 0.4, TEXTURE_MAP_SKYBOX(0) );
        PopObjectMatrix();
     End;

     // rendu global
     DrawPlane( 1.0 );
     DrawBomberman( 1.0 );
     DrawGrid( 1.0 );
     DrawBomb( 1.0 );
     DrawFlame( 1.0 );
     DrawSkybox( 1.0, 1.0, 1.0, 1.0, TEXTURE_MAP_SKYBOX(0) );
     
     // affichage des scores
     DrawScore();
     
     // affichage de la minuterie
     DrawTimer();

     // affichage du panneau d'affichage
     DrawScreen();

     // gestion de l'intelligence artificielle
     For k := 1 To GetBombermanCount() Do Begin
         If GetBombermanByCount(k).Alive Then Begin
            If nPlayerType[GetBombermanByCount(k).BIndex] = PLAYER_COM Then
               ProcessComputer( GetBombermanByCount(k), nPlayerSkill[GetBombermanByCount(k).BIndex] );
         End;
     End;
     
     // mise à jour de la minuterie
     CheckTimer();

     // vérifie s'il reste des bomberman en jeu ou si la minuterie est à zéro
     If (CheckEndGame() <> 0) Or (GetTime > fRoundTime + fRoundDuration + 3.0) Then InitWait();
End;





























////////////////////////////////////////////////////////////////////////////////
// MENU JOUEUR                                                                //
////////////////////////////////////////////////////////////////////////////////



Function PlayerInfo( nConst : Integer ) : String ;
Begin
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
          PLAYER_NET :
          Begin
               PlayerInfo := 'network              : ' + sPlayerName[nConst];
          End;
     End;
End;

Function PlayerType() : String ;
Begin
     Case nPlayerType[nPlayer] Of
          PLAYER_NIL : PlayerType := 'none';
          PLAYER_KB1 : PlayerType := 'keyboard 1';
          PLAYER_KB2 : PlayerType := 'keyboard 2';
          PLAYER_COM : PlayerType := 'computer';
          PLAYER_NET : PlayerType := 'network';
     End;
End;

Function PlayerSkill() : String ;
Begin
     Case nPlayerSkill[nPlayer] Of
          1 : PlayerSkill := 'novice';
          2 : PlayerSkill := 'average';
          3 : PlayerSkill := 'masterful';
          4 : PlayerSkill := 'godlike';
     End;
End;



Procedure InitMenuPlayer () ;
Var k : Integer;
Begin
     // ajout du titre
     SetString( STRING_PRACTICE_MENU(2), 'player ' + IntToStr(nPlayer), 0.2, 0.2, 600 );

     // ajout du menu
     SetString( STRING_PRACTICE_MENU(61), 'name : ' + sPlayerName[nPlayer], 0.2, 1.0, 600 );
     If nPlayerCharacter[nPlayer] = -1 Then Begin
        pPlayerCharacter[nPlayer] := aCharacterList[Trunc(Random(nCharacterCount))];
        SetString( STRING_PRACTICE_MENU(62), 'character : ' + 'random', 0.2, 1.0, 600 );
     End Else Begin
        pPlayerCharacter[nPlayer] := aCharacterList[nPlayerCharacter[nPlayer]];
        SetString( STRING_PRACTICE_MENU(62), 'character : ' + pPlayerCharacter[nPlayer].Name, 0.2, 1.0, 600 );
     End;
     SetString( STRING_PRACTICE_MENU(63), 'type : ' + PlayerType, 0.2, 1.0, 600 );
     SetString( STRING_PRACTICE_MENU(64), 'skill : ' + PlayerSkill, 0.2, 1.0, 600 );

     // ajout du bouton back
     SetString( STRING_PRACTICE_MENU(71), 'back', 0.2, 0.5, 600 );

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



Function CheckKey() : Char ;
Var k : Integer;
Begin
     CheckKey := #0;
     
     If GetKey(8) Then CheckKey := #8;

     For k := 97 To 122 Do
         If GetKey(k) Then CheckKey := Chr(k);
         
     For k := 48 To 57 Do
         If GetKey(k) Then CheckKey := Chr(k);

     If GetKey(32) Then CheckKey := #32;
     If GetKey(33) Then CheckKey := #33;
     If GetKey(39) Then CheckKey := #39;
     If GetKey(40) Then CheckKey := #40;
     If GetKey(41) Then CheckKey := #41;
     If GetKey(44) Then CheckKey := #44;
     If GetKey(45) Then CheckKey := #45;
     If GetKey(46) Then CheckKey := #46;
     If GetKey(58) Then CheckKey := #58;
     If GetKey(59) Then CheckKey := #59;
     If GetKey(63) Then CheckKey := #63;
     If GetKey(91) Then CheckKey := #91;
     If GetKey(93) Then CheckKey := #93;
End;

Procedure ProcessMenuPlayer () ;
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
     DrawString( STRING_PRACTICE_MENU(2), -w / h * 0.4,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.3;
     DrawString( STRING_PRACTICE_MENU(61), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER_NAME), IsActive(MENU_PLAYER_NAME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_PRACTICE_MENU(62), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER_CHARACTER), IsActive(MENU_PLAYER_CHARACTER), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_PRACTICE_MENU(63), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER_TYPE), IsActive(MENU_PLAYER_TYPE), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     If nPlayerType[nPlayer] = PLAYER_COM Then
        DrawString( STRING_PRACTICE_MENU(64), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER_SKILL), IsActive(MENU_PLAYER_SKILL), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(71), -w / h * -0.6, -0.8, -1, 0.024 * w / h, 0.036, 1.0, IsActive(MENU_PLAYER_BACK), IsActive(MENU_PLAYER_BACK), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;

     If GetKey( KEY_ESC ) Then Begin
        PlaySound( SOUND_MENU_BACK );
        nPractice := PRACTICE_MENU;
        SetString( STRING_PRACTICE_MENU(10 + nPlayer), PlayerInfo(nPlayer), 0.0, 0.02, 600 );
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
                     SetString( STRING_PRACTICE_MENU(64), 'skill : ' + PlayerSkill, 0.0, 0.02, 600 );
                End;
                MENU_PLAYER_TYPE :
                Begin
                     If nPlayerType[nPlayer] = PLAYER_KB1 Then nPlayerType[nPlayer] := PLAYER_NIL;
                     If nPlayerType[nPlayer] = PLAYER_KB2 Then nPlayerType[nPlayer] := PLAYER_KB1;
                     If nPlayerType[nPlayer] = PLAYER_COM Then nPlayerType[nPlayer] := PLAYER_KB2;
                     //If nPlayerType[nPlayer] = PLAYER_NET Then nPlayerType[nPlayer] := PLAYER_COM;
                     SetString( STRING_PRACTICE_MENU(63), 'type : ' + PlayerType, 0.0, 0.02, 600 );
                End;
                MENU_PLAYER_CHARACTER :
                Begin
                     nPlayerCharacter[nPlayer] -= 1;
                     If nPlayerCharacter[nPlayer] < -1 Then nPlayerCharacter[nPlayer] := nCharacterCount - 1;
                     If nPlayerCharacter[nPlayer] = -1 Then Begin
                        pPlayerCharacter[nPlayer] := aCharacterList[Trunc(Random(nCharacterCount))];
                        SetString( STRING_PRACTICE_MENU(62), 'character : ' + 'random', 0.0, 0.02, 600 );
                     End Else Begin
                        pPlayerCharacter[nPlayer] := aCharacterList[nPlayerCharacter[nPlayer]];
                        SetString( STRING_PRACTICE_MENU(62), 'character : ' + pPlayerCharacter[nPlayer].Name, 0.0, 0.02, 600 );
                     End;
                     DelMesh( MESH_BOMBERMAN(nPlayer) );
                     AddMesh( './characters/' + pPlayerCharacter[nPlayer].PlayerMesh, MESH_BOMBERMAN(nPlayer) );
                     DelMesh( MESH_BOMB(nPlayer) );
                     AddMesh( './characters/' + pPlayerCharacter[nPlayer].BombMesh, MESH_BOMB(nPlayer) );
                     DelTexture( TEXTURE_BOMBERMAN(nPlayer) );
                     AddTexture( './characters/' + pPlayerCharacter[nPlayer].PlayerSkin[nPlayer], TEXTURE_BOMBERMAN(nPlayer) );
                     DelTexture( TEXTURE_BOMB(nPlayer) );
                     AddTexture( './characters/' + pPlayerCharacter[nPlayer].BombSkin, TEXTURE_BOMB(nPlayer) );
                     DelTexture( TEXTURE_FLAME(nPlayer) );
                     AddTexture( './characters/' + pPlayerCharacter[nPlayer].FlameTexture, TEXTURE_FLAME(nPlayer) );
                     DelSound( SOUND_BOMB(10+nPlayer) );
                     AddSound( './characters/' + pPlayerCharacter[nPlayer].BombSound[1], SOUND_BOMB(10+nPlayer) );
                     DelSound( SOUND_BOMB(20+nPlayer) );
                     AddSound( './characters/' + pPlayerCharacter[nPlayer].BombSound[2], SOUND_BOMB(20+nPlayer) );
                     DelSound( SOUND_BOMB(30+nPlayer) );
                     AddSound( './characters/' + pPlayerCharacter[nPlayer].BombSound[3], SOUND_BOMB(30+nPlayer) );
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
                     SetString( STRING_PRACTICE_MENU(64), 'skill : ' + PlayerSkill, 0.0, 0.02, 600 );
                End;
                MENU_PLAYER_TYPE :
                Begin
                     //If nPlayerType[nPlayer] = PLAYER_COM Then nPlayerType[nPlayer] := PLAYER_NET;
                     If nPlayerType[nPlayer] = PLAYER_KB2 Then nPlayerType[nPlayer] := PLAYER_COM;
                     If nPlayerType[nPlayer] = PLAYER_KB1 Then nPlayerType[nPlayer] := PLAYER_KB2;
                     If nPlayerType[nPlayer] = PLAYER_NIL Then nPlayerType[nPlayer] := PLAYER_KB1;
                     SetString( STRING_PRACTICE_MENU(63), 'type : ' + PlayerType, 0.0, 0.02, 600 );
                End;
                MENU_PLAYER_CHARACTER :
                Begin
                     nPlayerCharacter[nPlayer] += 1;
                     If nPlayerCharacter[nPlayer] = nCharacterCount Then nPlayerCharacter[nPlayer] := -1;
                     If nPlayerCharacter[nPlayer] = -1 Then Begin
                        pPlayerCharacter[nPlayer] := aCharacterList[Trunc(Random(nCharacterCount))];
                        SetString( STRING_PRACTICE_MENU(62), 'character : ' + 'random', 0.0, 0.02, 600 );
                     End Else Begin
                        pPlayerCharacter[nPlayer] := aCharacterList[nPlayerCharacter[nPlayer]];
                        SetString( STRING_PRACTICE_MENU(62), 'character : ' + pPlayerCharacter[nPlayer].Name, 0.0, 0.02, 600 );
                     End;
                     DelMesh( MESH_BOMBERMAN(nPlayer) );
                     AddMesh( './characters/' + pPlayerCharacter[nPlayer].PlayerMesh, MESH_BOMBERMAN(nPlayer) );
                     DelMesh( MESH_BOMB(nPlayer) );
                     AddMesh( './characters/' + pPlayerCharacter[nPlayer].BombMesh, MESH_BOMB(nPlayer) );
                     DelTexture( TEXTURE_BOMBERMAN(nPlayer) );
                     AddTexture( './characters/' + pPlayerCharacter[nPlayer].PlayerSkin[nPlayer], TEXTURE_BOMBERMAN(nPlayer) );
                     DelTexture( TEXTURE_BOMB(nPlayer) );
                     AddTexture( './characters/' + pPlayerCharacter[nPlayer].BombSkin, TEXTURE_BOMB(nPlayer) );
                     DelTexture( TEXTURE_FLAME(nPlayer) );
                     AddTexture( './characters/' + pPlayerCharacter[nPlayer].FlameTexture, TEXTURE_FLAME(nPlayer) );
                     DelSound( SOUND_BOMB(10+nPlayer) );
                     AddSound( './characters/' + pPlayerCharacter[nPlayer].BombSound[1], SOUND_BOMB(10+nPlayer) );
                     DelSound( SOUND_BOMB(20+nPlayer) );
                     AddSound( './characters/' + pPlayerCharacter[nPlayer].BombSound[2], SOUND_BOMB(20+nPlayer) );
                     DelSound( SOUND_BOMB(30+nPlayer) );
                     AddSound( './characters/' + pPlayerCharacter[nPlayer].BombSound[3], SOUND_BOMB(30+nPlayer) );
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
                     nPractice := PRACTICE_MENU;
                     SetString( STRING_PRACTICE_MENU(10 + nPlayer), PlayerInfo(nPlayer), 0.0, 0.02, 600 );
                     nMenu := MENU_PLAYER1 + nPlayer - 1;
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
                     SetString( STRING_PRACTICE_MENU(61), 'name : ' + sPlayerName[nPlayer], 0.0, 0.02, 600 );
                End;
           End;
           fKey := GetTime + 0.1;
        End;
     End Else Begin
        fKey := 0.0;
     End;

End;





























////////////////////////////////////////////////////////////////////////////////
// MENU PRINCIPAL                                                             //
////////////////////////////////////////////////////////////////////////////////



Procedure InitMenu () ;
Var k : Integer;
Begin
     // ajout du titre
     SetString( STRING_PRACTICE_MENU(1), 'practice', 0.2, 0.2, 600 );

     // ajout de la liste de joueurs
     SetString( STRING_PRACTICE_MENU(11), PlayerInfo(1), 0.2, 1.0, 600 );
     SetString( STRING_PRACTICE_MENU(12), PlayerInfo(2), 0.2, 1.0, 600 );
     SetString( STRING_PRACTICE_MENU(13), PlayerInfo(3), 0.2, 1.0, 600 );
     SetString( STRING_PRACTICE_MENU(14), PlayerInfo(4), 0.2, 1.0, 600 );
     SetString( STRING_PRACTICE_MENU(15), PlayerInfo(5), 0.2, 1.0, 600 );
     SetString( STRING_PRACTICE_MENU(16), PlayerInfo(6), 0.2, 1.0, 600 );
     SetString( STRING_PRACTICE_MENU(17), PlayerInfo(7), 0.2, 1.0, 600 );
     SetString( STRING_PRACTICE_MENU(18), PlayerInfo(8), 0.2, 1.0, 600 );

     // chargement et ajout du scheme
     LoadScheme();
     If nScheme = -1 Then Begin
        SetString( STRING_PRACTICE_MENU(21), 'scheme : ' + 'random', 0.2, 1.0, 600 );
     End Else Begin
        SetString( STRING_PRACTICE_MENU(21), 'scheme : ' + pScheme.Name, 0.2, 1.0, 600 );
     End;

     // chargement et ajout de la map
     LoadMap();
     If nMap = -1 Then Begin
        SetString( STRING_PRACTICE_MENU(31), 'map : ' + 'random', 0.2, 1.0, 600 );
     End Else Begin
        SetString( STRING_PRACTICE_MENU(31), 'map : ' + pMap.Name, 0.2, 1.0, 600 );
     End;

     // ajout du compteur de rounds
     SetString( STRING_PRACTICE_MENU(41), 'round count : ' + IntToStr(nRoundCount), 0.2, 1.0, 600 );

     // ajout du bouton fight
     SetString( STRING_PRACTICE_MENU(51), 'fight!', 0.2, 0.5, 600 );

     // définition de la machine d'état interne
     nPractice := PRACTICE_MENU;

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
Begin
     w := GetRenderWidth();
     h := GetRenderHeight();

     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // définition de la camera
     SetCamera();

     // rendu du plateau
     DrawPlane( 0.3 );
     DrawBomberman( 0.3 );
     DrawGrid( 0.3 );
     DrawSkybox( 0.3, 0.3, 0.3, 0.3, TEXTURE_MAP_SKYBOX(0) );

     // affichage du menu
     DrawString( STRING_PRACTICE_MENU(1), -w / h * 0.4,  0.9, -1, 0.048 * w / h, 0.064, 1.0, 1.0, 1.0, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
     t := 0.0;
     DrawString( STRING_PRACTICE_MENU(11), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER1), IsActive(MENU_PLAYER1), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(12), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER2), IsActive(MENU_PLAYER2), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(13), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER3), IsActive(MENU_PLAYER3), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(14), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER4), IsActive(MENU_PLAYER4), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(15), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER5), IsActive(MENU_PLAYER5), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(16), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER6), IsActive(MENU_PLAYER6), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(17), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER7), IsActive(MENU_PLAYER7), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(18), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_PLAYER8), IsActive(MENU_PLAYER8), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_PRACTICE_MENU(21), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_SCHEME), IsActive(MENU_SCHEME), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_PRACTICE_MENU(31), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_MAP), IsActive(MENU_MAP), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     t += 0.12;
     DrawString( STRING_PRACTICE_MENU(41), -w / h * 0.8, 0.7 - t, -1, 0.018 * w / h, 0.024, 1.0, IsActive(MENU_ROUNDCOUNT), IsActive(MENU_ROUNDCOUNT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;
     DrawString( STRING_PRACTICE_MENU(51), -w / h * -0.6, -0.8, -1, 0.024 * w / h, 0.036, 1.0, IsActive(MENU_FIGHT), IsActive(MENU_FIGHT), 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL ); t += 0.12;

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

     If GetKeyS( KEY_LEFT ) Then Begin
        If Not bLeft Then Begin
           PlaySound( SOUND_MENU_CLICK );
           Case nMenu Of
                MENU_SCHEME :
                Begin
                     nScheme -= 1;
                     If nScheme < -1 Then nScheme := nSchemeCount - 1;
                     LoadScheme();
                     If nScheme = -1 Then Begin
                        SetString( STRING_PRACTICE_MENU(21), 'scheme : ' + 'random', 0.0, 0.02, 600 );
                     End Else Begin
                        SetString( STRING_PRACTICE_MENU(21), 'scheme : ' + pScheme.Name, 0.0, 0.02, 600 );
                     End;
                End;
                MENU_MAP :
                Begin
                     nMap -= 1;
                     If nMap < -1 Then nMap := nMapCount - 1;
                     LoadMap();
                     If nMap = -1 Then Begin
                        SetString( STRING_PRACTICE_MENU(31), 'map : ' + 'random', 0.0, 0.02, 600 );
                     End Else Begin
                        SetString( STRING_PRACTICE_MENU(31), 'map : ' + pMap.Name, 0.0, 0.02, 600 );
                     End;
                End;
                MENU_ROUNDCOUNT :
                Begin
                     nRoundCount -= 1;
                     If nRoundCount < 1 Then nRoundCount := 1;
                     SetString( STRING_PRACTICE_MENU(41), 'round count : ' + IntToStr(nRoundCount), 0.0, 0.02, 600 );
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
                MENU_SCHEME :
                Begin
                     nScheme += 1;
                     If nScheme = nSchemeCount Then nScheme := -1;
                     LoadScheme();
                     If nScheme = -1 Then Begin
                        SetString( STRING_PRACTICE_MENU(21), 'scheme : ' + 'random', 0.0, 0.02, 600 );
                     End Else Begin
                        SetString( STRING_PRACTICE_MENU(21), 'scheme : ' + pScheme.Name, 0.0, 0.02, 600 );
                     End;
                End;
                MENU_MAP :
                Begin
                     nMap += 1;
                     If nMap = nMapCount Then nMap := -1;
                     LoadMap();
                     If nMap = -1 Then Begin
                        SetString( STRING_PRACTICE_MENU(31), 'map : ' + 'random', 0.0, 0.02, 600 );
                     End Else Begin
                        SetString( STRING_PRACTICE_MENU(31), 'map : ' + pMap.Name, 0.0, 0.02, 600 );
                     End;
                End;
                MENU_ROUNDCOUNT :
                Begin
                     nRoundCount += 1;
                     If nRoundCount > 99 Then nRoundCount := 1;
                     SetString( STRING_PRACTICE_MENU(41), 'round count : ' + IntToStr(nRoundCount), 0.0, 0.02, 600 );
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
                MENU_PLAYER1 :
                Begin
                     nPlayer := 1;
                     InitMenuPlayer();
                     nPractice := PRACTICE_MENU_PLAYER;
                End;
                MENU_PLAYER2 :
                Begin
                     nPlayer := 2;
                     InitMenuPlayer();
                     nPractice := PRACTICE_MENU_PLAYER;
                End;
                MENU_PLAYER3 :
                Begin
                     nPlayer := 3;
                     InitMenuPlayer();
                     nPractice := PRACTICE_MENU_PLAYER;
                End;
                MENU_PLAYER4 :
                Begin
                     nPlayer := 4;
                     InitMenuPlayer();
                     nPractice := PRACTICE_MENU_PLAYER;
                End;
                MENU_PLAYER5 :
                Begin
                     nPlayer := 5;
                     InitMenuPlayer();
                     nPractice := PRACTICE_MENU_PLAYER;
                End;
                MENU_PLAYER6 :
                Begin
                     nPlayer := 6;
                     InitMenuPlayer();
                     nPractice := PRACTICE_MENU_PLAYER;
                End;
                MENU_PLAYER7 :
                Begin
                     nPlayer := 7;
                     InitMenuPlayer();
                     nPractice := PRACTICE_MENU_PLAYER;
                End;
                MENU_PLAYER8 :
                Begin
                     nPlayer := 8;
                     InitMenuPlayer();
                     nPractice := PRACTICE_MENU_PLAYER;
                End;
                MENU_FIGHT :
                Begin
                     nPractice := PRACTICE_INIT;
                End;
           End;
        End;
        bEnter := True;
     End Else Begin
        bEnter := False;
     End;

End;





























////////////////////////////////////////////////////////////////////////////////
// GESTION DE L'UNITE                                                         //
////////////////////////////////////////////////////////////////////////////////



Procedure InitPractice () ;
Begin
     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     // initialisation du menu
     InitMenu();

     // mise à jour de la machine d'état
     nState := STATE_PRACTICE;
End;



Procedure ProcessPractice () ;
Begin
     Case nPractice Of
          PRACTICE_MENU : ProcessMenu();
          PRACTICE_MENU_PLAYER : ProcessMenuPlayer();
          PRACTICE_INIT : InitGame();
          PRACTICE_GAME : ProcessGame();
          PRACTICE_WAIT : ProcessWait();
          PRACTICE_SCORE : ProcessScore();
     End;
End;





























End.

