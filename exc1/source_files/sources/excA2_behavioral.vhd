-------------------------------------------------------------------
-- DEC 3 TO 8 (BEHAVIORAL)
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec_3_to_8_behavioral is
    port (
        i_enc     : in    std_logic_vector(2 downto 0);
        o_dec     : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture behavioral_arch of dec_3_to_8_behavioral is

begin 
    
    DEC_MODULE : process(i_enc)
    begin
        case i_enc is
            when "000" => 
                o_dec <= X"01";
            when "001" => 
                o_dec <= X"02";
            when "010" => 
                o_dec <= X"04";
            when "011" => 
                o_dec <= X"08";
            when "100" => 
                o_dec <= X"10";
            when "101" => 
                o_dec <= X"20";
            when "110" => 
                o_dec <= X"40";
            when "111" => 
                o_dec <= X"80";
            when others => 
                o_dec <= (others => '-');
        end case;
    end process;

end behavioral_arch;