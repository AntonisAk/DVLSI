library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity bcd_full_adder is
    Port (
        i_a     :in std_logic_vector (3 downto 0);
        i_b     :in std_logic_vector (3 downto 0);
        i_cin   :in std_logic;  
        o_sum   :out std_logic_vector (3 downto 0);  
        o_cout :out std_logic
   );
end bcd_full_adder;

architecture structural_arch of bcd_full_adder is

    signal w_carry  :std_logic;
    signal w_sum    :std_logic_vector(3 downto 0);
    signal w_midin  :std_logic_vector(3 downto 0);
    
    component adder_4bit is
        Port ( 
            i_a     :in std_logic_vector(3 downto 0);
            i_b     :in std_logic_vector(3 downto 0);
            i_cin   :in std_logic;
            o_sum   :out std_logic_vector(3 downto 0);
            o_cout  :out std_logic    
        );
    end component;


begin

    FA1: adder_4bit
    port map(
        i_a => i_a,
        i_b => i_b,
        i_cin => i_cin,
        o_sum => w_sum,
        o_cout => w_carry
    );
    
    w_midin(0) <= '0'; 
    w_midin(3) <= '0'; 
    w_midin(1) <= (w_carry or (w_sum(3) and w_sum(2)) or (w_sum(3) and w_sum(1)));
    w_midin(2) <= (w_carry or (w_sum(3) and w_sum(2)) or (w_sum(3) and w_sum(1)));
    
    FA2: adder_4bit
    port map(
        i_a => w_sum,
        i_b => w_midin,
        i_cin => '0',
        o_sum => o_sum
    );
    
    o_cout <= (w_carry or (w_sum(3) and w_sum(2)) or (w_sum(3) and w_sum(1)));


end structural_arch;
