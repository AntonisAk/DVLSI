library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity full_adder_behavioral_tb is
end full_adder_behavioral_tb;

architecture test_bench of full_adder_behavioral_tb is
    component full_adder_behavioral is
        port(
            i_a : in std_logic;
            i_b : in std_logic;
            i_cin : in std_logic;
            o_sum : out std_logic;
            o_cout : out std_logic
        );
    end component;

    signal t_in: std_logic_vector(2 downto 0);
    signal t_sum: std_logic;
    signal t_cout: std_logic;
begin
    
    FA: full_adder_behavioral
        port map(t_in(0),t_in(1),t_in(2),t_sum,t_cout);

    STIMULUS : process
    begin
    
        for i in 1 to 7 loop
            t_in <= std_logic_vector(to_unsigned(i, 3)); 
            wait for 10ns;
        end loop;
    end process;
    
end test_bench;
