--Test Bench for dec_3_to_8_behavioral

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dec_3_to_8_behavioral_tb is
end entity;

architecture tb of dec_3_to_8_behavioral_tb is
    ---------------------------------------------------------------
    -- COMPONENT
    ---------------------------------------------------------------
    component dec_3_to_8_behavioral is 
        port (
            i_enc     : in    std_logic_vector(2 downto 0);
            o_dec     : out   std_logic_vector(7 downto 0)
        );
    end component;

    ---------------------------------------------------------------
    -- SIGNALS 
    ---------------------------------------------------------------
    signal i_enc      : std_logic_vector(2 downto 0) := (others => '0');
    signal o_dec      : std_logic_vector(7 downto 0) := (others => '0');

    ---------------------------------------------------------------
    -- CONSTANTS
    ---------------------------------------------------------------
    constant TIME_DELAY : time := 10 ns;

begin 

    DUT : dec_3_to_8_behavioral
        port map (
            i_enc     => i_enc,
            o_dec     => o_dec
        );


    STIMULUS : process
    begin
        ---------------------------------------------------------------
        -- INITIALIZE SIGNALS
        i_enc <= (others => '0');
        wait for (1 * TIME_DELAY);

     
        ---------------------------------------------------------------
        -- EXAMPLE INPUTS 
        for i in 1 to 7 loop
            i_enc <= std_logic_vector(to_unsigned(i,3)); 
            wait for (1 * TIME_DELAY);
        end loop;

        i_enc <= (others => '0');
        wait for (1 * TIME_DELAY);

        wait;

    end process;

end architecture;