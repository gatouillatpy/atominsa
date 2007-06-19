Unit UUtils;

{$mode objfpc}{$H+}

////////////////////////////////////////////////////////////////////////////////
// UUtils : Unit� o� sont stock�es toutes les constantes et fonctions         //
//          utilis�es dans l'ensemble du projet.                              //
////////////////////////////////////////////////////////////////////////////////



Interface

Uses Classes, SysUtils;



// macro de la fonction exposant
Function  pow ( base, exponent : single ) : single ;



// type vecteur g�om�trique
TYPE Vector = RECORD
                    x : single;
                    y : single;
                    z : single;
              END;

// foncitons d'op�rations vectorielles de base
Procedure Normalize ( Var v : Vector ) ;
Function CrossProduct ( a, b : Vector ) : Vector ;
Function DotProduct ( a, b : Vector ) : Single ;

// constantes g�om�triques
Const PI = 3.141592654;
      PI2 = 2 * PI;
      RAD2DEG = 180 / PI;
      DEG2RAD = PI / 180;



Const VERSION = 'v.1.0.b';



Const PHASE_EXIT          =  0;
Const PHASE_INTRO         =  1;
Const STATE_INTRO         = 11;
Const PHASE_MENU          =  2;
Const STATE_MENU          = 12;
Const PHASE_PRACTICE      =  3;
Const STATE_PRACTICE      = 13;

Var nState : Integer;



// constantes du jeu
Const GRIDWIDTH = 15;           // largeur de la grille
      GRIDHEIGHT = 11;          // longueur de la grille
      DEFAULTFLAMESIZE = 3;     // taille initiale de la portee des flames
      DEFAULTBOMBCOUNT = 10;     // nombre initial de bombes
      DEFAULTSPEED = 4;         // vitesse initiale des joueurs
      SPAWNCOUNT = 256;         // nombre maximum de points d'apparitions
      POWERUPCOUNT = 13;        // nombre de powerups diff�rents
      TIMEDISEASE = 10;         // duree d'action des maladies
      SPEEDCHANGE = 1;          // valeur d'augmentation de la vitesse
      SPEEDLIMIT = 5;           // vitesse maximale
      FLAMECHANGE = 1;          // valeur d'augmentation de la portee des flammes
      FLAMELIMIT = 10;          // port�e des flammes maximale
      FLAMETIME = 0.8;          // dur�e avant suppression d'une flamme
      BOMBTIME = 15.0;           // dur�e avant explosion d'une bombe
      BOMBMOVESPEED = 5;        // vitesse de deplacement d'une bombe



// constantes de d�finition des chemins d'acc�s
Const PATH_MAP            = './maps/';
      PATH_SCHEME         = './schemes/';
      PATH_CHARACTER      = './characters/';



// constantes de d�finition des cases dans un scheme
Const BLOCK_BLANK = 0;
      BLOCK_BRICK = 1;
      BLOCK_SOLID = 2;



// constantes de d�finition des sons
Const SOUND_MENU_MOVE    = 01;
      SOUND_MENU_SELECT  = 02;
      SOUND_MENU_BACK    = 03;

      SOUND_BOMB_NULL    = 10;

Function SOUND_BOMB( k : Integer ) : Integer ;


// constantes de d�finition des meshes
Const MESH_BOMBERMAN    = 1;
      MESH_BLOCK_SOLID  = 2;
      MESH_BLOCK_BRICK  = 3;
      MESH_BLOCK_BLANK  = 4;
      MESH_DISEASE      = 5;
      MESH_BOMB         = 6;
      MESH_EXTRABOMB    = 7;
      MESH_FLAMEUP      = 8;
      MESH_SPEEDUP      = 9;
      MESH_PLANE        = 10;



// constantes de d�finition des textures et sprites
Const TEXTURE_NONE              = 0;

      SPRITE_MENU_BACK          = 1001;
      SPRITE_MENU_MAIN_BUTTON0  = 1002;
      SPRITE_MENU_MAIN_BUTTON1  = 1003;
      SPRITE_MENU_MAIN_BUTTON2  = 1004;
      SPRITE_MENU_MAIN_BUTTON3  = 1005;
      SPRITE_MENU_MAIN_BUTTON4  = 1006;
      SPRITE_MENU_CROSS         = 1007;
      SPRITE_CHARSET_TERMINAL   = 1101;
      SPRITE_CHARSET_TERMINALX  = 1111;
      SPRITE_CHARSET_DIGITAL    = 1102;
      SPRITE_INTRO_LAYER_NULL   = 1200;
      
      TEXTURE_BOMBERMAN_NULL    = 1300;
      TEXTURE_BOMBERMAN_FLAME   = 1311;
      TEXTURE_BOMBERMAN_BOMB    = 1312;

      TEXTURE_MAP_BRICK         = 1401;
      TEXTURE_MAP_SOLID         = 1402;
      TEXTURE_MAP_PLANE         = 1403;

Function SPRITE_INTRO_LAYER( k : Integer ) : Integer ;

Function TEXTURE_BOMBERMAN( k : Integer ) : Integer ;



// constantes de d�finition des bonus dans les schemes
Const POWERUP_NONE                 = -1;
      POWERUP_EXTRABOMB            = 0;
      POWERUP_FLAMEUP              = 1;
      POWERUP_DISEASE              = 2;
      POWERUP_KICK                 = 3;
      POWERUP_SPEEDUP              = 4;
      POWERUP_PUNCH                = 5;
      POWERUP_GRAB                 = 6;
      POWERUP_SPOOGER              = 7;
      POWERUP_GOLDFLAME            = 8;
      POWERUP_TRIGGERBOMB          = 9;
      POWERUP_JELLYBOMB            = 10;
      POWERUP_SUPERDISEASE         = 11;
      POWERUP_RANDOM               = 12;
      
      BOMBERMAN_WHITE              = 0;
      BOMBERMAN_BLACK              = 1;



// constantes de d�finition des chaines de caract�res affich�es avec effet
Const STRING_SCORE_TABLE_NULL   = 0;
      STRING_MENU_MAIN          = 1;

Function STRING_SCORE_TABLE( k : Integer ) : Integer ;



// foncitons de v�rification de d�passement des limites de la grille
Function CheckX ( x : Integer ) : Boolean ;
Function CheckY ( y : Integer ) : Boolean ;
Function CheckCoordinates ( x, y : Integer ) : Boolean ;



Implementation



// macro de la fonction exposant
function pow ( base, exponent : single ) : single ;
begin
     if base = 0.0 then pow := 0.0 else pow := exp(ln(base)*(exponent));
end;



////////////////////////////////////////////////////////////////////////////////
// Fonctions de constantes dynamiques.                                        //
////////////////////////////////////////////////////////////////////////////////

Function SPRITE_INTRO_LAYER( k : Integer ) : Integer ;
Begin
     SPRITE_INTRO_LAYER := k + SPRITE_INTRO_LAYER_NULL;
End;

Function STRING_SCORE_TABLE( k : Integer ) : Integer ;
Begin
     STRING_SCORE_TABLE := k + STRING_SCORE_TABLE_NULL;
End;

Function TEXTURE_BOMBERMAN( k : Integer ) : Integer ;
Begin
     TEXTURE_BOMBERMAN := k + TEXTURE_BOMBERMAN_NULL;
End;

Function SOUND_BOMB( k : Integer ) : Integer ;
Begin
     SOUND_BOMB := k + SOUND_BOMB_NULL;
End;



////////////////////////////////////////////////////////////////////////////////
// Foncitons de v�rification de d�passement des limites de la grille.         //
////////////////////////////////////////////////////////////////////////////////

Function CheckX( x : Integer ) : Boolean ;
Begin
     Result := ((x>=1) And (x<=GRIDWIDTH));
End;

Function CheckY( y : Integer ) : Boolean ;
Begin
     Result := ((y>=1) And (y<=GRIDHEIGHT));
End;

Function CheckCoordinates ( x, y : Integer ) : Boolean ;
Begin
     Result := CheckX(x) And CheckY(y);
End;



////////////////////////////////////////////////////////////////////////////////
// Foncitons d'op�rations vectorielles de base.                               //
////////////////////////////////////////////////////////////////////////////////

Procedure Normalize ( Var v : Vector ) ;
Var n : Single;
Begin
     n := sqrt( (v.x*v.x) + (v.y*v.y) + (v.z*v.z) );
     If n <> 0 Then Begin
        v.x := v.x / n;
        v.y := v.y / n;
        v.z := v.z / n;
     End;
End;

Function CrossProduct ( a, b : Vector ) : Vector ;
Var c : Vector;
Begin
     c.x := a.y * b.z - a.z * b.y;
     c.y := a.z * b.x - a.x * b.z;
     c.z := a.x * b.y - a.y * b.x;
     CrossProduct := c;
End;

Function DotProduct ( a, b : Vector ) : single ;
Begin
     DotProduct := a.x * b.x + a.y * b.y + a.z * b.z;
End;



End.

