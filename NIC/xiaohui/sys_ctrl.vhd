library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.custom.all;

entity sys_ctrl is
	generic(sys_ctrl_base:std_logic_vector(19 downto 0):="00000");
    port(
        ---system interface 
       	clk:in std_logic;
       	sys_reset:in std_logic;
	 	reset_m:out std_logic_vector(35 downto 0);
	    module_int:in std_logic_vector(35 downto 0);
		reset_aclcluster_abstkey_request:in std_logic;
		reset_aclcluster_rdresult_request:in std_logic;
		datapass_stb:buffer std_logic;
		upip_handover_ctl_reg:buffer std_logic_vector(35 downto 0);
		other_handover_ctl_reg:buffer std_logic_vector(35 downto 0);
		notupip_handover_ctl_reg:buffer std_logic_vector(35 downto 0);
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
end sys_ctrl;
		
architecture logicfunc of sys_ctrl is
																
signal portx_status:state_type_portx;

--=================================reset===============================
signal reset:std_logic;
signal sys_reset_reg:std_logic_vector(35 downto 0);
----reset_aclcluster
--signal reset_aclcluster_cnt:integer;
--signal reset_aclcluster:std_logic_vector(35 downto 0);
--signal err_recover_aclcluster_stb:std_logic:='0';--cpu r/w reg
----module reset
signal reset_m_reg:std_logic_vector(35 downto 0):=(others=>'0');--cpu r/w reg
--
signal reset_m_out:std_logic_vector(35 downto 0);
--============================portx int===================
signal int_val:std_logic:='0';--cpu r/w reg


begin
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  reset  =*=*=*=*=*=*=*=*=*=*=
reset<=sys_reset;

sys_reset_reg<=(others=>'1') when sys_reset='1' else
			   (others=>'0');
reset_m_out<=reset_m_reg or sys_reset_reg;
reset_m<=reset_m_out;
-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*portx_interface=*=*=*=*=*=*=*=*=*=*=
process(clk,reset)
    begin
        if reset='1' then
            portx_status<=portx_idle;
        elsif clk'event and clk='1' then
           case portx_status is 
              when portx_idle=>if PORTX_CS_l='0' then 
                                portx_status<=portx_1d;
                               end if;
              when portx_1d=>if PORTX_CS_l='0' then 
                                portx_status<=portx_2d;
							   else 
								portx_status<=portx_idle; 
                             end if;
              when portx_2d=>if PORTX_CS_l='0' then 
                                portx_status<=portx_3d;
							   else 
								portx_status<=portx_idle; 
                             end if;  
              when portx_3d=>if PORTX_CS_l='0' then 
                                portx_status<=portx_4d;
							   else 
								portx_status<=portx_idle; 
                             end if;                             
              when portx_4d=>if PORTX_CS_l='0' then 
                                portx_status<=portx_5d;
							   else 
								portx_status<=portx_idle; 
                             end if;                                                  
              when portx_5d=>if PORTX_CS_l='0' then 
                                portx_status<=portx_write_or_read;
							   else 
								portx_status<=portx_idle; 
                             end if;
              when portx_write_or_read=>if PORTX_WE_l='0' then
                                          portx_status<=portx_write;
                                        elsif PORTX_OE_l='0' then
                                           portx_status<=portx_read;
                                        end if;
              when portx_write=>portx_status<=portx_wait;
			     when portx_read=>portx_status<=portx_wait;
              when portx_wait=>if PORTX_CS_l='1' then
                                   portx_status<=portx_idle;
                                end if;
              when others=>portx_status<=portx_idle;
              end case;
          end if;
      end process;

----------read registor     
process(clk,reset)
		variable add:std_logic_vector(23 downto 0);
		variable group_num:integer range 0 to 31;
		variable member_num:integer range 0 to 15;
		variable number:integer range 0 to 127;
		begin
			add:=x"1" & PORTX_A(19 downto 0)-sys_ctrl_base;    
			mib_groupmem_num(add(11 downto 4),add(3 downto 0),group_num,member_num);
			number:=conv_integer(add-x"100080");
        if reset='1' then
            PORTX_DAT<=(others=>'Z');
        elsif clk'event and clk='1' then
            if portx_status=portx_read then
               case x"1" & PORTX_A(19 downto 0)-sys_ctrl_base is
               when x"100000" =>PORTX_DAT<=x"0075bcd15";
				   when x"100001" =>PORTX_DAT<= reset_m_reg;
				   when x"100002" =>PORTX_DAT<=x"0000000" & "0" & pktrx_fifo_q(134 downto 128);
				   when x"100003" =>PORTX_DAT<=x"0" & pktrx_fifo_q(127 downto 96);
				   when x"100004" =>PORTX_DAT<=x"0" & pktrx_fifo_q(95 downto 64);
				   when x"100005" =>PORTX_DAT<=x"0" & pktrx_fifo_q(63 downto 32);
				   when x"100006" =>PORTX_DAT<=x"0" & pktrx_fifo_q(31 downto 0);
				   when x"100008" =>PORTX_DAT<=x"00000000" & "000" & int_val;
               when x"100020" =>PORTX_DAT<=x"00000000" & "000" & datapass_stb;            
               when x"100021" =>PORTX_DAT<=upip_handover_ctl_reg;
				   when x"100022" =>PORTX_DAT<=other_handover_ctl_reg;
				   when x"100023" =>PORTX_DAT<=notupip_handover_ctl_reg;

				   when x"100024" =>PORTX_DAT<=x"00000" & smac_local_array(0)(47 downto 32);
				   when x"100025" =>PORTX_DAT<=x"0" & smac_local_array(0)(31 downto 0);
				   when x"100026" =>PORTX_DAT<=x"00000" & smac_local_array(1)(47 downto 32);
				   when x"100027" =>PORTX_DAT<=x"0" & smac_local_array(1)(31 downto 0);
				   when x"100028" =>PORTX_DAT<=x"00000" & smac_local_array(2)(47 downto 32);
				   when x"100029" =>PORTX_DAT<=x"0" & smac_local_array(2)(31 downto 0);
				   when x"10002a" =>PORTX_DAT<=x"00000" & smac_local_array(3)(47 downto 32);
				   when x"10002b" =>PORTX_DAT<=x"0" & smac_local_array(3)(31 downto 0);   
					when others =>PORTX_DAT<=(others=>'Z');
               end case;
            elsif portx_status=portx_wait and PORTX_CS_l='1' then
               PORTX_DAT<=(others=>'Z'); 
           end if;
       end if;
   end process;
 
----------write registor     
process(clk,reset)
		variable add:std_logic_vector(23 downto 0);
		variable group_num:integer range 0 to 31;
		variable member_num:integer range 0 to 15;
    begin
			add:=x"1" & PORTX_A(19 downto 0)-sys_ctrl_base;    
			mib_groupmem_num(add(11 downto 4),add(3 downto 0),group_num,member_num);
        if reset='1' then
				reset_m_reg<=(others=>'0');
				int_val<='0';
				datapass_stb<='0';
				upip_handover_ctl_reg<=(others=>'0');
				other_handover_ctl_reg<=(others=>'0');
				notupip_handover_ctl_reg<=(others=>'0');
				smac_local_array<=(0=>(others=>'0'),1=>(others=>'0'),2=>(others=>'0'),3=>(others=>'0'));      
        elsif clk'event and clk='1' then
            if portx_status=portx_write then
               case x"1" & PORTX_A(19 downto 0)-sys_ctrl_base is
				   when x"100001" =>reset_m_reg<=PORTX_DAT;
					when x"100002" =>pktrx_fifo_data(134 downto 128) <=PORTX_DAT(6 downto 0 );
					when x"100003" =>pktrx_fifo_data(127 downto 96) <= PORTX_DAT(31 downto 0);
					when x"100004" =>pktrx_fifo_data(95 downto 64) <= PORTX_DAT(31 downto 0);
					when x"100005" =>pktrx_fifo_data(63 downto 32) <= PORTX_DAT(31 downto 0);
					when x"100006" =>pktrx_fifo_data(31 downto 0) <= PORTX_DAT(31 downto 0);
				   when x"100008" =>int_val<=PORTX_DAT(0);
				   when x"100020" =>datapass_stb<=PORTX_DAT(0);
				   when x"100021" =>upip_handover_ctl_reg<=PORTX_DAT;
               when x"100022" =>other_handover_ctl_reg<=PORTX_DAT;
               when x"100023" =>notupip_handover_ctl_reg<=PORTX_DAT;
                   
				   when x"100024" =>smac_local_array(0)(47 downto 32)<=PORTX_DAT(15 downto 0);
					 when x"100025" =>smac_local_array(0)(31 downto 0)<=PORTX_DAT(31 downto 0);
					 when x"100026" =>smac_local_array(1)(47 downto 32)<=PORTX_DAT(15 downto 0);
					 when x"100027" =>smac_local_array(1)(31 downto 0)<=PORTX_DAT(31 downto 0);
					 when x"100028" =>smac_local_array(2)(47 downto 32)<=PORTX_DAT(15 downto 0);
					 when x"100029" =>smac_local_array(2)(31 downto 0)<=PORTX_DAT(31 downto 0);
					 when x"10002a" =>smac_local_array(3)(47 downto 32)<=PORTX_DAT(15 downto 0);
					 when x"10002b" =>smac_local_array(3)(31 downto 0)<=PORTX_DAT(31 downto 0);
					 
					when others=>null;					
				end case;
			end if;
		end if;
	end process;


-- =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*other logic=*=*=*=*=*=*=*=*=*=*=*=*=*=

pktrx_fifo_rdreq<='1' when portx_status=portx_read and (x"1" & PORTX_A(19 downto 0)-sys_ctrl_base)=x"100006" else
						'0';
pkttx_fifo_wrreq<= '1' when portx_status =portx_write and (x"1" & PORTX_A(19 downto 0)-sys_ctrl_base)=x"100006" else 
                   '0';	
						 
end logicfunc;