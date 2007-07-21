unit uAI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  UBomberman, UUtils;


  procedure InitComputer(pBomberman : CBomberman);
  procedure ProcessComputer(pBomberman : CBomberman);
  
implementation


Const PRIORITY_MAX    = 100;
      PRIORITY_MEDIUM = 0;
      PRIORITY_MIN    = -100;
      
      
      
      



type  LPPropertyCPU = ^TPropertyCPU;
      TPropertyCPU = record
                    Index,                  // numero d'identification du bomberman
                    MinBombtime,
                    OperatingRange,
                    Priority          : integer;
                    CanEnvisageMove,       // peut-il prevoir en fonction du temps restant avant l'explosion d'une bombe et de sa position s'il à le temps de traverser la case ?
                    CanDetectTrigger,
                    CanAnalyseBomb    : boolean;
                    Next : LPPropertyCPU;
                  end;


var PropertyCPUItem    : LPPropertyCPU = Nil;
    MinBombTime,
    OperatingRange,
    Priority           : integer;
    CanEnvisageMove,
    CanDetectTrigger,
    CanAnalyseBomb     : boolean;
    
    
    
    
    
    
    
    
    

procedure AddItem(aIndex : integer);
var pTemp : LPPropertyCPU;
begin
  pTemp := PropertyCPUItem;
  New(PropertyCPUItem);
  PropertyCPUItem^.Index := aIndex;
  PropertyCPUItem^.Next := pTemp;
end;

procedure FreeItem();
var pTemp : LPPropertyCPU;
begin
  pTemp := PropertyCPUItem;
  if Not(pTemp=Nil) then
  begin
    PropertyCPUItem := PropertyCPUItem^.Next;
    Dispose(pTemp);
    FreeItem();
  end;
end;










procedure LoadProperty(aIndex : integer);
var pTemp : LPPropertyCPU;
    Find : boolean;
begin
  pTemp := PropertyCPUItem;
  Find  := (pTemp^.Index=aIndex);
  While Not(Find) do
  begin
    pTemp := pTemp^.Next;
    Find  := (pTemp^.Index=aIndex);
  end;
  
  MinBombTime      := pTemp^.MinBombTime;
  OperatingRange   := pTemp^.OperatingRange;
  Priority         := pTemp^.Priority;
  CanEnvisageMove  := pTemp^.CanEnvisageMove;
  CanDetectTrigger := pTemp^.CanDetectTrigger;
  CanAnalyseBomb   := pTemp^.CanAnalyseBomb;
end;


procedure SaveProperty(aIndex : integer);
var pTemp : LPPropertyCPU;
    Find : boolean;
begin
  pTemp := PropertyCPUItem;
  Find  := (pTemp^.Index=aIndex);
  While Not(Find) do
  begin
    pTemp := pTemp^.Next;
    Find  := (pTemp^.Index=aIndex);
  end;

  pTemp^.MinBombTime      := MinBombTime;
  pTemp^.OperatingRange   := OperatingRange;
  pTemp^.Priority         := Priority;
  pTemp^.CanEnvisageMove  := CanEnvisageMove;
  pTemp^.CanDetectTrigger := CanDetectTrigger;
  pTemp^.CanAnalyseBomb   := CanAnalyseBomb;
end;






procedure InitNoviceSkill();
begin
  CanAnalyseBomb   := false;
  CanEnvisageMove  := false;
  CanDetectTrigger := false;

  MinBombTime      := 10;
  OperatingRange   := 1;
  Priority         := PRIORITY_MIN;
end;

procedure InitAverageSkill();
begin
  CanAnalyseBomb   := true;
  CanEnvisageMove  := false;
  CanDetectTrigger := false;

  MinBombTime      := 2;
  OperatingRange   := 2;
  Priority         := PRIORITY_MIN;
end;

procedure InitMasterFulSkill();
begin
  CanAnalyseBomb   := true;
  CanEnvisageMove  := true;
  CanDetectTrigger := true;
  
  MinBombTime      := 3;
  OperatingRange   := 3;
  Priority         := PRIORITY_MIN;
end;

procedure InitGodLikeSkill();
begin
  CanAnalyseBomb    := true;
  CanEnvisageMove   := true;
  CanDetectTrigger  := true;

  MinBombTime       := 3;
  OperatingRange    := 4;
  Priority          := PRIORITY_MIN;
end;

procedure InitComputer(pBomberman: CBomberman);
begin
  case pBomberman.AISkill of
    SKILL_NOVICE     : InitNoviceSkill();
    SKILL_AVERAGE    : InitAverageSkill();
    SKILL_MASTERFUL  : InitMasterFulSkill();
    SKILL_GODLIKE    : InitGodLikeSkill();
  end;
  
  AddItem(pBomberman.BIndex);
  SaveProperty(pBomberman.BIndex);
end;









procedure ProcessComputer(pBomberman: CBomberman);
begin
  LoadProperty(pBomberman.BIndex);
end;

end.

