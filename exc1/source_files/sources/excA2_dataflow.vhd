--3 to 8 decoder | dataflow design

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity dec_3_to_8_dataflow is
    port(
        i_enc   : in std_logic_vector (2 downto 0);
        o_dec   : out std_logic_vector (7 downto 0)
    );
end entity;

architecture dataflow_arch of dec_3_to_8_dataflow is

begin
    o_dec(0) <= (not i_enc(2))  and (not i_enc(1))  and (not i_enc(0)) ;
    o_dec(1) <= (not i_enc(2))  and (not i_enc(1))  and i_enc(0) ;
    o_dec(2) <= (not i_enc(2))  and i_enc(1)        and (not i_enc(0)) ;
    o_dec(3) <= (not i_enc(2))  and i_enc(1)        and i_enc(0) ;
    o_dec(4) <= i_enc(2)        and (not i_enc(1))  and (not i_enc(0)) ;
    o_dec(5) <= i_enc(2)        and (not i_enc(1))  and i_enc(0) ;
    o_dec(6) <= i_enc(2)        and i_enc(1)        and (not i_enc(0)) ;
    o_dec(7) <= i_enc(2)        and i_enc(1)        and i_enc(0) ;

--    with i_enc select o_dec <=
--        X"01" when "000",
--        X"02" when "001",
--        X"04" when "010",
--        X"08" when "011",
--        X"10" when "100",
--        X"20" when "101",
--        X"40" when "110",
--        X"80" when "111",
--        (others => '-') when others; 

end architecture;
