library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real."log2";

entity compute_unit is
    generic(N : integer := 32);
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        input       : in std_logic_vector(71 downto 0);
        pixel_no    : in std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0);
        valid_in    : in std_logic;
        R,G,B       : out std_logic_vector(7 downto 0) := (others => '0');
        valid_out   : out std_logic := '0';
        image_finished  : out std_logic := '0' 
    );
end compute_unit;

architecture Behavioral of compute_unit is
    constant LOGN : integer := integer(log2(real(N)));

    type data_arr is array (8 downto 0) of std_logic_vector(7 downto 0);
    signal data : data_arr := (others => (others => '0'));
    
    -- Define a data type for the colour (FSM state)
    type pixel_colour is (green,red,blue);
    signal pix_clr: pixel_colour := green;
    
begin

    INPUT_PARSE:
    for i in 0 to 8 generate
        data(i) <= input(i*8+7 downto i*8);
    end generate; 
        
    process(clk,rst)
    begin
        if rising_edge(clk) then 
            if rst = '1' then 
                pix_clr <= green;
                valid_out <= '0';
                image_finished <= '0';
                R <= (others => '0');
                G <= (others => '0');
                B <= (others => '0');
                
            
            elsif valid_in = '1' then
                if (to_integer(unsigned(pixel_no)) / N) mod 2 = 0 then -- Even row
                    if (to_integer(unsigned(pixel_no)) mod N) mod 2 = 0 then    -- Even column -> Green
                        pix_clr <= green;
                        G <= data(4);  
                        R <= std_logic_vector(resize((resize(unsigned(data(1)),10)+resize(unsigned(data(7)),10))/2,8));
                        B <= std_logic_vector(resize((resize(unsigned(data(3)),10)+resize(unsigned(data(5)),10))/2,8));  
                    else                                                        -- Odd column -> Blue
                        pix_clr <= blue;
                        B <= data(4);
                        G <= std_logic_vector(resize((resize(unsigned(data(1)),10)+resize(unsigned(data(3)),10)+resize(unsigned(data(5)),10)+resize(unsigned(data(7)),10))/4,8));                        
                        R <= std_logic_vector(resize((resize(unsigned(data(0)),10)+resize(unsigned(data(2)),10)+resize(unsigned(data(6)),10)+resize(unsigned(data(8)),10))/4,8));
                    
                    end if;
                    
                else                                                            -- Odd row
                     if (to_integer(unsigned(pixel_no)) mod N) mod 2 = 0 then    -- Even column -> Red
                        pix_clr <= red;
                        R <= data(4);
                        G <= std_logic_vector(resize((resize(unsigned(data(1)),10)+resize(unsigned(data(3)),10)+resize(unsigned(data(5)),10)+resize(unsigned(data(7)),10))/4,8));
                        B <= std_logic_vector(resize((resize(unsigned(data(0)),10)+resize(unsigned(data(2)),10)+resize(unsigned(data(6)),10)+resize(unsigned(data(8)),10))/4,8));
                    else                                                        -- Odd column -> Green
                        pix_clr <= green;
                        G <= data(4);
                        B <= std_logic_vector(resize((resize(unsigned(data(1)),10)+resize(unsigned(data(7)),10))/2,8));
                        R <= std_logic_vector(resize((resize(unsigned(data(3)),10)+resize(unsigned(data(5)),10))/2,8));
                    end if;
                
                end if;
            
                valid_out <= '1';
                
                -- Set image_finished on the last pixel
                if pixel_no = std_logic_vector(to_unsigned(N*N-1,2*LOGN)) then
                    image_finished <= '1';
                else 
                    image_finished <= '0';
                end if;     
            else
                -- invalid output for invalid input CHECKME
                valid_out <= '0';
            end if;
        end if;
    end process;  

end Behavioral;
