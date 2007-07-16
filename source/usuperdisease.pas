unit USuperDisease;

{$mode objfpc}{$H+}

interface

uses
    UCore, UBomberman, UDisease, uUtils, UItem;


type

    { CSuperDisease }

    CSuperDisease = class(CItem)
      public
        Procedure Bonus ( _uPlayer : CBomberman );override;
    end;
implementation

{ CSuperDisease }


procedure CSuperDisease.Bonus(_uPlayer: CBomberman);
var i,j,k : integer;
    aDisease : CDisease;
begin
  if _uPlayer.DiseaseNumber=0 then
  begin
      SetString( STRING_NOTIFICATION, _uPlayer.Name + ' has picked up a super disease.', 0.0, 0.2, 5 );
      repeat
         i := Random(DISEASECOUNT)+1;
      until (i<>DISEASE_SWITCH);
      Repeat
         j := Random(DISEASECOUNT)+1;
      until (j<>i) and (j<>DISEASE_SWITCH);
      repeat
         k := Random(DISEASECOUNT)+1;
      until (k<>i) and (k<>j) and (k<>DISEASE_SWITCH);

      aDisease := CDisease.Create(0,0);
      aDisease.BonusForced(_uPlayer,i);
      aDisease := CDisease.Create(0,0);
      aDisease.BonusForced(_uPlayer,j);
      aDisease := CDisease.Create(0,0);
      aDisease.BonusForced(_uPlayer,k);
  end;
  Destroy();
end;

end.

