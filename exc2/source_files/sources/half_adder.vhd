library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity half_adder is
  Port ( 
    i_a     :in std_logic;
    i_b     :in std_logic;
    o_sum   :out std_logic;
    o_carry :out std_logic 
  );
end half_adder;

architecture dataflow_arch of half_adder is 
begin  
    o_sum <= i_a xor i_b;
    o_carry <= i_a and i_b;
 end architecture;
