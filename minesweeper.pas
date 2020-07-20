Uses
 crt,dos,Sysutils;
Const
//SavePath='C:\Users\freddie\AppData\Roaming\BluesetStudio\Minesweeper\';
 SavePath='';
 dR:array[1..8] of -1..1=(-1,0,-1,-1,+1,+1,0,+1);
 dC:array[1..8] of -1..1=(0,-1,-1,+1,-1,0,+1,+1);
Var
{ Config:record=
  HasHelp:boolean;
 end; }

 HighScore:Array[1..3] of Real;
 HighName:Array[1..3] of String;

 Options:record
  W,H,M:Word;
 end;

 Game:record
  H,W:Byte;
  Mines:Word;
  MineGround:array[0..80,0..80] of byte;
  Flag:array[0..80,0..80] of -1..2;
  ActionCount:Dword;
  StartTime:Real;
  SaveTime:Real;
  TimeNum:Byte;
  MineNum:integer;
  CurC,CurR:Byte;
  Mode:byte;
  Start:Boolean;
  NewGame:Boolean;
 end;
 Menu:Array[0..255] of String;
 h,m,s,ms:word;
 sC,sR:Byte;

Procedure Fill(X,Y,W,H,C,B:Byte; Ch:Char);
Var
 i,j:integer;
Begin
 If C<>255 Then TextColor(C) else TextColor(White);
 If B<>255 Then TextBackGround(B) else TextBackGround(0);
 For i:=0 to H-1 do
  Begin
   GotoXY(X,Y+i);
   For j:=1 to W do
    Write(Ch);
  End;
 TextBackGround(0);
End;

Procedure DrawStateBar(C,B:Byte; T:String);
Var
 i:word;
 S:byte;
Begin
   If C<>255 then TextColor(C) else TextColor(Black);
   If B<>255 Then TextBackGround(B) else TextBackGround(White);
   GotoXY(1,24);
   S:=(80-length(T)) div 2;
   For i:=1 to S do
    write(' ');
   write(T);
   For i:=S+length(T)+1 to 80 do
    write(' ');
   TextColor(White);
   TextBackGround(0);
End;
Function MakeMenu(X,Y,W,C,B,N,S:Byte):Byte;
Var
 t:Byte;
 i:word;
 Procedure Update(K:Byte);
  Var
   i,j:integer;
  Begin
   If C<>255 then TextColor(C) else TextColor(White);
   If B<>255 Then TextBackGround(B) else TextBackGround(0);
   For i:=0 to K-1 do
    Begin
     GotoXY(X,Y+i);
     t:=(W-length(Menu[i])) div 2;
     For j:=1 to t do write(' ');
     Write(Menu[i]);
     For j:=t+length(Menu[i])+1 to W do write(' ');
    End;
   TextColor(Black);
   TextBackGround(White);
   GotoXY(X,Y+K);
   t:=(W-length(Menu[K])) div 2;
   For i:=1 to t do write(' ');
   Write(Menu[K]);
   For i:=t+length(Menu[K])+1 to W do write(' ');
   If C<>255 then TextColor(C) else TextColor(White);
   If B<>255 Then TextBackGround(B) else TextBackGround(0);
   For i:=K+1 to N-1 do
    Begin
     GotoXY(X,Y+i);
     t:=(W-length(Menu[i])) div 2;
     For j:=1 to t do write(' ');
     Write(Menu[i]);
     For j:=t+length(Menu[i])+1 to W do write(' ');
    End;
  End;
Begin
 MakeMenu:=S;
 Update(S);
 Repeat
  Case ReadKey of
   #72:Begin MakeMenu:=(MakeMenu+N-1) Mod N; Update(MakeMenu); End;
   #80:Begin MakeMenu:=(MakeMenu+1) Mod N; Update(MakeMenu); End;
   #13:Begin TextBackGround(0); Exit(MakeMenu); End;
   #27:Begin TextBackGround(0); Exit(255); End;
  end;
 Until False;
 TextColor(White);
 TextBackGround(0);
End;

Procedure Drawtext(X,Y,C:byte; T:String);
Begin
 GotoXY(X,Y);
 If C<>255 then TextColor(C) Else TextColor(White);
 write(T);
 TextColor(White);
End;

Procedure DrawWindow(X,Y,W,H,C:Byte);
Var
 i:Byte;
begin
 If C<>255 then TextColor(C) Else TextColor(White);
 GotoXY(X-1,Y-1);
 Write('+');
 For i:=1 to W do
  Write('-');
 Write('+');
 For i:=1 to H do
  Begin
   GotoXY(X-1,Y+i-1);
   Write('|');
   GotoXY(X+W,Y+i-1);
   Write('|');
  End;
 GotoXY(X-1,Y+H);
 Write('+');
 For i:=1 to W do
  Write('-');
 Write('+');
 TextColor(White);
End;

Function ShowDialog(Typ,C:Byte; T,TT:String):Boolean;
Var
 W,H,s,ss:Byte;
Begin
 s:=(80-length(t)) div 2;
 ss:=(80-length(tt)) div 2;
 Case Typ of
  1:
   Begin
    DrawWindow(s,11,length(t),3,C);
    Fill(s,11,length(t),3,255,255,' ');
    DrawText(ss,11,C,TT);
    DrawText(s,12,White,T);
    Menu[0]:='OK';
    MakeMenu(s,13,length(t),255,C,1,0);
    Exit(true);
   End;
  2:
   Begin
    DrawWindow(s,10,length(t),4,C);
    Fill(s,10,length(t),4,255,255,' ');
    DrawText(ss,10,C,TT);
    DrawText(s,11,White,T);
    Menu[0]:='YES';
    Menu[1]:='NO';
    If MakeMenu(s,12,length(t),255,C,2,1)=0 Then Exit(true) Else Exit(False);
   End;
 End;
End;


Procedure SaveHighscore;
Var
 WriteFile:text;
 i:Word;
Begin
 assign(WriteFile,SavePath+'Highscores.txt'); rewrite(WriteFile);
 For i:=1 to 3 do
  Begin
   Writeln(WriteFile,HighScore[i]:0:2);
   Writeln(WriteFile,HighName[i]);
  End;
 Close(WriteFile);
End;

Procedure LoadHighscore;
Var
 ReadFile:text;
 i:Word;
Begin
 if FileExists(SavePath+'Highscores.txt') then
  Begin
   assign(ReadFile,SavePath+'Highscores.txt'); reset(ReadFile);
   For i:=1 to 3 do
    Begin
     Readln(ReadFile,HighScore[i]);
     Readln(ReadFile,HighName[i]);
    End;
   Close(ReadFile);
  End
  Else
   Begin
    For i:=1 to 3 do
    Begin
     HighScore[i]:=999;
     HighName[i]:='Nobody';
    End;
    SaveHighscore;
   End;
End;

Procedure ShowHigh;
Var
 MenuIndex:Byte;
 st:string;
 temp:Dword;
Begin
 MenuIndex:=0;
 Repeat
  ClrScr;
  DrawStateBar(White,LightCyan,'UP & DOWN - Move Cursor | Enter - Delete Selected Record | ESC - Back');
  TextColor(White);
  DrawWindow(10,8,59,7,lightCyan);
  DrawText(10,8,White,'Highscore:');
  Menu[0]:='Easy: ';
  Temp:=Trunc(HighScore[1]*1000);
  str(Temp,st);
  Insert('.',st,length(st)-2);
  Menu[0]:=Menu[0]+st+' '+HighName[1];
  Menu[1]:='Medium: ';
  Temp:=Trunc(HighScore[2]*1000);
  str(Temp,st);
  Insert('.',st,length(st)-2);
  Menu[1]:=Menu[1]+st+' '+HighName[2];
  Menu[2]:='Hard: ';
  Temp:=Trunc(HighScore[3]*1000);
  str(Temp,st);
  Insert('.',st,length(st)-2);
  Menu[2]:=Menu[2]+st+' '+HighName[3];
  Menu[3]:='Reset Record';
  Menu[4]:='Back to Menu';
  MenuIndex:=MakeMenu(10,10,59,255,lightCyan,5,MenuIndex);
  Case MenuIndex of
   0: If ShowDialog(2,LightRed,'Delete Easy Record? This CAN''T be restored.','Warning') Then
      Begin Highscore[1]:=999; HighName[1]:='Nobody'; SaveHighScore; End;
   1: If ShowDialog(2,LightRed,'Delete Medium Record? This CAN''T be restored.','Warning') Then
      Begin Highscore[2]:=999; HighName[2]:='Nobody'; SaveHighScore; End;
   2: If ShowDialog(2,LightRed,'Delete Hard Record? This CAN''T be restored.','Warning') Then
      Begin Highscore[3]:=999; HighName[3]:='Nobody'; SaveHighScore; End;
   3: If ShowDialog(2,LightRed,'Delete All the Record? This CAN''T be restored.','Warning') Then
      Begin Highscore[1]:=999; HighName[1]:='Nobody';
            Highscore[2]:=999; HighName[2]:='Nobody';
            Highscore[3]:=999; HighName[3]:='Nobody';
            SaveHighScore;
      End;
   4: Exit;
   255: Exit;
  End;
 Until False;
End;

Procedure InitMapState;
Begin
 Fillchar(Game.Flag,sizeof(Game.Flag),0);
 Fillchar(Game.MineGround,sizeof(Game.MineGround),0);
 Game.TimeNum:=0;
 h:=0; m:=0; s:=0; ms:=0;
 Game.Mines:=0; Game.H:=0; Game.W:=0; Game.Mode:=0;
 Game.NewGame:=True; Game.Start:=False;
End;

Procedure UpdateTime;
Var
 T:string;
Begin
 CursorOff;
 TextBackGround(0);
 str(Game.TimeNum,T);
 DrawText(9,2,LightRed,'   ');
 DrawText(9,2,LightRed,T);
 TextBackGround(lightGray);
 CursorBig;
 GotoXY(sC+Game.CurC-1,sR+Game.CurR-1);
End;

Procedure UpdateMine;
Var
 T:string;
Begin
 CursorOff;
 TextBackGround(0);
 str(Game.MineNum,T);
 DrawText(76,2,LightRed,'   ');
 DrawText(76,2,LightRed,T);
 TextBackGround(LightGray);
 CursorBig;
 GotoXY(sC+Game.CurC-1,sR+Game.CurR-1);
End;

Procedure WriteNum(R,C:Byte);
Begin
 TextBackGround(LightGray);
 If Game.MineGround[R,C]=0 Then
  Begin
   Write(' ');
   Exit;
  End;
 Case Game.MineGround[R,C] of
  1:TextColor(lightblue);
  2:textcolor(green);
  3:textcolor(lightred);
  4:textcolor(blue);
  5:textcolor(red);
  6:textcolor(cyan);
  7:textcolor(black);
  8:textcolor(darkgray);
 End;
 Write(Game.MineGround[R,C]);
 TextColor(White);
End;

Procedure Refresh;
Var
 i,j:Word;
Begin
 TextBackGround(0);
 Clrscr;
 DrawWindow(sC,sR,Game.W,Game.H,LightBlue);
 DrawStateBar(White,LightBlue,'Arrow - Move Cursor | Space & 1 & 3 - Dig | Z & 2 - Put Flag | ESC - Menu');
 DrawText(3,2,LightCyan,'Time:');
 DrawText(69,2,LightCyan,'Mines:');
 UpdateTime;
 UpdateMine;
 TextColor(White);
 TextBackGround(LightGray);
 for i:=1 to Game.H do
  Begin
   GotoXY(sC,sR+i-1);
   For j:=1 to Game.W do
    Begin
     Case Game.Flag[i,j] of
      -1:WriteNum(i,j);
      0:write('#');
      1:Begin Textcolor(Red); Write(#24); TextColor(White); End;
      2:Begin TextColor(Black); Write('?'); TextColor(White); End;
     End;
    End;
  End;
 TextColor(White);
 TextBackGround(Black);
End;

Procedure GameSystem;
Var
 TimeTemp:Byte;
 TimeNow:Real;
 LoseExit:Boolean;
 Procedure MakeEdge;
 Var
  i:Word;
 Begin
  For i:=0 to Game.H+1 do
   Begin
    Game.Flag[i,0]:=-1; Game.Flag[i,Game.W+1]:=-1;
   End;
  For i:=0 to Game.W+1 do
   Begin
    Game.Flag[0,i]:=-1; Game.Flag[Game.H+1,i]:=-1;
   End;
 End;

 Procedure NewGame;
 Begin
  Game.TimeNum:=0; Game.NewGame:=True; Game.Start:=False; Game.MineNum:=Game.Mines;
  Fillchar(Game.Flag,sizeof(Game.Flag),0);
  Fillchar(Game.MineGround,sizeof(Game.MineGround),0);
  Game.CurC:=(Game.W+1) div 2; Game.CurR:=(Game.H+1) div 2;
 End;

 Procedure Restart;
 Begin
  Game.TimeNum:=0; Game.NewGame:=False; Game.Start:=False;
  Game.MineNum:=Game.Mines;
  Fillchar(Game.Flag,sizeof(Game.Flag),0);
  MakeEdge;
  Game.CurC:=(Game.W+1) div 2; Game.CurR:=(Game.H+1) div 2;
  ShowDialog(1,LightRed,'You have restart this game. You may lose at the FIRST STEP.','NOTICE');
  DrawStateBar(White,LightRed,'Enter - Confirm');
 End;

 Function ShowResult(Typ:Byte; T:String; Time:Real; Action:Dword; Mode:Byte):Byte;
 Var
  s,C:Byte;
 Begin
  CursorOff;
  TextBackGround(0);
  s:=(17-length(T)) div 2;
  Case Typ Of
  {Win2} 0:
    Begin
      DrawWindow(31,8,17,8,LightGreen);
      Fill(31,8,17,8,255,Black,' ');
      DrawText(31+s,8,LightGreen,T);
      TextColor(White); GotoXY(32,10); Write('   Time:'); TextColor(LightGreen); Write(Time:0:3);
      TextColor(White); GotoXY(32,11); Write('Actions:'); TextColor(LightGreen); Write(Action);
      Menu[0]:='Create a New Game';
      Menu[1]:='Restart This Game';
      Menu[2]:='Back to Main Menu';
      Exit(MakeMenu(31,13,17,255,255,3,0));
    End;

   {Win} 1:
    Begin
      DrawWindow(31,6,17,11,LightGreen);
      Fill(31,6,17,11,255,Black,' ');
      DrawText(31+s,6,LightGreen,T);
      TextColor(White); GotoXY(32,8); Write('   Time:'); TextColor(LightGreen); Write(Time:0:3);
      TextColor(White); GotoXY(32,9); Write('Actions:'); TextColor(LightGreen); Write(Action);
      DrawText(32,11,LightCyan,'New Highscore!');
      Menu[0]:='Leave My Name';
      Menu[1]:='Create a New Game';
      Menu[2]:='Restart This Game';
      Menu[3]:='Back to Main Menu';
      Exit(MakeMenu(31,13,17,255,255,4,0));
    End;
  {Lose} 2:
    Begin
      DrawWindow(31,8,17,8,LightRed);
      Fill(31,8,17,8,255,Black,' ');
      DrawText(31+s,8,LightRed,T);
      TextColor(White); GotoXY(32,10); Write('   Time:'); TextColor(LightRed); Write(Time:0:3);
      TextColor(White); GotoXY(32,11); Write('Actions:'); TextColor(LightRed); Write(Action);
      Menu[0]:='Create a New Game';
      Menu[1]:='Restart This Game';
      Menu[2]:='Back to Main Menu';
      Exit(MakeMenu(31,13,17,255,255,3,0));
    End;
  {Menu} 3:
    Begin
      Game.SaveTime:=Time;
      DrawWindow(31,8,17,9,LightCyan);
      Fill(31,8,17,9,255,Black,' ');
      DrawText(31+s,8,LightCyan,T);
      TextColor(White); GotoXY(32,10); Write('   Time:'); TextColor(LightCyan); Write(Time:0:3);
      TextColor(White); GotoXY(32,11); Write('Actions:'); TextColor(LightCyan); Write(Action);
      Menu[0]:='Resume';
      Menu[1]:='Create a New Game';
      Menu[2]:='Restart This Game';
      Menu[3]:='Back to Main Menu';
      Exit(MakeMenu(31,13,17,255,255,4,0));
    End;
  End;
 End;
 Procedure TakeWin;
 Var
  i,j:Word;
  NoHigh:Boolean;
 Begin
  For i:=1 to Game.H do
   For j:=1 to Game.W do
     If (Game.Flag[i,j]=0) or (Game.Flag[i,j]=1) Then
      If Game.MineGround[i,j]<>9 Then Exit;
  For i:=1 to Game.H do
   For j:=1 to Game.W do
    If Game.MineGround[i,j]=9 Then
     Begin
      Game.Flag[i,j]:=1;
     End;
  Game.MineNum:=0;
  Refresh;
  DrawStateBar(White,LightGreen,'Press ESC to show the Game Menu.');
  Repeat
  Until Readkey=#27;
  DrawStateBar(White,LightGreen,'Arrow - Move Cursor | Enter - Confirm | ESC - Back to Menu');
  NoHigh:=true;
  If (Game.Mode<4) and (TimeNow<HighScore[Game.Mode]) Then
   Begin
    HighScore[Game.Mode]:=TimeNow;
    HighName[Game.Mode]:='Anonymous';
    SaveHighscore;
    NoHigh:=False;
    Case ShowResult(1,'You Win!',TimeNow,Game.ActionCount,Game.Mode) of
     0:
      Begin
       Fill(31,11,17,2,255,Black,' ');
       TextColor(White); GotoXY(31,10); Write('Your Name:');
       DrawStateBar(White,LightGreen,'Type your name and press Enter to Confirm.');
       Window(31,12,47,12);
       CursorOn;
       TextColor(LightGreen);
       Readln(HighName[Game.Mode]);
       Window(1,1,80,25);
       CursorOff;
       TextColor(White);
       NoHigh:=True;
      End;
     1:NewGame;
     2:Restart;
     3:Begin LoseExit:=True; Exit; End;
     255:Begin LoseExit:=True; Exit; End;
    End;
    SaveHighscore;
    ReFresh;
   End;
  If NoHigh Then
   Case ShowResult(0,'You Win!',TimeNow,Game.ActionCount,Game.Mode) of
     0:NewGame;
     1:Restart;
     2:Begin LoseExit:=True; Exit; End;
     255:Begin LoseExit:=True; Exit; End;
   End;
  ReFresh;
End;

 Procedure Takelose;
 Var
  i,j:word;
 Begin
  LoseExit:=False;
  TextBackGround(lightGray);
  For i:=1 to Game.H do
   For j:=1 to Game.W do
    Begin
     If (Game.MineGround[i,j]<>9) and (Game.Flag[i,j]=1) Then
      Begin
       GotoXY(sC+j-1,sR+i-1);
       TextColor(lightRed);
       Write('X');
       TextColor(White);
      End;
     If Game.MineGround[i,j]=9 Then
      Begin
       GotoXY(sC+j-1,sR+i-1);
       TextColor(Black);
       Write(#15);
      End;
    End;
  DrawStateBar(White,Lightred,'Press ESC to show the Game Menu.');
  Repeat
  Until Readkey=#27;
  DrawStateBar(White,LightRed,'Arrow - Move Cursor | Enter - Confirm | ESC - Back to Menu');
  Case ShowResult(2,'You Lose.',TimeNow,Game.ActionCount,Game.Mode) of
    0:NewGame;
    1:Restart;
    2:Begin LoseExit:=True; Exit; End;
   255:Begin LoseExit:=True; Exit; End;
  End;
 End;



 Procedure InitMine;
 Var
  R,C:array[1..1351] of Word;
  i,j,k:Word;
  Number:Byte;
  RanR,RanC:Word;
  F:boolean;
 Begin
  Randomize;
  For i:=1 to Game.Mines Do
   Begin
    Repeat
     F:=False;
     Repeat
      RanR:=Random(Game.H+1);
      RanC:=Random(Game.W+1);
     Until ((RanR<>Game.CurR) or (RanC<>Game.CurC)) and (RanR>0) and (RanC>0);
     For j:=1 to i-1 do
      If (R[j]=RanR) and (C[j]=RanC) then Begin f:=True; Break; End;
    Until Not F;
    R[i]:=RanR;
    C[i]:=RanC;
   End;
  For i:=1 to Game.Mines Do
   Game.MineGround[R[i],C[i]]:=9;
  Number:=0;
  For i:=1 to Game.H do
   For j:=1 to Game.W do
    Begin
     Number:=0;
     If Game.MineGround[i,j]<>9 then
      For k:=1 to 8 do
        If Game.MineGround[i+dR[k],j+dC[k]]=9 then Inc(Number);
     if Number<>0 Then Game.MineGround[i,j]:=Number;
    End;
  MakeEdge;
 End;


 Procedure Button1;

  Procedure FillBlank(R,C:Byte);
   Procedure Go(R,C:Byte);
   Begin
    If (Game.Flag[R,C]=0) and (Game.MineGround[R,C]<>9) and (R>0) and (C>0) and (R<Game.H+1) and (C<Game.W+1) Then
     Begin
      Game.Flag[R,C]:=-1;
      GotoXY(sC+C-1,sR+R-1);
      WriteNum(R,C);
      If Game.MineGround[R,C]=0 Then
       Begin
        Go(R-1,C); Go(R,C-1); Go(R-1,C-1); Go(R+1,C); Go(R,C+1); Go(R+1,C+1); Go(R+1,C-1); Go(R-1,C+1);
       End;
     End;
   End;
  Begin
   CursorOff;
   Go(R,C);
   CursorBig;
   GotoXY(sC+Game.CurC-1,sR+Game.CurR-1);
  End;

  Procedure LeftButton;
  Begin
   If Game.NewGame Then Begin InitMine; Game.NewGame:=False; End;
   If Not Game.Start Then
    Begin
     Game.SaveTime:=0;
     GetTime(h,m,s,ms);
     Game.StartTime:=h*3600+m*60+s+ms/100;
     Game.Start:=True;
    End;
   If Game.MineGround[Game.CurR,Game.CurC]=9 Then Begin TakeLose; If LoseExit Then Exit Else ReFresh; End
   Else
    Begin
     If Game.MineGround[Game.CurR,Game.CurC]<>0 Then
      Begin
       Game.Flag[Game.CurR,Game.CurC]:=-1;
       WriteNum(Game.CurR,Game.CurC);
      End
     Else FillBlank(Game.CurR,Game.CurC);
    End;
  End;

  Procedure Detect;
  Var tR,tC:Byte; i:Word;
  Begin
   //Wrong Flag
   For i:=1 to 8 do
    If Game.Flag[Game.CurR+dR[i],Game.CurC+dC[i]]=2 Then Exit;

   For i:=1 to 8 do
    If (Game.MineGround[Game.CurR+dR[i],Game.CurC+dC[i]]<>9)
     and (Game.Flag[Game.CurR+dR[i],Game.CurC+dC[i]]=1) Then Begin TakeLose; If LoseExit Then Exit Else ReFresh; Exit; End;

   For i:=1 to 8 do
    If (Game.MineGround[Game.CurR+dR[i],Game.CurC+dC[i]]=9)
     and (Game.Flag[Game.CurR+dR[i],Game.CurC+dC[i]]=0) Then Exit;

   tR:=Game.CurR;
   tC:=Game.CurC;
   For i:=1 to 8 do
    Begin
     Game.CurR:=tR+dR[i]; Game.CurC:=tC+dC[i];
     If Game.Flag[Game.CurR,Game.CurC]=0 Then
      Begin
       GotoXY(sC+Game.CurC-1,sR+Game.CurR-1);
       LeftButton;
      End;
    End;
   Game.CurR:=tR;
   Game.CurC:=tC;
   GotoXY(sC+Game.CurC-1,sR+Game.CurR-1);
  End;

 Begin
  inc(Game.ActionCount);
  if Game.Flag[Game.CurR,Game.CurC]=0 Then LeftButton Else
  if Game.Flag[Game.CurR,Game.CurC]=-1 Then Detect;
  TakeWin;
 End;

 Procedure Button2;
 Begin
  TextBackGround(LightGray);
  if Game.Flag[Game.CurR,Game.CurC]<>-1 Then
   Case Game.Flag[Game.CurR,Game.CurC] of
    0:
     Begin
      TextColor(Red);
      Write(#24);
      TextColor(White);
      Game.Flag[Game.CurR,Game.CurC]:=1;
      Dec(Game.MineNum);
      UpdateMine;
     End;
    1:
     Begin
      TextColor(Black);
      Write('?');
      TextColor(White);
      Game.Flag[Game.CurR,Game.CurC]:=2;
      Inc(Game.MineNum);
      UpdateMine;
     End;
    2:
     Begin
      TextColor(White);
      Write('#');
      Game.Flag[Game.CurR,Game.CurC]:=0;
     End;
   End;
 End;

Begin
 CursorBig;
 LoseExit:=False;
 Game.CurC:=(Game.W+1) div 2; Game.CurR:=(Game.H+1) div 2;
 GotoXY(sC+Game.CurC-1,sR+Game.CurR-1);
 Repeat
  Repeat
   If Game.Start Then
    Begin
     Gettime(h,m,s,ms);
     TimeNow:=h*3600+m*60+s+ms/100-Game.StartTime+Game.SaveTime;
     TimeTemp:=Trunc(TimeNow);
     If TimeTemp<>Game.TimeNum Then
      Begin
       Game.TimeNum:=TimeTemp;
        If Game.TimeNum>999 Then
         Begin
          Begin TakeLose; If LoseExit Then Exit Else ReFresh; End;
         End;
       UpdateTime;
      End;
    End;
    Until (KeyPressed);
  Case Readkey of
   #72:Begin if Game.CurR>1 then dec(Game.CurR); End;
   #75:Begin if Game.CurC>1 then dec(Game.CurC); End;
   #80:Begin if Game.CurR<Game.H then inc(Game.CurR); End;
   #77:Begin if Game.CurC<Game.W then inc(Game.CurC); End;
   '1':Button1;
   '2':Button2;
   '3':Button1;
   #32:Button1;
   'Z':Button2;
   'z':Button2;
   #27:Begin
        DrawStateBar(White,LightCyan,'Arrow - Move Cursor | Enter - Confirm | ESC - Resume');
        Case ShowResult(3,'Game Paused',TimeNow,Game.ActionCount,Game.Mode) of
          0:Begin GetTime(h,m,s,ms); Game.StartTime:=h*3600+m*60+s+ms/100; End;
          1:NewGame;
          2:Restart;
          3:Exit;
          255:Begin GetTime(h,m,s,ms); Game.StartTime:=h*3600+m*60+s+ms/100; End;
        End;
        Refresh;
       End;
  End;
  If LoseExit Then Begin LoseExit:=False; Exit End;
  GotoXY(sC+Game.CurC-1,sR+Game.CurR-1);
 Until False;
End;

Procedure InitGame;
Begin
 Game.Start:=False;
 Game.MineNum:=Game.Mines;
 sC:=(80-Game.W) div 2;
 sR:=((24-Game.H) div 2)+2;
 Refresh;
End;


Procedure MapMenu;
 Procedure Customize;
 Var
  Value:array[0..2] of Word;
  NowSelect:Byte;

  Procedure Update;
  Begin
   If NowSelect<>3 Then DrawStateBar(White,LightCyan,'UP & DOWN - Change | LEFT & RIGHT - Select | Enter - Input | ESC - Back')
   Else DrawStateBar(White,LightCyan,'LEFT & RIGHT - Select | Enter - Confirm | ESC - Back');
   GotoXY(21,12);
   TextColor(LightCyan); write('  Width:');
   If NowSelect=0 Then Begin TextColor(Black); TextBackGround(White); End
   Else Begin TextColor(LightRed); End; write(Value[0]:2);
   TextBackGround(0); TextColor(LightCyan); write('   Height:');
   If NowSelect=1 Then Begin TextColor(Black); TextBackGround(White); End
   Else Begin TextColor(LightRed); End; write(Value[1]:2);
   TextBackGround(0); TextColor(LightCyan); write('   Mines:');
   If NowSelect=2 Then Begin TextColor(Black); TextBackGround(White); End
   Else Begin TextColor(LightRed); End; write(Value[2]:4);
   TextBackGround(0); write('  ');
   If NowSelect=3 Then Begin TextColor(Black); TextBackGround(White); End
   Else Begin TextColor(LightGreen); End; write('OK');
   TextBackGround(0);
  End;

  Procedure Lagel;
  Begin
   if Value[0]<9 Then Value[0]:=9;
   if Value[1]<9 Then Value[1]:=9;
   if Value[2]<10 Then Value[2]:=10;
   if Value[0]>76 Then Value[0]:=76;
   if Value[1]>19 Then Value[1]:=19;
   if Value[2]>(Value[1]-1)*(Value[0]-1) Then Value[2]:=(Value[1]-1)*(Value[0]-1)
  End;

  Procedure Input;
  Begin
   TextColor(White);
   TextBackGround(LIghtBlue);
   Case NowSelect of
    0:window(29,12,30,12);
    1:window(41,12,42,12);
    2:window(52,12,55,12);
   End;
   Clrscr;
   CursorOn;
   read(Value[NowSelect]);
   CursorOff;
   window(1,1,80,25);
  End;

 Begin
  TextBackGround(0);
  NowSelect:=0;
  Value[0]:=9;
  Value[1]:=9;
  Value[2]:=10;
  DrawWindow(21,10,40,3,lightCyan);
  Fill(21,10,40,3,255,255,' ');
  DrawText(38,10,White,'Custom');
  TextColor(White);
  Update;
  Repeat
   Case Readkey of
    #72:
     Begin
      If NowSelect<>3 Then
       Inc(Value[NowSelect]);
      Lagel;
     End;
    #80:
     Begin
      If NowSelect<>3 Then
       Dec(Value[NowSelect]);
      Lagel;
     End;
    #77:
     Begin
      NowSelect:=(NowSelect+1) mod 4;
     End;
    #75:
     Begin
      NowSelect:=(NowSelect+3) mod 4;
     End;
    #13:
     Begin
      if NowSelect=3 Then
       Begin
        Game.H:=Value[1]; Game.W:=Value[0]; Game.Mines:=Value[2]; Exit;
       End
      Else
       Begin
        Input;
        Lagel;
       End;
     End;
    #27: Begin Game.H:=3; Exit; End;
   End;
   Update;
  Until False;
 End;
Begin
 InitMapState;
 Repeat
  TextBackGround(0);
  ClrScr;
  DrawStateBar(White,Lightgreen,'UP & DOWN - Move Cursor | Enter - Confirm | ESC - Back');
  TextColor(White);
  DrawWindow(25,8,32,7,lightGreen);
  DrawText(25,8,lightCyan,'Please select your difficulty:');
  Menu[0]:='  Easy :  9x9  10 Mines';
  Menu[1]:='Medium : 16x16 40 Mines';
  Menu[2]:='  Hard : 16x30 99 Mines';
  Menu[3]:='         Custom        ';
  Menu[4]:='      Back to Menu     ';
  Case MakeMenu(25,10,32,255,lightgreen,5,Game.H) of
   0: Begin Game.H:=9; Game.W:=9; Game.Mines:=10; Game.Mode:=1; End;
   1: Begin Game.H:=16; Game.W:=16; Game.Mines:=40; Game.Mode:=2; End;
   2: Begin Game.H:=16; Game.W:=30; Game.Mines:=99; Game.Mode:=3; End;
   3: Begin Customize; Game.Mode:=4; End;
   4: Exit;
   255: Exit;
  End;
 Until Game.H<>3;
 InitGame;
 GameSystem;
End;

Procedure WelcomeMenu;
Var
 SaveIndex:Byte;
 MenuIndex:Byte;
Begin
 MenuIndex:=0;
 Repeat
  Textbackground(0);
  Clrscr;
  DrawStateBar(White,Lightred,'UP & DOWN - Move Cursor | Enter - Select | ESC - Quit');
  DrawWindow(27,8,28,7,lightred);
  DrawText(30,8,lightCyan,'MINESWEEPER ReFix v2.42');
  DrawText(35,10,lightgreen,'By Freddie');
  Menu[0]:='Start Game';
  Menu[1]:='Highscores';
  Menu[2]:='Quit';
  SaveIndex:=MenuIndex;
  MenuIndex:=MakeMenu(27,12,28,LightCyan,Red,3,MenuIndex);
  Case MenuIndex of
   0:
    Begin
     MapMenu;
    End;
   1:
    Begin
     ShowHigh;
    End;
   2:If ShowDialog(2,LightGreen,'ARE YOU SURE TO QUIT?','Minesweeper') Then Exit;
   255:Begin MenuIndex:=SaveIndex; If ShowDialog(2,LightGreen,'ARE YOU SURE TO QUIT?','Minesweeper') Then Exit; End;
  End;
 Until False;
end;

Procedure Loading;
Begin
 LoadHighscore;
 //LoadConfig;
 //InitOptions;
End;
Begin
 window(1,1,80,25);
 CursorBig;
 CursorOff;
 Loading;
 WelcomeMenu;
 Clrscr;
 CursorOn;
End.