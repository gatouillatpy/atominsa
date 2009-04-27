Unit UDisease;

{$mode objfpc}{$H+}


Interface

// utilisation de UCore pour le timer et de UUtils pour les variables globales
Uses Classes, SysUtils, UItem, UBomberman, UCore, UUtils;


Const DISEASECOUNT = 9;

Type

{ CDisease }
CDisease = Class ( CItem )

           Private
                  uPlayer : CBomberman     ;               // stock le bomberman qui prend la maladie
                  nOldValue : integer;                     // garde en memoire les anciennes valeurs si necessaire
                  fOldValue : Single;
                  bOldValue : boolean;
                  bDisease : Boolean       ;               // définit si on applique la maladie ou si on la retire

                  // méthodes des differentes maladies
                  Procedure SpeedUp () ; cdecl;            // maladie qui augmente temporairement la vitesse du joueur
                  Procedure SpeedDown () ; cdecl;          // maladie qui diminue temporairement la vitesse du joueur
                  Procedure NoBomb () ; cdecl;             // maladie qui empeche temporairement le joueur de poser des bombes
                  Procedure ChangeKeys (); cdecl;          // maladie qui change temporairement les touches de deplacement
                  Procedure SwitchBomberman (); cdecl;     // maladie qui echange la position de deux joueurs
                  procedure FastBomb();cdecl;
                  procedure SmallFlame();cdecl;
                  Procedure EjectBombFast () ; cdecl;          // maladie qui oblige temporairement la joueur a ejecter ses bombes + vitesse max
                  Procedure EjectBombKick () ; cdecl;          // idem sauf que kick au lieu de vitesse max
           Public
                 Constructor Create (aX, aY : Integer);OverRide;
                 Destructor Destroy();override;
                 Procedure Bonus ( _uPlayer : CBomberman ) ; override; // procédure appelée par le bomberman pour l'attribution d'un bonus
                 Procedure BonusForced( _uPlayer : CBomberman; num : integer);

End;

Implementation

Uses UGame, USetup, UMulti;

{ CDisease }

Procedure CDisease.Bonus( _uPlayer : CBomberman );
Var i : integer;
Begin
     SetString( STRING_NOTIFICATION, _uPlayer.Name + ' has picked up a disease.', 0.0, 0.2, 5 );
     i := Random(DISEASECOUNT) + 1;                                                                            // on tire un nombre aleatoire pour choisir la maladie
     if (_uPlayer.DiseaseNumber=0) or (i=DISEASE_SWITCH) then BonusForced(_uPlayer,i) else Destroy();         // s'il est deja malade il peut pas etre encore malade
End;

procedure CDisease.BonusForced(_uPlayer: CBomberman; num: integer);
begin
  uPlayer := _uPlayer;
  bDisease := True;
    uPlayer.DiseaseNumber:=num;
    
    Case num Of
            DISEASE_SPEEDUP : Begin
                SpeedUp();                                // maladie qui augmente temporairement la vitesse du joueur
  	      AddTimer( TIMEDISEASE, @SpeedUp );        // on utilise un timer pour annuler l'effet de la maladie après TIMEDISEASE secondes
            End;
            DISEASE_SPEEDDOWN : Begin
  	      SpeedDown();                              // maladie qui diminue temporairement la vitesse du joueur
  	      AddTimer( TIMEDISEASE, @SpeedDown );
            End;
            DISEASE_NOBOMB : Begin
  	      NoBomb();                                 // maladie qui empeche temporairement le joueur de poser des bombes
  	      AddTimer( TIMEDISEASE, @NoBomb );
            End;
            DISEASE_CHANGEKEY : Begin
  	      ChangeKeys();                             // maladie qui change temporairement les touches de deplacement
  	      AddTimer( TIMEDISEASE, @ChangeKeys );
            End;
            DISEASE_SWITCH :
                SwitchBomberman();                        // maladie qui echange la position de deux joueurs
            DISEASE_FASTBOMB : Begin
                FastBomb();                               // bombe explose apres BOMBTIMEDISEASE de temps (inferieur a la normale)
                AddTimer( TIMEDISEASE, @FastBomb);
            End;
            DISEASE_SMALLFLAME : Begin
                SmallFlame();                             // reduit la taille de la flame a une case aux alentours
                AddTimer( TIMEDISEASE, @SmallFlame);
            End;
            DISEASE_EJECTBOMBFAST : Begin
  	      EjectBombFast();               // maladie qui oblige temporairement la joueur a ejecter ses bombes
  	      AddTimer( TIMEDISEASE, @EjectBombFast); // on utilise un timer pour annuler l'effet de la maladie apres TIMEDISEASE
            End;
            DISEASE_EJECTBOMBKICK : Begin
  	      EjectBombKick();               // maladie qui oblige temporairement la joueur a ejecter ses bombes
  	      AddTimer( TIMEDISEASE, @EjectBombKick); // on utilise un timer pour annuler l'effet de la maladie apres TIMEDISEASE
            End;
       End;
end;


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


Procedure CDisease.ejectbombfast (); cdecl;
BEGIN
     If ( bDisease = true ) then begin                       // si on doit appliquer la maladie
                             uPlayer.EjectBomb := true;     // oblige le joueur a ejecter ses bombes
                             foldValue := uPlayer.Speed;
                             uPlayer.Speed := SPEEDLIMIT;
                             bDisease := false;               // on change la valeur de la variable pour qu'a la prochaine utilissation de la methode, on annule son effet
                             end
                        else begin                  // pour annuler l'effet de la maladie
                             uPlayer.EjectBomb := false;  // annule l'effet
                             uPlayer.Speed := fOldValue;
                             Self.destroy();      // on peut detruire le bonus
                        end;
END;

Procedure CDisease.ejectbombkick (); cdecl;
BEGIN
     If ( bDisease = true ) then begin                       // si on doit appliquer la maladie
                             uPlayer.EjectBomb := true;     // oblige le joueur a ejecter ses bombes
                             boldValue := uPlayer.Kick;
                             uPlayer.ActiveKick;
                             bDisease := false;               // on change la valeur de la variable pour qu'a la prochaine utilissation de la methode, on annule son effet
                             end
                        else begin                  // pour annuler l'effet de la maladie
                             uPlayer.EjectBomb := false;  // annule l'effet
                             if Not(bOldValue) then uPlayer.DisableKick();
                             Self.destroy();      // on peut detruire le bonus
                        end;
END;

constructor CDisease.Create(aX, aY: Integer);
begin
  uPlayer:=nil;
  inherited Create(aX, aY);
end;

destructor CDisease.Destroy();
begin
  if Not(uPlayer=nil) then uPlayer.DiseaseNumber:=DISEASE_NONE;
  inherited Destroy();
end;


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
    sData : String;
BEGIN
     If ( bMulti = false ) Or ( nClientIndex[0] = nLocalIndex ) Then Begin
         i := 1;                                       // initialisation de la variable

         Repeat                                        // boucle pour trouver un autre bomberman pour echanger de coordonnees
         i := random(GetBombermanCount())+1;             // on prend un joueur au hasard pour echanger ses coordonnees
         uSecondPlayer := GetBombermanByCount(i);
         until ( ( i <> uPlayer.BIndex ) and (uSecondPlayer.Alive) );  // on termine la boucle quand on a trouve un bomberman autre que celui du joueur qui a prit le bonus et qui n'est pas mort

         // Echange de coordonnees des deux joueurs
         xtemp := uSecondPlayer.Position.X;
         ytemp := uSecondPlayer.Position.Y;
         uSecondPlayer.Position.X := uPlayer.Position.X;
         uSecondPlayer.Position.Y := uPlayer.Position.Y;
         uPlayer.Position.X := xtemp;
         uPlayer.Position.Y := ytemp;
     End;
     
     uPlayer.DiseaseNumber := DISEASE_NONE;

     If ( bMulti = true ) And ( nClientIndex[0] = nLocalIndex ) Then Begin
         sData := IntToStr( uPlayer.nIndex ) + #31;
         sData := sData + FormatFloat( '0.000', uPlayer.Position.X ) + #31;
         sData := sData + FormatFloat( '0.000', uPlayer.Position.Y ) + #31;
         sData := sData + IntToStr( uSecondPlayer.nIndex ) + #31;
         sData := sData + FormatFloat( '0.000', uSecondPlayer.Position.X ) + #31;
         sData := sData + FormatFloat( '0.000', uSecondPlayer.Position.Y ) + #31;
         Send( nLocalIndex, HEADER_SWITCH, sData );
     End;

     Self.destroy();                    // on peut detruire le bonus
END;

procedure CDisease.FastBomb(); cdecl;
begin
  if bDisease then
  begin
    fOldValue:=uPlayer.ExploseBombTime;
    uPlayer.ExploseBombTime:=BOMBTIMEDISEASE;
    bDisease:=false;
  end
  else
  begin
    uPlayer.ExploseBombTime:=fOldValue;
    Destroy;
  end;

end;

procedure CDisease.SmallFlame(); cdecl;
begin
  if bDisease then
  begin
      nOldValue:=uPlayer.FlameSize;
      uPlayer.FlameSize:=2;
      bDisease:=false;
  end
  else
  begin
    uPlayer.FlameSize:=nOldValue;
    Destroy;
  end;
end;



End.
