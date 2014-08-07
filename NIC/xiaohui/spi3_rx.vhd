library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.custom.all;
 --8bit mac帧到128 bit tag+ip包
entity spi3_rx is
    port(        
    	-----sys-------
         clk:in std_logic;
         reset_m:in std_logic;
    	----spi rx-------
         spi3_renb_l:out std_logic;    --接收读使能
         spi3_rdat:in std_logic_vector(7 downto 0); -- 接收数据总线
         spi3_rsop:in std_logic;   -- 接收包起始标志
         spi3_reop:in std_logic;   --接收包结束标志
         spi3_rerr:in std_logic;   --接收错误
         spi3_rprty:in std_logic;  --接收奇偶校验
         spi3_rval:in std_logic;   --接收数据有效指示
    	--------rx fifo---
         rxfifo_wrreq:buffer std_logic;
         rxfifo_data:out std_logic_vector(134 downto 0);
		   rxfifo_almost_empty:in std_logic
         );
end spi3_rx;
architecture logicfunc of spi3_rx is 
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=*=*=*=
signal reset:std_logic;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*portx_interface=*=*=*=*=*=*=*=*=*=*=*=*=*=
--signal portx_status:state_type_portx;
--constant portx_idle:integer:=0;
--constant portx_1d:integer:=1;
--constant portx_2d:integer:=2;
--constant portx_write_or_read:integer:=3;
--constant portx_write:integer:=4;
--constant portx_read:integer:=5;
--constant portx_wait:integer:=6;

--signal spi3rxbase:std_logic_vector(15 downto 0);
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=

signal spi3rx_status:state_type_spi3rx;

--constant spi3_sop:integer:=0;
--constant spi3_data0:integer:=14;
--constant spi3_data1:integer:=15;
--constant spi3_data2:integer:=16;
--constant spi3_data3:integer:=17;
--constant spi3_data4:integer:=18;
--constant spi3_data5:integer:=19;
--constant spi3_data6:integer:=20;
--constant spi3_data7:integer:=21;
--constant spi3_data8:integer:=22;
--constant spi3_data9:integer:=23;
--constant spi3_data10:integer:=24;
--constant spi3_data11:integer:=25;
--constant spi3_data12:integer:=26;
--constant spi3_data13:integer:=27;
--constant spi3_data14:integer:=28;
--constant spi3_data15:integer:=29;

--in
signal spi3_renb_l_out:std_logic;


signal dat_in:std_logic_vector(7 downto 0);
signal sop_in:std_logic;
signal eop_in:std_logic;
signal err_in:std_logic;
signal val_in:std_logic;


--out
signal out_stb:std_logic;

signal rxfifo_wrreq_out:std_logic;
signal data128:std_logic_vector(127 downto 0);
signal sop_out:std_logic;
signal eop_out:std_logic;
signal mty_out:std_logic_vector(3 downto 0);
signal err_out:std_logic;
signal rxfifo_data_out:std_logic_vector(134 downto 0); 




------------mib

begin
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=
reset<=reset_m;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*portx_interface=*=*=*=*=*=*=*=*=*=*=

-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=


dat_in<=spi3_rdat;
sop_in<=spi3_rsop;
eop_in<=spi3_reop;
err_in<=spi3_rerr;
val_in<=spi3_rval;

---status    
process(clk,reset)
    begin
        if reset='1' then
            spi3rx_status<=spi3rx_sop;
        elsif clk'event and clk='1' then
           case spi3rx_status is 
              when spi3rx_sop=>		if val_in='1' and sop_in='1' then
										spi3rx_status<=spi3rx_data1;
									end if;

              when spi3rx_data0=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data1;
									end if;
									
              when spi3rx_data1=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data2;
									end if;
									
              when spi3rx_data2=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data3;
									end if;
									
              when spi3rx_data3=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data4;
									end if;
                                
              when spi3rx_data4=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data5;
									end if;
                                
              when spi3rx_data5=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data6;
									end if;
                                
              when spi3rx_data6=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data7;
									end if;
                                
              when spi3rx_data7=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data8;
									end if;
                                
              when spi3rx_data8=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data9;
									end if;
                                
              when spi3rx_data9=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data10;
									end if;
                                
              when spi3rx_data10=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data11;
									end if;
                                
              when spi3rx_data11=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data12;
									end if;
                                
              when spi3rx_data12=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data13;
									end if;
                                
              when spi3rx_data13=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data14;
									end if;
                                
              when spi3rx_data14=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data15;
									end if;
									
              when spi3rx_data15=>	if val_in='1' and eop_in='1' then 
										spi3rx_status<=spi3rx_sop;
									elsif val_in='1' then
										spi3rx_status<=spi3rx_data0;
									end if;

              when others=>spi3rx_status<=spi3rx_sop;
              end case;
          end if;
      end process;
      
----in 
spi3_renb_l_out<='0';
spi3_renb_l<=spi3_renb_l_out; 
--spi3_rprty<='1';

--      process(clk,reset)
--          begin
--              if reset='1' then 
--                 wtype1<=(others=>'0');
--              elsif clk'event and clk='1' then
--				 if spi3_rval='1' and spi3_status=spi3_type1 then
--					wtype1<=spi3_rdat;
--				 end if;
--			  end if;
--		  end process;
		

--out
      process(clk,reset)
          begin
             if reset='1' then 
                 out_stb<='0';
             elsif clk'event and clk='1' then
				if spi3rx_status=spi3rx_sop and val_in='1' and sop_in='1'then
					if rxfifo_almost_empty='1' then
						out_stb<='1';
					else
						out_stb<='0';
					end if;
				end if;
             end if;
		end process;
          
      process(clk,reset)
      begin
		if reset='1' then 
		data128<=(others=>'0'); -- 对128位数据赋值为0
            sop_out<='0';
            eop_out<='0';
            mty_out<=(others=>'0');
            err_out<='0';
			rxfifo_wrreq_out<='0';
        elsif clk'event and clk='1' then
			if val_in='1' then
				case spi3rx_status is
                    when spi3rx_sop=>	if sop_in='1' then
											data128(127 downto 120)<=dat_in;
											sop_out<='1'; 
											rxfifo_wrreq_out<='0'; 
										end if;
										
                    when spi3rx_data0=>	if eop_in='1' then
											data128(127 downto 120)<=dat_in;
											data128(119 downto 0)<=(others=>'0');
											sop_out<='0';
											eop_out<='1';
											mty_out<=x"f";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(127 downto 120)<=dat_in;
											sop_out<='0';
											rxfifo_wrreq_out<='0';
										end if;
										
                    when spi3rx_data1=>	if eop_in='1' then
											data128(119 downto 112)<=dat_in;
											data128(111 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"e";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(119 downto 112)<=dat_in;
											rxfifo_wrreq_out<='0';
										end if;
										
                    when spi3rx_data2=>	if eop_in='1' then
											data128(111 downto 104)<=dat_in;
											data128(103 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"d";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(111 downto 104)<=dat_in;
											rxfifo_wrreq_out<='0';
										end if;
										
                    when spi3rx_data3=>	if eop_in='1' then
											data128(103 downto 96)<=dat_in;
											data128(95 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"c";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(103 downto 96)<=dat_in;
											rxfifo_wrreq_out<='0';
										end if;
										
                    when spi3rx_data4=>	if eop_in='1' then
											data128(95 downto 88)<=dat_in;
											data128(87 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"b";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(95 downto 88)<=dat_in;
											rxfifo_wrreq_out<='0';						
										end if;
										
                    when spi3rx_data5=>	if eop_in='1' then
											data128(87 downto 80)<=dat_in;
											data128(79 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"a";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(87 downto 80)<=dat_in;	
											rxfifo_wrreq_out<='0';					
										end if;
										
                    when spi3rx_data6=>	if eop_in='1' then
											data128(79 downto 72)<=dat_in;
											data128(71 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"9";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(79 downto 72)<=dat_in;
											rxfifo_wrreq_out<='0';						
										end if;
										
                    when spi3rx_data7=>	if eop_in='1' then
											data128(71 downto 64)<=dat_in;
											data128(63 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"8";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(71 downto 64)<=dat_in;
											rxfifo_wrreq_out<='0';						
										end if;
										
                    when spi3rx_data8=>	if eop_in='1' then
											data128(63 downto 56)<=dat_in;
											data128(55 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"7";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(63 downto 56)<=dat_in;
											rxfifo_wrreq_out<='0';						
										end if;
										
                    when spi3rx_data9=>	if eop_in='1' then
											data128(55 downto 48)<=dat_in;
											data128(47 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"6";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(55 downto 48)<=dat_in;
											rxfifo_wrreq_out<='0';						
										end if;
										
                    when spi3rx_data10=>if eop_in='1' then
											data128(47 downto 40)<=dat_in;
											data128(39 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"5";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(47 downto 40)<=dat_in;
											rxfifo_wrreq_out<='0';						
										end if;
										
                    when spi3rx_data11=>if eop_in='1' then
											data128(39 downto 32)<=dat_in;
											data128(31 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"4";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(39 downto 32)<=dat_in;	
											rxfifo_wrreq_out<='0';					
										end if;
										
                    when spi3rx_data12=>if eop_in='1' then
											data128(31 downto 24)<=dat_in;
											data128(23 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"3";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(31 downto 24)<=dat_in;	
											rxfifo_wrreq_out<='0';					
										end if;
										
                    when spi3rx_data13=>if eop_in='1' then
											data128(23 downto 16)<=dat_in;
											data128(15 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"2";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(23 downto 16)<=dat_in;
											rxfifo_wrreq_out<='0';						
										end if;
										
                    when spi3rx_data14=>if eop_in='1' then
											data128(15 downto 8)<=dat_in;
											data128(7 downto 0)<=(others=>'0');
											eop_out<='1';
											mty_out<=x"1";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(15 downto 8)<=dat_in;
											rxfifo_wrreq_out<='0';						
										end if;
										
                    when spi3rx_data15=>if eop_in='1' then
											data128(7 downto 0)<=dat_in;
											eop_out<='1';
											mty_out<=x"0";
											err_out<=err_in;
											rxfifo_wrreq_out<='1';
										else
											data128(7 downto 0)<=dat_in;
											eop_out<='0';
											mty_out<=x"0";
											err_out<='0';
											rxfifo_wrreq_out<='1';						
										end if;
										
                    when others=>			data128<=(others=>'0');
											sop_out<='0';
											eop_out<='0';
											mty_out<=(others=>'0');
											err_out<='0';
											rxfifo_wrreq_out<='0';
				end case;
			else
				data128<=(others=>'0');
				sop_out<='0';
				eop_out<='0';
				mty_out<=(others=>'0');
				err_out<='0';
				rxfifo_wrreq_out<='0';
			end if;
		end if;
      end process;
        
rxfifo_wrreq<=rxfifo_wrreq_out and out_stb; 
    
rxfifo_data_out(134)<=sop_out;
rxfifo_data_out(133)<=eop_out;
rxfifo_data_out(132 downto 129)<=mty_out;
rxfifo_data_out(128)<=err_out;
rxfifo_data_out(127 downto 0)<=data128;					
rxfifo_data<=rxfifo_data_out;

  
 end logicfunc; 
