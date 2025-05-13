--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_unsigned.all;


--entity fir_tb is
--    generic (
--		data_width : integer :=8;		
--		coef_width : integer :=8		
--	 );
--end fir_tb;

--architecture test_bench of fir_tb is
--    component fir  is 
--        port (
--            clk : in std_logic;
--            rst : in std_logic;
--            valid_in  : in std_logic;						               
--            valid_out : out std_logic;
--            x   : in std_logic_vector(data_width-1 downto 0);		
--            y   : out std_logic_vector(2*data_width+3-1 downto 0));
--    end component;

--    signal clk  : std_logic;
--    signal rst  : std_logic;
--    signal valid_in  : std_logic;						               
--    signal valid_out : std_logic;
--    signal x    : std_logic_vector(data_width-1 downto 0);		
--    signal y    :  std_logic_vector(2*data_width+3-1 downto 0);		


--    constant CLOCK_PERIOD : time := 10 ns; 


--begin
   
--    FIR_INST: fir
--        port map(clk,rst,valid_in,valid_out,x,y);
        
--    STIMULUS: process 
--    begin
        
--        rst <= '1';
--        wait for (2*CLOCK_PERIOD);            
--        rst <= '0';            
         
--        for i in 1 to 10 loop
--            valid_in <='1';
--            x <= std_logic_vector(to_unsigned(10*i,8));
--            wait for (1 * CLOCK_PERIOD);
--            valid_in <='0';
--            wait for (7 * CLOCK_PERIOD);

--        end loop;
--        wait for (10*CLOCK_PERIOD);
        
--        wait;
--    end process;
    

--    GEN_CLK : process
--    begin
--        clk <= '0';
--        wait for (CLOCK_PERIOD / 2);
--        clk <= '1';
--        wait for (CLOCK_PERIOD / 2);
--    end process;
    
    



--end test_bench;


library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity fir_tb is
end fir_tb;

architecture fir_tb_arch of fir_tb is
    component fir_filter
        port(
            clk: in std_logic;
            rst: in std_logic;
            valid_in: in std_logic;
            valid_out: out std_logic;
            x: in std_logic_vector(7 downto 0);
            y: out std_logic_vector(18 downto 0)            
        );
    end component;

    constant CLKP : time := 1ns;

    signal x_s: std_logic_vector(7 downto 0);
    signal y_s: std_logic_vector(18 downto 0);
    signal rst_s, clk, valid_in_s, valid_out_s: std_logic;

    type x_array is array (0 to 15) of std_logic_vector(7 downto 0);
    signal data : x_array := (
        "11010101",  -- Random binary values
        "01101011",
        "10101100",
        "00111010",
        "10010011",
        "11100001",
        "01011100",
        "00100111",
        "11001101",
        "00011010",
        "10110100",
        "01100011",
        "11111000",
        "00001111",
        "10000110",
        "01001001"
    );

begin

    clk_proc: process
    begin
        clk <= '0';
        wait for CLKP/2;
        clk <= '1';
        wait for CLKP/2;
    end process;

    UUT: fir_filter port map (clk,rst_s,valid_in_s,valid_out_s,x_s,y_s);
    testSequence: process
    begin
        valid_in_s <= '0';
        rst_s <= '1';
        wait for CLKP;
        rst_s <= '0';
        for i in 0 to 15 loop
            for j in 0 to 7 loop
                if j=0 then
                    valid_in_s <= '1';
                    x_s <= data(i);
                else
                    valid_in_s <= '0';
                end if;
                wait for CLKP;
            end loop;
        end loop;
        wait for 8*CLKP;
        rst_s <= '1';
        wait for CLKP;
    end process;
end fir_tb_arch;