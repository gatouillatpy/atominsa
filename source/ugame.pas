Unit UGame;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UUtils, UBlock, UItem, UScheme, USpawn, UBomberman, UDisease,
     USpeedUp, UExtraBomb, UFlameUp, UGrid, UFlame, UBomb, USetup, UForm;



Procedure InitPractice () ;
Procedure ProcessGame () ;



Implementation



// vrai si on est en train d'afficher les scores
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



Procedure InitRound () ;
Var i : Integer;
Begin
     // supression des différents éléments du jeu
     FreeFlame();
     FreeBomb();
     FreeTimer();
     
     // rechargement de la grille
     pGrid.LoadScheme( pScheme );
     
     // restauration des bomberman
     If GetBombermanCount() <> 0 Then
        For i := 1 To GetBombermanCount() Do
            GetBombermanByCount(i).Restore();

     // ajout d'un round
     nRound += 1;
     
     // mise à zero de la minuterie du round
     fRoundTime := GetTime();
End;



Procedure InitPractice () ;
Var pPlayer1 : CBomberman;
    pPlayer2 : CBomberman;
Begin
     // initialisation de la camera
     nCamera := CAMERA_OVERALL;

     // création de la grille en fonction du scheme
     pGrid := CGrid.Create( pScheme );

     // création du premier joueur et définition de ses touches
     pPlayer1 := AddBomberman( sName1, 1, 1, pGrid, pScheme.Spawn(1).X, pScheme.Spawn(1).Y ); // le spawn du bomberman est variable : à voir
     BindKeyObj( nKey1MoveUp, False, True, @pPlayer1.MoveUp );
     BindKeyObj( nKey1MoveDown, False, True, @pPlayer1.MoveDown );
     BindKeyObj( nKey1MoveLeft, False, True, @pPlayer1.MoveLeft );
     BindKeyObj( nKey1MoveRight, False, True, @pPlayer1.MoveRight );
     BindKeyObj( nKey1Primary, True, False, @pPlayer1.CreateBomb );
     //BindKeyObj( nKey1Secondary, True, False, @pPlayer1.??? );

     // création du deuxième joueur et définition de ses touches
     pPlayer2 := AddBomberman( sName2, 2, 2, pGrid, pScheme.Spawn(2).X, pScheme.Spawn(2).Y );
     BindKeyObj( nKey2MoveUp, False, False, @pPlayer2.MoveUp );
     BindKeyObj( nKey2MoveDown, False, False, @pPlayer2.MoveDown );
     BindKeyObj( nKey2MoveLeft, False, False, @pPlayer2.MoveLeft );
     BindKeyObj( nKey2MoveRight, False, False, @pPlayer2.MoveRight );
     BindKeyObj( nKey2Primary, True, False, @pPlayer2.CreateBomb );
     //BindKeyObj( nKey2Secondary, True, False, @tPlayer.??? );

     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     // mise à zero de la minuterie du jeu
     fGameTime := GetTime();

     // initialisation du premier round
     nRound := 0;
     InitRound();

     // mise à jour de la machine d'état
     nState := STATE_PRACTICE;
End;



Procedure SetCamera () ;
Begin
     If GetTime() - fGameTime < 3.0 Then Begin
     // on fait le tour du plateau durant les trois premières secondes de jeu
        vPointer.x := 8.0 + (fGameTime - GetTime() + 3.0) * 8.0 * cos((GetTime() - fGameTime) / 3.0 * PI + PI * 3 / 2);
        vPointer.y := 8.5 + (fGameTime - GetTime() + 3.0) * 8.0;
        vPointer.z := 6.0 + (fGameTime - GetTime() + 3.0) * 8.0 * sin((GetTime() - fGameTime) / 3.0 * PI + PI * 3 / 2);
        vCenter.x := 8.0;
        vCenter.y := 0.0;
        vCenter.z := 5.5;
        vCamera.x := vPointer.x;
        vCamera.y := vPointer.y;
        vCamera.z := vPointer.z;
     End Else If GetTime() - fRoundTime < 1.0 Then Begin
     // on se rapproche du plateau la première seconde d'un round
        vPointer.x := 8.0;
        vPointer.y := 8.5 + (fRoundTime - GetTime() + 1.0) * 3.0;
        vPointer.z := 6.0 + (fRoundTime - GetTime() + 1.0) * 16.0;
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
Begin
     SetLight( 0,                 0, h,                - 1, 1, 1, 1, 1, a0, a1, a2, True );
     SetLight( 1, GRIDWIDTH     - 1, h,                - 1, 1, 1, 1, 1, a0, a1, a2, True );
     SetLight( 2,                 0, h, GRIDHEIGHT     - 2, 1, 1, 1, 1, a0, a1, a2, True );
     SetLight( 3, GRIDWIDTH     - 1, h, GRIDHEIGHT     - 2, 1, 1, 1, 1, a0, a1, a2, True );
     SetLight( 4, GRIDWIDTH / 2 + 1, h, GRIDHEIGHT / 2 - 2, 1, 1, 1, 1, a0, a1, a2, True );
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
               DrawMesh( MESH_BOMBERMAN, False );
               PopObjectMatrix();
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
Begin
     EnableLighting();
     SetLighting( 5.0, 1.0, 1.8, 2.4 );

     SetMaterial( w, w, w, 1.0 );

     i := 1;
     While ( i <= GetBombCount() ) Do Begin
           SetMaterial( w, w, w, 1.0 );
           SetTexture( 1, TEXTURE_NONE );
           PushObjectMatrix( GetBombByCount(i).X, 0, GetBombByCount(i).Y,
                             1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)*0.5),
                             1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)*0.5),
                             1/30*(0.7+Cos(4*GetBombByCount(i).Time)*Cos(4*GetBombByCount(i).Time)*0.5),
                             0, 0, 0 );
           DrawMesh( MESH_BOMB, False );
           PopObjectMatrix();     _(èol
          PushBillboardMatrix( vCamera.x, vCamera.y, vCamera.z, GetFlameByCount(i).X - 0.001, 0, GetFlameByCount(i).Y - 0.001 ); // on évite les cas particuliers (les angles à 90° bug)
          DrawSprite( 1.0 + 2.0 * GetFlameByCount(i).Itensity, 1.0 + 2.0 * GetFlameByCount(i).Itensity, 1, 1, 1, GetFlameByCount(i).Itensity, True );
          PopObjectMatrix();
          // flammes centrales
          PushBillboardMatrix( vColk(_-èol
              For i := 1 To GetBombermanCount() Do
                  SetString( STRING_SCORE_TABLE(i), GetBombermanByCount(i).Name + Format(' : %2d ; %d kill(s), %d death(s).', [GetBombermanByCount(i).Score, GetBombermanByCount(i).Kills, GetBombermanByCount(i).Deaths]), Single(i) * 0.1 + 0.1, 1.0, 20 );
        End;
        If GetBombermanCount() <> 0 Then
           For i := 1 To GetBombermanCount() Do
               DrawString( STRING_SCORE_TABLE(i), -w / h * 0.9, 0.4 - 0.1 * Single(i), -1, 0.018 * w / h, 0.024, 1, 1, 1, 0.8, True, SPRITE_CHARSET_TERMINAL, SPRITE_CHARSET_TERMINALX, EFFECT_TERMINAL );
        bScoreTable := True;
     End Else Begin
        bS_ç(èop(è_-tr



End.

