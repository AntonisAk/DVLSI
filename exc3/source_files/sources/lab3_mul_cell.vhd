library ieee;
use ieee.std_logic_1164.all;

entity mul_cell is
    port(
        ain: in std_logic;
        bin: in std_logic;
        cin: in std_logic;
        sin: in std_logic;
        clk: in std_logic;
        aout: out std_logic;
        bout: out std_logic;
        cout: out std_logic;
        sout: out std_logic
    );
end mul_cell;

architecture mul_cell_arch of mul_cell is
    component fa_sync is
        port(
        a: in std_logic;
        b: in std_logic;
        cin: in std_logic;
        clk: in std_logic;
        s: out std_logic;
        cout: out std_logic
    );
    end component;
    signal a_inter,t: std_logic;
begin
    sync_mul: process(clk)
    begin
        if clk'event and clk='1' then
            aout <= a_inter;
            a_inter <= ain;
            bout <= bin;
        end if;
    end process;
    t <= ain and bin;
    fa: fa_sync port map(
        a => sin,
        b => t,
        cin => cin,
        clk => clk,
        s => sout,
        cout => cout
    );
end mul_cell_arch;