unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, helper, IdTCPConnection,
  IdTCPClient, IdHTTP, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type
  TDownloader = class(TForm)
    LoginEdit: TEdit;
    PassEdit: TEdit;
    AuthBtn: TButton;
    Button2: TButton;
    Label_Status: TLabel;
    Status: TLabel;
    Button1: TButton;
    ListBox1: TListBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Button3: TButton;
    CheckBox1: TCheckBox;
    procedure AuthBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  Auth = class(TThread)
  private
    http: tidhttp;
    ssl: TIdSSLIOHandlerSocketOpenSSL;
  protected
    procedure Execute; override;
    constructor Create(CreateSuspended: Boolean);
  end;

  TakeMSG = class(TThread)
  private
    http: tidhttp;
    ssl: TIdSSLIOHandlerSocketOpenSSL;
    allmsgs, userid: string;
  protected
    procedure Execute; override;
    procedure SaveToFile;
    constructor Create(CreateSuspended: Boolean);
  end;

  SaveAudio = class(TThread)
  private
    http: tidhttp;
    userid: string;
    ssl: TIdSSLIOHandlerSocketOpenSSL;
  protected
    procedure Execute; override;
    constructor Create(CreateSuspended: Boolean);
  end;

  SavePhoto = class(TThread)
  private
    http: tidhttp;
    userid: string;
    ssl: TIdSSLIOHandlerSocketOpenSSL;
  protected
    procedure Execute; override;
    constructor Create(CreateSuspended: Boolean);
  end;

var
  Downloader: TDownloader;
  VK_TOKEN: string;
  FriendList: TStringList;

implementation

{$R *.dfm}

procedure TDownloader.AuthBtnClick(Sender: TObject);
begin
  Auth.Create(false);
end;

{ Working }

constructor Auth.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
end;

procedure Auth.Execute;
var
  html: string;
  FList: TStringList;
  i: integer;
begin
  inherited;
  try
    begin
      Downloader.Status.Caption := 'trying to auth..';
      Downloader.AuthBtn.Enabled := false;
      Downloader.LoginEdit.Enabled := false;
      Downloader.PassEdit.Enabled := false;
      Application.ProcessMessages;
      VK_TOKEN := AuthVK(Downloader.LoginEdit.Text, Downloader.PassEdit.Text);
      if VK_TOKEN <> 'null' then
      begin
        Downloader.Status.Caption := 'authorized!';
        http := tidhttp.Create(nil);
        ssl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
        http.IOHandler := ssl;
        http.Request.UserAgent :=
          'Opera/9.80 (Windows NT 6.1; Win64; x64) Presto/2.12.388 Version/12.17';
        http.ReadTimeout := 7000;
        http.ConnectTimeout := 7000;
        html := http.Get
          ('https://api.vk.com/method/friends.get?order=hints&fields=name&access_token='
          + VK_TOKEN);
        FList := TStringList.Create;
        ParsList('{', html, '}', FList, true);
        for i := 0 to FList.Count - 1 do
        begin
          FriendList.Add(Pars('first_name":"', FList[i], '"') + ' ' +
            Pars('last_name":"', FList[i], '"') + '[' + Pars('id":', FList[i],
            ',') + ']');
          Downloader.Label2.Caption := IntToStr(FriendList.Count);
        end;
        Downloader.ListBox1.Items := FriendList;
        FList.Free;
        Downloader.Edit1.Enabled := true;
        Downloader.Edit2.Enabled := true;
        Downloader.Button1.Enabled := true;
        Downloader.Button2.Enabled := true;
        Downloader.Button3.Enabled := true;
        Downloader.ListBox1.Enabled := true;
      end
      else
      begin
        Downloader.Status.Caption := 'not authorized..';
        Downloader.AuthBtn.Enabled := true;
        Downloader.LoginEdit.Enabled := true;
        Downloader.PassEdit.Enabled := true;
      end;
    end;
  except
    on E: Exception do
      Downloader.Status.Caption := E.Message;
  end;
end;

procedure TDownloader.Button1Click(Sender: TObject);
begin
  if Edit2.Text <> '' then
    TakeMSG.Create(false);
  Button1.Enabled := false;
  Button2.Enabled := false;
  Button3.Enabled := false;
  ListBox1.Enabled := false;
  Edit1.Enabled := false;
  Edit2.Enabled := false;
end;

procedure TDownloader.Button2Click(Sender: TObject);
begin
  if Edit2.Text <> '' then
    SaveAudio.Create(false);
  Button1.Enabled := false;
  Button2.Enabled := false;
  Button3.Enabled := false;
  ListBox1.Enabled := false;
  Edit1.Enabled := false;
  Edit2.Enabled := false;
end;

procedure TDownloader.Button3Click(Sender: TObject);
begin
  if Edit2.Text <> '' then
    SavePhoto.Create(false);
  Button1.Enabled := false;
  Button2.Enabled := false;
  Button3.Enabled := false;
  ListBox1.Enabled := false;
  Edit1.Enabled := false;
  Edit2.Enabled := false;
end;

procedure TDownloader.Edit1Change(Sender: TObject);
var
  i: integer;
begin
  ListBox1.Clear;
  if (FriendList.Count > -1) then
    for i := 0 to FriendList.Count - 1 do
    begin
      if Pos(Edit1.Text, FriendList.Strings[i]) <> 0 then
        ListBox1.Items.Add(FriendList.Strings[i]);
    end;
  if Edit1.Text = '' then
    ListBox1.Items := FriendList;
  Label2.Caption := IntToStr(ListBox1.Items.Count)
end;

procedure TDownloader.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FriendList.Free;
end;

procedure TDownloader.FormCreate(Sender: TObject);
begin
  FriendList := TStringList.Create;
end;

procedure TDownloader.ListBox1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex > -1 then
  Begin
    Edit2.Text := Pars('[', ListBox1.Items.Strings[ListBox1.ItemIndex], ']');
  End;
end;

{ TakeMSG }

constructor TakeMSG.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
end;

procedure TakeMSG.Execute;
var
  i, offset, allmsg: integer;
  data: TStringList;
  html: string;
begin
  inherited;
  try
    begin
      userid := Downloader.Edit2.Text;
      Downloader.Status.Caption := 'try to download messages from ' + userid +
        ' user dialog';
      http := tidhttp.Create(nil);
      ssl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      http.IOHandler := ssl;
      http.Request.CustomHeaders.Add('X-Requested-With:XMLHttpRequest');
      http.Request.UserAgent :=
        'Opera/9.80 (Windows NT 6.1; Win64; x64) Presto/2.12.388 Version/12.17';
      http.ReadTimeout := 7000;
      http.ConnectTimeout := 7000;
      data := TStringList.Create;
      offset := 0;
      data.Add('offset=' + IntToStr(offset));
      data.Add('count=200');
      data.Add('user_id=' + userid);
      data.Add('access_token=' + VK_TOKEN);
      html := http.Post('https://api.vk.com/method/messages.getHistory', data);
      allmsg := StrToInt(Pars('response":[', html, ','));
      if allmsg > 0 then
      begin
        allmsgs := allmsgs + #13#10 + html;
        for i := 1 to (allmsg div 200) do
        begin

          data.Clear;
          offset := offset + 200;
          if i <> (allmsg div 200) then
            Downloader.Status.Caption := 'Downloading(' + IntToStr(offset) + '/'
              + IntToStr(allmsg) + ')'
          else
            Downloader.Status.Caption := 'Downloading(' +
              IntToStr(offset + (allmsg - offset)) + '/' +
              IntToStr(allmsg) + ')';
          data.Add('offset=' + IntToStr(offset));
          if i <> (allmsg div 200) then
            data.Add('count=200')
          else
            data.Add('count=' + IntToStr(allmsg - offset));
          data.Add('user_id=' + userid);
          data.Add('access_token=' + VK_TOKEN);
          html := http.Post
            ('https://api.vk.com/method/messages.getHistory', data);
          Sleep(Random(300));
          allmsgs := allmsgs + #13#10 + html;
          if Downloader.CheckBox1.Checked then
          SaveToFile;
        end;
        if not(Downloader.CheckBox1.Checked) then
          SaveToFile;
        Downloader.Status.Caption := 'Complete!';
      end;
    end;
  except
    on E: Exception do
      Downloader.Status.Caption := E.Message;
  end;
  Downloader.Button1.Enabled := true;
  Downloader.Button2.Enabled := true;
  Downloader.Button3.Enabled := true;
  Downloader.ListBox1.Enabled := true;
  Downloader.Edit1.Enabled := true;
  Downloader.Edit2.Enabled := true;
end;

function UTimeToDate(UnixTime: LongWord): TDateTime;
begin
  Result := (UnixTime / 86400) + 25569;
end;

procedure TakeMSG.SaveToFile;
var
  MsgText: TStringList;
  s, resp, resm, reso: string;
  date: string;
  i: integer;
begin
  try
    begin
      if not DirectoryExists(ExtractFilePath(Application.ExeName) + userid) then
        ForceDirectories(ExtractFilePath(Application.ExeName) + userid);
      MsgText := TStringList.Create;
      MsgText.Text := allmsgs;
      MsgText.SaveToFile(ExtractFilePath(Application.ExeName) + userid +
        '\MainMSGS.text');
      MsgText.Clear;
      ParsList('"attachments":', allmsgs, '}', MsgText, true);
      MsgText.SaveToFile(ExtractFilePath(Application.ExeName) + userid +
        '\AttachmetsMSGS.text');
      for i := 0 to MsgText.Count - 1 do
      begin
        if Pos('"type":"sticker"', MsgText[i]) = 0 then
        begin
          s := Pars('url":"', MsgText[i], '"');
          if s = '' then
            s := Pars('"src_xxbig":"', MsgText[i], '"');
          if s = '' then
            s := Pars('"src_xbig":"', MsgText[i], '"');
          if s = '' then
            s := Pars('"src_big":"', MsgText[i], '"');
          if s = '' then
            s := Pars('"src":"', MsgText[i], '"');
          s := StringReplace(s, '\/', '/', [rfReplaceAll, rfIgnoreCase]);
          date := Pars('"date":', MsgText[i], ',');
          if date = '' then
            date := Pars('"created":', MsgText[i], ',');
          try
            date := DateTimeToStr(UTimeToDate(StrToInt64(date)));
          except
            date := '?';
          end;
          MsgText[i] := s + ' (' + date + ')';

        end;
      end;
      i := 0;
      while Pos('"type":"sticker"', MsgText.Text) <> 0 do
      begin
        if Pos('"type":"sticker"', MsgText[i]) <> 0 then
          MsgText.Delete(i)
        else
          Inc(i);
      end;

      if MsgText.Text <> '' then
        MsgText.SaveToFile(ExtractFilePath(Application.ExeName) + userid +
          '\msg_attachmets.txt');
      for i := 0 to MsgText.Count - 1 do
      begin
        if Pos('.mp3', MsgText[i]) <> 0 then
          if resm = '' then
            resm := MsgText[i]
          else
            resm := resm + #13#10 + MsgText[i]
        else if (Pos('.jpg', MsgText[i]) <> 0) or (Pos('.png', MsgText[i]) <> 0)
        then
          if resp = '' then
            resp := MsgText[i]
          else
            resp := resp + #13#10 + MsgText[i]
        else if reso = '' then
          reso := MsgText[i]
        else
          reso := reso + #13#10 + MsgText[i]
      end;
      MsgText.Clear;
      MsgText.Text := resm;
      if MsgText.Text <> '' then
        MsgText.SaveToFile(ExtractFilePath(Application.ExeName) + userid +
          '\msg_audio.txt');
      MsgText.Clear;
      MsgText.Text := resp;
      if MsgText.Text <> '' then
        MsgText.SaveToFile(ExtractFilePath(Application.ExeName) + userid +
          '\msg_photo.txt');
      MsgText.Clear;
      MsgText.Text := reso;
      if MsgText.Text <> '' then
        MsgText.SaveToFile(ExtractFilePath(Application.ExeName) + userid +
          '\msg_other_attachments.txt');
      MsgText.Free;
    end;
  except
    on E: Exception do
      Downloader.Status.Caption := E.Message;
  end;
end;

{ SaveAudio }

constructor SaveAudio.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
end;

procedure SaveAudio.Execute;
var
  F: TFileStream;
  FileList: TStringList;
  i: integer;
  name, link: string;
begin
  inherited;
  try
    begin
      userid := Downloader.Edit2.Text;
      http := tidhttp.Create(nil);
      ssl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      http.IOHandler := ssl;
      http.Request.CustomHeaders.Add('X-Requested-With:XMLHttpRequest');
      http.Request.UserAgent :=
        'Opera/9.80 (Windows NT 6.1; Win64; x64) Presto/2.12.388 Version/12.17';
      FileList := TStringList.Create;
      if FileExists(ExtractFilePath(Application.ExeName) + userid +
        '\msg_audio.txt') then
      begin
        FileList.LoadFromFile(ExtractFilePath(Application.ExeName) + userid +
          '\msg_audio.txt');
        if not DirectoryExists(ExtractFilePath(Application.ExeName) + userid +
          '\audio') then
          ForceDirectories(ExtractFilePath(Application.ExeName) + userid +
            '\audio');
        Downloader.Status.Caption := 'Start downloading messsges audio..';
        for i := 0 to FileList.Count - 1 do
        begin
          Downloader.Status.Caption := 'Downloading(' + IntToStr(i + 1) + '\' +
            IntToStr(FileList.Count) + ')';
          try
            begin
              name := Pars('(', FileList[i], ')');
              name := StringReplace(name, ':', '_',
                [rfReplaceAll, rfIgnoreCase]);
              link := Trim('h' + Pars('h', FileList[i], ' ('));
              F := TFileStream.Create(ExtractFilePath(Application.ExeName) +
                userid + '\audio\' + name + '.mp3', fmCreate);
              http.Get(link, F);
              F.Free;
            end;
          except

          end;
        end;
        Downloader.Status.Caption := 'Complete!';

      end
      else
        Downloader.Status.Caption := 'File "' +
          ExtractFilePath(Application.ExeName) + userid + '\msg_audio.txt' +
          '" doesn`t exist';
      FileList.Free;
    end;
  except
    on E: Exception do
      Downloader.Status.Caption := E.Message;
  end;
  Downloader.Button1.Enabled := true;
  Downloader.Button2.Enabled := true;
  Downloader.Button3.Enabled := true;
  Downloader.ListBox1.Enabled := true;
  Downloader.Edit1.Enabled := true;
  Downloader.Edit2.Enabled := true;
end;

constructor SavePhoto.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
end;

procedure SavePhoto.Execute;
var
  F: TFileStream;
  FileList: TStringList;
  i: integer;
  name, link: string;
begin
  inherited;
  try
    begin
      userid := Downloader.Edit2.Text;
      http := tidhttp.Create(nil);
      ssl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      http.IOHandler := ssl;
      http.Request.UserAgent :=
        'Opera/9.80 (Windows NT 6.1; Win64; x64) Presto/2.12.388 Version/12.17';
      FileList := TStringList.Create;
      if FileExists(ExtractFilePath(Application.ExeName) + userid +
        '\msg_photo.txt') then
      begin
        FileList.LoadFromFile(ExtractFilePath(Application.ExeName) + userid +
          '\msg_photo.txt');
        if not DirectoryExists(ExtractFilePath(Application.ExeName) + userid +
          '\photo') then
          ForceDirectories(ExtractFilePath(Application.ExeName) + userid +
            '\photo');
        Downloader.Status.Caption := 'Start downloading messsges photo..';
        for i := 0 to FileList.Count - 1 do
        begin
          Downloader.Status.Caption := 'Downloading(' + IntToStr(i + 1) + '\' +
            IntToStr(FileList.Count) + ')';
          try
            begin
              name := Pars('(', FileList[i], ')');
              name := StringReplace(name, ':', '_',
                [rfReplaceAll, rfIgnoreCase]);
              link := Trim('h' + Pars('h', FileList[i], ' ('));
                                          F := TFileStream.Create(ExtractFilePath(Application.ExeName) +
                userid + '\photo\' + name + '.jpg', fmCreate);
              http.Get(link,f);
              Application.ProcessMessages;
              F.Free;
            end;
          except

          end;
        end;
        Downloader.Status.Caption := 'Complete!';

      end
      else
        Downloader.Status.Caption := 'File "' +
          ExtractFilePath(Application.ExeName) + userid + '\msg_photo.txt' +
          '" doesn`t exist';
      FileList.Free;
    end;
  except
    on E: Exception do
      Downloader.Status.Caption := E.Message;
  end;
  Downloader.Button1.Enabled := true;
  Downloader.Button2.Enabled := true;
  Downloader.Button3.Enabled := true;
  Downloader.ListBox1.Enabled := true;
  Downloader.Edit1.Enabled := true;
  Downloader.Edit2.Enabled := true;
end;

end.
