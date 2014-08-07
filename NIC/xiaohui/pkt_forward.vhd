library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pkt_forward is
	port(
    	-----sys-------
         clk:in std_logic;
         reset_m:in std_logic;
		---tx fifo------------
		downstreamfifo_0_almost_empty:in std_logic;
--		downstreamfifo_0_almost_full:in std_logic;
		downstreamfifo_0_wrreq:out std_logic;
		downstreamfifo_0_data:out std_logic_vector(134 downto 0);

		downstreamfifo_1_almost_empty:in std_logic;
--		downstreamfifo_1_almostfull:in std_logic;
		downstreamfifo_1_wrreq:out std_logic;
		downstreamfifo_1_data:out std_logic_vector(134 downto 0);
		
		downstreamfifo_2_almost_empty:in std_logic;
--		downstreamfifo_2_almost_full:in std_logic;
		downstreamfifo_2_wrreq:out std_logic;
		downstreamfifo_2_data:out std_logic_vector(134 downto 0);
		
		downstreamfifo_3_almost_empty:in std_logic;
--		downstreamfifo_3_almost_full:in std_logic;
		downstreamfifo_3_wrreq:out std_logic;
		downstreamfifo_3_data:out std_logic_vector(134 downto 0);
		---upstreamfifo------------
		upstreamfifo_almost_empty:in std_logic;
		upstreamfifo_empty:in std_logic;
		upstreamfifo_rdreq:out std_logic;
		upstreamfifo_q:in std_logic_vector(134 downto 0)
		);
	end  pkt_forward;
architecture logicfunc of pkt_forward is
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=*=*=*=
signal reset:std_logic;

type state_type_forward is (fwd_tag,fwd_eop);
signal fwd_status:state_type_forward;
signal next_status:integer;
signal sop_in:std_logic;
signal eop_in:std_logic;
signal mty_in:std_logic_vector(3 downto 0);
signal err_in:std_logic;
signal dat_in:std_logic_vector(127 downto 0);

signal val_in:std_logic;
----out
signal ph_dport:std_logic_vector(7 downto 0);		
signal frame_type:std_logic_vector(7 downto 0);

signal downstreamfifo_data:std_logic_vector(134 downto 0);
signal downstreamfifo_wrreq:std_logic;
signal Upstreamfifo_rdreq_out:std_logic;
signal downstreamfifo_0_wrreq_stb:std_logic;
signal downstreamfifo_1_wrreq_stb:std_logic;
signal downstreamfifo_2_wrreq_stb:std_logic;
signal downstreamfifo_3_wrreq_stb:std_logic;
signal upstreamfifo_out_stb:std_logic;


begin
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=
reset<=reset_m;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=

--status
sop_in<=upstreamfifo_q(134);
eop_in<=upstreamfifo_q(133);
mty_in<=upstreamfifo_q(132 downto 129);
err_in<=upstreamfifo_q(128);
dat_in<=upstreamfifo_q(127 downto 0);
val_in<=not Upstreamfifo_empty;
		
process(clk,reset)
	begin
		if reset='1' then
			fwd_status<=fwd_tag;
		elsif clk'event and clk='1' then
			case fwd_status is
				when fwd_tag=>	if val_in='1' and sop_in='1' then
									fwd_status<=fwd_eop;
								end if;
				when fwd_eop=>	if val_in='1' and eop_in='1' then
									fwd_status<=fwd_tag;
								end if;
				when others=>	fwd_status<=fwd_tag;
			end case;
		end if;
	end process;
	
--^_^ in
Upstreamfifo_rdreq_out<='1' when val_in='1' else
						'0' ;
Upstreamfifo_rdreq<=Upstreamfifo_rdreq_out;


--^_^ out
frame_type<=Upstreamfifo_q(119 downto 112);

ph_dport<=Upstreamfifo_q(83 downto 76);

process(clk,reset)
	begin
		if reset='1' then
			downstreamfifo_0_wrreq_stb<='0';
			downstreamfifo_1_wrreq_stb<='0';
			downstreamfifo_2_wrreq_stb<='0';
			downstreamfifo_3_wrreq_stb<='0';
		elsif clk'event and clk='1' then
			if fwd_status=fwd_tag and sop_in='1' and val_in='1' and ph_dport(3 downto 0)="0000" then
				if ph_dport(4)='1' and downstreamfifo_0_almost_empty='1' then
					downstreamfifo_0_wrreq_stb<='1';
				else
					downstreamfifo_0_wrreq_stb<='0';
				end if;
				if ph_dport(5)='1' and downstreamfifo_1_almost_empty='1' then
					downstreamfifo_1_wrreq_stb<='1';
				else
					downstreamfifo_1_wrreq_stb<='0';
				end if;
				if ph_dport(6)='1' and downstreamfifo_2_almost_empty='1' then
						downstreamfifo_2_wrreq_stb<='1';
				else
					downstreamfifo_2_wrreq_stb<='0';
				end if;
				if ph_dport(7)='1' and downstreamfifo_3_almost_empty='1' then
					downstreamfifo_3_wrreq_stb<='1';
				else
					downstreamfifo_3_wrreq_stb<='0';
				end if;
			end if;
		end if;
	end process;

process(clk,reset)
	begin
		if reset='1' then
			downstreamfifo_wrreq<='0';
			downstreamfifo_data<=(others=>'0');
		elsif clk'event and clk='1' then
			case fwd_status is 
				when fwd_tag=>	if sop_in='1' and val_in='1' then
										downstreamfifo_wrreq<='1';
										downstreamfifo_data<=upstreamfifo_q;
									else
										downstreamfifo_wrreq<='0';
										downstreamfifo_data<=(others=>'0');
									end if;
				when fwd_eop=>	if val_in='1' then
										downstreamfifo_wrreq<='1';
										downstreamfifo_data<=upstreamfifo_q;
									else
										downstreamfifo_wrreq<='0';
										downstreamfifo_data<=(others=>'0');
									end if;
				when others=>	downstreamfifo_wrreq<='0';
									downstreamfifo_data<=(others=>'0');
			end case;
		end if;
	end process;
		
downstreamfifo_0_data<=downstreamfifo_data;								
downstreamfifo_1_data<=downstreamfifo_data;					
downstreamfifo_2_data<=downstreamfifo_data;	
downstreamfifo_3_data<=downstreamfifo_data;

downstreamfifo_0_wrreq<=downstreamfifo_0_wrreq_stb and downstreamfifo_wrreq;
downstreamfifo_1_wrreq<=downstreamfifo_1_wrreq_stb and downstreamfifo_wrreq;
downstreamfifo_2_wrreq<=downstreamfifo_2_wrreq_stb and downstreamfifo_wrreq;
downstreamfifo_3_wrreq<=downstreamfifo_3_wrreq_stb and downstreamfifo_wrreq;

end logicfunc;