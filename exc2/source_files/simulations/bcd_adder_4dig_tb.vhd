library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_adder_4dig_tb is
end bcd_adder_4dig_tb;

architecture test_bench of bcd_adder_4dig_tb is

    signal t_a,t_b,t_s  : std_logic_vector(15 downto 0);
    signal t_c          : std_logic;
    
    component bcd_adder_4dig is
        Port (
            i_a     :in std_logic_vector (15 downto 0);
            i_b     :in std_logic_vector (15 downto 0);
            o_sum   :out std_logic_vector (15 downto 0);
            o_cout  :out std_logic   
         );
    end component;
    
    
begin

    BCD4DA: bcd_adder_4dig
    port map(
        i_a => t_a,
        i_b => t_b,
        o_sum => t_s,
        o_cout => t_c
    );

    t_a <= X"9"&X"9"&X"9"&X"9";
    t_b <= X"9"&X"9"&X"9"&X"9";


end test_bench;
