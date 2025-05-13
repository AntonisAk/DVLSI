library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity adder_4bit is
    Port ( 
        i_a     :in std_logic_vector(3 downto 0);
        i_b     :in std_logic_vector(3 downto 0);
        i_cin   :in std_logic;
        o_sum   :out std_logic_vector(3 downto 0);
        o_cout  :out std_logic    
  );
end entity;

architecture structural of adder_4bit is
    signal carry : std_logic_vector(2 downto 0);
    
    component full_adder is
        Port ( 
            i_a : in STD_LOGIC;
            i_b : in STD_LOGIC;
            i_c : in STD_LOGIC;
            o_sum : out STD_LOGIC;
            o_carry : out STD_LOGIC
           );
    end component; 

begin

    FA1: full_adder
        port map(
            i_a => i_a(0),
            i_b => i_b(0),
            i_c => i_cin,
            o_sum => o_sum(0),  
            o_carry => carry(0)
        );
        
    FA2: full_adder
        port map(
            i_a => i_a(1),
            i_b => i_b(1),
            i_c => carry(0),
            o_sum => o_sum(1),  
            o_carry => carry(1)
        );
    
    FA3: full_adder
        port map(
            i_a => i_a(2),
            i_b => i_b(2),
            i_c => carry(1),
            o_sum => o_sum(2),  
            o_carry => carry(2)
        );
    
    FA4: full_adder
        port map(
            i_a => i_a(3),
            i_b => i_b(3),
            i_c => carry(2),
            o_sum => o_sum(3),  
            o_carry => o_cout
        );
        

end structural;
