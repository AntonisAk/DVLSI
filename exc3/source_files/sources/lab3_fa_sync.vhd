library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fa_sync is
    port(
        a: in std_logic;
        b: in std_logic;
        cin: in std_logic;
        clk: in std_logic;
        s: out std_logic;
        cout: out std_logic
    );
end fa_sync;

architecture behavioral of fa_sync is
    signal result: std_logic_vector(1 downto 0);
begin
    sync_add: process(clk)
    begin
        if clk'event and clk='1' then
            result <= ('0' & a) + ('0' & b) + ('0' & cin);
        end if;
    end process;
    s <= result(0);
    cout <= result(1);
end behavioral;