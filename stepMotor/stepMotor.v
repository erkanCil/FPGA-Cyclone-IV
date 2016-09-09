/*******************************************************************************
 * @dosya    stepMotor  Uygulaması
 * @yazar    Erkan ÇİL
 * @sürüm    V0.0.1
 * @tarih    09-Ağustos-2016
 * @özet     Cyclone IV EP4CE6 FPGA stepMotor  Uygulaması 
 * 
 * Bu örnek uygulamada, Cyclone IV EP4CE6 FPGA kartı ile stepMotor kontrol edilecektir.  
 ******************************************************************************
 *
 * Bu program özgür yazılımdır: Özgür Yazılım Vakfı tarafından yayımlanan GNU 
 * Genel Kamu Lisansı’nın sürüm 3 ya da (isteğinize bağlı olarak) daha sonraki
 * sürümlerinin hükümleri altında yeniden dağıtabilir ve/veya değiştirebilirsiniz.
 *
 ******************************************************************************/
module stepMotor (saatDarbesi,rst,motorCikis);
// stepMotor  MODÜLÜ TANIMI

//-------------Giriş Portları-----------------------------
input saatDarbesi,rst;     //saatDarbesi, rst giriş olarak tanımlanmıştır

//-------------Çıkış Portları-----------------------------	
output [3:0] motorCikis;  //motorCikis 12 bitlik çıkış olarak tanımlanmıştır

//-------------Çıkış Portları Veri Tipleri------------------ 
// Çıkış portları bellek elemanı(reg-yazmaç) veya bir tel olabilir
reg [3:0] motorCikis;	//motorCikis register(kayıtcısının oluşturulması)
reg [31:0] sayac; //sayac register(kayıtcısının oluşturulması)
reg [1:0] yon;
//------------Kod Burada Başlamaktadır------------------------- 
// Ana döngü bloğu
// Bu sayaç yükselen kenar tetiklemeli olduğundan,
// Bu bloğu saatin yükselen kenarına veya,
// reset butonun alçalan kenarına göre tetikleyeceğiz.
always @ ( posedge saatDarbesi )
 begin
  sayac<=sayac+1;
 end

always @ ( posedge saatDarbesi or negedge rst)
begin
case(sayac[29:29])
0: 
 begin
  case ( sayac[18:16] ) //case döngüsünün sayaç ile döndürülmesi
  // 4 bitlik stepMotor çıkış değerlerinin registere ve oradanda çıkışa aktarılması
  0: motorCikis<=4'b0001;
  
  1: motorCikis<=4'b0011;
  
  2: motorCikis<=4'b0010;
  
  3: motorCikis<=4'b0110;
  
  4: motorCikis<=4'b0100;
  
  5: motorCikis<=4'b1100;
  
  6: motorCikis<=4'b1000;
    
  7: motorCikis<=4'b1001; 
  
  default: 
		motorCikis<=4'b0000;
    endcase
  end

1: begin 
  
  case ( sayac[18:16] ) //case döngüsünün sayaç ile döndürülmesi
  // 4 bitlik stepMotor çıkış değerlerinin registere ve oradanda çıkışa aktarılması
  0: motorCikis<=4'b1001;
  
  1: motorCikis<=4'b1000;
  
  2: motorCikis<=4'b1100;
  
  3: motorCikis<=4'b0100;
  
  4: motorCikis<=4'b0110;
  
  5: motorCikis<=4'b0010;
  
  6: motorCikis<=4'b0011;
    
  7: motorCikis<=4'b0001; 
  
  default: 
		motorCikis<=4'b0000;
  endcase
  end
  endcase
 end
endmodule //  stepMotor  MODÜLÜ SONU










