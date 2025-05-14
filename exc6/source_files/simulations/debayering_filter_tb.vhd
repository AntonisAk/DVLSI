library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity debayering_filter_tb is
end debayering_filter_tb;

architecture debayering_filter_tb_arch of debayering_filter_tb is
    component debayering_filter is
        generic( N : integer := 32);
        port(
            clk: in std_logic;
            rst_n: in std_logic;
            new_image: in std_logic;
            valid_in: in std_logic;
            pixel: in std_logic_vector(7 downto 0);
            image_finished: out std_logic;
            valid_out: out std_logic;
            R: out std_logic_vector(7 downto 0);
            G: out std_logic_vector(7 downto 0);
            B: out std_logic_vector(7 downto 0)
        );
    end component;

    constant CLKP : time := 1ns;

    signal clk, new_image, valid_in, image_finished, valid_out: std_logic := '0';
    signal rst: std_logic;
    signal pixel: std_logic_vector(7 downto 0);
    signal R, G, B: std_logic_vector(7 downto 0);
    signal init: std_logic := '0';
    signal count: std_logic_vector(9 downto 0) := (others => '0');
    
begin
    
        clk_proc: process
        begin
            clk <= '0';
            wait for CLKP/2;
            clk <= '1';
            wait for CLKP/2;
        end process;
    
        UUT: debayering_filter port map(
            clk => clk,
            rst_n => rst,
            new_image => new_image,
            valid_in => valid_in,
            pixel => pixel,
            image_finished => image_finished,
            valid_out => valid_out,
            R => R,
            G => G,
            B => B
        );
    
        testSequence: process
        file input_file : text open read_mode is "/path/to/input.txt";

        Variable in_line_buffer : line;
        Variable pixel_buffer : integer;
        begin
            rst <= '0';
            wait for 5*CLKP;
            rst <= '1';
            
            while (not endfile(input_file)) loop
            if count = std_logic_vector(to_unsigned(0,10)) then
                new_image <= '1';
                init <= '1';
            else
                new_image <= '0';
            end if;
            if count = std_logic_vector(to_unsigned(43,10)) then
               valid_in <= '0'; 
                wait for 10*CLKP;
            end if;
            valid_in <= '1';
            readline(input_file, in_line_buffer);
            read(in_line_buffer, pixel_buffer);
            pixel <= std_logic_vector(to_unsigned(pixel_buffer, 8));
            count <= count + 1;

            wait for CLKP;
            end loop;
            valid_in <= '0';
            
            wait for 50 * CLKP;
            rst <= '0';
            
            wait;
        end process;
        
        
        process(clk)
            file output_file : text open write_mode is "/path/to/output.txt";
            variable out_line_buffer : line;
        begin
            if rising_edge(clk) then 
                if valid_out = '1' then
                    write(out_line_buffer, string'("("));
                    write(out_line_buffer, integer'image(to_integer(unsigned(R))));
                    write(out_line_buffer, string'(", "));
                    write(out_line_buffer, integer'image(to_integer(unsigned(G))));
                    write(out_line_buffer, string'(", "));
                    write(out_line_buffer, integer'image(to_integer(unsigned(B))));
                    write(out_line_buffer, string'(")"));
                    writeline(output_file, out_line_buffer);
                end if;
            end if;
        end process;
        
end debayering_filter_tb_arch;