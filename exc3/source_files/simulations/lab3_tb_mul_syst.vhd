library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity mul_syst_tb is
end mul_syst_tb;

architecture mul_syst_tb_arch of mul_syst_tb is
    component mul_syst is
        port(
            a: in std_logic_vector(3 downto 0);
            b: in std_logic_vector(3 downto 0);
            clk: in std_logic;
            p: out std_logic_vector(7 downto 0)
        );
    end component;

    constant CLKP : time := 1ns;

    signal a_s: std_logic_vector(3 downto 0);
    signal b_s: std_logic_vector(3 downto 0);
    signal p_s: std_logic_vector(7 downto 0);
    signal clk: std_logic;
begin
    clk_proc: process
    begin
        clk <= '0';
        wait for CLKP/2;
        clk <= '1';
        wait for CLKP/2;
    end process;

    UUT: mul_syst port map (a_s,b_s,clk,p_s);
    testSequence: process
        begin
            a_s <= "0001";
            b_s <= "0001";
            
            for i in 1 to 15 loop
                for j in 1 to 15 loop
                    wait for CLKP;
                    a_s <= a_s + 1;
                end loop;
                b_s <= b_s + 1;
            end loop;
    end process;
end mul_syst_tb_arch;