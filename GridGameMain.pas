unit GridGameMain;

// TODO: Top scores (also count misclicks)
// TODO: Remember grid size for next session
// TODO: Music and Sound Effects

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.ExtCtrls;

const
  MinGridSize = 2;
  MaxGridSize = 14; // 14 Max because King has value 13

type
  TCardSuit = (csUp, csDown, csLeft, csRight);

  TGameStat = record
    Initialized: boolean;
    GridSize: integer;
    StartTime: TDateTime;
    FinishTime: TDateTime;
    StepsStart: integer;
    StepsRemaining: integer;
    MisClicks: integer;
  end;
  PGameStat = ^TGameStat;

  TCard = record
    isJoker: boolean;
    number: integer; //1=A, 2..10, 11=J, 12=Q, 13=K
    suit: TCardSuit;
    isFaceDown: boolean;
    tag: integer;
    btn: TBitBtn;
  end;
  PCard = ^TCard;

  TDeck = array[0..1{Joker}+13*4-1] of TCard;
  PDeck = ^TDeck;

  TGrid = array[0..MaxGridSize-1, 0..MaxGridSize-1] of TCard;
  PGrid = ^TGrid;

  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    SpinEdit1: TSpinEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Timer1: TTimer;
    Timer2: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    Fdeck: TDeck;
    Fgrid: TGrid;
    stat: TGameStat;
    procedure DrawGameStat;
    procedure CardClick(Sender: TObject);
    procedure LaycardsToGrid_BA(AStats: PGameStat; ADeck: PDeck; AGrid: PGrid);
    procedure DrawGridToScreen_BA_Print(AGrid: PGrid; AMemo: TMemo);
    procedure CardButtonDraw(ACard: PCard);
    procedure DrawGridToScreen_BA_Interactive(AGrid: PGrid; AParent: TWinControl);
    procedure RegisterMisclick;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure InitDeck(var ADeck: TDeck);
var
  i: integer;
begin
  for i := 0 to Length(ADeck)-1 do
  begin
    ADeck[i].isJoker := i = 0;
    ADeck[i].tag := 0;
    ADeck[i].isFaceDown := false;
    if i >= 1 then
    begin
      ADeck[i].suit := TCardSuit((i-1) mod 4);
      ADeck[i].number := 1+((i-1) div 4);
    end;
  end;
end;

procedure TForm1.LaycardsToGrid_BA(AStats: PGameStat; ADeck: PDeck; AGrid: PGrid);
var
  x, y: integer;
  initx, inity: integer;
  curx, cury: integer;
  nextx, nexty: integer;
  di: integer;
  crit: integer;
  dist: integer;
  pathLength: integer;
begin
  // 1. Put all cards facedown
  for y := 0 to stat.GridSize-1 do
  begin
    for x := 0 to stat.GridSize-1 do
    begin
      AGrid[x, y].isFaceDown := true;
    end;
  end;

  // 2. Search a random first card
  initx := Random(stat.GridSize);
  inity := Random(stat.GridSize);
  AGrid[initx, inity].isJoker := true;
  AGrid[initx, inity].isFaceDown := false;

  curx := initx;
  cury := inity;

  nextx := 0;
  nexty := 0;
  dist := 0;

  // 3. Make a path through the grid
  pathLength := 0;
  for di := 0 to 10000 do
  begin
    crit := 0;
    repeat
      Inc(crit);
      case Random(2) of
        0:
        begin
          repeat
            nextx := Random(stat.GridSize);
          until nextx <> curx;
          dist := Abs(nextx - curx);
          nexty := cury;
        end;

        1:
        begin
          nextx := curx;
          repeat
            nexty := Random(stat.GridSize);
          until nexty <> cury;
          dist := Abs(nexty - cury);
        end;
      end;
    until AGrid[nextx, nexty].isFaceDown or (crit > 1000);

    if crit > 1000 then break;

    AGrid[nextx, nexty].isJoker := false;
    AGrid[nextx, nexty].isFaceDown := false;
    if nextx > curx then
      AGrid[nextx, nexty].suit := csRight
    else if nextx < curx then
      AGrid[nextx, nexty].suit := csLeft
    else if nexty > cury then
      AGrid[nextx, nexty].suit := csDown
    else
      AGrid[nextx, nexty].suit := csUp;
    AGrid[nextx, nexty].number := dist;
    Inc(pathLength);

    curx := nextx;
    cury := nexty;
  end;

  // 4. Fill unused spots with junk
  for y := 0 to stat.GridSize-1 do
  begin
    for x := 0 to stat.GridSize-1 do
    begin
      if AGrid[x, y].isFaceDown then
      begin
        AGrid[x, y].isJoker := false;
        AGrid[x, y].isFaceDown := false;
        AGrid[x, y].suit := TCardSuit(Random(4));
        AGrid[x, y].number := Random(stat.GridSize-1)+1;
      end;
    end;
  end;

  AStats.StepsStart := pathLength;
  AStats.StepsRemaining := pathLength;
end;

procedure TForm1.RegisterMisclick;
begin
  Inc(stat.MisClicks);
  DrawGameStat;
  Beep;
end;

function CardName(ACard: TCard): string;
begin
  if Acard.isFaceDown then
  begin
    result := '???';
  end
  else if Acard.isJoker then
  begin
    result := 'Jkr';
  end
  else
  begin
    result := '';
    if ACard.suit = csUp then
      result := '♣'
    else if ACard.suit = csDown then
      result := '♠'
    else if ACard.suit = csLeft then
      result := '♥'
    else if ACard.suit = csRight then
      result := '♦';

    if ACard.number = 1 then
      result := result + ' A'
    else if ACard.number = 13 then
      result := result + ' K'
    else if ACard.number = 12 then
      result := result + ' Q'
    else if ACard.number = 11 then
      result := result + ' J'
    else if ACard.number = 10 then
      result := result + '10'
    else
      result := result + ' ' + IntToStr(ACard.number);
  end;
end;

function StrRepeat(str: string; count: integer): string;
var
  i: integer;
begin
  result := '';
  for i := 0 to count-1 do
    result := result + str;
end;

procedure TForm1.DrawGridToScreen_BA_Print(AGrid: PGrid; AMemo: TMemo);
var
  x, y: integer;
  card: TCard;
  s: string;
  linelength: integer;
begin
  AMemo.Clear;
  linelength := 0;
  for y := 0 to stat.GridSize-1 do
  begin
    s := '';
    for x := 0 to stat.GridSize-1 do
    begin
      card := AGrid[x, y];
      s := s + Cardname(card) + '   ';
    end;
    s := '♦  ' + Trim(s) + '  ♥';
    AMemo.Lines.Add(s);
    linelength := Length(s);
    AMemo.Lines.Add('♦'+StrRepeat(' ', linelength-2)+'♥');
  end;
  AMemo.Lines.Insert(0, '/'+StrRepeat('♠', linelength-2)+'\');
  AMemo.Lines.Insert(1, '♦'+StrRepeat(' ', linelength-2)+'♥');
  AMemo.Lines.Add('\'+StrRepeat('♣', linelength-2)+'/');
end;

procedure TForm1.CardButtonDraw(ACard: PCard);
const
  GuiVertSpaceReserved = 350; // incl. Taskbar etc.
var
  bitbtn: TBitBtn;
begin
  bitbtn := ACard.btn;

  bitbtn.TabStop := false;

  if ACard.isJoker then
    bitbtn.Font.Size := 17
  else
    bitbtn.Font.Size := 20;

  bitbtn.Width := 60;

  if ((Screen.Height - GuiVertSpaceReserved) div stat.GridSize) < 90 then
    bitbtn.Height := (Screen.Height - GuiVertSpaceReserved) div stat.GridSize
  else
    bitbtn.Height := 90;

  if ACard.isJoker then
    bitbtn.Font.Color := clBlue
  else if (ACard.suit = csLeft) or (ACard.suit = csRight) then
    bitbtn.Font.Color := clRed
  else
    bitbtn.Font.Color := clBlack;

  bitbtn.Caption := CardName(ACard^);
  if bitbtn.Caption = '???' then bitbtn.Caption := '';
  if bitbtn.Caption = 'Jkr' then bitbtn.Caption := 'Joker';
end;

procedure TForm1.DrawGameStat;
var
  Timer: string;
resourcestring
  S_TITLE = 'Grid Game';
  S_STATS = '%d of %d steps remaining - Time: %s (%d misclicks)';
begin
  Caption := S_TITLE;

  if not stat.Initialized then exit;

  if stat.StepsRemaining = 0 then
    Timer := TimeToStr(stat.FinishTime - stat.StartTime)
  else
    Timer := TimeToStr(Now - stat.StartTime);
  Caption := Caption + Format(' - '+S_STATS, [stat.StepsRemaining, stat.StepsStart, Timer, stat.MisClicks]);
end;

procedure TForm1.DrawGridToScreen_BA_Interactive(AGrid: PGrid; AParent: TWinControl);
var
  x, y: integer;
  bitbtn: TBitBtn;
  card: PCard;
  curx, cury: integer;
begin
  // Clean all cards from the grid
  while AParent.ControlCount > 0 do
  begin
    FreeAndNil(AParent.Controls[0]);
  end;

  // Draw new cards
  curx := 0;
  cury := 0;
  for y := 0 to stat.GridSize-1 do
  begin
    bitbtn := nil;
    for x := 0 to stat.GridSize-1 do
    begin
      bitbtn := TBitBtn.Create(AParent);
      card := @AGrid[x, y];
      card^.btn := bitbtn;
      CardButtonDraw(card);
      bitbtn.Left := curx;
      bitbtn.Top := cury;
      bitbtn.Parent := AParent;
      bitbtn.OnClick := CardClick;
      bitbtn.Tag := y * stat.GridSize + x;
      curx := curx + bitbtn.Width + 3;
      Sleep(150 div stat.GridSize);
      Application.ProcessMessages;
    end;
    curx := 0;
    cury := cury + bitbtn.Height + 3;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
resourcestring
  S_PLEASEWAIT = 'Please wait...';
begin
  Button1.Enabled := false;
  try
    Caption := S_PLEASEWAIT;
    stat.GridSize := SpinEdit1.Value;
    Randomize;
    InitDeck(Fdeck);
    LaycardsToGrid_BA(@stat, @Fdeck, @Fgrid); // Note: deck is not used at all...
    DrawGridToScreen_BA_Interactive(@Fgrid, Scrollbox1);
    DrawGridToScreen_BA_Print(@Fgrid, Memo1);
    stat.StartTime := Now;
    stat.FinishTime := 0;
    stat.MisClicks := 0;
    stat.Initialized := true;
    DrawGameStat;
    Timer2.Enabled := true;
  finally
    Button1.Enabled := true;
  end;
end;

procedure TForm1.CardClick(Sender: TObject);
var
  x, y: integer;
  oldx, oldy: integer;
resourcestring
  S_WIN = 'WIN!';
begin
  if not stat.Initialized then exit;
  if stat.StepsRemaining = 0 then exit;

  x := TBitBtn(Sender).Tag mod stat.GridSize;
  y := TBitBtn(Sender).Tag div stat.GridSize;

  if Fgrid[x, y].isJoker or Fgrid[x, y].isFaceDown then
  begin
    RegisterMisclick;
    Exit;
  end;

  if Fgrid[x, y].suit = csUp then
  begin
    oldx := x;
    oldy := y + Fgrid[x, y].number;
  end
  else if Fgrid[x, y].suit = csDown then
  begin
    oldx := x;
    oldy := y - Fgrid[x, y].number;
  end
  else if Fgrid[x, y].suit = csLeft then
  begin
    oldx := x + Fgrid[x, y].number;
    oldy := y;
  end
  else if Fgrid[x, y].suit = csRight then
  begin
    oldx := x - Fgrid[x, y].number;
    oldy := y;
  end
  else
  begin
    // Otherwise compiler complains
    oldx := 0;
    oldy := 0;
  end;

  if (oldy >= 0) and (oldy < stat.GridSize) and (oldx >= 0) and (oldx < stat.GridSize) then
  begin
    if not Fgrid[oldx, oldy].isJoker or Fgrid[oldx, oldy].isFaceDown then
      RegisterMisclick
    else
    begin
      Fgrid[oldx, oldy].isFaceDown := true;
      CardButtonDraw(@Fgrid[oldx, oldy]);

      Dec(stat.StepsRemaining);

      Fgrid[x, y].isJoker := true;
      CardButtonDraw(@Fgrid[x, y]);

      DrawGameStat;

      if stat.StepsRemaining = 0 then
      begin
        stat.FinishTime := Now;

        // Hide all cards
        for y := 0 to stat.GridSize-1 do
        begin
          for x := 0 to stat.GridSize-1 do
          begin
            Fgrid[x, y].isFaceDown := true;
            CardButtonDraw(@Fgrid[x, y]);
          end;
        end;

        showmessage(S_WIN);
      end;
    end;
  end
  else RegisterMisclick;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  Button1.Click;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  DrawGameStat;
end;

end.
