library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity control_unit_tb is
    generic (
		data_width : integer :=8		
	 );
end control_unit_tb;

architecture test_bench of control_unit_tb is
    component control_unit is 
        port(
        clk: in std_logic;
        rst: in std_logic;
        valid_in: in std_logic;
        rom_addr: out std_logic_vector(2 downto 0);
        ram_addr: out std_logic_vector(2 downto 0);
        mac_init: out std_logic;
        we: out std_logic;
        valid_out: out std_logic
    );
    end component;

    signal clk  : std_logic;
    signal rst  : std_logic;
    signal valid_in  : std_logic := '0';
    signal rom_address  : std_logic_vector(2 downto 0); 
    signal ram_address  : std_logic_vector(2 downto 0); 
    signal mac_init  : std_logic;
    signal we   : std_logic;
    signal valid_out : std_logic;


    constant CLOCK_PERIOD : time := 10 ns; 


begin
   
    CU: control_unit
        port map(clk,rst,valid_in,rom_address,ram_address,mac_init,we,valid_out);
        
    STIMULUS: process 
    begin
        rst <= '1';
        wait for CLOCK_PERIOD;
        rst <= '0';
        wait for (10*CLOCK_PERIOD);    
        rst <= '1';
        wait for CLOCK_PERIOD;
        rst <= '0';
        wait for CLOCK_PERIOD;
        valid_in <= '1';
        wait;
    end process;
    
    GEN_CLK : process
    begin
        clk <= '0';
        wait for (CLOCK_PERIOD / 2);
        clk <= '1';
        wait for (CLOCK_PERIOD / 2);
    end process;
    
    
end test_bench;
