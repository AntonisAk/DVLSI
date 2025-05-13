library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real."log2";

entity compute_unit_tb is
end compute_unit_tb;

architecture Behavioral of compute_unit_tb is 

constant N : integer := 32;

component compute_unit is
generic(N : integer := N);
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        input       : in std_logic_vector(71 downto 0);
        pixel_no    : in std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0);
        valid_in    : in std_logic;
        R,G,B       : out std_logic_vector(7 downto 0);
        valid_out   : out std_logic := '0';
        image_finished  : out std_logic := '0' 
    );
end component;

signal clk  : std_logic;
signal rst  : std_logic := '0';
signal valid_in : std_logic := '0';
signal valid_out: std_logic := '0';
signal img_fin  : std_logic := '0';
signal input    : std_logic_vector(71 downto 0);
signal state    : std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0);
signal R,G,B    : std_logic_vector(7 downto 0);

type pixel_arr is array (8 downto 0) of std_logic_vector(7 downto 0);
signal data : pixel_arr := (others => (others => '0'));


begin

INS:
    compute_unit
    port map(
        clk => clk,
        rst => rst,
        input => input,
        pixel_no => state,
        valid_in => valid_in,
        R => R,
        G => G,
        B => B,   
        valid_out => valid_out,
        image_finished => img_fin     
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
        input(i*8+7 downto i*8) <= data(i);
end generate;   

test:
    process    
    begin
        rst <= '1';
        wait for 10ns;
        rst <= '0';
        
        valid_in <= '1';
        
        for i in 0 to 63 loop
            state <= std_logic_vector(to_unsigned(i,2 * integer(log2(real(N)))));
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
