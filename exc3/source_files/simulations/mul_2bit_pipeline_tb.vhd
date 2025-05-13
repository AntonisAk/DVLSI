library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mul_2bit_pipeline_tb is
end mul_2bit_pipeline_tb;


architecture test_bench of mul_2bit_pipeline_tb is
    component mul_2bit_pipeline is 
      Port (
        i_clk   : in std_logic;
        i_a     : in std_logic_vector(1 downto 0);        
        i_b     : in std_logic_vector(1 downto 0);        
        o_sum   : out std_logic_vector(3 downto 0) := (others=>'0')
    );
    end component;
    
    signal t_clk    : std_logic;
    signal t_a      : std_logic_vector(1 downto 0) := (others => '0');
    signal t_b      : std_logic_vector(1 downto 0) := (others => '0');
    signal t_sum    : std_logic_vector(3 downto 0) := (others => '0');
    
    constant CLOCK_PERIOD : time := 10 ns;

begin
    TEST: mul_2bit_pipeline 
    port map(
        i_clk => t_clk,
        i_a => t_a,
        i_b => t_b,
        o_sum => t_sum
        );
    
    STIMULUS: process
    begin
            
        --try every input
        for i in 1 to 3 loop
            for j in 1 to 3 loop
                t_a <= std_logic_vector(to_unsigned(i, 2)); 
                t_b <= std_logic_vector(to_unsigned(j, 2)); 
                wait for (1 * CLOCK_PERIOD);
            end loop;
        end loop;

        t_a <= (others => '0');
        t_b <= (others => '0');
        wait for (10 * CLOCK_PERIOD);
        
        wait;
    end process;

    GEN_CLK : process
    begin
        t_clk <= '0';
        wait for (CLOCK_PERIOD / 2);
        t_clk <= '1';
        wait for (CLOCK_PERIOD / 2);
    end process;

end architecture;
