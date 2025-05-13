library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity full_adder_pipeline is
    Port ( 
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_a : in std_logic_vector(3 downto 0);
        i_b : in std_logic_vector(3 downto 0);
        i_cin : in std_logic;
        o_sum : out std_logic_vector(3 downto 0);
        o_cout : out std_logic
    );
end full_adder_pipeline;

architecture structural_arch of full_adder_pipeline is
    component full_adder_behavioral is
        port(
            i_a : in std_logic;
            i_b : in std_logic;
            i_cin : in std_logic;
            o_sum : out std_logic;
            o_cout : out std_logic          
        );
    end component;
    
    --input signals
    signal a_sig:   std_logic_vector(3 downto 0) := (others=>'0');
    signal b_sig:   std_logic_vector(3 downto 0) := (others=>'0');
    signal cin_sig: std_logic_vector(3 downto 0) := (others=>'0');
    signal cout_sig:std_logic_vector(3 downto 0) := (others=>'0');
    signal sum_sig: std_logic_vector(3 downto 0) := (others=>'0');
       
       
    --input registers
    signal a1_reg: std_logic := '0';
    signal a2_reg: std_logic_vector(1 downto 0) := (others=>'0');
    signal a3_reg: std_logic_vector(2 downto 0) := (others=>'0');
    signal b1_reg: std_logic := '0';
    signal b2_reg: std_logic_vector(1 downto 0) := (others=>'0');
    signal b3_reg: std_logic_vector(2 downto 0) := (others=>'0');
    
    --sum registers
    signal s0_reg: std_logic_vector(2 downto 0) := (others=>'0');
    signal s1_reg: std_logic_vector(1 downto 0) := (others=>'0');
    signal s2_reg: std_logic := '0';
    
begin

    FA_GEN:for i in 0 to 3 generate
        FA: full_adder_behavioral
            port map(a_sig(i),b_sig(i),cin_sig(i),sum_sig(i),cout_sig(i));
    end generate FA_GEN;
    
    FA_PIPELINE_LOGIC: process(i_clk)
    begin
        if (rising_edge(i_clk)) then 
            if (i_rst = '1') then
                 a_sig <= (others=>'0');
                 b_sig <= (others=>'0');
                 cin_sig <= (others=>'0');
                 a1_reg <= '0';   
                 a2_reg <= (others=>'0');   
                 a3_reg <= (others=>'0');
                 b1_reg <= '0';   
                 b2_reg <= (others=>'0');   
                 b3_reg <= (others=>'0'); 
                 s0_reg <= (others=>'0');   
                 s1_reg <= (others=>'0');   
                 s2_reg <= '0';   
                 o_cout <= '0';
                 o_sum <= (others=> '0');
            else 
                ------sum------ 
                o_sum(0) <= s0_reg(2);
                o_sum(1) <= s1_reg(1);
                o_sum(2) <= s2_reg;
                o_sum(3) <= sum_sig(3);
                
                s0_reg(2) <= s0_reg(1);
                s0_reg(1) <= s0_reg(0);
                s0_reg(0) <= sum_sig(0);
                
                s1_reg(1) <= s1_reg(0);
                s1_reg(0) <= sum_sig(1);
                                
                s2_reg <= sum_sig(2);
                
               	------carry------ 
                o_cout <= cout_sig(3);
                cin_sig(3) <= cout_sig(2);
                cin_sig(2) <= cout_sig(1);
                cin_sig(1) <= cout_sig(0);
                cin_sig(0) <= i_cin;
                              
                ------a_in------ 
                a_sig(0) <= i_a(0);

                a_sig(1) <= a1_reg;
                a1_reg <= i_a(1);
                
                a_sig(2) <= a2_reg(0);
                a2_reg(0) <= a2_reg(1);
                a2_reg(1) <= i_a(2);

                a_sig(3) <= a3_reg(0);
                a3_reg(0) <= a3_reg(1);
                a3_reg(1) <= a3_reg(2);
                a3_reg(2) <= i_a(3);
				
				------b_in------
                b_sig(0) <= i_b(0);

                b_sig(1) <= b1_reg;
                b1_reg <= i_b(1);

                b_sig(2) <= b2_reg(0);
                b2_reg(0) <= b2_reg(1);
                b2_reg(1) <= i_b(2);
                
				b_sig(3) <= b3_reg(0);
                b3_reg(0) <= b3_reg(1);
                b3_reg(1) <= b3_reg(2);
                b3_reg(2) <= i_b(3);
                
                
            end if;
        end if;
    end process;
    
end structural_arch;
