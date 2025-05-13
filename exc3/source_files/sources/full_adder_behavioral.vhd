library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity full_adder_behavioral is
    Port (
        i_a : in std_logic;
        i_b : in std_logic;
        i_cin : in std_logic;
        o_sum : out std_logic;
        o_cout : out std_logic
    );
end full_adder_behavioral;

architecture behavioral_arch of full_adder_behavioral is
begin
    process (i_a,i_b,i_cin)
        variable temp: std_logic_vector(1 downto 0); 
    begin     
        temp := ('0' & i_a) + ('0' & i_b) + ('0' & i_cin);
        (o_cout,o_sum) <= temp;
    end process; 
end behavioral_arch;
