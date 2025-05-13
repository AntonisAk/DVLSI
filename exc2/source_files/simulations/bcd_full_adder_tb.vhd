library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_full_adder_tb is
end bcd_full_adder_tb;

architecture test_bench of bcd_full_adder_tb is

    signal t_a,t_b,t_s  : std_logic_vector(3 downto 0);
    signal t_cin,t_cout : std_logic;
    
    component bcd_full_adder is
        Port (
            i_a     :in std_logic_vector (3 downto 0);
            i_b     :in std_logic_vector (3 downto 0);
            i_cin   :in std_logic;  
            o_sum   :out std_logic_vector (3 downto 0);  
            o_cout :out std_logic
        );
    end component;
    
    
begin

    BCDFA: bcd_full_adder
    port map(
        i_a => t_a,
        i_b => t_b,
        o_sum => t_s,
        o_cout => t_cout,
        i_cin => t_cin
    );


    STIMULUS: process
    begin
        t_cin <= '0';
        for i in 0 to 9 loop
            for j in 0 to 9 loop
                t_a <= std_logic_vector(to_unsigned(i,4));
                t_b <= std_logic_vector(to_unsigned(j,4));
                wait for 10 ns;
            end loop;
        end loop;
    end process;

end test_bench;
