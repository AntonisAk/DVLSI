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
            x: in std_logic_vector(7 downto 0);
            valid_out: out std_logic;
            y: out std_logic_vector(18 downto 0)            
        );
    end component;

    constant CLKP : time := 1ns;

    signal x_s: std_logic_vector(7 downto 0);
    signal y_s: std_logic_vector(18 downto 0);
    signal rst_s, clk, valid_in_s, valid_out_s: std_logic;

    type x_array is array (0 to 19) of std_logic_vector(7 downto 0);
    signal data : x_array := (
        std_logic_vector(to_unsigned(208,8)),  
        std_logic_vector(to_unsigned(231,8)),  
        std_logic_vector(to_unsigned(32,8)),  
        std_logic_vector(to_unsigned(233,8)),  
        std_logic_vector(to_unsigned(161,8)),  
        std_logic_vector(to_unsigned(24,8)),  
        std_logic_vector(to_unsigned(71,8)),  
        std_logic_vector(to_unsigned(140,8)),  
        std_logic_vector(to_unsigned(245,8)),  
        std_logic_vector(to_unsigned(247,8)),  
        std_logic_vector(to_unsigned(40,8)),
        std_logic_vector(to_unsigned(248,8)),
        std_logic_vector(to_unsigned(245,8)),
        std_logic_vector(to_unsigned(124,8)),
        std_logic_vector(to_unsigned(204,8)),
        std_logic_vector(to_unsigned(36,8)),
        std_logic_vector(to_unsigned(107,8)),
        std_logic_vector(to_unsigned(234,8)),
        std_logic_vector(to_unsigned(202,8)),
        std_logic_vector(to_unsigned(245,8))
    );

begin

    clk_proc: process
    begin
        clk <= '0';
        wait for CLKP/2;
        clk <= '1';
        wait for CLKP/2;
    end process;

    UUT: fir_filter port map (clk,rst_s,valid_in_s,x_s,valid_out_s,y_s);
    testSequence: process
    begin
        rst_s <= '0';
        for i in 0 to 19 loop
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