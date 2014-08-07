library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.custom.all;
entity pkt_converge is
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
		---downstream_fifo----------
		downstreamfifo_almost_empty:in std_logic;
		downstreamfifo_wrreq:out std_logic;
		downstreamfifo_data:out std_logic_vector(134 downto 0);
		----mib or debug--------
		mib_almost_empty_drop_array		: out array_sl(numfifo-1 downto 0);
		mib_bigfifo_data_array			: out array_slv_7(numfifo-1 downto 0);
		mib_bigfifo_wrreq_array			: out array_sl(numfifo-1 downto 0);
		mib_bigfifo_q_array				: out array_slv_7(numfifo-1 downto 0);
		mib_bigfifo_rdreq_array			: out array_sl(numfifo-1 downto 0)
		);
	end  pkt_converge;
architecture logicfunc of pkt_converge is
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
--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=
component small_big_bridge_fullpkt is
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
		---fullpkt_fifo------------
		fullpktfifo_wrreq:out std_logic;
		fullpktfifo_data:out std_logic_vector(0 downto 0);
		----mib or debug--------
		mib_almost_empty_drop:out std_logic
		);
	end  component;
	
----------------------bigfifo
signal  bigfifo_data_array: 			array_slv_135(numfifo-1 downto 0);
signal  bigfifo_rdreq_array:			array_sl(numfifo-1 downto 0);
signal  bigfifo_wrreq_array: 			array_sl(numfifo-1 downto 0);
signal  bigfifo_almost_empty_array: 	array_sl(numfifo-1 downto 0);
signal  bigfifo_almost_full_array: 		array_sl(numfifo-1 downto 0);
signal  bigfifo_empty_array:			array_sl(numfifo-1 downto 0);
signal  bigfifo_q_array:				array_slv_135(numfifo-1 downto 0);
	
component bigfifo_converge IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (134 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		sclr		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_empty		: OUT STD_LOGIC ;
		almost_full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (134 DOWNTO 0)
	);
END component;
----------------------fullpktflagfifo
signal  sop_in_array:			array_sl(numfifo-1 downto 0);
signal  eop_in_array:			array_sl(numfifo-1 downto 0);
signal  val_in_array:			array_sl(numfifo-1 downto 0);

--signal	bigfifo_pktsop_in_flag_array:array_sl(numfifo-1 downto 0);

signal  fullpktflagfifo_data_array: 			array_slv_1(numfifo-1 downto 0);
signal  fullpktflagfifo_rdreq_array:			array_sl(numfifo-1 downto 0);
signal  fullpktflagfifo_wrreq_array: 			array_sl(numfifo-1 downto 0);
--signal  fullpktflagfifo_almost_empty_array: 	array_sl(numfifo-1 downto 0);
signal  fullpktflagfifo_empty_array:			array_sl(numfifo-1 downto 0);
--signal  fullpktflagfifo_q_array:				array_slv_1(numfifo-1 downto 0);

component fullpktflagfifo IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		sclr		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_empty		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
END component;	



component converge is
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
	end  component;
------------mib
begin
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=
reset<=reset_m;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=
fullpktfifo:for i in 0 to numfifo-1 generate

fifo_bridge: small_big_bridge_fullpkt
    port map(
        -----sys-------
        clk				=>clk,
        reset_m			=>reset,
		----Upstream_fifo-------
		Upstreamfifo_empty		=>Upstreamfifo_empty_array(i),
		Upstreamfifo_rdreq		=>Upstreamfifo_rdreq_array(i),
		Upstreamfifo_q		    =>Upstreamfifo_q_array(i),
		---downstream_fifo----------
		downstreamfifo_almost_empty	=>bigfifo_almost_empty_array(i),
		downstreamfifo_almost_full	=>bigfifo_almost_full_array(i),
		downstreamfifo_wrreq		=>bigfifo_wrreq_array(i),
		downstreamfifo_data			=>bigfifo_data_array(i),
		---fullpkt_fifo------------
		fullpktfifo_wrreq			=>fullpktflagfifo_wrreq_array(i),
		fullpktfifo_data			=>fullpktflagfifo_data_array(i),
		----mib or debug--------
		mib_almost_empty_drop		=>mib_almost_empty_drop_array(i)
		);

big_fifo: bigfifo_converge 
	PORT map
	(
		clock		=>clk,
		data		=>bigfifo_data_array(i),
		rdreq		=>bigfifo_rdreq_array(i),
		sclr		=>reset,
		wrreq		=>bigfifo_wrreq_array(i),
		almost_empty=>bigfifo_almost_empty_array(i),
		almost_full	=>bigfifo_almost_full_array(i),
		empty		=>bigfifo_empty_array(i),
		q			=>bigfifo_q_array(i)
	);
mib_bigfifo_data_array(i)	<=bigfifo_data_array(i)(134 downto 128);
mib_bigfifo_wrreq_array(i)	<=bigfifo_wrreq_array(i);
mib_bigfifo_q_array(i)		<=bigfifo_q_array(i)(134 downto 128);
mib_bigfifo_rdreq_array(i)	<=bigfifo_rdreq_array(i);


--sop_in_array(i)<=bigfifo_data_array(i)(134);
--eop_in_array(i)<=bigfifo_data_array(i)(133);
--val_in_array(i)<=bigfifo_wrreq_array(i);

--      process(clk,reset)
--          begin
--              if reset='1' then 
--				bigfifo_pktsop_in_flag_array(i)<='0';
--              elsif clk'event and clk='1' then
--				if val_in_array(i)='1' and sop_in_array(i)='1' then
--					bigfifo_pktsop_in_flag_array(i)<='1';
--				elsif val_in_array(i)='1' and eop_in_array(i)='1' then
--					bigfifo_pktsop_in_flag_array(i)<='0';
--				end if;
--			  end if;
--	  end process;

--      process(clk,reset)
--          begin
--              if reset='1' then 
--				fullpktflagfifo_wrreq_array(i)<='0';
--              elsif clk'event and clk='1' then
--				if bigfifo_pktsop_in_flag_array(i)='1' and val_in_array(i)='1' and eop_in_array(i)='1' then
--						fullpktflagfifo_wrreq_array(i)<='1';
--				else
--						fullpktflagfifo_wrreq_array(i)<='0';
--				end if;
--			  end if;
--	  end process;

fullpktflagfifo_m: fullpktflagfifo 
	PORT map
	(
		clock			=>clk,
		data			=>fullpktflagfifo_data_array(i),
		rdreq			=>fullpktflagfifo_rdreq_array(i),
		sclr			=>reset,
		wrreq			=>fullpktflagfifo_wrreq_array(i),
--		almost_empty		: OUT STD_LOGIC ;
		empty			=>fullpktflagfifo_empty_array(i)
--		q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
	
end generate;

converge_m: converge
	generic map(Scheduling=>Scheduling,
				numfifo=>numfifo)
    port map(
        -----sys-------
        clk				=>clk,
        reset_m			=>reset,
		----Upstream_fifo-------
		Upstreamfifo_rdreq_array		=>bigfifo_rdreq_array,
		Upstreamfifo_empty_array		=>bigfifo_empty_array,
		Upstreamfifo_q_array		    =>bigfifo_q_array,
		fullpktflagfifo_rdreq_array		=>fullpktflagfifo_rdreq_array,
		fullpktflagfifo_empty_array		=>fullpktflagfifo_empty_array,
--		fullpktflagfifo_q_array			:in	array_slv_1(numfifo-1 downto 0);
		---downstream_fifo----------
		downstreamfifo_almost_empty	=>downstreamfifo_almost_empty,
		downstreamfifo_wrreq		=>downstreamfifo_wrreq,
		downstreamfifo_data			=>downstreamfifo_data
		);

end logicfunc;