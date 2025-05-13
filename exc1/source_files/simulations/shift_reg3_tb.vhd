library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shift_reg3_tb is
end entity;

architecture tb of shift_reg3_tb is
    ---------------------------------------------------------------
    -- COMPONENT
    ---------------------------------------------------------------
    component shift_reg3 is 
        port (
        clk,rst,si,en,pl,lr: in std_logic;  --lr for left/right
        din: in std_logic_vector(3 downto 0);
        so: out std_logic
        );
    end component;

    ---------------------------------------------------------------
    -- SIGNALS 
    ---------------------------------------------------------------
    signal t_din      : std_logic_vector(3 downto 0) := (others => '1');
    signal t_rst      : std_logic := '1';
    signal t_en       : std_logic := '0';
    signal t_si       : std_logic := '0';
    signal t_pl       : std_logic := '0';
    signal t_lr       : std_logic := '1';
    signal t_so       : std_logic;
    signal t_clk      : std_logic := '0';
    ---------------------------------------------------------------
    -- CONSTANTS
    ---------------------------------------------------------------
    constant CLOCK_PERIOD : time := 100 ns;

begin 

    DUT : shift_reg3
        port map (
            din => t_din,
            rst => t_rst,
            en => t_en,
            si => t_si,
            pl => t_pl,
            lr => t_lr,
            so => t_so,
            clk => t_clk
        );


    STIMULUS : process
    begin
        ---------------------------------------------------------------
        --  EXAMPLE INPUTS
        t_rst <= '0';                   --reset 
        wait for (1 * CLOCK_PERIOD);
        t_rst <= '1';
        wait for (2 * CLOCK_PERIOD);
        t_pl <= '1';                    --load
        wait for (1 * CLOCK_PERIOD);
        t_pl <='0';
        wait for (2 * CLOCK_PERIOD);
        
        t_en <= '1';                    --shift 3 times right
        wait for (3 * CLOCK_PERIOD);
        t_lr <= '0';                    --shift 3 times left
        wait for (3 * CLOCK_PERIOD);
        t_lr <= '1';   
        t_si <= '1';
        wait for (4 * CLOCK_PERIOD);
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