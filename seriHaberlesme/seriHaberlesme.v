/*******************************************************************************
 * @dosya    Seri Haberleşme(RS232 serial) Uygulaması
 * @yazar    Erkan ÇİL
 * @sürüm    V0.0.1
 * @tarih    04-Eylül-2016
 * @özet     Cyclone IV EP4CE6 FPGA Seri Haberleşme Uygulaması 
 * 
 * Bu örnek uygulamada, Cyclone IV EP4CE6 FPGA kartını ile Seri Haberleşme bağlantısı
 * üretilecek, bu durumlar Display Gösterge üzerinde gösterilecektir edilecektir. 
 ******************************************************************************
 *
 * Bu program özgür yazılımdır: Özgür Yazılım Vakfı tarafından yayımlanan GNU 
 * Getkinel Kamu Lisansı’nın sürüm 3 ya da (isteğinize bağlı olarak) daha sonraki
 * sürümlerinin hükümleri altında yeniden dağıtabilir ve/veya değiştirebilirsiniz.
 *
 ******************************************************************************/
module seriHaberlesme(saatDarbesi,sifirlama,gelenVeri,gidenVeri,etkin,display,girisButon,dusukBit);
// seriHaberlesme MODÜLÜ TANIMI

//-------------Giriş Portları-----------------------------
input 				saatDarbesi,sifirlama;
input 				gelenVeri;
input 				girisButon;

//-------------Çıkış Portları-----------------------------
output[7:0] 		etkin;
output[7:0] 		display;
output 				gidenVeri;
output 				dusukBit;

//-------------Parametre Tanımlamaları--------------------
parameter 
	baudBolmeSabiti=16'h145, 	//9600 Baud için(saatDarbesi 50MHz)
	durum0=8'h30,					//0. durum
	durum1=8'h31,					//1. durum
	durum2=8'h32,					//2. durum
	durum3=8'h33,					//3. durum
	durum4=8'h34,					//4. durum
	durum5=8'h35,					//5. durum
	durum6=8'h36,					//6. durum
	durum7=8'h37,					//7. durum
	durum8=8'h38,					//8. durum
	durum9=8'h39,					//9. durum
	durumA=8'h41,					//A. durum
	durumB=8'h42,					//B. durum
	durumC=8'h43,					//C. durum
	durumD=8'h44,					//D. durum
	durumE=8'h45,					//E. durum
	durumF=8'h46;					//F. durum

//-------------Çıkış Portları Veri Tipleri------------------ 
// Çıkış portları bellek elemanı(reg-yazmaç) veya bir tel olabilir	
reg[15:0] 			bolmeKaydedici;
reg[2:0]  			bol8gideniKaydedici;
reg[2:0]  			bol8gelenKaydedici;
reg[3:0] 			gidenDurumu;
reg[3:0] 			gelenDurumu;
reg[7:0] 			etkin;
reg[7:0] 			gelenVeriTampon;
reg[7:0] 			gidenVeriTampon;
reg[4:0] 			gondermeDurumu;
reg[19:0] 			beklemeSayaci;
reg[7:0] 			display;

reg 					gidenBaudSaatDarbesi;
reg 					gelenBaudSaatDarbesi;
reg 					baudx8SaatDarbesi;
reg 					gelenBasla;
reg 					gelenBaslaGecici;
reg 					gidenBasla;
reg 					gelenVeriKaydedici1;
reg 					gelenVeriKaydedici2;
reg 					gidenVeriKaydedici;
reg 					beklemeSayaciBasla;
reg 					butonGiris1,butonGiris2;

//-------------Doğrusal Tanımlamalar-------------------------
assign gidenVeri=gidenVeriKaydedici;
assign dusukBit=0;

//------------Kod Burada Başlamaktadır------------------------- 
// Ana döngü bloğu
// Bu sayaç yükselen kenar tetiklemeli olduğundan,
// Bu bloğu saatin yükselen kenarına göre tetikleyeceğiz.
always@(posedge saatDarbesi)
begin
	if(!sifirlama) begin 
		beklemeSayaci<=0;
		beklemeSayaciBasla<=0;
	 end
	else if(beklemeSayaciBasla) begin
		if(beklemeSayaci!=20'd800000) begin
			beklemeSayaci<=beklemeSayaci+1;
		 end
		else begin
			beklemeSayaci<=0;
			beklemeSayaciBasla<=0;
		 end
	 end
	else begin
		if(!girisButon&&beklemeSayaci==0)
				beklemeSayaciBasla<=1;
	 end
end

always@(posedge saatDarbesi)
begin
	if(!sifirlama) 
		butonGiris1<=0;
	else begin
		if(butonGiris2)
			butonGiris1<=0;
		else if(beklemeSayaci==20'd800000) begin
			if(!girisButon)
				butonGiris1<=1;
		 end
	 end
end

always@(posedge saatDarbesi )
begin
	if(!sifirlama)
		bolmeKaydedici<=0;
	else begin
		if(bolmeKaydedici==baudBolmeSabiti-1)
			bolmeKaydedici<=0;
		else
			bolmeKaydedici<=bolmeKaydedici+1;
	 end
end

always@(posedge saatDarbesi)
begin
	if(!sifirlama)
		baudx8SaatDarbesi<=0;
	else if(bolmeKaydedici==baudBolmeSabiti-1)
		baudx8SaatDarbesi<=~baudx8SaatDarbesi;
end


always@(posedge baudx8SaatDarbesi or negedge sifirlama)
begin
	if(!sifirlama)
		bol8gelenKaydedici<=0;
	else if(gelenBasla)
		bol8gelenKaydedici<=bol8gelenKaydedici+1;
end

always@(posedge baudx8SaatDarbesi or negedge sifirlama)
begin
	if(!sifirlama)
		bol8gideniKaydedici<=0;
	else if(gidenBasla)
		bol8gideniKaydedici<=bol8gideniKaydedici+1;
end

always@(bol8gelenKaydedici)
begin
	if(bol8gelenKaydedici==7)
		gelenBaudSaatDarbesi=1;
	else
		gelenBaudSaatDarbesi=0;
end

always@(bol8gideniKaydedici)
begin
	if(bol8gideniKaydedici==7)
		gidenBaudSaatDarbesi=1;
	else
		gidenBaudSaatDarbesi=0;
end
// Bilgisayara Bilgi Gönderme
always@(posedge baudx8SaatDarbesi or negedge sifirlama)
begin
	if(!sifirlama) begin
		gidenVeriKaydedici<=1;
		gidenBasla<=0;
		gidenVeriTampon<=0;
		gidenDurumu<=0;
		gondermeDurumu<=0;
		butonGiris2<=0;
	 end
	else begin
		if(!butonGiris2) begin
			if(butonGiris1) begin
				butonGiris2<=1;
			 end
		 end
		else  begin
			case(gidenDurumu)
				4'b0000: begin  //BAŞLAMA Biti
					if(!gidenBasla&&gondermeDurumu<16) 
						gidenBasla<=1;
					else if(gondermeDurumu<16) begin
						if(gidenBaudSaatDarbesi) begin
							gidenVeriKaydedici<=0;
							gidenDurumu<=gidenDurumu+1;
						 end
					 end
					else begin
						butonGiris2<=0;
						gidenDurumu<=0;
					 end					
				end		
				4'b0001: begin //0. Giden Bit
					if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=gidenVeriTampon[0];
						gidenVeriTampon[7:0]<=gidenVeriTampon[7:1];
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				4'b0010: begin //1. Giden Bit
					if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=gidenVeriTampon[0];
						gidenVeriTampon[7:0]<=gidenVeriTampon[7:1];
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				 4'b0011: begin //2. Giden Bit
				 	if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=gidenVeriTampon[0];
						gidenVeriTampon[7:0]<=gidenVeriTampon[7:1];
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				4'b0100: begin //3. Giden Bit
					if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=gidenVeriTampon[0];
						gidenVeriTampon[7:0]<=gidenVeriTampon[7:1];
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				4'b0101: begin //4. Giden Bit
					if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=gidenVeriTampon[0];
						gidenVeriTampon[7:0]<=gidenVeriTampon[7:1];
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				4'b0110: begin //5. Giden Bit
					if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=gidenVeriTampon[0];
						gidenVeriTampon[7:0]<=gidenVeriTampon[7:1];
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				4'b0111: begin //6. Giden Bit
					if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=gidenVeriTampon[0];
						gidenVeriTampon[7:0]<=gidenVeriTampon[7:1];
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				4'b1000: begin //7. Giden Bit
					if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=gidenVeriTampon[0];
						gidenVeriTampon[7:0]<=gidenVeriTampon[7:1];
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				4'b1001: begin //BİTİRME Biti
					if(gidenBaudSaatDarbesi) begin
						gidenVeriKaydedici<=1;
						gidenVeriTampon<=8'h55;
						gidenDurumu<=gidenDurumu+1;
					 end
				 end
				4'b1111:begin 
					if(gidenBaudSaatDarbesi) begin
						gidenDurumu<=gidenDurumu+1;
						gondermeDurumu<=gondermeDurumu+1;
						gidenBasla<=0;
						case(gondermeDurumu)
							4'b0000:
								gidenVeriTampon<=8'd77;		//"M"
							4'b0001:
								gidenVeriTampon<=8'd101;	//"e"
							4'b0010:
								gidenVeriTampon<=8'd114;	//"r"
							4'b0011:
								gidenVeriTampon<=8'd104;	//"h"
							4'b0100:
								gidenVeriTampon<=8'd97;		//"a"
							4'b0101:
								gidenVeriTampon<=8'd98;		//"b"
							4'b0110:
								gidenVeriTampon<=8'd97;		//"a"
							4'b0111:
								gidenVeriTampon<=8'd32;	//"Boşluk"
							4'b1000:
								gidenVeriTampon<=8'd68;		//"D"
							4'b1001:
								gidenVeriTampon<=8'd117;	//"u"
							4'b1010:
								gidenVeriTampon<=8'd110;	//"n"
							4'b1011:
								gidenVeriTampon<=8'd121;	//"y"
							4'b1100:
								gidenVeriTampon<=8'd97;		//"a"
							4'b1101:
								gidenVeriTampon<=8'd10;		//"yeniSatır"
							4'b1110:
								gidenVeriTampon<=8'd13;		//"satırBaşı/carriageReturn"
							default:
								gidenVeriTampon<=0;
						 endcase
					 end
				 end
				default: begin
					if(gidenBaudSaatDarbesi) begin
						gidenDurumu<=gidenDurumu+1;
						gidenBasla<=1;
					 end
				 end
			 endcase
		 end
	 end
end
// Bilgisayardan Gelen Bilgiyi karşılama 
always@(posedge baudx8SaatDarbesi or negedge sifirlama)
begin
	if(!sifirlama) begin
		gelenVeriKaydedici1<=0;
		gelenVeriKaydedici2<=0;
		gelenVeriTampon<=0;
		gelenDurumu<=0;
		gelenBasla<=0;
		gelenBaslaGecici<=0;
	 end
	else  begin
		 gelenVeriKaydedici1<=gelenVeri;
		 gelenVeriKaydedici2<=gelenVeriKaydedici1;
		 if(gelenDurumu==0) begin
			 if(gelenBaslaGecici==1) begin
		 		gelenBasla<=1;
		 		gelenBaslaGecici<=0;
				gelenDurumu<=gelenDurumu+1;
		  	  end
		 	 else if(!gelenVeriKaydedici1&&gelenVeriKaydedici2)
				gelenBaslaGecici<=1;
		   end
		 else if(gelenDurumu>=1&&gelenDurumu<=8) begin
		 	 if(gelenBaudSaatDarbesi) begin
			 	gelenVeriTampon[7]<=gelenVeriKaydedici2;
				gelenVeriTampon[6:0]<=gelenVeriTampon[7:1];
				gelenDurumu<=gelenDurumu+1;
			  end
		  end
		 else if(gelenDurumu==9) begin
		 	if(gelenBaudSaatDarbesi) begin
		 		gelenDurumu<=0;
				gelenBasla<=0;
			 end
		  end
	  end
end

always@(gelenVeriTampon) //??????????????
begin
      case (gelenVeriTampon)
		durum0:						//durum0
		begin				 	
			display<=8'b1100_0000;//display göstergeye 0 değeri gönderilmesi
		  	  etkin<=8'b1111_1110;//1. display gösterge aktif 
		end
		
		durum1:						 //durum1
		begin	
			display<=8'b1111_1001;//display göstergeye 1 değeri gönderilmesi
			  etkin<=8'b1111_1101;//2. display gösterge aktif
		end
		
		durum2:					 	//durum2
		begin
			display<=8'b1010_0100;//display göstergeye 2 değeri gönderilmesi
			  etkin<=8'b1111_1011;//3. display gösterge aktif 
		end
		
		durum3:					 	//durum3
		begin	
			display<=8'b1011_0000;//display göstergeye 3 değeri gönderilmesi
			  etkin<=8'b1111_0111;//4. display gösterge aktif 
		end
		
		durum4:						//durum4
		begin	
			display<=8'b1001_1001;//display göstergeye 4 değeri gönderilmesi
			  etkin<=8'b1110_1111;//5. display gösterge aktif 
		end
		
		durum5:					 	//durum5
		begin	
			display<=8'b1001_0010;//display göstergeye 5 değeri gönderilmesi
			  etkin<=8'b1101_1111;//6. display gösterge aktif 
		end
		
		durum6:					 	//durum6
		begin
			display<=8'b1000_0010;//display göstergeye 6 değeri gönderilmesi
			  etkin<=8'b1011_1111;//7. display gösterge aktif 
		end
		
		durum7:					 	//durum7
		begin	
			display<=8'b1111_1000;//display göstergeye 7 değeri gönderilmesi
			  etkin<=8'b0111_1111;//8. display gösterge aktif 
		end
		durum8:						//durum8
		begin				 	
			display<=8'b1000_0000;//display göstergeye 0 değeri gönderilmesi
		  	  etkin<=8'b0111_1111;//1. display gösterge aktif 
		end
		
		durum9:						 //durum9
		begin	
			display<=8'b1001_0000;//display göstergeye 1 değeri gönderilmesi
			  etkin<=8'b1011_1111;//2. display gösterge aktif
		end
		
		durumA:					 	//durumA
		begin
			display<=8'b1000_1000;//display göstergeye 2 değeri gönderilmesi
			  etkin<=8'b1101_1111;//3. display gösterge aktif 
		end
		
		durumB:					 	//durumB
		begin	
			display<=8'b1000_0011;//display göstergeye 3 değeri gönderilmesi
			  etkin<=8'b1110_1111;//4. display gösterge aktif 
		end
		
		durumC:						//durumC
		begin	
			display<=8'b1100_0110;//display göstergeye 4 değeri gönderilmesi
			  etkin<=8'b1111_0111;//5. display gösterge aktif 
		end
		
		durumD:					 	//durumD
		begin	
			display<=8'b1010_0001;//display göstergeye 5 değeri gönderilmesi
			  etkin<=8'b1111_1011;//6. display gösterge aktif 
		end
		
		durumE:					 	//durumE
		begin
			display<=8'b1000_0110;//display göstergeye 6 değeri gönderilmesi
			  etkin<=8'b1111_1101;//7. display gösterge aktif 
		end
		
		durumF:					 	//durumF
		begin	
			display<=8'b1000_1110;//display göstergeye 7 değeri gönderilmesi
			  etkin<=8'b1111_1110;//8. display gösterge aktif 
		end
		default:
			display=8'b1111_1111;	// BOŞ DİSPLAY
	 endcase
end	

endmodule //  serial MODÜLÜ SONU
	
