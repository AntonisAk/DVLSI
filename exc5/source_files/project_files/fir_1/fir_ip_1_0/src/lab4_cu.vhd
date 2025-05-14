library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
    port(
        clk: in std_logic;
        rst: in std_logic;
        valid_in: in std_logic;
        rom_addr: out std_logic_vector(2 downto 0);
        ram_addr: out std_logic_vector(2 downto 0);
        mac_init: out std_logic;
        we: out std_logic;
        valid_out: out std_logic
    );
end control_unit;

architecture behavioral of control_unit is
    signal count: std_logic_vector(2 downto 0);
begin
    addr_cnt: process(clk,rst)
    begin
        if rst = '1' then
            count <= "000";
            mac_init <= '1';
        else
            if clk'event and clk = '1' then
                if valid_in = '1' then
                    count <= "000";
                    valid_out <= '1';
                    mac_init <= '1';
                    we <= '1';
                else
                    count <= count + 1;
                    valid_out <= '0';
                    mac_init <= '0';
                    we <= '0';
                end if;
            end if;
        end if;
    end process;

    rom_addr <= count;
    ram_addr <= count; 
end behavioral;
