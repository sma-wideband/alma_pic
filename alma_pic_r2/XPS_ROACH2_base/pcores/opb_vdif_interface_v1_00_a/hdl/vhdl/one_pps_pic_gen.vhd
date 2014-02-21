-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------

-- This entity is used to generate an internal 1PPS reference signal, 1PPS_PIC.
-- It uses the TE_p rising edge for alignment and depends on the signal 1PPS_arm from the uP_interface to tell it that the next TE is coincident with the maser 1PPS.
-- # $Id: one_pps_pic_gen.vhd,v 1.6 2014/01/06 22:12:55 cv-corr Exp $

entity one_pps_pic_gen is
   port	(
   
   Grs      : in std_logic;			--Grs is the general reset.  It holds the logic reset while it is high
									--Start 1 PPS counter at the next 1PPS (Grs needs to be zero)
   RunTG    : in std_logic; 		--from uP_interface

   TE       : in std_logic;    		--TE connects to a signal derived from TE_p

   C125     : in std_logic; 		--125 MHz clock

   ONE_PPS_PIC : out std_logic; 	--internal 1PPS, high for one C125 clock 

   ONE_PPS_PIC_Adv: out std_logic 	-- high for one clock exactly one clock before 1PPS_PIC

   	);
end one_pps_pic_gen;

architecture comportamental of one_pps_pic_gen is

constant counter_limit:integer:= 125000000;

signal counter    : std_logic_vector(27 downto 0); -- BUS:=X"000_0000";  		--28 bits counter, 125,000,000 = 0x7735940
signal one_pps    : std_logic := '0';
signal RunTG_Z1   : std_logic;
signal syncReq    : std_logic := '0';

begin
process(C125,RunTG,Grs,TE)
begin
	if Grs='1' then														-- Asynchronous reset
		counter <= X"000_0000";	
		ONE_PPS_PIC_Adv <= '1';			
		one_pps <= '1';		
	elsif C125='1' and C125'event then		-- upon 125MHz clock rising edge.
	  ONE_PPS_PIC <= one_pps;							-- "ONE_PPS_PIC" is high when counter = 0
		counter <= counter + '1';						-- increment counter
		RunTG_Z1 <= RunTG;                  -- make a delayed copy of RunTG
		
		-- "one_pps_pic" and "one_pps_pic_adv" will be high 8nsec
		
		if counter = counter_limit - 2 then 							-- to make these signals go high when counter = 124,999,999.
			ONE_PPS_PIC_Adv <= '1';			
			one_pps <= '1';
		else
			ONE_PPS_PIC_Adv <= '0';										-- if 	"counter" !="counter_limit", one "ONE_PPS_PIC_Adv" is clear					
			one_pps <= '0';
		end if;
		
		if counter = counter_limit - 1 then 							-- once "counter" ="counter_limit - 1", reset the counter
			counter <= X"000_0000";
		end if;
		
		if RunTG='1' and RunTG_Z1 = '0' then					-- detect rising edge
			syncReq  <= '1';  
		end if;                                       -- request sync at next TE
	  if TE = '1' then
	    syncReq  <= '0';
	  end if;
	    
		if syncReq = '1' and TE = '1' then						-- synchronize the counter to TE
			counter <= X"000_0000";		
		end if;		
		
	end if;
end process;

end comportamental;
