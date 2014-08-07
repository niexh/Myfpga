library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.custom.all;

entity small_big_bridge is
    port(
    	-----sys-------
        clk:in std_logic;
        reset_m:in std_logic;
		----Upstream_fifo-------
		Upstreamfifo_empty		: in std_logic;
		Upstreamfifo_rdreq		: out std_logic;
		Upstreamfifo_q		    : in std_logic_vector(134 downto 0);
		---downstream_fifo----------
		downstreamfifo_almost_empty:in std_logic;
		downstreamfifo_almost_full:in std_logic;
		downstreamfifo_wrreq:out std_logic;
		downstreamfifo_data:out std_logic_vector(134 downto 0);
		----mib or debug--------
		mib_almost_empty_drop:out std_logic
		);
	end  small_big_bridge;
architecture logicfunc of small_big_bridge is
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=*=*=*=
signal reset:std_logic;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=
signal sbb_status:state_type_sbb;

signal dat_in:std_logic_vector(127 downto 0);		
signal val_in:std_logic;		
signal sop_in:std_logic;
signal eop_in:std_logic;
signal mty_in:std_logic_vector(3 downto 0);
signal err_in:std_logic;

--in
signal		Upstreamfifo_rdreq_out		:  std_logic;
--out
signal downstreamfifo_out_stb:std_logic;

signal downstreamfifo_data_out:std_logic_vector(134 downto 0);
signal downstreamfifo_wrreq_out:std_logic;
------------mib
begin
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=
reset<=reset_m;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=
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
			sbb_status<=sbb_tag;
		elsif clk'event and clk='1' then
			case sbb_status is
				when sbb_tag=>	if val_in='1' and sop_in='1' then
									sbb_status<=sbb_eop;
								end if;
				when sbb_eop=>	if val_in='1' and (eop_in='1' or downstreamfifo_almost_full='1') then
									sbb_status<=sbb_tag;
								end if;

				when others=>	sbb_status<=sbb_tag;
			end case;
		end if;
	end process;

--^_^ in
Upstreamfifo_rdreq_out<='1' when val_in='1' else
						'0' ;
Upstreamfifo_rdreq<=Upstreamfifo_rdreq_out;
	
--^_^ out
--downstreamfifo
process(clk,reset)
begin
	if reset='1' then
		downstreamfifo_out_stb<='0';
	elsif clk'event and clk='1' then
		if sbb_status=sbb_tag and val_in='1' and sop_in='1' then 
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
			case sbb_status is 
				when sbb_tag=>			if sop_in='1' and val_in='1' then
											downstreamfifo_wrreq_out<='1';
											downstreamfifo_data_out<=Upstreamfifo_q;
										else
											downstreamfifo_wrreq_out<='0';
											downstreamfifo_data_out<=(others=>'0');
										end if;
						
				when sbb_eop=>	    	if val_in='1' and eop_in='0' and downstreamfifo_almost_full='1' then
											downstreamfifo_wrreq_out<='1';
											downstreamfifo_data_out<="0100001" & Upstreamfifo_q(127 downto 0);
										elsif val_in='1' then		
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
      process(clk,reset)
          begin
              if reset='1' then 
				 mib_almost_empty_drop<='0';
              elsif clk'event and clk='1' then
						if sbb_status=sbb_tag and val_in='1' and sop_in='1' then 
							if downstreamfifo_almost_empty='0' then
								mib_almost_empty_drop<='1';
							else
								mib_almost_empty_drop<='0';
							end if;
						else
							mib_almost_empty_drop<='0';
						end if;
			  end if;
	  end process;

end logicfunc;