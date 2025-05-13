library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fa_and_module is
    port(
            i_a     : in std_logic;
            i_b     : in std_logic;
            i_sin   : in std_logic;
            i_cin   : in std_logic;
            o_sum   : out std_logic;
            o_cout  : out std_logic          
        );
end fa_and_module;

architecture structural of fa_and_module is
    component full_adder_behavioral is
        port(
            i_a     : in std_logic;
            i_b     : in std_logic;
            i_cin   : in std_logic;
            o_sum   : out std_logic;
            o_cout  : out std_logic          
        );
    end component;
    
    signal w_and    : std_logic;
    
begin
    w_and <= i_a and i_b;
    FA: full_adder_behavioral 
        port map(i_sin,w_and,i_cin,o_sum,o_cout);

end structural;
