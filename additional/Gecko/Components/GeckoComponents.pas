{ This file was automatically created by Lazarus. do not edit!
  This source is only used to compile and install the package.
 }

unit GeckoComponents; 

interface

uses
  GeckoBrowser, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('GeckoBrowser', @GeckoBrowser.Register); 
end; 

initialization
  RegisterPackage('GeckoComponents', @Register); 
end.
