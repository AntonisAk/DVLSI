library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mul_2bit_pipeline is
    Port (
        i_clk   : in std_logic;
        i_a     : in std_logic_vector(1 downto 0);        
        i_b     : in std_logic_vector(1 downto 0);        
        o_sum   : out std_logic_vector(3 downto 0) := (others=>'0')
    );
    
end mul_2bit_pipeline;

architecture Behavioral of mul_2bit_pipeline is
    component fa_and_module is
    port(
            i_a     : in std_logic;
            i_b     : in std_logic;
            i_sin   : in std_logic;
            i_cin   : in std_logic;
            o_sum   : out std_logic;
            o_cout  : out std_logic          
        );        
    end component;
    
    type my_array is array (0 to 1) of std_logic_vector(3 downto 0);
    
    signal a    : my_array;
    signal b    : my_array;
    signal sin  : my_array;
    signal cin  : my_array;
    signal sum  : my_array;
    signal cout  : my_array;
    
    signal a0_reg  : std_logic;
    signal a1_reg  : std_logic_vector(1 downto 0);
    signal b1_reg  : std_logic_vector(1 downto 0);
    
    signal s0_reg  : std_logic_vector(1 downto 0);
    signal s1_reg  : std_logic;
        
       
begin

    sin(0)(0) <= '0';
    sin(1)(0) <= '0';
    sin(1)(1) <= '0';
    cin(0)(0) <= '0';
    cin(1)(0) <= '0';
    cin(0)(1) <= '0';
    
    FA1i_GEN: for i in 0 to 1 generate
        FA1j_GEN: for j in 0 to 1 generate
            FA: fa_and_module
            port map(a(i)(j),b(i)(j),sin(i)(j),cin(i)(j),sum(i)(j),cout(i)(j));
        end generate FA1j_GEN;
     end generate FA1i_GEN;


    FA_PIPELINE_LOGIC: process(i_clk)
    begin
        if (rising_edge(i_clk)) then 
            a(0)(0) <= i_a(0);
            b(0)(0) <= i_b(0);
            a(1)(0) <= i_a(1);
            b(1)(0) <= i_b(0);
        
            a(0)(1) <= a0_reg;
            b(0)(1) <= b1_reg(0);
            
            a(1)(1) <= a1_reg(1);
            b(1)(1) <= b1_reg(1);
        
            a0_reg <= i_a(0);
        
            a1_reg(1) <= a1_reg(0);
            a1_reg(0) <= i_a(1);
            
            b1_reg(1) <= b1_reg(0);
            b1_reg(0) <= i_b(1);            
            
            o_sum(0) <= s0_reg(1);
            s0_reg(1) <= s0_reg(0);    
            s0_reg(0) <= sum(0)(0);
        
            o_sum(1) <= s1_reg;
            s1_reg <= sum(0)(1);
            sin(0)(1) <= sum(1)(0);
            
            cin(1)(1) <= cout(0)(1);           
            
            o_sum(2) <= sum(1)(1);               
            
            o_sum(3) <= cout(1)(1);
            
        end if;
    end process;

end Behavioral;
