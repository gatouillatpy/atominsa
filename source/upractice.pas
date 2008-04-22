Unit UPractice;

{$mode objfpc}{$H+}




Interface



Uses Classes, SysUtils,
     UCore, UGame, UUtils, USetup;



Procedure InitPractice () ;
Procedure ProcessPractice () ;



Implementation



Procedure InitPractice () ;
Begin
     // désactivation de la souris
     BindButton( BUTTON_LEFT, NIL );

     // désactivation du mode multi
     bMulti := False;

     // initialisation du menu
     InitMenu();

     // mise à jour de la machine d'état
     nState := STATE_PRACTICE;
End;



Procedure ProcessPractice () ;
Begin
     Case nGame Of
          GAME_MENU : ProcessMenu();
          GAME_MENU_PLAYER : ProcessMenuPlayer();
          GAME_INIT : InitGame();
          GAME_ROUND : ProcessGame();
          GAME_WAIT : ProcessWait();
          GAME_SCORE : ProcessScore();
     End;
End;





























End.

