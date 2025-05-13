library IEEE;
use IEEE.std_logic_1164.all;

entity shift_reg3 is
    port(
        clk,rst,si,en,pl,lr: in std_logic;  --lr for left/right
        din: in std_logic_vector(3 downto 0);
        so: out std_logic
--        dff: linkage std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of shift_reg3 is
    signal dff: std_logic_vector(3 downto 0);
begin
    edge: process (clk,rst)
    begin
        if rst='0' then
            dff<=(others=>'0');
        elsif clk'event and clk='1' then
            if pl='1' then          --parallel load
                dff<=din;
            elsif en='1' then       --shift
                if lr='1' then               --lr = 1 -> right
                    dff<=si&dff(3 downto 1); --right shift input
                elsif lr='0' then            --lr = 0 -> left   
                    dff<=dff(2 downto 0)&si; --left shift input
                end if;
            end if;
        end if;
    end process;
         
    so <= 
        dff(0) when lr='1' else
        dff(3) when lr='0';
end rtl;