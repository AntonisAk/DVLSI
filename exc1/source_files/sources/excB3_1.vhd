library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity count3 is
  Port (
    clk,
    resetn,
    count_en    :in std_logic;
    ud          :in std_logic;   --up/down control 
    sum         :out std_logic_vector(2 downto 0);
    cout        :out std_logic
   );
end entity;

architecture rtl_nolimit of count3 is
signal count: std_logic_vector(2 downto 0);
begin 
    process(clk,resetn)
    begin
        if resetn='0' then
            count<=(others=>'0');
        elsif clk'event and clk='1' then 
            if count_en='1' then 
                case ud is 
                    when '1'=> count<=count+1;
                    when '0'=> count<=count-1;
                    when others => count<=(others=>'-');
                end case;
            end if;
        end if;
    end process;
    sum<=count;
        cout<='1' when (count=7 and count_en='1' and ud='1') or (count=0 and count_en='1' and ud='0') 
              else '0';

end rtl_nolimit;

--architecture rtl_limit of count3 is
--signal count: std_logic_vector(2 downto 0);
--begin 
--    process(clk,resetn)
--    begin
--        if resetn='0' then
--            count<=(others=>'0');
--        elsif clk'event and clk='1' then 
--            if count_en='1' then 
--                case ud is 
--                    when '1'=> 
--                        if count/=3 then 
--                            count<=count+1;
--                        else 
--                            count<=(others=>'0');
--                        end if;
--                    when '0'=> 
--                        if count/=3 then 
--                            count<=count-1;
--                        else 
--                            count<=(others=>'1');
--                        end if;
--                    when others => count<=(others=>'-');
--                end case;
--            end if;
--        end if;
--    end process;
--    sum<=count;
--    cout<='1' when (count=7 and count_en='1' and ud='1') or (count=0 and count_en='1' and ud='0')
--              else '0';

--end rtl_limit;
