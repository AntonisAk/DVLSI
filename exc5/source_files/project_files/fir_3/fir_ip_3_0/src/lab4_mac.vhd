library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mac is
    port(
        init: in std_logic;
        b: in std_logic_vector(7 downto 0);
        c: in std_logic_vector(7 downto 0);
        clk: in std_logic;
        y: out std_logic_vector(18 downto 0) -- 2X + 3 bits
    );
end mac;

architecture behavioral of mac is
    signal acc: std_logic_vector(18 downto 0) := (others => '0'); --accumulator
begin
    calc: process(clk)
    begin
        if clk'event and clk = '1' then
            if init = '1' then
--                acc <= (others => '0');
                acc <= "000" & b * c;
            else
                acc <= acc + (b * c);
            end if;
        end if;
    end process;
    y <= acc;
end behavioral;