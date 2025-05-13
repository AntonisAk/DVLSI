library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity mlab_ram_tb is
    generic (
		data_width : integer :=8  			
	 );
end mlab_ram_tb;

architecture test_bench of mlab_ram_tb is
    component mlab_ram is 
        port (
        rst  : in std_logic;
        clk  : in std_logic;
        we   : in std_logic;						--- memory write enable
	    en   : in std_logic;				--- operation enable
        addr : in std_logic_vector(2 downto 0);			-- memory address
        di   : in std_logic_vector(data_width-1 downto 0);		-- input data
        do   : out std_logic_vector(data_width-1 downto 0));		-- output data
    end component;

    signal clk  : std_logic;
    signal rst  : std_logic;
    signal we   : std_logic;
    signal en   : std_logic;
    signal addr : std_logic_vector(2 downto 0); 
    signal di   : std_logic_vector(data_width-1 downto 0); 
    signal do   : std_logic_vector(data_width-1 downto 0); 

    constant CLOCK_PERIOD : time := 10 ns; 


begin
   
    RAM: mlab_ram
        port map(rst,clk,we,en,addr,di,do);
        
    STIMULUS: process 
    begin
        addr <= "000";
        rst <= '0';
        en <= '1';
        we <= '1';
        
        for i in 1 to 10 loop
            di <= std_logic_vector(to_unsigned(10*i,8));
            wait for (1 * CLOCK_PERIOD);
        end loop;
        
        we <= '0';
        for i in 0 to 7 loop
            addr <= std_logic_vector(to_unsigned(i,3));
            wait for (1 * CLOCK_PERIOD);
        end loop;
            
        rst <= '1';
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
