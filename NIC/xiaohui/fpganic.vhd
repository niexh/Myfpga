library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.custom.all;
entity fpganic is 
port(
-- CLOCK, RESET----------------
PTM1_CLK155	: IN STD_LOGIC;
PTM1_CLK125	: IN STD_LOGIC;
PTM1_CLK100	: IN STD_LOGIC;
PTM1_CLK133	: IN STD_LOGIC;

HRESET		: IN STD_LOGIC;
SRESET		: IN STD_LOGIC;

-- CPU Interface--------
CPU_PORTX_A	: IN STD_LOGIC_VECTOR(21 DOWNTO 0);
CPU_PTM1_CS	: IN STD_LOGIC;
CPU_PORTX_AS	: IN STD_LOGIC;
CPU_PORTX_WE	: IN STD_LOGIC;
CPU_PORTX_OE	: IN STD_LOGIC;
CPU_PORTX_INT3	: OUT STD_LOGIC;
CPU_PORTX_DAT	: INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);

-- IXF1104 SPI3 Interface
PTM1_MAC1_RFCLK : OUT STD_LOGIC;
MAC1_PTM1_RDAT	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
MAC1_PTM1_RENB 	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
MAC1_PTM1_RVAL	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
MAC1_PTM1_RERR	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
MAC1_PTM1_RPRTY	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
MAC1_PTM1_RSOP	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
MAC1_PTM1_REOP	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);

PTM1_MAC1_TFCLK	: OUT STD_LOGIC;
PTM1_MAC1_TDAT	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
PTM1_MAC1_TENB	: buffer STD_LOGIC_VECTOR(3 DOWNTO 0);
PTM1_MAC1_TERR	: buffer STD_LOGIC_VECTOR(3 DOWNTO 0);
PTM1_MAC1_TPRTY	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
PTM1_MAC1_TSOP	: buffer STD_LOGIC_VECTOR(3 DOWNTO 0);
PTM1_MAC1_TEOP	: buffer STD_LOGIC_VECTOR(3 DOWNTO 0);
PTM1_MAC1_DTPA	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
PTM1_MAC1_LDATA	: IN STD_LOGIC;
PTM1_MAC1_LCLK	: IN STD_LOGIC;
PTM1_MAC1_LLATCH: IN STD_LOGIC;

PTM1_MAC1_RST	: OUT STD_LOGIC;
PTM1_MAC1_MOD_DEF: IN STD_LOGIC;
PTM1_MAC1_RX_LOS : IN STD_LOGIC;
PTM1_MAC1_TX_FAULT: IN STD_LOGIC

--PTM1_MAC1_TXPSFR : OUT STD_LOGIC;
--PTM1_MAC1_TXPSA	 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

);
end fpganic;


architecture logicfunc of fpganic is

signal  smac_local_array:								array_slv_48(3 downto 0);

-----------------------sys_ctrl + pktrxfifo----------------------

signal  pktrxfifo_data: 			std_logic_vector(134 downto 0);
signal  pktrxfifo_rdreq:			std_logic;
signal  pktrxfifo_wrreq: 			std_logic;
signal  pktrxfifo_almost_empty: 	std_logic;
signal  pktrxfifo_empty:			std_logic;
signal  pktrxfifo_q:				std_logic_vector(134 downto 0); 

component pktrx_fifo is 
	 port(
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
end component;
-----------------------sys_ctrl + pkttxfifo----------------------

signal  pkttxfifo_data: 			std_logic_vector(134 downto 0);
signal  pkttxfifo_rdreq:			std_logic;
signal  pkttxfifo_wrreq: 			std_logic;
signal  pkttxfifo_almost_empty: 	std_logic;
signal  pkttxfifo_empty:			std_logic;
signal  pkttxfifo_q:				std_logic_vector(134 downto 0); 

component pkttx_fifo is 
	 port(
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
end component;
--------------------------------------------------------------------------
signal  rx_bigfifo_data_array: 			array_slv_135(3 downto 0);
signal  rx_bigfifo_rdreq_array:			array_sl(3 downto 0);
signal  rx_bigfifo_wrreq_array: 			array_sl(3 downto 0);
signal  rx_bigfifo_almost_empty_array: 	array_sl(3 downto 0);
signal  rx_bigfifo_empty_array:			array_sl(3 downto 0);
signal  rx_bigfifo_q_array:				array_slv_135(3 downto 0);

component rx_bigfifo is 
	 port(
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
end component;
-------------------------------------------------------------------------
component spi3_rx is
    port(        
    	-----sys-------
         clk:in std_logic;
         reset_m:in std_logic;
    	----spi rx-------
         spi3_renb_l:out std_logic;
         spi3_rdat:in std_logic_vector(7 downto 0);
         spi3_rsop:in std_logic;
         spi3_reop:in std_logic;
         spi3_rerr:in std_logic;
         spi3_rprty:in std_logic;
         spi3_rval:in std_logic;
    	--------rx fifo---
         rxfifo_wrreq:buffer std_logic;
         rxfifo_data:out std_logic_vector(134 downto 0);
--         rxfifo_almost_full:in std_logic;
		   rxfifo_almost_empty:in std_logic
         );
end component;	
--------------------------------------------------------------------------
component pkt_converge is
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
	end  component;
---------------------------------------------------------------------------------
------------------------------pkt_fotwrad-------------------------
component pkt_forward is
	port(
    	-----sys-------
		clk:in std_logic;
		reset_m:in std_logic;
		---tx fifo------------
		downstreamfifo_0_almost_empty:in std_logic;
		downstreamfifo_0_wrreq:out std_logic;
		downstreamfifo_0_data:out std_logic_vector(134 downto 0);

		downstreamfifo_1_almost_empty:in std_logic;
		downstreamfifo_1_wrreq:out std_logic;
		downstreamfifo_1_data:out std_logic_vector(134 downto 0);
		
		downstreamfifo_2_almost_empty:in std_logic;
		downstreamfifo_2_wrreq:out std_logic;
		downstreamfifo_2_data:out std_logic_vector(134 downto 0);
		
		downstreamfifo_3_almost_empty:in std_logic;
		downstreamfifo_3_wrreq:out std_logic;
		downstreamfifo_3_data:out std_logic_vector(134 downto 0);
		---upstreamfifo------------
		upstreamfifo_almost_empty:in std_logic;
		upstreamfifo_empty:in std_logic;
		upstreamfifo_rdreq:out std_logic;
		upstreamfifo_q:in std_logic_vector(134 downto 0)
		);
	end  component;
	
signal  tx_bigfifo_data_array: 			array_slv_135(3 downto 0);
signal  tx_bigfifo_rdreq_array:			array_sl(3 downto 0);
signal  tx_bigfifo_wrreq_array: 			array_sl(3 downto 0);
signal  tx_bigfifo_almost_empty_array: 	array_sl(3 downto 0);
signal  tx_bigfifo_empty_array:			array_sl(3 downto 0);
signal  tx_bigfifo_q_array:				array_slv_135(3 downto 0);


component tx_bigfifo is 
	 port(
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
end  component;	

component spi3_tx is
    port(
    	-----sys-------
        clk:in std_logic;
        reset_m:in std_logic;
		----Upstream_fifo-------
		Upstreamfifo_empty		: in std_logic;
		Upstreamfifo_rdreq		: out std_logic;
		Upstreamfifo_q		    : in std_logic_vector(134 downto 0);
		----spi tx-------
		spi3_DTPA:in std_logic;
		spi3_TENB_l : out STD_LOGIC;
		spi3_TDAT : out STD_LOGIC_VECTOR(7 downto 0);
		spi3_TSOP : out STD_LOGIC;
		spi3_TEOP : out STD_LOGIC;
		spi3_TERR : out STD_LOGIC;
		spi3_TPRTY : out STD_LOGIC;
		----mib or debug--------
		mib_almost_empty_drop		: out std_logic;
		mib_bigfifo_data			: out std_logic_vector(6 downto 0);
		mib_bigfifo_wrreq			: out std_logic;
		mib_bigfifo_q				: out std_logic_vector(6 downto 0);
		mib_bigfifo_rdreq			: out std_logic;

		mib_DTPAis0_drop:out std_logic;
		mib_mty3tof_drop:out std_logic
		);
	end  component;	
	
signal fpga_reset: std_logic;
signal fpga_reset_n: std_logic;
signal reset_m:std_logic_vector(35 downto 0);
signal module_int:std_logic_vector(35 downto 0);
signal datapass_stb: std_logic;

component sys_ctrl is 
	generic(sys_ctrl_base:std_logic_vector(19 downto 0):="00000");

	port(
	    ---system interface 
       	clk:in std_logic;
       	sys_reset:in std_logic;
	 	reset_m:out std_logic_vector(35 downto 0);
	    module_int:in std_logic_vector(35 downto 0);
		datapass_stb:buffer std_logic;
		smac_local_array:buffer array_slv_48(3 downto 0);
        -- CPU Interface--------
		PORTX_A	: IN STD_LOGIC_VECTOR(21 DOWNTO 0);
		PORTX_CS_l	: IN STD_LOGIC;
		PORTX_AS_l	: IN STD_LOGIC;
		PORTX_WE_l	: IN STD_LOGIC;
		PORTX_OE_l	: IN STD_LOGIC;
		PORTX_INT	: OUT STD_LOGIC;
		PORTX_DAT	: INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		---- pkt output interface -----
		pktrx_fifo_data : out std_logic_vector(134 downto 0);
		pkttx_fifo_wrreq : out std_logic;
		pkttx_fifo_almost_empty :  in std_logic;
		----- pkt input interface -----
		pktrx_fifo_q: in std_logic_vector(134 downto 0);
		pktrx_fifo_rdreq: out std_logic;
		pktrx_fifo_empty: in std_logic
		
	);
	end component;

	
-------------------------------------------------begin-----------------------------------------------------
begin
-----sys clk-----
PTM1_MAC1_TFCLK <=PTM1_CLK125;
PTM1_MAC1_RFCLK<=PTM1_CLK125;

--=======================reset===============
fpga_reset<=not (Hreset and Sreset);
PTM1_MAC1_RST <= not reset_m(35);

getx_interface:for i in 0 to 3 generate
--===========================================
rx_bigfifo_model: rx_bigfifo
    port map(
		clock		=> PTM1_CLK125,
		data		=> rx_bigfifo_data_array(i),
		rdreq		=> rx_bigfifo_rdreq_array(i),
		sclr		=> reset_m(0),
		wrreq		=> rx_bigfifo_wrreq_array(i),
		almost_empty	=> rx_bigfifo_almost_empty_array(i),
		empty		=> rx_bigfifo_empty_array(i),
		q		=>rx_bigfifo_q_array(i)
	 );
spi3rx_model: spi3_rx
    port map(
	  -----sys-------
        clk				=>PTM1_CLK125,
        reset_m			=>reset_m(0),
		 ----spi rx-------
         spi3_renb_l	=>MAC1_PTM1_RENB(i),
         spi3_rdat		=>MAC1_PTM1_RDAT(i*8+7 downto i*8),
         spi3_rsop		=>MAC1_PTM1_RSOP(i),
         spi3_reop		=>MAC1_PTM1_REOP(i),
         spi3_rerr		=>MAC1_PTM1_RERR(i),
        spi3_rprty		=>MAC1_PTM1_RPRTY(i),
         spi3_rval		=>MAC1_PTM1_RVAL(i),
   	--------rx fifo---
         rxfifo_wrreq			=>rx_bigfifo_wrreq_array(i),
         rxfifo_data			=>rx_bigfifo_data_array(i),
     	   rxfifo_almost_empty	=>rx_bigfifo_almost_empty_array(i)
	 );
	 
tx_bigfifo_model: tx_bigfifo
    port map(
		clock		=> PTM1_CLK125,
		data		=> tx_bigfifo_data_array(i),
		rdreq		=> tx_bigfifo_rdreq_array(i),
		sclr		=> reset_m(0),
		wrreq		=> tx_bigfifo_wrreq_array(i),
		almost_empty	=> tx_bigfifo_almost_empty_array(i),
		empty		=> tx_bigfifo_empty_array(i),
		q		=>tx_bigfifo_q_array(i)
	 );
spi3tx_model: spi3_tx
    port map(
        -----sys-------
        clk				=>PTM1_CLK125,
        reset_m			=>reset_m(0),
		---tx fifo
		Upstreamfifo_rdreq	=>tx_bigfifo_rdreq_array(i),
		Upstreamfifo_empty	=>tx_bigfifo_empty_array(i),
		Upstreamfifo_q		=>tx_bigfifo_q_array(i),
		----spi tx-------
	 	spi3_DTPA	  	=>	PTM1_MAC1_DTPA(i),
		spi3_TENB_l  	=>	PTM1_MAC1_TENB(i),
		spi3_TDAT	  	=>	PTM1_MAC1_TDAT(i*8+7 downto i*8),
		spi3_TSOP	  	=>	PTM1_MAC1_TSOP(i),
		spi3_TEOP	  	=>	PTM1_MAC1_TEOP(i),
		spi3_TERR	  	=>	PTM1_MAC1_TERR(i),
		spi3_TPRTY	  	=>	PTM1_MAC1_TPRTY(i)
		---mib or debug--------- 
		--mib_DTPAis0_drop	=>mib_DTPAis0_drop_array(i),
		--mib_mty3tof_drop	=>mib_mty3tof_drop_array(i)
		);	
end generate;

pktconverge_ge: pkt_converge 
	generic map(Scheduling=>Round_Robin,
				numfifo=>4)
    port map(
        -----sys-------
        clk				=>PTM1_CLK125,
        reset_m			=>reset_m(0),
		----Upstream_fifo-------
		Upstreamfifo_rdreq_array(0)		=>rx_bigfifo_rdreq_array(0),
		Upstreamfifo_empty_array(0)		=>rx_bigfifo_empty_array(0),
		Upstreamfifo_q_array(0)		    =>rx_bigfifo_q_array(0),
		Upstreamfifo_rdreq_array(1)		=>rx_bigfifo_rdreq_array(1),
		Upstreamfifo_empty_array(1)		=>rx_bigfifo_empty_array(1),
		Upstreamfifo_q_array(1)		    =>rx_bigfifo_q_array(1),
		Upstreamfifo_rdreq_array(2)		=>rx_bigfifo_rdreq_array(2),
		Upstreamfifo_empty_array(2)		=>rx_bigfifo_empty_array(2),
		Upstreamfifo_q_array(2)		    =>rx_bigfifo_q_array(2),
		Upstreamfifo_rdreq_array(3)		=>rx_bigfifo_rdreq_array(3),
		Upstreamfifo_empty_array(3)		=>rx_bigfifo_empty_array(3),
		Upstreamfifo_q_array(3)		    =>rx_bigfifo_q_array(3),
		---downstream_fifo----------
		downstreamfifo_almost_empty		=>pktrxfifo_almost_empty,
		downstreamfifo_wrreq			=>pktrxfifo_wrreq,
		downstreamfifo_data				=>pktrxfifo_data
		);
		

pktrx_fifo_model : pktrx_fifo
     port map(
		clock		=> PTM1_CLK125,
		data		=> pktrxfifo_data,
		rdreq		=> pktrxfifo_rdreq,
		sclr		=> reset_m(0),
		wrreq		=> pktrxfifo_wrreq,
		almost_empty	=> pktrxfifo_almost_empty,
		empty		=> pktrxfifo_empty,
		q		=>pktrxfifo_q
	 );
pkttx_fifo_model : pkttx_fifo
     port map(
		clock		=> PTM1_CLK125,
		data		=> pkttxfifo_data,
		rdreq		=> pkttxfifo_rdreq,
		sclr		=> reset_m(0),
		wrreq		=> pkttxfifo_wrreq,
		almost_empty	=> pkttxfifo_almost_empty,
		empty		=> pkttxfifo_empty,
		q		=>pkttxfifo_q
	 );


pkt_forwar_module: pkt_forward 
	port map(
    	-------sys---------------
		clk=>PTM1_CLK125,
		reset_m=>reset_m(0),
		---tx fifo------------
		downstreamfifo_0_almost_empty	=>rx_bigfifo_almost_empty_array(0),
		downstreamfifo_0_wrreq			=>tx_bigfifo_wrreq_array(0),
		downstreamfifo_0_data			=>tx_bigfifo_data_array(0),

		downstreamfifo_1_almost_empty	=>rx_bigfifo_almost_empty_array(1),
		downstreamfifo_1_wrreq			=>tx_bigfifo_wrreq_array(1),
		downstreamfifo_1_data			=>tx_bigfifo_data_array(1),
		
		downstreamfifo_2_almost_empty	=>rx_bigfifo_almost_empty_array(2),
		downstreamfifo_2_wrreq			=>tx_bigfifo_wrreq_array(2),
		downstreamfifo_2_data			=>tx_bigfifo_data_array(2),

		downstreamfifo_3_almost_empty	=>rx_bigfifo_almost_empty_array(3),
		downstreamfifo_3_wrreq			=>tx_bigfifo_wrreq_array(3),
		downstreamfifo_3_data			=>tx_bigfifo_data_array(3),
		---upstreamfifo------------
		upstreamfifo_almost_empty		=>pkttxfifo_almost_empty,
		upstreamfifo_empty				=>pkttxfifo_empty,
		upstreamfifo_rdreq				=>pkttxfifo_rdreq,
		upstreamfifo_q					   =>pkttxfifo_q
		);
sys_ctrl_module: sys_ctrl
     generic map(sys_ctrl_base=>x"00000")
	  port map(
	      ---system interface 
       	clk 					=>PTM1_CLK125,
       	sys_reset 			=>fpga_reset,
	 	reset_m					 =>reset_m,
	    module_int				 =>module_int,
		datapass_stb =>datapass_stb,
		
		smac_local_array =>smac_local_array,
        -- CPU Interface--------
		PORTX_A	 =>CPU_PORTX_A,
		PORTX_CS_l	 =>CPU_PTM1_CS,
		PORTX_AS_l	 =>CPU_PORTX_AS,
		PORTX_WE_l	 =>CPU_PORTX_WE,
		PORTX_OE_l	 =>CPU_PORTX_OE,
		PORTX_INT	 =>CPU_PORTX_INT3,
		PORTX_DAT	 =>CPU_PORTX_DAT,
		---- pkt output interface -----
		pktrx_fifo_data =>pkttxfifo_data,
		pkttx_fifo_wrreq =>pkttxfifo_wrreq,
		pkttx_fifo_almost_empty  =>pkttxfifo_almost_empty,
		----- pkt input interface -----
		pktrx_fifo_q =>pktrxfifo_q,
		pktrx_fifo_rdreq =>pktrxfifo_rdreq,
		pktrx_fifo_empty =>pktrxfifo_empty
	  );
end logicfunc;

