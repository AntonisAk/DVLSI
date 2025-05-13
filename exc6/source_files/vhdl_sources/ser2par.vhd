library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all; 
use IEEE.math_real."log2";

entity ser2par is
    generic(N   : integer := 32);
    port(
        clk     : IN STD_LOGIC;
        rst     : IN STD_LOGIC; -- resets on '1'
        input   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        valid_in: IN STD_LOGIC;
        new_image   : IN STD_LOGIC;
        valid_out   : OUT STD_LOGIC := '0';
        output  : OUT STD_LOGIC_VECTOR(71 DOWNTO 0) := (others => '0');
        pixel_no   : OUT STD_LOGIC_VECTOR(2 * integer(log2(real(N))) - 1 downto 0) := (others => '0')
    );
end ser2par;

architecture Behavioral of ser2par is

-- Different size FIFOs
COMPONENT fifo_32 is 
  PORT (
    clk : IN STD_LOGIC;
    srst: IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty: OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT fifo_64 is
  PORT (
    clk : IN STD_LOGIC;
    srst: IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty: OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT fifo_128 is
  PORT (
    clk : IN STD_LOGIC;
    srst: IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty: OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT fifo_1024 is
  PORT (
    clk : IN STD_LOGIC;
    srst: IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty: OUT STD_LOGIC
  );
END COMPONENT;

constant LOGN : integer := integer(log2(real(N))); 

type data_arr is array(3 downto 0) of std_logic_vector(7 downto 0);
type reg_arr is array (8 downto 0) of std_logic_vector(7 downto 0);

signal full,empty   : std_logic_vector(3 downto 1);
signal rd_en,wr_en  : std_logic_vector(3 downto 1);
signal data         : data_arr;
signal regs         : reg_arr;

-- Sync signals
signal s_pixel_no       : std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0) := (others => '0');
signal valid_in_count   : std_logic_vector(2 * integer(log2(real(N))) - 1 downto 0) := (others => '0'); -- Counts the inputs  
signal full_image       : std_logic := '0';
signal in_stop          : std_logic := '0';  -- Sets when valid in stops early
signal finished         : std_logic := '0';

begin
    
    pixel_no <= s_pixel_no;
    


REG_GEN:
    for i in 0 to 8 generate
        output(i*8+7 downto i*8) <= regs(i);
    end generate; 

    
FIFO_GEN: 
    for i in 1 to 3 generate
    FIFO_32_GEN: if N = 32 generate
        FIFO_32_MODULE: fifo_32
            port map(
                clk => clk,
                srst => rst,
                din => data(i-1),
                wr_en => wr_en(i),
                rd_en => rd_en(i),
                dout => data(i),
                full => full(i),
                empty => empty(i)
            );
        end generate;
        
        FIFO_64_GEN: if N = 64 generate
        FIFO_64_MODULE: fifo_64 
            port map(
                clk => clk,
                srst => rst,
                din => data(i-1),
                wr_en => wr_en(i),
                rd_en => rd_en(i),
                dout => data(i),
                full => full(i),
                empty => empty(i)
            );
        end generate;
         
        FIFO_128_GEN: if N = 128 generate
        FIFO_128_MODULE: fifo_128 
            port map(
                clk => clk,
                srst => rst,
                din => data(i-1),
                wr_en => wr_en(i),
                rd_en => rd_en(i),
                dout => data(i),
                full => full(i),
                empty => empty(i)
            );
        end generate;
        
        FIFO_1024_GEN: if N = 1024 generate
        FIFO_1024_MODULE: fifo_1024 
            port map(
                clk => clk,
                srst => rst,
                din => data(i-1),
                wr_en => wr_en(i),
                rd_en => rd_en(i),
                dout => data(i),
                full => full(i),
                empty => empty(i)
            );
        end generate;
    end generate; 


    process(clk)
    begin
        if(rising_edge(clk)) then
            if rst = '1' then
                for i in 0 to 8 loop
                    regs(i) <= (others => '0');
                end loop;
            else    
                
                -- New Image Reset
                if new_image = '1' then
                    s_pixel_no <= (others => '0');
                    valid_in_count <= (others => '0');     --Start Counting Inputs
                    valid_out <= '0';
                    full_image <= '0';
                    wr_en(3) <= '0';
                    rd_en(2) <= '0';
                    rd_en(3) <= '0';
                    in_stop <= '0';
                end if;
                
                data(0) <= input;
                
                -- Input Counter
                if valid_in = '1' then
                    if valid_in_count < std_logic_vector(to_unsigned(N*N-1,2*LOGN)) then 
                        valid_in_count <= valid_in_count + 1;
                    end if;
                end if;
                        
                -- Valid Out & Out Counter
                
                if valid_in_count = std_logic_vector(to_unsigned(N+4,2*LOGN)) and (in_stop = '0') and (finished = '0') then 
                    valid_out <= '1';
                elsif valid_in_count > std_logic_vector(to_unsigned(N+4,2*LOGN)) and (in_stop = '0') and (finished = '0') then 
                    valid_out <= '1';
                    -- Increase pixel_no output
                    s_pixel_no <= s_pixel_no + 1;
                else
                    valid_out <= '0';
                end if;
            
                -- All inputs received signal
                if valid_in_count = std_logic_vector(to_unsigned(N*N-1,2*LOGN)) then
                    full_image <= '1'; -- Set full_image flag so the module runs without valid in
                end if;
            
                -- Image Finished -> Stop
                if s_pixel_no = std_logic_vector(to_unsigned(N*N-1,2*LOGN)) then 
                    valid_out <= '0';
                    finished <= '1';
                    full_image <= '0';
                end if;
            
                -- Fifo enable signals
                wr_en(1) <= valid_in;
                wr_en(2) <= rd_en(1);
                rd_en(1) <= valid_in or full_image;
                                                                
                if valid_in_count >= std_logic_vector(to_unsigned(N,2*LOGN)) then
                    -- Enable the 2nd FIFO 
                    wr_en(3) <= rd_en(2);
                    rd_en(2) <= valid_in or full_image;
                end if;   
                
                if valid_in_count >= std_logic_vector(to_unsigned(2*N,2*LOGN)) then
                    -- Enable the 3rd FIFO 
                    rd_en(3) <= valid_in or full_image;                  
                end if;
                   
                -- Register Shift When the system runs
                if in_stop = '0'  then 
                    for i in 0 to 2 loop
                        regs(3*i) <= data(i+1);
                        regs(3*i+1) <= regs(3*i); 
                        regs(3*i+2) <= regs(3*i+1); 
                    end loop;     
                end if;         
                
                -- Check for input hault
                in_stop <= valid_in nor full_image;                   
            end if;                 
        end if;         
    end process;  
    
end architecture;
