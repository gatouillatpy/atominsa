Unit UComputer;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UUtils, UBomberman, UForm, UFlame, UListBomb;

Type Table = Array [1..GRIDWIDTH,1..GRIDHEIGHT] Of Integer;

Procedure ProcessComputer ( pBomberman : CBomberman ; nSkill : Integer ) ;
Function CalculateFastDanger ( fX, fY : Single; x, y : Integer ; pState : Table ; iSkill : Integer ; isAfraid : Boolean ) : Integer ;
Function CalculateDanger ( fX, fY : Single; x, y, xMin, xMax, yMin, yMax : Integer ; wState : Table ;
                               wSkill : Integer ; canPush : Boolean ; isAfraid : Boolean ) : Integer ;
Function PutBomb( x, y : Integer; pState : Table; wSkill : Integer; m_bMustPut : Boolean ) : Boolean ;
Function CanSpoog( nX, nY : Integer; wState : Table; wSkill, wDirection : Integer ) : Boolean;
Function SmallWay( aX, aY, bX, bY, n : Integer; m_aState : Table ) : Boolean;
Procedure DangerWay( aX, aY, bX, bY, n : Integer; m_aState : Table; Var p_nDangerMin, p_nDirection : Integer );




Implementation

Uses UGame, UItem, UDisease, USuperDisease, UBomb, UBlock, UTriggerBomb, USetup;


Const SKILL_NOVICE         = 1;
Const SKILL_AVERAGE        = 2;
Const SKILL_MASTERFUL      = 3;
Const SKILL_GODLIKE        = 4;






Procedure ProcessComputer ( pBomberman : CBomberman ; nSkill : Integer ) ;
Var
    i, j, k : Integer;
    isBombermanFound,                                                // Le bomberman a-t-il d�j� �t� comptabilis� dans le tableau
    continue,                                                        // La boucle while doit-elle �tre continu�e
    canPush,                                                         // Le bomberman peut pousser la bombe (donc n'est pas sur la bombe)
    afraid,                                                          // Le bomberman a-t-il peur des autres bombermans
    doExplosion : Boolean;                                           // Le bomberman doit-il faire exploser sa Trigger Bombe
    bLeft, bDown, bUp, bRight : Integer;                             // Limites pour les calculs dans le tableau
    dangerMin : Integer;                                             // Le danger minimal connu pour l'instant
    nDirection : Integer;                                            // La direction pour aller � la cible.
    sum : Integer;                                                   // La somme des dangers sans tenir compte des blocks et des bords.
    pX, pY, cX, cY, lX, lY, bX, bY : Integer;                        // Renommage des coordonn�es pour am�liorer la lisibilit� du code.
    fTime, dt : Single;                                              // Temps actuel et diff�rence de temps.
    aState : Array [1..GRIDWIDTH,1..GRIDHEIGHT] Of Integer ;         // tableau du contenu de chaque case, 0 pour vide, 1 pour flamme, 2 pour bombe et 4 pour autre bomberman.
Begin
// Initialisation des variables
   fTime := GetTime();
   dt := fTime - pBomberman.IATime;
   pBomberman.IATime := fTime;
   pX := Trunc(pBomberman.Position.X + 0.5);
   pY := Trunc(pBomberman.Position.Y + 0.5);
   cX := Trunc(pBomberman.CX + 0.5);
   cY := Trunc(pBomberman.CY + 0.5);
   lX := Trunc(pBomberman.LX + 0.5);
   lY := Trunc(pBomberman.LY + 0.5);
   dangerMin := 10000;
   isBombermanFound := false;
   
  // pGrid.DelBlock(pX,pY);
   
   If ( ( nSkill = SKILL_GODLIKE ) And ( ( pBomberman.DiseaseNumber <> DISEASE_NONE )
   Or ( pBomberman.uGrabbedBomb <> Nil ) Or ( pBomberman.bGrabbed = True ) ) ) Then
      afraid := false
   Else
       afraid := true;
   

// Mise � jour du tableau.
     
     // On met toutes les donn�es � 0.
     For i := 1 To GRIDWIDTH Do Begin
         For j := 1 To GRIDHEIGHT Do Begin
             aState[i,j] := 0;
         End;
     End;

     // On ajoute 1 � chaque case qui contient une flamme.
     For k := 1 To GetFlameCount() Do Begin
         If ( GetFlameByCount(k) <> Nil ) And CheckCoordinates( GetFlameByCount(k).X, GetFlameByCount(k).Y ) Then
            aState[GetFlameByCount(k).X, GetFlameByCount(k).Y] += 1
         Else Begin
             If bDebug Then AddLineToConsole( 'Bug in GetFlame' );
             FreeFlame();
         End;
     End;

     // On ajoute 2 � chaque case qui contient une bombe.
     For k := 1 To GetBombCount() Do Begin
         If ( GetBombByCount(k).BIndex = pBomberman.BIndex ) And ( GetBombByCount(k) Is CTriggerBomb )
         And ( ( GetBombByCount(k) As CTriggerBomb ).bIgnition = False ) Then
             aState[Trunc(GetBombByCount(k).Position.X + 0.5), Trunc(GetBombByCount(k).Position.Y + 0.5)] += 32;
         aState[Trunc(GetBombByCount(k).Position.X + 0.5), Trunc(GetBombByCount(k).Position.Y + 0.5)] += 2;
     End;
     
     // On ajoute 4 � chaque case qui contient un personnage autre que l'IA
     For k := 1 To GetBombermanCount() Do Begin
         If ( Trunc(GetBombermanByCount(k).Position.X + 0.5) <> pX )
         Or ( Trunc(GetBombermanByCount(k).Position.Y + 0.5) <> pY )
         Or ( isBombermanFound = true ) Then Begin
             aState[Trunc(GetBombermanByCount(k).Position.X + 0.5), Trunc(GetBombermanByCount(k).Position.Y + 0.5)] += 4;
         End
         Else isBombermanFound := true;
     End;
     
     // On ajoute 8 � chaque case qui contient un block et 16 � celles qui continennent un bonus.
     For i := 1 To GRIDWIDTH Do Begin
         For j := 1 To GRIDHEIGHT Do Begin
             If ( pGrid.GetBlock(i,j) Is CBlock ) And ( aState[i, j] mod 4 < 2 ) Then Begin
                If ( Not( pGrid.GetBlock(i,j) Is CItem ) ) Or ( (pGrid.GetBlock(i,j) As CItem).IsExplosed() = false ) Then
                   aState[i, j] += 8;
                If ( pGrid.GetBlock(i,j) is CItem ) And ( (pGrid.GetBlock(i,j) As CItem).IsExplosed() = true ) Then
                   aState[i, j] += 16;
             End;
         End;
     End;


        
// Mise � jour des dangers s'il ne vient pas de bouger
   If ( pBomberman.CanCalculate = true ) Or ( pBomberman.Position.X <> pBomberman.LX )
   Or ( pBomberman.Position.Y <> pBomberman.LY ) Then Begin
      // Mise � jour de canPush
      If ( pBomberman.Kick = true ) Or ( pBomberman.Punch = true ) Then
         canPush := true
      Else
          canPush := false;
      // Case du bomberman : pas de pouss�e de bombes possible
      pBomberman.Danger := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX, pY, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
      // Gauche : pouss�e possible s'il y a une bombe � gauche et rien apr�s
      If ( pX >= 3 ) And ( aState[pX - 1, pY] mod 4 >= 2 ) And ( aState[pX - 2, pY] mod 16 = 0 ) Then
         pBomberman.DangerLeft := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX - 1, pY, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush, afraid)
      Else
          pBomberman.DangerLeft := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX - 1, pY, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
      // Droite
      If ( pX <= GRIDWIDTH - 2 ) And ( aState[pX + 1, pY] mod 4 >= 2 ) And ( aState[pX + 2, pY] mod 16 = 0 ) Then
         pBomberman.DangerRight := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX + 1, pY, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush, afraid)
      Else
          pBomberman.DangerRight := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX + 1, pY, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
      // Haut
      If ( pY >= 3 ) And ( aState[pX, pY - 1] mod 4 >= 2 ) And ( aState[pX, pY - 2] mod 16 = 0 ) Then
         pBomberman.DangerUp := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX, pY - 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush, afraid)
      Else
          pBomberman.DangerUp := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX, pY - 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
      // Bas
      If ( pY <= GRIDHEIGHT - 2 ) And ( aState[pX, pY + 1] mod 4 >= 2 ) And ( aState[pX, pY + 2] mod 16 = 0 ) Then
         pBomberman.DangerDown := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX, pY + 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush, afraid)
      Else
          pBomberman.DangerDown := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX, pY + 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
      // Bas + Gauche
      If ( pY >= 3 ) And ( pX >= 3 ) And ( aState[pX - 1, pY - 1] mod 4 >= 2 ) And ( aState[pX, pY + 2] mod 16 = 0 ) Then
         pBomberman.DangerDL := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX - 1, pY - 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush, afraid)
      Else
          pBomberman.DangerDL := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX - 1, pY - 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
      // Bas + Droite
      If ( pY >= 3 ) And ( pX <= GRIDWIDTH - 2 ) And ( aState[pX + 1, pY - 1] mod 4 >= 2 ) And ( aState[pX, pY + 2] mod 16 = 0 ) Then
         pBomberman.DangerDR := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX + 1, pY - 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush, afraid)
      Else
          pBomberman.DangerDR := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX + 1, pY - 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
      // Haut + Gauche
      If ( pY <= GRIDHEIGHT - 2 ) And ( pX >= 3 ) And ( aState[pX - 1, pY + 1] mod 4 >= 2 ) And ( aState[pX, pY + 2] mod 16 = 0 ) Then
         pBomberman.DangerUL := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX - 1, pY + 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush, afraid)
      Else
          pBomberman.DangerUL := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX - 1, pY + 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
      // Haut + Droite
      If ( pY <= GRIDHEIGHT - 2 ) And ( pX <= GRIDWIDTH - 2 ) And ( aState[pX + 1, pY + 1] mod 4 >= 2 ) And ( aState[pX, pY + 2] mod 16 = 0 ) Then
         pBomberman.DangerUR := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX + 1, pY + 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, canPush, afraid)
      Else
          pBomberman.DangerUR := CalculateDanger(pBomberman.Position.X, pBomberman.Position.Y, pX + 1, pY + 1, 1, GRIDWIDTH, 1, GRIDHEIGHT, aState, nSkill, false, afraid);
   End;



// Calcul des coordonn�es cibles.
   If ( pBomberman.CanCalculate = true ) Or ( pBomberman.Position.X <> pBomberman.LX )
   Or ( pBomberman.Position.Y <> pBomberman.LY ) Then Begin
               
   // On fixe les limites du rectangle dans lequel on va calculer les dangers.
      If ( pX - ( nSkill + 2 ) < 1 ) Then bLeft := 1 Else bLeft := pX - ( nSkill + 2 );
      If ( pX + ( nSkill + 2 ) > GRIDWIDTH ) Then bRight := GRIDWIDTH Else bRight := pX + ( nSkill + 2 );
      If ( pY - ( nSkill + 2 ) < 1 ) Then bUp := 1 Else bUp := pY - ( nSkill + 2 );
      If ( pY + ( nSkill + 2 ) > GRIDHEIGHT ) Then bDown := GRIDHEIGHT Else bDown := pY + ( nSkill + 2 );

   // Puis on calcule les dangers et s�lectionne le minimum.
      For i := bLeft To bRight Do Begin
         For j := bUp To bDown Do Begin
              sum := CalculateFastDanger( pBomberman.Position.X, pBomberman.Position.Y, i, j, aState, nSkill, afraid );
              continue := SmallWay( pX, pY, i, j, nSkill + 2, aState );
              If ( sum < dangerMin ) And ( continue = true )
              Or ( ( sum = dangerMin ) And ( Random < 0.5 ) ) Then Begin
                  cX := i;
                  cY := j;
                  dangerMin := sum;
              End;
         End;
      End;

   // Calcul du danger du chemin entre le bomberman et le cible.
      DangerWay( pX, pY, cX, cY, nSkill + 2, aState, dangerMin, nDirection );
      If ( nDirection in [ 1..4 ] ) And ( dangerMin in [ 1..9999 ] ) Then Begin
          Case nDirection Of
               1 : pBomberman.DangerLeft := ( pBomberman.DangerLeft + 2 * dangerMin ) div 3;
               2 : pBomberman.DangerRight := ( pBomberman.DangerRight + 2 * dangerMin ) div 3;
               3 : pBomberman.DangerUp := ( pBomberman.DangerUp + 2 * dangerMin ) div 3;
               4 : pBomberman.DangerDown := ( pBomberman.DangerDown + 2 * dangerMin ) div 3;
          End;
      End;
   End;
   
   
   
   // Minimiser les changements de directions
   If ( pBomberman.SumDirGetDelta <> 0 ) Then Begin
       If ( pBomberman.Direction2 = 180 ) Then pBomberman.DangerUp := pBomberman.DangerUp - 1024 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
       If ( pBomberman.Direction2 = 0 ) Then pBomberman.DangerDown := pBomberman.DangerDown - 1024 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
       If ( pBomberman.Direction2 = -90 ) Then pBomberman.DangerRight := pBomberman.DangerRight - 1024 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
       If ( pBomberman.Direction2 = 90 ) Then pBomberman.DangerLeft := pBomberman.DangerLeft - 1024 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
       If ( pBomberman.Direction2 = 135 ) Then pBomberman.DangerUL := pBomberman.DangerUL - 1024 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
       If ( pBomberman.Direction2 = -135 ) Then pBomberman.DangerUR := pBomberman.DangerUR - 1024 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
       If ( pBomberman.Direction2 = 45 ) Then pBomberman.DangerDL := pBomberman.DangerDL - 1024 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
       If ( pBomberman.Direction2 = -45 ) Then pBomberman.DangerDR := pBomberman.DangerDR - 1024 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
       pBomberman.Danger := pBomberman.Danger - 64 div Trunc ( 64 * pBomberman.SumDirGetDelta * pBomberman.SumDirGetDelta + 0.5 );
   End;
   pBomberman.SumDirGetDelta := pBomberman.SumDirGetDelta + dt;
   
   
   
   // Empecher de rester fixe
   If ( pBomberman.SumFixGetDelta > 4 ) Then
      pBomberman.Danger := pBomberman.Danger + Trunc( ( pBomberman.SumFixGetDelta - 4.0 ) * ( pBomberman.SumFixGetDelta - 4.0 ) * 8 );
   If ( pBomberman.SumFixGetDelta < 12 ) Then
      pBomberman.SumFixGetDelta := pBomberman.SumFixGetDelta + dt;
   


   // Risques de passer par les cases autour pour les diagonales.
   pBomberman.DangerUL := ( pBomberman.DangerUp + pBomberman.DangerLeft + 2 * pBomberman.DangerUL ) div 4;
   pBomberman.DangerUR := ( pBomberman.DangerUp + pBomberman.DangerRight + 2 * pBomberman.DangerUR ) div 4;
   pBomberman.DangerDL := ( pBomberman.DangerDown + pBomberman.DangerLeft + 2 * pBomberman.DangerDL ) div 4;
   pBomberman.DangerDR := ( pBomberman.DangerDown + pBomberman.DangerRight + 2 * pBomberman.DangerDR ) div 4;



// Si les touches sont invers�es et que le niveau est godlike ou masterful, alors les pr�f�rences sont invers�es.
   If ( ( nSkill = SKILL_GODLIKE ) Or ( nSkill = SKILL_MASTERFUL ) ) And ( pBomberman.Reverse = true ) Then Begin
       dangerMin := pBomberman.DangerLeft;
       pBomberman.DangerLeft := pBomberman.DangerRight;
       pBomberman.DangerRight := dangerMin;
       dangerMin := pBomberman.DangerUp;
       pBomberman.DangerUp := pBomberman.DangerDown;
       pBomberman.DangerDown := dangerMin;
       dangerMin := pBomberman.DangerUL;
       pBomberman.DangerUL := pBomberman.DangerDR;
       pBomberman.DangerDR := dangerMin;
       dangerMin := pBomberman.DangerUR;
       pBomberman.DangerUR := pBomberman.DangerDL;
       pBomberman.DangerDL := dangerMin;
   End;



// PunchBomb
   If ( ( nSkill = SKILL_GODLIKE ) Or ( nSkill = SKILL_MASTERFUL ) ) And ( pBomberman.bCanPunch ) Then
      pBomberman.PunchBomb( dt );
      


// Explosion des trigger bombes.
   If ( pBomberman.TriggerBomb <> Nil ) Then Begin
      pBomberman.SumIgnitionGetDelta := pBomberman.SumIgnitionGetDelta + dt;

      // Initialisation des donn�es
      doExplosion := false;
      bX := Trunc(pBomberman.TriggerBomb^.Bomb.Position.X + 0.5);
      bY := Trunc(pBomberman.TriggerBomb^.Bomb.Position.Y + 0.5);
      If ( bX - (pBomberman.FlameSize - 1) <= 1 ) Then bLeft := 1 Else bLeft := bX - (pBomberman.FlameSize - 1);
      If ( bX + (pBomberman.FlameSize - 1) >= GRIDWIDTH ) Then bRight := GRIDWIDTH Else bRight := bX + (pBomberman.FlameSize - 1);
      If ( bY - (pBomberman.FlameSize - 1) <= 1 ) Then bUp := 1 Else bUp := bY - (pBomberman.FlameSize - 1);
      If ( bY + (pBomberman.FlameSize - 1) >= GRIDHEIGHT ) Then bDown := GRIDHEIGHT Else bDown := bY + (pBomberman.FlameSize - 1);

      // Rechercher d'un bomberman pour le niveau godlike ou masterful.
      If ( nSkill = SKILL_GODLIKE ) Or ( nSkill = SKILL_MASTERFUL ) Then Begin
          // S'il y a quelqu'un sur la ligne/colonne de la bombe et qu'il n'y a pas de bloc ou de bonus entre alors on fait exploser la bombe
          // Gauche
          continue := true;
          i := bX - 1;
          While ( continue = true ) And ( i >= bLeft ) Do Begin
                If ( aState[i, bY] mod 8 >= 4 ) Then
                   doExplosion := true;
                If ( aState[i, bY] >= 8 ) Then
                   continue := false;
                i -= 1;
          End;
          // Droite
          continue := true;
          i := bX + 1;
          While ( continue = true ) And ( i <= bRight ) Do Begin
                If ( aState[i, bY] mod 8 >= 4 ) Then
                   doExplosion := true;
                If ( aState[i, bY] >= 8 ) Then
                   continue := false;
                i += 1;
          End;
          // Haut
          continue := true;
          j := bY - 1;
          While ( continue = true ) And ( j >= bUp ) Do Begin
                If ( aState[bX, j] mod 8 >= 4 ) Then
                   doExplosion := true;
                If ( aState[bX, j] >= 8 ) Then
                   continue := false;
                j -= 1;
          End;
          // Bas
          continue := true;
          j := bY + 1;
          While ( continue = true ) And ( j <= bDown ) Do Begin
                If ( aState[bX, j] mod 8 >= 4 ) Then
                   doExplosion := true;
                If ( aState[bX, j] >= 8 ) Then
                   continue := false;
                j += 1;
          End;
      End;
      
      // Si cela fait plus de 32 secondes que la bombe est pos�e, alors on peut la faire exploser.
      If ( pBomberman.SumIgnitionGetDelta > 16 ) Then
         doExplosion := true;

      // S'il le bomberman est sur la ligne/colonne de la bombe, alors on ne fait pas exploser la bombe
      // Gauche
      continue := true;
      i := bX - 1;
      While ( continue = true ) And ( i >= bLeft ) Do Begin
            If ( pX = i ) And ( pY = bY ) Then
               doExplosion := false;
            If ( aState[i, bY] >= 8 ) Then
               continue := false;
            i -= 1;
      End;
      // Droite
      continue := true;
      i := bX + 1;
      While ( continue = true ) And ( i <= bRight ) Do Begin
            If ( pX = i ) And ( pY = bY ) Then
               doExplosion := false;
            If ( aState[i, bY] >= 8 ) Then
               continue := false;
            i += 1;
      End;
      // Haut
      continue := true;
      j := bY - 1;
      While ( continue = true ) And ( j >= bUp ) Do Begin
            If ( pX = bX ) And ( pY = j ) Then
               doExplosion := false;
            If ( aState[bX, j] >= 8 ) Then
               continue := false;
            j -= 1;
      End;
      // Bas
      continue := true;
      j := bY + 1;
      While ( continue = true ) And ( j <= bDown ) Do Begin
            If ( pX = bX ) And ( pY = j ) Then
               doExplosion := false;
            If ( aState[bX, j] >= 8 ) Then
               continue := false;
            j += 1;
      End;
      // M�me case
      If ( pX = bX ) And ( pY = bY ) Then
         doExplosion := false;

      // Explosion de la bombe si n�cessaire
      If ( doExplosion = true ) Then Begin
         pBomberman.DoIgnition();
         pBomberman.SumIgnitionGetDelta := 0;
      End;
   End;



// DropBomb pour le niveau Godlike.
If ( ( nSkill = SKILL_GODLIKE ) Or ( nSkill = SKILL_MASTERFUL ) )
And ( ( pBomberman.uGrabbedBomb <> Nil ) Or ( pBomberman.bGrabbed = True ) ) Then Begin
     pBomberman.SumGrabGetDelta := pBomberman.SumGrabGetDelta + dt;
     // Si la case suivante est un bloc, le bout de la map ou un bomberman, alors on lance la bombe.
     If ( ( pBomberman.Direction = 0 ) And ( ( pY + 1 > GRIDHEIGHT )
     Or ( aState[ pX, pY + 1 ] = 8 ) Or ( aState[ pX, pY + 1 ] = 4 ) ) )
     Or ( ( pBomberman.Direction = 180 ) And ( ( pY - 1 < 1 )
     Or ( aState[ pX, pY - 1 ] = 8 ) Or ( aState[ pX, pY - 1 ] = 4 ) ) )
     Or ( ( pBomberman.Direction = -90 ) And ( ( pX + 1 > GRIDWIDTH )
     Or ( aState[ pX + 1, pY ] = 8 ) Or ( aState[ pX + 1, pY ] = 4 ) ) )
     Or ( ( pBomberman.Direction = 90 ) And ( ( pX - 1 < 1 )
     Or ( aState[ pX - 1, pY ] = 8 ) Or ( aState[ pX - 1, pY ] = 4 ) ) )
     // Si �a fait plus de 8 secondes que l'on porte la bombe et qu'il n'y a ni bombe, ni flamme � la case suivante,
     // alors on lance la bombe.
     Or ( ( pBomberman.SumGrabGetDelta >= 8 )
     And ( ( ( pBomberman.Direction = 0 ) And ( aState[ pX, pY + 1 ] mod 4 = 0 ) )
     Or ( ( pBomberman.Direction = 180 ) And ( aState[ pX, pY - 1 ] mod 4 = 0 ) )
     Or ( ( pBomberman.Direction = -90 ) And ( aState[ pX + 1, pY ] mod 4 = 0 ) )
     Or ( ( pBomberman.Direction = 90 ) And ( aState[ pX - 1, pY ] mod 4 = 0 ) ) ) ) Then Begin
        pBomberman.PrimaryKeyUp( dt );
     End;
End;
      
      

// Si les derni�res coordonn�es ne sont pas les m�mes que les actuelles, alors d�terminer pX et pY.
   If ( pBomberman.Position.X <> pBomberman.LX )
   Or ( pBomberman.Position.Y <> pBomberman.LY ) Then Begin
      // Mise � jour de lX et lY
      pBomberman.LX := pBomberman.Position.X;
      pBomberman.LY := pBomberman.Position.Y;
      pBomberman.SumFixGetDelta := 0;

      // Comparaison des dangers.
      If ( pBomberman.DangerUL <= pBomberman.DangerUR ) And ( pBomberman.DangerUL <= pBomberman.DangerDL )
      And ( pBomberman.DangerUL <= pBomberman.DangerDR ) And ( pBomberman.DangerUL <= pBomberman.DangerLeft )
      And ( pBomberman.DangerUL < pBomberman.Danger ) And ( pBomberman.DangerUL <= pBomberman.DangerRight )
      And ( pBomberman.DangerUL <= pBomberman.DangerUp ) And ( pBomberman.DangerUL <= pBomberman.DangerDown ) Then Begin
          If ( pBomberman.Direction2 <> 135 ) Then Begin
             pBomberman.SumDirGetDelta := 0.125;
             pBomberman.Direction2 := 135;
          End;
          pBomberman.MoveLeft( dt );
          pBomberman.MoveUp( dt );
          pBomberman.CanCalculate := false;
      End
      Else  If ( pBomberman.DangerUR <= pBomberman.DangerDL )
      And ( pBomberman.DangerUR <= pBomberman.DangerDR ) And ( pBomberman.DangerUR <= pBomberman.DangerLeft )
      And ( pBomberman.DangerUR < pBomberman.Danger ) And ( pBomberman.DangerUR <= pBomberman.DangerRight )
      And ( pBomberman.DangerUR <= pBomberman.DangerUp ) And ( pBomberman.DangerUR <= pBomberman.DangerDown ) Then Begin
          If ( pBomberman.Direction2 <> -135 ) Then Begin
             pBomberman.SumDirGetDelta := 0.125;
             pBomberman.Direction2 := -135;
          End;
          pBomberman.MoveUp( dt );
          pBomberman.MoveRight( dt );
          pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerDL <= pBomberman.DangerDR ) And ( pBomberman.DangerDL <= pBomberman.DangerLeft )
      And ( pBomberman.DangerDL < pBomberman.Danger ) And ( pBomberman.DangerDL <= pBomberman.DangerRight )
      And ( pBomberman.DangerDL <= pBomberman.DangerUp ) And ( pBomberman.DangerDL <= pBomberman.DangerDown ) Then Begin
          If ( pBomberman.Direction2 <> 45 ) Then Begin
              pBomberman.SumDirGetDelta := 0.125;
              pBomberman.Direction2 := 45;
          End;
          pBomberman.MoveDown( dt );
          pBomberman.MoveLeft( dt );
          pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerDR <= pBomberman.DangerLeft )
      And ( pBomberman.DangerDR < pBomberman.Danger ) And ( pBomberman.DangerDR <= pBomberman.DangerRight )
      And ( pBomberman.DangerDR <= pBomberman.DangerUp ) And ( pBomberman.DangerDR <= pBomberman.DangerDown ) Then Begin
          If ( pBomberman.Direction2 <> -45 ) Then Begin
              pBomberman.SumDirGetDelta := 0.125;
              pBomberman.Direction2 := -45;
          End;
          pBomberman.MoveRight( dt );
          pBomberman.MoveDown( dt );
          pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerLeft < pBomberman.Danger ) And ( pBomberman.DangerLeft <= pBomberman.DangerRight )
      And ( pBomberman.DangerLeft <= pBomberman.DangerUp ) And ( pBomberman.DangerLeft <= pBomberman.DangerDown ) Then Begin
         If ( pBomberman.Direction2 <> 90 ) Then Begin
            pBomberman.SumDirGetDelta := 0.125;
            pBomberman.Direction2 := 90;
         End;
         pBomberman.MoveLeft( dt );
         pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerRight < pBomberman.Danger ) And ( pBomberman.DangerRight <= pBomberman.DangerUp )
      And ( pBomberman.DangerRight <= pBomberman.DangerDown ) Then Begin
         If ( pBomberman.Direction2 <> -90 ) Then Begin
            pBomberman.SumDirGetDelta := 0.125;
            pBomberman.Direction2 := -90;
         End;
         pBomberman.MoveRight( dt );
         pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerUp < pBomberman.Danger ) And ( pBomberman.DangerUp <= pBomberman.DangerDown ) Then Begin
           If ( pBomberman.Direction2 <> 180 ) Then Begin
            pBomberman.SumDirGetDelta := 0.125;
            pBomberman.Direction2 := 180;
         End;
           pBomberman.MoveUp( dt );
           pBomberman.CanCalculate := false;
      End
      Else If ( pBomberman.DangerDown < pBomberman.Danger ) Then Begin
           If ( pBomberman.Direction2 <> 0 ) Then Begin
            pBomberman.SumDirGetDelta := 0.125;
            pBomberman.Direction2 := 0;
         End;
           pBomberman.MoveDown( dt );
           pBomberman.CanCalculate := false;
      End
      Else
          pBomberman.CanCalculate := true;

      // Le bomberman se d�place donc on initialise les possibilit�s de d�placement.
      If ( pX <> lX ) Or ( pY <> lY ) Then Begin
          pBomberman.CanGoToTheLeft := true;
          pBomberman.CanGoToTheRight := true;
          pBomberman.CanGoToTheUp := true;
          pBomberman.CanGoToTheDown := true;
      End;
   End

// Si les derni�res coordonn�es sont les m�mes que les actuelles alors prendre le plus bas danger possible.
   Else Begin
      // Mise � jour de lX et lY
      pBomberman.LX := pBomberman.Position.X;
      pBomberman.LY := pBomberman.Position.Y;

      // Si le bomberman ne bouge pas, alors tout recommence.
      // Sinon, il y a des probl�mes...
      If  ( ( pBomberman.Danger <= pBomberman.DangerLeft ) Or ( pBomberman.CanGoToTheLeft = false ) )
      And ( ( pBomberman.Danger <= pBomberman.DangerRight ) Or ( pBomberman.CanGoToTheRight = false ) )
      And ( ( pBomberman.Danger <= pBomberman.DangerUp ) Or ( pBomberman.CanGoToTheUp = false ) )
      And ( ( pBomberman.Danger <= pBomberman.DangerDown ) Or ( pBomberman.CanGoToTheDown = false ) ) Then Begin
          pBomberman.CanGoToTheLeft := true;
          pBomberman.CanGoToTheRight := true;
          pBomberman.CanGoToTheDown := true;
          pBomberman.CanGoToTheUp := true;
          pBomberman.CanCalculate := true;
      End
      Else Begin
      // Sinon, la situation est a d�coinc�e sans recalculer les dangers.
           pBomberman.CanCalculate := false;

           If ( ( pBomberman.DangerLeft <= pBomberman.DangerRight ) Or ( pBomberman.CanGoToTheRight = false ) )
           And ( ( pBomberman.DangerLeft <= pBomberman.DangerUp ) Or ( pBomberman.CanGoToTheUp = false ) )
           And ( ( pBomberman.DangerLeft <= pBomberman.DangerDown ) Or ( pBomberman.CanGoToTheDown = false ) )
           And ( pBomberman.CanGoToTheLeft = true ) Then Begin
               If ( pBomberman.Direction2 <> 90 ) Then Begin
                  If ( pBomberman.SumDirGetDelta > 1.0 ) Then
                     pBomberman.SumDirGetDelta := 1.0;
                  pBomberman.Direction2 := 90;
               End;
               pBomberman.MoveLeft( dt );
               pBomberman.CanGoToTheLeft := false;
           End
           Else If ( ( pBomberman.DangerRight <= pBomberman.DangerUp ) Or ( pBomberman.CanGoToTheUp = false ) )
           And ( ( pBomberman.DangerRight <= pBomberman.DangerDown ) Or ( pBomberman.CanGoToTheDown = false ) )
           And ( pBomberman.CanGoToTheRight = true ) Then Begin
               If ( pBomberman.Direction2 <> -90 ) Then Begin
                  If ( pBomberman.SumDirGetDelta > 1.0 ) Then
                     pBomberman.SumDirGetDelta := 1.0;
                  pBomberman.Direction2 := -90;
               End;
               pBomberman.MoveRight( dt );
               pBomberman.CanGoToTheRight := false;
           End
           Else If ( ( pBomberman.DangerUp <= pBomberman.DangerDown ) Or ( pBomberman.CanGoToTheDown = false ) )
           And ( pBomberman.CanGoToTheUp = true ) Then Begin
               If ( pBomberman.Direction2 <> 180 ) Then Begin
                  If ( pBomberman.SumDirGetDelta > 1.0 ) Then
                     pBomberman.SumDirGetDelta := 1.0;
                  pBomberman.Direction2 := 180;
               End;
               pBomberman.MoveUp( dt );
               pBomberman.CanGoToTheUp := false;
           End
           Else Begin
                If ( pBomberman.Direction2 <> 90 ) Then pBomberman.SumDirGetDelta := 1.0;
                If ( pBomberman.Direction2 <> 0 ) Then Begin
                  If ( pBomberman.SumDirGetDelta > 1.0 ) Then
                     pBomberman.SumDirGetDelta := 1.0;
                  pBomberman.Direction2 := 0;
               End;
                pBomberman.MoveDown( dt );
                pBomberman.CanGoToTheDown := false;
           End;
      End;

      // Si le bomberman n'a plus le droit de bouger, alors toutes les coordonn�es redeviennent possibles.
      // Cela sert notamment quand la fonction ProcessComputer est lanc�e avant que les d�placements soient autoris�es.
      If ( pBomberman.CanGoToTheRight = false ) And ( pBomberman.CanGoToTheLeft = false )
      And ( pBomberman.CanGoToTheDown = false ) And ( pBomberman.CanGoToTheUp = false ) Then Begin
          pBomberman.CanGoToTheRight := true;
          pBomberman.CanGoToTheLeft := true;
          pBomberman.CanGoToTheUp := true;
          pBomberman.CanGoToTheDown := true;
      End;
   End;



// Posage de bombes
   // On ajoute le danger � la somme sans tenir compte des murs.
   sum := pBomberman.Danger + pBomberman.DangerLeft + pBomberman.DangerRight + pBomberman.DangerUp
         + pBomberman.DangerDown;
   If ( pX = 1 ) Or ( aState[ pX - 1, pY ] mod 16 >= 8 ) Then sum := sum - 8192;      // On retire les dangers des bords et des blocs.
   If ( pX = GRIDWIDTH ) Or ( aState[ pX + 1, pY ] mod 16 >= 8 ) Then sum := sum - 8192;
   If ( pY = 1 ) Or ( aState[ pX, pY - 1 ] mod 16 >= 8 ) Then sum := sum - 8192;
   If ( pY = GRIDHEIGHT ) Or ( aState[ pX, pY + 1 ] mod 16 >= 8 ) Then sum := sum - 8192;

   // Si le bomberman vient de bouger et qu'il n'y a pas trop de danger autour, alors il peut cr�er une bombe.
   // Si le bomberman est malade et que le niveau est godlike ou masterful, alors il ne pose pas la bombe.
   If ( sum < 1024 ) And ( ( nSkill = SKILL_NOVICE ) Or ( nSkill = SKILL_AVERAGE ) Or ( pBomberman.ExploseBombTime >= 3 ) )
   And ( PutBomb( Trunc( pBomberman.Position.X + 0.5 ), Trunc( pBomberman.Position.Y + 0.5 ), aState, nSkill,
   pBomberman.SumBombGetDelta > 8 ) ) Then Begin
       pBomberman.CreateBomb( dt, Random( 1000000000 ) );
       If ( pBomberman.bCanGrabBomb ) And ( ( nSkill = SKILL_GODLIKE ) Or ( nSkill = SKILL_MASTERFUL ) ) Then Begin
          pBomberman.PrimaryKeyDown( dt );
          pBomberman.SumGrabGetDelta := 0;
       End;
       If ( pBomberman.bCanSpoog ) And ( ( nSkill = SKILL_GODLIKE ) Or ( nSkill = SKILL_MASTERFUL ) )
       And ( CanSpoog( Trunc( pBomberman.Position.X + 0.5), Trunc( pBomberman.Position.Y + 0.5 ), aState, nSkill,
       pBomberman.Direction ) ) Then Begin
          pBomberman.CreateBomb( dt, Random( 1000000000 ) );
       End;
       pBomberman.SumBombGetDelta := 0;
   End
   Else
       pBomberman.SumBombGetDelta := pBomberman.SumBombGetDelta + dt;

     
     
// Entr�es des variables locales dans les variables du bomberman.
     pBomberman.CX := cX;
     pBomberman.CY := cY;

End;






Function CalculateFastDanger ( fX, fY : Single; x, y : Integer; pState : Table ; iSkill : Integer ; isAfraid : Boolean ) : Integer ;
Var
   result1 : Integer;                            // r�sultat renvoy�
   cLeft, cRight, cUp, cDown : Integer;          // limites pour les calculs du tableau.
Begin
// Initialisation des variables
   result1 := 0;                                 // Le minimum est 0, le maximum est autour de 10000.
   If ( x - ( iSkill + 2 ) < 1 ) Then cLeft := 1 Else cLeft := x - ( iSkill + 2 );
   If ( x + ( iSkill + 2 ) > GRIDWIDTH ) Then cRight := GRIDWIDTH Else cRight := x + ( iSkill + 2 );
   If ( y - ( iSkill + 2 ) < 1 ) Then cUp := 1 Else cUp := y - ( iSkill + 2 );
   If ( y + ( iSkill + 2 ) > GRIDHEIGHT ) Then cDown := GRIDHEIGHT Else cDown := y + ( iSkill + 2 );

// Traitement des flammes, des bombes et des bombermans.
   result1 := CalculateDanger( fX, fY, x, y, cLeft, cRight, cUp, cDown, pState, iSkill, false, isAfraid );
// Pour que les coins ne soient pas favoris�s.
   result1 := result1 * 49 div ( ( cRight - cLeft + 1 ) *  ( cDown - cUp + 1 ) );

CalculateFastDanger := result1;
End;




Function CalculateDanger ( fX, fY : Single; x, y, xMin, xMax, yMin, yMax : Integer ; wState : Table ;
                               wSkill : Integer ; canPush : Boolean ; isAfraid : Boolean ) : Integer ;
Var
   iBomb,                                        // Position de la bombe
   iExit,                                        // Position de la sortie
   numFreeCase,                                  // Num�ro de la case libre (1:gauche,2:droite,3:haut,4:bas)
   sumFreeCases,                                 // Nombres de cases libres.
   result2 : Integer;                            // R�sultat renvoy�
   i, j, k : Integer;
   bEnd,
   continue,                                     // Vrai si on doit continuer la boucle while
   isDangerous,                                  // Vrai si la bombe est dangereuse
   freeCase,                                     // Vrai si une case est libre
   upBomb, downBomb,                             // Vrai s'il y a une bombe sur la ligne/colonne sup�rieure (resp. inf�rieure)
   canPushThisBomb,                              // Vrai s'il peut pousser la bombe en question.
   blocked : Boolean;                            // Vrai si le bomberman est coinc� ( avec au maximum une case de libert� ).
   pBomb : CBomb;
   pPlayer : CBomberman;
   aTableIndex : ArrayIndex;
   bIsPlayer : Boolean;
   bBackupIsAfraid : Boolean;
Begin
// Initialisation des variables
   result2 := 0;                                 // Le minimum est 0, le maximum est autour de 10000.
   bBackupIsAfraid := IsAfraid;
   If ( xMin < 1 ) Then xMin := 1;
   If ( xMax > GRIDWIDTH ) Then xMax := GRIDWIDTH;
   If ( yMin < 1 ) Then yMin := 1;
   If ( yMax > GRIDHEIGHT ) Then xMax := GRIDHEIGHT;

// Traitement des objets.
   For i := xMin To xMax Do Begin
       For j := yMin To yMax Do Begin
       // Traitement des objets qui sont sur des cases diff�rentes.
           If (i <> x) Or ( j <> y )Then Begin
           // Traitement des flammes
              If ( wState[i, j] mod 2 = 1 ) Then
                 result2 := result2 + 128 div ( abs(x - i) + abs(y - j) );
           // Traitement des bombes qui ne sont pas sur la ligne/colonne du bomberman.
              If ( wState[i, j] mod 4 >= 2 ) Then Begin
              // Si le bomberman n'est pas sur la ligne/colonne de la bombe, le danger est relativement faible.
                 If ( x <> i ) And ( y <> j ) Then Begin
                 // Traitement des propres triggers bombes.
                    isDangerous := True;
                    If ( wState[i, j] mod 64 >= 32 ) Then Begin
                         isDangerous := False;
                         For k := 1 To i - 1 Do Begin
                             If ( wState[ k, j ] mod 4 >= 2 ) Then isDangerous := True;
                         End;
                         For k := i + 1 To GRIDWIDTH Do Begin
                             If ( wState[ k, j ] mod 4 >= 2 ) Then isDangerous := True;
                         End;
                         For k := 1 To j - 1 Do Begin
                             If ( wState[ i, k ] mod 4 >= 2 ) Then isDangerous := True;
                         End;
                         For k := j + 1 To GRIDHEIGHT Do Begin
                             If ( wState[ i, k ] mod 4 >= 2 ) Then isDangerous := True;
                         End;
                     End;
                     If ( isDangerous = True ) Then k := 32 Else k := 1;
                     result2 := result2 + 4 * k div ( abs(x - i) + abs(y - j) );
                     If ( GetBombByGridCoo(i, j) Is CBomb ) And ( GetBombByGridCoo(i, j).Time + 1 >= GetBombByGridCoo(i, j).ExploseTime ) Then Begin
                        result2 := result2 + 4 * k div ( abs(x - i) + abs(y - j) );
                     End;
                 End;
              End;
           // Traitement des bombermans si le bomberman n'est pas sur la m�me case.
              If ( wState[i, j] mod 8 >= 4 ) Then Begin
                 IsAfraid := bBackupIsAfraid;
                 If bSolo = True Then Begin
                     aTableIndex := GetBombermanIndexByCoo( i, y );
                     bIsPlayer := False;
                     For k := 1 To aTableIndex.Count Do Begin
                         If aTableIndex.Tab[k] = 1 Then
                            bIsPlayer := True;
                     End;
                     pPlayer := GetBombermanByIndex( 1 );
                     // Si ce n'est pas le joueur humain, on ne l'attaque pas en solo
                     If ( pPlayer <> Nil ) And ( pPlayer.Alive = True ) And ( bIsPlayer = True ) Then Begin
                         isAfraid := False;
                         If ( ( abs(x - i) + abs(y - j) ) <= 16 ) Then
                            result2 := result2 - 224 + 14 * ( abs(x - i) + abs(y - j) );
                     End;
                 End;
                 If ( ( abs(x - i) + abs(y - j) ) <= 4 ) And ( isAfraid = true ) Then
                    result2 := result2 + 32 - 2 * ( abs(x - i) + abs(y - j) );
                 If ( ( abs(x - i) + abs(y - j) ) >= 6 ) And ( isAfraid = true ) Then
                    result2 := result2 - 16 + 1 * ( abs(x - i) + abs(y - j) );
                 If ( ( abs(x - i) + abs(y - j) ) <= 16 ) And ( isAfraid = false ) Then
                    result2 := result2 - 32 + 2 * ( abs(x - i) + abs(y - j) );
              End;
           // Traitement des bonus pour le niveau godlike.
              If ( wSkill = SKILL_GODLIKE ) And ( wState[i, j] mod 32 >= 16 ) Then Begin
                 If ( pGrid.GetBlock(i,j) Is CDisease ) Or ( pGrid.GetBlock(i,j) Is CSuperDisease ) Then
                    result2 := result2 + 8 div ( abs(x - i) + abs(y - j) )
                 Else
                     result2 := result2 - 8 div ( abs(x - i) + abs(y - j) );
              End;

           End

       // Traitement des objets situ�s sur la m�me case.
           Else Begin
           // Traitement des flammes.
              If ( wState[i, j] mod 2 = 1 ) Then
                 result2 := result2 + 4096;
           // Traitement des bombes.
              // Si le niveau est godlike ou masterful est que le bomberman peut pousser la bombe, alors elle ne repr�sente pas un danger.
              If ( wState[i, j] mod 4 >= 2 ) Then Begin
                 canPushThisBomb := True;
                 If  ( CanPush = False )
                 Or ( ( x < i ) And ( ( i >= GRIDWIDTH ) Or ( wState[i+1, j] mod 16 >= 1 ) Or ( wState[i+1, j] mod 64 >= 32 ) ) )
                 Or ( ( x > i ) And ( ( i <= 1 ) Or ( wState[i-1, j] mod 16 >= 1 ) Or ( wState[i-1, j] mod 64 >= 32 ) ) )
                 Or ( ( y < j ) And ( ( j >= GRIDHEIGHT ) Or ( wState[i, j+1] mod 16 >= 1 ) Or ( wState[i, j+1] mod 64 >= 32 ) ) )
                 Or ( ( y > j ) And ( ( j <= 1 ) Or ( wState[i, j-1] mod 16 >= 1 ) Or ( wState[i, j-1] mod 64 >= 32 ) ) ) Then
                    canPushThisBomb := False;
                 If ( ( wSkill = SKILL_GODLIKE ) Or ( wSkill = SKILL_MASTERFUL ) ) And ( canPushThisBomb = true )
                 And ( GetBombByGridCoo(i, j) Is CBomb ) And ( GetBombByGridCoo(i, j).Time + 1 < GetBombByGridCoo(i, j).ExploseTime ) Then
                    result2 := result2 - 64
                 Else Begin
                     result2 := result2 + 2048;
                     If ( GetBombByGridCoo(i, j) Is CBomb ) And ( GetBombByGridCoo(i, j).Time + 1 >= GetBombByGridCoo(i, j).ExploseTime ) Then
                        result2 := result2 + 1024;
                     End;
              End;
           // Traitement des bombermans situ�s sur le m�me case.
              If ( wState[i, j] mod 8 >= 4 ) Then Begin
                 IsAfraid := bBackupIsAfraid;
                 If bSolo = True Then Begin
                     aTableIndex := GetBombermanIndexByCoo( i, y );
                     bIsPlayer := False;
                     For k := 1 To aTableIndex.Count Do Begin
                         If aTableIndex.Tab[k] = 1 Then
                            bIsPlayer := True;
                     End;
                     pPlayer := GetBombermanByIndex( 1 );
                     // Si ce n'est pas le joueur humain, on ne l'attaque pas en solo
                     If ( pPlayer <> Nil ) And ( pPlayer.Alive = True ) And ( bIsPlayer = True ) Then Begin
                         isAfraid := False;
                         result2 := result2 - 224;
                     End;
                 End;
                 If isAfraid Then
                    result2 := result2 + 32
                 Else
                     result2 := result2 - 32;
              End;
           // Traitement des blocks.
              If ( wState[i, j] mod 16 >= 8 ) Then
                 result2 := result2 + 8192;
           // Traitement des bonus pour le niveau godlike.
              If ( wSkill = SKILL_GODLIKE ) And ( wState[i, j] mod 32 >= 16 ) Then Begin
                 If ( pGrid.GetBlock(i,j) Is CDisease ) Or ( pGrid.GetBlock(i,j) Is CSuperDisease ) Then
                    result2 := result2 + 16
                 Else
                     result2 := result2 - 16;
              End;
           End;
       End;
   End;
   
   // Traitement des bombes sur la m�me ligne/colonne que le bomberman.
   // M�me colonne.
   For j := 1 To GRIDHEIGHT Do Begin
      If ( wState[x, j] mod 4 >= 2 ) Then Begin
          // Triggers Bombs.
          isDangerous := True;
          If ( wState[x, j] mod 64 >= 32 ) Then Begin
               isDangerous := False;
               For k := 1 To x - 1 Do Begin
                   If ( wState[ k, j ] mod 4 >= 2 ) Then isDangerous := True;
               End;
               For k := x + 1 To GRIDWIDTH Do Begin
                   If ( wState[ k, j ] mod 4 >= 2 ) Then isDangerous := True;
               End;
               For k := 1 To j - 1 Do Begin
                   If ( wState[ x, k ] mod 4 >= 2 ) Then isDangerous := True;
               End;
               For k := j + 1 To GRIDHEIGHT Do Begin
                   If ( wState[ x, k ] mod 4 >= 2 ) Then isDangerous := True;
               End;
          End;
          If ( isDangerous = True ) Then k := 32 Else k := 1;
          continue := true;
          If ( y > j ) Then iBomb := j + 1 Else iBomb := j - 1;
          While ( continue = true ) And ( iBomb <> y ) Do Begin
                If ( wState[x, iBomb] >= 8 ) Then
                   continue := false;
                If ( y > iBomb ) Then iBomb := iBomb + 1 Else iBomb := iBomb - 1;
          End;
          // S'il n'y a pas d'obstacle entre la bombe et le bomberman, alors il y a danger.
          If ( continue = true ) Then Begin
             If ( abs(y - j) <= 2 ) Then Begin
                If ( GetBombByGridCoo(x, j) Is CBomb ) And ( GetBombermanByIndex( GetBombByGridCoo(x, j).BIndex ) Is CBomberman )
                And ( abs(y - j) <= GetBombermanByIndex( GetBombByGridCoo(x, j).BIndex ).FlameSize ) Then
                   result2 := result2 + 32 * k
                Else
                    result2 := result2 + 4 * k;
             End
             Else Begin
                  If ( GetBombByGridCoo(x, j) Is CBomb ) And ( GetBombermanByIndex( GetBombByGridCoo(x, j).BIndex ) Is CBomberman )
                  And ( abs(y - j) <= GetBombermanByIndex( GetBombByGridCoo(x, j).BIndex ).FlameSize ) Then
                     result2 := result2 + 64 * k div abs(y - j)
                  Else
                      result2 := result2 + 8 * k div abs(y - j);
             End;
             If ( GetBombByGridCoo(x, j) Is CBomb )
             And ( GetBombByGridCoo(x, j).Time + 1 >= GetBombByGridCoo(x, j).ExploseTime ) Then Begin
                 If ( abs(y - j) <= 2 ) Then Begin
                    If ( GetBombByGridCoo(x, j) Is CBomb ) And ( GetBombermanByIndex( GetBombByGridCoo(x, j).BIndex ) Is CBomberman )
                    And ( abs(y - j) <= GetBombermanByIndex( GetBombByGridCoo(x, j).BIndex ).FlameSize ) Then
                       result2 := result2 + 32 * k
                    Else
                        result2 := result2 + 4 * k;
                 End
                 Else Begin
                      If ( GetBombByGridCoo(x, j) Is CBomb ) And ( GetBombermanByIndex( GetBombByGridCoo(x, j).BIndex ) Is CBomberman )
                      And ( abs(y - j) <= GetBombermanByIndex( GetBombByGridCoo(x, j).BIndex ).FlameSize ) Then
                         result2 := result2 + 64 * k div abs(y - j)
                      Else
                          result2 := result2 + 8 * k div abs(y - j);
                 End;
             End;
          End;
      End;
   End;
   // M�me ligne.
   For i := 1 To GRIDWIDTH Do Begin
       If ( wState[i, y] mod 4 >= 2 ) Then Begin
          // Triggers Bombs
          isDangerous := True;
          If ( wState[i, y] mod 64 >= 32 ) Then Begin
               isDangerous := False;
               For k := 1 To i - 1 Do Begin
                   If ( wState[ k, y ] mod 4 >= 2 ) Then isDangerous := True;
               End;
               For k := i + 1 To GRIDWIDTH Do Begin
                   If ( wState[ k, y ] mod 4 >= 2 ) Then isDangerous := True;
               End;
               For k := 1 To y - 1 Do Begin
                   If ( wState[ i, k ] mod 4 >= 2 ) Then isDangerous := True;
               End;
               For k := y + 1 To GRIDHEIGHT Do Begin
                   If ( wState[ i, k ] mod 4 >= 2 ) Then isDangerous := True;
               End;
          End;
          If ( isDangerous = True ) Then k := 32 Else k := 1;
          continue := true;
          If ( x > i ) Then iBomb := i + 1 Else iBomb := i - 1;
          While ( continue = true ) And ( iBomb <> x ) Do Begin
                If ( wState[iBomb, y] >= 8 ) Then
                   continue := false;
                If ( x > iBomb ) Then iBomb := iBomb + 1 Else iBomb := iBomb - 1;
          End;
          If ( continue = true ) Then Begin
             If ( abs(x - i) <= 2 ) Then Begin
                If ( GetBombByGridCoo(i, y) Is CBomb ) And ( GetBombermanByIndex( GetBombByGridCoo(i, y).BIndex ) Is CBomberman )
                And( abs(x - i) <= GetBombermanByIndex( GetBombByGridCoo(i, y).BIndex ).FlameSize ) Then
                   result2 := result2 + 32 * k
                Else
                    result2 := result2 + 4 * k;
             End
             Else Begin
                  If ( GetBombByGridCoo(i, y) Is CBomb ) And ( GetBombermanByIndex( GetBombByGridCoo(i, y).BIndex ) Is CBomberman )
                  And( abs(x - i) <= GetBombermanByIndex( GetBombByGridCoo(i, y).BIndex ).FlameSize ) Then
                     result2 := result2 + 64 * k div abs(x - i)
                  Else
                      result2 := result2 + 8 * k div abs(x - i);
             End;
             If ( GetBombByGridCoo(i, y) Is CBomb )
             And ( GetBombByGridCoo(i, y).Time + 1 >= GetBombByGridCoo(i, y).ExploseTime ) Then Begin
                 If ( abs(x - i) <= 2 ) Then Begin
                    If ( GetBombByGridCoo(i, y) Is CBomb ) And ( GetBombermanByIndex( GetBombByGridCoo(i, y).BIndex ) Is CBomberman )
                    And( abs(x - i) <= GetBombermanByIndex( GetBombByGridCoo(i, y).BIndex ).FlameSize ) Then
                       result2 := result2 + 32 * k
                    Else
                        result2 := result2 + 4 * k;
                 End
                 Else Begin
                      If ( GetBombByGridCoo(i, y) Is CBomb ) And ( GetBombermanByIndex( GetBombByGridCoo(i, y).BIndex ) Is CBomberman )
                      And( abs(x - i) <= GetBombermanByIndex( GetBombByGridCoo(i, y).BIndex ).FlameSize ) Then
                         result2 := result2 + 64 * k div abs(x - i)
                      Else
                          result2 := result2 + 8 * k div abs(x - i);
                 End;
             End;
          End;
       End;
   End;
   
   // Traitement des bombes sur la m�me case que le bomberman pour qu'il ne soit pas coinc�.
 {  If ( GetBombByGridCoo( Trunc( fX + 0.5 ), Trunc( fY + 0.5 ) ) is CBomb ) Then Begin
      pBomb := GetBombByGridCoo( Trunc( fX + 0.5 ), Trunc( fY + 0.5 ) );
      // Si le bomberman est un peu � gauche de la bombe, alors il doit aller � gauche.
      // De m�me pour les autres directions.
      If ( ( fX + 0.5 < pBomb.Position.X ) And ( x = Trunc( fX + 0.5 ) - 1 ) )
      Or ( ( fX + 0.5 > pBomb.Position.X ) And ( x = Trunc( fX + 0.5 ) + 1 ) )
      Or ( ( fY + 0.5 < pBomb.Position.Y ) And ( y = Trunc( fY + 0.5 ) - 1 ) )
      Or ( ( fY + 0.5 > pBomb.Position.Y ) And ( y = Trunc( fY + 0.5 ) + 1 ) ) Then Begin
         result2 := result2 - 512;
         If ( pBomb.Time + 1 >= pBomb.ExploseTime ) Then
            result2 := result2 - 512;
      End;
   End; }
   
   // Traitement des cases hors plateau.
   If ( x < 1 ) Or ( x > GRIDWIDTH ) Or ( y < 1 ) Or ( y > GRIDHEIGHT ) Then
      result2 := result2 + 8192;
      
      
      
// Traitement des cases sans issues pour les niveaux average, masterful et godlike.
   // Si pour chaque c�t�, il n'y a pas de case de sortie apr�s celle du c�t�
   // et qu'un bomberman est proche, alors il y a danger.
   // Ca sert � ne pas se faire coincer dans un coin.
   If ( wSkill <> SKILL_NOVICE ) Then Begin
      // S'il n'y a pas de bomberman � moins de 4 cases, alors il n'y a pas de danger.
      blocked := false;
      freeCase := false;
      sumFreeCases := 0;                // r�presente le nombre de cases libres.
      If ( x < 4 ) Then xMin := 1 Else xMin := x - 3;
      If ( x > GRIDWIDTH - 3 ) Then xMax := GRIDWIDTH Else xMax := x + 3;
      If ( y < 4 ) Then yMin := 1 Else yMin := y - 3;
      If ( x > GRIDHEIGHT - 3 ) Then yMax := GRIDHEIGHT Else yMax := y + 3;

      For i := xMin To xMax Do Begin
          For j := yMin To yMax Do Begin
              If ( wState[i, j] mod 8 >= 4 ) Then
                 blocked := true;
          End;
      End;

      // Pour la case de gauche, s'il y a deux cases libres de suite alors, il n'y a pas de danger.
      If ( x > 1 ) And ( ( wState[x - 1, y] mod 16 = 0 ) Or ( wState[x - 1, y] mod 16 = 4 ) ) Then Begin
         sumFreeCases := sumFreeCases + 1;
         If ( ( ( x > 2 ) And ( ( wState[x - 2, y] mod 16 = 0 ) Or ( wState[x - 2, y] mod 16 = 4 ) ) )
         Or ( ( y > 1 ) And ( ( wState[x - 1, y - 1] mod 16 = 0 ) Or ( wState[x - 1, y - 1] mod 16 = 4 ) ) )
         Or ( ( y < GRIDHEIGHT ) And ( ( wState[x - 1, y + 1] mod 16 = 0 ) Or ( wState[x - 1, y + 1] mod 16 = 4 ) ) ) ) Then Begin
            freeCase := true;
            sumFreeCases := sumFreeCases + 1;
         End;
      End;
      // Droite.
      If ( x < GRIDWIDTH ) And ( ( wState[x + 1, y] mod 16 = 0 ) Or ( wState[x + 1, y] mod 16 = 4 ) ) Then Begin
         sumFreeCases := sumFreeCases + 1;
         If ( ( ( x < GRIDWIDTH - 1 ) And ( ( wState[x + 2, y] mod 16 = 0 ) Or ( wState[x + 2, y] mod 16 = 4 ) ) )
         Or ( ( y > 1 ) And ( ( wState[x + 1, y - 1] mod 16 = 0 ) Or ( wState[x + 1, y - 1] mod 16 = 4 ) ) )
         Or ( ( y < GRIDHEIGHT ) And ( ( wState[x + 1, y + 1] mod 16 = 0 ) Or ( wState[x + 1, y + 1] mod 16 = 4 ) ) ) ) Then Begin
            If ( freeCase = true ) Then blocked := false Else freeCase := true;
            sumFreeCases := sumFreeCases + 1;
         End;
      End;
      // Haut
      If ( y > 1 ) And ( ( wState[x, y - 1] mod 16 = 0 ) Or ( wState[x, y - 1] mod 16 = 4 ) ) Then Begin
         sumFreeCases := sumFreeCases + 1;
         If ( ( ( y > 2 ) And ( ( wState[x, y - 2] mod 16 = 0 ) Or ( wState[x, y - 2] mod 16 = 4 ) ) )
         Or ( ( x > 1 ) And ( ( wState[x - 1, y - 1] mod 16 = 0 ) Or ( wState[x - 1, y - 1] mod 16 = 4 ) ) )
         Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, y - 1] mod 16 = 0 ) Or ( wState[x + 1, y - 1] mod 16 = 4 ) ) ) ) Then Begin
            If ( freeCase = true ) Then blocked := false Else freeCase := true;
            sumFreeCases := sumFreeCases + 1;
         End;
      End;
      // Bas
      If  ( y < GRIDHEIGHT ) And ( ( wState[x, y + 1] mod 16 = 0 ) Or ( wState[x, y + 1] mod 16 = 4 ) ) Then Begin
          sumFreeCases := sumFreeCases + 1;
          If ( ( ( y < GRIDHEIGHT - 1 ) And ( ( wState[x, y + 2] mod 16 = 0 ) Or ( wState[x, y + 2] mod 16 = 4 ) ) )
          Or ( ( x > 1 ) And ( ( wState[x - 1, y + 1] mod 16 = 0 ) Or ( wState[x - 1, y + 1] mod 16 = 4 ) ) )
          Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, y + 1] mod 16 = 0 ) Or ( wState[x + 1, y + 1] mod 16 = 4 ) ) ) ) Then Begin
             If ( freeCase = true ) Then blocked := false Else freeCase := true;
             sumFreeCases := sumFreeCases + 1;
          End;
      End;

      // Plus le nombre de cases libres est grand, plus le danger est faible. Si ce coefficient est trop faible, alors il
      // se coince car il a peur des bombermans. Si ce coefficient est trop fort, alors il ne fait plus attention aux bombes.
      If ( blocked = true ) Then
         result2 := result2 + 512 div ( 8 + sumFreeCases );
   End;



// Traitement des bombes
   // Ca sert � ne pas se coincer dans un coin juste apr�s avoir poser une bombe et en sortir si c'est possible.
    // Si le bomberman ne peut se d�placer que dans le sens dans la bombe qui est proche, alors il le fait.
    blocked := false;
    // Bombe � gauche : si pour le haut, la droite et le bas, il y a le bord, un obstacle ou qu'il y a une bombe
    // qui menace la case, et qu'il y a une bombe � gauche du bomberman, alors il est bloqu�.
    If ( ( y = 1 ) Or ( ( wState[x, y - 1] mod 16 <> 0 ) And ( wState[x, y - 1] mod 16 <> 4 ) ) Or ( ( x > 1 )                 // Obstacle ou bombe au-dessus.
    And ( wState[x - 1, y - 1] mod 4 >= 2 ) ) Or ( ( x > 2 ) And ( wState[x - 2, y - 1] mod 4 >= 2 ) ) )
    And ( ( x = GRIDWIDTH ) Or ( (  wState[x + 1, y] mod 16 <> 0 ) And ( wState[x + 1, y] mod 16 <> 4 ) ) )                    // Obstacle � droite.
    And ( ( y = GRIDHEIGHT ) Or ( ( wState[x, y + 1] mod 16 <> 0 ) And ( wState[x, y + 1] mod 16 <> 4 ) ) Or ( ( x > 1 )       // Obstacle ou bombe au-dessous.
    And ( wState[x - 1, y + 1] mod 4 >= 2 ) ) Or ( ( x > 2 ) And ( wState[x - 2, y + 1] mod 4 >= 2 ) ) )
    And ( ( ( x > 1 ) And ( wState[x - 1, y] mod 4 >= 2 ) )                                                                    // Bombe � gauche.
    Or ( ( x > 2 ) And ( wState[x - 2, y] mod 4 >= 2 ) ) ) Then
       blocked := true;
    // Bombe en haut
    If ( ( x = 1 ) Or ( ( wState[x - 1, y] mod 16 <> 0 ) And ( wState[x - 1, y] mod 16 <> 4 ) ) Or ( ( y > 1 )
    And ( wState[x - 1, y - 1] mod 4 >= 2 ) ) Or ( ( y > 2 ) And ( wState[x - 1, y - 2] mod 4 >= 2 ) ) )
    And ( ( x = GRIDWIDTH ) Or ( ( wState[x + 1, y] mod 16 <> 0 ) And ( wState[x + 1, y] mod 16 <> 4 ) ) Or ( ( y > 1 )
    And ( wState[x + 1, y - 1] mod 4 >= 2 ) ) Or ( ( y > 2 ) And ( wState[x + 1, y - 2] mod 4 >= 2 ) ) )
    And ( ( y = GRIDHEIGHT ) Or ( ( wState[x, y + 1] mod 16 <> 0 ) And ( wState[x, y + 1] mod 16 <> 4 ) ) )
    And ( ( ( y > 1 ) And ( wState[x, y - 1] mod 4 >= 2 ) )
    Or ( ( y > 2 ) And ( wState[x, y - 2] mod 4 >= 2 ) ) ) Then
       blocked := true;
    // Bombe � droite.
    If ( ( x = 1 ) Or ( ( wState[x - 1, y] mod 16 <> 0 ) And ( wState[x - 1, y] mod 16 <> 4 ) ) )
    And ( ( y = 1 ) Or ( ( wState[x, y - 1] mod 16 <> 0 ) And ( wState[x, y - 1] mod 16 <> 4 ) ) Or ( ( x < GRIDWIDTH )
    And ( wState[x + 1, y - 1] mod 4 >= 2 ) ) Or ( ( x < GRIDWIDTH - 1 ) And ( wState[x + 2, y - 1] mod 4 >= 2 ) ) )
    And ( ( y = GRIDHEIGHT ) Or ( ( wState[x, y + 1] mod 16 <> 0 ) And ( wState[x, y + 1] mod 16 <> 4 ) ) Or ( ( x < GRIDWIDTH )
    And ( wState[x + 1, y + 1] mod 4 >= 2 ) ) Or ( ( x < GRIDWIDTH - 1 ) And ( wState[x + 2, y + 1] mod 4 >= 2 ) ) )
    And ( ( ( x < GRIDWIDTH ) And ( wState[x + 1, y] mod 4 >= 2 ) )
    Or ( ( x < GRIDWIDTH - 1 ) And ( wState[x + 2, y] mod 4 >= 2 ) ) ) Then
       blocked := true;
    // Bombe en bas.
    If ( ( x = 1 ) Or ( ( wState[x - 1, y ] mod 16 <> 0 ) And ( wState[x - 1, y] mod 16 <> 4 ) ) Or ( ( y < GRIDHEIGHT )
    And ( wState[x - 1, y + 1] mod 4 >= 2 ) ) Or ( ( y < GRIDHEIGHT - 1 ) And ( wState[x - 1, y + 2] mod 4 >= 2 ) ) )
    And ( ( y = 1 ) Or ( ( wState[x, y - 1] mod 16 <> 0 ) And ( wState[x, y - 1] mod 16 <> 4 ) ) )
    And ( ( x = GRIDWIDTH ) Or ( ( wState[x + 1, y] mod 16 <> 0 ) And ( wState[x + 1, y] mod 16 <> 4 ) ) Or ( ( y < GRIDHEIGHT )
    And ( wState[x + 1, y + 2] mod 4 >= 2 ) ) Or ( ( y < GRIDHEIGHT - 1 ) And ( wState[x + 1, y + 2] mod 4 >= 2 ) ) )
    And ( ( ( y < GRIDHEIGHT ) And ( wState[x, y + 1] mod 4 >= 2 ) )
    Or ( ( y < GRIDHEIGHT - 1 ) And ( wState[x, y + 2] mod 4 >= 2 ) ) ) Then
       blocked := true;

    // Si le bomberman est bloqu�, alors il est en danger. 1024 est-il trop fort?
    If ( blocked = true ) Then
      result2 := result2 + 1024;
   


// Traitement des bombes pour �viter d'�tre coinc�.
    // Ca sert � ne pas se coincer dans un axe juste apr�s avoir poser une bombe et en sortir si c'est possible.
    If ( wSkill <> SKILL_NOVICE ) Then Begin
        blocked := false;
        numFreeCase := 4096;
        // Bombe � gauche
        If ( x > 1 ) And ( wState[x - 1, y] mod 4 >= 2 ) Then Begin        // S'il y a une bombe � gauche
            continue := true;
            i := x + 1;
            While ( continue = true ) And ( i <= GRIDWIDTH ) Do Begin
                  If ( wState[i, y] mod 16 <> 0 ) And ( wState[i, y] mod 16 <> 4 ) Then Begin // Si la case � droite est bloqu�, c'est fini.
                     blocked := true;
                     numFreeCase := i - x;
                     continue := false;
                  End
                  Else If ( ( y > 1 ) And ( ( wState[i, y - 1] mod 16 = 0 ) Or ( wState[i, y - 1] mod 16 = 4 ) ) )   // S'il y a une case libre
                  Or ( ( y < GRIDHEIGHT ) And ( ( wState[i, y + 1] mod 16 = 0 ) Or ( wState[i, y + 1] mod 16 = 4 ) ) ) Then Begin
                     continue := false;
                  End;
                  i := i + 1;
            End;
            If ( continue = true ) Then Begin
               blocked := true;
               numFreeCase := i - x;
            End;
        End;
        // Bombe � droite
        If ( x < GRIDWIDTH ) And ( wState[x + 1, y] mod 4 >= 2 ) Then Begin
            continue := true;
            i := x - 1;
            While ( continue = true ) And ( i >= 1 ) Do Begin
                  If ( wState[i, y] mod 16 <> 0 ) And ( wState[i, y] mod 16 <> 4 ) Then Begin
                     If ( numFreeCase < x - i ) Then numFreeCase := x - i;
                     blocked := true;
                     continue := false;
                  End
                  Else If ( ( y > 1 ) And ( ( wState[i, y - 1] mod 16 = 0 ) Or ( wState[i, y - 1] mod 16 = 4 ) ) )
                  Or ( ( y < GRIDHEIGHT ) And ( ( wState[i, y + 1] mod 16 = 0 ) Or ( wState[i, y + 1] mod 16 = 4 ) ) ) Then Begin
                     continue := false;
                  End;
                  i := i - 1;
            End;
            If ( continue = true ) Then Begin
               If ( numFreeCase > x - i ) Then numFreeCase := x - i;
               blocked := true;
            End;
        End;
        // Bombe en haut
        If ( y > 1 ) And ( wState[x, y - 1] mod 4 >= 2 ) Then Begin
            continue := true;
            j := y + 1;
            While ( continue = true ) And ( j <= GRIDHEIGHT ) Do Begin
                  If ( wState[x, j] mod 16 <> 0 ) And ( wState[x, j] mod 16 <> 4 ) Then Begin
                     If ( numFreeCase < j - y ) Then numFreeCase := j - y;
                     blocked := true;
                     continue := false;
                  End
                  Else If ( ( x > 1 ) And ( ( wState[x - 1, j] mod 16 = 0 ) Or ( wState[x - 1, j] mod 16 = 4 ) ) )
                  Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, j] mod 16 = 0 ) Or ( wState[x + 1, j] mod 16 = 4 ) ) ) Then Begin
                     continue := false;
                  End;
                  j := j + 1;
            End;
            If ( continue = true ) Then Begin
               If ( numFreeCase > j - y ) Then numFreeCase := j - y;
               blocked := true;
            End;
        End;
        // Bombe en bas
        If ( y < GRIDHEIGHT ) And ( wState[x, y + 1] mod 4 >= 2 ) Then Begin
            continue := true;
            j := y - 1;
            While ( continue = true ) And ( j >= 1 ) Do Begin
                  If ( wState[x, j] mod 16 <> 0 ) And ( wState[x, j] mod 16 <> 4 ) Then Begin
                     If ( numFreeCase < y - j ) Then numFreeCase := y - j;
                     blocked := true;
                     continue := false;
                  End
                  Else If ( ( x > 1 ) And ( ( wState[x - 1, j] mod 16 = 0 ) Or ( wState[x - 1, j] mod 16 = 4 ) ) )
                  Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, j] mod 16 = 0 ) Or ( wState[x + 1, j] mod 16 = 4 ) ) ) Then Begin
                     continue := false;
                  End;
                  j := j - 1;
            End;
            If ( continue = true ) Then Begin
               If ( numFreeCase > y - j ) Then numFreeCase := y - j;
               blocked := true;
            End;
        End;
        
        // Si le bomberman est bloqu�, alors il est en danger.
        If ( blocked = true ) And ( numFreeCase >= 2 )Then
           result2 := result2 + 2048 div numFreeCase;
    End;

   
// Niveaux masterful et godlike
   // Traitement des cases sans planques pour les niveaux masterful et godlike
   // Ca sert � ne pas aller dans une impasse quand on est suivi.
   If ( wSkill = SKILL_MASTERFUL ) Or ( wSkill = SKILL_GODLIKE ) Then Begin
      // S'il n'y a pas de bomberman � moins de 7 cases, alors il n'y a pas de danger.
      blocked := false;
      numFreeCase := 0;
      If ( x < 7 ) Then xMin := 1 Else xMin := x - 6;
      If ( x > GRIDWIDTH - 6 ) Then xMax := GRIDWIDTH Else xMax := x + 6;
      If ( y < 7 ) Then yMin := 1 Else yMin := y - 6;
      If ( x > GRIDHEIGHT - 6 ) Then yMax := GRIDHEIGHT Else yMax := y + 6;

      For i := xMin To xMax Do Begin
          For j := yMin To yMax Do Begin
              If ( wState[i, j] mod 8 >= 4 ) And ( abs(x - i) + abs(y - j) <= 7 ) Then
                 blocked := true;
          End;
      End;
      
      // S'il y a une case de sortie ou un bomberman sur une autre ligne � gauche, alors gauche est une sortie.
      continue := true;
      i := x - 1;
      While ( continue = true ) And ( i >= 1 ) Do Begin
            If ( wState[i, y] mod 16 <> 0 ) And ( wState[i, y] mod 16 <> 4 ) Then
               continue := false
            Else If ( ( y > 1 ) And ( ( wState[i, y - 1] mod 16 = 0 ) Or ( wState[i, y - 1] mod 16 = 4 ) ) )
            Or ( ( y < GRIDHEIGHT ) And ( ( wState[i, y + 1] mod 16 = 0 ) Or ( wState[i, y + 1] mod 16 = 4 ) ) ) Then Begin
               numFreeCase := 1;
               iExit := i;
               continue := false;
            End;
            i := i - 1;
      End;
      // Sortie � droite.
      continue := true;
      i := x + 1;
      While ( continue = true ) And ( i <= GRIDWIDTH ) Do Begin
            If ( wState[i, y] mod 16 <> 0 ) And ( wState[i, y] mod 16 <> 4 )Then
               continue := false
            Else If ( ( y > 1 ) And ( ( wState[i, y - 1] mod 16 = 0 ) Or ( wState[i, y - 1] mod 16 = 4 ) ) )
            Or ( ( y < GRIDHEIGHT ) And ( ( wState[i, y + 1] mod 16 = 0 ) Or ( wState[i, y + 1] mod 16 = 4 ) ) ) Then Begin
               If ( numFreeCase <> 0 ) Then blocked := false
               Else Begin
                    numFreeCase := 2;
                    iExit := i;
               End;
               continue := false;
            End;
            i := i + 1;
      End;
      // Sortie en haut.
      continue := true;
      j := y - 1;
      While ( continue = true ) And ( j >= 1 ) Do Begin
            If ( wState[x, j] mod 16 <> 0 ) And ( wState[x, j] mod 16 <> 4 )Then
               continue := false
            Else If ( ( x > 1 ) And ( ( wState[x - 1, j] mod 16 = 0 ) Or ( wState[x - 1, j] mod 16 = 4 ) ) )
            Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, j] mod 16 = 0 ) Or ( wState[x + 1, j] mod 16 = 4 ) ) ) Then Begin
               If ( numFreeCase <> 0 ) Then blocked := false
               Else Begin
                    numFreeCase := 3;
                    iExit := j;
               End;
               continue := false;
            End;
            j := j - 1;
      End;
      // Sortie en bas.
      continue := true;
      j := y + 1;
      While ( continue = true ) And ( j <= GRIDHEIGHT ) Do Begin
            If ( wState[x, j] mod 16 <> 0 ) And ( wState[x, j] mod 16 <> 4 ) Then
               continue := false
            Else If ( ( x > 1 ) And ( ( wState[x - 1, j] mod 16 = 0 ) Or ( wState[x - 1, j] mod 16 = 4 ) ) )
            Or ( ( x < GRIDWIDTH ) And ( ( wState[x + 1, j] mod 16 = 0 ) Or ( wState[x + 1, j] mod 16 = 4 ) ) ) Then Begin
               If ( numFreeCase <> 0 ) Then blocked := false
               Else Begin
                    numFreeCase := 4;
                    iExit := j;
               End;
               continue := false;
            End;
            j := j + 1;
      End;

      // Si la case est bloqu�e, alors le danger est proportionnelle � la distance de la case de sortie.
      If ( blocked = true ) Then Begin
         If ( numFreeCase = 1 ) Or ( numFreeCase = 2 ) Then
            result2 := result2 + 16 * ( 8 + abs(iExit - x) );
         If ( numFreeCase = 3 ) Or ( numFreeCase = 3 ) Then
            result2 := result2 + 16 * ( 8 + abs(iExit - y) ) ;
      End;
   End;
            

              
// Traitement des bombes qui sont sur la m�me rang�e. Notion d'espoir.
   // Ca sert � sortir de l'impasse s'il y a sortie et qu'il y a de l'espoir.
   // Si une bombe est � plus de 3 cases de la sortie ou que la sortie est � moins de 6 cases du bomberman, alors il va vers la sortie.
   // Si une bombe est sur la ligne/colonne d'� c�t�, on consid�re qu'il n'y a pas de sortie de ce c�t�.
   If ( wSkill = SKILL_MASTERFUL ) Or ( wSkill = SKILL_GODLIKE ) Then Begin
      // Gauche : on ne continue que s'il y a une bombe � gauche et qu'il n'y a pas de sortie � droite.
      continue := false;
      bEnd := False;
      upBomb := false;
      downBomb := false;
      i := x - 1;
      While ( i >= 1 ) And ( Not bEnd ) Do Begin
          If ( wState[i, y] mod 4 >= 2 ) Then Begin
             continue := true;
             iBomb := i;
          End;
          If ( wState[i, y] mod 16 >= 8 ) Then Begin
             bEnd := true;
          End;
          // S'il y a une bombe � la ligne du dessous et qu'il n'y a pas de bloc entre, alors il n'y a pas de sortie en dessous.
          If ( y > 1 ) And ( wState[i, y - 1] mod 4 >= 2 ) And ( upBomb = false ) Then Begin
             upBomb := true;
             j := i + 1;
             While ( upBomb = true ) And ( j < x ) Do Begin
                   If ( wState[j, y - 1] >= 8 ) Then
                      upBomb := false;
                   j := j + 1;
             End;
          End;
          If ( y < GRIDHEIGHT ) And ( wState[i, y + 1] mod 4 >= 2 ) And ( downBomb = false ) Then Begin
             downBomb := true;
             j := i + 1;
             While ( downBomb = true ) And ( j < x ) Do Begin
                   If ( wState[j, y + 1] >= 8 ) Then
                      downBomb := false;
                   j := j + 1;
             End;
          End;
          i := i - 1;
      End;
      // Si le bomberman peut sortir par la droite, c'est bien.
      For i := x To GRIDWIDTH Do
          If ( ( y > 1 ) And ( upBomb = false ) And ( ( wState[i, y - 1] mod 16 = 0 ) Or ( wState[i, y - 1] mod 16 = 4 ) ) )
          Or ( ( y < GRIDHEIGHT ) And ( downBomb = false ) And ( ( wState[i, y + 1] mod 16 = 0 ) Or ( wState[i, y + 1] mod 16 = 4 ) ) ) Then
             continue := false;
      // S'il y a une sortie � gauche et que la sortie est � plus de 3 cases de la bombe ou � moins de 6 cases du bomberman,
      // alors le danger est proportionnel � la distance de la sortie.
      If ( continue = true ) Then
         For i := iBomb + 1 To x - 1 Do
             If ( ( ( y > 1 ) And ( upBomb = false ) And ( ( wState[i, y - 1] mod 16 = 0 ) Or ( wState[i, y - 1] mod 16 = 4 ) ) )
             Or ( ( y < GRIDHEIGHT ) And ( downBomb = false ) And ( ( wState[i, y + 1] mod 16 = 0 ) Or ( wState[i, y + 1] mod 16 = 4 ) ) ) )
             And ( ( i - iBomb >= 3 ) Or ( x - i <= 5 ) ) Then
                 result2 := result2 + 512 * abs( x - i );
      // Droite
      continue := false;
      bEnd := false;
      upBomb := false;
      downBomb := false;
      i := x + 1;
      While ( i <= GRIDWIDTH ) And ( Not bEnd ) Do Begin
          If ( wState[i, y] mod 4 >= 2 ) Then Begin
             continue := true;
             iBomb := i;
          End;
          If ( wState[i, y] mod 16 >= 8 ) Then Begin
             bEnd := true;
          End;
          If ( y > 1 ) And ( wState[i, y - 1] mod 4 >= 2 ) And ( upBomb = false ) Then Begin
             upBomb := true;
             j := i - 1;
             While ( upBomb = true ) And ( j > x ) Do Begin
                   If ( wState[j, y - 1] >= 8 ) Then
                      upBomb := false;
                   j := j - 1;
             End;
          End;
          If ( y < GRIDHEIGHT ) And ( wState[i, y + 1] mod 4 >= 2 ) And ( downBomb = false ) Then Begin
             downBomb := true;
             j := i - 1;
             While ( downBomb = true ) And ( j > x ) Do Begin
                   If ( wState[j, y + 1] >= 8 ) Then
                      downBomb := false;
                   j := j - 1;
             End;
          End;
          i += 1;
      End;
      For i := 1 To x Do
          If ( ( y > 1 ) And ( upBomb = false ) And ( ( wState[i, y - 1] mod 16 = 0 ) Or ( wState[i, y - 1] mod 16 = 4 ) ) )
          Or ( ( y < GRIDHEIGHT ) And ( downBomb = false ) And ( ( wState[i, y + 1] mod 16 = 0 ) Or ( wState[i, y + 1] mod 16 = 4 ) ) ) Then
             continue := false;
      If ( continue = true ) Then
         For i := x + 1 To iBomb - 1 Do
             If ( ( ( y > 1 ) And ( upBomb = false ) And ( ( wState[i, y - 1] mod 16 = 0 ) Or ( wState[i, y - 1] mod 16 = 4 ) ) )
             Or ( ( y < GRIDHEIGHT ) And ( downBomb = false ) And ( ( wState[i, y + 1] mod 16 = 0 ) Or ( wState[i, y + 1] mod 16 = 4 ) ) ) )
             And ( ( iBomb - i >= 3 ) Or ( i - x <= 5 ) ) Then
                 result2 := result2 + 512 * abs( x - i );
      // Haut
      continue := false;
      bEnd := false;
      upBomb := false;       // upBomb = leftBomb
      downBomb := false;     // downBomb = rightBomb
      j := y - 1;
      While ( j >= 1 ) And ( Not bEnd ) Do Begin
          If ( wState[x, j] mod 4 >= 2 ) Then Begin
             continue := true;
             iBomb := j;
          End;
          If ( wState[x, j] mod 16 >= 8 ) Then Begin
             bEnd := true;
          End;
          If ( x > 1 ) And ( wState[x - 1, j] mod 4 >= 2 ) And ( upBomb = false ) Then Begin
             upBomb := true;
             i := j + 1;
             While ( upBomb = true ) And ( i < y ) Do Begin
                   If ( wState[x - 1, i] >= 8 ) Then
                      upBomb := false;
                   i := i + 1;
             End;
          End;
          If ( x < GRIDWIDTH ) And ( wState[x + 1, j] mod 4 >= 2 ) And ( downBomb = true ) Then Begin
             downBomb := true;
             i := j + 1;
             While ( downBomb = true ) And ( i < y ) Do Begin
                   If ( wState[x + 1, i] >= 8 ) Then
                      downBomb := false;
                   i := i + 1;
             End;
          End;
          j -= 1;
      End;
      For j := y To GRIDHEIGHT Do
          If ( ( x > 1 ) And ( upBomb = false ) And ( ( wState[x - 1, j] mod 16 = 0 ) Or ( wState[x - 1, j] mod 16 = 4 ) ) )
          Or ( ( x < GRIDWIDTH ) And ( downBomb = false ) And ( ( wState[x + 1, j] mod 16 = 0 ) Or ( wState[x + 1, j] mod 16 = 4 ) ) ) Then
             continue := false;
      If ( continue = true ) Then
         For j := iBomb + 1 To y - 1 Do
             If ( ( ( x > 1 ) And ( upBomb = false ) And ( ( wState[x - 1, j] mod 16 = 0 ) Or ( wState[x - 1, j] mod 16 = 4 ) ) )
             Or ( ( x < GRIDWIDTH ) And ( downBomb = false ) And ( ( wState[x + 1, j] mod 16 = 0 ) Or ( wState[x + 1, j] mod 16 = 4 ) ) ) )
             And ( ( j - iBomb >= 3 ) Or ( y - j <= 5 ) ) Then
                 result2 := result2 + 512 * abs( y - i );
      // Bas
      continue := false;
      bEnd := false;
      upBomb := false;
      downBomb := false;
      j := y + 1;
      While ( j <= GRIDHEIGHT ) And ( Not bEnd ) Do Begin
          If ( wState[x, j] mod 4 >= 2 ) Then Begin
             continue := true;
             iBomb := j;
          End;
          If ( wState[x, j] mod 16 >= 8 ) Then Begin
             bEnd := True;
          End;
          If ( x > 1 ) And ( wState[x - 1, j] mod 4 >= 2 ) And ( upBomb = false ) Then Begin
             upBomb := true;
             i := j - 1;
             While ( upBomb = true ) And ( i > y ) Do Begin
                   If ( wState[x - 1, i] >= 8 ) Then
                      upBomb := false;
                   i := i - 1;
             End;
          End;
          If ( x < GRIDWIDTH ) And ( wState[x + 1, j] mod 4 >= 2 ) And ( downBomb = false ) Then Begin
             downBomb := true;
             i := j - 1;
             While ( downBomb = true ) And ( i > y ) Do Begin
                   If ( wState[x + 1, i] >= 8 ) Then
                      downBomb := false;
                   i := i - 1;
             End;
          End;
          j += 1;
      End;
      For j := 1 To y Do
          If ( ( x > 1 ) And ( upBomb = false ) And ( ( wState[x - 1, j] mod 16 = 0 ) Or ( wState[x - 1, j] mod 16 = 4 ) ) )
          Or ( ( x < GRIDWIDTH ) And ( downBomb = false ) And ( ( wState[x + 1, j] mod 16 = 0 ) Or ( wState[x + 1, j] mod 16 = 4 ) ) ) Then
             continue := false;
      If ( continue = true ) Then
         For j := y + 1 To iBomb - 1 Do
             If ( ( ( x > 1 ) And ( upBomb = false ) And ( ( wState[x - 1, j] mod 16 = 0 ) Or ( wState[x - 1, j ] mod 16 = 4 ) ) )
             Or ( ( x < GRIDWIDTH ) And ( downBomb = false ) And ( ( wState[x + 1, j] mod 16 = 0 ) Or ( wState[x + 1, j] mod 16 = 4 ) ) ) )
             And ( ( iBomb - j >= 3 ) Or ( j - y <= 5 ) ) Then
                 result2 := result2 + 512 * abs( y - i );
   End;



   CalculateDanger := result2;
End;




Function PutBomb( x, y : Integer; pState : Table; wSkill : Integer; m_bMustPut : Boolean ) : Boolean ;
Var
   CanPut, continue : Boolean;
   FreeDirections : Integer;                // Nombres de directions sans danger.
   i, j, k, cLeft, cRight, cUp, cDown : Integer;
   aTableIndex : ArrayIndex;
   pPlayer : CBomberman;
   bIsPlayer : Boolean;
Begin
// Initialisation des variables
   CanPut := false;
   If ( x - 4 ) < 1 Then cLeft := 1 Else cLeft := x - 4;
   If ( x + 4 ) > GRIDWIDTH Then cRight := GRIDWIDTH Else cRight := x + 4;
   If ( y - 4 ) < 1 Then cUp := 1 Else cUp := y - 4;
   If ( y + 4 ) > GRIDHEIGHT Then cDown := GRIDHEIGHT Else cDown := y + 4;

         
// Si un bomberman est proche, alors on peut poser une bombe.
   For i := cLeft To cRight Do Begin
       If ( pState[ i, y ] mod 8 >= 4 ) Then Begin
          CanPut := true;
          If bSolo = True Then Begin
             aTableIndex := GetBombermanIndexByCoo( i, y );
             bIsPlayer := False;
             For k := 1 To aTableIndex.Count Do Begin
                 If aTableIndex.Tab[k] = 1 Then
                    bIsPlayer := True;
             End;
             pPlayer := GetBombermanByIndex( 1 );
             // Si ce n'est pas le joueur humain, on ne l'attaque pas en solo
             If ( pPlayer <> Nil ) And ( pPlayer.Alive = True ) And ( bIsPlayer = False ) Then
                 CanPut := False;
          End;
       End
   End;;
   For i := cUp To cDown Do
       If ( pState[ x, i ] mod 8 >= 4 ) Then Begin
          CanPut := true;
          If bSolo = True Then Begin
             aTableIndex := GetBombermanIndexByCoo( i, y );
             bIsPlayer := False;
             For k := 1 To aTableIndex.Count Do Begin
                 If aTableIndex.Tab[k] = 1 Then
                    bIsPlayer := True;
             End;
             pPlayer := GetBombermanByIndex( 1 );
             // Si ce n'est pas le joueur humain, on ne l'attaque pas en solo
             If ( pPlayer <> Nil ) And ( pPlayer.Alive = True ) And ( bIsPlayer = False ) Then
                 CanPut := False;
          End;
       End;
   If ( m_bMustPut = true ) Then
      CanPut := true;


// Si le niveau est au moins average et que le bomberman se coince avec sa bombe, alors il ne la pose pas.
    // On initialise le nombre de directions libres � 0.
    FreeDirections := 0;
    
    // Pour la case de gauche, s'il y a deux cases libres de suite alors, il n'y a pas de danger.
    If ( x > 1 ) And ( pState[x - 1, y] mod 16 mod 16 = 0 )
    And ( ( ( x > 2 ) And ( pState[x - 2, y] mod 16 = 0 ) )
    Or ( ( y > 1 ) And ( pState[x - 1, y - 1] mod 16 = 0 ) )
    Or ( ( y < GRIDHEIGHT ) And ( pState[x - 1, y + 1] mod 16 = 0 ) ) ) Then
       FreeDirections := FreeDirections + 1;
    // Droite.
    If ( x < GRIDWIDTH ) And ( pState[x + 1, y] mod 16 = 0 )
    And ( ( ( x < GRIDWIDTH - 1 ) And ( pState[x + 2, y] mod 16 = 0 ) )
    Or ( ( y > 1 ) And ( pState[x + 1, y - 1] mod 16 = 0 ) )
    Or ( ( y < GRIDHEIGHT ) And ( pState[x + 1, y + 1] mod 16 = 0 ) ) ) Then
       FreeDirections := FreeDirections + 1;
    // Haut
    If ( y > 1 ) And ( pState[x, y - 1] mod 16 = 0 )
    And ( ( ( y > 2 ) And ( pState[x, y - 2] mod 16 = 0 ) )
    Or ( ( x > 1 ) And ( pState[x - 1, y - 1] mod 16 = 0 ) )
    Or ( ( x < GRIDWIDTH ) And ( pState[x + 1, y - 1] mod 16 = 0 ) ) ) Then
       FreeDirections := FreeDirections + 1;
    // Bas
    If  ( y < GRIDHEIGHT ) And ( pState[x, y + 1] mod 16 = 0 )
    And ( ( ( y < GRIDHEIGHT - 1 ) And  ( pState[x, y + 2] mod 16 = 0 ) )
    Or ( ( x > 1 ) And ( pState[x - 1, y + 1] mod 16 = 0 ) )
    Or ( ( x < GRIDWIDTH ) And ( pState[x + 1, y + 1] mod 16 = 0 ) ) ) Then
       FreeDirections := FreeDirections + 1;
    
    // S'il n'y pas plus de deux directions libres, alors on ne pose pas la bombe.
    If ( FreeDirections < 1 ) Then
       CanPut := false;

   
// Si le bomberman est dans une impasse, et que le niveau est au moins average alors il ne pose pas de bombe.
   If ( wSkill <> SKILL_NOVICE )  Then Begin
      FreeDirections := 0;

      // S'il y a une case de sortie ou un bomberman sur une autre ligne � gauche, alors gauche est une sortie.
      continue := true;
      i := x - 1;
      While ( continue = true ) And ( i >= 1 ) Do Begin
            If ( pState[i, y] mod 16 <> 0 ) Then
               continue := false
            Else If ( ( y > 1 ) And ( pState[i, y - 1] mod 16 = 0 ) )
            Or ( ( y < GRIDHEIGHT ) And ( pState[i, y + 1] mod 16 = 0 ) ) Then Begin
               FreeDirections := FreeDirections + 1;
               continue := false;
            End;
            i := i - 1;
      End;
      // Sortie � droite.
      continue := true;
      i := x + 1;
      While ( continue = true ) And ( i <= GRIDWIDTH ) Do Begin
            If ( pState[i, y] mod 16 <> 0 ) Then
               continue := false
            Else If ( ( y > 1 ) And ( pState[i, y - 1] mod 16 = 0 ) )
            Or ( ( y < GRIDHEIGHT ) And ( pState[i, y + 1] mod 16 = 0 ) ) Then Begin
               FreeDirections := FreeDirections + 1;
               continue := false;
            End;
            i := i + 1;
      End;
      // Sortie en haut.
      continue := true;
      j := y - 1;
      While ( continue = true ) And ( j >= 1 ) Do Begin
            If ( pState[x, j] mod 16 <> 0 ) Then
               continue := false
            Else If ( ( x > 1 ) And ( pState[x - 1, j] mod 16 = 0 ) )
            Or ( ( x < GRIDWIDTH ) And ( pState[x + 1, j] mod 16 = 0 ) ) Then Begin
               FreeDirections := FreeDirections + 1;
               continue := false;
            End;
            j := j - 1;
      End;
      // Sortie en bas.
      continue := true;
      j := y + 1;
      While ( continue = true ) And ( j <= GRIDHEIGHT ) Do Begin
            If ( pState[x, j] mod 16 <> 0 ) Then
               continue := false
            Else If ( ( x > 1 ) And ( pState[x - 1, j] mod 16 = 0 ) )
            Or ( ( x < GRIDWIDTH ) And ( pState[x + 1, j] mod 16 = 0 ) ) Then Begin
               FreeDirections := FreeDirections + 1;
               continue := false;
            End;
            j := j + 1;
      End;
      
   // S'il n'y pas de directions libres, alors on ne pose pas la bombe.
      If ( FreeDirections < 1 ) Then
         CanPut := false;
   End;
   
      

// On renvoye la variable.
   PutBomb := CanPut;
End;




// Renvoie true si le bomberman peut spooger.
Function CanSpoog( nX, nY : Integer; wState : Table; wSkill, wDirection : Integer ) : Boolean;
Var CanDo : Boolean;
    i : Integer;
Begin
     CanDo := True;
     // Bas
     If ( wDirection = 0 ) Then Begin
        If ( wState[ nX, nY + 1 ] mod 16 <> 0 ) And ( wState[ nX, nY + 1 ] mod 16 <> 4 ) Then Begin
           CanDo := False;
        End
        Else If ( wState[ nX, nY + 2 ] mod 16 <> 0 ) And ( wState[ nX, nY + 2 ] mod 16 <> 4 )
        And ( wState[ nX - 1, nY + 1 ] mod 16 <> 0 ) And ( wState[ nX - 1, nY + 1 ] mod 16 <> 4 )
        And ( wState[ nX + 1, nY + 1 ] mod 16 <> 0 ) And ( wState[ nX + 1, nY + 1 ] mod 16 <> 4 ) Then Begin
            CanDo := False;
        End;
     End;
     // Haut
     If ( wDirection = 180 ) Then Begin
        If ( wState[ nX, nY - 1 ] mod 16 <> 0 ) And ( wState[ nX, nY - 1 ] mod 16 <> 4 ) Then Begin
           CanDo := False;
        End
        Else If ( wState[ nX, nY - 2 ] mod 16 <> 0 ) And ( wState[ nX, nY - 2 ] mod 16 <> 4 )
        And ( wState[ nX - 1, nY - 1 ] mod 16 <> 0 ) And ( wState[ nX - 1, nY - 1 ] mod 16 <> 4 )
        And ( wState[ nX + 1, nY - 1 ] mod 16 <> 0 ) And ( wState[ nX + 1, nY - 1 ] mod 16 <> 4 ) Then Begin
            CanDo := False;
        End;
     End;
     // Droite
     If ( wDirection = -90 ) Then Begin
        If ( wState[ nX + 1, nY ] mod 16 <> 0 ) And ( wState[ nX + 1, nY ] mod 16 <> 4 ) Then Begin
           CanDo := False;
        End
        Else If ( wState[ nX + 2, nY ] mod 16 <> 0 ) And ( wState[ nX + 2, nY ] mod 16 <> 4 )
        And ( wState[ nX + 1, nY - 1 ] mod 16 <> 0 ) And ( wState[ nX + 1, nY - 1 ] mod 16 <> 4 )
        And ( wState[ nX + 1, nY + 1 ] mod 16 <> 0 ) And ( wState[ nX + 1, nY + 1 ] mod 16 <> 4 ) Then Begin
            CanDo := False;
        End;
     End;
     // Gauche
     If ( wDirection = 90 ) Then Begin
        If ( wState[ nX - 1, nY ] mod 16 <> 0 ) And ( wState[ nX - 1, nY ] mod 16 <> 4 ) Then Begin
           CanDo := False;
        End
        Else If ( wState[ nX - 2, nY ] mod 16 <> 0 ) And ( wState[ nX - 2, nY ] mod 16 <> 4 )
        And ( wState[ nX - 1, nY - 1 ] mod 16 <> 0 ) And ( wState[ nX - 1, nY - 1 ] mod 16 <> 4 )
        And ( wState[ nX - 1, nY + 1 ] mod 16 <> 0 ) And ( wState[ nX - 1, nY + 1 ] mod 16 <> 4 ) Then Begin
            CanDo := False;
        End;
     End;

     CanSpoog := CanDo;
End;





// Renvoie true s'il existe un chemin de A � B inf�rieur ou �gal � n cases.
Function SmallWay( aX, aY, bX, bY, n : Integer; m_aState : Table ) : Boolean;
Var
   m_bWay         : Boolean;
   m_nNbCases     : Integer;
   i, j           : Integer;
   m_nCount       : Integer;
   m_aDirCases    : Table;                       // Contient la prochaine direction de la case.
   m_aDirPrefered : Array[ 1..4 ] Of Integer;    // Contient les �quivalences (1:gauche, 2:droite, 3:haut, 4:bas).
Begin
     m_bWay := false;
     If ( abs( aX - bX ) + abs( aY - bY ) <= n ) Then Begin
     
        // Initialisation des donn�es.
        If ( abs( aX - bX ) > abs( aY - bY ) ) Then Begin
           If ( bX < aX ) Then Begin
              m_aDirPrefered[ 1 ] := 1;
              m_aDirPrefered[ 4 ] := 2;
           End
           Else Begin
              m_aDirPrefered[ 1 ] := 2;
              m_aDirPrefered[ 4 ] := 1;
           End;
           If ( bY < aY ) Then Begin
              m_aDirPrefered[ 2 ] := 3;
              m_aDirPrefered[ 3 ] := 4;
           End
           Else Begin
                m_aDirPrefered[ 2 ] := 4;
                m_aDirPrefered[ 3 ] := 3;
           End;
        End
        Else If ( abs( aX - bX ) < abs( aY - bY ) ) Then Begin
             If ( bY < aY ) Then Begin
                m_aDirPrefered[ 1 ] := 3;
                m_aDirPrefered[ 4 ] := 4;
             End
             Else Begin
                  m_aDirPrefered[ 1 ] := 4;
                  m_aDirPrefered[ 4 ] := 3;
             End;
             If ( bX < aX ) Then Begin
                m_aDirPrefered[ 2 ] := 1;
                m_aDirPrefered[ 3 ] := 2;
             End
             Else Begin
                  m_aDirPrefered[ 2 ] := 2;
                  m_aDirPrefered[ 3 ] := 1;
             End;
        End
        Else Begin
           If ( abs( aX - bX ) = 0 ) Then
              m_bWay := true
           Else Begin
                If ( bX < aX ) Then Begin
                   m_aDirPrefered[ 1 ] := 1;
                   m_aDirPrefered[ 4 ] := 2;
                End
                Else Begin
                     m_aDirPrefered[ 1 ] := 2;
                     m_aDirPrefered[ 4 ] := 1;
                End;
                If ( bY < aY ) Then Begin
                   m_aDirPrefered[ 2 ] := 3;
                   m_aDirPrefered[ 3 ] := 4;
                End
                Else Begin
                     m_aDirPrefered[ 2 ] := 4;
                     m_aDirPrefered[ 3 ] := 3;
                End;
           End;
        End;
        For i := 1 To GRIDWIDTH Do Begin
            For j := 1 To GRIDHEIGHT Do Begin
                If ( abs( bX - i ) + abs( bY - j ) <= n ) Then
                   m_aDirCases[ i, j ] := 1
                Else
                    m_aDirCases[ i, j ] := 0;
            End;
        End;
        i := aX;
        j := aY;
        m_nNbCases := 0;
        m_nCount := 0;

        // Recherche d'un chemin.
        While ( m_bWay = false ) And ( m_aDirCases[ i, j ] < 5 ) And ( m_nCount < 5 * n * n ) Do Begin
              Case m_aDirPrefered[ m_aDirCases[ i, j ] ] Of
                   1 : Begin
                            // On essaie une direction donc on incr�mente pour ne pas le refaire.
                            m_aDirCases[ i, j ] += 1;
                            // S'il le bomberman peut aller sur la case et que la case est utilisable.
                            If ( m_aState[ i - 1, j ] mod 16 < 8 ) And ( m_aState[ i - 1, j ] mod 4 = 0 )
                            And ( m_aDirCases[ i - 1, j ] in [ 1..4 ] ) Then Begin
                               // Si on passe sur pour un n-i�me fois, avec n impair...
                               If ( m_aDirCases[ i - 1, j ] = 1 ) Or ( m_aDirCases[ i - 1, j ] = 3 ) Then Begin
                                  // ...et que le case est suffisament proche, alors on incr�mente le nombre de cases pass�es.
                                  If ( abs( i - 1 - bX ) + abs( j - bY ) <= n - ( m_nNbCases + 1 ) ) Then Begin
                                     m_nNbCases += 1;
                                     i := i - 1;
                                  End;
                               End
                               // Si n est pair, on d�cremente le nombre de cases pass�es.
                               Else Begin
                                   m_nNbCases -= 1;
                                   i := i - 1;
                               End;
                            End;
                       End;
                   2 : Begin
                            m_aDirCases[ i, j ] += 1;
                            If ( m_aState[ i + 1, j ] mod 16 < 8 ) And ( m_aState[ i + 1, j ] mod 4 = 0 )
                            And ( m_aDirCases[ i + 1, j ] in [ 1..4 ] ) Then Begin
                               If ( m_aDirCases[ i + 1, j ] = 1 ) Or ( m_aDirCases[ i + 1, j ] = 3 ) Then Begin
                                  If ( abs( i + 1 - bX ) + abs( j - bY ) <= n - ( m_nNbCases + 1 ) ) Then Begin
                                     m_nNbCases += 1;
                                     i := i + 1;
                                  End;
                               End
                               Else Begin
                                   m_nNbCases -= 1;
                                   i := i + 1;
                               End;
                            End;
                       End;
                   3 : Begin
                            m_aDirCases[ i, j ] += 1;
                            If ( m_aState[ i, j - 1 ] mod 16 < 8 ) And ( m_aState[ i, j - 1 ] mod 4 = 0 )
                            And ( m_aDirCases[ i, j - 1 ] in [ 1..4 ] ) Then Begin
                               If ( m_aDirCases[ i, j - 1 ] = 1 ) Or ( m_aDirCases[ i, j - 1 ] = 3 ) Then Begin
                                  If ( abs( i - bX ) + abs( j - 1 - bY ) <= n - ( m_nNbCases + 1 ) ) Then Begin
                                     m_nNbCases += 1;
                                     j := j - 1;
                                  End;
                               End
                               Else Begin
                                   m_nNbCases -= 1;
                                   j := j - 1;
                               End;
                            End;
                       End;
                   4 : Begin
                            m_aDirCases[ i, j ] += 1;
                            If ( m_aState[ i, j + 1 ] mod 16 < 8 ) And ( m_aState[ i, j + 1 ] mod 4 = 0 )
                            And ( m_aDirCases[ i, j + 1 ] in [ 1..4 ] ) Then Begin
                               If ( m_aDirCases[ i, j + 1 ] = 1 ) Or ( m_aDirCases[ i, j + 1 ] = 3 ) Then Begin
                                  If ( abs( i - bX ) + abs( j + 1 - bY ) <= n - ( m_nNbCases + 1 ) ) Then Begin
                                     m_nNbCases += 1;
                                     j := j + 1;
                                  End;
                               End
                               Else Begin
                                   m_nNbCases -= 1;
                                   j := j + 1;
                               End;
                            End;
                       End;
              End;
              // Si on a atteint les coordon�es, on est content.
              If ( i = bX ) And ( j = bY ) Then
                 m_bWay := true;
              // On incr�mente le compteur de protection anti-bugs Lazarus.
              m_nCount += 1;
        End;
     End;
     SmallWay := m_bWay;
End;





Procedure DangerWay( aX, aY, bX, bY, n : Integer; m_aState : Table; Var p_nDangerMin, p_nDirection : Integer);
Var
   m_nDangerWay   : Integer;
   m_nNbCases     : Integer;
   i, j           : Integer;
   m_nCount       : Integer;
   m_aDirCases    : Table;                       // Contient la prochaine direction de la case.
   m_aDirPrefered : Array[ 1..4 ] Of Integer;    // Contient les �quivalences (1:gauche, 2:droite, 3:haut, 4:bas).
Begin
     p_nDangerMin := 10000;
     p_nDirection := 0;
     If ( abs( aX - bX ) + abs( aY - bY ) <= n ) Then Begin

        // Initialisation des donn�es.
        If ( abs( aX - bX ) > abs( aY - bY ) ) Then Begin
           If ( bX < aX ) Then Begin
              m_aDirPrefered[ 1 ] := 1;
              m_aDirPrefered[ 4 ] := 2;
           End
           Else Begin
              m_aDirPrefered[ 1 ] := 2;
              m_aDirPrefered[ 4 ] := 1;
           End;
           If ( bY < aY ) Then Begin
              m_aDirPrefered[ 2 ] := 3;
              m_aDirPrefered[ 3 ] := 4;
           End
           Else Begin
                m_aDirPrefered[ 2 ] := 4;
                m_aDirPrefered[ 3 ] := 3;
           End;
        End
        Else If ( abs( aX - bX ) < abs( aY - bY ) ) Then Begin
             If ( bY < aY ) Then Begin
                m_aDirPrefered[ 1 ] := 3;
                m_aDirPrefered[ 4 ] := 4;
             End
             Else Begin
                  m_aDirPrefered[ 1 ] := 4;
                  m_aDirPrefered[ 4 ] := 3;
             End;
             If ( bX < aX ) Then Begin
                m_aDirPrefered[ 2 ] := 1;
                m_aDirPrefered[ 3 ] := 2;
             End
             Else Begin
                  m_aDirPrefered[ 2 ] := 2;
                  m_aDirPrefered[ 3 ] := 1;
             End;
        End
        Else Begin
           If ( abs( aX - bX ) = 0 ) Then
              p_nDangerMin := 0
           Else Begin
                If ( bX < aX ) Then Begin
                   m_aDirPrefered[ 1 ] := 1;
                   m_aDirPrefered[ 4 ] := 2;
                End
                Else Begin
                     m_aDirPrefered[ 1 ] := 2;
                     m_aDirPrefered[ 4 ] := 1;
                End;
                If ( bY < aY ) Then Begin
                   m_aDirPrefered[ 2 ] := 3;
                   m_aDirPrefered[ 3 ] := 4;
                End
                Else Begin
                     m_aDirPrefered[ 2 ] := 4;
                     m_aDirPrefered[ 3 ] := 3;
                End;
           End;
        End;
        For i := 1 To GRIDWIDTH Do Begin
            For j := 1 To GRIDHEIGHT Do Begin
                If ( abs( bX - i ) + abs( bY - j ) <= n ) Then
                   m_aDirCases[ i, j ] := 1
                Else
                    m_aDirCases[ i, j ] := 0;
            End;
        End;
        i := aX;
        j := aY;
        m_nNbCases := 0;
        m_nDangerWay := m_aState[ i, j ];
        m_nCount := 0;
        
        // Recherche du minimum.
        While ( m_aDirCases[ i, j ] < 5 ) And ( p_nDangerMin > 0 ) And ( m_nCount < 5 * n * n ) Do Begin
              Case m_aDirPrefered[ m_aDirCases[ i, j ] ] Of
                   1 : Begin
                            // On essaie une direction donc on incr�mente pour ne pas le refaire.
                            m_aDirCases[ i, j ] += 1;
                            // S'il le bomberman peut aller sur la case et que la case est utilisable.
                            If ( m_aState[ i - 1, j ] mod 16 < 8 ) And ( m_aState[ i - 1, j ] mod 4 = 0 )
                            And ( m_aDirCases[ i - 1, j ] in [ 1..4 ] ) Then Begin
                               // Si on passe sur pour un n-i�me fois, avec n impair...
                               If ( m_aDirCases[ i - 1, j ] = 1 ) Or ( m_aDirCases[ i - 1, j ] = 3 ) Then Begin
                                  // ...et que le case est suffisament proche, alors on incr�mente le nombre de cases pass�es
                                  // et on ajoute le danger de la case au danger du chemin.
                                  If ( abs( i - 1 - bX ) + abs( j - bY ) <= n - ( m_nNbCases + 1 ) ) Then Begin
                                     m_nNbCases += 1;
                                     m_nDangerWay += m_aState[ i - 1, j ];
                                     i := i - 1;
                                  End;
                               End
                               // Si n est pair, on d�cremente le nombre de cases pass�es
                               // et on retire le danger de la case au danger du chemin.
                               Else Begin
                                   m_nNbCases -= 1;
                                   i := i - 1;
                                   m_nDangerWay -= m_aState[ i - 1, j ];
                               End;
                            End;
                       End;
                   2 : Begin
                            m_aDirCases[ i, j ] += 1;
                            If ( m_aState[ i + 1, j ] mod 16 < 8 ) And ( m_aState[ i + 1, j ] mod 4 = 0 )
                            And ( m_aDirCases[ i + 1, j ] in [ 1..4 ] ) Then Begin
                               If ( m_aDirCases[ i + 1, j ] = 1 ) Or ( m_aDirCases[ i + 1, j ] = 3 ) Then Begin
                                  If ( abs( i + 1 - bX ) + abs( j - bY ) <= n - ( m_nNbCases + 1 ) ) Then Begin
                                     m_nNbCases += 1;
                                     i := i + 1;
                                     m_nDangerWay += m_aState[ i + 1, j ];
                                  End;
                               End
                               Else Begin
                                   m_nNbCases -= 1;
                                   i := i + 1;
                                   m_nDangerWay -= m_aState[ i + 1, j ];
                               End;
                            End;
                       End;
                   3 : Begin
                            m_aDirCases[ i, j ] += 1;
                            If ( m_aState[ i, j - 1 ] mod 16 < 8 ) And ( m_aState[ i, j - 1 ] mod 4 = 0 )
                            And ( m_aDirCases[ i, j - 1 ] in [ 1..4 ] ) Then Begin
                               If ( m_aDirCases[ i, j - 1 ] = 1 ) Or ( m_aDirCases[ i, j - 1 ] = 3 ) Then Begin
                                  If ( abs( i - bX ) + abs( j - 1 - bY ) <= n - ( m_nNbCases + 1 ) ) Then Begin
                                     m_nNbCases += 1;
                                     j := j - 1;
                                     m_nDangerWay += m_aState[ i, j - 1 ];
                                  End;
                               End
                               Else Begin
                                   m_nNbCases -= 1;
                                   j := j - 1;
                                   m_nDangerWay -= m_aState[ i, j - 1 ];
                               End;
                            End;
                       End;
                   4 : Begin
                            m_aDirCases[ i, j ] += 1;
                            If ( m_aState[ i, j + 1 ] mod 16 < 8 ) And ( m_aState[ i, j + 1 ] mod 4 = 0 )
                            And ( m_aDirCases[ i, j + 1 ] in [ 1..4 ] ) Then Begin
                               If ( m_aDirCases[ i, j + 1 ] = 1 ) Or ( m_aDirCases[ i, j + 1 ] = 3 ) Then Begin
                                  If ( abs( i - bX ) + abs( j + 1 - bY ) <= n - ( m_nNbCases + 1 ) ) Then Begin
                                     m_nNbCases += 1;
                                     j := j + 1;
                                     m_nDangerWay += m_aState[ i, j + 1 ];
                                  End;
                               End
                               Else Begin
                                   m_nNbCases -= 1;
                                   j := j + 1;
                                   m_nDangerWay -= m_aState[ i, j + 1 ];
                               End;
                            End;
                       End;
              End;
              // Si on a atteint les coordon�es, on est content.
              If ( i = bX ) And ( j = bY ) And ( m_nDangerWay < p_nDangerMin ) Then Begin
                 If ( m_nNbCases < 0 ) Then m_nNbCases := 0;
                 p_nDangerMin := 2 * m_nDangerWay div ( m_nNbCases + 2 );
                 p_nDirection := m_aDirPrefered[ m_aDirCases[ aX, aY ] - 1 ];
              End;
              // On incr�mente le compteur de protection anti-bugs Lazarus.
              m_nCount += 1;
        End;
     End;
End;




End.
