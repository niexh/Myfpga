library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.custom.all;
entity spi3_tx_gateway is
    port(
    	-----sys-------
        clk:in std_logic;
        reset_m:in std_logic;
		---tx fifo
		txfifo_rdreq		: out STD_LOGIC ;
		txfifo_empty		: in STD_LOGIC ;
		txfifo_q		: in STD_LOGIC_VECTOR (134 DOWNTO 0);
		----spi tx-------
	 	 spi3_DTPA:in std_logic;
		 spi3_TENB_l : out STD_LOGIC;
		 spi3_TDAT : out STD_LOGIC_VECTOR(7 downto 0);
		 spi3_TSOP : out STD_LOGIC;
		 spi3_TEOP : out STD_LOGIC;
		 spi3_TERR : out STD_LOGIC;
		 spi3_TPRTY : out STD_LOGIC;
		 ---mib or debug--------- 
		mib_DTPAis0_drop:out std_logic;
		mib_mty3tof_drop:out std_logic
		);
	end  spi3_tx_gateway;
architecture logicfunc of spi3_tx_gateway is
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=*=*=*=
signal reset:std_logic;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*portx_interface=*=*=*=*=*=*=*=*=*=*=*=*=*=
--signal portx_status:state_type_portx;
--constant portx_idle:std_logic_vector(11 downto 0):=				x"001";
--constant portx_1d:std_logic_vector(11 downto 0):=				x"002";
--constant portx_2d:std_logic_vector(11 downto 0):=				x"004";
--constant portx_3d:std_logic_vector(11 downto 0):=				x"008";
--constant portx_4d:std_logic_vector(11 downto 0):=				x"010";
--constant portx_5d:std_logic_vector(11 downto 0):=				x"020";
--constant portx_write_or_read:std_logic_vector(11 downto 0):=	x"040";
--constant portx_write:std_logic_vector(11 downto 0):=			x"080";
--constant portx_read:std_logic_vector(11 downto 0):=				x"100";
--constant portx_wait:std_logic_vector(11 downto 0):=				x"200";

--signal spi3txbase:std_logic_vector(15 downto 0);
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=
signal spi3tx_status:state_type_spi3tx;

--constant spi3tx_sop:std_logic_vector(16 downto 0):=		"0" & x"0001";
--constant spi3tx_data0:std_logic_vector(16 downto 0):=		"0" & x"0002";
--constant spi3tx_data1:std_logic_vector(16 downto 0):=		"0" & x"0004";
--constant spi3tx_data2:std_logic_vector(16 downto 0):=		"0" & x"0008";
--constant spi3tx_data3:std_logic_vector(16 downto 0):=		"0" & x"0010";
--constant spi3tx_data4:std_logic_vector(16 downto 0):=		"0" & x"0020";
--constant spi3tx_data5:std_logic_vector(16 downto 0):=		"0" & x"0040";
--constant spi3tx_data6:std_logic_vector(16 downto 0):=		"0" & x"0080";
--constant spi3tx_data7:std_logic_vector(16 downto 0):=		"0" & x"0100";
--constant spi3tx_data8:std_logic_vector(16 downto 0):=		"0" & x"0200";
--constant spi3tx_data9:std_logic_vector(16 downto 0):=		"0" & x"0400";
--constant spi3tx_data10:std_logic_vector(16 downto 0):=	"0" & x"0800";
--constant spi3tx_data11:std_logic_vector(16 downto 0):=	"0" & x"1000";
--constant spi3tx_data12:std_logic_vector(16 downto 0):=	"0" & x"2000";
--constant spi3tx_data13:std_logic_vector(16 downto 0):=	"0" & x"4000";
--constant spi3tx_data14:std_logic_vector(16 downto 0):=	"0" & x"8000";
--constant spi3tx_data15:std_logic_vector(16 downto 0):=	"1" & x"0000";

--in
signal sop_in:std_logic; 
signal eop_in:std_logic;
signal mty_in:std_logic_vector(3 downto 0);
signal err_in:std_logic;
signal data_in:std_logic_vector(127 downto 0);
signal val_in:std_logic;

signal txfifo_rdreq_out:std_logic;

--out
signal out_stb_l:std_logic;

signal data_out:std_logic_vector(7 downto 0);
signal enb_l_out:std_logic;
signal sop_out:std_logic;
signal eop_out:std_logic;
signal err_out:std_logic;
signal prty_out:std_logic;

------------mib

		
begin
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=
reset<=reset_m;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*portx_interface=*=*=*=*=*=*=*=*=*=*=

-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=

sop_in<=txfifo_q(134);
eop_in<=txfifo_q(133);
mty_in<=txfifo_q(132 downto 129);
err_in<=txfifo_q(128); 
data_in<=txfifo_q(127 downto 0); 
val_in<=not txfifo_empty;
---status
process(clk,reset)
    begin
        if reset='1' then
            spi3tx_status<=spi3tx_sop;
        elsif clk'event and clk='1' then
           case spi3tx_status is
			  when spi3tx_sop=>	if val_in='1' and sop_in='1' then
--								if val_in='1' and sop_in='1' and spi3_DTPA='1' then
									spi3tx_status<=spi3tx_data1;
								end if;
			  when spi3tx_data0=>if val_in='1' and eop_in='1' and mty_in=x"f" then
							   		spi3tx_status<=spi3tx_sop;
							   elsif val_in='1' then
									spi3tx_status<=spi3tx_data1;
							   end if;
			  when spi3tx_data1=>if eop_in='1' and mty_in=x"e" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data2;
							   end if;
			  when spi3tx_data2=>if eop_in='1' and mty_in=x"d" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data3;
							   end if;
			  when spi3tx_data3=>if eop_in='1' and mty_in=x"c" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data4;
							   end if;
			  when spi3tx_data4=>if eop_in='1' and mty_in=x"b" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data5;
							   end if;
			  when spi3tx_data5=>if eop_in='1' and mty_in=x"a" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data6;
							   end if;
			  when spi3tx_data6=>if eop_in='1' and mty_in=x"9" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data7;
							   end if;
			  when spi3tx_data7=>if eop_in='1' and mty_in=x"8" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data8;
							   end if;
			  when spi3tx_data8=>if eop_in='1' and mty_in=x"7" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data9;
							   end if;
			  when spi3tx_data9=>if eop_in='1' and mty_in=x"6" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data10;
							   end if;
			  when spi3tx_data10=>if eop_in='1' and mty_in=x"5" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data11;
							   end if;
			  when spi3tx_data11=>if eop_in='1' and mty_in=x"4" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data12;
							   end if;
			  when spi3tx_data12=>if eop_in='1' and mty_in=x"3" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data13;
							   end if;
			  when spi3tx_data13=>if eop_in='1' and mty_in=x"2" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data14;
							   end if;
			  when spi3tx_data14=>if eop_in='1' and mty_in=x"1" then
							   		spi3tx_status<=spi3tx_sop;
							   else
									spi3tx_status<=spi3tx_data15;
							   end if;
			  when spi3tx_data15=>if eop_in='1' then
							   		spi3tx_status<=spi3tx_sop;
								else 
								    spi3tx_status<=spi3tx_data0;
							   end if;
              when others=>spi3tx_status<=spi3tx_sop;
      	end case;
      end if;
  end process;
  --in
txfifo_rdreq_out<=	'1' when spi3tx_status=spi3tx_sop    and val_in='1' and sop_in='0' else --(sop_in='0' or (sop_in='1' and eop_in='1' and mty_in>="3" and mty_in<="f"))else
					'1' when spi3tx_status=spi3tx_data0  and val_in='1' and eop_in='1' and mty_in=x"f"  else
					'1' when spi3tx_status=spi3tx_data1  and eop_in='1' and mty_in=x"e" else
					'1' when spi3tx_status=spi3tx_data2  and eop_in='1' and mty_in=x"d" else
					'1' when spi3tx_status=spi3tx_data3  and eop_in='1' and mty_in=x"c" else
					'1' when spi3tx_status=spi3tx_data4  and eop_in='1' and mty_in=x"b" else
					'1' when spi3tx_status=spi3tx_data5  and eop_in='1' and mty_in=x"a" else
					'1' when spi3tx_status=spi3tx_data6  and eop_in='1' and mty_in=x"9" else
					'1' when spi3tx_status=spi3tx_data7  and eop_in='1' and mty_in=x"8" else
					'1' when spi3tx_status=spi3tx_data8  and eop_in='1' and mty_in=x"7" else
					'1' when spi3tx_status=spi3tx_data9  and eop_in='1' and mty_in=x"6" else
					'1' when spi3tx_status=spi3tx_data10 and eop_in='1' and mty_in=x"5" else
					'1' when spi3tx_status=spi3tx_data11 and eop_in='1' and mty_in=x"4" else
					'1' when spi3tx_status=spi3tx_data12 and eop_in='1' and mty_in=x"3" else
					'1' when spi3tx_status=spi3tx_data13 and eop_in='1' and mty_in=x"2" else
					'1' when spi3tx_status=spi3tx_data14 and eop_in='1' and mty_in=x"1" else
					'1' when spi3tx_status=spi3tx_data15 else
					'0';
txfifo_rdreq<=txfifo_rdreq_out;



--out	
 process(clk,reset)
    begin
        if reset='1' then
            out_stb_l<='1';    
        elsif clk'event and clk='1' then
			if spi3tx_status=spi3tx_sop and val_in='1' and sop_in='1' then
				if spi3_DTPA='0' or (eop_in='1' and mty_in>=x"3" and mty_in<=x"f") then
--				if eop_in='1' and mty_in>=x"3" and mty_in<=x"f" then
					out_stb_l<='1';
				else
					out_stb_l<='0';
				end if;
			end if;
		end if;
	end process;
		
 process(clk,reset)
    begin
        if reset='1' then
			data_out<=(others=>'0');
            enb_l_out<='1';
            sop_out<='0';
            eop_out<='0'; 
            prty_out<='0';
            err_out<='0';    
        elsif clk'event and clk='1' then
            case spi3tx_status is
				when spi3tx_sop=>	if val_in='1' and sop_in='1' then 
--									if val_in='1' and sop_in='1' and spi3_DTPA='1' then
									data_out<=data_in(127 downto 120);
									enb_l_out<='0';
									sop_out<='1';
									eop_out<='0'; 
									err_out<='0';
									prty_out<='0';
								else
									data_out<=(others=>'0');
									enb_l_out<='1';
									sop_out<='0';
									eop_out<='0'; 
									prty_out<='0';
									err_out<='0';
								end if;				
                when spi3tx_data0=>if val_in='1' and eop_in='1' and mty_in=x"f" then 
									data_out<=data_in(127 downto 120);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								elsif val_in='1' then
									data_out<=data_in(127 downto 120);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								else
									data_out<=(others=>'0');
									enb_l_out<='1';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data1=>if eop_in='1' and mty_in=x"e" then 
									data_out<=data_in(119 downto 112);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(119 downto 112);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;	
                when spi3tx_data2=>if eop_in='1' and mty_in=x"d" then 
									data_out<=data_in(111 downto 104);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(111 downto 104);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data3=>if eop_in='1' and mty_in=x"c" then 
									data_out<=data_in(103 downto 96);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(103 downto 96);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data4=>if eop_in='1' and mty_in=x"b" then 
									data_out<=data_in(95 downto 88);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(95 downto 88);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data5=>if eop_in='1' and mty_in=x"a" then 
									data_out<=data_in(87 downto 80);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(87 downto 80);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data6=>if eop_in='1' and mty_in=x"9" then 
									data_out<=data_in(79 downto 72);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(79 downto 72);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data7=>if eop_in='1' and mty_in=x"8" then 
									data_out<=data_in(71 downto 64);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(71 downto 64);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data8=>if eop_in='1' and mty_in=x"7" then 
									data_out<=data_in(63 downto 56);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(63 downto 56);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data9=>if eop_in='1' and mty_in=x"6" then 
									data_out<=data_in(55 downto 48);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(55 downto 48);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data10=>if eop_in='1' and mty_in=x"5" then 
									data_out<=data_in(47 downto 40);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(47 downto 40);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data11=>if eop_in='1' and mty_in=x"4" then 
									data_out<=data_in(39 downto 32);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(39 downto 32);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data12=>if eop_in='1' and mty_in=x"3" then 
									data_out<=data_in(31 downto 24);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(31 downto 24);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data13=>if eop_in='1' and mty_in=x"2" then 
									data_out<=data_in(23 downto 16);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(23 downto 16);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data14=>if eop_in='1' and mty_in=x"1" then 
									data_out<=data_in(15 downto 8);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(15 downto 8);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when spi3tx_data15=>if eop_in='1' and mty_in=x"0" then 
									data_out<=data_in(7 downto 0);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='1'; 
									err_out<=err_in;
									prty_out<='0';
								else
									data_out<=data_in(7 downto 0);
									enb_l_out<='0';
									sop_out<='0';
									eop_out<='0';
									err_out<='0';
									prty_out<='0';
								end if;
                when others=>data_out<=(others=>'0');
							 enb_l_out<='1';
            				 sop_out<='0';
            				 eop_out<='0';
							 prty_out<='0';
            				 err_out<='0';
            end case;
        end if;
    end process;

 process(clk,reset)
    begin
		if reset='1' then
			spi3_TENB_l<='1';
			spi3_TDAT<=(others=>'0');
			spi3_TSOP<='0';
			spi3_TEOP<='0';
			spi3_TERR<='0';
			spi3_TPRTY<='0';
		elsif clk'event and clk='1' then
			spi3_TENB_l<=enb_l_out or out_stb_l;
			spi3_TDAT<=data_out;
			spi3_TSOP<=sop_out;
			spi3_TEOP<=eop_out;
			spi3_TERR<=err_out;
			spi3_TPRTY<=prty_out;
		end if;
	end process;   
 


--mib
      process(clk,reset)
          begin
              if reset='1' then 
				 mib_DTPAis0_drop<='0';
				 mib_mty3tof_drop<='0';
              elsif clk'event and clk='1' then
						if spi3tx_status=spi3tx_sop and val_in='1' and sop_in='1' and spi3_DTPA='0' then 
							mib_DTPAis0_drop<='1';
						else
							mib_DTPAis0_drop<='0';
						end if;
						if spi3tx_status=spi3tx_sop and val_in='1' and sop_in='1' and eop_in='1' and mty_in>=x"3" and mty_in<=x"f" then
							mib_mty3tof_drop<='1';
						else
							mib_mty3tof_drop<='0';
						end if;
			  end if;
	  end process;
	
end  logicfunc;

