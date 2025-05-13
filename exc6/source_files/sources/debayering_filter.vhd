library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real."log2";


entity debayering_filter is
    generic( N : integer := 32);
    port(
        clk         : in std_logic;
        rst_n       : in std_logic; -- Negative logic
        new_image   : in std_logic;
        valid_in    : in std_logic; 
        pixel       : in std_logic_vector(7 downto 0); 
        image_finished  : out std_logic;
        valid_out   : out std_logic; 
        R           : out std_logic_vector(7 downto 0); 
        G           : out std_logic_vector(7 downto 0); 
        B           : out std_logic_vector(7 downto 0)
    );
    
end debayering_filter;


architecture Behavioral of debayering_filter is

    component ser2par is
    generic(N   : integer := N);
    port(
        clk     : IN STD_LOGIC;
        rst     : IN STD_LOGIC; -- resets on '1'
        input   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        valid_in: IN STD_LOGIC;
        new_image   : IN STD_LOGIC;
        valid_out   : OUT STD_LOGIC := '0';
        output  : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
        pixel_no    : OUT STD_LOGIC_VECTOR(2 * integer(log2(real(N)))-1 downto 0)
    );
    end component;
    
    
    component compute_unit is
    generic(N : integer := N);
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        input       : in std_logic_vector(71 downto 0);
        pixel_no    : in std_logic_vector(2 * integer(log2(real(N)))-1 downto 0);
        valid_in    : in std_logic;
        R,G,B       : out std_logic_vector(7 downto 0) := (others => '0');
        valid_out   : out std_logic := '0';
        image_finished     : out std_logic := '0' 
    );
    end component;
    
    
    component edge_corrector is
    generic(N : integer := N);
    port(
        clk : in std_logic;
        valid_in: in std_logic;
        valid_out   : out std_logic := '0';
        state_in    : in std_logic_vector(2 * integer(log2(real(N)))-1 downto 0);
        state_out   : out std_logic_vector(2 * integer(log2(real(N)))-1 downto 0);
        data_in     : in std_logic_vector(71 downto 0);
        data_out    : out std_logic_vector(71 downto 0)
    );
    end component;
    
    type data_arr is array (2 downto 0) of std_logic_vector(71 downto 0);
    signal s_data : data_arr := (others => (others => '0'));
    
    type state_arr is array (1 downto 0) of std_logic_vector(2 * integer(log2(real(N)))-1 downto 0);
    signal s_state : state_arr := (others => (others => '0'));

    signal s_valid_out    : std_logic_vector(2 downto 0);
    signal s_rst    : std_logic := '0';
begin

    s_rst <= not rst_n;
    
SER_INST: ser2par
    port map(
        clk     => clk,
        rst     => s_rst,
        input   => pixel,
        valid_in    => valid_in,
        new_image   => new_image,
        valid_out   => s_valid_out(0),
        output      => s_data(0),
        pixel_no    => s_state(0)
    );
    
EDGE_INST: edge_corrector
    port map(
        clk => clk,
        valid_in    => s_valid_out(0),
        valid_out   => s_valid_out(1),
        state_in    => s_state(0),
        state_out   => s_state(1),
        data_in     => s_data(0),
        data_out    => s_data(1)
    );
    
COMP_INST: compute_unit
    port map(
        clk     => clk,
        rst     => s_rst,
        input   => s_data(1),
        pixel_no    => s_state(1),
        valid_in    => s_valid_out(1),
        R   => R,
        G   => G,
        B   => B,
        valid_out       => valid_out,
        image_finished  => image_finished    
    );

end Behavioral;
