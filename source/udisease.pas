Unit UDisease;

{$mode objfpc}{$H+}

////////////////////////////////////////////////////////////////////////////////
// UDisease : ?                                                               //
////////////////////////////////////////////////////////////////////////////////



Interface

// utilisation de UCore pour le timer et de UUtils pour les variables globales
Uses Classes, SysUtils, UItem, UBomberman, UCore, UUtils;

Type

{ CDisease }

CDisease = Class ( CItem )

           Private
                  uPlayer : CBomberman     ;               // stock le bomberman qui prend la maladie

                  bDisease : Boolean       ;               // définit si on applique la maladie ou si on la retire

                  // méthodes des differentes maladies
                  Procedure SpeedUp () ; cdecl;            // maladie qui augmente temporairement la vitesse du joueur
                  Procedure SpeedDown () ; cdecl;          // maladie qui diminue temporairement la vitesse du joueur
                  Procedure NoBomb () ; cdecl;             // maladie qui empeche temporairement le joueur de poser des bombes
                  //Procedure EjectBomb () ; cdecl;          // maladie qui oblige temporairement la joueur a ejecter ses bombes
                  Procedure ChangeKeys (); cdecl;          // maladie qui change temporairement les touches de deplacement
                  Procedure SwitchBomberman (); cdecl;     // maladie qui echange la position de deux joueurs

           Public
                 Procedure Bonus ( _uPlayer : CBomberman ) ; override; // procédure appelée par le bomberman pour l'attribution d'un bonus

End;

Implementation

{ CDisease }

Procedure CDisease.Bonus( _uPlayer : CBomberman );
Var i : integer;
Begin
     uPlayer := _uPlayer;
     bDisease := True;

     i := Random(5) + 1;                                // on tire un nombre aleatoire pour choisir la maladie
     Case i Of
          1 : Begin
	      SpeedUp();                                // maladie qui augmente temporairement la vitesse du joueur
	      AddTimer( TIMEDISEASE, @SpeedUp );        // on utilise un timer pour annuler l'effet de la maladie après TIMEDISEASE secondes
          End;
          2 : Begin
	      SpeedDown();                              // maladie qui diminue temporairement la vitesse du joueur
	      AddTimer( TIMEDISEASE, @SpeedDown );
          End;
          3 : Begin
	      NoBomb();                                 // maladie qui empeche temporairement le joueur de poser des bombes
	      AddTimer( TIMEDISEASE, @NoBomb );
          End;
          4 : Begin
	      ChangeKeys();                             // maladie qui change temporairement les touches de deplacement
	      AddTimer( TIMEDISEASE, @ChangeKeys );
          End;
          5 :
              SwitchBomberman();                        // maladie qui echange la position de deux joueurs
          //6 : Begin
	  //    EjectBomb( True, uPlayer );               // maladie qui oblige temporairement la joueur a ejecter ses bombes
	  //    AddTimer( TIMEDISEASE, @EjectBomb, False, uPlayer); // on utilise un timer pour annuler l'effet de la maladie apres TIMEDISEASE
          //End;
     End;
End;


Procedure CDisease.speedup (); cdecl;
BEGIN
     If ( bDisease = true ) then begin                                    // si on doit appliquer la maladie
                             uPlayer.Speed := uPlayer.Speed + SPEEDCHANGE; // augmente la vitesse du joueur
                             if (uPlayer.Speed > SPEEDLIMIT) then uPlayer.Speed := SPEEDLIMIT; // il faut limiter la vitesse du joueur
                             bDisease := false;             // on change la valeur de la variable pour qu'a la prochaine utilissation de la methode, on annule son effet
                             end
                        else begin                                   // pour annuler l'effet de la maladie
                             uPlayer.Speed := uPlayer.Speed - SPEEDCHANGE; // rediminue la vitesse du joueur
                             if (uPlayer.Speed < 1) then uPlayer.Speed := 1;   // la vitesse ne doit pas etre nul
                             Self.destroy();       // on peut detruire le bonus
                             end;

END;


Procedure CDisease.speeddown (); cdecl;
BEGIN
     If ( bDisease = true ) then begin                                  // si on doit appliquer la maladie
                             uPlayer.Speed := uPlayer.Speed - SPEEDCHANGE; // diminue la vitesse du joueur
                             if (uPlayer.Speed < 1) then uPlayer.Speed := 1;   // la vitesse ne doit pas etre nul
                             bDisease := false;                            // on change la valeur de la variable pour qu'a la prochaine utilissation de la methode, on annule son effet
                             end
                        else begin                                  // pour annuler l'effet de la maladie
                             uPlayer.Speed := uPlayer.Speed + SPEEDCHANGE; // reaugmente la vitesse du joueur
                             if (uPlayer.Speed > SPEEDLIMIT) then uPlayer.Speed := SPEEDLIMIT;    // il faut limiter la vitesse du joueur
                             Self.destroy();     // on peut detruire le bonus
                             end;
END;


Procedure CDisease.nobomb (); cdecl;
BEGIN
     If ( bDisease = true ) then begin                          // si on doit appliquer la maladie
                             uPlayer.NoBomb := true;    // empeche le joueur de poser des bombes
                             bDisease := false;            // on change la valeur de la variable pour qu'a la prochaine utilissation de la methode, on annule son effet
                             end
                        else begin                          // pour annuler l'effet de la maladie
                             uPlayer.NoBomb := false;  // reautorise le joueur a poser des bombes
                             Self.destroy();         // on peut detruire le bonus
                             end;
END;

{
Procedure CDisease.ejectbomb (); cdecl;
BEGIN
     If ( bDisease = true ) then begin                       // si on doit appliquer la maladie
                             uPlayer.ejectBomb := true;    // oblige le joueur a ejecter ses bombes
                             bDisease := false;               // on change la valeur de la variable pour qu'a la prochaine utilissation de la methode, on annule son effet
                             end
                        else begin                  // pour annuler l'effet de la maladie
                             player.ejectbomb := false;  // annule l'effet
                             Self.destroy();      // on peut detruire le bonus
                        end;
END;
}

Procedure CDisease.changekeys (); cdecl;
BEGIN
     If ( bDisease = true ) then begin                       // si on doit appliquer la maladie
                             uPlayer.ChangeReverse();      // inverse les touches de deplacement
                             bDisease := false;              // on change la valeur de la variable pour qu'a la prochaine utilissation de la methode, on annule son effet
                             end
                        else begin                    // pour annuler l'effet de la maladie
                             uPlayer.ChangeReverse();      // inverse les touches de deplacement
                             Self.destroy();        // on peut detruire le bonus
                        end;
END;


Procedure CDisease.switchbomberman (); cdecl;
var i : Integer;                                  // variable qui va definir l'index du bomberman avec qui on va changer de coordonnees
    uSecondPlayer : CBomberman;                    // variable qui va servir a recuperer les coordonnees d'un autre bomberman
    xtemp,ytemp : Single;                         // variable temporaire pour echanger les coordonnees des deux joueurs
BEGIN
     i := 0;                                       // initialisation de la variable

     Repeat                                        // boucle pour trouver un autre bomberman pour echanger de coordonnees
     i := random(GetBombermanCount())+1;             // on prend un joueur au hasard pour echanger ses coordonnees
     uSecondPlayer := GetBombermanByIndex(i);
     until ( ( i <> uPlayer.BIndex ) and (uSecondPlayer.Alive) );  // on termine la boucle quand on a trouve un bomberman autre que celui du joueur qui a prit le bonus et qui n'est pas mort

     // Echange de coordonnees des deux joueurs
     xtemp := uSecondPlayer.X;
     ytemp := uSecondPlayer.Y;
     uSecondPlayer.X := uPlayer.X;
     uSecondPlayer.Y := uPlayer.Y;
     uPlayer.X := xtemp;
     uPlayer.Y := ytemp;
     
     Self.destroy();                    // on peut detruire le bonus
END;



End.
