library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity count3_tb is
end entity;

architecture tb of count3_tb is
    ---------------------------------------------------------------
    -- COMPONENT
    ---------------------------------------------------------------
    component count3 is 
        port (
            clk,
            resetn,
            count_en    :in std_logic; 
            ud          :in std_logic;
            sum         :out std_logic_vector(2 downto 0);
            cout        :out std_logic
        );
    end component;

    ---------------------------------------------------------------
    -- SIGNALS 
    ---------------------------------------------------------------
    signal t_resetn   : std_logic := '1';
    signal t_count_en : std_logic := '0';
    signal t_clk      : std_logic := '0';
    signal t_sum      : std_logic_vector (2 downto 0) := (others=>'0');
    signal t_cout     : std_logic := '0';
    signal t_ud       : std_logic := '1';  
    ---------------------------------------------------------------
    -- CONSTANTS
    ---------------------------------------------------------------
    constant CLOCK_PERIOD : time := 100 ns;

begin 

    DUT : count3
        port map (
           clk => t_clk,
           resetn => t_resetn,
           count_en => t_count_en,
           sum => t_sum,
           cout => t_cout,
           ud => t_ud 
        );


    STIMULUS : process
    begin
        ---------------------------------------------------------------
        --  EXAMPLE INPUTS
        t_resetn <= '0';
        wait for (1 * CLOCK_PERIOD);
        t_resetn <= '1';
        t_count_en <= '1';
        wait for (10 * CLOCK_PERIOD);
        t_ud <= '0';
        wait for (8 * CLOCK_PERIOD);
        t_resetn <= '0';
        wait for (1 * CLOCK_PERIOD);
        t_resetn <= '1';
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