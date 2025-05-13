library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity mlab_rom_tb is
    generic (
		coeff_width : integer :=8  			
	 );
end mlab_rom_tb;

architecture test_bench of mlab_rom_tb is
    component mlab_rom is 
        Port ( 
            clk : in  STD_LOGIC;
            en : in  STD_LOGIC;				--- operation enable
            addr : in  STD_LOGIC_VECTOR (2 downto 0);			-- memory address
            rom_out : out  STD_LOGIC_VECTOR (coeff_width-1 downto 0));	-- output data
    end component;
    
    signal clk  : std_logic;
    signal en   : std_logic;
    signal addr : std_logic_vector(2 downto 0); 
    signal rom_out  : std_logic_vector(coeff_width-1 downto 0); 

    constant CLOCK_PERIOD : time := 10 ns; 


begin
   
    rom: mlab_rom
        port map(clk,en,addr,rom_out);
        
    STIMULUS: process 
    begin
        en <= '1';
        addr <= "000";        
        for i in 0 to 10 loop
            addr <= std_logic_vector(to_unsigned(i,3));
            wait for (1 * CLOCK_PERIOD);
        end loop;
        wait;
    end process;
   
   
    clk_proc: process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD/2;
        clk <= '1';
        wait for CLOCK_PERIOD/2;
    end process; 
   
end test_bench;
