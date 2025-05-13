library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

entity count3_mod is
  Port (
    clk,
    resetn,
    count_en    :in std_logic;
    count_mod   :in std_logic_vector (2 downto 0);
    sum         :out std_logic_vector(2 downto 0);
    cout        :out std_logic
   );
end entity;

architecture rtl_limit of count3_mod is
signal count: std_logic_vector(2 downto 0);
begin 
    process(clk,resetn)
    begin
        if resetn='0' then
            count<=(others=>'0');
        elsif clk'event and clk='1' then 
            if count_en='1' then 
                count <= std_logic_vector(to_unsigned(to_integer(unsigned(count+1)) mod to_integer(unsigned(count_mod)), 3));
            end if;
        end if;
    end process;
    sum <= std_logic_vector(to_unsigned(to_integer(unsigned(count)) mod to_integer(unsigned(count_mod)), 3));
    cout<='1' when count=7 and count_en='1' 
              else '0';

end rtl_limit;
