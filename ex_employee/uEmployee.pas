unit uEmployee;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TEmployee = class
  public
    FirstName: string;
    LastName: string;
    FullName: string;
    BirthDate: string;
    Address: string;
    City: string;
    State: string;
    ZipCode: string;
    HomePhone: string;
    MobilePhone: string;
    Email: string;
    Title: string;
    Prefix: string;
    Department: string;
    HireDate: string;
    Status: string;
    constructor Create(AFName, ALName, ATitle, AEmail, ABirth, AAddr, ACity, AState, AZip, AHome, AMobile, ADept, AHire, AStatus, APrefix: string);
  end;

implementation

constructor TEmployee.Create(AFName, ALName, ATitle, AEmail, ABirth, AAddr, ACity, AState, AZip, AHome, AMobile, ADept, AHire, AStatus, APrefix: string);
begin
  FirstName := AFName;
  LastName := ALName;
  FullName := AFName + ' ' + ALName;
  Title := ATitle;
  Email := AEmail;
  BirthDate := ABirth;
  Address := AAddr;
  City := ACity;
  State := AState;
  ZipCode := AZip;
  HomePhone := AHome;
  MobilePhone := AMobile;
  Department := ADept;
  HireDate := AHire;
  Status := AStatus;
  Prefix := APrefix;
end;

end.
