unit TAGEdit;

interface

uses
  LResources, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TTAGEditForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    TAGMemo: TMemo;
    TAGName: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{var
  TAGEditForm: TTAGEditForm; }

implementation

procedure TTAGEditForm.btnOKClick(Sender: TObject);
begin
   ModalResult := mrOK;
end;

procedure TTAGEditForm.btnCancelClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

initialization
{$I TAGEdit.lrs}

end.
