library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.math_real."log2";
use std.textio.all;

entity fifo_test_tb is
end fifo_test_tb;

architecture test_bench of fifo_test_tb is

    constant N : integer := 32;
    component ser2par is
        generic(N : integer := N);
        port(
            clk     : IN STD_LOGIC;
            rst     : IN STD_LOGIC; -- resets on '1'
            input   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            valid_in: IN STD_LOGIC;
            new_image   : IN STD_LOGIC;
            valid_out   : OUT STD_LOGIC;
            output      : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
            pixel_no    : OUT STD_LOGIC_VECTOR(2 * integer(log2(real(N)))-1 downto 0)
        );
    end component;
    
constant CLKP : time := 1ns;


signal clk      : std_logic;
signal rst      : std_logic := '0';
signal valid_in : std_logic := '0';
signal valid_out1   : std_logic := '0';
signal valid_out2   : std_logic := '0';
signal new_image    : std_logic := '0';
signal data_in      : std_logic_vector(7 downto 0);
signal data_out1    : std_logic_vector(71 downto 0);
signal data_out2    : std_logic_vector(71 downto 0);
signal state1       : std_logic_vector(2 * integer(log2(real(N)))-1 downto 0);
signal state2       : std_logic_vector(2 * integer(log2(real(N)))-1 downto 0);
signal init     : std_logic := '0';
signal count: std_logic_vector(9 downto 0) := (others => '0');


begin

FIFO_INST: ser2par
    port map(
       clk => clk,
       rst => rst,
       input => data_in,
       valid_in => valid_in,
       new_image => new_image,
       valid_out => valid_out1,
       output => data_out1,
       pixel_no => state1
    );
    
test_pr:process

    file file_handler : text open read_mode is "/path/to/input.txt";
    Variable line_buffer : line;
    Variable pixel_buffer : integer;
begin
        
        rst <= '1';
        wait for 5*CLKP;
        rst <= '0';
        
        while (not endfile(file_handler)) loop
            if count = std_logic_vector(to_unsigned(0,10)) then
                new_image <= '1';
                init <= '1';
            else
                new_image <= '0';
            end if;
            if count = std_logic_vector(to_unsigned(105,10)) then
               valid_in <='0'; 
                wait for 10*CLKP;
            end if;
            valid_in <= '1';
            readline(file_handler,line_buffer);
            read(line_buffer, pixel_buffer);
            data_in <= std_logic_vector(to_unsigned(pixel_buffer,8));
            count <= count + 1;
            wait for CLKP;
        end loop;
        valid_in <= '0';
        
        wait for 100 * CLKP;
        rst <= '1';
            
    wait;
end process;

clk_proc: process
begin
    clk <= '0';
    wait for CLKP/2;
    clk <= '1';
    wait for CLKP/2;
end process;

end test_bench;
