; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Atominsa"
!define PRODUCT_VERSION "0.8e"
!define PRODUCT_PUBLISHER "IGC"
!define PRODUCT_WEB_SITE "http://atominsa.sf.net"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\atominsa.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "..\source\atominsa.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "gpl-3.0.txt"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Start menu page
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Atominsa"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\atominsa.exe"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\readme.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Show readme.txt"
!define MUI_FINISHPAGE_LINK "atominsa.sf.net"
!define MUI_FINISHPAGE_LINK_LOCATION "http://atominsa.sf.net"
!define MUI_FINISHPAGE_LINK_COLOR 000080
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "setup-atominsa_0.8e.exe"
InstallDir "$PROGRAMFILES\Atominsa"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Function .onInit
 
  ReadRegStr $R0 HKLM \
  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
  "UninstallString"
  StrCmp $R0 "" done
 
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "${PRODUCT_NAME} is already installed. $\n$\nClick `OK` to remove the \
  previous version or `Cancel` to cancel this upgrade." \
  IDOK uninst
  Abort
 
;Run the uninstaller
uninst:
  ClearErrors
  ExecWait '$R0 _?=$INSTDIR' ;Do not copy the uninstaller to a temp file
 
  IfErrors no_remove_uninstaller
    ;You can either use Delete /REBOOTOK in the uninstaller or add some code
    ;here to remove the uninstaller. Use a registry key to check
    ;whether the user has chosen to uninstall. If you are using an uninstaller
    ;components page, make sure all sections are uninstalled.
  no_remove_uninstaller:
 
done:
 
FunctionEnd

Section "SectionPrincipale" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite try
  File "..\source\exec\atominsa.cfg"
  File "..\source\exec\atominsa.exe"
  File "..\source\exec\readme.txt"
  SetOutPath "$INSTDIR\characters\bomberman"
  File "..\source\exec\characters\bomberman\bomb.jpg"
  File "..\source\exec\characters\bomberman\bomb.m12"
  File "..\source\exec\characters\bomberman\bomberman.a12"
  File "..\source\exec\characters\bomberman\bomberman.m12"
  File "..\source\exec\characters\bomberman\bomberman0.jpg"
  File "..\source\exec\characters\bomberman\bomberman1.jpg"
  File "..\source\exec\characters\bomberman\bomberman2.jpg"
  File "..\source\exec\characters\bomberman\bomberman3.jpg"
  File "..\source\exec\characters\bomberman\bomberman4.jpg"
  File "..\source\exec\characters\bomberman\bomberman5.jpg"
  File "..\source\exec\characters\bomberman\bomberman6.jpg"
  File "..\source\exec\characters\bomberman\bomberman7.jpg"
  File "..\source\exec\characters\bomberman\flame.jpg"
  SetOutPath "$INSTDIR\characters"
  File "..\source\exec\characters\bomberman.chr"
  SetOutPath "$INSTDIR\maps\night"
  File "..\source\exec\maps\night\brick.jpg"
  File "..\source\exec\maps\night\brick.m12"
  File "..\source\exec\maps\night\plane.jpg"
  File "..\source\exec\maps\night\plane.m12"
  File "..\source\exec\maps\night\sb-back.jpg"
  File "..\source\exec\maps\night\sb-bottom.jpg"
  File "..\source\exec\maps\night\sb-front.jpg"
  File "..\source\exec\maps\night\sb-left.jpg"
  File "..\source\exec\maps\night\sb-right.jpg"
  File "..\source\exec\maps\night\sb-top.jpg"
  File "..\source\exec\maps\night\solid.jpg"
  File "..\source\exec\maps\night\solid.m12"
  SetOutPath "$INSTDIR\maps"
  File "..\source\exec\maps\night.map"
  SetOutPath "$INSTDIR\maps\sunset"
  File "..\source\exec\maps\sunset\brick.jpg"
  File "..\source\exec\maps\sunset\brick.m12"
  File "..\source\exec\maps\sunset\plane.jpg"
  File "..\source\exec\maps\sunset\plane.m12"
  File "..\source\exec\maps\sunset\sb-back.jpg"
  File "..\source\exec\maps\sunset\sb-bottom.jpg"
  File "..\source\exec\maps\sunset\sb-front.jpg"
  File "..\source\exec\maps\sunset\sb-left.jpg"
  File "..\source\exec\maps\sunset\sb-right.jpg"
  File "..\source\exec\maps\sunset\sb-top.jpg"
  File "..\source\exec\maps\sunset\solid.jpg"
  File "..\source\exec\maps\sunset\solid.m12"
  SetOutPath "$INSTDIR\maps"
  File "..\source\exec\maps\sunset.map"
  SetOutPath "$INSTDIR\meshes"
  File "..\source\exec\meshes\bomb.m12"
  File "..\source\exec\meshes\disease.m12"
  File "..\source\exec\meshes\extrabomb.m12"
  File "..\source\exec\meshes\flameup.m12"
  File "..\source\exec\meshes\speedup.m12"
  SetOutPath "$INSTDIR\musics"
  File "..\source\exec\musics\menu.mp3"
  File "..\source\exec\musics\game0.mp3"
  File "..\source\exec\musics\game1.mp3"
  File "..\source\exec\musics\game2.mp3"
  File "..\source\exec\musics\game3.mp3"
  SetOutPath "$INSTDIR\schemes"
  File "..\source\exec\schemes\4CORNERS.SCH"
  File "..\source\exec\schemes\AIRCHAOS.SCH"
  File "..\source\exec\schemes\AIRMAIL.SCH"
  File "..\source\exec\schemes\ALLEYS.SCH"
  File "..\source\exec\schemes\ALLEYS2.SCH"
  File "..\source\exec\schemes\ANTFARM.SCH"
  File "..\source\exec\schemes\ASYLUM.SCH"
  File "..\source\exec\schemes\BACK.SCH"
  File "..\source\exec\schemes\BACK2.SCH"
  File "..\source\exec\schemes\BASIC.SCH"
  File "..\source\exec\schemes\BASICSML.SCH"
  File "..\source\exec\schemes\BMAN93.SCH"
  File "..\source\exec\schemes\BORDER.SCH"
  File "..\source\exec\schemes\BOWLING.SCH"
  File "..\source\exec\schemes\BOXED.SCH"
  File "..\source\exec\schemes\BREAKOUT.SCH"
  File "..\source\exec\schemes\BUNCH.SCH"
  File "..\source\exec\schemes\CASTLE.SCH"
  File "..\source\exec\schemes\CASTLE2.SCH"
  File "..\source\exec\schemes\CHAIN.SCH"
  File "..\source\exec\schemes\CHASE.SCH"
  File "..\source\exec\schemes\CHECKERS.SCH"
  File "..\source\exec\schemes\CHICANE.SCH"
  File "..\source\exec\schemes\CLEAR.SCH"
  File "..\source\exec\schemes\CLEARING.SCH"
  File "..\source\exec\schemes\CONFUSED.SCH"
  File "..\source\exec\schemes\CUBIC.SCH"
  File "..\source\exec\schemes\CUTTER.SCH"
  File "..\source\exec\schemes\CUTTHROT.SCH"
  File "..\source\exec\schemes\DEADEND.SCH"
  File "..\source\exec\schemes\DIAMOND.SCH"
  File "..\source\exec\schemes\DOGRACE.SCH"
  File "..\source\exec\schemes\DOME.SCH"
  File "..\source\exec\schemes\E_VS_W.SCH"
  File "..\source\exec\schemes\FAIR.SCH"
  File "..\source\exec\schemes\FARGO.SCH"
  File "..\source\exec\schemes\FORT.SCH"
  File "..\source\exec\schemes\FREEWAY.SCH"
  File "..\source\exec\schemes\GRIDLOCK.SCH"
  File "..\source\exec\schemes\HAPPY.SCH"
  File "..\source\exec\schemes\JAIL.SCH"
  File "..\source\exec\schemes\LEAK.SCH"
  File "..\source\exec\schemes\NEIGHBOR.SCH"
  File "..\source\exec\schemes\NEIL.SCH"
  File "..\source\exec\schemes\N_VS_S.SCH"
  File "..\source\exec\schemes\OBSTACLE.SCH"
  File "..\source\exec\schemes\OG.SCH"
  File "..\source\exec\schemes\PATTERN.SCH"
  File "..\source\exec\schemes\PINGPONG.SCH"
  File "..\source\exec\schemes\PURIST.SCH"
  File "..\source\exec\schemes\RACER1.SCH"
  File "..\source\exec\schemes\RAIL1.SCH"
  File "..\source\exec\schemes\RAILROAD.SCH"
  File "..\source\exec\schemes\ROOMMATE.SCH"
  File "..\source\exec\schemes\R_GARDEN.SCH"
  File "..\source\exec\schemes\SPIRAL.SCH"
  File "..\source\exec\schemes\SPREAD.SCH"
  File "..\source\exec\schemes\TENNIS.SCH"
  File "..\source\exec\schemes\THATTHIS.SCH"
  File "..\source\exec\schemes\THE_RIM.SCH"
  File "..\source\exec\schemes\THISTHAT.SCH"
  File "..\source\exec\schemes\TIGHT.SCH"
  File "..\source\exec\schemes\TOILET.SCH"
  File "..\source\exec\schemes\UTURN.SCH"
  File "..\source\exec\schemes\VOLLEY.SCH"
  File "..\source\exec\schemes\WALLYBOM.SCH"
  File "..\source\exec\schemes\X.SCH"
  SetOutPath "$INSTDIR\shaders"
  File "..\source\exec\shaders\bomb.vs"
  File "..\source\exec\shaders\bomb2.ps"
  File "..\source\exec\shaders\bomb3.ps"
  File "..\source\exec\shaders\bomb4.ps"
  SetOutPath "$INSTDIR\sounds"
  File "..\source\exec\sounds\back.mp3"
  File "..\source\exec\sounds\click.mp3"
  File "..\source\exec\sounds\message.mp3"
  File "..\source\exec\sounds\move.mp3"
  File "..\source\exec\sounds\select.mp3"
  File "..\source\exec\sounds\speech0.mp3"
  File "..\source\exec\sounds\speech1.mp3"
  File "..\source\exec\sounds\speech2.mp3"
  File "..\source\exec\sounds\speech3.mp3"
  File "..\source\exec\sounds\speech4.mp3"
  File "..\source\exec\sounds\speech5.mp3"
  File "..\source\exec\sounds\speech6.mp3"
  File "..\source\exec\sounds\speech7.mp3"
  File "..\source\exec\sounds\speech8.mp3"
  File "..\source\exec\sounds\speech9.mp3"
  File "..\source\exec\sounds\speech10.mp3"
  File "..\source\exec\sounds\speech11.mp3"
  File "..\source\exec\sounds\speech12.mp3"
  File "..\source\exec\sounds\speech13.mp3"
  File "..\source\exec\sounds\speech14.mp3"
  File "..\source\exec\sounds\speech15.mp3"
  File "..\source\exec\sounds\speech16.mp3"
  File "..\source\exec\sounds\speech17.mp3"
  File "..\source\exec\sounds\speech18.mp3"
  File "..\source\exec\sounds\speech19.mp3"
  File "..\source\exec\sounds\speech20.mp3"
  File "..\source\exec\sounds\speech21.mp3"
  File "..\source\exec\sounds\speech22.mp3"
  File "..\source\exec\sounds\speech23.mp3"
  File "..\source\exec\sounds\speech24.mp3"
  File "..\source\exec\sounds\speech25.mp3"
  File "..\source\exec\sounds\speech26.mp3"
  File "..\source\exec\sounds\speech27.mp3"
  File "..\source\exec\sounds\speech28.mp3"
  File "..\source\exec\sounds\speech29.mp3"
  File "..\source\exec\sounds\speech30.mp3"
  File "..\source\exec\sounds\speech31.mp3"
  File "..\source\exec\sounds\speech32.mp3"
  File "..\source\exec\sounds\speech33.mp3"
  File "..\source\exec\sounds\speech34.mp3"
  File "..\source\exec\sounds\speech35.mp3"
  File "..\source\exec\sounds\speech36.mp3"
  File "..\source\exec\sounds\speech37.mp3"
  File "..\source\exec\sounds\speech38.mp3"
  File "..\source\exec\sounds\speech39.mp3"
  File "..\source\exec\sounds\speech40.mp3"
  File "..\source\exec\sounds\speech41.mp3"
  File "..\source\exec\sounds\speech42.mp3"
  File "..\source\exec\sounds\speech43.mp3"
  File "..\source\exec\sounds\speech44.mp3"
  File "..\source\exec\sounds\speech45.mp3"
  File "..\source\exec\sounds\speech46.mp3"
  File "..\source\exec\sounds\speech47.mp3"
  File "..\source\exec\sounds\speech48.mp3"
  File "..\source\exec\sounds\speech49.mp3"
  File "..\source\exec\sounds\speech50.mp3"
  File "..\source\exec\sounds\speech51.mp3"
  File "..\source\exec\sounds\speech52.mp3"
  File "..\source\exec\sounds\speech53.mp3"
  File "..\source\exec\sounds\speech54.mp3"
  File "..\source\exec\sounds\speech55.mp3"
  File "..\source\exec\sounds\speech56.mp3"
  File "..\source\exec\sounds\speech57.mp3"
  File "..\source\exec\sounds\speech58.mp3"
  File "..\source\exec\sounds\speech59.mp3"
  File "..\source\exec\sounds\speech60.mp3"
  File "..\source\exec\sounds\speech61.mp3"
  File "..\source\exec\sounds\speech62.mp3"
  File "..\source\exec\sounds\speech63.mp3"
  File "..\source\exec\sounds\speech64.mp3"
  File "..\source\exec\sounds\speech65.mp3"
  File "..\source\exec\sounds\speech66.mp3"
  File "..\source\exec\sounds\speech67.mp3"
  File "..\source\exec\sounds\speech68.mp3"
  File "..\source\exec\sounds\speech69.mp3"
  File "..\source\exec\sounds\speech70.mp3"
  File "..\source\exec\sounds\speech71.mp3"
  File "..\source\exec\sounds\speech72.mp3"
  File "..\source\exec\sounds\speech73.mp3"
  File "..\source\exec\sounds\speech74.mp3"
  File "..\source\exec\sounds\speech75.mp3"
  File "..\source\exec\sounds\speech76.mp3"
  File "..\source\exec\sounds\speech77.mp3"
  File "..\source\exec\sounds\speech78.mp3"
  File "..\source\exec\sounds\speech79.mp3"
  File "..\source\exec\sounds\speech80.mp3"
  File "..\source\exec\sounds\speech81.mp3"
  File "..\source\exec\sounds\speech82.mp3"
  File "..\source\exec\sounds\speech83.mp3"
  File "..\source\exec\sounds\speech84.mp3"
  File "..\source\exec\sounds\speech85.mp3"
  File "..\source\exec\sounds\speech86.mp3"
  File "..\source\exec\sounds\bomb0.mp3"
  File "..\source\exec\sounds\bomb1.mp3"
  File "..\source\exec\sounds\bomb2.mp3"
  File "..\source\exec\sounds\bomb3.mp3"
  File "..\source\exec\sounds\bomb4.mp3"
  File "..\source\exec\sounds\bomb5.mp3"
  File "..\source\exec\sounds\bomb6.mp3"
  File "..\source\exec\sounds\bomb7.mp3"
  File "..\source\exec\sounds\bomb8.mp3"
  File "..\source\exec\sounds\bomb9.mp3"
  File "..\source\exec\sounds\bomb10.mp3"
  File "..\source\exec\sounds\bomb11.mp3"
  File "..\source\exec\sounds\bomb12.mp3"
  File "..\source\exec\sounds\bomb13.mp3"
  File "..\source\exec\sounds\bomb14.mp3"
  File "..\source\exec\sounds\bomb15.mp3"
  File "..\source\exec\sounds\bomb16.mp3"
  File "..\source\exec\sounds\bomb17.mp3"
  File "..\source\exec\sounds\bomb18.mp3"
  File "..\source\exec\sounds\bomb19.mp3"
  File "..\source\exec\sounds\bomb20.mp3"
  File "..\source\exec\sounds\bomb21.mp3"
  File "..\source\exec\sounds\bomb22.mp3"
  File "..\source\exec\sounds\bomb23.mp3"
  File "..\source\exec\sounds\bomb24.mp3"
  File "..\source\exec\sounds\bomb25.mp3"
  File "..\source\exec\sounds\bomb26.mp3"
  File "..\source\exec\sounds\bomb27.mp3"
  File "..\source\exec\sounds\bomb28.mp3"
  File "..\source\exec\sounds\bomb29.mp3"
  File "..\source\exec\sounds\bonus0.mp3"
  File "..\source\exec\sounds\bonus1.mp3"
  File "..\source\exec\sounds\bonus2.mp3"
  File "..\source\exec\sounds\bonus3.mp3"
  File "..\source\exec\sounds\bounce0.mp3"
  File "..\source\exec\sounds\bounce1.mp3"
  File "..\source\exec\sounds\die0.mp3"
  File "..\source\exec\sounds\die1.mp3"
  File "..\source\exec\sounds\disease0.mp3"
  File "..\source\exec\sounds\disease1.mp3"
  File "..\source\exec\sounds\disease2.mp3"
  File "..\source\exec\sounds\disease3.mp3"
  File "..\source\exec\sounds\disease4.mp3"
  File "..\source\exec\sounds\disease5.mp3"
  File "..\source\exec\sounds\disease6.mp3"
  File "..\source\exec\sounds\disease7.mp3"
  File "..\source\exec\sounds\drop0.mp3"
  File "..\source\exec\sounds\drop1.mp3"
  File "..\source\exec\sounds\drop2.mp3"
  File "..\source\exec\sounds\grab0.mp3"
  File "..\source\exec\sounds\grab1.mp3"
  File "..\source\exec\sounds\kick0.mp3"
  File "..\source\exec\sounds\kick1.mp3"
  File "..\source\exec\sounds\kick2.mp3"
  File "..\source\exec\sounds\kick3.mp3"
  File "..\source\exec\sounds\stop0.mp3"
  File "..\source\exec\sounds\stop1.mp3"
  File "..\source\exec\sounds\throw0.mp3"
  File "..\source\exec\sounds\throw1.mp3"
  File "..\source\exec\sounds\throw2.mp3"
  File "..\source\exec\sounds\throw3.mp3"
  SetOutPath "$INSTDIR\textures"
  File "..\source\exec\textures\back.jpg"
  File "..\source\exec\textures\charset0.jpg"
  File "..\source\exec\textures\charset0x.jpg"
  File "..\source\exec\textures\charset1.jpg"
  File "..\source\exec\textures\cross.jpg"
  File "..\source\exec\textures\mainbt0.jpg"
  File "..\source\exec\textures\mainbt1.jpg"
  File "..\source\exec\textures\mainbt2.jpg"
  File "..\source\exec\textures\mainbt3.jpg"
  File "..\source\exec\textures\mainbt4.jpg"
  File "..\source\exec\textures\mainbt5.jpg"
  File "..\source\exec\textures\mask.bmp"
  SetOutPath "$INSTDIR"
  File "..\source\exec\fmod.dll"
  File "..\source\exec\glut.dll"
  File "..\source\exec\glut.lib"
  File "..\source\exec\glut32.dll"
  File "..\source\exec\glut32.lib"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Atominsa.lnk" "$INSTDIR\atominsa.exe"
  CreateShortCut "$DESKTOP\Atominsa.lnk" "$INSTDIR\atominsa.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\atominsa.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\atominsa.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) a �t� d�sinstall� avec succ�s de votre ordinateur."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "�tes-vous certains de vouloir d�sinstaller totalement $(^Name) et tous ses composants ?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\textures\mask.bmp"
  Delete "$INSTDIR\textures\mainbt5.jpg"
  Delete "$INSTDIR\textures\mainbt4.jpg"
  Delete "$INSTDIR\textures\mainbt3.jpg"
  Delete "$INSTDIR\textures\mainbt2.jpg"
  Delete "$INSTDIR\textures\mainbt1.jpg"
  Delete "$INSTDIR\textures\mainbt0.jpg"
  Delete "$INSTDIR\textures\cross.jpg"
  Delete "$INSTDIR\textures\charset1.jpg"
  Delete "$INSTDIR\textures\charset0x.jpg"
  Delete "$INSTDIR\textures\charset0.jpg"
  Delete "$INSTDIR\textures\back.jpg"
  Delete "$INSTDIR\sounds\back.mp3"
  Delete "$INSTDIR\sounds\click.mp3"
  Delete "$INSTDIR\sounds\message.mp3"
  Delete "$INSTDIR\sounds\move.mp3"
  Delete "$INSTDIR\sounds\select.mp3"
  Delete "$INSTDIR\sounds\speech0.mp3"
  Delete "$INSTDIR\sounds\speech1.mp3"
  Delete "$INSTDIR\sounds\speech2.mp3"
  Delete "$INSTDIR\sounds\speech3.mp3"
  Delete "$INSTDIR\sounds\speech4.mp3"
  Delete "$INSTDIR\sounds\speech5.mp3"
  Delete "$INSTDIR\sounds\speech6.mp3"
  Delete "$INSTDIR\sounds\speech7.mp3"
  Delete "$INSTDIR\sounds\speech8.mp3"
  Delete "$INSTDIR\sounds\speech9.mp3"
  Delete "$INSTDIR\sounds\speech10.mp3"
  Delete "$INSTDIR\sounds\speech11.mp3"
  Delete "$INSTDIR\sounds\speech12.mp3"
  Delete "$INSTDIR\sounds\speech13.mp3"
  Delete "$INSTDIR\sounds\speech14.mp3"
  Delete "$INSTDIR\sounds\speech15.mp3"
  Delete "$INSTDIR\sounds\speech16.mp3"
  Delete "$INSTDIR\sounds\speech17.mp3"
  Delete "$INSTDIR\sounds\speech18.mp3"
  Delete "$INSTDIR\sounds\speech19.mp3"
  Delete "$INSTDIR\sounds\speech20.mp3"
  Delete "$INSTDIR\sounds\speech21.mp3"
  Delete "$INSTDIR\sounds\speech22.mp3"
  Delete "$INSTDIR\sounds\speech23.mp3"
  Delete "$INSTDIR\sounds\speech24.mp3"
  Delete "$INSTDIR\sounds\speech25.mp3"
  Delete "$INSTDIR\sounds\speech26.mp3"
  Delete "$INSTDIR\sounds\speech27.mp3"
  Delete "$INSTDIR\sounds\speech28.mp3"
  Delete "$INSTDIR\sounds\speech29.mp3"
  Delete "$INSTDIR\sounds\speech30.mp3"
  Delete "$INSTDIR\sounds\speech31.mp3"
  Delete "$INSTDIR\sounds\speech32.mp3"
  Delete "$INSTDIR\sounds\speech33.mp3"
  Delete "$INSTDIR\sounds\speech34.mp3"
  Delete "$INSTDIR\sounds\speech35.mp3"
  Delete "$INSTDIR\sounds\speech36.mp3"
  Delete "$INSTDIR\sounds\speech37.mp3"
  Delete "$INSTDIR\sounds\speech38.mp3"
  Delete "$INSTDIR\sounds\speech39.mp3"
  Delete "$INSTDIR\sounds\speech40.mp3"
  Delete "$INSTDIR\sounds\speech41.mp3"
  Delete "$INSTDIR\sounds\speech42.mp3"
  Delete "$INSTDIR\sounds\speech43.mp3"
  Delete "$INSTDIR\sounds\speech44.mp3"
  Delete "$INSTDIR\sounds\speech45.mp3"
  Delete "$INSTDIR\sounds\speech46.mp3"
  Delete "$INSTDIR\sounds\speech47.mp3"
  Delete "$INSTDIR\sounds\speech48.mp3"
  Delete "$INSTDIR\sounds\speech49.mp3"
  Delete "$INSTDIR\sounds\speech50.mp3"
  Delete "$INSTDIR\sounds\speech51.mp3"
  Delete "$INSTDIR\sounds\speech52.mp3"
  Delete "$INSTDIR\sounds\speech53.mp3"
  Delete "$INSTDIR\sounds\speech54.mp3"
  Delete "$INSTDIR\sounds\speech55.mp3"
  Delete "$INSTDIR\sounds\speech56.mp3"
  Delete "$INSTDIR\sounds\speech57.mp3"
  Delete "$INSTDIR\sounds\speech58.mp3"
  Delete "$INSTDIR\sounds\speech59.mp3"
  Delete "$INSTDIR\sounds\speech60.mp3"
  Delete "$INSTDIR\sounds\speech61.mp3"
  Delete "$INSTDIR\sounds\speech62.mp3"
  Delete "$INSTDIR\sounds\speech63.mp3"
  Delete "$INSTDIR\sounds\speech64.mp3"
  Delete "$INSTDIR\sounds\speech65.mp3"
  Delete "$INSTDIR\sounds\speech66.mp3"
  Delete "$INSTDIR\sounds\speech67.mp3"
  Delete "$INSTDIR\sounds\speech68.mp3"
  Delete "$INSTDIR\sounds\speech69.mp3"
  Delete "$INSTDIR\sounds\speech70.mp3"
  Delete "$INSTDIR\sounds\speech71.mp3"
  Delete "$INSTDIR\sounds\speech72.mp3"
  Delete "$INSTDIR\sounds\speech73.mp3"
  Delete "$INSTDIR\sounds\speech74.mp3"
  Delete "$INSTDIR\sounds\speech75.mp3"
  Delete "$INSTDIR\sounds\speech76.mp3"
  Delete "$INSTDIR\sounds\speech77.mp3"
  Delete "$INSTDIR\sounds\speech78.mp3"
  Delete "$INSTDIR\sounds\speech79.mp3"
  Delete "$INSTDIR\sounds\speech80.mp3"
  Delete "$INSTDIR\sounds\speech81.mp3"
  Delete "$INSTDIR\sounds\speech82.mp3"
  Delete "$INSTDIR\sounds\speech83.mp3"
  Delete "$INSTDIR\sounds\speech84.mp3"
  Delete "$INSTDIR\sounds\speech85.mp3"
  Delete "$INSTDIR\sounds\speech86.mp3"
  Delete "$INSTDIR\sounds\bomb0.mp3"
  Delete "$INSTDIR\sounds\bomb1.mp3"
  Delete "$INSTDIR\sounds\bomb2.mp3"
  Delete "$INSTDIR\sounds\bomb3.mp3"
  Delete "$INSTDIR\sounds\bomb4.mp3"
  Delete "$INSTDIR\sounds\bomb5.mp3"
  Delete "$INSTDIR\sounds\bomb6.mp3"
  Delete "$INSTDIR\sounds\bomb7.mp3"
  Delete "$INSTDIR\sounds\bomb8.mp3"
  Delete "$INSTDIR\sounds\bomb9.mp3"
  Delete "$INSTDIR\sounds\bomb10.mp3"
  Delete "$INSTDIR\sounds\bomb11.mp3"
  Delete "$INSTDIR\sounds\bomb12.mp3"
  Delete "$INSTDIR\sounds\bomb13.mp3"
  Delete "$INSTDIR\sounds\bomb14.mp3"
  Delete "$INSTDIR\sounds\bomb15.mp3"
  Delete "$INSTDIR\sounds\bomb16.mp3"
  Delete "$INSTDIR\sounds\bomb17.mp3"
  Delete "$INSTDIR\sounds\bomb18.mp3"
  Delete "$INSTDIR\sounds\bomb19.mp3"
  Delete "$INSTDIR\sounds\bomb20.mp3"
  Delete "$INSTDIR\sounds\bomb21.mp3"
  Delete "$INSTDIR\sounds\bomb22.mp3"
  Delete "$INSTDIR\sounds\bomb23.mp3"
  Delete "$INSTDIR\sounds\bomb24.mp3"
  Delete "$INSTDIR\sounds\bomb25.mp3"
  Delete "$INSTDIR\sounds\bomb26.mp3"
  Delete "$INSTDIR\sounds\bomb27.mp3"
  Delete "$INSTDIR\sounds\bomb28.mp3"
  Delete "$INSTDIR\sounds\bomb29.mp3"
  Delete "$INSTDIR\sounds\bonus0.mp3"
  Delete "$INSTDIR\sounds\bonus1.mp3"
  Delete "$INSTDIR\sounds\bonus2.mp3"
  Delete "$INSTDIR\sounds\bonus3.mp3"
  Delete "$INSTDIR\sounds\bounce0.mp3"
  Delete "$INSTDIR\sounds\bounce1.mp3"
  Delete "$INSTDIR\sounds\die0.mp3"
  Delete "$INSTDIR\sounds\die1.mp3"
  Delete "$INSTDIR\sounds\disease0.mp3"
  Delete "$INSTDIR\sounds\disease1.mp3"
  Delete "$INSTDIR\sounds\disease2.mp3"
  Delete "$INSTDIR\sounds\disease3.mp3"
  Delete "$INSTDIR\sounds\disease4.mp3"
  Delete "$INSTDIR\sounds\disease5.mp3"
  Delete "$INSTDIR\sounds\disease6.mp3"
  Delete "$INSTDIR\sounds\disease7.mp3"
  Delete "$INSTDIR\sounds\drop0.mp3"
  Delete "$INSTDIR\sounds\drop1.mp3"
  Delete "$INSTDIR\sounds\drop2.mp3"
  Delete "$INSTDIR\sounds\grab0.mp3"
  Delete "$INSTDIR\sounds\grab1.mp3"
  Delete "$INSTDIR\sounds\kick0.mp3"
  Delete "$INSTDIR\sounds\kick1.mp3"
  Delete "$INSTDIR\sounds\kick2.mp3"
  Delete "$INSTDIR\sounds\kick3.mp3"
  Delete "$INSTDIR\sounds\stop0.mp3"
  Delete "$INSTDIR\sounds\stop1.mp3"
  Delete "$INSTDIR\sounds\throw0.mp3"
  Delete "$INSTDIR\sounds\throw1.mp3"
  Delete "$INSTDIR\sounds\throw2.mp3"
  Delete "$INSTDIR\sounds\throw3.mp3"
  Delete "$INSTDIR\shaders\bomb4.ps"
  Delete "$INSTDIR\shaders\bomb3.ps"
  Delete "$INSTDIR\shaders\bomb2.ps"
  Delete "$INSTDIR\shaders\bomb.vs"
  Delete "$INSTDIR\schemes\X.SCH"
  Delete "$INSTDIR\schemes\WALLYBOM.SCH"
  Delete "$INSTDIR\schemes\VOLLEY.SCH"
  Delete "$INSTDIR\schemes\UTURN.SCH"
  Delete "$INSTDIR\schemes\TOILET.SCH"
  Delete "$INSTDIR\schemes\TIGHT.SCH"
  Delete "$INSTDIR\schemes\THISTHAT.SCH"
  Delete "$INSTDIR\schemes\THE_RIM.SCH"
  Delete "$INSTDIR\schemes\THATTHIS.SCH"
  Delete "$INSTDIR\schemes\TENNIS.SCH"
  Delete "$INSTDIR\schemes\SPREAD.SCH"
  Delete "$INSTDIR\schemes\SPIRAL.SCH"
  Delete "$INSTDIR\schemes\R_GARDEN.SCH"
  Delete "$INSTDIR\schemes\ROOMMATE.SCH"
  Delete "$INSTDIR\schemes\RAILROAD.SCH"
  Delete "$INSTDIR\schemes\RAIL1.SCH"
  Delete "$INSTDIR\schemes\RACER1.SCH"
  Delete "$INSTDIR\schemes\PURIST.SCH"
  Delete "$INSTDIR\schemes\PINGPONG.SCH"
  Delete "$INSTDIR\schemes\PATTERN.SCH"
  Delete "$INSTDIR\schemes\OG.SCH"
  Delete "$INSTDIR\schemes\OBSTACLE.SCH"
  Delete "$INSTDIR\schemes\N_VS_S.SCH"
  Delete "$INSTDIR\schemes\NEIL.SCH"
  Delete "$INSTDIR\schemes\NEIGHBOR.SCH"
  Delete "$INSTDIR\schemes\LEAK.SCH"
  Delete "$INSTDIR\schemes\JAIL.SCH"
  Delete "$INSTDIR\schemes\HAPPY.SCH"
  Delete "$INSTDIR\schemes\GRIDLOCK.SCH"
  Delete "$INSTDIR\schemes\FREEWAY.SCH"
  Delete "$INSTDIR\schemes\FORT.SCH"
  Delete "$INSTDIR\schemes\FARGO.SCH"
  Delete "$INSTDIR\schemes\FAIR.SCH"
  Delete "$INSTDIR\schemes\E_VS_W.SCH"
  Delete "$INSTDIR\schemes\DOME.SCH"
  Delete "$INSTDIR\schemes\DOGRACE.SCH"
  Delete "$INSTDIR\schemes\DIAMOND.SCH"
  Delete "$INSTDIR\schemes\DEADEND.SCH"
  Delete "$INSTDIR\schemes\CUTTHROT.SCH"
  Delete "$INSTDIR\schemes\CUTTER.SCH"
  Delete "$INSTDIR\schemes\CUBIC.SCH"
  Delete "$INSTDIR\schemes\CONFUSED.SCH"
  Delete "$INSTDIR\schemes\CLEARING.SCH"
  Delete "$INSTDIR\schemes\CLEAR.SCH"
  Delete "$INSTDIR\schemes\CHICANE.SCH"
  Delete "$INSTDIR\schemes\CHECKERS.SCH"
  Delete "$INSTDIR\schemes\CHASE.SCH"
  Delete "$INSTDIR\schemes\CHAIN.SCH"
  Delete "$INSTDIR\schemes\CASTLE2.SCH"
  Delete "$INSTDIR\schemes\CASTLE.SCH"
  Delete "$INSTDIR\schemes\BUNCH.SCH"
  Delete "$INSTDIR\schemes\BREAKOUT.SCH"
  Delete "$INSTDIR\schemes\BOXED.SCH"
  Delete "$INSTDIR\schemes\BOWLING.SCH"
  Delete "$INSTDIR\schemes\BORDER.SCH"
  Delete "$INSTDIR\schemes\BMAN93.SCH"
  Delete "$INSTDIR\schemes\BASICSML.SCH"
  Delete "$INSTDIR\schemes\BASIC.SCH"
  Delete "$INSTDIR\schemes\BACK2.SCH"
  Delete "$INSTDIR\schemes\BACK.SCH"
  Delete "$INSTDIR\schemes\ASYLUM.SCH"
  Delete "$INSTDIR\schemes\ANTFARM.SCH"
  Delete "$INSTDIR\schemes\ALLEYS2.SCH"
  Delete "$INSTDIR\schemes\ALLEYS.SCH"
  Delete "$INSTDIR\schemes\AIRMAIL.SCH"
  Delete "$INSTDIR\schemes\AIRCHAOS.SCH"
  Delete "$INSTDIR\schemes\4CORNERS.SCH"
  Delete "$INSTDIR\musics\menu.mp3"
  Delete "$INSTDIR\musics\game0.mp3"
  Delete "$INSTDIR\musics\game1.mp3"
  Delete "$INSTDIR\musics\game2.mp3"
  Delete "$INSTDIR\musics\game3.mp3"
  Delete "$INSTDIR\meshes\speedup.m12"
  Delete "$INSTDIR\meshes\flameup.m12"
  Delete "$INSTDIR\meshes\extrabomb.m12"
  Delete "$INSTDIR\meshes\disease.m12"
  Delete "$INSTDIR\meshes\bomb.m12"
  Delete "$INSTDIR\maps\sunset.map"
  Delete "$INSTDIR\maps\sunset\solid.m12"
  Delete "$INSTDIR\maps\sunset\solid.jpg"
  Delete "$INSTDIR\maps\sunset\sb-top.jpg"
  Delete "$INSTDIR\maps\sunset\sb-right.jpg"
  Delete "$INSTDIR\maps\sunset\sb-left.jpg"
  Delete "$INSTDIR\maps\sunset\sb-front.jpg"
  Delete "$INSTDIR\maps\sunset\sb-bottom.jpg"
  Delete "$INSTDIR\maps\sunset\sb-back.jpg"
  Delete "$INSTDIR\maps\sunset\plane.m12"
  Delete "$INSTDIR\maps\sunset\plane.jpg"
  Delete "$INSTDIR\maps\sunset\brick.m12"
  Delete "$INSTDIR\maps\sunset\brick.jpg"
  Delete "$INSTDIR\maps\night.map"
  Delete "$INSTDIR\maps\night\solid.m12"
  Delete "$INSTDIR\maps\night\solid.jpg"
  Delete "$INSTDIR\maps\night\sb-top.jpg"
  Delete "$INSTDIR\maps\night\sb-right.jpg"
  Delete "$INSTDIR\maps\night\sb-left.jpg"
  Delete "$INSTDIR\maps\night\sb-front.jpg"
  Delete "$INSTDIR\maps\night\sb-bottom.jpg"
  Delete "$INSTDIR\maps\night\sb-back.jpg"
  Delete "$INSTDIR\maps\night\plane.m12"
  Delete "$INSTDIR\maps\night\plane.jpg"
  Delete "$INSTDIR\maps\night\brick.m12"
  Delete "$INSTDIR\maps\night\brick.jpg"
  Delete "$INSTDIR\glut32.lib"
  Delete "$INSTDIR\glut32.dll"
  Delete "$INSTDIR\glut.lib"
  Delete "$INSTDIR\glut.dll"
  Delete "$INSTDIR\fmod.dll"
  Delete "$INSTDIR\characters\bomberman.chr"
  Delete "$INSTDIR\characters\bomberman\flame.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman7.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman6.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman5.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman4.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman3.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman2.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman1.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman0.jpg"
  Delete "$INSTDIR\characters\bomberman\bomberman.m12"
  Delete "$INSTDIR\characters\bomberman\bomberman.a12"
  Delete "$INSTDIR\characters\bomberman\bomb.m12"
  Delete "$INSTDIR\characters\bomberman\bomb.jpg"
  Delete "$INSTDIR\readme.txt"
  Delete "$INSTDIR\atominsa.exe"
  Delete "$INSTDIR\atominsa.cfg"

  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
  Delete "$DESKTOP\Atominsa.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Atominsa.lnk"

  RMDir "$SMPROGRAMS\$ICONS_GROUP"
  RMDir "$INSTDIR\textures"
  RMDir "$INSTDIR\sounds"
  RMDir "$INSTDIR\shaders"
  RMDir "$INSTDIR\schemes"
  RMDir "$INSTDIR\musics"
  RMDir "$INSTDIR\meshes"
  RMDir "$INSTDIR\maps\sunset"
  RMDir "$INSTDIR\maps\night"
  RMDir "$INSTDIR\maps"
  RMDir "$INSTDIR\characters\bomberman"
  RMDir "$INSTDIR\characters"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd