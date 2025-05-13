library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mac_tb is
    generic (
		data_width : integer :=8  				--- width of data (bits)
	 );
end mac_tb;


architecture test_bench of mac_tb is
     component mac is 
        Port (
            init: in std_logic;
            b: in std_logic_vector(7 downto 0);
            c: in std_logic_vector(7 downto 0);
            clk: in std_logic;
            y: out std_logic_vector(18 downto 0) -- 2X + 3 bits
        );
    end component;
    
    signal clk : std_logic;
    signal init: std_logic;
    signal b   : std_logic_vector(data_width-1 downto 0);   
    signal c   : std_logic_vector(data_width-1 downto 0);   
    signal y   : std_logic_vector(2*data_width+3-1 downto 0);
   
    constant CLOCK_PERIOD : time := 10 ns; 
begin
    
    MAC_INST: mac
        port map(init, b, c, clk, y);


    STIMULUS: process
    begin 
        init <= '0';
        b <= std_logic_vector(to_unsigned(2,8));
        for i in 0 to 8 loop
            c <= std_logic_vector(to_unsigned(i,8));
            wait for (1*CLOCK_PERIOD);
        end loop;
        
        init <= '1';
        wait for CLOCK_PERIOD;
        init <= '0';
        
        for i in 0 to 8 loop
            c <= std_logic_vector(to_unsigned(i,8));
            b <= std_logic_vector(to_unsigned(i,8));
            wait for (1*CLOCK_PERIOD);
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
