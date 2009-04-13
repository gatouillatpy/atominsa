Unit UUtils;

{$mode objfpc}{$H+}

////////////////////////////////////////////////////////////////////////////////
// UUtils : Unité où sont stockées toutes les constantes et fonctions         //
//          utilisées dans l'ensemble du projet.                              //
////////////////////////////////////////////////////////////////////////////////



Interface

Uses Classes, SysUtils;



// macro de la fonction exposant
function pow ( base, exponent : single ) : single ;



// type vecteur géométrique
TYPE Vector = RECORD
                    x : single;
                    y : single;
                    z : single;
              END;

// type vecteur d'entier
TYPE VectorN = RECORD
                    x : integer;
                    y : integer;
                    z : integer;
              END;
// foncitons d'opérations vectorielles de base
Procedure Normalize ( Var v : Vector ) ;
Function CrossProduct ( a, b : Vector ) : Vector ;
Function DotProduct ( a, b : Vector ) : Single ;

// constantes géométriques
Const PI = 3.141592654;
      PI2 = 2 * PI;
      RAD2DEG = 180 / PI;
      DEG2RAD = PI / 180;



Const VERSION = 'v.0.8.b';



Const PHASE_EXIT          =  0;
Const STATE_EXIT          = 10;
Const PHASE_INTRO         =  1;
Const STATE_INTRO         = 11;
Const PHASE_MENU          =  2;
Const STATE_MENU          = 12;
Const PHASE_PRACTICE      =  3;
Const STATE_PRACTICE      = 13;
Const PHASE_EDITOR        =  4;
Const STATE_EDITOR        = 14;
Const PHASE_SETUP         =  5;
Const STATE_SETUP         = 15;
Const PHASE_MULTI         =  6;
Const STATE_MULTI         = 16;
Const PHASE_ONLINE        =  7;
Const STATE_ONLINE        = 17;
Const REFRESH_ONLINE      = 27;
Const PHASE_NETWORK       =  8;
Const STATE_NETWORK       = 18;
Const PHASE_SOLO          =  9;
Const STATE_SOLO          = 19;

Var nState : Integer;
Var bSolo : Boolean;



// constantes du jeu
Const GRIDWIDTH         = 15;           // largeur de la grille
      GRIDHEIGHT        = 11;          // longueur de la grille
      DEFAULTFLAMESIZE  = 3;     // taille initiale de la portee des flames
      DEFAULTBOMBCOUNT  = 1;     // nombre initial de bombes
      DEFAULTSPEED      = 4;         // vitesse initiale des joueurs
      SPAWNCOUNT        = 256;         // nombre maximum de points d'apparitions
      POWERUPCOUNT      = 12;        // nombre de powerups différents
      TIMEDISEASE       = 10;         // duree d'action des maladies
      SPEEDCHANGE       = 0.5;          // valeur d'augmentation de la vitesse
      SPEEDLIMIT        = 7;           // vitesse maximale
      FLAMECHANGE       = 1;          // valeur d'augmentation de la portee des flammes
      FLAMELIMIT        = 10;          // portée des flammes maximale
      FLAMETIME         = 0.8;          // durée avant suppression d'une flamme
      BOMBTIME          = 3.0;           // durée avant explosion d'une bombe en situation normale
      BOMBTIMEDISEASE   = 0.75 ;    // duree avant explosion d'une bombe d'un malade =)
      BOMBMOVESPEED     = 6;        // vitesse de deplacement d'une bombe
      MAXBOMBCOUNT      = 10;        // nombre maximum de bombe par bomberman
      PUNCHNUMBERCASE   = 3;         // nombre de cases de deplacement dû à un coup de punch


// constantes d'identification des maladies
Const DISEASE_NONE           = 0;
      DISEASE_SPEEDUP        = 1;
      DISEASE_SPEEDDOWN      = 2;
      DISEASE_NOBOMB         = 3;
      DISEASE_CHANGEKEY      = 4;
      DISEASE_SWITCH         = 5;
      DISEASE_FASTBOMB       = 6;
      DISEASE_SMALLFLAME     = 7;
      DISEASE_EJECTBOMBFAST  = 8;
      DISEASE_EJECTBOMBKick  = 9;



// constatntes pour l'intelligence artificielle
const SKILL_PLAYER    = 0;
      SKILL_NOVICE    = 1;
      SKILL_AVERAGE   = 2;
      SKILL_MASTERFUL = 3;
      SKILL_GODLIKE   = 4;
      
      
// constantes de définition des chemins d'accès
Const PATH_MAP            = './maps/';
      PATH_SCHEME         = './schemes/';
      PATH_CHARACTER      = './characters/';



// constantes de définition des cases dans un scheme
Const BLOCK_BLANK = 0;
      BLOCK_BRICK = 1;
      BLOCK_SOLID = 2;



// constantes de définition des sons
Const SOUND_MENU_MOVE    = 101;
      SOUND_MENU_SELECT  = 102;
      SOUND_MENU_BACK    = 103;
      SOUND_MENU_CLICK   = 104;

      SOUND_MESSAGE      = 201;

      SOUND_BOMB_NULL    = 300;
      
      SOUND_MENU         = 400;

      SOUND_BONUS_NULL   = 500;
      SOUND_DROP_NULL    = 600;
      SOUND_DIE_NULL     = 700;
      SOUND_DISEASE_NULL = 800;
      SOUND_GRAB_NULL    = 900;
      SOUND_KICK_NULL    = 1000;
      SOUND_THROW_NULL   = 1100;
      SOUND_BOUNCE_NULL  = 1200;
      SOUND_STOP_NULL    = 1300;
      SOUND_SPEECH_NULL    = 1400;


Function SOUND_BOMB( k : Integer ) : Integer ;
Function SOUND_BONUS( k : Integer ) : Integer ;
Function SOUND_DROP( k : Integer ) : Integer ;
Function SOUND_DIE( k : Integer ) : Integer ;
Function SOUND_DISEASE( k : Integer ) : Integer ;
Function SOUND_GRAB( k : Integer ) : Integer ;
Function SOUND_KICK( k : Integer ) : Integer ;
Function SOUND_THROW( k : Integer ) : Integer ;
Function SOUND_BOUNCE( k : Integer ) : Integer ;
Function SOUND_STOP( k : Integer ) : Integer ;
Function SOUND_SPEECH( k : Integer ) : Integer ;


// constantes de définition des animations
Const ANIMATION_BOMBERMAN_NULL    = 9700;

// constantes de définition des meshes
Const MESH_BOMBERMAN_NULL    = 5300;

      MESH_BLOCK_SOLID       = 5001;
      MESH_BLOCK_BRICK       = 5002;
      MESH_BLOCK_BLANK       = 5003;
      
      MESH_DISEASE           = 5101;
      MESH_EXTRABOMB         = 5102;
      MESH_FLAMEUP           = 5103;
      MESH_SPEEDUP           = 5104;

      MESH_PLANE             = 5201;

      MESH_BOMB_NULL         = 5400;

Function MESH_BOMBERMAN( k : Integer ) : Integer ;

Function MESH_BOMB( k : Integer ) : Integer ;

Function ANIMATION_BOMBERMAN( k : Integer ) : Integer ;

// constantes de définition des textures et sprites
Const TEXTURE_NONE              = 0;

      SPRITE_MENU_BACK          = 1001;
      SPRITE_MENU_MAIN_BUTTON0  = 1002;
      SPRITE_MENU_MAIN_BUTTON1  = 1003;
      SPRITE_MENU_MAIN_BUTTON2  = 1004;
      SPRITE_MENU_MAIN_BUTTON3  = 1005;
      SPRITE_MENU_MAIN_BUTTON4  = 1006;
      SPRITE_MENU_MAIN_BUTTON5  = 1007;
      SPRITE_MENU_CROSS         = 1008;
      SPRITE_BACK               = 1009;
      SPRITE_CHARSET_TERMINAL   = 1101;
      SPRITE_CHARSET_TERMINALX  = 1111;
      SPRITE_CHARSET_DIGITAL    = 1102;
      SPRITE_CHARSET_DIGITALX   = 1112;
      SPRITE_INTRO_LAYER_NULL   = 1200;
      
      TEXTURE_BOMBERMAN_NULL    = 1300;
      TEXTURE_FLAME_NULL        = 1500;
      TEXTURE_BOMB_NULL         = 1600;

      TEXTURE_MAP_BRICK         = 1401;
      TEXTURE_MAP_SOLID         = 1402;
      TEXTURE_MAP_PLANE         = 1403;

      TEXTURE_MAP_SKYBOX_NULL   = 1410;

Function SPRITE_INTRO_LAYER( k : Integer ) : Integer ;

Function TEXTURE_BOMBERMAN( k : Integer ) : Integer ;
Function TEXTURE_FLAME( k : Integer ) : Integer ;
Function TEXTURE_BOMB( k : Integer ) : Integer ;
Function TEXTURE_MAP_SKYBOX( k : Integer ) : Integer ;



// constantes de définition des bonus dans les schemes
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



// constantes de définition des chaines de caractères affichées avec effet
Const STRING_SCORE_TABLE_NULL   =  0;
      STRING_MENU_MAIN          =  1;
      STRING_EDITOR_MENU_NULL   =  0;
      STRING_SETUP_MENU_NULL    =  0;
      STRING_GAME_MENU_NULL     =  0;
      STRING_TIMER              = 10;
      STRING_SCREEN             = 11;
      STRING_MESSAGE            = 12;
      STRING_NOTIFICATION       = 13;

Function STRING_SCORE_TABLE( k : Integer ) : Integer ;
Function STRING_EDITOR_MENU( k : Integer ) : Integer ;
Function STRING_SETUP_MENU( k : Integer ) : Integer ;
Function STRING_GAME_MENU( k : Integer ) : Integer ;



// foncitons de vérification de dépassement des limites de la grille
Function CheckX ( x : Integer ) : Boolean ;
Function CheckY ( y : Integer ) : Boolean ;
Function CheckCoordinates ( x, y : Integer ) : Boolean ;



Function BoolToStr( b : Boolean ) : String ;



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

Function STRING_EDITOR_MENU( k : Integer ) : Integer ;
Begin
     STRING_EDITOR_MENU := k + STRING_EDITOR_MENU_NULL;
End;

Function STRING_SETUP_MENU( k : Integer ) : Integer ;
Begin
     STRING_SETUP_MENU := k + STRING_SETUP_MENU_NULL;
End;

Function STRING_GAME_MENU( k : Integer ) : Integer ;
Begin
     STRING_GAME_MENU := k + STRING_GAME_MENU_NULL;
End;

Function TEXTURE_BOMBERMAN( k : Integer ) : Integer ;
Begin
     TEXTURE_BOMBERMAN := k + TEXTURE_BOMBERMAN_NULL;
End;

Function TEXTURE_FLAME( k : Integer ) : Integer ;
Begin
     TEXTURE_FLAME := k + TEXTURE_FLAME_NULL;
End;

Function TEXTURE_BOMB( k : Integer ) : Integer ;
Begin
     TEXTURE_BOMB := k + TEXTURE_BOMB_NULL;
End;

Function SOUND_BOMB( k : Integer ) : Integer ;
Begin
     SOUND_BOMB := k + SOUND_BOMB_NULL;
End;

Function SOUND_BONUS( k : Integer ) : Integer ;
Begin
     SOUND_BONUS := k + SOUND_BONUS_NULL;
End;

Function SOUND_DROP( k : Integer ) : Integer ;
Begin
     SOUND_DROP := k + SOUND_DROP_NULL;
End;

Function SOUND_DIE( k : Integer ) : Integer ;
Begin
     SOUND_DIE := k + SOUND_DIE_NULL;
End;

Function SOUND_DISEASE( k : Integer ) : Integer ;
Begin
     SOUND_DISEASE := k + SOUND_DISEASE_NULL;
End;

Function SOUND_GRAB( k : Integer ) : Integer ;
Begin
     SOUND_GRAB := k + SOUND_GRAB_NULL;
End;

Function SOUND_KICK( k : Integer ) : Integer ;
Begin
     SOUND_KICK := k + SOUND_KICK_NULL;
End;

Function SOUND_THROW( k : Integer ) : Integer ;
Begin
     SOUND_THROW := k + SOUND_THROW_NULL;
End;

Function SOUND_BOUNCE( k : Integer ) : Integer ;
Begin
     SOUND_BOUNCE := k + SOUND_BOUNCE_NULL;
End;

Function SOUND_STOP( k : Integer ) : Integer ;
Begin
     SOUND_STOP := k + SOUND_STOP_NULL;
End;

Function SOUND_SPEECH( k : Integer ) : Integer ;
Begin
     SOUND_SPEECH := k + SOUND_SPEECH_NULL;
End;

Function MESH_BOMBERMAN( k : Integer ) : Integer ;
Begin
     MESH_BOMBERMAN := k + MESH_BOMBERMAN_NULL;
End;

Function MESH_BOMB( k : Integer ) : Integer ;
Begin
     MESH_BOMB := k + MESH_BOMB_NULL;
End;

Function TEXTURE_MAP_SKYBOX( k : Integer ) : Integer ;
Begin
     TEXTURE_MAP_SKYBOX := k + TEXTURE_MAP_SKYBOX_NULL;
End;

Function ANIMATION_BOMBERMAN( k : Integer ) : Integer ;
Begin
     ANIMATION_BOMBERMAN := k + ANIMATION_BOMBERMAN_NULL;
End;



////////////////////////////////////////////////////////////////////////////////
// Fonctions de vérification de dépassement des limites de la grille.         //
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
// Foncitons d'opérations vectorielles de base.                               //
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



Function BoolToStr( b : Boolean ) : String ;
Begin
     If b Then BoolToStr := 'true' Else BoolToStr := 'false';
End;



End.

