library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity full_adder_pipeline_tb is
end full_adder_pipeline_tb;


architecture test_bench of full_adder_pipeline_tb is
    component full_adder_pipeline is 
        port(
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_a : in std_logic_vector(3 downto 0);
            i_b : in std_logic_vector(3 downto 0);
            i_cin : in std_logic;
            o_sum : out std_logic_vector(3 downto 0);
            o_cout : out std_logic
        );
    end component;
    
    signal t_clk    : std_logic;
    signal t_rst    : std_logic := '0';
    signal t_a      : std_logic_vector(3 downto 0) := (others => '0');
    signal t_b      : std_logic_vector(3 downto 0) := (others => '0');
    signal t_cin    : std_logic := '0';
    signal t_sum    : std_logic_vector(3 downto 0) := (others => '0');
    signal t_cout   : std_logic := '0';
    
    constant CLOCK_PERIOD : time := 10 ns;

begin
    TEST: full_adder_pipeline 
    port map(
        i_clk => t_clk,
        i_rst => t_rst,
        i_a => t_a,
        i_b => t_b,
        i_cin => t_cin,
        o_sum => t_sum,
        o_cout => t_cout
        );
    
    STIMULUS: process
    begin
        t_rst <= '1';
        t_cin <= '0';
        wait for (10 * CLOCK_PERIOD);
        t_rst <= '0';
        wait for (1 * CLOCK_PERIOD);
            
        --try every input
        for i in 0 to 15 loop
            for j in 0 to 15 loop
                t_a <= std_logic_vector(to_unsigned(i, 4)); 
                t_b <= std_logic_vector(to_unsigned(j, 4)); 
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
