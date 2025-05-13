library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real."log2";

entity edge_corrector_tb is
end edge_corrector_tb;

architecture Behavioral of edge_corrector_tb is
    constant N : integer := 32;

    component edge_corrector is
        generic(N : integer := N);
        port(
            clk : in std_logic;
            valid_in: in std_logic;
            valid_out   : out std_logic := '0';
            state_in    : in std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0);
            state_out   : out std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0);
            data_in     : in std_logic_vector(71 downto 0);
            data_out    : out std_logic_vector(71 downto 0)
        );
    end component;
    
    signal clk  : std_logic;
    signal valid_in : std_logic := '0';
    signal valid_out: std_logic := '0';
    signal state_in : std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0);
    signal state_out: std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0);
    signal data_in  : std_logic_vector(71 downto 0);
    signal data_out : std_logic_vector(71 downto 0);

type pixel_arr is array (8 downto 0) of std_logic_vector(7 downto 0);
signal data : pixel_arr := (others => (others => '0'));


begin

INST:edge_corrector
    port map(
        clk => clk,
        valid_in => valid_in,
        valid_out => valid_out,
        state_in => state_in,
        state_out => state_out,
        data_in => data_in,
        data_out => data_out
    );



data(0) <= std_logic_vector(to_unsigned(43,8)); 
data(1) <= std_logic_vector(to_unsigned(64,8)); 
data(2) <= std_logic_vector(to_unsigned(7,8)); 
data(3) <= std_logic_vector(to_unsigned(4,8)); 
data(4) <= std_logic_vector(to_unsigned(95,8)); 
data(5) <= std_logic_vector(to_unsigned(100,8)); 
data(6) <= std_logic_vector(to_unsigned(36,8)); 
data(7) <= std_logic_vector(to_unsigned(255,8)); 
data(8) <= std_logic_vector(to_unsigned(42,8)); 

Gds:
for i in 0 to 8 generate
        data_in(i*8+7 downto i*8) <= data(i);
end generate;   

test:
    process    
    begin       
        valid_in <= '1';
        
        for i in 0 to 63 loop
            state_in <= std_logic_vector(to_unsigned(i,2 * integer(log2(real(N)))));
            wait for 10ns;
        end loop;
        valid_in <= '0';
        
        wait;
    end process;
    
clk_proc: process
begin
    clk <= '0';
    wait for 5ns;
    clk <= '1';
    wait for 5ns;
end process;





end Behavioral;
