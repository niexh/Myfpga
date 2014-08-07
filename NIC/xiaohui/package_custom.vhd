library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package custom is
--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*portx=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_portx is (portx_idle,portx_1d,portx_2d,portx_3d,portx_4d,portx_5d,portx_write_or_read,portx_write,portx_read,portx_wait);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*msa_pm5390_config=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_msa_pm5390_config is (
 portx_idle,
 portx_1d,
 portx_2d,
 portx_3d,
 portx_4d,
 portx_5d,
 portx_write_or_read,
 portx_write,
 portx_read,
 portx_wait,

 portx_5390read_addsetup_1d,
 portx_5390read_addsetup_2d,		 
 portx_5390read_csb_rdb_1d,			
 portx_5390read_csb_rdb_2d,		
 portx_5390read_csb_rdb_3d,			
 portx_5390read_csb_rdb_4d,		
 portx_5390read_csb_rdb_5d,		
 portx_5390read_csb_rdb_6d,
 portx_5390read_csb_rdb_7d,
 portx_5390read_csb_rdb_8d,		
 portx_5390read_csb_rdb_validdata_9d,
 portx_5390read_addhold_1d,
 portx_5390read_addhold_2d,
              
 portx_5390write_addsetup_1d,
 portx_5390write_addsetup_2d,
 portx_5390write_csb_wrb_data_1d,
 portx_5390write_csb_wrb_data_2d,
 portx_5390write_csb_wrb_data_3d,
 portx_5390write_csb_wrb_data_4d,
 portx_5390write_add_data_hold_1d,
 portx_5390write_add_data_hold_2d);



--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*sys ctl=*=*=*=*=*=*=*=*=*=*=*=*
type pktcapture_fifo_data  is array (natural range<>) of std_logic_vector(134 downto 0);
type pktcapture_fifo_wrreq is array (natural range<>) of std_logic;
type pktcapture_fifo_q     is array (natural range<>) of std_logic_vector(134 downto 0);
type pktcapture_fifo_rdreq is array (natural range<>) of std_logic;

procedure mib_groupmem_num(tens_digit:in std_logic_vector(7 downto 0);unit:in std_logic_vector(3 downto 0);group_num:out integer;mem_num:out integer);
--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*arx=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_arx is (arx_sop,arx_eop);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*format=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_fmt is (fmt_tag,fmt_nip,fmt_payload1,fmt_payload2,fmt_weop,fmt_macup_sopeop_v4,fmt_macup_sop_v6,fmt_macup_eop_v6,fmt_arp_payload1,fmt_arp_payload2,fmt_arpup_sop,fmt_arpup_eop);


type format_workingmode_type is (ppp_to_datapass,mac_to_datapass,pppdown_to_datapass,macdown_to_datapass,
								 datapass_to_ppp,datapass_to_mac,datapass_to_routeup,datapass_to_macup,datapass_to_arpup);

type offset_type is array (format_workingmode_type range ppp_to_datapass to datapass_to_arpup) of integer;                                                                                            
type sport_type is (geport0,geport1,geport2,geport3,geport4,geport5,geport6,geport7,tengport,cpu);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*extract=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_alk is (alk_tag,alk_nip,alk_ipv4cyc1,alk_ipv4cyc2,alk_ipv6cyc1,alk_ipv6cyc2,alk_ipv6cyc3,alk_ipv4mackey,alk_ipv6mackey,alk_notlookupmac,alk_otherpayload,alk_eop);
type camlookup_type is (route,mac);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*cam=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_cam is ( cam_reset,
  cam_40delay,
  cam_idle,

  cam_wr_add1,
  cam_wr_add2,
  cam_wr_data1,
  cam_wr_data2,

  cam_rd_add1,
  cam_rd_add2,
--  cam_rd_t1,
--  cam_rd_t2,
--  cam_rd_t3,
--  cam_rd_t4,
--  cam_rd_t5,
--  cam_rd_t6,
--  cam_rd_t7,
--  cam_rd_t8,
--  cam_rd_t9,
--  cam_rd_t10,
--  cam_rd_t11,
--  cam_rd_t12,
--  cam_rd_t13,
--  cam_rd_t14,
--  cam_rd_t15,
  cam_wait_rd_t15,

  cam_v6fibkey_143_72,
  cam_v6fibkey_71_0,
				
  cam_v4aclkey_143_72,
  cam_v4aclkey_71_0,
  cam_v6aclkey_287_216,
  cam_v6aclkey_215_144,
  cam_v6aclkey_143_72,
  cam_v6aclkey_71_0,

  cam_v4pbrkey_143_72,
  cam_v4pbrkey_71_0,
  cam_v6pbrkey_287_216,
  cam_v6pbrkey_215_144,
  cam_v6pbrkey_143_72,
  cam_v6pbrkey_71_0,
		
  cam_v4mackey_71_0_t1,
  cam_v4mackey_71_0_t2,
  cam_v6mackey_143_72,
  cam_v6mackey_71_0,

  cam_notlookup,
  cam_otherlookup
);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*readlookupresult=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_rlr is (rlr_tag,rlr_nip,rlr_eop);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*pktprocess=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_ie is (ie_tag,ie_nip,ie_payload1_v4,ie_payload2_v4,ie_payload1_v6,ie_payload2_v6,ie_payload3_v6,ie_eop);
type state_type_pp is (pp_tag,pp_nip,pp_payload1_v4,pp_payload2_v4,pp_payload1_v6,pp_payload2_v6,pp_payload3_v6,pp_eop);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*pkt_forward=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_fwd is (fwd_tag,fwd_eop);

type filtering_constraint_type is (dport_0,dport_1,dport_2,dport_3,dport_4,dport_5,dport_6,dport_7,
									dport_lower,dport_upper,dport_10g,dport_lower10g,sport_lower,
									routeup,routefwd,arpup,notarpfwd,macup,macfwd);

type array_filtering_constraint_type is array (natural range<>) of filtering_constraint_type;

function offset_calculation(i:integer) return std_logic_vector;
    procedure mib_groupout_num(tens_digit:in std_logic_vector(3 downto 0);unit:in std_logic_vector(3 downto 0);i:out integer;j:out integer);
--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*atx=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_atx is (atx_tag,atx_eop);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*spi3tx=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_spi3tx is(spi3tx_sop,spi3tx_data0,spi3tx_data1,spi3tx_data2,spi3tx_data3,
									 spi3tx_data4,spi3tx_data5,spi3tx_data6,spi3tx_data7,
									 spi3tx_data8,spi3tx_data9,spi3tx_data10,spi3tx_data11,
									 spi3tx_data12,spi3tx_data13,spi3tx_data14,spi3tx_data15);

--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*spi3rx=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_spi3rx is (	spi3rx_sop,spi3rx_data0,spi3rx_data1,spi3rx_data2,spi3rx_data3,
									   spi3rx_data4,spi3rx_data5,spi3rx_data6,spi3rx_data7,
									   spi3rx_data8,spi3rx_data9,spi3rx_data10,spi3rx_data11,
									   spi3rx_data12,spi3rx_data13,spi3rx_data14,spi3rx_data15);



--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*pkt_converge=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_cvg is (cvg_tag,cvg_eop);
--type state_type_cvg is (cvg_currentfifoselect,cvg_tag,cvg_eop);
type Scheduling_type is (Round_Robin,priority);

type array_slv_135		is array (natural range<>) of std_logic_vector(134 downto 0);
type array_sl			is array (natural range<>) of std_logic;
type array_slv_36		is array (natural range<>) of std_logic_vector(35 downto 0);
type array_slv_4		is array (natural range<>) of std_logic_vector(3 downto 0);
type array_slv_7		is array (natural range<>) of std_logic_vector(6 downto 0);
type array_slv_20		is array (natural range<>) of std_logic_vector(19 downto 0);
type array_slv_1		is array (natural range<>) of std_logic_vector(0 downto 0);
type array_slv_48		is array (natural range<>) of std_logic_vector(47 downto 0);

function round_robin_select (current_fifo:integer;numfifo:integer;Upstreamfifo_empty_array:array_sl) return integer;
function priority_select (current_fifo:integer;numfifo:integer;Upstreamfifo_empty_array:array_sl) return integer;

procedure mib_groupin_num(tens_digit:in std_logic_vector(3 downto 0);unit:in std_logic_vector(3 downto 0);i:out integer;j:out integer);
--=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*small_big_bridge=*=*=*=*=*=*=*=*=*=*=*=*
type state_type_sbb is (sbb_tag,sbb_eop);
end package custom;











package body custom is
--sys_ctrl
    procedure mib_groupmem_num(tens_digit:in std_logic_vector(7 downto 0);unit:in std_logic_vector(3 downto 0);group_num:out integer;mem_num:out integer) is
        variable tens_digit_v:integer range 16 to 47;
        variable unit_v:integer range 0 to 15;
    begin
						 tens_digit_v:=conv_integer(tens_digit); 
						 unit_v:=conv_integer(unit); 
						 group_num:=tens_digit_v-16;
						 mem_num:=unit_v;
	--				if unit_v<=9 then
	--					j:=unit_v;
	--				else
	--					j:=;
	--				end if;	
    end procedure;

--pkt_converge
function round_robin_select (current_fifo:integer;numfifo:integer;Upstreamfifo_empty_array:array_sl) return integer is
variable next_fifo:integer;
begin
	if current_fifo>=numfifo then
		next_fifo:=0;
	else
		next_fifo:=current_fifo;
	end if;
	
	for i in 0 to numfifo-1 loop

	if next_fifo<numfifo-1 then
		next_fifo:=next_fifo+1;
	else
		next_fifo:=0;
	end if;

	exit when Upstreamfifo_empty_array(next_fifo)='0';
	end loop;
	return(next_fifo);
end function;

function priority_select (current_fifo:integer;numfifo:integer;Upstreamfifo_empty_array:array_sl) return integer is
variable next_fifo,result_fifo:integer;
begin
	next_fifo:=0;
	result_fifo:=0;
	loop
	if Upstreamfifo_empty_array(next_fifo)='0' then
		result_fifo:=next_fifo;
	end if;
	
	exit when Upstreamfifo_empty_array(next_fifo)='0' or next_fifo=numfifo-1;

	next_fifo:=next_fifo+1;

	end loop;
	
	return(result_fifo);
end function;

    procedure mib_groupin_num(tens_digit:in std_logic_vector(3 downto 0);unit:in std_logic_vector(3 downto 0);i:out integer;j:out integer) is
        variable tens_digit_v:integer range 0 to 15;
        variable unit_v:integer range 0 to 15;
    begin
                      tens_digit_v:=conv_integer(tens_digit); 
                      unit_v:=conv_integer(unit); 
                      i:=tens_digit_v*3+unit_v/5;
					if unit_v=15 then
						j:=5;
					else
						j:=unit_v rem 5;
					end if;	
    end procedure;
    
--pkt_forward



function offset_calculation(i:integer) return std_logic_vector is
	  variable quotient,remainder,offset :integer;
          begin
			quotient:=i/3;
			remainder:=i rem 3;
			if remainder=0 or remainder=1 then
				offset:=quotient*16+remainder*5;
			else
				offset:=quotient*16+remainder*5+1;
			end if;
		return (conv_std_logic_vector(offset,20));
end function;		
		
    procedure mib_groupout_num(tens_digit:in std_logic_vector(3 downto 0);unit:in std_logic_vector(3 downto 0);i:out integer;j:out integer) is
        variable tens_digit_v:integer range 0 to 15;
        variable unit_v:integer range 0 to 15;
    begin
                      tens_digit_v:=conv_integer(tens_digit); 
                      unit_v:=conv_integer(unit); 
                      i:=tens_digit_v*3-1+unit_v/5;
					if unit_v=15 then
						j:=5;
					else
						j:=unit_v rem 5;
					end if;		
    end procedure;
    		
end custom;