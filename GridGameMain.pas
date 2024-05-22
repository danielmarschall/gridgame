unit GridGameMain;

// TODO: Remember grid size and settings for next session
// TODO: Settings
//       - Disable Sounds
//       - Disable Music
// TODO: Game Modes
//       - Nightmare = 1 misclick leads to reshuffle
//       - Hard = 20% (?) misclicks leads reshuffle
//       - Medium = Deadlock paths possible, infinite misclicks allowed
//       - Easy = No deadlock paths, infinite misclicks allowed  <== current default
//       When deadlocks are implemented, add a warning to the help file
//       "Please be aware that there might be traps. This means paths which lead to a deadlock."
// TODO: Double click should not count as misclick
// TODO: Center the cards to the screen center

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.MPlayer, Vcl.Menus;

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
    AllowTraps: boolean;
    MisClicksCur: integer;
    MisClicksMax: integer;
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
    tsPlay: TTabSheet;
    tsText: TTabSheet;
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Timer1: TTimer;
    Timer2: TTimer;
    Label1: TLabel;
    tsHelp: TTabSheet;
    Memo2: TMemo;
    MediaPlayer1: TMediaPlayer;
    Label2: TLabel;
    tsHighscores: TTabSheet;
    Memo3: TMemo;
    PopupMenu1: TPopupMenu;
    Deleteallentries1: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MediaPlayer1Notify(Sender: TObject);
    procedure MediaPlayer1Click(Sender: TObject; Button: TMPBtnType;
      var DoDefault: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Deleteallentries1Click(Sender: TObject);
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
    procedure Reshuffle;
    function GetScore: integer;
    procedure AddToHighScores(const APlayerName: string; AGridSize: integer; AScore: integer);
    function HighScoreFile(MayCreateDir: boolean): string;
    procedure ClearHighScoreList;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Winapi.MMSystem, DateUtils, Math, ActiveX, ShlObj;

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
  if stat.AllowTraps then
  begin
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
  end;

  AStats.StepsStart := pathLength;
  AStats.StepsRemaining := pathLength;
end;

procedure TForm1.MediaPlayer1Click(Sender: TObject; Button: TMPBtnType;
  var DoDefault: Boolean);
begin
  Case Button of
    btStop:   MediaPlayer1.EnabledButtons := [btPlay];
    btPlay:   MediaPlayer1.EnabledButtons := [btPause,btStop];
  end;
end;

procedure TForm1.MediaPlayer1Notify(Sender: TObject);
var
  MP: TMediaPlayer;
begin
  MP := TMediaPlayer(Sender);

  if MP.Position = MP.Length then
  begin
    if MP.Mode = mpPlaying then MP.Rewind;
    MP.Play;
  end;

  MP.Notify := True;
end;

procedure TForm1.RegisterMisclick;
begin
  Inc(stat.MisClicksCur);
  if (stat.MisClicksMax <> -1) and (stat.MisClicksCur > stat.MisClicksMax) then
  begin
    Reshuffle;
  end
  else
  begin
    DrawGameStat;
    PlaySound('sounds\misclick.wav', 0, SND_FILENAME or SND_NODEFAULT or SND_ASYNC);
  end;
end;

function CardName(ACard: TCard): string;
begin
  if Acard.isFaceDown then
  begin
    result := '???'; // do not translate
  end
  else if Acard.isJoker then
  begin
    result := 'Jkr'; // do not translate
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  FileName: string;
begin
  // Load highscores
  FileName := HighScoreFile(False);
  if FileExists(FileName) then
    Memo3.Lines.LoadFromFile(FileName)
  else
    Memo3.Clear;
end;

procedure TForm1.CardButtonDraw(ACard: PCard);
const
  GuiVertSpaceReserved = 325; // incl. Taskbar etc.
var
  bitbtn: TBitBtn;
resourcestring
  S_Joker = 'Joker';
begin
  bitbtn := ACard.btn;

  bitbtn.TabStop := false;

  if ACard.isJoker then
    bitbtn.Font.Size := 17
  else
    bitbtn.Font.Size := 20;

  bitbtn.Width := 60;

  // Monitor is the screen where the for is CURRENTLY at!
  if ((Monitor.Height - GuiVertSpaceReserved) div stat.GridSize) < 90 then
    bitbtn.Height := (Monitor.Height - GuiVertSpaceReserved) div stat.GridSize
  else
    bitbtn.Height := 90;

  if ACard.isJoker then
    bitbtn.Font.Color := clBlue
  else if (ACard.suit = csLeft) or (ACard.suit = csRight) then
    bitbtn.Font.Color := clRed
  else
    bitbtn.Font.Color := clBlack;

  bitbtn.Caption := CardName(ACard^);
  if bitbtn.Caption = '???' then bitbtn.Caption := '';       // do not translate
  if bitbtn.Caption = 'Jkr' then bitbtn.Caption := S_Joker;  // do not translate
end;

function TForm1.GetScore: integer;
var
  ms: Int64;
  clc: double;
begin
  if (stat.StepsRemaining = 0) and (CompareValue(stat.FinishTime,0) <> 0) then
    ms := MilliSecondsBetween(stat.FinishTime, stat.StartTime)
  else
    ms := MilliSecondsBetween(Now, stat.StartTime);

  clc := stat.StepsStart-stat.StepsRemaining; // Successful clicks
  clc := clc - stat.MisClicksCur * 0.5; // Penality  0,5clicks per misclick

  if clc < 0 then clc := 0;

  if clc = 0 then exit(0);

  result := (60*1000) - round(ms/clc);
  if result < 0 then result := 0;
end;

procedure TForm1.Deleteallentries1Click(Sender: TObject);
begin
  ClearHighScoreList;
end;

procedure TForm1.DrawGameStat;
var
  Timer: string;
  sMisClicksMax: string;
  sNewCaption: string;
resourcestring
  S_TITLE = 'Grid Game';
  S_STATS = '%d of %d steps remaining - Time: %s (%d of %s misclicks) - SCORE %d';
  S_Infinite = 'infinite';
begin
  sNewCaption := S_TITLE;

  if not stat.Initialized then exit;

  if (stat.StepsRemaining = 0) and (CompareValue(stat.FinishTime,0) <> 0) then
    Timer := TimeToStr(stat.FinishTime - stat.StartTime)
  else
    Timer := TimeToStr(Now - stat.StartTime);

  if stat.MisClicksMax = -1 then
    sMisClicksMax := S_Infinite
  else
    sMisClicksMax := IntToStr(stat.MisClicksMax);

  sNewCaption := sNewCaption + Format(' - '+S_STATS, [stat.StepsRemaining, stat.StepsStart, Timer, stat.MisClicksCur, sMisClicksMax, GetScore]);

  if Caption <> sNewCaption then Caption := sNewCaption;
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

procedure TForm1.Reshuffle;
resourcestring
  S_PLEASEWAIT = 'Please wait...';
var
  shouldStartMusic: boolean;
begin
  Caption := S_PLEASEWAIT;
  Timer2.Enabled := false;

  shouldStartMusic := (MediaPlayer1.Tag = 0) or (MediaPlayer1.Mode = TMPModes.mpPlaying); // <-- if the user stopped the music, don't start it again at reshuffle

  PlaySound(nil, 0, 0);
  if MediaPlayer1.Mode = TMPModes.mpPlaying then
  begin
    MediaPlayer1.Stop;
  end;
  MediaPlayer1.EnabledButtons := []; // We need to do this crap because AutoEnable does not work together with the Play/Stop commands

  PlaySound('sounds\shuffle.wav', 0, SND_FILENAME or SND_NODEFAULT or SND_LOOP or SND_ASYNC);
  stat.Initialized := false;
  stat.GridSize := SpinEdit1.Value;
  Randomize;
  InitDeck(Fdeck);
  LaycardsToGrid_BA(@stat, @Fdeck, @Fgrid); // Note: deck is not used at all...
  DrawGridToScreen_BA_Interactive(@Fgrid, Scrollbox1);
  DrawGridToScreen_BA_Print(@Fgrid, Memo1);
  stat.StartTime := Now;
  stat.FinishTime := 0;
  stat.MisClicksCur := 0;
  stat.MisClicksMax := -1; // TODO: game mode
  stat.AllowTraps := false; // TODO: game mode
  stat.Initialized := true;
  DrawGameStat;
  PlaySound(nil, 0, 0);

  MediaPlayer1.FileName := 'sounds\music.wav';
  if FileExists(MediaPlayer1.FileName) then
  begin
    MediaPlayer1.Open;
    if shouldStartMusic then
    begin
      MediaPlayer1.Play;
      MediaPlayer1.EnabledButtons := [btStop]; // We need to do this crap because AutoEnable does not work together with the Play/Stop commands
      MediaPlayer1.Notify := True;
      MediaPlayer1.AutoRewind := False; // Otherwise Loop does not work
      MediaPlayer1.Tag := 1; // ran once
    end
    else
    begin
      MediaPlayer1.EnabledButtons := [btPlay];
    end;
  end;

  Timer2.Enabled := true;
end;

function TForm1.HighScoreFile(MayCreateDir: boolean): string;

  const
    FOLDERID_SavedGames: TGuid = '{4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4}'; // do not localize

  function GetKnownFolderPath(const rfid: TGUID): string;
  var
    OutPath: PWideChar;
  begin
    // https://www.delphipraxis.net/135471-unit-zur-verwendung-von-shgetknownfolderpath.html
    if ShGetKnownFolderPath(rfid, 0, 0, OutPath) {>= 0} = S_OK then
    begin
      Result := OutPath;
      // From MSDN
      // ppszPath [out]
      // Type: PWSTR*
      // When this method returns, contains the address of a pointer to a null-terminated Unicode string that specifies the path of the known folder
      // The calling process is responsible for freeing this resource once it is no longer needed by calling CoTaskMemFree.
      // The returned path does not include a trailing backslash. For example, "C:\Users" is returned rather than "C:\Users\".
      CoTaskMemFree(OutPath);
    end
    else
    begin
      Result := '';
    end;
  end;

var
  HighScoreDir: string;
begin
  HighScoreDir := IncludeTrailingPathDelimiter(GetKnownFolderPath(FOLDERID_SavedGames)) + 'GridGame';
  result := IncludeTrailingPathDelimiter(HighScoreDir) + 'HighScores.txt';
  if MayCreateDir then ForceDirectories(HighScoreDir);
end;

function CompareDescending(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := CompareText(List.Strings[Index2], List.Strings[Index1]);
end;

procedure TForm1.AddToHighScores(const APlayerName: string; AGridSize: integer; AScore: integer);
var
  sl: TStringList;
  FileName: string;
begin
  sl := TStringList.Create;
  try
    FileName := HighScoreFile(True);
    if FileExists(FileName) then sl.LoadFromFile(FileName);
    sl.Add(Format('Grid %.*d   Score %.*d   %s', [2, AGridSize, Length('60000'), AScore, APlayerName]));
    sl.CustomSort(CompareDescending);
    sl.SaveToFile(FileName);
    Memo3.Lines.Text := sl.Text; // reload GUI
    PageControl1.ActivePage := tsHighscores;
  finally
    FreeAndNil(sl);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Button1.Enabled := false;
  try
    PageControl1.ActivePage := tsPlay;
    Reshuffle;
  finally
    Button1.Enabled := true;
  end;
end;

procedure TForm1.CardClick(Sender: TObject);
resourcestring
  SWinCaption = 'Win!';
  SEnterName = 'Enter your name:';
var
  x, y: integer;
  oldx, oldy: integer;
  playerName: string;
begin
  if not stat.Initialized then exit;
  if stat.StepsRemaining = 0 then exit;

  x := TBitBtn(Sender).Tag mod stat.GridSize;
  y := TBitBtn(Sender).Tag div stat.GridSize;

  if Fgrid[x, y].isJoker or Fgrid[x, y].isFaceDown then
  begin
    // It is theoretically a misclick, but we do not count it, because
    // clicking Joker or face-down card is too invalid to be taken seriously.
    // RegisterMisclick;
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
    begin
      RegisterMisclick;
      Exit;
    end
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

        // Play sound
        PlaySound('sounds\win.wav', 0, SND_FILENAME or SND_NODEFAULT or SND_ASYNC);
        if MediaPlayer1.Mode = TMPModes.mpPlaying then
        begin
          MediaPlayer1.Stop;
          MediaPlayer1.EnabledButtons := [btPlay];
          MediaPlayer1.Tag := 0; // Allow that the music starts again after reshuffling
        end;

        // Ask for name for the high scores
        playerName := '';
        InputQuery(SWinCaption, SEnterName, playerName);
        if playerName <> '' then
          AddToHighScores(playerName, stat.GridSize, GetScore);
      end
      else
      begin
        PlaySound('sounds\pick.wav', 0, SND_FILENAME or SND_NODEFAULT or SND_ASYNC);
      end;
    end;
  end
  else
  begin
    RegisterMisclick;
    Exit;
  end;
end;

procedure TForm1.ClearHighScoreList;
var
  FileName: string;
begin
  FileName := HighScoreFile(false);
  if FileExists(FileName) then DeleteFile(FileName);
  Memo3.Clear;
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
