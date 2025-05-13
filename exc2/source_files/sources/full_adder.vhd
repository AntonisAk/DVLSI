library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity full_adder is
    Port ( i_a : in STD_LOGIC;
           i_b : in STD_LOGIC;
           i_c : in STD_LOGIC;
           o_sum : out STD_LOGIC;
           o_carry : out STD_LOGIC
           );
end full_adder;

architecture structural_arch of full_adder is

    signal sum1,car1,car2   : std_logic;

    component half_adder is
        Port ( 
            i_a     :in std_logic;
            i_b     :in std_logic;
            o_sum   :out std_logic;
            o_carry :out std_logic 
        );
    end component;

begin

HA1: half_adder 
    port map( 
        i_a => i_a,
        i_b => i_b,
        o_carry => car1, 
        o_sum => sum1
    );  

HA2: half_adder 
    port map( 
        i_a => i_c,
        i_b => sum1,
        o_carry => car2, 
        o_sum => o_sum
    );  

o_carry <= car1 or car2;

end architecture;
