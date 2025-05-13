library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real."log2";

entity edge_corrector is
    generic(N : integer := 32);
    port(
        clk         : in std_logic;
        valid_in    : in std_logic;
        valid_out   : out std_logic := '0';
        state_in    : in std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0);
        state_out   : out std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0) := (others => '0');
        data_in     : in std_logic_vector(71 downto 0);
        data_out    : out std_logic_vector(71 downto 0) := (others => '0')
    );
end edge_corrector;

architecture Behavioral of edge_corrector is

    type data_arr is array (8 downto 0) of std_logic_vector(7 downto 0);
    signal data : data_arr := (others => (others=>'0'));


begin
    
    -- Insert data array to a single output vector   
    OUT_GEN:
    for i in 0 to 8 generate
            data_out(i*8+7 downto i*8) <= data(i);
    end generate; 
    
    process(clk)
    begin
        if rising_edge(clk) then
            --INPUT_PARSE
            for i in 0 to 8 loop
                data(i) <= data_in(i*8+7 downto i*8);
            end loop;
           
            
            -- Check columns
            if to_integer(unsigned(state_in)) mod N = N-1 then
                -- Last column
                data(0) <= (others=>'0');
                data(3) <= (others=>'0');
                data(6) <= (others=>'0');
            elsif to_integer(unsigned(state_in)) mod N = 0 then
                -- First column
                data(2) <= (others=>'0');
                data(5) <= (others=>'0');
                data(8) <= (others=>'0');
            end if;
            
            -- Check rows
            if to_integer(unsigned(state_in)) / N = N-1 then
                -- Last row
                data(0) <= (others=>'0');
                data(1) <= (others=>'0');
                data(2) <= (others=>'0');
            elsif to_integer(unsigned(state_in)) / N = 0 then
                -- First row
                data(6) <= (others=>'0');
                data(7) <= (others=>'0');
                data(8) <= (others=>'0');
            end if;           
                       
            valid_out <= valid_in;
            state_out <= state_in;
        end if;
    end process;


end Behavioral;
