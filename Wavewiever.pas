unit Unit1;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TeEngine, Series, ExtCtrls, TeeProcs, Chart;
type
  TForm1 = class(TForm)
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Chart1: TChart;
    Chart2: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series3: TLineSeries;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Series6: TLineSeries;
    Button2: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Series7: TLineSeries;
    Series8: TLineSeries;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    Procedure filtersNK(nk:integer{Sta/Lta};ns{порядок} : integer{номер ф-ра}; var data: real);
    procedure BpDes(f1,f2,tstep:real; ns:byte; i:byte { var a,b,c,d,e: array of real});
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
  tt:textfile;
   f_data:array[0..7,0..6,0..4] of real;
  a,b,c,d,e:array[0..7,0..6] of real;
implementation
{$R *.dfm}
   procedure TForm1.BpDes(f1,f2,tstep:real; ns:byte; i:byte { var a,b,c,d,e: array of real});
 Var  w1,w2,wc,q,s,cs,p,r,x : real;
      k : byte;
 Begin
    w1:= sin(f1*pi*tstep)/cos(f1*pi*tstep);
    w2:= sin(f2*pi*tstep)/cos(f2*pi*tstep);
    wc:= w2-w1;
    q:= wc*wc+2.*w1*w2;
    s:= w1*w1*w2*w2;
    for k:=0 to ns-1 do
     begin
    	cs:= cos((2*(k+ns+1)-1)*pi/(4*ns));
    	p:= -2.*wc*cs;
    	r:= p*w1*w2;
    	x:= 1.+p+q+r+s;
    	a[i,k]:= wc*wc/x;
    	b[i,k]:= (-4.-2.*p+2.*r+4.*s)/x;
    	c[i,k]:= (6.-2.*q+6.*s)/x;
    	d[i,k]:= (-4.+2.*p-2.*r+4.*s)/x;
    	e[i,k]:= (1.-p+q-r+s)/x;
     end;
 End;
Procedure TForm1.filtersNK(nk:integer{Sta/Lta};ns{порядок} : integer{номер ф-ра}; var data: real);
Var n,m : integer;
{    f : array[0..7,0..6,0..4] of real;}
    temp : real;
    //nk:byte;
Begin
  f_data[nk,0,4]:= data;
  For n:=0 to ns-1 do  Begin
    temp:= a[nk,n]*(f_data[nk,n,4]-2.*f_data[nk,n,2]+f_data[nk,n,0]);
    f_data[nk,n+1,4]:= temp-b[nk,n]*f_data[nk,n+1,3]-c[nk,n]*f_data[nk,n+1,2]-d[nk,n]*f_data[nk,n+1,1]-e[nk,n]*f_data[nk,n+1,0];
                       End;
  For n:=0 to ns do  for m:=0 to 4-1 do  f_data[nk,n,m] := f_data[nk,n,m+1];
  data:=f_data[nk,ns,4];
End;

procedure TForm1.Button1Click(Sender: TObject);
 var
 s: string;
 i:integer;
 a, b, c, d: string;
 k: integer;
 zz: string;
begin
//i:=1;
 if OpenDialog1.Execute then begin
 Series1.Clear;
 Series2.Clear;
 Series3.Clear;
 Series7.Clear;
   {i-}
   assignfile(tt,Opendialog1.FileName);
   reset(tt);
   {i+}
   while not eof(tt) do begin
          {i-}
          readln(tt,s);
          {i+}
          k:=1;
          a:='';
          b:='';
          c:='';
          d:='';
          zz:='';
           for i:=1 to length(s) do begin
                                 zz:=copy(s,i,1);
                                 //if (zz<>#9) and (k=1) then a:=a+zz;
                                 //if (zz<>#9) and (k=2) then b:=b+zz;
                                 //if (zz<>#9) and (k=3) then c:=c+zz;
                                 //if (zz<>#9) and (k=4) then d:=d+zz;
                                 //if zz=#9 then k:=k+1;
                                    end;
             Series1.AddY(strtoint(s));
             //Series2.AddY(strtoint(b));
             //Series3.AddY(strtoint(c));
             //Series7.AddY(strtoint(d));
                    end;
                    closefile(tt);
end;
end;
procedure TForm1.Button2Click(Sender: TObject);
var
i,ord:integer;
z,fn,fv:real;
begin
Series4.Clear;
Series5.Clear;
Series6.Clear;
Series8.Clear;
fn:=strtofloat(combobox1.Text);
fv:=strtofloat(combobox2.Text);
ord:=strtoint(combobox3.Text);
BpDes(fn,fv,0.01,ord,1);
for i:=series1.FirstValueIndex to series1.LastValueIndex do begin
                                 z:=series1.YValue[i];
                                 filtersNK(1,ord,z);
                                 Series4.AddXY(i,z);
                                                          end;
BpDes(fn,fv,0.01,ord,2);
for i:=series2.FirstValueIndex to series2.LastValueIndex do begin
                                 z:=series2.YValue[i];
                                 filtersNK(2,ord,z);
                                 Series5.AddXY(i,z);
                                                          end;
 BpDes(fn,fv,0.01,ord,3);
for i:=series3.FirstValueIndex to series3.LastValueIndex do begin
                                 z:=series3.YValue[i];
                                 filtersNK(3,ord,z);
                                 Series6.AddXY(i,z);
                                                          end;
BpDes(fn,fv,0.01,ord,4);
for i:=series7.FirstValueIndex to series7.LastValueIndex do begin
                                 z:=series7.YValue[i];
                                 filtersNK(4,ord,z);
                                 Series8.AddXY(i,z);
                                                          end;
end;
end.
