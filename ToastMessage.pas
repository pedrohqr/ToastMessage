unit ToastMessage;

// Author : Pedro Henrique Ramos
// 14/03/2022

{To use, declare a object TToastMessage in your form. Call from "Activate"
with your title message and content, if necessary, the duration of message in
miliseconds. On finish of animation, the object will be destroyed. The content
height is calc auto}

interface

uses
  FMX.Objects;

type
  TToastMessage = class
  private
    procedure OnFinishAni(Sender: TObject);
    procedure Desactivate;
  public
    procedure Activate(ATitle, AText : String; ADuration : Integer = 2000);
  end;

implementation

uses
  FMX.Forms, FMX.Types, FMX.Graphics, System.SysUtils, FMX.Ani, System.UITypes,
  FMX.StdCtrls, System.Classes;

var
  Rec_Main   : TRectangle;
  Ani        : TFloatAnimation;
  lbl_header : TLabel;
  lbl_text   : TLabel;

{ TToastMessage }

procedure TToastMessage.Activate(ATitle, AText: String; ADuration : Integer);
var
  RecHeight : Single;
begin
  RecHeight := 100;//min height of rectangle
  if not Assigned(Rec_Main) then
    Rec_Main := TRectangle.Create(Screen.ActiveForm);
  with Rec_Main do
  begin
    Parent      := Screen.ActiveForm;
    Align       := TAlignLayout.None;
//    Anchors := [TAnchorKind.akTop];
    if Assigned(Screen.ActiveForm.FindComponent('recTop') as TRectangle) then
      Fill.Color  := (Screen.ActiveForm.FindComponent('recTop') as TRectangle).Fill.Color
    else
      Fill.Color  := $FFFF8746;
    Height      := RecHeight;
    Width       := Screen.ActiveForm.Width;
    Position.X  := 0;
    Position.Y  := Screen.ActiveForm.Height-Rec_Main.Height;
    Stroke.Kind := TBrushKind.None;
    XRadius     := 10;
    YRadius     := 10;
    Corners     := [TCorner.TopLeft, TCorner.TopRight];
    BringToFront;
  end;

  //if not Assigned(lbl_header) then
    lbl_header := TLabel.Create(Rec_Main);
  with lbl_header do
  begin
    Text := ATitle;
    Parent := Rec_Main;
    StyledSettings := StyledSettings-[TStyledSetting.Size];
    Align := TAlignLayout.MostTop;
//    AutoSize := True;
    Height := 13;
    Margins.Top := 3;
    Margins.Right := 5;
    Margins.Left := 5;
    Font.Size := 15;
  end;

  //if not Assigned(lbl_text) then
    lbl_text := TLabel.Create(Rec_Main);
  with lbl_text do
  begin
    Parent := Rec_Main;
    Text := AText;
    StyledSettings := StyledSettings-[TStyledSetting.Size];
    Align := TAlignLayout.Top;
    //Height := Screen.ActiveForm.Height;
    Margins.Top := 5;
    Margins.Right := 5;
    Margins.Left := 5;
    Font.Size := 12;
    TextSettings.VertAlign := TTextAlign.Leading;
    TextSettings.HorzAlign := TTextAlign.Leading;
    AutoSize := True;
  end;

  //calc sum of height after create all components
  RecHeight := lbl_header.Height+
               lbl_header.Margins.Top+
               lbl_header.Margins.Bottom+
               lbl_text.Height+
               lbl_text.Margins.Top+
               lbl_text.Margins.Bottom;
  Rec_Main.Height := RecHeight;
  //end calc

  //if not Assigned(Ani) then
    Ani := TFloatAnimation.Create(Rec_Main);
  with ani do
  begin
    Parent        := Rec_Main;
    AnimationType := TAnimationType.Out;
    Duration      := 1;
    Interpolation := TInterpolationType.Circular;
    Loop          := False;
    PropertyName  := 'Position.Y';
    StartValue    := Screen.ActiveForm.Height;
    StopValue     := Screen.ActiveForm.Height-RecHeight;
    Enabled       := True;
  end;

  TThread.CreateAnonymousThread(procedure
  begin
    Sleep(ADuration);
    TThread.Synchronize(nil, procedure
    begin
      Desactivate;
    end);
  end).Start;
end;

procedure TToastMessage.OnFinishAni(Sender : TObject);
begin
  if Assigned(Rec_Main) then
    FreeAndNil(Rec_Main);
end;

procedure TToastMessage.Desactivate;
begin
  //if Assigned(Ani) then
  with Ani do
  begin
    OnFinish := OnFinishAni;
    Inverse  := True;
    Start;
  end;
end;

end.
