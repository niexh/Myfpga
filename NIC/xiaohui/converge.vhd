library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.custom.all;
entity converge is
	generic(Scheduling:Scheduling_type:=priority;
			numfifo:integer:=4);
    port(
    	-----sys-------
        clk:in std_logic;
        reset_m:in std_logic;
		----Upstream_fifo-------
		Upstreamfifo_rdreq_array		: out array_sl(numfifo-1 downto 0);
		Upstreamfifo_empty_array		: in array_sl(numfifo-1 downto 0);
		Upstreamfifo_q_array		    : in array_slv_135(numfifo-1 downto 0);
		fullpktflagfifo_rdreq_array		:out array_sl(numfifo-1 downto 0);
		fullpktflagfifo_empty_array		:in array_sl(numfifo-1 downto 0);
--		fullpktflagfifo_q_array			:in	array_slv_1(numfifo-1 downto 0);
		---downstream_fifo----------
		downstreamfifo_almost_empty:in std_logic;
		downstreamfifo_wrreq:out std_logic;
		downstreamfifo_data:out std_logic_vector(134 downto 0)
		);
	end  converge;
architecture logicfunc of converge is
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

--constant arxbase:std_logic_vector(15 downto 0):=x"0300";
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=
--signal  sop_in_array:			array_sl(numfifo-1 downto 0);
--signal  eop_in_array:			array_sl(numfifo-1 downto 0);
--signal  mty_in_array:			array_slv_4(numfifo-1 downto 0);
--signal  err_in_array:			array_sl(numfifo-1 downto 0);
--signal  val_in_array:			array_sl(numfifo-1 downto 0);

signal cvg_status:state_type_cvg;

--constant cvg_tag:std_logic:=			"0";
--constant cvg_eop:std_logic:=			"1";

signal dat_in:std_logic_vector(127 downto 0);		
signal val_in:std_logic;		
signal sop_in:std_logic;
signal eop_in:std_logic;
signal mty_in:std_logic_vector(3 downto 0);
signal err_in:std_logic;

--in
signal  fullpktflagfifo_rdreq:			std_logic;

signal		Upstreamfifo_empty		:  std_logic;
signal		Upstreamfifo_rdreq		:  std_logic;
signal		Upstreamfifo_q		    :  std_logic_vector(134 downto 0);

signal current_fifo:integer range 0 to numfifo-1;

--out
signal downstreamfifo_out_stb:std_logic;

signal downstreamfifo_data_out:std_logic_vector(134 downto 0);
signal downstreamfifo_wrreq_out:std_logic;
------------mib
begin
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=
reset<=reset_m;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*portx_interface=*=*=*=*=*=*=*=*=*=*=

-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=
-----pkt_converge
process(clk,reset)

begin
	if reset='1' then
		current_fifo<=0;
	elsif clk'event and clk='1' then
		if Scheduling=Round_Robin then
			if cvg_status=cvg_tag and val_in='0' then
				current_fifo<=round_robin_select (current_fifo,numfifo,fullpktflagfifo_empty_array);
			elsif cvg_status=cvg_eop and val_in='1' and eop_in='1' then
				current_fifo<=round_robin_select (current_fifo,numfifo,fullpktflagfifo_empty_array);
			end if;
		else
			if cvg_status=cvg_tag and val_in='0' then
				current_fifo<=priority_select (current_fifo,numfifo,fullpktflagfifo_empty_array);
			elsif cvg_status=cvg_eop and val_in='1' and eop_in='1' then
				current_fifo<=priority_select (current_fifo,numfifo,fullpktflagfifo_empty_array);
			end if;	
		end if;
	end if;
end process;	


mux:for i in 0 to numfifo-1 generate
	
Upstreamfifo_rdreq_array(i)<=Upstreamfifo_rdreq when current_fifo=i else
							 '0';	
							 	
fullpktflagfifo_rdreq_array(i)<=fullpktflagfifo_rdreq when current_fifo=i else
								'0';		
end generate;

Upstreamfifo_empty	<=Upstreamfifo_empty_array(current_fifo);					--#
Upstreamfifo_q		<=Upstreamfifo_q_array(current_fifo);							--#


	
--Upstreamfifo_rdreq_array(0)<=Upstreamfifo_rdreq;	
							 	
--fullpktflagfifo_rdreq_array(0)<=fullpktflagfifo_rdreq;		

--Upstreamfifo_empty	<=Upstreamfifo_empty_array(0);					--#
--Upstreamfifo_q		<=Upstreamfifo_q_array(0);

--status
sop_in<=Upstreamfifo_q(134);
eop_in<=Upstreamfifo_q(133);
mty_in<=Upstreamfifo_q(132 downto 129);
err_in<=Upstreamfifo_q(128);
dat_in<=Upstreamfifo_q(127 downto 0);
val_in<=not Upstreamfifo_empty;
		
process(clk,reset)
	begin
		if reset='1' then
			cvg_status<=cvg_tag;
		elsif clk'event and clk='1' then
			case cvg_status is
				when cvg_tag=>	if val_in='1' and sop_in='1' then
									cvg_status<=cvg_eop;
								end if;
				when cvg_eop=>	if val_in='1' and eop_in='1' then
									cvg_status<=cvg_tag;
								end if;

				when others=>	cvg_status<=cvg_tag;
			end case;
		end if;
	end process;
	
--^_^ in
Upstreamfifo_rdreq<='1' when val_in='1' else
						'0' ;
fullpktflagfifo_rdreq<=	'1' when cvg_status=cvg_eop and val_in='1' and eop_in='1' else
						'0' ;
	
--^_^ out
--downstreamfifo
process(clk,reset)
begin
	if reset='1' then
		downstreamfifo_out_stb<='0';
	elsif clk'event and clk='1' then
		if cvg_status=cvg_tag and val_in='1' and sop_in='1' then 
				if downstreamfifo_almost_empty='1' then
					downstreamfifo_out_stb<='1';
				else
					downstreamfifo_out_stb<='0';
				end if;
		end if;
	end if;
end process;

process(clk,reset)
	begin
		if reset='1' then
			downstreamfifo_wrreq_out<='0';
			downstreamfifo_data_out<=(others=>'0');
		elsif clk'event and clk='1' then
			case cvg_status is 
				when cvg_tag=>			if sop_in='1' and val_in='1' then
											downstreamfifo_wrreq_out<='1';
											downstreamfifo_data_out<=Upstreamfifo_q;
										else
											downstreamfifo_wrreq_out<='0';
											downstreamfifo_data_out<=(others=>'0');
										end if;
						
				when cvg_eop=>	    	if val_in='1' then		
											downstreamfifo_wrreq_out<='1';
											downstreamfifo_data_out<=Upstreamfifo_q;
										else
											downstreamfifo_wrreq_out<='0';
											downstreamfifo_data_out<=(others=>'0');
										end if;
				when others=>	downstreamfifo_wrreq_out<='0';
							 	downstreamfifo_data_out<=(others=>'0');
			end case;
		end if;
	end process;
	

downstreamfifo_data<=downstreamfifo_data_out;
downstreamfifo_wrreq<=downstreamfifo_wrreq_out and downstreamfifo_out_stb;
--mib
end logicfunc;