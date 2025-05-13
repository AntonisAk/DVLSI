library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_adder_4dig is
    Port (
        i_a     :in std_logic_vector (15 downto 0);
        i_b     :in std_logic_vector (15 downto 0);
        o_sum   :out std_logic_vector (15 downto 0);
        o_cout  :out std_logic   
     );
end bcd_adder_4dig;

architecture structural_arch of bcd_adder_4dig is
    signal carry    :std_logic_vector(2 downto 0);
    
    component bcd_full_adder is
        Port ( 
            i_a     :in std_logic_vector(3 downto 0);
            i_b     :in std_logic_vector(3 downto 0);
            i_cin   :in std_logic;
            o_sum   :out std_logic_vector(3 downto 0);
            o_cout  :out std_logic    
        ); 
    end component;
    
begin

    BCDFA1: bcd_full_adder
    port map(
        i_a => i_a(3 downto 0),     
        i_b => i_b(3 downto 0),
        i_cin => '0',
        o_sum => o_sum(3 downto 0),
        o_cout => carry(0)
    );
    
    BCDFA2: bcd_full_adder
    port map(
        i_a => i_a(7 downto 4),     
        i_b => i_b(7 downto 4),
        i_cin => carry(0),
        o_sum => o_sum(7 downto 4),
        o_cout => carry(1)
    );
    BCDFA3: bcd_full_adder
    port map(
        i_a => i_a(11 downto 8),     
        i_b => i_b(11 downto 8),
        i_cin => carry(1),
        o_sum => o_sum(11 downto 8),
        o_cout => carry(2)
    );
    BCDFA4: bcd_full_adder
    port map(
        i_a => i_a(15 downto 12),     
        i_b => i_b(15 downto 12),
        i_cin => carry(2),
        o_sum => o_sum(15 downto 12),
        o_cout => o_cout
    );
    


end structural_arch;
