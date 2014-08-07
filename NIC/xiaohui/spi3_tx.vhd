library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.custom.all;
entity spi3_tx is
    port(
    	-----sys-------
        clk:in std_logic;
        reset_m:in std_logic;
		----Upstream_fifo-------
		Upstreamfifo_empty		: in std_logic;
		Upstreamfifo_rdreq		: out std_logic;
		Upstreamfifo_q		    : in std_logic_vector(134 downto 0);
		----spi tx-------
		spi3_DTPA:in std_logic;       --端口发送FIFO空间状态指示
		spi3_TENB_l : out STD_LOGIC;  --发送写使能
		spi3_TDAT : out STD_LOGIC_VECTOR(7 downto 0); --发送数据总线
		spi3_TSOP : out STD_LOGIC;    --发送包起始标志
		spi3_TEOP : out STD_LOGIC;    --发送包结束标志
		spi3_TERR : out STD_LOGIC;    --发送错误
		spi3_TPRTY : out STD_LOGIC;   --接收奇偶校验
		----mib or debug--------
		mib_almost_empty_drop		: out std_logic;
		mib_bigfifo_data			: out std_logic_vector(6 downto 0);
		mib_bigfifo_wrreq			: out std_logic;
		mib_bigfifo_q				: out std_logic_vector(6 downto 0);
		mib_bigfifo_rdreq			: out std_logic;

		mib_DTPAis0_drop:out std_logic;
		mib_mty3tof_drop:out std_logic
		);
	end  spi3_tx;
architecture logicfunc of spi3_tx is
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
component small_big_bridge is
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
	end  component;
	
----------------------bigfifo------------------------------------------
signal  bigfifo_data: 			std_logic_vector(134 downto 0);
signal  bigfifo_rdreq:			std_logic;
signal  bigfifo_wrreq: 			std_logic;
signal  bigfifo_almost_empty: 	std_logic;
signal  bigfifo_almost_full: 	std_logic;
signal  bigfifo_empty:			std_logic;
signal  bigfifo_q:				std_logic_vector(134 downto 0);
	
component bigfifo_spi3tx IS
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

component spi3_tx_gateway is
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
	end  component;
------------mib
begin
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=
reset<=reset_m;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logicfunc=*=*=*=*=*=*=*=*=*=*=*=*=*=
fifo_bridge: small_big_bridge
    port map(
        -----sys-------
        clk				=>clk,
        reset_m			=>reset,
		----Upstream_fifo-------
		Upstreamfifo_empty		=>Upstreamfifo_empty,
		Upstreamfifo_rdreq		=>Upstreamfifo_rdreq,
		Upstreamfifo_q		    =>Upstreamfifo_q,
		---downstream_fifo----------
		downstreamfifo_almost_empty	=>bigfifo_almost_empty,
		downstreamfifo_almost_full	=>bigfifo_almost_full,
		downstreamfifo_wrreq		=>bigfifo_wrreq,
		downstreamfifo_data			=>bigfifo_data,
		----mib or debug--------
		mib_almost_empty_drop		=>mib_almost_empty_drop
		);

big_fifo: bigfifo_spi3tx 
	PORT map
	(
		clock		=>clk,
		data		=>bigfifo_data,
		rdreq		=>bigfifo_rdreq,
		sclr		=>reset,
		wrreq		=>bigfifo_wrreq,
		almost_empty=>bigfifo_almost_empty,
		almost_full	=>bigfifo_almost_full,
		empty		=>bigfifo_empty,
		q			=>bigfifo_q
	);
	
mib_bigfifo_data	<=bigfifo_data(134 downto 128);
mib_bigfifo_wrreq	<=bigfifo_wrreq;
mib_bigfifo_q		<=bigfifo_q(134 downto 128);
mib_bigfifo_rdreq	<=bigfifo_rdreq;

spi3_tx_gateway_m: spi3_tx_gateway
    port map(
        -----sys-------
        clk				=>clk,
        reset_m			=>reset,
		---tx fifo
		txfifo_rdreq	=>bigfifo_rdreq,
		txfifo_empty	=>bigfifo_empty,
		txfifo_q		=>bigfifo_q,
		----spi tx-------
	 	 spi3_DTPA		=>spi3_DTPA,
		 spi3_TENB_l	=>spi3_TENB_l,
		 spi3_TDAT 		=>spi3_TDAT,
		 spi3_TSOP 		=>spi3_TSOP,
		 spi3_TEOP 		=>spi3_TEOP,
		 spi3_TERR 		=>spi3_TERR,
		 spi3_TPRTY 	=>spi3_TPRTY,
		 ---mib or debug--------- 
		mib_DTPAis0_drop=>mib_DTPAis0_drop,
		mib_mty3tof_drop=>mib_mty3tof_drop
		);
	
end  logicfunc;

